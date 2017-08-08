Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 48FCB6B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 10:36:05 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u89so4949770wrc.1
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 07:36:05 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q19si1295874wme.157.2017.08.08.07.36.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 07:36:03 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v78EXcAG099493
	for <linux-mm@kvack.org>; Tue, 8 Aug 2017 10:36:01 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2c7b3d1mmm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Aug 2017 10:36:01 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 8 Aug 2017 15:35:58 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH 00/16] Speculative page faults
Date: Tue,  8 Aug 2017 16:35:33 +0200
Message-Id: <1502202949-8138-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

This is a port on kernel 4.13 of the work done by Peter Zijlstra to
handle page fault without holding the mm semaphore [1].

The idea is to try to handle user space page faults without holding the
mmap_sem. This should allow better concurrency for massively threaded
process since the page fault handler will not wait for other threads memory
layout change to be done, assuming that this change is done in another part
of the process's memory space. This type page fault is named speculative
page fault. If the speculative page fault fails because of a concurrency is
detected or because underlying PMD or PTE tables are not yet allocating, it
is failing its processing and a classic page fault is then tried.

The speculative page fault (SPF) has to look for the VMA matching the fault
address without holding the mmap_sem, so the VMA list is now managed using
SRCU allowing lockless walking. The only impact would be the deferred file
derefencing in the case of a file mapping, since the file pointer is
released once the SRCU cleaning is done.  This patch relies on the change
done recently by Paul McKenney in SRCU which now runs a callback per CPU
instead of per SRCU structure [1].

The VMA's attributes checked during the speculative page fault processing
have to be protected against parallel changes. This is done by using a per
VMA sequence lock. This sequence lock allows the speculative page fault
handler to fast check for parallel changes in progress and to abort the
speculative page fault in that case.

Once the VMA is found, the speculative page fault handler would check for
the VMA's attributes to verify that the page fault has to be handled
correctly or not. Thus the VMA is protected through a sequence lock which
allows fast detection of concurrent VMA changes. If such a change is
detected, the speculative page fault is aborted and a *classic* page fault
is tried.  VMA sequence locks are added when VMA attributes which are
checked during the page fault are modified.

When the PTE is fetched, the VMA is checked to see if it has been changed,
so once the page table is locked, the VMA is valid, so any other changes
leading to touching this PTE will need to lock the page table, so no
parallel change is possible at this time.

Compared to the Peter's initial work, this series introduces a spin_trylock
when dealing with speculative page fault. This is required to avoid dead
lock when handling a page fault while a TLB invalidate is requested by an
other CPU holding the PTE. Another change due to a lock dependency issue
with mapping->i_mmap_rwsem.

This series builds on top of v4.13-rc4 and is functional on x86 and
PowerPC.

Tests have been made using a large commercial in-memory database on a
PowerPC system with 752 CPUs. The results are very encouraging since the
loading of the 2TB database was faster by 14% with the speculative page
fault.

Using ebizzy test [3], which spreads a lot of threads, the result are good
when running on both a large or a small system. When using kernbench, the
result are quite similar which expected as not so much multithreaded
processes are involved. But there is no performance degradation neither
which is good.

------------------
Benchmarks results

Note these test have been made on top of 4.13-rc3 with the following patch
from Paul McKenney applied: 
 "srcu: Provide ordering for CPU not involved in grace period" [5]

Ebizzy:
-------
The test is counting the number of records per second it can manage, the
higher is the best. I run it like this 'ebizzy -mTRp'. To get consistent
result I repeated the test 100 times and measure the average result, mean
deviation and max.

- 16 CPUs x86 VM
Records/s	4.13-rc3	4.13-rc3-spf
Average		11455.92	45803.64
Mean deviation	509.34		848.19
Max		13997		49824

- 80 CPUs Power 8 node:
Records/s	4.13-rc3	4.13-rc3-spf
Average		33848.76	63427.62
Mean deviation	684.48		1618.84
Max		36235		70401

Kernbench:
----------
This test is building a 4.12 kernel using platform default config. The
build has been run 5 times each time.

- 16 CPUs x86 VM
Average Half load -j 7 Run (std deviation)
 		 4.13.0-rc3		4.13.0-rc3-spf
Elapsed Time     166.668 (0.462299)	167.55 (0.432724)
User Time        1083.11 (2.89018)	1083.76 (2.17015)
System Time      202.982 (0.984058)	210.364 (0.890382)
Percent CPU 	 771.2 (0.83666)	771.8 (1.09545)
Context Switches 46789 (519.558)	67602.4 (365.929)
Sleeps           83870.8 (836.392)	84269.4 (457.962)

Average Optimal load -j 16 Run (std deviation)
 		 4.13.0-rc3		4.13.0-rc3-spf
Elapsed Time     85.002 (0.298111)	85.406 (0.506784)
User Time        1033.25 (52.6037)	1034.63 (51.8167)
System Time      185.46 (18.4826)	191.75 (19.6379)
Percent CPU 	 1062.6 (307.181)	1063.9 (307.948)
Context Switches 67423.3 (21762.7)	91316.1 (25004.4)
Sleeps           89393.6 (5860.2)	89489.9 (5563.54)

The elapsed time is in the same order, a bit larger in the case of the spf
release, but that seems to be in the error margin.

- 80 CPUs Power 8 node:
Average Half load -j 40 Run (std deviation)
 		 4.13.0-rc3		4.13.0-rc3-spf
Elapsed Time     116.422 (0.604707)	116.898 (1.00981)
User Time        4410.13 (23.4272)	4393.49 (22.6739)
System Time      130.128 (0.567468)	132.16 (0.840238)
Percent CPU      3899.2 (13.9535)	3871 (17.6777)
Context Switches 72699.8 (585.077)	73281.4 (516.003)
Sleeps           160396 (1248.34)	161801 (522.71)

Average Optimal load -j 80 Run (std deviation)
 		 4.13.0-rc3		4.13.0-rc3-spf
Elapsed Time     111.216 (0.826698)	110.442 (0.846505)
User Time        5911.85 (1583.04)	5932.14 (1622.02)
System Time      164.799 (36.5712)	168.29 (38.0891)
Percent CPU      5371.9 (1552.74)	5410.2 (1623.17)
Context Switches 117770 (47512.1)	130131 (59927.8)
Sleeps           161619 (2210.47)	163442 (2349.71)

Here the elapsed time is a bit shorter using the spf release, but again we
stay in the error margin. It has to be noted that this system is not
correctly balanced on the NUMA point of view as all the available memory is
attached to one core.

------------------------
Changes since RFC V5 [6]
 - Port to 4.13 kernel
 - Merging patch fixing lock dependency into the original patch
 - Replace the 2 parameters of vma_has_changed() with the vmf pointer
 - In patch 7, don't call __do_fault() in the speculative path as it may
 want to unlock the mmap_sem.
 - In patch 11-12, don't check for vma boundaries when
 page_add_new_anon_rmap() is called during the spf path and protect against
 anon_vma pointer's update.
 - In patch 13-16, add performance events to report number of successful
 and failed speculative events. 

[1] http://linux-kernel.2935.n7.nabble.com/RFC-PATCH-0-6-Another-go-at-speculative-page-faults-tt965642.html#none
[2] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=da915ad5cf25b5f5d358dd3670c3378d8ae8c03e
[3] http://ebizzy.sourceforge.net/
[4] http://ck.kolivas.org/apps/kernbench/kernbench-0.50/
[5] https://lkml.org/lkml/2017/7/24/829
[6] https://lwn.net/Articles/725607/

Laurent Dufour (10):
  mm: Introduce pte_spinlock for FAULT_FLAG_SPECULATIVE
  mm: Protect VMA modifications using VMA sequence count
  mm: Try spin lock in speculative path
  powerpc/mm: Add speculative page fault
  mm: Introduce __page_add_new_anon_rmap()
  mm: Protect SPF handler against anon_vma changes
  perf: Add a speculative page fault sw events
  x86/mm: Add support for SPF events
  powerpc/mm: Add support for SPF events
  perf tools: Add support for SPF events

Peter Zijlstra (6):
  mm: Dont assume page-table invariance during faults
  mm: Prepare for FAULT_FLAG_SPECULATIVE
  mm: VMA sequence count
  mm: RCU free VMAs
  mm: Provide speculative fault infrastructure
  x86/mm: Add speculative pagefault handling

 arch/powerpc/mm/fault.c               |  30 +++-
 arch/x86/mm/fault.c                   |  18 ++
 fs/proc/task_mmu.c                    |   2 +
 include/linux/mm.h                    |   4 +
 include/linux/mm_types.h              |   3 +
 include/linux/rmap.h                  |  12 +-
 include/uapi/linux/perf_event.h       |   2 +
 kernel/fork.c                         |   1 +
 mm/init-mm.c                          |   1 +
 mm/internal.h                         |  19 +++
 mm/khugepaged.c                       |   3 +
 mm/madvise.c                          |   4 +
 mm/memory.c                           | 302 ++++++++++++++++++++++++++++------
 mm/mempolicy.c                        |  10 +-
 mm/mlock.c                            |   9 +-
 mm/mmap.c                             | 123 ++++++++++----
 mm/mprotect.c                         |   2 +
 mm/mremap.c                           |   7 +
 mm/rmap.c                             |   5 +-
 tools/include/uapi/linux/perf_event.h |   2 +
 tools/perf/util/evsel.c               |   2 +
 tools/perf/util/parse-events.c        |   8 +
 tools/perf/util/parse-events.l        |   2 +
 tools/perf/util/python.c              |   2 +
 24 files changed, 484 insertions(+), 89 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
