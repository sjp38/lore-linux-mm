Subject: Re: [PATCH] VM kswapd autotuning vs. -ac7
References: <Pine.LNX.4.21.0006031746410.5754-100000@duckman.distro.conectiva> <qww7lc5wvhx.fsf@sap.com>
From: Christoph Rohland <cr@sap.com>
Date: 05 Jun 2000 10:58:48 +0200
Message-ID: <qwwvgzov707.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Rohland <cr@sap.com> writes:

> From a short view #3 looks much better, but one thing is disturbing me:
> 
> 12  0  0      0 492440   1604  10200   0   0     0     0  104 72356   5  94   1
> shmget: Cannot allocate memory
>  9  2  1   8992 610136    148  13840   0 1798     3   452 1581 83181   0  90   9
> 
> it begins swapping with 490MB free and fails to allocate a shm segment?

O.k. more (not that nice) data from the same run:

3  9  1 235720   2404     96  12576  58 18585    21  4648 13905 35860   0  85
15
VM: killing process ipctst
 4  6  1  11004 113588    100  19804  78 39615    20  9904 2542 27828   0  16  83
VM: killing process ipctst
VM: killing process ipctst
shmget: Cannot allocate memory
VM: killing process ipctst
 3  3  1 109996   3176     96  13884 239 20720    63  5180 1312 132803   1  38
61
VM: killing process ipctst
 0  5  1 264652   2012     96  13544   2 30912     0  7728 1636 11053   0  10  90 
[...] Killing until only one ipctst is running and then a long time no swap
 1  0  0 282760 606512    116  11360   0   0     0     0  107  1272   1  11  87
 1  0  0 282760 656164    116  11360   0   0     0     0  103     2   1  12  87
 1  0  0 282760   4664    116  11360   0   0     0     0  105     2   1  12  87
4294967295  1  1 323808   2032     96  12828   1 8226     0  2057  533  1600   1   7  92
VM: killing process vmstat
VM: killing process bash
VM: killing process init
NMI Watchdog detected LOCKUP on CPU6, registers:                               CPU:    6
EIP:    0010:[<c011efed>]
EFLAGS: 00000002
eax: c1088000   ebx: f7400000   ecx: c02c20a4   edx: c02c20a4
esi: 00000368   edi: c1088000   ebp: c1088000   esp: c1089eec
ds: 0018   es: 0018   ss: 0018
Process init (pid: 1, stackpage=c1089000)
Stack: c1088000 c0289c60 00000009 08050054 c011f362 00000004 c3fce05c c1088000
       c0114304 00000009 c1088000 0804ff80 40105720 bffff68c c3fcc200 c3fce078
       c3fce078 c3fce05c c3fce040 bffffa50 bffff9d0 00030002 ffffffff c1089fa4
Call Trace: [<c011f362>] [<c0114304>] [<c010b125>]
Call Trace: [<c011f362>] [<c0114304>] [<c010b125>]
Code: 89 83 80 00 00 00 8b 80 84 00 00 00 89 83 8c 00 00 00 85 c0

>>EIP; c011efed <exit_notify+165/270>   <=====
Trace; c011f362 <do_exit+26a/2ac>
Trace; c0114304 <do_page_fault+4b4/570>
Trace; c010b125 <error_code+2d/38>
Code: 89 83 80 00 00 00 8b 80 84 00 00 00 89 83 8c 00 00 00 85 c0
Code;  c011efed <exit_notify+165/270>
00000000 <_EIP>:
Code;  c011efed <exit_notify+165/270>   <=====
   0:   89 83 80 00 00 00         movl   %eax,0x80(%ebx)   <=====
Code;  c011eff3 <exit_notify+16b/270>
   6:   8b 80 84 00 00 00         movl   0x84(%eax),%eax
Code;  c011eff9 <exit_notify+171/270>
   c:   89 83 8c 00 00 00         movl   %eax,0x8c(%ebx)
Code;  c011efff <exit_notify+177/270>
  12:   85 c0                     testl  %eax,%eax
console shuts up ...

Please note the ridiculous vmstat output before/while going
berserk. (But at least the kernel now notifies again when killing
processes)

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
