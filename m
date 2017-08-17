Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id DD2CB6B025F
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 18:05:38 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id p141so5975078iop.6
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 15:05:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w70si2505801pgw.888.2017.08.17.15.05.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 15:05:37 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7HM5EJb116644
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 18:05:36 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2cdax05b4q-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 18:05:36 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 17 Aug 2017 23:05:33 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v2 00/20] Speculative page faults
Date: Fri, 18 Aug 2017 00:04:59 +0200
Message-Id: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
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

In addition some VMA field values which are used once the PTE is unlocked
at the end the page fault path are saved into the vm_fault structure to
used the values matching the VMA at the time the PTE was locked.

This series builds on top of v4.13-rc5 and is functional on x86 and
PowerPC.

Tests have been made using a large commercial in-memory database on a
PowerPC system with 752 CPU using RFC v5. The results are very encouraging
since the loading of the 2TB database was faster by 14% with the
speculative page fault.

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
deviation, max and min.

- 16 CPUs x86 VM
Records/s	4.13-rc5	4.13-rc5-spf
Average		11350.29	21760.36
Mean deviation	396.56		881.40
Max		13773		26194
Min		10567		19223

- 80 CPUs Power 8 node:
Records/s	4.13-rc5	4.13-rc5-spf
Average		33904.67	58847.91
Mean deviation	789.40		1753.19
Max		36703		68958
Min		31759		55125

The number of record per second is far better with the speculative page
fault.
The mean deviation is higher with the speculative page fault, may be
because sometime the fault are not handled in a speculative way leading to
more variation.


Kernbench:
----------
This test is building a 4.12 kernel using platform default config. The
build has been run 5 times each time.

- 16 CPUs x86 VM
Average Half load -j 8 Run (std deviation)
 		 4.13.0-rc5		4.13.0-rc5-spf
Elapsed Time     166.574 (0.340779)	145.754 (0.776325)		
User Time        1080.77 (2.05871)	999.272 (4.12142)		
System Time      204.594 (1.02449)	116.362 (1.22974)		
Percent CPU 	 771.2 (1.30384)	765 (0.707107)
Context Switches 46590.6 (935.591)	66316.4 (744.64)
Sleeps           84421.2 (596.612)	85186 (523.041)		

Average Optimal load -j 16 Run (std deviation)
 		 4.13.0-rc5		4.13.0-rc5-spf
Elapsed Time     85.422 (0.42293)	74.81 (0.419345)
User Time        1031.79 (51.6557)	954.912 (46.8439)
System Time      186.528 (19.0575)	107.514 (9.36902)
Percent CPU 	 1059.2 (303.607)	1056.8 (307.624)
Context Switches 67240.3 (21788.9)	89360.6 (24299.9)
Sleeps           89607.8 (5511.22)	90372.5 (5490.16)

The elapsed time is a bit shorter in the case of the SPF release, but the
impact less important since there are less multithreaded processes involved
here. 

- 80 CPUs Power 8 node:
Average Half load -j 40 Run (std deviation)
 		 4.13.0-rc5		4.13.0-rc5-spf
Elapsed Time     117.176 (0.824093)	116.792 (0.695392)
User Time        4412.34 (24.29)	4396.02 (24.4819)
System Time      131.106 (1.28343)	133.452 (0.708851)
Percent CPU      3876.8 (18.1439)	3877.6 (21.9955)
Context Switches 72470.2 (466.181)	72971 (673.624)
Sleeps           161294 (2284.85)	161946 (2217.9)

Average Optimal load -j 80 Run (std deviation)
 		 4.13.0-rc5		4.13.0-rc5-spf
Elapsed Time     111.176 (1.11123)	111.242 (0.801542)
User Time        5930.03 (1600.07)	5929.89 (1617)
System Time      166.258 (37.0662)	169.337 (37.8419)
Percent CPU      5378.5 (1584.16)	5385.6 (1590.24)
Context Switches 117389 (47350.1)	130132 (60256.3)
Sleeps           163354 (4153.9)	163219 (2251.27)

Here the elapsed time is a bit shorter using the spf release, but we
remain in the error margin. It has to be noted that this system is not
correctly balanced on the NUMA point of view as all the available memory is
attached to one core.

------------------------
Changes since v1:
 - Remove PERF_COUNT_SW_SPF_FAILED perf event.
 - Add tracing events to details speculative page fault failures.
 - Cache VMA fields values which are used once the PTE is unlocked at the
 end of the page fault events.
 - Ensure that fields read during the speculative path are written and read
 using WRITE_ONCE and READ_ONCE.
 - Add checks at the beginning of the speculative path to abort it if the
 VMA is known to not be supported.
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

Laurent Dufour (14):
  mm: Introduce pte_spinlock for FAULT_FLAG_SPECULATIVE
  mm: Protect VMA modifications using VMA sequence count
  mm: Cache some VMA fields in the vm_fault structure
  mm: Protect SPF handler against anon_vma changes
  mm/migrate: Pass vm_fault pointer to migrate_misplaced_page()
  mm: Introduce __lru_cache_add_active_or_unevictable
  mm: Introduce __maybe_mkwrite()
  mm: Introduce __vm_normal_page()
  mm: Introduce __page_add_new_anon_rmap()
  mm: Try spin lock in speculative path
  mm: Adding speculative page fault failure trace events
  perf: Add a speculative page fault sw event
  perf tools: Add support for the SPF perf event
  powerpc/mm: Add speculative page fault

Peter Zijlstra (6):
  mm: Dont assume page-table invariance during faults
  mm: Prepare for FAULT_FLAG_SPECULATIVE
  mm: VMA sequence count
  mm: RCU free VMAs
  mm: Provide speculative fault infrastructure
  x86/mm: Add speculative pagefault handling

 arch/powerpc/include/asm/book3s/64/pgtable.h |   5 +
 arch/powerpc/mm/fault.c                      |  30 +-
 arch/x86/include/asm/pgtable_types.h         |   7 +
 arch/x86/mm/fault.c                          |  19 ++
 fs/proc/task_mmu.c                           |   5 +-
 fs/userfaultfd.c                             |  17 +-
 include/linux/hugetlb_inline.h               |   2 +-
 include/linux/migrate.h                      |   4 +-
 include/linux/mm.h                           |  21 +-
 include/linux/mm_types.h                     |   3 +
 include/linux/pagemap.h                      |   4 +-
 include/linux/rmap.h                         |  12 +-
 include/linux/swap.h                         |  11 +-
 include/trace/events/pagefault.h             |  87 +++++
 include/uapi/linux/perf_event.h              |   1 +
 kernel/fork.c                                |   1 +
 mm/hugetlb.c                                 |   2 +
 mm/init-mm.c                                 |   1 +
 mm/internal.h                                |  19 ++
 mm/khugepaged.c                              |   5 +
 mm/madvise.c                                 |   6 +-
 mm/memory.c                                  | 474 ++++++++++++++++++++++-----
 mm/mempolicy.c                               |  51 ++-
 mm/migrate.c                                 |   4 +-
 mm/mlock.c                                   |  13 +-
 mm/mmap.c                                    | 138 ++++++--
 mm/mprotect.c                                |   4 +-
 mm/mremap.c                                  |   7 +
 mm/rmap.c                                    |   5 +-
 mm/swap.c                                    |  12 +-
 tools/include/uapi/linux/perf_event.h        |   1 +
 tools/perf/util/evsel.c                      |   1 +
 tools/perf/util/parse-events.c               |   4 +
 tools/perf/util/parse-events.l               |   1 +
 tools/perf/util/python.c                     |   1 +
 35 files changed, 803 insertions(+), 175 deletions(-)
 create mode 100644 include/trace/events/pagefault.h

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
