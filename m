Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6535783293
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 13:52:46 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g78so43100998pfg.4
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 10:52:46 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b17si1542983pgn.143.2017.06.16.10.52.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 10:52:45 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5GHnCgo055471
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 13:52:44 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2b4g5ehvwv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 13:52:44 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 16 Jun 2017 18:52:41 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v5 00/11] Speculative page faults
Date: Fri, 16 Jun 2017 19:52:24 +0200
Message-Id: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

This is a port on kernel 4.12 of the work done by Peter Zijlstra to
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
is tried.  VMA sequence lockings are added when VMA attributes which are
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

This series builds on top of v4.12-rc5 and is functional on x86 and
PowerPC.

Tests have been made using a large commercial in-memory database on a
PowerPC system with 752 CPUs. The results are very encouraging since the
loading of the 2TB database was faster by 14% with the speculative page
fault.

However tests done using multi-fault [3] or kernbench [4], on smaller
systems didn't show performance improvements, I saw a little degradation but
running the tests again shows that this is in the noise. So nothing
significant enough on the both sides.

Since benchmarks are encouraging and running test suites didn't raise any
issue, I'd like this request for comment series to move to a patch series
soon. So please comment.

------------------
Benchmarks results

Here are the results on a 8 CPUs X86 guest using kernbench on a 4.12-r5
kernel (kernel is build 5 times):

Average Half load -j 4 Run (std deviation):
		 4.12.0-rc5		4.12.0-rc5-spf
		 Run (std deviation)
Elapsed Time     48.42 (0.334515)       48.638 (0.344848)
User Time        124.322 (0.964324)     124.478 (0.659902)
System Time      58.008 (0.300865)      58.664 (0.590999)
Percent CPU 	 376.2 (1.09545)        376.4 (1.51658)
Context Switches 7409.6 (215.18)        11022.8 (281.093)
Sleeps           15255.8 (63.0254)      15250.8 (43.4592)

Average Optimal load -j 8
 		 4.12.0-rc5		4.12.0-rc5-spf
                 Run (std deviation)
Elapsed Time     24.268 (0.151723)      24.514 (0.143805)
User Time        112.092 (12.9135)      112.04 (13.1257)
System Time      49.03 (9.46999)        49.721 (9.44455)
Percent CPU      476 (105.205)          474.3 (103.209)
Context Switches 10268.7 (3020.16)      14069.2 (3219.98)
Sleeps           15790.8 (568.885)      15829.4 (615.371)

Average Maximal load -j
 		 4.12.0-rc5		4.12.0-rc5-spf
                 Run (std deviation)
Elapsed Time     25.042 (0.237844)      25.216 (0.201941)
User Time        110.19 (10.7245)       110.312 (10.8245)
System Time      45.9113 (8.86119)      46.48 (8.93778)
Percent CPU      511.533 (99.1376)      510.133 (97.9897)
Context Switches 19521.1 (13759.8)      22354.1 (12400)
Sleeps           15514.7 (609.76)       15521.2 (670.054)

The elapsed time is in the same order, a bit larger in the case of the spf
release, but that seems to be in the error margin.

Here are the kerbench results on a 572 CPUs Power8 system :

Average Half load -j 376
 		 4.12.0-rc5		4.12.0-rc5-spf
                 Run (std deviation)
Elapsed Time     3.384 (0.0680441)      3.344 (0.0634823)
User Time        203.998 (8.41125)      193.476 (8.23406)
System Time      13.064 (0.624444)      12.028 (0.495954)
Percent CPU      6407 (285.422)         6136.2 (198.173)
Context Switches 7319.2 (517.785)       8960 (221.735)
Sleeps           24287.8 (861.132)      22902.4 (728.475)

Average Optimal load -j 752
 		 4.12.0-rc5		4.12.0-rc5-spf
                 Run (std deviation)
Elapsed Time     3.414 (0.136858)       3.432 (0.0506952)
User Time        200.985 (8.71172)      197.747 (8.9511)
System Time      12.903 (0.638262)      12.472 (0.684865)
Percent CPU      6287.9 (322.208)       6194.8 (192.116)
Context Switches 7173.5 (479.038)       9355.7 (712.3)
Sleeps           24241.6 (1003.66)      22867.5 (1242.49)

Average Maximal load -j
 		 4.12.0-rc5		4.12.0-rc5-spf
                 Run (std deviation)
Elapsed Time     3.422 (0.0791833)      3.312 (0.109864)
User Time        202.096 (7.45845)      197.541 (9.42758)
System Time      12.8733 (0.57327)      12.4567 (0.568465)
Percent CPU      6304.87 (278.195)      6234.67 (204.769)
Context Switches 7166 (412.524)         9398.73 (639.917)
Sleeps           24065.6 (1132.3)       22822.8 (1176.71)

Here the elapsed time is a bit shorter using the spf release, but again we
stay in the error margin.

Here are results using multi-fault :

--- x86 8 CPUs
                Page faults in 60s
4.12.0-rc5      23,014,776
4.12-0-rc5-spf  23,224,435

--- ppc64le 752 CPUs
                Page faults in 60s
4.12.0-rc5      28,087,752
4.12-0-rc5-spf  32,272,610

Results is a bit higher on ppc64le with the SPF patch, but I'm not convince
about this test on Power8 since the page table are managed differently on
this architecture, I'm wondering if we are not hitting the PTE lock.
I run the test multiple times, the number are varying a bit but remain in
the same order.

------------------
Changes since V4:
 - merge several patches to reduce the series as requested by Jan Kara
 - check any comment warning in the code and remove each of them
 - reword some patch description
 
Changes since V3:
 - support for the 5-level paging.
 - abort speculative path before entering userfault code
 - support for PowerPC architecture
 - reorder the patch to fix build test errors.

[1] http://linux-kernel.2935.n7.nabble.com/RFC-PATCH-0-6-Another-go-at-speculative-page-faults-tt965642.html#none
[2] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=da915ad5cf25b5f5d358dd3670c3378d8ae8c03e
[3] https://lkml.org/lkml/2010/1/6/28
[4] http://ck.kolivas.org/apps/kernbench/kernbench-0.50/

Laurent Dufour (5):
  mm: Introduce pte_spinlock for FAULT_FLAG_SPECULATIVE
  mm: fix lock dependency against mapping->i_mmap_rwsem
  mm: Protect VMA modifications using VMA sequence count
  mm: Try spin lock in speculative path
  powerpc/mm: Add speculative page fault

Peter Zijlstra (6):
  mm: Dont assume page-table invariance during faults
  mm: Prepare for FAULT_FLAG_SPECULATIVE
  mm: VMA sequence count
  mm: RCU free VMAs
  mm: Provide speculative fault infrastructure
  x86/mm: Add speculative pagefault handling

 arch/powerpc/mm/fault.c  |  25 ++++-
 arch/x86/mm/fault.c      |  14 +++
 fs/proc/task_mmu.c       |   2 +
 include/linux/mm.h       |   4 +
 include/linux/mm_types.h |   3 +
 kernel/fork.c            |   1 +
 mm/init-mm.c             |   1 +
 mm/internal.h            |  20 ++++
 mm/madvise.c             |   4 +
 mm/memory.c              | 286 +++++++++++++++++++++++++++++++++++++++--------
 mm/mempolicy.c           |  10 +-
 mm/mlock.c               |   9 +-
 mm/mmap.c                | 123 +++++++++++++++-----
 mm/mprotect.c            |   2 +
 mm/mremap.c              |   7 ++
 15 files changed, 430 insertions(+), 81 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
