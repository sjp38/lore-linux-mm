Message-ID: <3A930E34.E24BF93E@amis.com>
Date: Tue, 20 Feb 2001 17:39:16 -0700
From: Eric Whiting <ewhiting@amis.com>
MIME-Version: 1.0
Subject: large mem, heavy paging issues (256M VmStk on Athlon)
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm working with an application in Lisp. It runs on a Solaris box and uses about 1.3G of RAM and 9M
stack before it exits after 2hours of running.

I have been trying to run the same application on linux. It's memory usage hits about 1.2G and then
it loses it's brain.

Under 2.4.2pre4 PIII SMP 800Mhz 1.2G physical 2G swap -- it seg faults with a stack size of 6M.

Under 2.4.2pre4 Athlon 1000Mhz 1.2G physical 2G swap -- it seg faults with a stack size of 256M.

None of the boxes are OC. Both have big memory set to 64G.

This problem is either 
1. an application problem
2. a linux vm/mm problem
3. a wacky HW problem.
4. ???


I keep dumps of /proc/$pid/status and /proc/$pid/maps to watch memory usage. (10s intervals for the
2 hours it takes before the seg fault happens). I even captured a full strace of the run one time. I
have not been able to figure out what might be wrong.

I think this might just be an application problem, but wanted to know if this sort of problem has
been seen before. The box does go crazy paging once I run it out of physical ram. 

Questions:
----------
Anyone have ideas? 
What other things can I do?
Why the athlon/PIII difference?

I'm dumping 2G of physical RAM into the PIII box tomorrow and I'll see what happens in the absense
of the killer paging. 

Thanks,
eric


Last valid status (for Athlon T-bird test):
-------------------------------------------
Name:   access
State:  R (running)
Pid:    597
PPid:   596
TracerPid:      0
Uid:    500     500     500     500
Gid:    100     100     100     100
FDSize: 256
Groups: 100 
VmSize:  1839028 kB
VmLck:         0 kB
VmRSS:   1057196 kB
VmData:  1553132 kB
VmStk:    252376 kB     <---- looks like we are in big trouble!!!!
VmExe:        12 kB
VmLib:      4196 kB
SigPnd: 0000000000000000
SigBlk: 0000000000000000
SigIgn: 8000000002000000
SigCgt: 00000000004154db
CapInh: 0000000000000000
CapPrm: 0000000000000000
CapEff: 0000000000000000




Last valid status (for PIII test):
----------------------------------
Name:   access          (no it is not the M$ access)
State:  R (running)
Pid:    1205
PPid:   1203
TracerPid:      0
Uid:    15041   15041   15041   15041
Gid:    21      21      21      21
FDSize: 256
Groups: 21 42 181 41 
VmSize:  1830076 kB
VmLck:         0 kB
VmRSS:   1159196 kB
VmData:  1790132 kB
VmStk:      6744 kB   
VmExe:        12 kB
VmLib:      3896 kB
SigPnd: 0000000000000000
SigBlk: 0000000000000000
SigIgn: 8000000002000000
SigCgt: 00000000004154db
CapInh: 0000000000000000
CapPrm: 0000000000000000
CapEff: 0000000000000000

Last valid maps output (for PIII)
-------------------------
08048000-0804b000 r-xp 00000000 00:0c 29261935   /home/pendsm1/access/bin11/linux/access
0804b000-0804d000 rw-p 00002000 00:0c 29261935   /home/pendsm1/access/bin11/linux/access
0804d000-0805a000 rwxp 00000000 00:00 0
40000000-40013000 r-xp 00000000 03:03 275293     /lib/ld-2.1.3.so
40013000-40014000 rw-p 00012000 03:03 275293     /lib/ld-2.1.3.so
40014000-40015000 r-xp 00000000 00:0c 29261965   /home/pendsm1/access/bin11/linux/climxm.so
40015000-40016000 rw-p 00000000 00:0c 29261965   /home/pendsm1/access/bin11/linux/climxm.so
4001d000-4001e000 rw-p 00000000 00:00 0
4001e000-4003a000 r-xp 00000000 03:03 275303     /lib/libm.so.6
4003a000-4003b000 rw-p 0001b000 03:03 275303     /lib/libm.so.6
4003b000-4003d000 r-xp 00000000 03:03 275302     /lib/libdl.so.2
4003d000-4003f000 rw-p 00001000 03:03 275302     /lib/libdl.so.2
4003f000-4011a000 r-xp 00000000 03:03 275298     /lib/libc.so.6
4011a000-4011f000 rw-p 000da000 03:03 275298     /lib/libc.so.6
4011f000-40122000 rw-p 00000000 00:00 0
40122000-40186000 r-xp 00000000 00:0c 29261971   /home/pendsm1/access/bin11/linux/libacl601.so
40186000-40192000 rw-p 00063000 00:0c 29261971   /home/pendsm1/access/bin11/linux/libacl601.so
40192000-401ac000 rw-p 00000000 00:00 0
401ac000-401b4000 r-xp 00000000 03:03 275309     /lib/libnss_files.so.2
401b4000-401b5000 rw-p 00007000 03:03 275309     /lib/libnss_files.so.2
401b5000-402c0000 r-xp 00000000 03:03 1151085    /usr/X11R6/LessTif/Motif1.2/lib/libXm.so.1.0.2
402c0000-402dc000 rw-p 0010a000 03:03 1151085    /usr/X11R6/LessTif/Motif1.2/lib/libXm.so.1.0.2
402dc000-402de000 rw-p 00000000 00:00 0
402de000-402eb000 r-xp 00000000 03:03 1167687    /usr/X11R6/lib/libXpm.so.4.11
402eb000-402ec000 rw-p 0000c000 03:03 1167687    /usr/X11R6/lib/libXpm.so.4.11
402ec000-402f9000 r-xp 00000000 03:03 1167677    /usr/X11R6/lib/libXext.so.6.4
402f9000-402fa000 rw-p 0000c000 03:03 1167677    /usr/X11R6/lib/libXext.so.6.4
402fa000-40343000 r-xp 00000000 03:03 1167689    /usr/X11R6/lib/libXt.so.6.0
40343000-40347000 rw-p 00048000 03:03 1167689    /usr/X11R6/lib/libXt.so.6.0
40347000-40348000 rw-p 00000000 00:00 0
40348000-40412000 r-xp 00000000 03:03 1167669    /usr/X11R6/lib/libX11.so.6.1
40412000-40417000 rw-p 000c9000 03:03 1167669    /usr/X11R6/lib/libX11.so.6.1
40417000-40418000 rw-p 00000000 00:00 0
40418000-40420000 r-xp 00000000 03:03 1167667    /usr/X11R6/lib/libSM.so.6.0
40420000-40422000 rw-p 00007000 03:03 1167667    /usr/X11R6/lib/libSM.so.6.0
40422000-40437000 r-xp 00000000 03:03 1167663    /usr/X11R6/lib/libICE.so.6.3
40437000-40438000 rw-p 00014000 03:03 1167663    /usr/X11R6/lib/libICE.so.6.3
40438000-4043a000 rw-p 00000000 00:00 0
50000000-51444000 rwxp 0000a000 00:0c 29261937   /home/pendsm1/access/bin11/linux/access-11-0r.dxl
51444000-5144a000 rwxp 00000000 00:00 0
5144a000-51848000 rwxp 0144e000 00:0c 29261937   /home/pendsm1/access/bin11/linux/access-11-0r.dxl
51848000-5184a000 rwxp 00000000 00:00 0
5184a000-51ac0000 rwxp 0184c000 00:0c 29261937   /home/pendsm1/access/bin11/linux/access-11-0r.dxl
51ac0000-51aca000 rwxp 00000000 00:00 0
51aca000-51c58000 rwxp 01ac2000 00:0c 29261937   /home/pendsm1/access/bin11/linux/access-11-0r.dxl
51c58000-51eca000 rwxp 00000000 00:00 0
51eca000-51ed4000 rwxp 01c50000 00:0c 29261937   /home/pendsm1/access/bin11/linux/access-11-0r.dxl
51ed4000-56898000 rwxp 00000000 00:00 0
56898000-57246000 rwxp 00000000 00:00 0
57246000-57bf4000 rwxp 00000000 00:00 0
57bf4000-582f4000 rwxp 00000000 00:00 0
582f4000-58834000 rwxp 00000000 00:00 0
58834000-58db4000 rwxp 00000000 00:00 0
58db4000-597f4000 rwxp 00000000 00:00 0
597f4000-5a5f4000 rwxp 00000000 00:00 0
5a5f4000-5b334000 rwxp 00000000 00:00 0
5b334000-5bdb4000 rwxp 00000000 00:00 0
5bdb4000-5c034000 rwxp 00000000 00:00 0
5c034000-5cd74000 rwxp 00000000 00:00 0
5cd74000-5e4f4000 rwxp 00000000 00:00 0
5e4f4000-5fb34000 rwxp 00000000 00:00 0
5fb34000-62674000 rwxp 00000000 00:00 0
62674000-65674000 rwxp 00000000 00:00 0
65674000-66e74000 rwxp 00000000 00:00 0
66e74000-67234000 rwxp 00000000 00:00 0
67234000-69234000 rwxp 00000000 00:00 0
69234000-6c574000 rwxp 00000000 00:00 0
6c574000-6ef74000 rwxp 00000000 00:00 0
6ef74000-70134000 rwxp 00000000 00:00 0
70134000-737b4000 rwxp 00000000 00:00 0
737b4000-77fb4000 rwxp 00000000 00:00 0
77fb4000-7b274000 rwxp 00000000 00:00 0
7b274000-7ce34000 rwxp 00000000 00:00 0
7ce34000-7f2b4000 rwxp 00000000 00:00 0
7f2b4000-82634000 rwxp 00000000 00:00 0
82634000-846f4000 rwxp 00000000 00:00 0
846f4000-bef5a000 rwxp 2cb00000 00:00 0
bf000000-bf008000 rwxp 01c68000 00:0c 29261937   /home/pendsm1/access/bin11/linux/access-11-0r.dxl
bf008000-bf0fa000 rwxp 00000000 00:00 0
bf96a000-c0000000 rwxp ff96b000 00:00 0
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
