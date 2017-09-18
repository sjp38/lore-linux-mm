Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id DE3B56B0253
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 03:15:35 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 43so8370973qtr.6
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 00:15:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i125si6141468qka.329.2017.09.18.00.15.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Sep 2017 00:15:34 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8I7DwRD175389
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 03:15:33 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2d27p0cqnp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 03:15:33 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 18 Sep 2017 08:15:31 +0100
Subject: Re: [PATCH v3 00/20] Speculative page faults
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
References: <1504894024-2750-1-git-send-email-ldufour@linux.vnet.ibm.com>
Date: Mon, 18 Sep 2017 09:15:22 +0200
MIME-Version: 1.0
In-Reply-To: <1504894024-2750-1-git-send-email-ldufour@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <9e206be2-57a7-ee60-581c-5afc6df030d0@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Despite the unprovable lockdep warning raised by Sergey, I didn't get any
feedback on this series.

Is there a chance to get it moved upstream ?

Thanks,
Laurent.

On 08/09/2017 20:06, Laurent Dufour wrote:
> This is a port on kernel 4.13 of the work done by Peter Zijlstra to
> handle page fault without holding the mm semaphore [1].
> 
> The idea is to try to handle user space page faults without holding the
> mmap_sem. This should allow better concurrency for massively threaded
> process since the page fault handler will not wait for other threads memory
> layout change to be done, assuming that this change is done in another part
> of the process's memory space. This type page fault is named speculative
> page fault. If the speculative page fault fails because of a concurrency is
> detected or because underlying PMD or PTE tables are not yet allocating, it
> is failing its processing and a classic page fault is then tried.
> 
> The speculative page fault (SPF) has to look for the VMA matching the fault
> address without holding the mmap_sem, so the VMA list is now managed using
> SRCU allowing lockless walking. The only impact would be the deferred file
> derefencing in the case of a file mapping, since the file pointer is
> released once the SRCU cleaning is done.  This patch relies on the change
> done recently by Paul McKenney in SRCU which now runs a callback per CPU
> instead of per SRCU structure [1].
> 
> The VMA's attributes checked during the speculative page fault processing
> have to be protected against parallel changes. This is done by using a per
> VMA sequence lock. This sequence lock allows the speculative page fault
> handler to fast check for parallel changes in progress and to abort the
> speculative page fault in that case.
> 
> Once the VMA is found, the speculative page fault handler would check for
> the VMA's attributes to verify that the page fault has to be handled
> correctly or not. Thus the VMA is protected through a sequence lock which
> allows fast detection of concurrent VMA changes. If such a change is
> detected, the speculative page fault is aborted and a *classic* page fault
> is tried.  VMA sequence locks are added when VMA attributes which are
> checked during the page fault are modified.
> 
> When the PTE is fetched, the VMA is checked to see if it has been changed,
> so once the page table is locked, the VMA is valid, so any other changes
> leading to touching this PTE will need to lock the page table, so no
> parallel change is possible at this time.
> 
> Compared to the Peter's initial work, this series introduces a spin_trylock
> when dealing with speculative page fault. This is required to avoid dead
> lock when handling a page fault while a TLB invalidate is requested by an
> other CPU holding the PTE. Another change due to a lock dependency issue
> with mapping->i_mmap_rwsem.
> 
> In addition some VMA field values which are used once the PTE is unlocked
> at the end the page fault path are saved into the vm_fault structure to
> used the values matching the VMA at the time the PTE was locked.
> 
> This series only support VMA with no vm_ops define, so huge page and mapped
> file are not managed with the speculative path. In addition transparent
> huge page are not supported. Once this series will be accepted upstream
> I'll extend the support to mapped files, and transparent huge pages.
> 
> This series builds on top of v4.13.9-mm1 and is functional on x86 and
> PowerPC.
> 
> Tests have been made using a large commercial in-memory database on a
> PowerPC system with 752 CPU using RFC v5 using a previous version of this
> series. The results are very encouraging since the loading of the 2TB
> database was faster by 14% with the speculative page fault.
> 
> Using ebizzy test [3], which spreads a lot of threads, the result are good
> when running on both a large or a small system. When using kernbench, the
> result are quite similar which expected as not so much multithreaded
> processes are involved. But there is no performance degradation neither
> which is good.
> 
> ------------------
> Benchmarks results
> 
> Note these test have been made on top of 4.13.0-mm1.
> 
> Ebizzy:
> -------
> The test is counting the number of records per second it can manage, the
> higher is the best. I run it like this 'ebizzy -mTRp'. To get consistent
> result I repeated the test 100 times and measure the average result, mean
> deviation, max and min.
> 
> - 16 CPUs x86 VM
> Records/s	4.13.0-mm1	4.13.0-mm1-spf	delta
> Average		13217.90 	65765.94	+397.55%
> Mean deviation	690.37		2609.36		+277.97%
> Max		16726		77675		+364.40%
> Min		12194		616340		+405.45%
> 		
> - 80 CPUs Power 8 node:
> Records/s	4.13.0-mm1	4.13.0-mm1-spf	delta
> Average		38175.40	67635.55	77.17% 
> Mean deviation	600.09	 	2349.66		291.55%
> Max		39563		74292		87.78% 
> Min		35846		62657		74.79% 
> 
> The number of record per second is far better with the speculative page
> fault. 
> The mean deviation is higher with the speculative page fault, may be
> because sometime the fault are not handled in a speculative way leading to
> more variation.
> The numbers for the x86 guest are really insane for the SPF case, but I
> did the test several times and this leads each time this delta. I did again
> the test using the previous version of the patch and I got similar
> numbers. It happens that the host running the VM is far less loaded now
> leading to better results as more threads are eligible to run.
> Test on Power are done on a badly balanced node where the memory is only
> attached to one core.
> 
> Kernbench:
> ----------
> This test is building a 4.12 kernel using platform default config. The
> build has been run 5 times each time.
> 
> - 16 CPUs x86 VM
> Average Half load -j 8 Run (std deviation)
>  		 4.13.0-mm1		4.13.0-mm1-spf		delta %
> Elapsed Time     145.968 (0.402206)	145.654 (0.533601)	-0.22
> User Time        1006.58 (2.74729)	1003.7 (4.11294)	-0.29
> System Time      108.464 (0.177567)	111.034 (0.718213)	+2.37
> Percent CPU 	 763.4 (1.34164)	764.8 (1.30384)		+0.18
> Context Switches 46599.6 (412.013)	63771 (1049.95)		+36.85
> Sleeps           85313.2 (514.456)	85532.2 (681.199)	-0.26
> 
> Average Optimal load -j 16 Run (std deviation)
>  		 4.13.0-mm1		4.13.0-mm1-spf		delta %
> Elapsed Time     74.292 (0.75998)	74.484 (0.723035)	+0.26
> User Time        959.949 (49.2036)	956.057 (50.2993)	-0.41
> System Time      100.203 (8.7119)	101.984 (9.56099)	+1.78
> Percent CPU 	 1058 (310.661)		1054.3 (305.263)	-0.35
> Context Switches 65713.8 (20161.7)	86619.4 (24095.4)	+31.81
> Sleeps           90344.9 (5364.74)	90877.4 (5655.87)	-0.59
> 
> The elapsed time are similar, but the impact less important since there are
> less multithreaded processes involved here. 
> 
> - 80 CPUs Power 8 node:
> Average Half load -j 40 Run (std deviation)
> 		 4.13.0-mm1		4.13.0-mm1-spf		delta %
> Elapsed Time 	 115.342 (0.321668)	115.786 (0.427118)	+0.38
> User Time 	 4355.08 (10.1778)	4371.77 (14.9715)	+0.38
> System Time 	 127.612 (0.882083)	130.048 (1.06258)	+1.91
> Percent CPU 	 3885.8 (11.606)	3887.4 (8.04984)	+0.04
> Context Switches 80907.8 (657.481)	81936.4 (729.538)	+1.27
> Sleeps		 162109 (793.331)	162057 (1414.08)	+0.03
> 
> Average Optimal load -j 80 Run (std deviation)
>  		 4.13.0-mm1		4.13.0-mm1-spf
> Elapsed Time 	 110.308 (0.725445)	109.78 (0.826862)	-0.48
> User Time 	 5893.12 (1621.33)	5923.19 (1635.48)	+0.51
> System Time 	 162.168 (36.4347)	166.533 (38.4695)	+2.69
> Percent CPU 	 5400.2 (1596.89)	5440.4 (1637.71)	+0.74
> Context Switches 129372 (51088.2)	144529 (65985.5)	+11.72
> Sleeps		 157312 (5113.57)	158696 (4301.48)	-0.87
> 
> Here the elapsed time are similar the SPF release, but we remain in the error
> margin. It has to be noted that this system is not correctly balanced on
> the NUMA point of view as all the available memory is attached to one core.
> 
> ------------------------
> Changes since v2:
>  - Perf event is renamed in PERF_COUNT_SW_SPF
>  - On Power handle do_page_fault()'s cleaning
>  - On Power if the VM_FAULT_ERROR is returned by
>  handle_speculative_fault(), do not retry but jump to the error path
>  - If VMA's flags are not matching the fault, directly returns
>  VM_FAULT_SIGSEGV and not VM_FAULT_RETRY
>  - Check for pud_trans_huge() to avoid speculative path
>  - Handles _vm_normal_page()'s introduced by 6f16211df3bf
>  ("mm/device-public-memory: device memory cache coherent with CPU")
>  - add and review few comments in the code
> Changes since v1:
>  - Remove PERF_COUNT_SW_SPF_FAILED perf event.
>  - Add tracing events to details speculative page fault failures.
>  - Cache VMA fields values which are used once the PTE is unlocked at the
>  end of the page fault events.
>  - Ensure that fields read during the speculative path are written and read
>  using WRITE_ONCE and READ_ONCE.
>  - Add checks at the beginning of the speculative path to abort it if the
>  VMA is known to not be supported.
> Changes since RFC V5 [5]
>  - Port to 4.13 kernel
>  - Merging patch fixing lock dependency into the original patch
>  - Replace the 2 parameters of vma_has_changed() with the vmf pointer
>  - In patch 7, don't call __do_fault() in the speculative path as it may
>  want to unlock the mmap_sem.
>  - In patch 11-12, don't check for vma boundaries when
>  page_add_new_anon_rmap() is called during the spf path and protect against
>  anon_vma pointer's update.
>  - In patch 13-16, add performance events to report number of successful
>  and failed speculative events. 
> 
> [1] https://urldefense.proofpoint.com/v2/url?u=http-3A__linux-2Dkernel.2935.n7.nabble.com_RFC-2DPATCH-2D0-2D6-2DAnother-2Dgo-2Dat-2Dspeculative-2Dpage-2Dfaults-2Dtt965642.html-23none&d=DwIBAg&c=jf_iaSHvJObTbx-siA1ZOg&r=WE1-GjEMX6XRg4v6rPpC0RVdhh4z63Csy-Wmu5dgUp0&m=449ThuJ31DP_64d96xAqLlSqq4qgY5LlJvzwiULSaos&s=9wDEbeKddqKRa0zfN13yjrErkFIQJo9Ohe07I7IuBSk&e= 
> [2] https://urldefense.proofpoint.com/v2/url?u=https-3A__git.kernel.org_pub_scm_linux_kernel_git_torvalds_linux.git_commit_-3Fid-3Dda915ad5cf25b5f5d358dd3670c3378d8ae8c03e&d=DwIBAg&c=jf_iaSHvJObTbx-siA1ZOg&r=WE1-GjEMX6XRg4v6rPpC0RVdhh4z63Csy-Wmu5dgUp0&m=449ThuJ31DP_64d96xAqLlSqq4qgY5LlJvzwiULSaos&s=OUT_ItjCInfCHdZQS5cjmxUQd3Ws8VkT54MZgJm2dAE&e= 
> [3] https://urldefense.proofpoint.com/v2/url?u=http-3A__ebizzy.sourceforge.net_&d=DwIBAg&c=jf_iaSHvJObTbx-siA1ZOg&r=WE1-GjEMX6XRg4v6rPpC0RVdhh4z63Csy-Wmu5dgUp0&m=449ThuJ31DP_64d96xAqLlSqq4qgY5LlJvzwiULSaos&s=cMZB09rj1TqCKM2B3DPrtrB1LpZan637kvHrM6ShaDk&e= 
> [4] https://urldefense.proofpoint.com/v2/url?u=http-3A__ck.kolivas.org_apps_kernbench_kernbench-2D0.50_&d=DwIBAg&c=jf_iaSHvJObTbx-siA1ZOg&r=WE1-GjEMX6XRg4v6rPpC0RVdhh4z63Csy-Wmu5dgUp0&m=449ThuJ31DP_64d96xAqLlSqq4qgY5LlJvzwiULSaos&s=2D_JH8n0pGF5lE0jSXnb2RY5etKV7C7UfO7-8hknJDE&e= 
> [5] https://urldefense.proofpoint.com/v2/url?u=https-3A__lwn.net_Articles_725607_&d=DwIBAg&c=jf_iaSHvJObTbx-siA1ZOg&r=WE1-GjEMX6XRg4v6rPpC0RVdhh4z63Csy-Wmu5dgUp0&m=449ThuJ31DP_64d96xAqLlSqq4qgY5LlJvzwiULSaos&s=CEgoZjaMNHIZFX-XAzuzr8EswsKhQAArNwmc_8bnduA&e= 
> 
> Laurent Dufour (14):
>   mm: Introduce pte_spinlock for FAULT_FLAG_SPECULATIVE
>   mm: Protect VMA modifications using VMA sequence count
>   mm: Cache some VMA fields in the vm_fault structure
>   mm: Protect SPF handler against anon_vma changes
>   mm/migrate: Pass vm_fault pointer to migrate_misplaced_page()
>   mm: Introduce __lru_cache_add_active_or_unevictable
>   mm: Introduce __maybe_mkwrite()
>   mm: Introduce __vm_normal_page()
>   mm: Introduce __page_add_new_anon_rmap()
>   mm: Try spin lock in speculative path
>   mm: Adding speculative page fault failure trace events
>   perf: Add a speculative page fault sw event
>   perf tools: Add support for the SPF perf event
>   powerpc/mm: Add speculative page fault
> 
> Peter Zijlstra (6):
>   mm: Dont assume page-table invariance during faults
>   mm: Prepare for FAULT_FLAG_SPECULATIVE
>   mm: VMA sequence count
>   mm: RCU free VMAs
>   mm: Provide speculative fault infrastructure
>   x86/mm: Add speculative pagefault handling
> 
>  arch/powerpc/include/asm/book3s/64/pgtable.h |   5 +
>  arch/powerpc/mm/fault.c                      |  15 +
>  arch/x86/include/asm/pgtable_types.h         |   7 +
>  arch/x86/mm/fault.c                          |  19 ++
>  fs/proc/task_mmu.c                           |   5 +-
>  fs/userfaultfd.c                             |  17 +-
>  include/linux/hugetlb_inline.h               |   2 +-
>  include/linux/migrate.h                      |   4 +-
>  include/linux/mm.h                           |  28 +-
>  include/linux/mm_types.h                     |   3 +
>  include/linux/pagemap.h                      |   4 +-
>  include/linux/rmap.h                         |  12 +-
>  include/linux/swap.h                         |  11 +-
>  include/trace/events/pagefault.h             |  87 +++++
>  include/uapi/linux/perf_event.h              |   1 +
>  kernel/fork.c                                |   1 +
>  mm/hugetlb.c                                 |   2 +
>  mm/init-mm.c                                 |   1 +
>  mm/internal.h                                |  19 ++
>  mm/khugepaged.c                              |   5 +
>  mm/madvise.c                                 |   6 +-
>  mm/memory.c                                  | 478 ++++++++++++++++++++++-----
>  mm/mempolicy.c                               |  51 ++-
>  mm/migrate.c                                 |   4 +-
>  mm/mlock.c                                   |  13 +-
>  mm/mmap.c                                    | 138 ++++++--
>  mm/mprotect.c                                |   4 +-
>  mm/mremap.c                                  |   7 +
>  mm/rmap.c                                    |   5 +-
>  mm/swap.c                                    |  12 +-
>  tools/include/uapi/linux/perf_event.h        |   1 +
>  tools/perf/util/evsel.c                      |   1 +
>  tools/perf/util/parse-events.c               |   4 +
>  tools/perf/util/parse-events.l               |   1 +
>  tools/perf/util/python.c                     |   1 +
>  35 files changed, 796 insertions(+), 178 deletions(-)
>  create mode 100644 include/trace/events/pagefault.h
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
