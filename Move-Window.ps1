function Move-Window
{

param(
[Parameter(Mandatory=$True)]
   [int]$PosX,
[Parameter(Mandatory=$True)]
   [int]$PosY,
[Parameter(Mandatory=$True)]
   [int]$Width,
[Parameter(Mandatory=$True)]
   [int]$Height
)

$WinPosSignature=@' 
[DllImport("user32.dll")] 
public static extern IntPtr SetWindowPos(IntPtr hWnd, int hWndInsertAfter, int x, int Y, int cx, int cy, int wFlags);
'@

$ForeWindowSignature=@'
[DllImport("user32.dll")]
public static extern IntPtr GetForegroundWindow();
'@

# C# declarations
$WinPos = Add-Type -memberDefinition $WinPosSignature -name "Win32SetWindowPos" -Namespace Win32Functions -PassThru
$ForeWin = Add-Type -memberDefinition $ForeWindowSignature -name "Win32GetForegroundWindow" -Namespace Win32Functions -PassThru

$handle=$ForeWin::GetForegroundWindow();

#window handle, ? (0), pos x, pos y, width, height, ? (SWP_NOZORDER | SWP_SHOWWINDOW)
$WinPos::SetWindowPos($handle, 0, $PosX, $PosY, $Width, $Height, 0)
}

function Split-Window
{
Param([int]$shift)
$Signature=@'
[DllImport("user32.dll")]
public static extern bool GetWindowRect(IntPtr hwnd, out RECT lpRect);

public struct RECT
  {
    public int Left;        // x position of upper-left corner
    public int Top;         // y position of upper-left corner
    public int Right;       // x position of lower-right corner
    public int Bottom;      // y position of lower-right corner
  }
'@

$ForeWindowSignature=@'
[DllImport("user32.dll")]
public static extern IntPtr GetForegroundWindow();
'@

<#$Win = #>Add-Type -memberDefinition $Signature -name Wutils -Namespace WindowUtils -PassThru
$ForeWin = Add-Type -memberDefinition $ForeWindowSignature -name "Win32GetForegroundWindow" -Namespace Win32Functions -PassThru

$handle=$ForeWin::GetForegroundWindow();
$o = New-Object -TypeName System.Object            
$href = New-Object -TypeName System.RunTime.InteropServices.HandleRef -ArgumentList $o, $handle  

$Rectangle=New-Object WindowUtils.Wutils+RECT   #[System.Drawing.Rectangle]
[WindowUtils.Wutils]::GetWindowRect($href, [ref]$Rectangle);
Move-Window -PosX ($Rectangle.Left+$shift) -PosY $Rectangle.Top -Width 976 -Height 1058
}

function Minimize-Window
{
$AsyncSignature=@'
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
'@

$ForeWindowSignature=@'
[DllImport("user32.dll")]
public static extern IntPtr GetForegroundWindow();
'@

$ForeWin = Add-Type -memberDefinition $ForeWindowSignature -name "Win32GetForegroundWindow" -Namespace Win32Functions -PassThru
$handle=$ForeWin::GetForegroundWindow();

$AsyncWin = Add-Type -memberDefinition $AsyncSignature -name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru
$AsyncWin::ShowWindowAsync($handle, 2)
}