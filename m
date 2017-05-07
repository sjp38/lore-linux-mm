Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB8326B03AB
	for <linux-mm@kvack.org>; Sun,  7 May 2017 08:39:30 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b67so42948269pfk.0
        for <linux-mm@kvack.org>; Sun, 07 May 2017 05:39:30 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id h184si9589083pfg.177.2017.05.07.05.39.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 May 2017 05:39:29 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 09/10] x86/mm: Rework lazy TLB to track the actual loaded mm
Date: Sun,  7 May 2017 05:38:38 -0700
Message-Id: <1a124281c99741606f1789140f9805beebb119da.1494160201.git.luto@kernel.org>
In-Reply-To: <cover.1494160201.git.luto@kernel.org>
References: <cover.1494160201.git.luto@kernel.org>
In-Reply-To: <cover.1494160201.git.luto@kernel.org>
References: <cover.1494160201.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

Lazy TLB state is current managed in a rather baroque manner.
AFAICT, there are three possible states:

 - Non-lazy.  This means that we're running a user thread or a
   kernel thread that has called use_mm().  current->mm ==
   current->active_mm == cpu_tlbstate.active_mm and
   cpu_tlbstate.state == TLBSTATE_OK.

 - Lazy with user mm.  We're running a kernel thread without an mm
   and we're borrowing an mm_struct.  We have current->mm == NULL,
   current->active_mm == cpu_tlbstate.active_mm, cpu_tlbstate.state
   != TLBSTATE_OK (i.e. TLBSTATE_LAZY or 0).  The current cpu is set
   in mm_cpumask(current->active_mm).  CR3 points to
   current->active_mm->pgd.  The TLB is up to date.

 - Lazy with init_mm.  This happens when we call leave_mm().  We
   have current->mm == NULL, current->active_mm ==
   cpu_tlbstate.active_mm, but that mm is only relelvant insofar as
   the scheduler is tracking it for refcounting.  cpu_tlbstate.state
   != TLBSTATE_OK.  The current cpu is clear in
   mm_cpumask(current->active_mm).  CR3 points to swapper_pg_dir,
   i.e. init_mm->pgd.

This patch simplifies the situation.  Other than perf, x86 stops
caring about current->active_mm at all.  We have
cpu_tlbstate.loaded_mm pointing to the mm that CR3 references.  The
TLB is always up to date for that mm.  leave_mm() just switches us
to init_mm.  There are no longer any special cases for mm_cpumask,
and switch_mm() switches mms without worrying about laziness.

After this patch, cpu_tlbstate.state serves only to tell the TLB
flush code whether it may switch to init_mm instead of doing a
normal flush.

This makes fairly extensive changes to xen_exit_mmap(), which used
to look a bit like black magic.

Perf is unchanged.  With or without this change, perf may behave a bit
erratically if it tries to read user memory in kernel thread context.
We should build on this patch to teach perf to never look at user
memory when cpu_tlbstate.loaded_mm != current->mm.

Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/events/core.c          |   3 +-
 arch/x86/include/asm/tlbflush.h |  12 ++-
 arch/x86/kernel/ldt.c           |   5 +-
 arch/x86/mm/init.c              |   2 +-
 arch/x86/mm/tlb.c               | 209 ++++++++++++++++++++--------------------
 arch/x86/xen/mmu.c              |  51 +++++-----
 6 files changed, 143 insertions(+), 139 deletions(-)

diff --git a/arch/x86/events/core.c b/arch/x86/events/core.c
index 580b60f5ac83..77a33096728d 100644
--- a/arch/x86/events/core.c
+++ b/arch/x86/events/core.c
@@ -2101,8 +2101,7 @@ static int x86_pmu_event_init(struct perf_event *event)
 
 static void refresh_pce(void *ignored)
 {
-	if (current->active_mm)
-		load_mm_cr4(current->active_mm);
+	load_mm_cr4(this_cpu_read(cpu_tlbstate.loaded_mm));
 }
 
 static void x86_pmu_event_mapped(struct perf_event *event)
diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 3c9289637669..a08680d3edaa 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -66,7 +66,13 @@ static inline void invpcid_flush_all_nonglobals(void)
 #endif
 
 struct tlb_state {
-	struct mm_struct *active_mm;
+	/*
+	 * cpu_tlbstate.loaded_mm should match CR3 whenever interrupts
+	 * are on.  This means that it may not match current->active_mm,
+	 * which will contain the previous user mm when we're in lazy TLB
+	 * mode even if we've already switched back to swapper_pg_dir.
+	 */
+	struct mm_struct *loaded_mm;
 	int state;
 
 	/*
@@ -256,7 +262,9 @@ void native_flush_tlb_others(const struct cpumask *cpumask,
 static inline void reset_lazy_tlbstate(void)
 {
 	this_cpu_write(cpu_tlbstate.state, 0);
-	this_cpu_write(cpu_tlbstate.active_mm, &init_mm);
+	this_cpu_write(cpu_tlbstate.loaded_mm, &init_mm);
+
+	WARN_ON(read_cr3() != __pa_symbol(swapper_pg_dir));
 }
 
 static inline void arch_tlbbatch_add_mm(struct arch_tlbflush_unmap_batch *batch,
diff --git a/arch/x86/kernel/ldt.c b/arch/x86/kernel/ldt.c
index d4a15831ac58..d7e01790ae86 100644
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -24,12 +24,13 @@
 /* context.lock is held for us, so we don't need any locking. */
 static void flush_ldt(void *current_mm)
 {
+	struct mm_struct *mm = current_mm;
 	mm_context_t *pc;
 
-	if (current->active_mm != current_mm)
+	if (this_cpu_read(cpu_tlbstate.loaded_mm) != current_mm)
 		return;
 
-	pc = &current->active_mm->context;
+	pc = &mm->context;
 	set_ldt(pc->ldt->entries, pc->ldt->size);
 }
 
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 078972129885..47453ce2374e 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -792,7 +792,7 @@ void __init zone_sizes_init(void)
 }
 
 DEFINE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate) = {
-	.active_mm = &init_mm,
+	.loaded_mm = &init_mm,
 	.state = 0,
 	.cr4 = ~0UL,	/* fail hard if we screw up cr4 shadow initialization */
 };
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index da1416c77bfb..c33fc1eaace4 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -34,20 +34,19 @@
  */
 void leave_mm(int cpu)
 {
-	struct mm_struct *active_mm = this_cpu_read(cpu_tlbstate.active_mm);
+	struct mm_struct *loaded_mm = this_cpu_read(cpu_tlbstate.loaded_mm);
 	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK)
 		BUG();
-	if (cpumask_test_cpu(cpu, mm_cpumask(active_mm))) {
-		cpumask_clear_cpu(cpu, mm_cpumask(active_mm));
-		load_cr3(swapper_pg_dir);
-		/*
-		 * This gets called in the idle path where RCU
-		 * functions differently.  Tracing normally
-		 * uses RCU, so we have to call the tracepoint
-		 * specially here.
-		 */
-		trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
-	}
+
+	/*
+	 * It's plausible that we're in lazy TLB mode while our mm is init_mm.
+	 * If so, our callers still expect us to flush the TLB, but there
+	 * aren't any user TLB entries in init_mm to worry about.
+	 */
+	if (loaded_mm == &init_mm)
+		return;
+
+	switch_mm(NULL, &init_mm, NULL);
 }
 EXPORT_SYMBOL_GPL(leave_mm);
 
@@ -65,108 +64,110 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 			struct task_struct *tsk)
 {
 	unsigned cpu = smp_processor_id();
+	struct mm_struct *real_prev = this_cpu_read(cpu_tlbstate.loaded_mm);
 
-	if (likely(prev != next)) {
-		if (IS_ENABLED(CONFIG_VMAP_STACK)) {
-			/*
-			 * If our current stack is in vmalloc space and isn't
-			 * mapped in the new pgd, we'll double-fault.  Forcibly
-			 * map it.
-			 */
-			unsigned int stack_pgd_index = pgd_index(current_stack_pointer());
+	/*
+	 * NB: The scheduler will call us with prev == next when
+	 * switching from lazy TLB mode to normal mode if active_mm
+	 * isn't changing.  When this happens, there is no guarantee
+	 * that CR3 (and hence cpu_tlbstate.loaded_mm) matches next.
+	 *
+	 * NB: leave_mm() calls us with prev == NULL and tsk == NULL.
+	 */
 
-			pgd_t *pgd = next->pgd + stack_pgd_index;
+	this_cpu_write(cpu_tlbstate.state, TLBSTATE_OK);
 
-			if (unlikely(pgd_none(*pgd)))
-				set_pgd(pgd, init_mm.pgd[stack_pgd_index]);
-		}
-
-		this_cpu_write(cpu_tlbstate.state, TLBSTATE_OK);
-		this_cpu_write(cpu_tlbstate.active_mm, next);
-
-		cpumask_set_cpu(cpu, mm_cpumask(next));
+	if (real_prev == next) {
+		/*
+		 * There's nothing to do: we always keep the per-mm control
+		 * regs in sync with cpu_tlbstate.loaded_mm.  Just
+		 * sanity-check mm_cpumask.
+		 */
+		if (WARN_ON_ONCE(!cpumask_test_cpu(cpu, mm_cpumask(next))))
+			cpumask_set_cpu(cpu, mm_cpumask(next));
+		return;
+	}
 
+	if (IS_ENABLED(CONFIG_VMAP_STACK)) {
 		/*
-		 * Re-load page tables.
-		 *
-		 * This logic has an ordering constraint:
-		 *
-		 *  CPU 0: Write to a PTE for 'next'
-		 *  CPU 0: load bit 1 in mm_cpumask.  if nonzero, send IPI.
-		 *  CPU 1: set bit 1 in next's mm_cpumask
-		 *  CPU 1: load from the PTE that CPU 0 writes (implicit)
-		 *
-		 * We need to prevent an outcome in which CPU 1 observes
-		 * the new PTE value and CPU 0 observes bit 1 clear in
-		 * mm_cpumask.  (If that occurs, then the IPI will never
-		 * be sent, and CPU 0's TLB will contain a stale entry.)
-		 *
-		 * The bad outcome can occur if either CPU's load is
-		 * reordered before that CPU's store, so both CPUs must
-		 * execute full barriers to prevent this from happening.
-		 *
-		 * Thus, switch_mm needs a full barrier between the
-		 * store to mm_cpumask and any operation that could load
-		 * from next->pgd.  TLB fills are special and can happen
-		 * due to instruction fetches or for no reason at all,
-		 * and neither LOCK nor MFENCE orders them.
-		 * Fortunately, load_cr3() is serializing and gives the
-		 * ordering guarantee we need.
-		 *
+		 * If our current stack is in vmalloc space and isn't
+		 * mapped in the new pgd, we'll double-fault.  Forcibly
+		 * map it.
 		 */
-		load_cr3(next->pgd);
+		unsigned int stack_pgd_index = pgd_index(current_stack_pointer());
 
-		trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
+		pgd_t *pgd = next->pgd + stack_pgd_index;
 
-		/* Stop flush ipis for the previous mm */
-		cpumask_clear_cpu(cpu, mm_cpumask(prev));
+		if (unlikely(pgd_none(*pgd)))
+			set_pgd(pgd, init_mm.pgd[stack_pgd_index]);
+	}
 
-		/* Load per-mm CR4 state */
-		load_mm_cr4(next);
+	this_cpu_write(cpu_tlbstate.loaded_mm, next);
+
+	WARN_ON_ONCE(cpumask_test_cpu(cpu, mm_cpumask(next)));
+	cpumask_set_cpu(cpu, mm_cpumask(next));
+
+	/*
+	 * Re-load page tables.
+	 *
+	 * This logic has an ordering constraint:
+	 *
+	 *  CPU 0: Write to a PTE for 'next'
+	 *  CPU 0: load bit 1 in mm_cpumask.  if nonzero, send IPI.
+	 *  CPU 1: set bit 1 in next's mm_cpumask
+	 *  CPU 1: load from the PTE that CPU 0 writes (implicit)
+	 *
+	 * We need to prevent an outcome in which CPU 1 observes
+	 * the new PTE value and CPU 0 observes bit 1 clear in
+	 * mm_cpumask.  (If that occurs, then the IPI will never
+	 * be sent, and CPU 0's TLB will contain a stale entry.)
+	 *
+	 * The bad outcome can occur if either CPU's load is
+	 * reordered before that CPU's store, so both CPUs must
+	 * execute full barriers to prevent this from happening.
+	 *
+	 * Thus, switch_mm needs a full barrier between the
+	 * store to mm_cpumask and any operation that could load
+	 * from next->pgd.  TLB fills are special and can happen
+	 * due to instruction fetches or for no reason at all,
+	 * and neither LOCK nor MFENCE orders them.
+	 * Fortunately, load_cr3() is serializing and gives the
+	 * ordering guarantee we need.
+	 *
+	 */
+	load_cr3(next->pgd);
+
+	/*
+	 * This gets called via leave_mm() in the idle path where RCU
+	 * functions differently.  Tracing normally uses RCU, so we have to
+	 * call the tracepoint specially here.
+	 */
+	trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
+
+	/* Stop flush ipis for the previous mm */
+	WARN_ON_ONCE(!cpumask_test_cpu(cpu, mm_cpumask(real_prev)) &&
+		     real_prev != &init_mm);
+	cpumask_clear_cpu(cpu, mm_cpumask(real_prev));
+
+	/* Load per-mm CR4 state */
+	load_mm_cr4(next);
 
 #ifdef CONFIG_MODIFY_LDT_SYSCALL
-		/*
-		 * Load the LDT, if the LDT is different.
-		 *
-		 * It's possible that prev->context.ldt doesn't match
-		 * the LDT register.  This can happen if leave_mm(prev)
-		 * was called and then modify_ldt changed
-		 * prev->context.ldt but suppressed an IPI to this CPU.
-		 * In this case, prev->context.ldt != NULL, because we
-		 * never set context.ldt to NULL while the mm still
-		 * exists.  That means that next->context.ldt !=
-		 * prev->context.ldt, because mms never share an LDT.
-		 */
-		if (unlikely(prev->context.ldt != next->context.ldt))
-			load_mm_ldt(next);
+	/*
+	 * Load the LDT, if the LDT is different.
+	 *
+	 * It's possible that prev->context.ldt doesn't match
+	 * the LDT register.  This can happen if leave_mm(prev)
+	 * was called and then modify_ldt changed
+	 * prev->context.ldt but suppressed an IPI to this CPU.
+	 * In this case, prev->context.ldt != NULL, because we
+	 * never set context.ldt to NULL while the mm still
+	 * exists.  That means that next->context.ldt !=
+	 * prev->context.ldt, because mms never share an LDT.
+	 */
+	if (unlikely(real_prev->context.ldt != next->context.ldt))
+		load_mm_ldt(next);
 #endif
-	} else {
-		this_cpu_write(cpu_tlbstate.state, TLBSTATE_OK);
-		BUG_ON(this_cpu_read(cpu_tlbstate.active_mm) != next);
-
-		if (!cpumask_test_cpu(cpu, mm_cpumask(next))) {
-			/*
-			 * On established mms, the mm_cpumask is only changed
-			 * from irq context, from ptep_clear_flush() while in
-			 * lazy tlb mode, and here. Irqs are blocked during
-			 * schedule, protecting us from simultaneous changes.
-			 */
-			cpumask_set_cpu(cpu, mm_cpumask(next));
-
-			/*
-			 * We were in lazy tlb mode and leave_mm disabled
-			 * tlb flush IPI delivery. We must reload CR3
-			 * to make sure to use no freed page tables.
-			 *
-			 * As above, load_cr3() is serializing and orders TLB
-			 * fills with respect to the mm_cpumask write.
-			 */
-			load_cr3(next->pgd);
-			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
-			load_mm_cr4(next);
-			load_mm_ldt(next);
-		}
-	}
 }
 
 /*
@@ -246,7 +247,7 @@ static void flush_tlb_func_remote(void *info)
 
 	inc_irq_stat(irq_tlb_count);
 
-	if (f->mm && f->mm != this_cpu_read(cpu_tlbstate.active_mm))
+	if (f->mm && f->mm != this_cpu_read(cpu_tlbstate.loaded_mm))
 		return;
 
 	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
@@ -314,7 +315,7 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 		info.end = TLB_FLUSH_ALL;
 	}
 
-	if (mm == current->active_mm)
+	if (mm == this_cpu_read(cpu_tlbstate.loaded_mm))
 		flush_tlb_func_local(&info, TLB_LOCAL_MM_SHOOTDOWN);
 	if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), &info);
diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index 894daefd6958..c34fd91a0f5a 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -1013,37 +1013,32 @@ static void xen_dup_mmap(struct mm_struct *oldmm, struct mm_struct *mm)
 	spin_unlock(&mm->page_table_lock);
 }
 
-
-#ifdef CONFIG_SMP
-/* Another cpu may still have their %cr3 pointing at the pagetable, so
-   we need to repoint it somewhere else before we can unpin it. */
-static void drop_other_mm_ref(void *info)
+static void drop_mm_ref_this_cpu(void *info)
 {
 	struct mm_struct *mm = info;
-	struct mm_struct *active_mm;
-
-	active_mm = this_cpu_read(cpu_tlbstate.active_mm);
 
-	if (active_mm == mm && this_cpu_read(cpu_tlbstate.state) != TLBSTATE_OK)
+	if (this_cpu_read(cpu_tlbstate.loaded_mm) == mm)
 		leave_mm(smp_processor_id());
 
-	/* If this cpu still has a stale cr3 reference, then make sure
-	   it has been flushed. */
+	/*
+	 * If this cpu still has a stale cr3 reference, then make sure
+	 * it has been flushed.
+	 */
 	if (this_cpu_read(xen_current_cr3) == __pa(mm->pgd))
-		load_cr3(swapper_pg_dir);
+		xen_mc_flush();
 }
 
+#ifdef CONFIG_SMP
+/*
+ * Another cpu may still have their %cr3 pointing at the pagetable, so
+ * we need to repoint it somewhere else before we can unpin it.
+ */
 static void xen_drop_mm_ref(struct mm_struct *mm)
 {
 	cpumask_var_t mask;
 	unsigned cpu;
 
-	if (current->active_mm == mm) {
-		if (current->mm == mm)
-			load_cr3(swapper_pg_dir);
-		else
-			leave_mm(smp_processor_id());
-	}
+	drop_mm_ref_this_cpu(mm);
 
 	/* Get the "official" set of cpus referring to our pagetable. */
 	if (!alloc_cpumask_var(&mask, GFP_ATOMIC)) {
@@ -1051,31 +1046,31 @@ static void xen_drop_mm_ref(struct mm_struct *mm)
 			if (!cpumask_test_cpu(cpu, mm_cpumask(mm))
 			    && per_cpu(xen_current_cr3, cpu) != __pa(mm->pgd))
 				continue;
-			smp_call_function_single(cpu, drop_other_mm_ref, mm, 1);
+			smp_call_function_single(cpu, drop_mm_ref_this_cpu, mm, 1);
 		}
 		return;
 	}
 	cpumask_copy(mask, mm_cpumask(mm));
 
-	/* It's possible that a vcpu may have a stale reference to our
-	   cr3, because its in lazy mode, and it hasn't yet flushed
-	   its set of pending hypercalls yet.  In this case, we can
-	   look at its actual current cr3 value, and force it to flush
-	   if needed. */
+	/*
+	 * It's possible that a vcpu may have a stale reference to our
+	 * cr3, because its in lazy mode, and it hasn't yet flushed
+	 * its set of pending hypercalls yet.  In this case, we can
+	 * look at its actual current cr3 value, and force it to flush
+	 * if needed.
+	 */
 	for_each_online_cpu(cpu) {
 		if (per_cpu(xen_current_cr3, cpu) == __pa(mm->pgd))
 			cpumask_set_cpu(cpu, mask);
 	}
 
-	if (!cpumask_empty(mask))
-		smp_call_function_many(mask, drop_other_mm_ref, mm, 1);
+	smp_call_function_many(mask, drop_mm_ref_this_cpu, mm, 1);
 	free_cpumask_var(mask);
 }
 #else
 static void xen_drop_mm_ref(struct mm_struct *mm)
 {
-	if (current->active_mm == mm)
-		load_cr3(swapper_pg_dir);
+	drop_mm_ref_this_cpu(mm);
 }
 #endif
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
