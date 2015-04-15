Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 36C086B006E
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 06:43:06 -0400 (EDT)
Received: by wgin8 with SMTP id n8so42058813wgi.0
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 03:43:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f6si2549086wiw.110.2015.04.15.03.43.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 03:43:02 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/4] mm: Send a single IPI to TLB flush multiple pages when unmapping
Date: Wed, 15 Apr 2015 11:42:54 +0100
Message-Id: <1429094576-5877-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1429094576-5877-1-git-send-email-mgorman@suse.de>
References: <1429094576-5877-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

An IPI is sent to flush remote TLBs when a page is unmapped that was
recently accessed by other CPUs. There are many circumstances where this
happens but the obvious one is kswapd reclaiming pages belonging to a
running process as kswapd and the task are likely running on separate CPUs.

On small machines, this is not a significant problem but as machine
gets larger with more cores and more memory, the cost of these IPIs can
be high. This patch uses a structure similar in principle to a pagevec
to collect a list of PFNs and CPUs that require flushing. It then sends
one IPI to flush the list of PFNs. A new TLB flush helper is required for
this and one is added for x86. Other architectures will need to decide if
batching like this is both safe and worth the memory overhead. Specifically
the requirement is;

	If a clean page is unmapped and not immediately flushed, the
	architecture must guarantee that a write to that page from a CPU
	with a cached TLB entry will trap a page fault.

This is essentially what the kernel already depends on but the window is
much larger with this patch applied and is worth highlighting.

The impact of this patch depends on the workload as measuring any benefit
requires both mapped pages co-located on the LRU and memory pressure. The
case with the biggest impact is multiple processes reading mapped pages
taken from the vm-scalability test suite. The test case uses NR_CPU readers
of mapped files that consume 10*RAM.

vmscale on a 4-node machine with 64G RAM and 48 CPUs
                                                4.0.0                      4.0.0
                                              vanilla              batchunmap-v1
lru-file-mmap-read-elapsed           161.08 (  0.00%)           117.73 ( 26.91%)

               4.0.0       4.0.0
             vanilla   batchunmap-v1
User          571.38      602.93
System       5990.12     4072.56
Elapsed       162.39      119.06

This is showing that the readers completed 26% with 32% less CPU time. From
vmstats, it is known that the vanilla kernel was interrupted roughly 900K
times per second during the steady phase of the test and the patched kernel
was interrupts 180K times per second.

The impact is much lower on a small machine

vmscale on a 1-node machine with 8G RAM and 1 CPU
                                                            4.0.0                              4.0.0
                                                          vanilla                      batchunmap-v1
Ops lru-file-mmap-read-elapsed                    22.50 (  0.00%)                    19.60 ( 12.89%)

               4.0.0       4.0.0
             vanilla   batchunmap-v1
User           33.64       32.72
System         36.22       33.22
Elapsed        24.11       21.21

It's still a noticeable improvement with vmstat showing interrupts went
from roughly 500K per second to 45K per second.

The patch will have no impact on workloads with no memory pressure or
have relatively few mapped pages.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/x86/Kconfig                |  1 +
 arch/x86/include/asm/tlbflush.h |  2 +
 include/linux/init_task.h       |  8 ++++
 include/linux/rmap.h            |  3 ++
 include/linux/sched.h           | 15 ++++++++
 init/Kconfig                    |  5 +++
 kernel/fork.c                   |  5 +++
 kernel/sched/core.c             |  3 ++
 mm/internal.h                   | 11 ++++++
 mm/rmap.c                       | 85 ++++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c                     | 33 +++++++++++++++-
 11 files changed, 169 insertions(+), 2 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index b7d31ca55187..290844263218 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -30,6 +30,7 @@ config X86
 	select ARCH_MIGHT_HAVE_PC_SERIO
 	select HAVE_AOUT if X86_32
 	select HAVE_UNSTABLE_SCHED_CLOCK
+	select ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
 	select ARCH_SUPPORTS_NUMA_BALANCING if X86_64
 	select ARCH_SUPPORTS_INT128 if X86_64
 	select HAVE_IDE
diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index cd791948b286..96a27051a70a 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -152,6 +152,8 @@ static inline void __flush_tlb_one(unsigned long addr)
  * and page-granular flushes are available only on i486 and up.
  */
 
+#define flush_local_tlb_addr(addr) __flush_tlb_one(addr)
+
 #ifndef CONFIG_SMP
 
 /* "_up" is for UniProcessor.
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 696d22312b31..8127a46d3b9c 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -175,6 +175,13 @@ extern struct task_group root_task_group;
 # define INIT_NUMA_BALANCING(tsk)
 #endif
 
+#ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
+# define INIT_UNMAP_BATCH_CONTROL(tsk)					\
+	.ubc = NULL,
+#else
+# define INIT_UNMAP_BATCH_CONTROL(tsk)
+#endif
+
 #ifdef CONFIG_KASAN
 # define INIT_KASAN(tsk)						\
 	.kasan_depth = 1,
@@ -257,6 +264,7 @@ extern struct task_group root_task_group;
 	INIT_RT_MUTEXES(tsk)						\
 	INIT_VTIME(tsk)							\
 	INIT_NUMA_BALANCING(tsk)					\
+	INIT_UNMAP_BATCH_CONTROL(tsk)					\
 	INIT_KASAN(tsk)							\
 }
 
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index c4c559a45dc8..8d23914b219e 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -89,6 +89,9 @@ enum ttu_flags {
 	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
 	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
 	TTU_IGNORE_HWPOISON = (1 << 10),/* corrupted page is recoverable */
+	TTU_BATCH_FLUSH = (1 << 11),	/* Batch TLB flushes where possible
+					 * and caller guarantees they will
+					 * do a final flush if necessary */
 };
 
 #ifdef CONFIG_MMU
diff --git a/include/linux/sched.h b/include/linux/sched.h
index a419b65770d6..9d51841806f4 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1275,6 +1275,16 @@ enum perf_event_task_context {
 	perf_nr_task_contexts,
 };
 
+/* Matches SWAP_CLUSTER_MAX but refined to limit header dependencies */
+#define BATCH_TLBFLUSH_SIZE 32UL
+
+/* Track pages that require TLB flushes */
+struct unmap_batch {
+	struct cpumask cpumask;
+	unsigned long nr_pages;
+	unsigned long pfns[BATCH_TLBFLUSH_SIZE];
+};
+
 struct task_struct {
 	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
 	void *stack;
@@ -1634,6 +1644,11 @@ struct task_struct {
 	unsigned long numa_pages_migrated;
 #endif /* CONFIG_NUMA_BALANCING */
 
+#ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
+	/* For batched TLB flushes of unmapped pages */
+	struct unmap_batch *ubc;
+#endif
+
 	struct rcu_head rcu;
 
 	/*
diff --git a/init/Kconfig b/init/Kconfig
index f5dbc6d4261b..4827d742bfeb 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -889,6 +889,11 @@ config ARCH_SUPPORTS_NUMA_BALANCING
 	bool
 
 #
+# For architectures that have a local TLB flush for a PFN without VMA knowledge
+config ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
+	bool
+
+#
 # For architectures that know their GCC __int128 support is sound
 #
 config ARCH_SUPPORTS_INT128
diff --git a/kernel/fork.c b/kernel/fork.c
index cf65139615a0..de9d35434863 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -246,6 +246,11 @@ void __put_task_struct(struct task_struct *tsk)
 	delayacct_tsk_free(tsk);
 	put_signal_struct(tsk->signal);
 
+#ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
+	kfree(tsk->ubc);
+	tsk->ubc = NULL;
+#endif
+
 	if (!profile_handoff_task(tsk))
 		free_task(tsk);
 }
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 62671f53202a..d17f8864c25d 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1823,6 +1823,9 @@ static void __sched_fork(unsigned long clone_flags, struct task_struct *p)
 
 	p->numa_group = NULL;
 #endif /* CONFIG_NUMA_BALANCING */
+#ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
+	p->ubc = NULL;
+#endif /* CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH */
 }
 
 #ifdef CONFIG_NUMA_BALANCING
diff --git a/mm/internal.h b/mm/internal.h
index a96da5b0029d..fe69dd159e34 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -431,4 +431,15 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 #define ALLOC_CMA		0x80 /* allow allocations from CMA areas */
 #define ALLOC_FAIR		0x100 /* fair zone allocation */
 
+enum ttu_flags;
+struct unmap_batch;
+
+#ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
+void try_to_unmap_flush(void);
+#else
+static inline void try_to_unmap_flush(void)
+{
+}
+
+#endif /* CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH */
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/rmap.c b/mm/rmap.c
index c161a14b6a8f..abb5e5373354 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -60,6 +60,8 @@
 
 #include <asm/tlbflush.h>
 
+#include <trace/events/tlb.h>
+
 #include "internal.h"
 
 static struct kmem_cache *anon_vma_cachep;
@@ -581,6 +583,74 @@ vma_address(struct page *page, struct vm_area_struct *vma)
 	return address;
 }
 
+#ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
+static void percpu_flush_tlb_batch_pages(void *data)
+{
+	struct unmap_batch *ubc = data;
+	int i;
+
+	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
+	for (i = 0; i < ubc->nr_pages; i++)
+		flush_local_tlb_addr(ubc->pfns[i] << PAGE_SHIFT);
+}
+
+void try_to_unmap_flush(void)
+{
+	struct unmap_batch *ubc = current->ubc;
+
+	if (!ubc || !ubc->nr_pages)
+		return;
+
+	trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, ubc->nr_pages);
+	smp_call_function_many(&ubc->cpumask, percpu_flush_tlb_batch_pages,
+		(void *)ubc, true);
+	cpumask_clear(&ubc->cpumask);
+	ubc->nr_pages = 0;
+}
+
+static void set_ubc_flush_pending(struct mm_struct *mm,
+		struct page *page)
+{
+	struct unmap_batch *ubc = current->ubc;
+
+	cpumask_or(&ubc->cpumask, &ubc->cpumask, mm_cpumask(mm));
+	ubc->pfns[ubc->nr_pages] = page_to_pfn(page);
+	ubc->nr_pages++;
+
+	if (ubc->nr_pages == BATCH_TLBFLUSH_SIZE)
+		try_to_unmap_flush();
+}
+
+/*
+ * Returns true if the TLB flush should be deferred to the end of a batch of
+ * unmap operations to reduce IPIs.
+ */
+static bool should_defer_flush(struct mm_struct *mm, enum ttu_flags flags)
+{
+	bool should_defer = false;
+
+	if (!current->ubc || !(flags & TTU_BATCH_FLUSH))
+		return false;
+
+	/* If remote CPUs need to be flushed then defer batch the flush */
+	if (cpumask_any_but(mm_cpumask(mm), get_cpu()) < nr_cpu_ids)
+		should_defer = true;
+	put_cpu();
+
+	return should_defer;
+}
+#else
+static void set_ubc_flush_pending(struct mm_struct *mm,
+		struct page *page)
+{
+}
+
+static bool should_defer_flush(struct mm_struct *mm, enum ttu_flags flags)
+{
+	return false;
+}
+#endif /* CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH */
+
 /*
  * At what user virtual address is page expected in vma?
  * Caller should check the page is actually part of the vma.
@@ -1213,7 +1283,20 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 	/* Nuke the page table entry. */
 	flush_cache_page(vma, address, page_to_pfn(page));
-	pteval = ptep_clear_flush(vma, address, pte);
+	if (should_defer_flush(mm, flags)) {
+		/*
+		 * We clear the PTE but do not flush so potentially a remote
+		 * CPU could still be writing to the page. If the entry was
+		 * already dirty then no data is lost. If the dirty bit was
+		 * previously clear then the architecture must guarantee that
+		 * a clear->dirty transition on a cached TLB entry is written
+		 * through and traps if the PTE is unmapped.
+		 */
+		pteval = ptep_get_and_clear(mm, address, pte);
+		set_ubc_flush_pending(mm, page);
+	} else {
+		pteval = ptep_clear_flush(vma, address, pte);
+	}
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
 	if (pte_dirty(pteval))
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5e8eadd71bac..68bcc0b73a76 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1024,7 +1024,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * processes. Try to unmap it here.
 		 */
 		if (page_mapped(page) && mapping) {
-			switch (try_to_unmap(page, ttu_flags)) {
+			switch (try_to_unmap(page,
+					ttu_flags|TTU_BATCH_FLUSH)) {
 			case SWAP_FAIL:
 				goto activate_locked;
 			case SWAP_AGAIN:
@@ -1065,6 +1066,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 
 			/* Page is dirty, try to write it out here */
+			try_to_unmap_flush();
 			switch (pageout(page, mapping, sc)) {
 			case PAGE_KEEP:
 				goto keep_locked;
@@ -1211,6 +1213,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 	ret = shrink_page_list(&clean_pages, zone, &sc,
 			TTU_UNMAP|TTU_IGNORE_ACCESS,
 			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5, true);
+	try_to_unmap_flush();
 	list_splice(&clean_pages, page_list);
 	mod_zone_page_state(zone, NR_ISOLATED_FILE, -ret);
 	return ret;
@@ -2223,6 +2226,7 @@ static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
 		scan_adjusted = true;
 	}
 	blk_finish_plug(&plug);
+	try_to_unmap_flush();
 	sc->nr_reclaimed += nr_reclaimed;
 
 	/*
@@ -2762,6 +2766,30 @@ out:
 	return false;
 }
 
+#ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
+static inline void alloc_ubc(void)
+{
+	if (current->ubc)
+		return;
+
+	/*
+	 * Allocate the control structure for batch TLB flushing. Harmless if
+	 * the allocation fails as reclaimer will just send more IPIs.
+	 */
+	current->ubc = kmalloc(sizeof(struct unmap_batch),
+						GFP_ATOMIC | __GFP_NOWARN);
+	if (!current->ubc)
+		return;
+
+	cpumask_clear(&current->ubc->cpumask);
+	current->ubc->nr_pages = 0;
+}
+#else
+static inline void alloc_ubc(void)
+{
+}
+#endif /* CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH */
+
 unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 				gfp_t gfp_mask, nodemask_t *nodemask)
 {
@@ -2789,6 +2817,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 				sc.may_writepage,
 				gfp_mask);
 
+	alloc_ubc();
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
 	trace_mm_vmscan_direct_reclaim_end(nr_reclaimed);
@@ -3364,6 +3393,8 @@ static int kswapd(void *p)
 
 	lockdep_set_current_reclaim_state(GFP_KERNEL);
 
+	alloc_ubc();
+
 	if (!cpumask_empty(cpumask))
 		set_cpus_allowed_ptr(tsk, cpumask);
 	current->reclaim_state = &reclaim_state;
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
