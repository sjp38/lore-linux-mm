Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 826536B025F
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 09:53:04 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 136so2908611wmu.3
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 06:53:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s27si697681edm.150.2017.10.11.06.52.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 06:53:00 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9BDmtr9077442
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 09:52:58 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2dhgmkr7ef-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 09:52:58 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 11 Oct 2017 14:52:55 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v5 00/22] Speculative page faults
Date: Wed, 11 Oct 2017 15:52:24 +0200
Message-Id: <1507729966-10660-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

This is a port on kernel 4.14 of the work done by Peter Zijlstra to
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

This series only support VMA with no vm_ops define, so huge page and mapped
file are not managed with the speculative path. In addition transparent
huge page are not supported. Once this series will be accepted upstream
I'll extend the support to mapped files, and transparent huge pages.

This series builds on top of v4.14-rc3-mmotm and is functional on x86 and
PowerPC.

Tests have been made using a large commercial in-memory database on a
PowerPC system with 752 CPU using RFC v5 using a previous version of this
series. The results are very encouraging since the loading of the 2TB
database was faster by 14% with the speculative page fault.

Using ebizzy test [3], which spreads a lot of threads, the result are good
when running on both a large or a small system. When using kernbench, the
result are quite similar which expected as not so much multithreaded
processes are involved. But there is no performance degradation neither
which is good.

------------------
Benchmarks results

No change since v4.
Please, see https://lkml.org/lkml/2017/10/9/180 for details.

Impact on the text size for x86_64 (same as v4):
       			UP		SMP
4.14.0-rc3-mm1		0x008ed859	0x00966ea9
4.14.0-rc3-mm1-spf	0x008ed859	0x00968ea9

------------------------
Changes since v4:
 - As requested by Andrew Morton, use CONFIG_SPF and define it earlier in
 the series to ease bisection.
Changes since v3:
 - Don't build when CONFIG_SMP is not set
 - Fixed a lock dependency warning in __vma_adjust()
 - Use READ_ONCE to access p*d values in handle_speculative_fault()
 - Call memcp_oom() service in handle_speculative_fault()
Changes since v2:
 - Perf event is renamed in PERF_COUNT_SW_SPF
 - On Power handle do_page_fault()'s cleaning
 - On Power if the VM_FAULT_ERROR is returned by
 handle_speculative_fault(), do not retry but jump to the error path
 - If VMA's flags are not matching the fault, directly returns
 VM_FAULT_SIGSEGV and not VM_FAULT_RETRY
 - Check for pud_trans_huge() to avoid speculative path
 - Handles _vm_normal_page()'s introduced by 6f16211df3bf
 ("mm/device-public-memory: device memory cache coherent with CPU")
 - add and review few comments in the code
Changes since v1:
 - Remove PERF_COUNT_SW_SPF_FAILED perf event.
 - Add tracing events to details speculative page fault failures.
 - Cache VMA fields values which are used once the PTE is unlocked at the
 end of the page fault events.
 - Ensure that fields read during the speculative path are written and read
 using WRITE_ONCE and READ_ONCE.
 - Add checks at the beginning of the speculative path to abort it if the
 VMA is known to not be supported.
Changes since RFC V5 [5]
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
[5] https://lwn.net/Articles/725607/

Laurent Dufour (16):
  x86/mm: Define CONFIG_SPF
  powerpc/mm: Define CONFIG_SPF
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

 arch/powerpc/Kconfig                  |   4 +
 arch/powerpc/mm/fault.c               |  17 ++
 arch/x86/Kconfig                      |   4 +
 arch/x86/mm/fault.c                   |  21 ++
 fs/proc/task_mmu.c                    |   5 +-
 fs/userfaultfd.c                      |  17 +-
 include/linux/hugetlb_inline.h        |   2 +-
 include/linux/migrate.h               |   4 +-
 include/linux/mm.h                    |  69 ++++-
 include/linux/mm_types.h              |   5 +
 include/linux/pagemap.h               |   4 +-
 include/linux/rmap.h                  |  12 +-
 include/linux/swap.h                  |  11 +-
 include/trace/events/pagefault.h      |  87 ++++++
 include/uapi/linux/perf_event.h       |   1 +
 kernel/fork.c                         |   1 +
 mm/hugetlb.c                          |   2 +
 mm/init-mm.c                          |   1 +
 mm/internal.h                         |  21 ++
 mm/khugepaged.c                       |   5 +
 mm/madvise.c                          |   6 +-
 mm/memory.c                           | 496 +++++++++++++++++++++++++++++-----
 mm/mempolicy.c                        |  51 ++--
 mm/migrate.c                          |   4 +-
 mm/mlock.c                            |  13 +-
 mm/mmap.c                             | 160 ++++++++---
 mm/mprotect.c                         |   4 +-
 mm/mremap.c                           |   6 +
 mm/rmap.c                             |   5 +-
 mm/swap.c                             |  12 +-
 tools/include/uapi/linux/perf_event.h |   1 +
 tools/perf/util/evsel.c               |   1 +
 tools/perf/util/parse-events.c        |   4 +
 tools/perf/util/parse-events.l        |   1 +
 tools/perf/util/python.c              |   1 +
 35 files changed, 906 insertions(+), 152 deletions(-)
 create mode 100644 include/trace/events/pagefault.h

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
