Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 55F0D6B0055
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 06:03:40 -0400 (EDT)
Subject: [patch] proc.txt: Update kernel filesystem/proc.txt documentation
From: Stefani Seibold <stefani@seibold.net>
In-Reply-To: <20090401193135.GA12316@elte.hu>
References: <1238511505.364.61.camel@matrix>
	 <20090401193135.GA12316@elte.hu>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 09 Jun 2009 12:35:58 +0200
Message-Id: <1244543758.13948.5.camel@wall-e>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This is a patch against the file Documentation/filesystem/proc.txt.

It is an update for the "Process-Specific Subdirectories" to reflect=20
the changes till kernel 2.6.30. It also introduce the my=20
"provide stack information for threads".
=20
 proc.txt |  210 ++++++++++++++++++++++++++++++++++++++++++++++++++++------=
-----
 1 file changed, 176 insertions(+), 34 deletions(-)

Signed-off-by: Stefani Seibold <stefani@seibold.net>

Signed-off-by: Stefani Seibold <stefani@seibold.net>

diff -u -N -r linux-2.6.30.orig/Documentation/filesystems/proc.txt linux-2.=
6.30/Documentation/filesystems/proc.txt
--- linux-2.6.30.orig/Documentation/filesystems/proc.txt	2009-06-04 09:29:4=
3.000000000 +0200
+++ linux-2.6.30/Documentation/filesystems/proc.txt	2009-06-09 12:26:25.000=
000000 +0200
@@ -10,6 +10,7 @@
 Version 1.3                                              Kernel version 2.=
2.12
 					      Kernel version 2.4.0-test11-pre4
 --------------------------------------------------------------------------=
----
+2.6.30 fixes/update  Stefani Seibold <stefani@seibold.net>      June 9 200=
9
=20
 Table of Contents
 -----------------
@@ -134,7 +135,8 @@
  status		Process status in human readable form
  wchan		If CONFIG_KALLSYMS is set, a pre-decoded wchan
  stack		Report full stack trace, enable via CONFIG_STACKTRACE
- smaps		Extension based on maps, the rss size for each mapped file
+ smaps		a extension based on maps, showing the memory consumption of
+               each mapping
 ..........................................................................=
....
=20
 For example, to get the status information of a process, all you have to d=
o is
@@ -143,37 +145,95 @@
   >cat /proc/self/status=20
   Name:   cat=20
   State:  R (running)=20
+  Tgid:   5452
   Pid:    5452=20
   PPid:   743=20
   TracerPid:      0						(2.4)
   Uid:    501     501     501     501=20
   Gid:    100     100     100     100=20
+  FDSize: 256
   Groups: 100 14 16=20
-  VmSize:     1112 kB=20
+  VmPeak:     5004 kB=20
+  VmSize:     5004 kB=20
   VmLck:         0 kB=20
-  VmRSS:       348 kB=20
-  VmData:       24 kB=20
-  VmStk:        12 kB=20
-  VmExe:         8 kB=20
-  VmLib:      1044 kB=20
+  VmHWM:       476 kB=20
+  VmRSS:       476 kB=20
+  VmData:      156 kB=20
+  VmStk:        88 kB=20
+  VmExe:        68 kB=20
+  VmLib:      1412 kB=20
+  VmPTE:        20 kb
+  Threads:        1
+  SigQ:   0/28578
   SigPnd: 0000000000000000=20
+  ShdPnd: 0000000000000000=20
   SigBlk: 0000000000000000=20
   SigIgn: 0000000000000000=20
   SigCgt: 0000000000000000=20
   CapInh: 00000000fffffeff=20
   CapPrm: 0000000000000000=20
   CapEff: 0000000000000000=20
-
+  CapBnd: ffffffffffffffff
+  voluntary_ctxt_switches:        0
+  nonvoluntary_ctxt_switches:     1
+  Stack usage:    12 kB
=20
 This shows you nearly the same information you would get if you viewed it =
with
 the ps  command.  In  fact,  ps  uses  the  proc  file  system  to  obtain=
 its
-information. The  statm  file  contains  more  detailed  information about=
 the
-process memory usage. Its seven fields are explained in Table 1-2.  The st=
at
-file contains details information about the process itself.  Its fields ar=
e
-explained in Table 1-3.
+information.  But you get a more detailed  view of the  process by reading=
 the
+file /proc/PID/status. It fields are described in table 1-2.
=20
+The  statm  file  contains  more  detailed  information about the process
+memory usage. Its seven fields are explained in Table 1-3.  The stat file
+contains details information about the process itself.  Its fields are
+explained in Table 1-4.
+
+Table 1-2: Contents of the statm files (as of 2.6.30-rc7)
+..........................................................................=
....
+ Field                       Content
+ Name                        filename of the executable
+ State                       state (R is running, S is sleeping, D is slee=
ping
+                             in an uninterruptible wait, Z is zombie,
+			     T is traced or stopped)
+ Tgid                        thread group ID
+ Pid                         process id
+ PPid                        process id of the parent process
+ TracerPid                   PID of process tracing this process (0 if not=
)=20
+ Uid                         Real, effective, saved set, and  file system =
UIDs
+ Gid                         Real, effective, saved set, and  file system =
GIDs
+ FDSize                      number of file descriptor slots currently all=
ocated
+ Groups                      supplementary group list
+ VmPeak                      peak virtual memory size
+ VmSize                      total program size
+ VmLck                       locked memory size
+ VmHWM                       peak resident set size ("high water mark")
+ VmRSS                       size of memory portions
+ VmData                      size of data, stack, and text segments
+ VmStk                       size of data, stack, and text segments
+ VmExe                       size of text segment
+ VmLib                       size of shared library code
+ VmPTE                       size of page table entries
+ Threads                     number of threads
+ SigQ                        number of signals queued/max. number for queu=
e
+ SigPnd                      bitmap of pending signals for the thread
+ ShdPnd                      bitmap of shared pending signals for the proc=
ess
+ SigBlk                      bitmap of blocked signals
+ SigIgn                      bitmap of ignored signals
+ SigCgt                      bitmap of catched signals
+ CapInh                      bitmap of inheritable capabilities
+ CapPrm                      bitmap of permitted capabilities
+ CapEff                      bitmap of effective capabilities
+ CapBnd                      bitmap of capabilities bounding set
+ Cpus_allowed                mask of CPUs on which this process may run
+ Cpus_allowed_list           Same as previous, but in "list format"
+ Mems_allowed                mask of memory nodes allowed to this process
+ Mems_allowed_list           Same as previous, but in "list format"
+ voluntary_ctxt_switches     number of voluntary context switches
+ nonvoluntary_ctxt_switches  number of non voluntary context switches
+ Stack usage:                stack usage high water mark (round up to page=
 size)
+..........................................................................=
....
=20
-Table 1-2: Contents of the statm files (as of 2.6.8-rc3)
+Table 1-3: Contents of the statm files (as of 2.6.8-rc3)
 ..........................................................................=
....
  Field    Content
  size     total program size (pages)		(same as VmSize in status)
@@ -188,7 +248,7 @@
 ..........................................................................=
....
=20
=20
-Table 1-3: Contents of the stat files (as of 2.6.22-rc3)
+Table 1-4: Contents of the stat files (as of 2.6.30-rc7)
 ..........................................................................=
....
  Field          Content
   pid           process id
@@ -222,10 +282,10 @@
   start_stack   address of the start of the stack
   esp           current value of ESP
   eip           current value of EIP
-  pending       bitmap of pending signals (obsolete)
-  blocked       bitmap of blocked signals (obsolete)
-  sigign        bitmap of ignored signals (obsolete)
-  sigcatch      bitmap of catched signals (obsolete)
+  pending       bitmap of pending signals
+  blocked       bitmap of blocked signals
+  sigign        bitmap of ignored signals
+  sigcatch      bitmap of catched signals
   wchan         address where process went to sleep
   0             (place holder)
   0             (place holder)
@@ -234,19 +294,101 @@
   rt_priority   realtime priority
   policy        scheduling policy (man sched_setscheduler)
   blkio_ticks   time spent waiting for block IO
+  gtime         guest time of the task in jiffies
+  cgtime        guest time of the task children in jiffies
 ..........................................................................=
....
=20
+The /proc/PID/map file containing the currently mapped memory regions and
+their access permissions.
+
+The format is:
+
+address           perms offset  dev   inode      pathname
+
+08048000-08049000 r-xp 00000000 03:00 8312       /opt/test
+08049000-0804a000 rw-p 00001000 03:00 8312       /opt/test
+0804a000-0806b000 rw-p 00000000 00:00 0          [heap]
+a7cb1000-a7cb2000 ---p 00000000 00:00 0=20
+a7cb2000-a7eb2000 rw-p 00000000 00:00 0          [thread stack: a7eb14b4]
+a7eb2000-a7eb3000 ---p 00000000 00:00 0=20
+a7eb3000-a7ed5000 rw-p 00000000 00:00 0=20
+a7ed5000-a8008000 r-xp 00000000 03:00 4222       /lib/libc.so.6
+a8008000-a800a000 r--p 00133000 03:00 4222       /lib/libc.so.6
+a800a000-a800b000 rw-p 00135000 03:00 4222       /lib/libc.so.6
+a800b000-a800e000 rw-p 00000000 00:00 0=20
+a800e000-a8022000 r-xp 00000000 03:00 14462      /lib/libpthread.so.0
+a8022000-a8023000 r--p 00013000 03:00 14462      /lib/libpthread.so.0
+a8023000-a8024000 rw-p 00014000 03:00 14462      /lib/libpthread.so.0
+a8024000-a8027000 rw-p 00000000 00:00 0=20
+a8027000-a8043000 r-xp 00000000 03:00 8317       /lib/ld-linux.so.2
+a8043000-a8044000 r--p 0001b000 03:00 8317       /lib/ld-linux.so.2
+a8044000-a8045000 rw-p 0001c000 03:00 8317       /lib/ld-linux.so.2
+aff35000-aff4a000 rw-p 00000000 00:00 0          [stack]
+ffffe000-fffff000 r-xp 00000000 00:00 0          [vdso]
+
+where "address" is the address space in the process that it occupies, "per=
ms"
+is a set of permissions:
+
+ r =3D read
+ w =3D write
+ x =3D execute
+ s =3D shared
+ p =3D private (copy on write)
+
+"offset" is the offset into the mapping, "dev" is the device (major:minor)=
, and
+"inode" is the inode  on that device.  0 indicates that  no inode is assoc=
iated
+with the memory region, as the case would be with BSS (uninitialized data)=
.
+The "pathname" shows the name associated file for this mapping.  If the ma=
pping
+is not associated with a file:
+
+ [heap]                   =3D the heap of the program
+ [stack]                  =3D the stack of the main process
+ [vdso]                   =3D the "virtual dynamic shared object",
+                            the kernel system call handler
+ [thread stack, xxxxxxxx] =3D the stack of the thread, xxxxxxxx is the sta=
rting
+                            address of the stack
+
+ or if empty, the mapping is anonymous.
+
+
+The /proc/PID/smaps is an extension based on maps, showing the memory
+consumption for each of the process's mappings. For each of mappings there
+is a series of lines such as the following:
+
+08048000-080bc000 r-xp 00000000 03:02 13130      /bin/bash
+Size:               1084 kB
+Rss:                 892 kB
+Pss:                 374 kB
+Shared_Clean:        892 kB
+Shared_Dirty:          0 kB
+Private_Clean:         0 kB
+Private_Dirty:         0 kB
+Referenced:          892 kB
+Swap:                  0 kB
+KernelPageSize:        4 kB
+MMUPageSize:           4 kB
+
+The first  of these lines shows  the same information  as is displayed for=
 the
+mapping in /proc/PID/maps.  The remaining lines show  the size of the mapp=
ing,
+the amount of the mapping that is currently resident in RAM, the "proporti=
onal
+set size=E2=80=9D (divide each shared page by the number of processes shar=
ing it), the
+number of clean and dirty shared pages in the mapping, and the number of c=
lean
+and dirty private pages in the mapping.  The "Referenced" indicates the am=
ount
+of memory currently marked as referenced or accessed.
+
+This file is only present if the CONFIG_MMU kernel configuration option is=
=20
+enabled.
=20
 1.2 Kernel data
 ---------------
=20
 Similar to  the  process entries, the kernel data files give information a=
bout
 the running kernel. The files used to obtain this information are containe=
d in
-/proc and  are  listed  in Table 1-4. Not all of these will be present in =
your
+/proc and  are  listed  in Table 1-5. Not all of these will be present in =
your
 system. It  depends  on the kernel configuration and the loaded modules, w=
hich
 files are there, and which are missing.
=20
-Table 1-4: Kernel info in /proc
+Table 1-5: Kernel info in /proc
 ..........................................................................=
....
  File        Content                                          =20
  apm         Advanced power management info                   =20
@@ -614,10 +756,10 @@
=20
 More detailed  information  can  be  found  in  the  controller  specific
 subdirectories. These  are  named  ide0,  ide1  and  so  on.  Each  of  th=
ese
-directories contains the files shown in table 1-5.
+directories contains the files shown in table 1-6.
=20
=20
-Table 1-5: IDE controller info in  /proc/ide/ide?
+Table 1-6: IDE controller info in  /proc/ide/ide?
 ..........................................................................=
....
  File    Content                                =20
  channel IDE channel (0 or 1)                   =20
@@ -627,11 +769,11 @@
 ..........................................................................=
....
=20
 Each device  connected  to  a  controller  has  a separate subdirectory in=
 the
-controllers directory.  The  files  listed in table 1-6 are contained in t=
hese
+controllers directory.  The  files  listed in table 1-7 are contained in t=
hese
 directories.
=20
=20
-Table 1-6: IDE device information
+Table 1-7: IDE device information
 ..........................................................................=
....
  File             Content                                   =20
  cache            The cache                                 =20
@@ -673,12 +815,12 @@
 1.4 Networking info in /proc/net
 --------------------------------
=20
-The subdirectory  /proc/net  follows  the  usual  pattern. Table 1-6 shows=
 the
+The subdirectory  /proc/net  follows  the  usual  pattern. Table 1-8 shows=
 the
 additional values  you  get  for  IP  version 6 if you configure the kerne=
l to
-support this. Table 1-7 lists the files and their meaning.
+support this. Table 1-9 lists the files and their meaning.
=20
=20
-Table 1-6: IPv6 info in /proc/net=20
+Table 1-8: IPv6 info in /proc/net=20
 ..........................................................................=
....
  File       Content                                              =20
  udp6       UDP sockets (IPv6)                                   =20
@@ -693,7 +835,7 @@
 ..........................................................................=
....
=20
=20
-Table 1-7: Network info in /proc/net=20
+Table 1-9: Network info in /proc/net=20
 ..........................................................................=
....
  File          Content                                                    =
    =20
  arp           Kernel  ARP table                                          =
    =20
@@ -817,10 +959,10 @@
 your system.  It  has  one  subdirectory  for  each port, named after the =
port
 number (0,1,2,...).
=20
-These directories contain the four files shown in Table 1-8.
+These directories contain the four files shown in Table 1-10.
=20
=20
-Table 1-8: Files in /proc/parport=20
+Table 1-10: Files in /proc/parport=20
 ..........................................................................=
....
  File      Content                                                        =
    =20
  autoprobe Any IEEE-1284 device ID information that has been acquired.    =
    =20
@@ -838,10 +980,10 @@
=20
 Information about  the  available  and actually used tty's can be found in=
 the
 directory /proc/tty.You'll  find  entries  for drivers and line discipline=
s in
-this directory, as shown in Table 1-9.
+this directory, as shown in Table 1-11.
=20
=20
-Table 1-9: Files in /proc/tty=20
+Table 1-11: Files in /proc/tty=20
 ..........................................................................=
....
  File          Content                                       =20
  drivers       list of drivers and their usage               =20
@@ -926,9 +1068,9 @@
 /proc/fs/ext4.  Each mounted filesystem will have a directory in
 /proc/fs/ext4 based on its device name (i.e., /proc/fs/ext4/hdc or
 /proc/fs/ext4/dm-0).   The files in each per-device directory are shown
-in Table 1-10, below.
+in Table 1-12, below.
=20
-Table 1-10: Files in /proc/fs/ext4/<devname>
+Table 1-12: Files in /proc/fs/ext4/<devname>
 ..........................................................................=
....
  File            Content                                       =20
  mb_groups       details of multiblock allocator buddy cache of free block=
s


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
