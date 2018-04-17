Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 599F96B0005
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:33:48 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id e12so7275386qtp.17
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:33:48 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l44si1255288qtf.162.2018.04.17.07.33.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 07:33:45 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3HETfdL115042
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:33:44 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hdhtdup35-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 10:33:44 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 17 Apr 2018 15:33:41 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v10 00/25] Speculative page faults
Date: Tue, 17 Apr 2018 16:33:06 +0200
Message-Id: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

This is a port on kernel 4.16 of the work done by Peter Zijlstra to
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

In pseudo code, this could be seen as:
    speculative_page_fault()
    {
	    vma = GET_VMA_vma()
	    check vma sequence count
	    check vma's support
	    disable interrupt
		  check pgd,p4d,...,pte
		  save pmd and pte in vmf
		  save vma sequence counter in vmf
	    enable interrupt
	    check vma sequence count
	    handle_pte_fault(vma)
		    ..
		    page = alloc_page()
		    pte_map_lock()
			    disable interrupt
				    abort if sequence counter has changed
				    abort if pmd or pte has changed
				    pte map and lock
			    enable interrupt
		    if abort
		       free page
		       abort
		    ...
    }
    
    arch_fault_handler()
    {
	    if (speculative_page_fault(&vma)) goto done
    again:
	    lock(mmap_sem)
	    if (!vma)
	       try_to_reuse(vma)
	    else
	       vma = find_vma();
	    handle_pte_fault(vma);
	    if retry
	       unlock(mmap_sem)
	       vma = NULL;
	       goto again;
    done
	    handle fault error
    }

Support for THP is not done because when checking for the PMD, we can be
confused by an in progress collapsing operation done by khugepaged. The
issue is that pmd_none() could be true either if the PMD is not already
populated or if the underlying PTE are in the way to be collapsed. So we
cannot safely allocate a PMD if pmd_none() is true.

This series add a new software performance event named 'speculative-faults'
or 'spf'. It counts the number of successful page fault event handled in a
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

There is also a dedicated vmstat counter showing the number of successful
page fault handled in a speculative way. I can be seen this way:
$ grep speculative_pgfault /proc/vmstat

This series builds on top of v4.16-mmotm-2018-04-13-17-28 and is
functional on x86 and PowerPC.

---------------------
Real Workload results

As mentioned in previous email, we did non official runs using a "popular
in memory multithreaded database product" on 176 cores SMT8 Power system
which showed a 30% improvements in the number of transaction processed per
second. This run has been done on the v6 series, but changes introduced in
this new verion should not impact the performance boost seen.

Here are the perf data captured during 2 of these runs on top of the v8
series:
		vanilla		spf
faults		89.418		101.364		
spf                n/a		 97.989

With the SPF kernel, most of the page fault were processed in a speculative
way.

Ganesh Mahendran had backported the series on top of a 4.9 kernel and give
it
a try on an android device. He reported that the application launch time
was
improved by 15%, and for large applications (~100 threads) by 20% [3].

------------------
Benchmarks results

Base kernel is v4.16
SPF is BASE + this series

Kernbench:
----------
Here are the results on a 16 CPUs X86 guest using kernbench on a 4.15
kernel (kernel is build 5 times):

Average	Half load -j 8
		 Run	(std deviation)
		 BASE			SPF
Elapsed	Time	 152.5	 (0.631585)	151.406	(0.391446)	-0.72%
User	Time	 1036.4	 (2.42065)	1025.2	(1.9909)	-1.08%
System	Time	 125.688 (0.403695)	126.794	(0.716715)	0.88%
Percent	CPU	 761.4	 (2.07364)	760.4	(1.34164)	-0.13%
Context	Switches 51429	 (804.93)	51435.6	(1108.12)	0.01%
Sleeps		 104625	 (510.468)	105877	(703.774)	1.20%
						
Average	Optimal	load -j	16
		 Run	(std deviation)
		 BASE			SPF
Elapsed	Time	 75.51	 (0.576498)	74.684	(0.279159)	-1.09%
User	Time	 970.701 (69.2768)	964.945	(63.5283)	-0.59%
System	Time	 111.965 (14.4711)	112.465	(15.1159)	0.45%
Percent	CPU	 1044.8	 (298.806)	1051.3	(306.658)	0.62%
Context	Switches 75261.5 (25129.6)	75387.4	(25264.8)	0.17%
Sleeps		 109660	 (5349.62)	110279	(4704.95)	0.56%

During a run on the SPF, perf events were captured:
 Performance counter stats for '../kernbench -M':
         513045402      faults
               202      spf
                 0      pagefault:spf_pte_lock
                 0      pagefault:spf_vma_changed
                 0      pagefault:spf_vma_noanon
              2210      pagefault:spf_vma_notsup
                 0      pagefault:spf_vma_access
                 0      pagefault:spf_pmd_changed

    1837.394054020 seconds time elapsed

Very few speculative page fault were recorded as most of the processes
involved are monothreaded (sounds that on this architecture some threads
were created during the kernel build processing).

Here are the kerbench results on a 80 CPUs Power8 system:

Average	Half load -j 40
		 Run	(std deviation)
		 BASE			SPF
Elapsed	Time	 117.222 (0.733294)	116.784	(0.452139)	-0.37%
User	Time	 4485.58 (27.1243)	4473.9	(8.0409)	-0.26%
System	Time	 134.228 (0.601764)	134.874	(0.680169)	0.48%
Percent	CPU	 3940.4	 (12.4218)	3945.8	(12.5579)	0.14%
Context	Switches 92414.8 (689.529)	92448.6	(511.846)	0.04%
Sleeps		 318388	 (758.783)	318758	(1758.96)	0.12%
						
Average	Optimal	load -j	80
		 Run	(std deviation)
		 BASE			SPF
Elapsed	Time	 107.102 (0.73605)	107.872	(1.08573)	0.72%
User	Time	 5875.13 (1464.89)	5862.59	(1463.87)	-0.21%
System	Time	 157.006 (24.0146)	157.731	(24.1209)	0.46%
Percent	CPU	 5445.4	 (1587.03)	5417.6	(1552.41)	-0.51%
Context	Switches 221714	 (136312)	221526	(136071)	-0.08%
Sleeps		 332500	 (15173.2)	332037	(14202.1)	-0.14%

During a run on the SPF, perf events were captured:
 Performance counter stats for '../kernbench -M':
         116933988      faults
                 0      spf
                 0      pagefault:spf_pte_lock
                 0      pagefault:spf_vma_changed
                 0      pagefault:spf_vma_noanon
               476      pagefault:spf_vma_notsup
                 0      pagefault:spf_vma_access
                 0      pagefault:spf_pmd_changed

Most of the processes involved are monothreaded so SPF is not activated but
there is no impact on the performance.

Ebizzy:
-------
The test is counting the number of records per second it can manage, the
higher is the best. I run it like this 'ebizzy -mTRp'. To get consistent
result I repeated the test 100 times and measure the average result. The
number is the record processes per second, the higher is the best.

  		BASE		SPF		delta	
16 CPUs x86 VM	12405.52	91104.52	634.39%
80 CPUs P8 node 37880.01	76201.05	101.16%

Here are the performance counter read during a run on a 16 CPUs x86 VM:
 Performance counter stats for './ebizzy -mRTp':
            860074      faults
            856866      spf
               285      pagefault:spf_pte_lock
              1506      pagefault:spf_vma_changed
                 0      pagefault:spf_vma_noanon
                73      pagefault:spf_vma_notsup
                 0      pagefault:spf_vma_access
                 0      pagefault:spf_pmd_changed

And the ones captured during a run on a 80 CPUs Power node:
 Performance counter stats for './ebizzy -mRTp':
            722695      faults
            699402      spf
             16048      pagefault:spf_pte_lock
              6838      pagefault:spf_vma_changed
                 0      pagefault:spf_vma_noanon
               277      pagefault:spf_vma_notsup
                 0      pagefault:spf_vma_access
                 0      pagefault:spf_pmd_changed

In ebizzy's case most of the page fault were handled in a speculative way,
leading the ebizzy performance boost.

------------------
Changes since v9:
 - Accounted for all review feedback from David Rientjes and Jerome Glisse,
   hopefully
 - Fix a lockdep warning when populate_vma_page_range() is called by
   mprotect_fixup(). The call to vm_write_end(vma) is now made before
calling
   populate_vma_page_range() since vma locking is not required here.
 - Introduce INIT_VMA() move VMA's sequence and refcount initialization out
   of __vma_link_rb(). This fix various lockdep warning raised when
   unmap_region() may be called before vma_link() (patch 7 & 8)
 - Allow CONFIG_SPECULATIVE_PAGE_FAULT to be switched off
 - Pass VMA's flag value to maybe_mkwrite() allowing to use the cached ones
   (patch 12)
 - Make CONFIG_SPECULATIVE_PAGE_FAULT user configurable
 - Add speculative page fault vmstats
 - Remove #ifdef in arch/*/mm/fault.c
Changes since v8:
 - Don't check PMD when locking the pte when THP is disabled
   Thanks to Daniel Jordan for reporting this.
 - Rebase on 4.16
Changes since v7:
 - move pte_map_lock() and pte_spinlock() upper in mm/memory.c (patch 4 &
   5)
 - make pte_unmap_same() compatible with the speculative page fault (patch
   6)
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

[1]
http://linux-kernel.2935.n7.nabble.com/RFC-PATCH-0-6-Another-go-at-speculative-page-faults-tt965642.html#none
[2] https://patchwork.kernel.org/patch/9999687/
[3] https://lkml.org/lkml/2018/3/21/894


Laurent Dufour (21):
  mm: introduce CONFIG_SPECULATIVE_PAGE_FAULT
  x86/mm: define ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
  powerpc/mm: set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
  mm: introduce pte_spinlock for FAULT_FLAG_SPECULATIVE
  mm: make pte_unmap_same compatible with SPF
  mm: introduce INIT_VMA()
  mm: protect VMA modifications using VMA sequence count
  mm: protect mremap() against SPF hanlder
  mm: protect SPF handler against anon_vma changes
  mm: cache some VMA fields in the vm_fault structure
  mm/migrate: Pass vm_fault pointer to migrate_misplaced_page()
  mm: introduce __lru_cache_add_active_or_unevictable
  mm: introduce __vm_normal_page()
  mm: introduce __page_add_new_anon_rmap()
  mm: protect mm_rb tree with a rwlock
  mm: adding speculative page fault failure trace events
  perf: add a speculative page fault sw event
  perf tools: add support for the SPF perf event
  mm: speculative page fault handler return VMA
  mm: add speculative page fault vmstats
  powerpc/mm: add speculative page fault

Peter Zijlstra (4):
  mm: prepare for FAULT_FLAG_SPECULATIVE
  mm: VMA sequence count
  mm: provide speculative fault infrastructure
  x86/mm: add speculative pagefault handling

 arch/powerpc/Kconfig                  |   1 +
 arch/powerpc/mm/fault.c               |  33 +-
 arch/x86/Kconfig                      |   1 +
 arch/x86/mm/fault.c                   |  42 ++-
 fs/exec.c                             |   2 +-
 fs/proc/task_mmu.c                    |   5 +-
 fs/userfaultfd.c                      |  17 +-
 include/linux/hugetlb_inline.h        |   2 +-
 include/linux/migrate.h               |   4 +-
 include/linux/mm.h                    | 145 +++++++-
 include/linux/mm_types.h              |   7 +
 include/linux/pagemap.h               |   4 +-
 include/linux/rmap.h                  |  12 +-
 include/linux/swap.h                  |  10 +-
 include/linux/vm_event_item.h         |   3 +
 include/trace/events/pagefault.h      |  88 +++++
 include/uapi/linux/perf_event.h       |   1 +
 kernel/fork.c                         |   5 +-
 mm/Kconfig                            |  22 ++
 mm/huge_memory.c                      |   6 +-
 mm/hugetlb.c                          |   2 +
 mm/init-mm.c                          |   3 +
 mm/internal.h                         |  20 ++
 mm/khugepaged.c                       |   5 +
 mm/madvise.c                          |   6 +-
 mm/memory.c                           | 649 +++++++++++++++++++++++++++++-----
 mm/mempolicy.c                        |  51 ++-
 mm/migrate.c                          |   6 +-
 mm/mlock.c                            |  13 +-
 mm/mmap.c                             | 229 +++++++++---
 mm/mprotect.c                         |   4 +-
 mm/mremap.c                           |  13 +
 mm/nommu.c                            |   2 +-
 mm/rmap.c                             |   5 +-
 mm/swap.c                             |   6 +-
 mm/swap_state.c                       |   8 +-
 mm/vmstat.c                           |   5 +-
 tools/include/uapi/linux/perf_event.h |   1 +
 tools/perf/util/evsel.c               |   1 +
 tools/perf/util/parse-events.c        |   4 +
 tools/perf/util/parse-events.l        |   1 +
 tools/perf/util/python.c              |   1 +
 42 files changed, 1231 insertions(+), 214 deletions(-)
 create mode 100644 include/trace/events/pagefault.h

-- 
2.7.4
