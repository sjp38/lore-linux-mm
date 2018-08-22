Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6C96D6B251D
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 11:46:07 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s18-v6so2116534wmc.5
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 08:46:07 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 7-v6si1707347wri.221.2018.08.22.08.46.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 22 Aug 2018 08:46:05 -0700 (PDT)
Message-ID: <20180822154046.717610121@infradead.org>
Date: Wed, 22 Aug 2018 17:30:13 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 1/4] x86/mm/tlb: Revert the recent lazy TLB patches
References: <20180822153012.173508681@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: peterz@infradead.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, will.deacon@arm.com, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Revert commits:

  95b0e6357d3e x86/mm/tlb: Always use lazy TLB mode
  64482aafe55f x86/mm/tlb: Only send page table free TLB flush to lazy TLB CPUs
  ac0315896970 x86/mm/tlb: Make lazy TLB mode lazier
  61d0beb5796a x86/mm/tlb: Restructure switch_mm_irqs_off()
  2ff6ddf19c0e x86/mm/tlb: Leave lazy TLB mode at page table free time

In order to simplify the TLB invalidate fixes for x86. We'll try again later.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -148,6 +148,22 @@ static inline unsigned long build_cr3_no
 #define __flush_tlb_one_user(addr) __native_flush_tlb_one_user(addr)
 #endif
 
+static inline bool tlb_defer_switch_to_init_mm(void)
+{
+	/*
+	 * If we have PCID, then switching to init_mm is reasonably
+	 * fast.  If we don't have PCID, then switching to init_mm is
+	 * quite slow, so we try to defer it in the hopes that we can
+	 * avoid it entirely.  The latter approach runs the risk of
+	 * receiving otherwise unnecessary IPIs.
+	 *
+	 * This choice is just a heuristic.  The tlb code can handle this
+	 * function returning true or false regardless of whether we have
+	 * PCID.
+	 */
+	return !static_cpu_has(X86_FEATURE_PCID);
+}
+
 struct tlb_context {
 	u64 ctx_id;
 	u64 tlb_gen;
@@ -538,9 +554,4 @@ extern void arch_tlbbatch_flush(struct a
 	native_flush_tlb_others(mask, info)
 #endif
 
-extern void tlb_flush_remove_tables(struct mm_struct *mm);
-extern void tlb_flush_remove_tables_local(void *arg);
-
-#define HAVE_TLB_FLUSH_REMOVE_TABLES
-
 #endif /* _ASM_X86_TLBFLUSH_H */
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -7,7 +7,6 @@
 #include <linux/export.h>
 #include <linux/cpu.h>
 #include <linux/debugfs.h>
-#include <linux/gfp.h>
 
 #include <asm/tlbflush.h>
 #include <asm/mmu_context.h>
@@ -186,11 +185,8 @@ void switch_mm_irqs_off(struct mm_struct
 {
 	struct mm_struct *real_prev = this_cpu_read(cpu_tlbstate.loaded_mm);
 	u16 prev_asid = this_cpu_read(cpu_tlbstate.loaded_mm_asid);
-	bool was_lazy = this_cpu_read(cpu_tlbstate.is_lazy);
 	unsigned cpu = smp_processor_id();
 	u64 next_tlb_gen;
-	bool need_flush;
-	u16 new_asid;
 
 	/*
 	 * NB: The scheduler will call us with prev == next when switching
@@ -244,41 +240,20 @@ void switch_mm_irqs_off(struct mm_struct
 			   next->context.ctx_id);
 
 		/*
-		 * Even in lazy TLB mode, the CPU should stay set in the
-		 * mm_cpumask. The TLB shootdown code can figure out from
-		 * from cpu_tlbstate.is_lazy whether or not to send an IPI.
+		 * We don't currently support having a real mm loaded without
+		 * our cpu set in mm_cpumask().  We have all the bookkeeping
+		 * in place to figure out whether we would need to flush
+		 * if our cpu were cleared in mm_cpumask(), but we don't
+		 * currently use it.
 		 */
 		if (WARN_ON_ONCE(real_prev != &init_mm &&
 				 !cpumask_test_cpu(cpu, mm_cpumask(next))))
 			cpumask_set_cpu(cpu, mm_cpumask(next));
 
-		/*
-		 * If the CPU is not in lazy TLB mode, we are just switching
-		 * from one thread in a process to another thread in the same
-		 * process. No TLB flush required.
-		 */
-		if (!was_lazy)
-			return;
-
-		/*
-		 * Read the tlb_gen to check whether a flush is needed.
-		 * If the TLB is up to date, just use it.
-		 * The barrier synchronizes with the tlb_gen increment in
-		 * the TLB shootdown code.
-		 */
-		smp_mb();
-		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
-		if (this_cpu_read(cpu_tlbstate.ctxs[prev_asid].tlb_gen) ==
-				next_tlb_gen)
-			return;
-
-		/*
-		 * TLB contents went out of date while we were in lazy
-		 * mode. Fall through to the TLB switching code below.
-		 */
-		new_asid = prev_asid;
-		need_flush = true;
+		return;
 	} else {
+		u16 new_asid;
+		bool need_flush;
 		u64 last_ctx_id = this_cpu_read(cpu_tlbstate.last_ctx_id);
 
 		/*
@@ -329,41 +304,41 @@ void switch_mm_irqs_off(struct mm_struct
 		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
 
 		choose_new_asid(next, next_tlb_gen, &new_asid, &need_flush);
-	}
 
-	if (need_flush) {
-		this_cpu_write(cpu_tlbstate.ctxs[new_asid].ctx_id, next->context.ctx_id);
-		this_cpu_write(cpu_tlbstate.ctxs[new_asid].tlb_gen, next_tlb_gen);
-		load_new_mm_cr3(next->pgd, new_asid, true);
+		if (need_flush) {
+			this_cpu_write(cpu_tlbstate.ctxs[new_asid].ctx_id, next->context.ctx_id);
+			this_cpu_write(cpu_tlbstate.ctxs[new_asid].tlb_gen, next_tlb_gen);
+			load_new_mm_cr3(next->pgd, new_asid, true);
+
+			/*
+			 * NB: This gets called via leave_mm() in the idle path
+			 * where RCU functions differently.  Tracing normally
+			 * uses RCU, so we need to use the _rcuidle variant.
+			 *
+			 * (There is no good reason for this.  The idle code should
+			 *  be rearranged to call this before rcu_idle_enter().)
+			 */
+			trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
+		} else {
+			/* The new ASID is already up to date. */
+			load_new_mm_cr3(next->pgd, new_asid, false);
+
+			/* See above wrt _rcuidle. */
+			trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH, 0);
+		}
 
 		/*
-		 * NB: This gets called via leave_mm() in the idle path
-		 * where RCU functions differently.  Tracing normally
-		 * uses RCU, so we need to use the _rcuidle variant.
-		 *
-		 * (There is no good reason for this.  The idle code should
-		 *  be rearranged to call this before rcu_idle_enter().)
+		 * Record last user mm's context id, so we can avoid
+		 * flushing branch buffer with IBPB if we switch back
+		 * to the same user.
 		 */
-		trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
-	} else {
-		/* The new ASID is already up to date. */
-		load_new_mm_cr3(next->pgd, new_asid, false);
+		if (next != &init_mm)
+			this_cpu_write(cpu_tlbstate.last_ctx_id, next->context.ctx_id);
 
-		/* See above wrt _rcuidle. */
-		trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH, 0);
+		this_cpu_write(cpu_tlbstate.loaded_mm, next);
+		this_cpu_write(cpu_tlbstate.loaded_mm_asid, new_asid);
 	}
 
-	/*
-	 * Record last user mm's context id, so we can avoid
-	 * flushing branch buffer with IBPB if we switch back
-	 * to the same user.
-	 */
-	if (next != &init_mm)
-		this_cpu_write(cpu_tlbstate.last_ctx_id, next->context.ctx_id);
-
-	this_cpu_write(cpu_tlbstate.loaded_mm, next);
-	this_cpu_write(cpu_tlbstate.loaded_mm_asid, new_asid);
-
 	load_mm_cr4(next);
 	switch_ldt(real_prev, next);
 }
@@ -386,7 +361,20 @@ void enter_lazy_tlb(struct mm_struct *mm
 	if (this_cpu_read(cpu_tlbstate.loaded_mm) == &init_mm)
 		return;
 
-	this_cpu_write(cpu_tlbstate.is_lazy, true);
+	if (tlb_defer_switch_to_init_mm()) {
+		/*
+		 * There's a significant optimization that may be possible
+		 * here.  We have accurate enough TLB flush tracking that we
+		 * don't need to maintain coherence of TLB per se when we're
+		 * lazy.  We do, however, need to maintain coherence of
+		 * paging-structure caches.  We could, in principle, leave our
+		 * old mm loaded and only switch to init_mm when
+		 * tlb_remove_page() happens.
+		 */
+		this_cpu_write(cpu_tlbstate.is_lazy, true);
+	} else {
+		switch_mm(NULL, &init_mm, NULL);
+	}
 }
 
 /*
@@ -473,9 +461,6 @@ static void flush_tlb_func_common(const
 		 * paging-structure cache to avoid speculatively reading
 		 * garbage into our TLB.  Since switching to init_mm is barely
 		 * slower than a minimal flush, just switch to init_mm.
-		 *
-		 * This should be rare, with native_flush_tlb_others skipping
-		 * IPIs to lazy TLB mode CPUs.
 		 */
 		switch_mm_irqs_off(NULL, &init_mm, NULL);
 		return;
@@ -582,9 +567,6 @@ static void flush_tlb_func_remote(void *
 void native_flush_tlb_others(const struct cpumask *cpumask,
 			     const struct flush_tlb_info *info)
 {
-	cpumask_var_t lazymask;
-	unsigned int cpu;
-
 	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH);
 	if (info->end == TLB_FLUSH_ALL)
 		trace_tlb_flush(TLB_REMOTE_SEND_IPI, TLB_FLUSH_ALL);
@@ -608,6 +590,8 @@ void native_flush_tlb_others(const struc
 		 * that UV should be updated so that smp_call_function_many(),
 		 * etc, are optimal on UV.
 		 */
+		unsigned int cpu;
+
 		cpu = smp_processor_id();
 		cpumask = uv_flush_tlb_others(cpumask, info);
 		if (cpumask)
@@ -615,29 +599,8 @@ void native_flush_tlb_others(const struc
 					       (void *)info, 1);
 		return;
 	}
-
-	/*
-	 * A temporary cpumask is used in order to skip sending IPIs
-	 * to CPUs in lazy TLB state, while keeping them in mm_cpumask(mm).
-	 * If the allocation fails, simply IPI every CPU in mm_cpumask.
-	 */
-	if (!alloc_cpumask_var(&lazymask, GFP_ATOMIC)) {
-		smp_call_function_many(cpumask, flush_tlb_func_remote,
+	smp_call_function_many(cpumask, flush_tlb_func_remote,
 			       (void *)info, 1);
-		return;
-	}
-
-	cpumask_copy(lazymask, cpumask);
-
-	for_each_cpu(cpu, lazymask) {
-		if (per_cpu(cpu_tlbstate.is_lazy, cpu))
-			cpumask_clear_cpu(cpu, lazymask);
-	}
-
-	smp_call_function_many(lazymask, flush_tlb_func_remote,
-			       (void *)info, 1);
-
-	free_cpumask_var(lazymask);
 }
 
 /*
@@ -690,68 +653,6 @@ void flush_tlb_mm_range(struct mm_struct
 	put_cpu();
 }
 
-void tlb_flush_remove_tables_local(void *arg)
-{
-	struct mm_struct *mm = arg;
-
-	if (this_cpu_read(cpu_tlbstate.loaded_mm) == mm &&
-			this_cpu_read(cpu_tlbstate.is_lazy)) {
-		/*
-		 * We're in lazy mode.  We need to at least flush our
-		 * paging-structure cache to avoid speculatively reading
-		 * garbage into our TLB.  Since switching to init_mm is barely
-		 * slower than a minimal flush, just switch to init_mm.
-		 */
-		switch_mm_irqs_off(NULL, &init_mm, NULL);
-	}
-}
-
-static void mm_fill_lazy_tlb_cpu_mask(struct mm_struct *mm,
-				      struct cpumask *lazy_cpus)
-{
-	int cpu;
-
-	for_each_cpu(cpu, mm_cpumask(mm)) {
-		if (!per_cpu(cpu_tlbstate.is_lazy, cpu))
-			cpumask_set_cpu(cpu, lazy_cpus);
-	}
-}
-
-void tlb_flush_remove_tables(struct mm_struct *mm)
-{
-	int cpu = get_cpu();
-	cpumask_var_t lazy_cpus;
-
-	if (cpumask_any_but(mm_cpumask(mm), cpu) >= nr_cpu_ids) {
-		put_cpu();
-		return;
-	}
-
-	if (!zalloc_cpumask_var(&lazy_cpus, GFP_ATOMIC)) {
-		/*
-		 * If the cpumask allocation fails, do a brute force flush
-		 * on all the CPUs that have this mm loaded.
-		 */
-		smp_call_function_many(mm_cpumask(mm),
-				tlb_flush_remove_tables_local, (void *)mm, 1);
-		put_cpu();
-		return;
-	}
-
-	/*
-	 * CPUs with !is_lazy either received a TLB flush IPI while the user
-	 * pages in this address range were unmapped, or have context switched
-	 * and reloaded %CR3 since then.
-	 *
-	 * Shootdown IPIs at page table freeing time only need to be sent to
-	 * CPUs that may have out of date TLB contents.
-	 */
-	mm_fill_lazy_tlb_cpu_mask(mm, lazy_cpus);
-	smp_call_function_many(lazy_cpus,
-				tlb_flush_remove_tables_local, (void *)mm, 1);
-	free_cpumask_var(lazy_cpus);
-	put_cpu();
-}
 
 static void do_flush_tlb_all(void *info)
 {
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -303,14 +303,4 @@ static inline void tlb_remove_check_page
 
 #define tlb_migrate_finish(mm) do {} while (0)
 
-/*
- * Used to flush the TLB when page tables are removed, when lazy
- * TLB mode may cause a CPU to retain intermediate translations
- * pointing to about-to-be-freed page table memory.
- */
-#ifndef HAVE_TLB_FLUSH_REMOVE_TABLES
-#define tlb_flush_remove_tables(mm) do {} while (0)
-#define tlb_flush_remove_tables_local(mm) do {} while (0)
-#endif
-
 #endif /* _ASM_GENERIC__TLB_H */
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -326,20 +326,16 @@ bool __tlb_remove_page_size(struct mmu_g
 
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 
+/*
+ * See the comment near struct mmu_table_batch.
+ */
+
 static void tlb_remove_table_smp_sync(void *arg)
 {
-	struct mm_struct __maybe_unused *mm = arg;
-	/*
-	 * On most architectures this does nothing. Simply delivering the
-	 * interrupt is enough to prevent races with software page table
-	 * walking like that done in get_user_pages_fast.
-	 *
-	 * See the comment near struct mmu_table_batch.
-	 */
-	tlb_flush_remove_tables_local(mm);
+	/* Simply deliver the interrupt */
 }
 
-static void tlb_remove_table_one(void *table, struct mmu_gather *tlb)
+static void tlb_remove_table_one(void *table)
 {
 	/*
 	 * This isn't an RCU grace period and hence the page-tables cannot be
@@ -348,7 +344,7 @@ static void tlb_remove_table_one(void *t
 	 * It is however sufficient for software page-table walkers that rely on
 	 * IRQ disabling. See the comment near struct mmu_table_batch.
 	 */
-	smp_call_function(tlb_remove_table_smp_sync, tlb->mm, 1);
+	smp_call_function(tlb_remove_table_smp_sync, NULL, 1);
 	__tlb_remove_table(table);
 }
 
@@ -369,8 +365,6 @@ void tlb_table_flush(struct mmu_gather *
 {
 	struct mmu_table_batch **batch = &tlb->batch;
 
-	tlb_flush_remove_tables(tlb->mm);
-
 	if (*batch) {
 		call_rcu_sched(&(*batch)->rcu, tlb_remove_table_rcu);
 		*batch = NULL;
@@ -393,7 +387,7 @@ void tlb_remove_table(struct mmu_gather
 	if (*batch == NULL) {
 		*batch = (struct mmu_table_batch *)__get_free_page(GFP_NOWAIT | __GFP_NOWARN);
 		if (*batch == NULL) {
-			tlb_remove_table_one(table, tlb);
+			tlb_remove_table_one(table);
 			return;
 		}
 		(*batch)->nr = 0;
