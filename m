Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2ED900015
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 08:51:03 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so85194414wiw.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 05:51:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h2si967945wiv.100.2015.06.08.05.50.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 05:50:59 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/3] mm: Send one IPI per CPU to TLB flush multiple pages that were recently unmapped
Date: Mon,  8 Jun 2015 13:50:53 +0100
Message-Id: <1433767854-24408-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1433767854-24408-1-git-send-email-mgorman@suse.de>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

An IPI is sent to flush remote TLBs when a page is unmapped that was
recently accessed by other CPUs. There are many circumstances where this
happens but the obvious one is kswapd reclaiming pages belonging to a
running process as kswapd and the task are likely running on separate CPUs.

On small machines, this is not a significant problem but as machine
gets larger with more cores and more memory, the cost of these IPIs can
be high. This patch uses a structure similar in principle to a pagevec
to collect a list of PFNs and CPUs that require flushing. It then sends
one IPI per CPU that was mapping any of those pages to flush the list of
PFNs. A new TLB flush helper is required for this and one is added for
x86. Other architectures will need to decide if batching like this is both
safe and worth the memory overhead. Specifically the requirement is;

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
           4.1.0-rc6     4.1.0-rc6
             vanilla batchunmap-v5
User          577.35        618.60
System       5927.06       4195.03
Elapsed       162.21        121.31

The workload completed 25% faster with 29% less CPU time.

This is showing that the readers completed 25% with 30% less CPU time. From
vmstats, it is known that the vanilla kernel was interrupted roughly 900K
times per second during the steady phase of the test and the patched kernel
was interrupts 180K times per second.

The impact is much lower on a small machine

vmscale on a 1-node machine with 8G RAM and 1 CPU
           4.1.0-rc6     4.1.0-rc6
             vanilla batchunmap-v5
User           59.14         58.86
System        109.15         83.78
Elapsed        27.32         23.14

It's still a noticeable improvement with vmstat showing interrupts went
from roughly 500K per second to 45K per second.

The patch will have no impact on workloads with no memory pressure or
have relatively few mapped pages.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/x86/Kconfig                |   1 +
 arch/x86/include/asm/tlbflush.h |   2 +
 include/linux/init_task.h       |   8 +++
 include/linux/rmap.h            |   3 ++
 include/linux/sched.h           |  14 ++++++
 init/Kconfig                    |   8 +++
 kernel/fork.c                   |   5 ++
 kernel/sched/core.c             |   3 ++
 mm/internal.h                   |  11 +++++
 mm/rmap.c                       | 105 +++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c                     |  23 ++++++++-
 11 files changed, 181 insertions(+), 2 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 226d5696e1d1..4e8bd86735af 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -31,6 +31,7 @@ config X86
 	select ARCH_MIGHT_HAVE_PC_SERIO
 	select HAVE_AOUT if X86_32
 	select HAVE_UNSTABLE_SCHED_CLOCK
+	select ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
 	select ARCH_SUPPORTS_NUMA_BALANCING if X86_64
 	select ARCH_SUPPORTS_INT128 if X86_64
 	select HAVE_IDE
diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index cd791948b286..10c197a649f5 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -152,6 +152,8 @@ static inline void __flush_tlb_one(unsigned long addr)
  * and page-granular flushes are available only on i486 and up.
  */
 
+#define flush_local_tlb_addr(addr) __flush_tlb_single(addr)
+
 #ifndef CONFIG_SMP
 
 /* "_up" is for UniProcessor.
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 696d22312b31..0771937b47e1 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -175,6 +175,13 @@ extern struct task_group root_task_group;
 # define INIT_NUMA_BALANCING(tsk)
 #endif
 
+#ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
+# define INIT_TLBFLUSH_UNMAP_BATCH_CONTROL(tsk)				\
+	.tlb_ubc = NULL,
+#else
+# define INIT_TLBFLUSH_UNMAP_BATCH_CONTROL(tsk)
+#endif
+
 #ifdef CONFIG_KASAN
 # define INIT_KASAN(tsk)						\
 	.kasan_depth = 1,
@@ -257,6 +264,7 @@ extern struct task_group root_task_group;
 	INIT_RT_MUTEXES(tsk)						\
 	INIT_VTIME(tsk)							\
 	INIT_NUMA_BALANCING(tsk)					\
+	INIT_TLBFLUSH_UNMAP_BATCH_CONTROL(tsk)				\
 	INIT_KASAN(tsk)							\
 }
 
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index c89c53a113a8..29446aeef36e 100644
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
index 26a2e6122734..57ff61b16565 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1289,6 +1289,16 @@ enum perf_event_task_context {
 	perf_nr_task_contexts,
 };
 
+/* Matches SWAP_CLUSTER_MAX but refined to limit header dependencies */
+#define BATCH_TLBFLUSH_SIZE 32UL
+
+/* Track pages that require TLB flushes */
+struct tlbflush_unmap_batch {
+	struct cpumask cpumask;
+	unsigned long nr_pages;
+	unsigned long pfns[BATCH_TLBFLUSH_SIZE];
+};
+
 struct task_struct {
 	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
 	void *stack;
@@ -1648,6 +1658,10 @@ struct task_struct {
 	unsigned long numa_pages_migrated;
 #endif /* CONFIG_NUMA_BALANCING */
 
+#ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
+	struct tlbflush_unmap_batch *tlb_ubc;
+#endif
+
 	struct rcu_head rcu;
 
 	/*
diff --git a/init/Kconfig b/init/Kconfig
index dc24dec60232..1ff5d17e518a 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -904,6 +904,14 @@ config ARCH_SUPPORTS_NUMA_BALANCING
 	bool
 
 #
+# For architectures that have a local TLB flush for a PFN without knowledge
+# of the VMA. The architecture must provide guarantees on what happens if
+# a clean TLB cache entry is written after the unmap. Details are in mm/rmap.c
+# near the check for should_defer_flush.
+config ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
+	bool
+
+#
 # For architectures that know their GCC __int128 support is sound
 #
 config ARCH_SUPPORTS_INT128
diff --git a/kernel/fork.c b/kernel/fork.c
index 03c1eaaa6ef5..8ea9e8730ada 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -257,6 +257,11 @@ void __put_task_struct(struct task_struct *tsk)
 	delayacct_tsk_free(tsk);
 	put_signal_struct(tsk->signal);
 
+#ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
+	kfree(tsk->tlb_ubc);
+	tsk->tlb_ubc = NULL;
+#endif
+
 	if (!profile_handoff_task(tsk))
 		free_task(tsk);
 }
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 123673291ffb..936ce13aeb97 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1843,6 +1843,9 @@ static void __sched_fork(unsigned long clone_flags, struct task_struct *p)
 
 	p->numa_group = NULL;
 #endif /* CONFIG_NUMA_BALANCING */
+#ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
+	p->tlb_ubc = NULL;
+#endif /* CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH */
 }
 
 #ifdef CONFIG_NUMA_BALANCING
diff --git a/mm/internal.h b/mm/internal.h
index a25e359a4039..8cbb68ccc731 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -433,4 +433,15 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 #define ALLOC_CMA		0x80 /* allow allocations from CMA areas */
 #define ALLOC_FAIR		0x100 /* fair zone allocation */
 
+enum ttu_flags;
+struct tlbflush_unmap_batch;
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
index 24dd3f9fee27..a8dbba62398a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -60,6 +60,8 @@
 
 #include <asm/tlbflush.h>
 
+#include <trace/events/tlb.h>
+
 #include "internal.h"
 
 static struct kmem_cache *anon_vma_cachep;
@@ -581,6 +583,90 @@ vma_address(struct page *page, struct vm_area_struct *vma)
 	return address;
 }
 
+#ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
+static void percpu_flush_tlb_batch_pages(void *data)
+{
+	struct tlbflush_unmap_batch *tlb_ubc = data;
+	int i;
+
+	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
+	for (i = 0; i < tlb_ubc->nr_pages; i++)
+		flush_local_tlb_addr(tlb_ubc->pfns[i] << PAGE_SHIFT);
+}
+
+/*
+ * Flush TLB entries for recently unmapped pages from remote CPUs. It is
+ * important that if a PTE was dirty when it was unmapped that it's flushed
+ * before any IO is initiated on the page to prevent lost writes. Similarly,
+ * it must be flushed before freeing to prevent data leakage.
+ */
+void try_to_unmap_flush(void)
+{
+	struct tlbflush_unmap_batch *tlb_ubc = current->tlb_ubc;
+	int cpu;
+
+	if (!tlb_ubc || !tlb_ubc->nr_pages)
+		return;
+
+	trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, tlb_ubc->nr_pages);
+
+	preempt_disable();
+	cpu = smp_processor_id();
+	if (cpumask_test_cpu(cpu, &tlb_ubc->cpumask))
+		percpu_flush_tlb_batch_pages(&tlb_ubc->cpumask);
+
+	if (cpumask_any_but(&tlb_ubc->cpumask, cpu) < nr_cpu_ids) {
+		smp_call_function_many(&tlb_ubc->cpumask,
+			percpu_flush_tlb_batch_pages, (void *)tlb_ubc, true);
+	}
+	cpumask_clear(&tlb_ubc->cpumask);
+	tlb_ubc->nr_pages = 0;
+	preempt_enable();
+}
+
+static void set_tlb_ubc_flush_pending(struct mm_struct *mm,
+		struct page *page)
+{
+	struct tlbflush_unmap_batch *tlb_ubc = current->tlb_ubc;
+
+	cpumask_or(&tlb_ubc->cpumask, &tlb_ubc->cpumask, mm_cpumask(mm));
+	tlb_ubc->pfns[tlb_ubc->nr_pages] = page_to_pfn(page);
+	tlb_ubc->nr_pages++;
+
+	if (tlb_ubc->nr_pages == BATCH_TLBFLUSH_SIZE)
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
+	if (!current->tlb_ubc || !(flags & TTU_BATCH_FLUSH))
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
+static void set_tlb_ubc_flush_pending(struct mm_struct *mm,
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
@@ -1213,7 +1299,24 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 	/* Nuke the page table entry. */
 	flush_cache_page(vma, address, page_to_pfn(page));
-	pteval = ptep_clear_flush(vma, address, pte);
+	if (should_defer_flush(mm, flags)) {
+		/*
+		 * We clear the PTE but do not flush so potentially a remote
+		 * CPU could still be writing to the page. If the entry was
+		 * previously clean then the architecture must guarantee that
+		 * a clear->dirty transition on a cached TLB entry is written
+		 * through and traps if the PTE is unmapped.
+		 */
+		pteval = ptep_get_and_clear(mm, address, pte);
+
+		/* Potentially writable TLBs must be flushed before IO */
+		if (pte_dirty(pteval))
+			flush_tlb_page(vma, address);
+		else
+			set_tlb_ubc_flush_pending(mm, page);
+	} else {
+		pteval = ptep_clear_flush(vma, address, pte);
+	}
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
 	if (pte_dirty(pteval))
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5e8eadd71bac..5121742ccb87 100644
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
@@ -1175,6 +1176,7 @@ keep:
 	}
 
 	mem_cgroup_uncharge_list(&free_pages);
+	try_to_unmap_flush();
 	free_hot_cold_page_list(&free_pages, true);
 
 	list_splice(&ret_pages, page_list);
@@ -2118,6 +2120,23 @@ out:
 	}
 }
 
+#ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
+/*
+ * Allocate the control structure for batch TLB flushing. An allocation
+ * failure is harmless as the reclaimer will send IPIs where necessary.
+ */
+static void alloc_tlb_ubc(void)
+{
+	if (!current->tlb_ubc)
+		current->tlb_ubc = kzalloc(sizeof(struct tlbflush_unmap_batch),
+						GFP_KERNEL | __GFP_NOWARN);
+}
+#else
+static inline void alloc_tlb_ubc(void)
+{
+}
+#endif /* CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH */
+
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
@@ -2152,6 +2171,8 @@ static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
 	scan_adjusted = (global_reclaim(sc) && !current_is_kswapd() &&
 			 sc->priority == DEF_PRIORITY);
 
+	alloc_tlb_ubc();
+
 	blk_start_plug(&plug);
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
