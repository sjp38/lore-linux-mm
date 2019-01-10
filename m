Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C0B68E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:10:19 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id b17so8629662pfc.11
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:10:19 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id a3si21122429pld.252.2019.01.10.13.10.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 13:10:17 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [RFC PATCH v7 00/16] Add support for eXclusive Page Frame Ownership
Date: Thu, 10 Jan 2019 14:09:32 -0700
Message-Id: <cover.1547153058.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: Khalid Aziz <khalid.aziz@oracle.com>, deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I am continuing to build on the work Juerg, Tycho and Julian have done
on XPFO. After the last round of updates, we were seeing very
significant performance penalties when stale TLB entries were flushed
actively after an XPFO TLB update. Benchmark for measuring performance
is kernel build using parallel make. To get full protection from
ret2dir attackes, we must flush stale TLB entries. Performance
penalty from flushing stale TLB entries goes up as the number of
cores goes up. On a desktop class machine with only 4 cores,
enabling TLB flush for stale entries causes system time for "make
-j4" to go up by a factor of 2.614x but on a larger machine with 96
cores, system time with "make -j60" goes up by a factor of 26.366x!
I have been working on reducing this performance penalty.

I implemented a solution to reduce performance penalty and
that has had large impact. When XPFO code flushes stale TLB entries,
it does so for all CPUs on the system which may include CPUs that
may not have any matching TLB entries or may never be scheduled to
run the userspace task causing TLB flush. Problem is made worse by
the fact that if number of entries being flushed exceeds
tlb_single_page_flush_ceiling, it results in a full TLB flush on
every CPU. A rogue process can launch a ret2dir attack only from a
CPU that has dual mapping for its pages in physmap in its TLB. We
can hence defer TLB flush on a CPU until a process that would have
caused a TLB flush is scheduled on that CPU. I have added a cpumask
to task_struct which is then used to post pending TLB flush on CPUs
other than the one a process is running on. This cpumask is checked
when a process migrates to a new CPU and TLB is flushed at that
time. I measured system time for parallel make with unmodified 4.20
kernel, 4.20 with XPFO patches before this optimization and then
again after applying this optimization. Here are the results:

Hardware: 96-core Intel Xeon Platinum 8160 CPU @ 2.10GHz, 768 GB RAM
make -j60 all

4.20				915.183s
4.20+XPFO			24129.354s	26.366x
4.20+XPFO+Deferred flush	1216.987s	 1.330xx


Hardware: 4-core Intel Core i5-3550 CPU @ 3.30GHz, 8G RAM
make -j4 all

4.20				607.671s
4.20+XPFO			1588.646s	2.614x
4.20+XPFO+Deferred flush	794.473s	1.307xx

30+% overhead is still very high and there is room for improvement.
Dave Hansen had suggested batch updating TLB entries and Tycho had
created an initial implementation but I have not been able to get
that to work correctly. I am still working on it and I suspect we
will see a noticeable improvement in performance with that. In the
code I added, I post a pending full TLB flush to all other CPUs even
when number of TLB entries being flushed on current CPU does not
exceed tlb_single_page_flush_ceiling. There has to be a better way
to do this. I just haven't found an efficient way to implemented
delayed limited TLB flush on other CPUs.

I am not entirely sure if switch_mm_irqs_off() is indeed the right
place to perform the pending TLB flush for a CPU. Any feedback on
that will be very helpful. Delaying full TLB flushes on other CPUs
seems to help tremendously, so if there is a better way to implement
the same thing than what I have done in patch 16, I am open to
ideas.

Performance with this patch set is good enough to use these as
starting point for further refinement before we merge it into main
kernel, hence RFC.

Since not flushing stale TLB entries creates a false sense of
security, I would recommend making TLB flush mandatory and eliminate
the "xpfotlbflush" kernel parameter (patch "mm, x86: omit TLB
flushing by default for XPFO page table modifications").

What remains to be done beyond this patch series:

1. Performance improvements
2. Remove xpfotlbflush parameter
3. Re-evaluate the patch "arm64/mm: Add support for XPFO to swiotlb"
   from Juerg. I dropped it for now since swiotlb code for ARM has
   changed a lot in 4.20.
4. Extend the patch "xpfo, mm: Defer TLB flushes for non-current
   CPUs" to other architectures besides x86.


---------------------------------------------------------

Juerg Haefliger (5):
  mm, x86: Add support for eXclusive Page Frame Ownership (XPFO)
  swiotlb: Map the buffer if it was unmapped by XPFO
  arm64/mm: Add support for XPFO
  arm64/mm, xpfo: temporarily map dcache regions
  lkdtm: Add test for XPFO

Julian Stecklina (4):
  mm, x86: omit TLB flushing by default for XPFO page table
    modifications
  xpfo, mm: remove dependency on CONFIG_PAGE_EXTENSION
  xpfo, mm: optimize spinlock usage in xpfo_kunmap
  EXPERIMENTAL: xpfo, mm: optimize spin lock usage in xpfo_kmap

Khalid Aziz (2):
  xpfo, mm: Fix hang when booting with "xpfotlbflush"
  xpfo, mm: Defer TLB flushes for non-current CPUs (x86 only)

Tycho Andersen (5):
  mm: add MAP_HUGETLB support to vm_mmap
  x86: always set IF before oopsing from page fault
  xpfo: add primitives for mapping underlying memory
  arm64/mm: disable section/contiguous mappings if XPFO is enabled
  mm: add a user_virt_to_phys symbol

 .../admin-guide/kernel-parameters.txt         |   2 +
 arch/arm64/Kconfig                            |   1 +
 arch/arm64/mm/Makefile                        |   2 +
 arch/arm64/mm/flush.c                         |   7 +
 arch/arm64/mm/mmu.c                           |   2 +-
 arch/arm64/mm/xpfo.c                          |  58 ++++
 arch/x86/Kconfig                              |   1 +
 arch/x86/include/asm/pgtable.h                |  26 ++
 arch/x86/include/asm/tlbflush.h               |   1 +
 arch/x86/mm/Makefile                          |   2 +
 arch/x86/mm/fault.c                           |  10 +
 arch/x86/mm/pageattr.c                        |  23 +-
 arch/x86/mm/tlb.c                             |  27 ++
 arch/x86/mm/xpfo.c                            | 171 ++++++++++++
 drivers/misc/lkdtm/Makefile                   |   1 +
 drivers/misc/lkdtm/core.c                     |   3 +
 drivers/misc/lkdtm/lkdtm.h                    |   5 +
 drivers/misc/lkdtm/xpfo.c                     | 194 ++++++++++++++
 include/linux/highmem.h                       |  15 +-
 include/linux/mm.h                            |   2 +
 include/linux/mm_types.h                      |   8 +
 include/linux/page-flags.h                    |  13 +
 include/linux/sched.h                         |   9 +
 include/linux/xpfo.h                          |  90 +++++++
 include/trace/events/mmflags.h                |  10 +-
 kernel/dma/swiotlb.c                          |   3 +-
 mm/Makefile                                   |   1 +
 mm/mmap.c                                     |  19 +-
 mm/page_alloc.c                               |   3 +
 mm/util.c                                     |  32 +++
 mm/xpfo.c                                     | 247 ++++++++++++++++++
 security/Kconfig                              |  29 ++
 32 files changed, 974 insertions(+), 43 deletions(-)
 create mode 100644 arch/arm64/mm/xpfo.c
 create mode 100644 arch/x86/mm/xpfo.c
 create mode 100644 drivers/misc/lkdtm/xpfo.c
 create mode 100644 include/linux/xpfo.h
 create mode 100644 mm/xpfo.c

-- 
2.17.1
