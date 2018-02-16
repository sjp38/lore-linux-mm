Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id B91816B0006
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:25:57 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id m7-v6so1174507yba.3
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 07:25:57 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l125si3309601qkc.161.2018.02.16.07.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 07:25:55 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1GFPcGE084673
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:25:54 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2g61dm9emk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:25:53 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 16 Feb 2018 15:25:49 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v8 00/24] Speculative page faults
Date: Fri, 16 Feb 2018 16:25:14 +0100
Message-Id: <1518794738-4186-1-git-send-email-ldufour@linux.vnet.ibm.com>
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
SRCU but it was introducing a lot of scheduling to process the VMA's freeing
operation which was hitting the performance by 20% as reported by Kemi Wang
[2].Using a rwlock to protect access to the mm_rb tree is limiting the
locking contention to these operations which are expected to be in a O(log n)
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
populated or if the underlying PTE are in the way to be collapsed. So we
cannot safely allocate a PMD if pmd_none() is true.

This series a new software performance event named 'speculative-faults' or
'spf'. It counts the number of successful page fault event handled in a
speculative way. When recording 'faults,spf' events, the faults one is
counting the total number of page fault events while 'spf' is only counting
the part of the faults processed in a speculative way.

There are some trace events introduced by this series. They allow to
identify why the page faults where not processed in a speculative way. This
doesn't take in account the faults generated by a monothreaded process
which directly processed while holding the mmap_sem. This trace events are
grouped in a system named 'pagefault', they are:
 - pagefault:spf_pte_lock : if the pte was already locked by another thread
 - pagefault:spf_vma_changed : if the VMA has been changed in our back
 - pagefault:spf_vma_noanon : the vma->anon_vma field was not yet set.
 - pagefault:spf_vma_notsup : the VMA's type is not supported
 - pagefault:spf_vma_access : the VMA's access right are not respected
 - pagefault:spf_pmd_changed : the upper PMD pointer has changed in our
 back.

To record all the related events, the easier is to run perf with the
following arguments :
$ perf stat -e 'faults,spf,pagefault:*' <command>

This series builds on top of v4.15-mmotm-2018-02-06-16-41 and is
functional on x86 and PowerPC.

---------------------
Real Workload results

As mentioned in previous email, we did non official runs using a "popular
in memory multithreaded database product" on 176 cores SMT8 Power system
which showed a 30% improvements in the number of transaction processed per
second. This run has been done on the v6 series, but changes introduced in
this new verion should not impact the performance boost seen.

Here are the perf data captured during 2 of these runs :
		vanilla		spf
faults		89.418		101.364		
spf                n/a		 97.989

With the SPF kernel, most of the page fault were processed in a speculative way.

------------------
Benchmarks results

Base kernel is 4.15-mmotm-2018-02-06-16-41
SPF is BASE + this series

Kernbench:
----------
Here are the results on a 16 CPUs X86 guest using kernbench on a 4.13-rc4
kernel (kernel is build 5 times):

Average	Half load -j 8
		 Run	(std deviation)
		 BASE			SPF
Elapsed	Time	 147.376 (0.471413)	147.362	(0.562468)	-0.01%
User	Time	 1006.99 (3.91733)	1006.41	(3.13905)	-0.06%
System	Time	 114.612 (0.819433)	116.348	(1.05897)	1.51%
Percent	CPU	 760.6 	 (3.97492)	761.4	(4.15933)	0.11%
Context	Switches 44241.6 (661.005)	44577.4	(642.631)	0.76%
Sleeps		 85929.6 (461.657)	86141.4	(795.939)	0.25%
						
Average	Optimal	load -j	16
		 Run	(std deviation)
		 BASE			SPF
Elapsed	Time	 71.082	 (0.374526)	71.374	(0.44264)	0.41%
User	Time	 937.35	 (73.4597)	937.865	(72.2913)	0.05%
System	Time	 101.216 (14.1338)	102.902	(14.1995)	1.67%
Percent	CPU	 1052.1	 (307.311)	1052	(306.364)	-0.01%
Context	Switches 63743.9 (20572.9)	64267.6	(20768.3)	0.82%
Sleeps		 91479.1 (5870.58)	92038.3	(6253.44)	0.61%

During a run on the SPF, perf events were captured:
 Performance counter stats for '../kernbench -M':
         367932002      faults
         227      	spf
         0      	pagefault:spf_pte_lock
         0      	pagefault:spf_vma_changed
         0      	pagefault:spf_vma_noanon
         2168      	pagefault:spf_vma_notsup
         0      	pagefault:spf_vma_access
         0      	pagefault:spf_pmd_changed                               

Very few speculative page fault were recorded as most of the processes
involved are monothreaded (sounds that on this architecture some threads
were created during the kernel build processing).

Here are the kerbench results on a 80 CPUs Power8 system:

Average	Half load -j 40
		 Run	(std deviation)
		 BASE			SPF
Elapsed	Time	 117.166 (0.254716)	117.068	(0.574952)	-0.08%
User	Time	 4480.71 (20.0644)	4480.12	(11.0745)	-0.01%
System	Time	 134.372 (0.31364)	136.66	(0.760164)	1.70%
Percent	CPU	 3938.2	 (8.58487)	3943	(18.8547)	0.12%
Context	Switches 92127.6 (171.901)	92288.8	(299.436)	0.17%
Sleeps		 318695	 (1307.96)	319125	(1278.35)	0.13%
						
Average	Optimal	load -j	80
		 Run	(std deviation)
		 BASE			SPF
Elapsed	Time	 107.816 (0.885257)	107.31	(0.639844)	-0.47%
User	Time	 5871.04 (1465.62)	5876.96	(1472.44)	0.10%
System	Time	 157.682 (24.5729)	160.354	(24.9855)	1.69%
Percent	CPU	 5420.2	 (1562.69)	5446.2	(1584.91)	0.48%
Context	Switches 222110	 (137020)	223067	(137867)	0.43%
Sleeps		 333091	 (15317.9)	334876	(17012.5)	0.54%

During a run on the SPF, perf events were captured:
 Performance counter stats for '../kernbench -M':
         116616867      faults
         0      	spf
         0      	pagefault:spf_pte_lock
         1      	pagefault:spf_vma_changed
         0      	pagefault:spf_vma_noanon
         473      	pagefault:spf_vma_notsup
         0      	pagefault:spf_vma_access
         0      	pagefault:spf_pmd_changed

Most of the processes involved are monothreaded so SPF is not activated but
there is no impact on the performance.

Ebizzy:
-------
The test is counting the number of records per second it can manage, the
higher is the best. I run it like this 'ebizzy -mTRp'. To get consistent
result I repeated the test 100 times and measure the average result. The
number is the record processes per second, the higher is the best.

  		BASE		SPF		delta	
16 CPUs x86 VM	11412.55	62236.93	445.34%
80 CPUs P8 node	37659.4		80985.63	115.05%

Here are the performance counter read during a run on a 16 CPUs x86 VM:
 Performance counter stats for './ebizzy -mRTp':
            596987      faults
	    591798      spf
            246      	pagefault:spf_pte_lock
            4033      	pagefault:spf_vma_changed
            0      	pagefault:spf_vma_noanon
            76      	pagefault:spf_vma_notsup
            0      	pagefault:spf_vma_access
            0      	pagefault:spf_pmd_changed

And the ones captured during a run on a 80 CPUs Power node:
 Performance counter stats for './ebizzy -mRTp':
            706445	faults
            697135	spf
            6304	pagefault:spf_pte_lock
            2595	pagefault:spf_vma_changed
            0		pagefault:spf_vma_noanon
            282		pagefault:spf_vma_notsup
            0		pagefault:spf_vma_access
            0		pagefault:spf_pmd_changed

In ebizzy's case most of the page fault were handled in a speculative way,
leading the ebizzy performance boost.

------------------
Changes since v7:
 - move pte_map_lock() and pte_spinlock() upper in mm/memory.c (patch 4 & 5)
 - make pte_unmap_same() compatible with the speculative page fault (patch 6)
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

Laurent Dufour (20):
  mm: Introduce CONFIG_SPECULATIVE_PAGE_FAULT
  x86/mm: Define CONFIG_SPECULATIVE_PAGE_FAULT
  powerpc/mm: Define CONFIG_SPECULATIVE_PAGE_FAULT
  mm: Introduce pte_spinlock for FAULT_FLAG_SPECULATIVE
  mm: make pte_unmap_same compatible with SPF
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

Peter Zijlstra (4):
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
 include/linux/mm.h                    |  92 +++++-
 include/linux/mm_types.h              |   7 +
 include/linux/pagemap.h               |   4 +-
 include/linux/rmap.h                  |  12 +-
 include/linux/swap.h                  |  10 +-
 include/trace/events/pagefault.h      |  87 +++++
 include/uapi/linux/perf_event.h       |   1 +
 kernel/fork.c                         |   3 +
 mm/Kconfig                            |   3 +
 mm/hugetlb.c                          |   2 +
 mm/init-mm.c                          |   3 +
 mm/internal.h                         |  20 ++
 mm/khugepaged.c                       |   5 +
 mm/madvise.c                          |   6 +-
 mm/memory.c                           | 594 +++++++++++++++++++++++++++++-----
 mm/mempolicy.c                        |  51 ++-
 mm/migrate.c                          |   4 +-
 mm/mlock.c                            |  13 +-
 mm/mmap.c                             | 211 +++++++++---
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
 37 files changed, 1096 insertions(+), 175 deletions(-)
 create mode 100644 include/trace/events/pagefault.h

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
