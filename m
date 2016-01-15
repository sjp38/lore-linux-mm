Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4FA82828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 00:26:26 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id 65so111929920pff.2
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 21:26:26 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id cb8si13974217pad.237.2016.01.14.21.26.25
        for <linux-mm@kvack.org>;
        Thu, 14 Jan 2016 21:26:25 -0800 (PST)
From: "Chen, Yu C" <yu.c.chen@intel.com>
Subject: proc-meminfo: Why the Mapped be much higher than Active(file) +
 Inactive(file) ?
Date: Fri, 15 Jan 2016 05:26:22 +0000
Message-ID: <36DF59CE26D8EE47B0655C516E9CE640286BCF23@shsmsx102.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi dear memory experts,

Currently we encountered a hibernation problem that,
the number of global_page_state(NR_FILE_MAPPED) is much higher
than global_page_state(NR_INACTIVE_ANON) + global_page_state(NR_ACTIVE_FILE=
)
which causes unexpected behavior when calculating the reclaimable
number of pages (https://bugzilla.kernel.org/show_bug.cgi?id=3D97201):

~> cat /proc/meminfo
MemTotal:       11998028 kB
MemFree:         7592344 kB
MemAvailable:    7972260 kB
Buffers:          229960 kB
Cached:           730140 kB
SwapCached:       133868 kB
Active:          1256224 kB
Inactive:         599452 kB
Active(anon):     904904 kB
Inactive(anon):   436112 kB
Active(file):     351320 kB
Inactive(file):   163340 kB
Unevictable:          60 kB
Mlocked:              60 kB
SwapTotal:      10713084 kB
SwapFree:        9850232 kB
Dirty:                 0 kB
Writeback:             0 kB
AnonPages:        847876 kB
Mapped:          2724140 kB        //very big...
Shmem:            445440 kB
Slab:             129984 kB
SReclaimable:      68368 kB
SUnreclaim:        61616 kB
KernelStack:        8128 kB
PageTables:        53692 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:    16712096 kB
Committed_AS:    6735376 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      578084 kB
VmallocChunk:   34359117432 kB
HardwareCorrupted:     0 kB
AnonHugePages:    276480 kB
HugePages_Total:       0
HugePages_Free:        0

Due to my lacking knowledge on memory management,
I don't know the reason why Mapped is much bigger than
the sum of Active(file) and Inactive(file), so the trace util is
enabled to track the increment of Mapped(target: page_add_file_rmap):

[root@localhost tracing]# pwd
/sys/kernel/debug/tracing
[root@localhost tracing]# echo page_add_file_rmap > set_ftrace_filter
 [root@localhost tracing]# echo function > current_tracer
 [root@localhost tracing]# echo 1 > options/func_stack_trace
//start virtual box, our testing process
 [root@localhost tracing]# cat trace > /home/tracer_nr_mapped.log
[root@localhost tracing]# echo 0 > options/func_stack_trace
[root@localhost tracing]#  echo > set_ftrace_filter
 [root@localhost tracing]# echo 0 > tracing_on

The result shows that, most of increment occur in the following path:
      VirtualBox-3151  [000] ...1   523.775961: page_add_file_rmap <-do_set=
_pte
      VirtualBox-3151  [000] ...1   523.775963: <stack trace>
 =3D> update_curr
 =3D> page_add_file_rmap
 =3D> put_prev_entity
 =3D> page_add_file_rmap
 =3D> do_set_pte
 =3D> filemap_map_pages
 =3D> do_read_fault.isra.61
 =3D> handle_mm_fault
 =3D> get_futex_key
 =3D> hrtimer_wakeup
 =3D> __do_page_fault
 =3D> do_futex
 =3D> do_page_fault
 =3D> page_fault

So it is filemap_map_pages.

Firstly, filemap_map_pages only considers the pages already
in the page cache tree,=20
secondly, all the pages in a page cache tree have previously
been added  to inactive list after finished the on-demand fault,
filemap_fault -> find_get_page,
thirdly, the pages caches are moved between inactive-lru and active-lru
(plus mem cgroup lru) ,=20
So, the total number of Active(file) and Inactive(file)
should be bigger than Mapped, why the latter=20
is bigger than the latters in our environment?

I'm not sure if I understand the code correctly, could you guys
please give me some advice/suggestion on why this happeded?=20
thanks in advance.



Yu


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
