;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Windows 8.1 (probably works for others)
; Author:         Trevor Williams
;
; Script Function:
;	Creates various hotkeys that simplify setting up fights in the arena mode of Dwarf Fortress.

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn ; For debugging
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.

global ProgramDir := A_Desktop . "\df_40_11_arena"
global ProgramName := "Dwarf Fortress.exe"
global WindowSignature := "Dwarf Fortress ahk_class SDL_app"
global LogFile := ProgramDir . "\gamelog.txt"

SetWorkingDir %ProgramDir%  ; Ensures a consistent starting directory.

; Arena configuration variables
global RowSpace := 17
global ColumnSpace := 15

global RowCount := 8
global ColumnCount := 9

; Dwarf Fortress UI configuration variables
global ShiftStep := 10

; The "program" component of the script
DeleteFile(LogFile)
StartArena()
WinWaitClose, %WindowSignature%

ExitApp

; The "hotkey" component of the script

; Control-1 populates an entire grid of one character
^1::
CreateCreatureGrid(RowCount, ColumnCount, 1)
return

; Control-2 populates a row for one character
^2::
CreateCreatureGrid(1, ColumnCount, 1)
return

; Control-3 populates an entire grid of one pre-configured character
^3::
CreateCreatureGrid(RowCount, ColumnCount)
return

; Function definitions!

StartArena() {
	global WindowSignature

	if (!WinExist(WindowSignature))
	{
		global ProgramDir
		global ProgramName

		Run %ProgramDir%\%ProgramName%
		WinWaitActive, %WindowSignature%

		Send {Down 2}
		Send {Enter}
		Sleep, 4000 ; Wait for the arena to (mostly) finish initializing
		Send {Tab 2} ; Get rid of the useless large map display
		
		; Navigate to the "origin" (top-left arena)
		Send +{Up 4}
		Send +{Left 7}

		; Move cursor to the first creature creation location
		Send k
		Move("Left", 26)
		Move("Up", 7)
	}

	return
}

CreateCreatureGrid( rowCount, columnCount, runFighterMacro := 0 ) {
	currentRow = 0
	while currentRow < rowCount
	{
		currentColumn = 0
		while currentColumn < columnCount
		{
			if ( currentRow == 0 && currentColumn == 0 && runFighterMacro )
			{
				; Configure and create first fighter
				CreateFirstCreature()
			}
			else
			{
				CreateCreature()
			}

			currentColumn += 1
			if ( currentColumn != columnCount )
			{
				NextColumn()
			}
		}

		currentRow += 1
		if ( currentRow != rowCount )
		{
			OriginColumnReturn()
			NextRow()
		}
	}

	ReturnToOrigin()
	return
}

CreateFirstCreature() {
	Send, c^l
	Sleep, 6000
	Send, {Enter}

	return
}

CreateCreature() {
	Send, c{Enter}

	return
}

NextRow() {
	Move("Down", RowSpace)

	return
}

NextColumn() {
	Move("Right", ColumnSpace)

	return
}

OriginRowReturn() {
	Move("Up", (RowCount - 1) * RowSpace)

	return
}

OriginColumnReturn() {
	Move("Left", (ColumnCount - 1) * ColumnSpace)

	return
}

Move(direction, y) {
	Sleep, 10 ; Only needed in Input SetMode to avoid confusing Dwarf Fortress
	big_steps := y // ShiftStep
	Send +{%direction% %big_steps%}

	small_steps := Mod(y, ShiftStep)
	Send {%direction% %small_steps%}

	return
}

ReturnToOrigin() {
	OriginRowReturn()
	OriginColumnReturn()

	return
}

DeleteFile(fileName) {
	FileGetSize, fileSize, %fileName%
	if (fileSize) {
		try {
			FileRecycle, %fileName%
		}
		catch {
			MsgBox, Error deleting %fileName%
			Exit
		}
	}

	return
}
