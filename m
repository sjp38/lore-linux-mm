Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D2CA26B00AF
	for <linux-mm@kvack.org>; Thu, 14 May 2009 15:10:15 -0400 (EDT)
Message-Id: <6.2.5.6.2.20090514135429.0588f5a0@binnacle.cx>
Date: Thu, 14 May 2009 14:42:11 -0400
From: starlight@binnacle.cx
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of
  process with hugepage shared memory segments attached
In-Reply-To: <20090514174947.GA24837@csn.ul.ie>
References: <bug-13302-10286@http.bugzilla.kernel.org/>
 <20090513130846.d463cc1e.akpm@linux-foundation.org>
 <20090514105326.GA11770@csn.ul.ie>
 <20090514105926.GB11770@csn.ul.ie>
 <6.2.5.6.2.20090514131734.05890270@binnacle.cx>
 <20090514174947.GA24837@csn.ul.ie>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="=====================_1090478672==_"
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

--=====================_1090478672==_
Content-Type: text/plain; charset="us-ascii"

At 06:49 PM 5/14/2009 +0100, Mel Gorman wrote:
>Ok, I just tried that there - parent writing 30% of the shared memory
>before forking but still did not reproduce the problem :(

Maybe it makes a difference to have lots of RAM (16GB on this 
server), and about 1.5 GB of hugepage shared memory allocated in 
the forking process in about four segments.  Often have all free 
memory consumed by the file cache, but I don't belive this is 
necessary to produce the problem as it will happen even right 
after a reboot.  [RHEL5 meminfo attached]

Other possible factors:
   daemon is non-root but has explicit
      CAP_IPC_LOCK, CAP_NET_RAW, CAP_SYS_NICE set via
      'setcap cap_net_raw,cap_ipc_lock,cap_sys_nice+ep daemon'
   ulimit -Hl and -Sl are set to <unlimited>
   process group is set in /proc/sys/vm/hugetlb_shm_group
   /proc/sys/vm/nr_hugepages is set to 2048
   daemon has 200 threads at time of fork()
   shared memory segments explictly located [RHEL5 pmap -x attached]
   between fork & exec these syscalls are issued
      sched_getscheduler/sched_setscheduler
      getpriority/setpriority
      seteuid(getuid())
      setegid(getgid())
   with vfork() work-around, no syscalls are made before exec()

Don't think it's something anything specific to the DL160 (Intel E5430)
we have because the DL165 (Opteron 2354) also exhibits the problem.

Will run the test cases provided this weekend for certain and 
will let you know if bug is reproduced.

Have to go silent on this till the weekend.
--=====================_1090478672==_
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: attachment; filename="meminfo.txt"

MemTotal:     16443828 kB
MemFree:        105364 kB
Buffers:          8476 kB
Cached:       11626260 kB
SwapCached:          0 kB
Active:         121876 kB
Inactive:     11570788 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:     16443828 kB
LowFree:        105364 kB
SwapTotal:     2031608 kB
SwapFree:      2031396 kB
Dirty:          417224 kB
Writeback:           0 kB
AnonPages:       62700 kB
Mapped:          10640 kB
Slab:           416872 kB
PageTables:       1904 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:   8156368 kB
Committed_AS:    71692 kB
VmallocTotal: 34359738367 kB
VmallocUsed:    266280 kB
VmallocChunk: 34359471371 kB
HugePages_Total:  2048
HugePages_Free:    889
HugePages_Rsvd:      0
Hugepagesize:     2048 kB

--=====================_1090478672==_
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: attachment; filename="pmap.txt"

Address           Kbytes     RSS    Anon  Locked Mode   Mapping
0000000000400000    2976       -       -       - r-x--  daemon
00000000007e8000       8       -       -       - rw---  daemon
00000000007ea000     192       -       -       - rw---    [ anon ]
000000001546d000    9228       -       -       - rw---    [ anon ]
0000000040955000       4       -       -       - -----    [ anon ]
0000000040956000     128       -       -       - rw---    [ anon ]
0000000040976000       4       -       -       - -----    [ anon ]
0000000040977000     128       -       -       - rw---    [ anon ]
0000000040997000       4       -       -       - -----    [ anon ]
0000000040998000     128       -       -       - rw---    [ anon ]
00000000409b8000       4       -       -       - -----    [ anon ]
00000000409b9000     128       -       -       - rw---    [ anon ]
000000004193a000       4       -       -       - -----    [ anon ]
000000004193b000     128       -       -       - rw---    [ anon ]
000000004195b000       4       -       -       - -----    [ anon ]
000000004195c000     128       -       -       - rw---    [ anon ]
000000004197c000       4       -       -       - -----    [ anon ]
000000004197d000     128       -       -       - rw---    [ anon ]
000000004199d000       4       -       -       - -----    [ anon ]
000000004199e000     128       -       -       - rw---    [ anon ]
00000000419be000       4       -       -       - -----    [ anon ]
00000000419bf000     128       -       -       - rw---    [ anon ]
00000000419df000       4       -       -       - -----    [ anon ]
00000000419e0000     128       -       -       - rw---    [ anon ]
0000000041a00000       4       -       -       - -----    [ anon ]
0000000041a01000     128       -       -       - rw---    [ anon ]
0000000041a21000       4       -       -       - -----    [ anon ]
0000000041a22000     128       -       -       - rw---    [ anon ]
0000000041a42000       4       -       -       - -----    [ anon ]
0000000041a43000     128       -       -       - rw---    [ anon ]
0000000041a63000       4       -       -       - -----    [ anon ]
0000000041a64000     128       -       -       - rw---    [ anon ]
0000000041a84000       4       -       -       - -----    [ anon ]
0000000041a85000     128       -       -       - rw---    [ anon ]
0000000041aa5000       4       -       -       - -----    [ anon ]
0000000041aa6000     128       -       -       - rw---    [ anon ]
0000000041ac6000       4       -       -       - -----    [ anon ]
0000000041ac7000     128       -       -       - rw---    [ anon ]
0000000041ae7000       4       -       -       - -----    [ anon ]
0000000041ae8000     128       -       -       - rw---    [ anon ]
0000000041b08000       4       -       -       - -----    [ anon ]
0000000041b09000     128       -       -       - rw---    [ anon ]
0000000041b29000       4       -       -       - -----    [ anon ]
0000000041b2a000     128       -       -       - rw---    [ anon ]
0000000041b4a000       4       -       -       - -----    [ anon ]
0000000041b4b000     128       -       -       - rw---    [ anon ]
0000000041b6b000       4       -       -       - -----    [ anon ]
0000000041b6c000     128       -       -       - rw---    [ anon ]
0000000041b8c000       4       -       -       - -----    [ anon ]
0000000041b8d000     128       -       -       - rw---    [ anon ]
0000000041bad000       4       -       -       - -----    [ anon ]
0000000041bae000     128       -       -       - rw---    [ anon ]
0000000041bce000       4       -       -       - -----    [ anon ]
0000000041bcf000     128       -       -       - rw---    [ anon ]
0000000041bef000       4       -       -       - -----    [ anon ]
0000000041bf0000     128       -       -       - rw---    [ anon ]
0000000041c10000       4       -       -       - -----    [ anon ]
0000000041c11000     128       -       -       - rw---    [ anon ]
0000000041c31000       4       -       -       - -----    [ anon ]
0000000041c32000     128       -       -       - rw---    [ anon ]
0000000041c52000       4       -       -       - -----    [ anon ]
0000000041c53000     128       -       -       - rw---    [ anon ]
0000000041c73000       4       -       -       - -----    [ anon ]
0000000041c74000     128       -       -       - rw---    [ anon ]
0000000041c94000       4       -       -       - -----    [ anon ]
0000000041c95000     128       -       -       - rw---    [ anon ]
0000000041cb5000       4       -       -       - -----    [ anon ]
0000000041cb6000     128       -       -       - rw---    [ anon ]
0000000041cd6000       4       -       -       - -----    [ anon ]
0000000041cd7000     128       -       -       - rw---    [ anon ]
0000000041cf7000       4       -       -       - -----    [ anon ]
0000000041cf8000     128       -       -       - rw---    [ anon ]
0000000041d18000       4       -       -       - -----    [ anon ]
0000000041d19000     128       -       -       - rw---    [ anon ]
0000000041d39000       4       -       -       - -----    [ anon ]
0000000041d3a000     128       -       -       - rw---    [ anon ]
0000000041d5a000       4       -       -       - -----    [ anon ]
0000000041d5b000     128       -       -       - rw---    [ anon ]
0000000041d7b000       4       -       -       - -----    [ anon ]
0000000041d7c000     128       -       -       - rw---    [ anon ]
0000000041d9c000       4       -       -       - -----    [ anon ]
0000000041d9d000     128       -       -       - rw---    [ anon ]
0000000041dbd000       4       -       -       - -----    [ anon ]
0000000041dbe000     128       -       -       - rw---    [ anon ]
0000000041dde000       4       -       -       - -----    [ anon ]
0000000041ddf000     128       -       -       - rw---    [ anon ]
0000000041dff000       4       -       -       - -----    [ anon ]
0000000041e00000     128       -       -       - rw---    [ anon ]
0000000041e20000       4       -       -       - -----    [ anon ]
0000000041e21000     128       -       -       - rw---    [ anon ]
0000000041e41000       4       -       -       - -----    [ anon ]
0000000041e42000     128       -       -       - rw---    [ anon ]
0000000041e62000       4       -       -       - -----    [ anon ]
0000000041e63000     128       -       -       - rw---    [ anon ]
0000000041e83000       4       -       -       - -----    [ anon ]
0000000041e84000     128       -       -       - rw---    [ anon ]
0000000041ea4000       4       -       -       - -----    [ anon ]
0000000041ea5000     128       -       -       - rw---    [ anon ]
0000000041ec5000       4       -       -       - -----    [ anon ]
0000000041ec6000     128       -       -       - rw---    [ anon ]
0000000041ee6000       4       -       -       - -----    [ anon ]
0000000041ee7000     128       -       -       - rw---    [ anon ]
0000000041f07000       4       -       -       - -----    [ anon ]
0000000041f08000     128       -       -       - rw---    [ anon ]
0000000041f28000       4       -       -       - -----    [ anon ]
0000000041f29000     128       -       -       - rw---    [ anon ]
0000000041f49000       4       -       -       - -----    [ anon ]
0000000041f4a000     128       -       -       - rw---    [ anon ]
0000000041f6a000       4       -       -       - -----    [ anon ]
0000000041f6b000     128       -       -       - rw---    [ anon ]
0000000041f8b000       4       -       -       - -----    [ anon ]
0000000041f8c000     128       -       -       - rw---    [ anon ]
0000000041fac000       4       -       -       - -----    [ anon ]
0000000041fad000     128       -       -       - rw---    [ anon ]
0000000041fcd000       4       -       -       - -----    [ anon ]
0000000041fce000     128       -       -       - rw---    [ anon ]
0000000041fee000       4       -       -       - -----    [ anon ]
0000000041fef000     128       -       -       - rw---    [ anon ]
000000004200f000       4       -       -       - -----    [ anon ]
0000000042010000     128       -       -       - rw---    [ anon ]
0000000042030000       4       -       -       - -----    [ anon ]
0000000042031000     128       -       -       - rw---    [ anon ]
0000000042051000       4       -       -       - -----    [ anon ]
0000000042052000     128       -       -       - rw---    [ anon ]
0000000042072000       4       -       -       - -----    [ anon ]
0000000042073000     128       -       -       - rw---    [ anon ]
0000000042093000       4       -       -       - -----    [ anon ]
0000000042094000     128       -       -       - rw---    [ anon ]
00000000420b4000       4       -       -       - -----    [ anon ]
00000000420b5000     128       -       -       - rw---    [ anon ]
00000000420d5000       4       -       -       - -----    [ anon ]
00000000420d6000     128       -       -       - rw---    [ anon ]
00000000420f6000       4       -       -       - -----    [ anon ]
00000000420f7000     128       -       -       - rw---    [ anon ]
0000000042117000       4       -       -       - -----    [ anon ]
0000000042118000     128       -       -       - rw---    [ anon ]
0000000042138000       4       -       -       - -----    [ anon ]
0000000042139000     128       -       -       - rw---    [ anon ]
0000000042159000       4       -       -       - -----    [ anon ]
000000004215a000     128       -       -       - rw---    [ anon ]
000000004217a000       4       -       -       - -----    [ anon ]
000000004217b000     128       -       -       - rw---    [ anon ]
000000004219b000       4       -       -       - -----    [ anon ]
000000004219c000     128       -       -       - rw---    [ anon ]
00000000421bc000       4       -       -       - -----    [ anon ]
00000000421bd000     128       -       -       - rw---    [ anon ]
00000000421dd000       4       -       -       - -----    [ anon ]
00000000421de000     128       -       -       - rw---    [ anon ]
00000000421fe000       4       -       -       - -----    [ anon ]
00000000421ff000     128       -       -       - rw---    [ anon ]
000000004221f000       4       -       -       - -----    [ anon ]
0000000042220000     128       -       -       - rw---    [ anon ]
0000000042240000       4       -       -       - -----    [ anon ]
0000000042241000     128       -       -       - rw---    [ anon ]
0000000042261000       4       -       -       - -----    [ anon ]
0000000042262000     128       -       -       - rw---    [ anon ]
0000000042282000       4       -       -       - -----    [ anon ]
0000000042283000     128       -       -       - rw---    [ anon ]
00000000422a3000       4       -       -       - -----    [ anon ]
00000000422a4000     128       -       -       - rw---    [ anon ]
00000000422c4000       4       -       -       - -----    [ anon ]
00000000422c5000     128       -       -       - rw---    [ anon ]
00000000422e5000       4       -       -       - -----    [ anon ]
00000000422e6000     128       -       -       - rw---    [ anon ]
0000000042306000       4       -       -       - -----    [ anon ]
0000000042307000     128       -       -       - rw---    [ anon ]
0000000042327000       4       -       -       - -----    [ anon ]
0000000042328000     128       -       -       - rw---    [ anon ]
0000000042348000       4       -       -       - -----    [ anon ]
0000000042349000     128       -       -       - rw---    [ anon ]
0000000042369000       4       -       -       - -----    [ anon ]
000000004236a000     128       -       -       - rw---    [ anon ]
000000004238a000       4       -       -       - -----    [ anon ]
000000004238b000     128       -       -       - rw---    [ anon ]
00000000423ab000       4       -       -       - -----    [ anon ]
00000000423ac000     128       -       -       - rw---    [ anon ]
00000000423cc000       4       -       -       - -----    [ anon ]
00000000423cd000     128       -       -       - rw---    [ anon ]
00000000423ed000       4       -       -       - -----    [ anon ]
00000000423ee000     128       -       -       - rw---    [ anon ]
000000004240e000       4       -       -       - -----    [ anon ]
000000004240f000     128       -       -       - rw---    [ anon ]
000000004242f000       4       -       -       - -----    [ anon ]
0000000042430000     128       -       -       - rw---    [ anon ]
0000000042450000       4       -       -       - -----    [ anon ]
0000000042451000     128       -       -       - rw---    [ anon ]
0000000042471000       4       -       -       - -----    [ anon ]
0000000042472000     128       -       -       - rw---    [ anon ]
0000000042492000       4       -       -       - -----    [ anon ]
0000000042493000     128       -       -       - rw---    [ anon ]
00000000424b3000       4       -       -       - -----    [ anon ]
00000000424b4000     128       -       -       - rw---    [ anon ]
00000000424d4000       4       -       -       - -----    [ anon ]
00000000424d5000     128       -       -       - rw---    [ anon ]
00000000424f5000       4       -       -       - -----    [ anon ]
00000000424f6000     128       -       -       - rw---    [ anon ]
0000000042516000       4       -       -       - -----    [ anon ]
0000000042517000     128       -       -       - rw---    [ anon ]
0000000042537000       4       -       -       - -----    [ anon ]
0000000042538000     128       -       -       - rw---    [ anon ]
0000000042558000       4       -       -       - -----    [ anon ]
0000000042559000     128       -       -       - rw---    [ anon ]
0000000042579000       4       -       -       - -----    [ anon ]
000000004257a000     128       -       -       - rw---    [ anon ]
000000004259a000       4       -       -       - -----    [ anon ]
000000004259b000     128       -       -       - rw---    [ anon ]
00000000425bb000       4       -       -       - -----    [ anon ]
00000000425bc000     128       -       -       - rw---    [ anon ]
00000000425dc000       4       -       -       - -----    [ anon ]
00000000425dd000     128       -       -       - rw---    [ anon ]
00000000425fd000       4       -       -       - -----    [ anon ]
00000000425fe000     128       -       -       - rw---    [ anon ]
000000004261e000       4       -       -       - -----    [ anon ]
000000004261f000     128       -       -       - rw---    [ anon ]
000000004263f000       4       -       -       - -----    [ anon ]
0000000042640000     128       -       -       - rw---    [ anon ]
0000000042660000       4       -       -       - -----    [ anon ]
0000000042661000     128       -       -       - rw---    [ anon ]
0000000042681000       4       -       -       - -----    [ anon ]
0000000042682000     128       -       -       - rw---    [ anon ]
00000000426a2000       4       -       -       - -----    [ anon ]
00000000426a3000     128       -       -       - rw---    [ anon ]
00000000426c3000       4       -       -       - -----    [ anon ]
00000000426c4000     128       -       -       - rw---    [ anon ]
00000000426e4000       4       -       -       - -----    [ anon ]
00000000426e5000     128       -       -       - rw---    [ anon ]
0000000042705000       4       -       -       - -----    [ anon ]
0000000042706000     128       -       -       - rw---    [ anon ]
0000000042726000       4       -       -       - -----    [ anon ]
0000000042727000     128       -       -       - rw---    [ anon ]
0000000042747000       4       -       -       - -----    [ anon ]
0000000042748000     128       -       -       - rw---    [ anon ]
0000000042768000       4       -       -       - -----    [ anon ]
0000000042769000     128       -       -       - rw---    [ anon ]
0000000042789000       4       -       -       - -----    [ anon ]
000000004278a000     128       -       -       - rw---    [ anon ]
00000000427aa000       4       -       -       - -----    [ anon ]
00000000427ab000     128       -       -       - rw---    [ anon ]
00000000427cb000       4       -       -       - -----    [ anon ]
00000000427cc000     128       -       -       - rw---    [ anon ]
00000000427ec000       4       -       -       - -----    [ anon ]
00000000427ed000     128       -       -       - rw---    [ anon ]
000000004280d000       4       -       -       - -----    [ anon ]
000000004280e000      28       -       -       - rw---    [ anon ]
0000000042815000       4       -       -       - -----    [ anon ]
0000000042816000      28       -       -       - rw---    [ anon ]
000000004281d000       4       -       -       - -----    [ anon ]
000000004281e000      28       -       -       - rw---    [ anon ]
0000000042825000       4       -       -       - -----    [ anon ]
0000000042826000      28       -       -       - rw---    [ anon ]
000000004282d000       4       -       -       - -----    [ anon ]
000000004282e000      28       -       -       - rw---    [ anon ]
0000000042835000       4       -       -       - -----    [ anon ]
0000000042836000      28       -       -       - rw---    [ anon ]
000000004283d000       4       -       -       - -----    [ anon ]
000000004283e000      28       -       -       - rw---    [ anon ]
0000000042845000       4       -       -       - -----    [ anon ]
0000000042846000      28       -       -       - rw---    [ anon ]
000000004284d000       4       -       -       - -----    [ anon ]
000000004284e000      28       -       -       - rw---    [ anon ]
0000000300000000  524288       -       -       - rw-s-  9 (deleted)
0000000330000000  131072       -       -       - rw-s-  6 (deleted)
00000003c0000000   98304       -       -       - rw-s-  8 (deleted)
00000003d8000000  169984       -       -       - rw-s-  5 (deleted)
00000003f0000000    2048       -       -       - rw-s-  1 (deleted)
00000003f0400000    2048       -       -       - rw-s-  7 (deleted)
0000000400000000 1048576       -       -       - rw-s-  3 (deleted)
0000000580000000  262144       -       -       - rw-s-  4 (deleted)
0000000600000000  131072       -       -       - rw-s-  2 (deleted)
00000032d5400000     112       -       -       - r-x--  ld-2.5.so
00000032d561b000       4       -       -       - r----  ld-2.5.so
00000032d561c000       4       -       -       - rw---  ld-2.5.so
00000032d5800000    1328       -       -       - r-x--  libc-2.5.so
00000032d594c000    2048       -       -       - -----  libc-2.5.so
00000032d5b4c000      16       -       -       - r----  libc-2.5.so
00000032d5b50000       4       -       -       - rw---  libc-2.5.so
00000032d5b51000      20       -       -       - rw---    [ anon ]
00000032d6800000     520       -       -       - r-x--  libm-2.5.so
00000032d6882000    2044       -       -       - -----  libm-2.5.so
00000032d6a81000       4       -       -       - r----  libm-2.5.so
00000032d6a82000       4       -       -       - rw---  libm-2.5.so
00000032d6c00000      88       -       -       - r-x--  libpthread-2.5.so
00000032d6c16000    2044       -       -       - -----  libpthread-2.5.so
00000032d6e15000       4       -       -       - r----  libpthread-2.5.so
00000032d6e16000       4       -       -       - rw---  libpthread-2.5.so
00000032d6e17000      16       -       -       - rw---    [ anon ]
00000032d7000000      28       -       -       - r-x--  librt-2.5.so
00000032d7007000    2048       -       -       - -----  librt-2.5.so
00000032d7207000       4       -       -       - r----  librt-2.5.so
00000032d7208000       4       -       -       - rw---  librt-2.5.so
00002aaaac000000     132       -       -       - rw---    [ anon ]
00002aaaac021000   65404       -       -       - -----    [ anon ]
00002aaab0000000     132       -       -       - rw---    [ anon ]
00002aaab0021000   65404       -       -       - -----    [ anon ]
00002aaab4000000     132       -       -       - rw---    [ anon ]
00002aaab4021000   65404       -       -       - -----    [ anon ]
00002ad69510e000       4       -       -       - rw---    [ anon ]
00002ad695115000       4       -       -       - rw---    [ anon ]
00002ad695116000     944       -       -       - r-x--  libstdc++.so.6.0.10
00002ad695202000    1024       -       -       - -----  libstdc++.so.6.0.10
00002ad695302000       8       -       -       - r----  libstdc++.so.6.0.10
00002ad695304000      28       -       -       - rw---  libstdc++.so.6.0.10
00002ad69530b000      80       -       -       - rw---    [ anon ]
00002ad69531f000      88       -       -       - r-x--  libgcc_s.so.1
00002ad695335000    1020       -       -       - -----  libgcc_s.so.1
00002ad695434000       4       -       -       - rw---  libgcc_s.so.1
00002ad695435000   24776       -       -       - rw---    [ anon ]
00007fff1597d000     124       -       -       - rw---    [ stack ]
ffffffffff600000    8192       -       -       - -----    [ anon ]
----------------  ------  ------  ------  ------
total kB         2641188       -       -       -

--=====================_1090478672==_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
