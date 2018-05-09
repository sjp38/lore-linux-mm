Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E32196B03AB
	for <linux-mm@kvack.org>; Wed,  9 May 2018 04:38:57 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d9-v6so3379850plj.4
        for <linux-mm@kvack.org>; Wed, 09 May 2018 01:38:57 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id t144-v6si21177836pgb.94.2018.05.09.01.38.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 01:38:56 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -V2 00/21] mm, THP, swap: Swapout/swapin THP as a whole
Date: Wed,  9 May 2018 16:38:25 +0800
Message-Id: <20180509083846.14823-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>

From: Huang Ying <ying.huang@intel.com>

Hi, Andrew, could you help me to check whether the overall design is
reasonable?

Hi, Hugh, Shaohua, Minchan and Rik, could you help me to review the
swap part of the patchset?  Especially [02/21], [03/21], [04/21],
[05/21], [06/21], [07/21], [08/21], [09/21], [10/21], [11/21],
[12/21], [20/21].

Hi, Andrea and Kirill, could you help me to review the THP part of the
patchset?  Especially [01/21], [07/21], [09/21], [11/21], [13/21],
[15/21], [16/21], [17/21], [18/21], [19/21], [20/21], [21/21].

Hi, Johannes and Michal, could you help me to review the cgroup part
of the patchset?  Especially [14/21].

And for all, Any comment is welcome!

This patchset is based on the 2018-05-03 head of mmotm/master.

This is the final step of THP (Transparent Huge Page) swap
optimization.  After the first and second step, the splitting huge
page is delayed from almost the first step of swapout to after swapout
has been finished.  In this step, we avoid splitting THP for swapout
and swapout/swapin the THP as a whole.

We tested the patchset with vm-scalability benchmark swap-w-seq test
case, with 16 processes.  The test case forks 16 processes.  Each
process allocates large anonymous memory range, and writes it from
begin to end for 8 rounds.  The first round will swapout, while the
remaining rounds will swapin and swapout.  The test is done on a Xeon
E5 v3 system, the swap device used is a RAM simulated PMEM (persistent
memory) device.  The test result is as follow,

            base                  optimized
---------------- -------------------------- 
         %stddev     %change         %stddev
             \          |                \  
   1417897 A+-  2%    +992.8%   15494673        vm-scalability.throughput
   1020489 A+-  4%   +1091.2%   12156349        vmstat.swap.si
   1255093 A+-  3%    +940.3%   13056114        vmstat.swap.so
   1259769 A+-  7%   +1818.3%   24166779        meminfo.AnonHugePages
  28021761           -10.7%   25018848 A+-  2%  meminfo.AnonPages
  64080064 A+-  4%     -95.6%    2787565 A+- 33%  interrupts.CAL:Function_call_interrupts
     13.91 A+-  5%     -13.8        0.10 A+- 27%  perf-profile.children.cycles-pp.native_queued_spin_lock_slowpath

Where, the score of benchmark (bytes written per second) improved
992.8%.  The swapout/swapin throughput improved 1008% (from about
2.17GB/s to 24.04GB/s).  The performance difference is huge.  In base
kernel, for the first round of writing, the THP is swapout and split,
so in the remaining rounds, there is only normal page swapin and
swapout.  While in optimized kernel, the THP is kept after first
swapout, so THP swapin and swapout is used in the remaining rounds.
This shows the key benefit to swapout/swapin THP as a whole, the THP
will be kept instead of being split.  meminfo information verified
this, in base kernel only 4.5% of anonymous page are THP during the
test, while in optimized kernel, that is 96.6%.  The TLB flushing IPI
(represented as interrupts.CAL:Function_call_interrupts) reduced
95.6%, while cycles for spinlock reduced from 13.9% to 0.1%.  These
are performance benefit of THP swapout/swapin too.

Below is the description for all steps of THP swap optimization.

Recently, the performance of the storage devices improved so fast that
we cannot saturate the disk bandwidth with single logical CPU when do
page swapping even on a high-end server machine.  Because the
performance of the storage device improved faster than that of single
logical CPU.  And it seems that the trend will not change in the near
future.  On the other hand, the THP becomes more and more popular
because of increased memory size.  So it becomes necessary to optimize
THP swap performance.

The advantages to swapout/swapin a THP as a whole include:

- Batch various swap operations for the THP.  Many operations need to
  be done once per THP instead of per normal page, for example,
  allocating/freeing the swap space, writing/reading the swap space,
  flushing TLB, page fault, etc.  This will improve the performance of
  the THP swap greatly.

- The THP swap space read/write will be large sequential IO (2M on
  x86_64).  It is particularly helpful for the swapin, which are
  usually 4k random IO.  This will improve the performance of the THP
  swap too.

- It will help the memory fragmentation, especially when the THP is
  heavily used by the applications.  The THP order pages will be free
  up after THP swapout.

- It will improve the THP utilization on the system with the swap
  turned on.  Because the speed for khugepaged to collapse the normal
  pages into the THP is quite slow.  After the THP is split during the
  swapout, it will take quite long time for the normal pages to
  collapse back into the THP after being swapin.  The high THP
  utilization helps the efficiency of the page based memory management
  too.

There are some concerns regarding THP swapin, mainly because possible
enlarged read/write IO size (for swapout/swapin) may put more overhead
on the storage device.  To deal with that, the THP swapin is turned on
only when necessary.  A new sysfs interface:
/sys/kernel/mm/transparent_hugepage/swapin_enabled is added to
configure it.  It uses "always/never/madvise" logic, to be turned on
globally, turned off globally, or turned on only for VMA with
MADV_HUGEPAGE, etc.
GE, etc.

Changelog
---------

v2:

- Fixed several build bugs, Thanks 0-Day!

- Improved documentation as suggested by Randy Dunlap.

- Fixed several bugs in reading huge swap cluster
