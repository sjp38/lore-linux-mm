Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id A44466B0029
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 11:50:25 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id i26so1988662qtc.1
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 08:50:25 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d1si2604631qtk.139.2018.02.06.08.50.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 08:50:24 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w16Gn30J122500
	for <linux-mm@kvack.org>; Tue, 6 Feb 2018 11:50:23 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2fye1ypux9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 06 Feb 2018 11:50:21 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 6 Feb 2018 16:50:19 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v7 00/24] Speculative page faults
Date: Tue,  6 Feb 2018 17:49:46 +0100
Message-Id: <1517935810-31177-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

This is a port on kernel 4.15 of the work done by Peter Zijlstra to
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
address without holding the mmap_sem, this is done by introducing a rwlock
which protects the access to the mm_rb tree. Previously this was done using
SRCU but it was introducing a lot of scheduling to process the VMA's
freeing
operation which was hitting the performance by 20% as reported by Kemi Wang
[2].Using a rwlock to protect access to the mm_rb tree is limiting the
locking contention to these operations which are expected to be in a O(log
n)
order. In addition to ensure that the VMA is not freed in our back a
reference count is added and 2 services (get_vma() and put_vma()) are
introduced to handle the reference count. When a VMA is fetch from the RB
tree using get_vma() is must be later freeed using put_vma(). Furthermore,
to allow the VMA to be used again by the classic page fault handler a
service is introduced can_reuse_spf_vma(). This service is expected to be
called with the mmap_sem hold. It checked that the VMA is still matching
the specified address and is releasing its reference count as the mmap_sem
is hold it is ensure that it will not be freed in our back. In general, the
VMA's reference count could be decremented when holding the mmap_sem but it
should not be increased as holding the mmap_sem is ensuring that the VMA is
stable. I can't see anymore the overhead I got while will-it-scale
benchmark anymore.

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

The locking of the PTE is done with interrupts disabled, this allows to
check for the PMD to ensure that there is not an ongoing collapsing
operation. Since khugepaged is firstly set the PMD to pmd_none and then is
waiting for the other CPU to have catch the IPI interrupt, if the pmd is
valid at the time the PTE is locked, we have the guarantee that the
collapsing opertion will have to wait on the PTE lock to move foward. This
allows the SPF handler to map the PTE safely. If the PMD value is different
than the one recorded at the beginning of the SPF operation, the classic
page fault handler will be called to handle the operation while holding the
mmap_sem. As the PTE lock is done with the interrupts disabled, the lock is
done using spin_trylock() to avoid dead lock when handling a page fault
while a TLB invalidate is requested by an other CPU holding the PTE.

Support for THP is not done because when checking for the PMD, we can be
confused by an in progress collapsing operation done by khugepaged. The
issue is that pmd_none() could be true either if the PMD is not already
populate or if the underlying PTE are in the way to be collapsed. So we
cannot safely allocate a PMD if pmd_none() is true.

This series builds on top of v4.15-mmotm-2018-01-31-16-51 and is
functional on x86 and PowerPC.

------------------
Benchmarks results

There is no functional change compared to the v6 so benchmark results are
the same.
Please see https://lkml.org/lkml/2018/1/12/515 for details.

------------------
Changes since v6:
 - Rename config variable to CONFIG_SPECULATIVE_PAGE_FAULT (patch 1)
 - Review the way the config variable is set (patch 1 to 3)
 - Introduce mm_rb_write_*lock() in mm/mmap.c (patch 18)
 - Merge patch introducing pte try locking in the patch 18.
Changes since v5:
 - use rwlock agains the mm RB tree in place of SRCU
 - add a VMA's reference count to protect VMA while using it without
   holding the mmap_sem.
 - check PMD value to detect collapsing operation
 - don't try speculative page fault for mono threaded processes
 - try to reuse the fetched VMA if VM_RETRY is returned
 - go directly to the error path if an error is detected during the SPF
   path
 - fix race window when moving VMA in move_vma()
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
[2] https://patchwork.kernel.org/patch/9999687/

Laurent Dufour (19):
  mm: Introduce CONFIG_SPECULATIVE_PAGE_FAULT
  x86/mm: Define CONFIG_SPECULATIVE_PAGE_FAULT
  powerpc/mm: Define CONFIG_SPECULATIVE_PAGE_FAULT
  mm: Introduce pte_spinlock for FAULT_FLAG_SPECULATIVE
  mm: Protect VMA modifications using VMA sequence count
  mm: protect mremap() against SPF hanlder
  mm: Protect SPF handler against anon_vma changes
  mm: Cache some VMA fields in the vm_fault structure
  mm/migrate: Pass vm_fault pointer to migrate_misplaced_page()
  mm: Introduce __lru_cache_add_active_or_unevictable
  mm: Introduce __maybe_mkwrite()
  mm: Introduce __vm_normal_page()
  mm: Introduce __page_add_new_anon_rmap()
  mm: Protect mm_rb tree with a rwlock
  mm: Adding speculative page fault failure trace events
  perf: Add a speculative page fault sw event
  perf tools: Add support for the SPF perf event
  mm: Speculative page fault handler return VMA
  powerpc/mm: Add speculative page fault

Peter Zijlstra (5):
  mm: Dont assume page-table invariance during faults
  mm: Prepare for FAULT_FLAG_SPECULATIVE
  mm: VMA sequence count
  mm: Provide speculative fault infrastructure
  x86/mm: Add speculative pagefault handling

 arch/powerpc/Kconfig                  |   1 +
 arch/powerpc/mm/fault.c               |  31 +-
 arch/x86/Kconfig                      |   1 +
 arch/x86/mm/fault.c                   |  38 ++-
 fs/proc/task_mmu.c                    |   5 +-
 fs/userfaultfd.c                      |  17 +-
 include/linux/hugetlb_inline.h        |   2 +-
 include/linux/migrate.h               |   4 +-
 include/linux/mm.h                    |  91 +++++-
 include/linux/mm_types.h              |   7 +
 include/linux/pagemap.h               |   4 +-
 include/linux/rmap.h                  |  12 +-
 include/linux/swap.h                  |  10 +-
 include/trace/events/pagefault.h      |  87 ++++++
 include/uapi/linux/perf_event.h       |   1 +
 kernel/fork.c                         |   3 +
 mm/Kconfig                            |   3 +
 mm/hugetlb.c                          |   2 +
 mm/init-mm.c                          |   3 +
 mm/internal.h                         |  20 ++
 mm/khugepaged.c                       |   5 +
 mm/madvise.c                          |   6 +-
 mm/memory.c                           | 563 ++++++++++++++++++++++++++++++----
 mm/mempolicy.c                        |  51 ++-
 mm/migrate.c                          |   4 +-
 mm/mlock.c                            |  13 +-
 mm/mmap.c                             | 211 ++++++++++---
 mm/mprotect.c                         |   4 +-
 mm/mremap.c                           |  13 +
 mm/rmap.c                             |   5 +-
 mm/swap.c                             |   6 +-
 mm/swap_state.c                       |   8 +-
 tools/include/uapi/linux/perf_event.h |   1 +
 tools/perf/util/evsel.c               |   1 +
 tools/perf/util/parse-events.c        |   4 +
 tools/perf/util/parse-events.l        |   1 +
 tools/perf/util/python.c              |   1 +
 37 files changed, 1075 insertions(+), 164 deletions(-)
 create mode 100644 include/trace/events/pagefault.h

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
