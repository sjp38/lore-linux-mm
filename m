Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0808F6B02FA
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 00:56:41 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id a30so65072003otd.2
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 21:56:41 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o185si1110853oig.207.2017.06.13.21.56.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 21:56:40 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 05/10] x86/mm: Rework lazy TLB mode and TLB freshness tracking
Date: Tue, 13 Jun 2017 21:56:23 -0700
Message-Id: <039935bc914009103fdaa6f72f14980c19562de5.1497415951.git.luto@kernel.org>
In-Reply-To: <cover.1497415951.git.luto@kernel.org>
References: <cover.1497415951.git.luto@kernel.org>
In-Reply-To: <cover.1497415951.git.luto@kernel.org>
References: <cover.1497415951.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

x86's lazy TLB mode used to be fairly weak -- it would switch to
init_mm the first time it tried to flush a lazy TLB.  This meant an
unnecessary CR3 write and, if the flush was remote, an unnecessary
IPI.

Rewrite it entirely.  When we enter lazy mode, we simply remove the
cpu from mm_cpumask.  This means that we need a way to figure out
whether we've missed a flush when we switch back out of lazy mode.
I use the tlb_gen machinery to track whether a context is up to
date.

Note to reviewers: this patch, my itself, looks a bit odd.  I'm
using an array of length 1 containing (ctx_id, tlb_gen) rather than
just storing tlb_gen, and making it at array isn't necessary yet.
I'm doing this because the next few patches add PCID support, and,
with PCID, we need ctx_id, and the array will end up with a length
greater than 1.  Making it an array now means that there will be
less churn and therefore less stress on your eyeballs.

NB: This is dubious but, AFAICT, still correct on Xen and UV.
xen_exit_mmap() uses mm_cpumask() for nefarious purposes and this
patch changes the way that mm_cpumask() works.  This should be okay,
since Xen *also* iterates all online CPUs to find all the CPUs it
needs to twiddle.

The UV tlbflush code is rather dated and should be changed.

Cc: Andrew Banman <abanman@sgi.com>
Cc: Mike Travis <travis@sgi.com>
Cc: Dimitri Sivanich <sivanich@sgi.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/mmu_context.h |   6 +-
 arch/x86/include/asm/tlbflush.h    |   4 -
 arch/x86/mm/init.c                 |   1 -
 arch/x86/mm/tlb.c                  | 242 +++++++++++++++++++------------------
 4 files changed, 131 insertions(+), 122 deletions(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index e5295d485899..69a4f1ee86ac 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -125,8 +125,10 @@ static inline void switch_ldt(struct mm_struct *prev, struct mm_struct *next)
 
 static inline void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk)
 {
-	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK)
-		this_cpu_write(cpu_tlbstate.state, TLBSTATE_LAZY);
+	int cpu = smp_processor_id();
+
+	if (cpumask_test_cpu(cpu, mm_cpumask(mm)))
+		cpumask_clear_cpu(cpu, mm_cpumask(mm));
 }
 
 extern atomic64_t last_mm_ctx_id;
diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 4f6c30d6ec39..87b13e51e867 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -95,7 +95,6 @@ struct tlb_state {
 	 * mode even if we've already switched back to swapper_pg_dir.
 	 */
 	struct mm_struct *loaded_mm;
-	int state;
 
 	/*
 	 * Access to this CR4 shadow and to H/W CR4 is protected by
@@ -310,9 +309,6 @@ static inline void flush_tlb_page(struct vm_area_struct *vma, unsigned long a)
 void native_flush_tlb_others(const struct cpumask *cpumask,
 			     const struct flush_tlb_info *info);
 
-#define TLBSTATE_OK	1
-#define TLBSTATE_LAZY	2
-
 static inline void arch_tlbbatch_add_mm(struct arch_tlbflush_unmap_batch *batch,
 					struct mm_struct *mm)
 {
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 88ee942cb47d..7d6fa4676af9 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -812,7 +812,6 @@ void __init zone_sizes_init(void)
 
 DEFINE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate) = {
 	.loaded_mm = &init_mm,
-	.state = 0,
 	.cr4 = ~0UL,	/* fail hard if we screw up cr4 shadow initialization */
 };
 EXPORT_SYMBOL_GPL(cpu_tlbstate);
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 3b19ba748e92..fea2b07ac7d8 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -45,8 +45,8 @@ void leave_mm(int cpu)
 	if (loaded_mm == &init_mm)
 		return;
 
-	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK)
-		BUG();
+	/* Warn if we're not lazy. */
+	WARN_ON(cpumask_test_cpu(smp_processor_id(), mm_cpumask(loaded_mm)));
 
 	switch_mm(NULL, &init_mm, NULL);
 }
@@ -67,133 +67,118 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 {
 	unsigned cpu = smp_processor_id();
 	struct mm_struct *real_prev = this_cpu_read(cpu_tlbstate.loaded_mm);
+	u64 next_tlb_gen;
 
 	/*
-	 * NB: The scheduler will call us with prev == next when
-	 * switching from lazy TLB mode to normal mode if active_mm
-	 * isn't changing.  When this happens, there is no guarantee
-	 * that CR3 (and hence cpu_tlbstate.loaded_mm) matches next.
+	 * NB: The scheduler will call us with prev == next when switching
+	 * from lazy TLB mode to normal mode if active_mm isn't changing.
+	 * When this happens, we don't assume that CR3 (and hence
+	 * cpu_tlbstate.loaded_mm) matches next.
 	 *
 	 * NB: leave_mm() calls us with prev == NULL and tsk == NULL.
 	 */
 
-	this_cpu_write(cpu_tlbstate.state, TLBSTATE_OK);
+	/* We don't want flush_tlb_func_* to run concurrently with us. */
+	if (IS_ENABLED(CONFIG_PROVE_LOCKING))
+		WARN_ON_ONCE(!irqs_disabled());
+
+	VM_BUG_ON(read_cr3_pa() != __pa(real_prev->pgd));
 
 	if (real_prev == next) {
-		/*
-		 * There's nothing to do: we always keep the per-mm control
-		 * regs in sync with cpu_tlbstate.loaded_mm.  Just
-		 * sanity-check mm_cpumask.
-		 */
-		if (WARN_ON_ONCE(!cpumask_test_cpu(cpu, mm_cpumask(next))))
-			cpumask_set_cpu(cpu, mm_cpumask(next));
-		return;
-	}
+		if (cpumask_test_cpu(cpu, mm_cpumask(next))) {
+			/*
+			 * There's nothing to do: we weren't lazy, and we
+			 * aren't changing our mm.  We don't need to flush
+			 * anything, nor do we need to update CR3, CR4, or
+			 * LDTR.
+			 */
+			return;
+		}
+
+		/* Resume remote flushes and then read tlb_gen. */
+		cpumask_set_cpu(cpu, mm_cpumask(next));
+		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
+
+		VM_BUG_ON(this_cpu_read(cpu_tlbstate.ctxs[0].ctx_id) !=
+			  next->context.ctx_id);
+
+		if (this_cpu_read(cpu_tlbstate.ctxs[0].tlb_gen) <
+		    next_tlb_gen) {
+			/*
+			 * Ideally, we'd have a flush_tlb() variant that
+			 * takes the known CR3 value as input.  This would
+			 * be faster on Xen PV and on hypothetical CPUs
+			 * on which INVPCID is fast.
+			 */
+			this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen,
+				       next_tlb_gen);
+			write_cr3(__pa(next->pgd));
+			/*
+			 * This gets called via leave_mm() in the idle path
+			 * where RCU functions differently.  Tracing normally
+			 * uses RCU, so we have to call the tracepoint
+			 * specially here.
+			 */
+			trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH,
+						TLB_FLUSH_ALL);
+		}
 
-	if (IS_ENABLED(CONFIG_VMAP_STACK)) {
 		/*
-		 * If our current stack is in vmalloc space and isn't
-		 * mapped in the new pgd, we'll double-fault.  Forcibly
-		 * map it.
+		 * We just exited lazy mode, which means that CR4 and/or LDTR
+		 * may be stale.  (Changes to the required CR4 and LDTR states
+		 * are not reflected in tlb_gen.)
 		 */
-		unsigned int stack_pgd_index = pgd_index(current_stack_pointer());
-
-		pgd_t *pgd = next->pgd + stack_pgd_index;
+	} else {
+		if (IS_ENABLED(CONFIG_VMAP_STACK)) {
+			/*
+			 * If our current stack is in vmalloc space and isn't
+			 * mapped in the new pgd, we'll double-fault.  Forcibly
+			 * map it.
+			 */
+			unsigned int stack_pgd_index =
+				pgd_index(current_stack_pointer());
+
+			pgd_t *pgd = next->pgd + stack_pgd_index;
+
+			if (unlikely(pgd_none(*pgd)))
+				set_pgd(pgd, init_mm.pgd[stack_pgd_index]);
+		}
 
-		if (unlikely(pgd_none(*pgd)))
-			set_pgd(pgd, init_mm.pgd[stack_pgd_index]);
-	}
+		/* Stop remote flushes for the previous mm */
+		if (cpumask_test_cpu(cpu, mm_cpumask(real_prev)))
+			cpumask_clear_cpu(cpu, mm_cpumask(real_prev));
 
-	this_cpu_write(cpu_tlbstate.loaded_mm, next);
-	this_cpu_write(cpu_tlbstate.ctxs[0].ctx_id, next->context.ctx_id);
-	this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen,
-		       atomic64_read(&next->context.tlb_gen));
+		WARN_ON_ONCE(cpumask_test_cpu(cpu, mm_cpumask(next)));
 
-	WARN_ON_ONCE(cpumask_test_cpu(cpu, mm_cpumask(next)));
-	cpumask_set_cpu(cpu, mm_cpumask(next));
+		/*
+		 * Start remote flushes and then read tlb_gen.
+		 */
+		cpumask_set_cpu(cpu, mm_cpumask(next));
+		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
 
-	/*
-	 * Re-load page tables.
-	 *
-	 * This logic has an ordering constraint:
-	 *
-	 *  CPU 0: Write to a PTE for 'next'
-	 *  CPU 0: load bit 1 in mm_cpumask.  if nonzero, send IPI.
-	 *  CPU 1: set bit 1 in next's mm_cpumask
-	 *  CPU 1: load from the PTE that CPU 0 writes (implicit)
-	 *
-	 * We need to prevent an outcome in which CPU 1 observes
-	 * the new PTE value and CPU 0 observes bit 1 clear in
-	 * mm_cpumask.  (If that occurs, then the IPI will never
-	 * be sent, and CPU 0's TLB will contain a stale entry.)
-	 *
-	 * The bad outcome can occur if either CPU's load is
-	 * reordered before that CPU's store, so both CPUs must
-	 * execute full barriers to prevent this from happening.
-	 *
-	 * Thus, switch_mm needs a full barrier between the
-	 * store to mm_cpumask and any operation that could load
-	 * from next->pgd.  TLB fills are special and can happen
-	 * due to instruction fetches or for no reason at all,
-	 * and neither LOCK nor MFENCE orders them.
-	 * Fortunately, load_cr3() is serializing and gives the
-	 * ordering guarantee we need.
-	 */
-	load_cr3(next->pgd);
+		VM_BUG_ON(this_cpu_read(cpu_tlbstate.ctxs[0].ctx_id) ==
+			  next->context.ctx_id);
 
-	/*
-	 * This gets called via leave_mm() in the idle path where RCU
-	 * functions differently.  Tracing normally uses RCU, so we have to
-	 * call the tracepoint specially here.
-	 */
-	trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
+		this_cpu_write(cpu_tlbstate.ctxs[0].ctx_id,
+			       next->context.ctx_id);
+		this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen,
+			       next_tlb_gen);
+		this_cpu_write(cpu_tlbstate.loaded_mm, next);
+		write_cr3(__pa(next->pgd));
 
-	/* Stop flush ipis for the previous mm */
-	WARN_ON_ONCE(!cpumask_test_cpu(cpu, mm_cpumask(real_prev)) &&
-		     real_prev != &init_mm);
-	cpumask_clear_cpu(cpu, mm_cpumask(real_prev));
+		/*
+		 * This gets called via leave_mm() in the idle path where RCU
+		 * functions differently.  Tracing normally uses RCU, so we
+		 * have to call the tracepoint specially here.
+		 */
+		trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH,
+					TLB_FLUSH_ALL);
+	}
 
-	/* Load per-mm CR4 and LDTR state */
 	load_mm_cr4(next);
 	switch_ldt(real_prev, next);
 }
 
-/*
- * The flush IPI assumes that a thread switch happens in this order:
- * [cpu0: the cpu that switches]
- * 1) switch_mm() either 1a) or 1b)
- * 1a) thread switch to a different mm
- * 1a1) set cpu_tlbstate to TLBSTATE_OK
- *	Now the tlb flush NMI handler flush_tlb_func won't call leave_mm
- *	if cpu0 was in lazy tlb mode.
- * 1a2) update cpu active_mm
- *	Now cpu0 accepts tlb flushes for the new mm.
- * 1a3) cpu_set(cpu, new_mm->cpu_vm_mask);
- *	Now the other cpus will send tlb flush ipis.
- * 1a4) change cr3.
- * 1a5) cpu_clear(cpu, old_mm->cpu_vm_mask);
- *	Stop ipi delivery for the old mm. This is not synchronized with
- *	the other cpus, but flush_tlb_func ignore flush ipis for the wrong
- *	mm, and in the worst case we perform a superfluous tlb flush.
- * 1b) thread switch without mm change
- *	cpu active_mm is correct, cpu0 already handles flush ipis.
- * 1b1) set cpu_tlbstate to TLBSTATE_OK
- * 1b2) test_and_set the cpu bit in cpu_vm_mask.
- *	Atomically set the bit [other cpus will start sending flush ipis],
- *	and test the bit.
- * 1b3) if the bit was 0: leave_mm was called, flush the tlb.
- * 2) switch %%esp, ie current
- *
- * The interrupt must handle 2 special cases:
- * - cr3 is changed before %%esp, ie. it cannot use current->{active_,}mm.
- * - the cpu performs speculative tlb reads, i.e. even if the cpu only
- *   runs in kernel space, the cpu could load tlb entries for user space
- *   pages.
- *
- * The good news is that cpu_tlbstate is local to each cpu, no
- * write/read ordering problems.
- */
-
 static void flush_tlb_func_common(const struct flush_tlb_info *f,
 				  bool local, enum tlb_flush_reason reason)
 {
@@ -209,15 +194,19 @@ static void flush_tlb_func_common(const struct flush_tlb_info *f,
 	u64 mm_tlb_gen = atomic64_read(&loaded_mm->context.tlb_gen);
 	u64 local_tlb_gen = this_cpu_read(cpu_tlbstate.ctxs[0].tlb_gen);
 
+	/* This code cannot presently handle being reentered. */
+	VM_WARN_ON(!irqs_disabled());
+
 	VM_WARN_ON(this_cpu_read(cpu_tlbstate.ctxs[0].ctx_id) !=
 		   loaded_mm->context.ctx_id);
 
-	if (this_cpu_read(cpu_tlbstate.state) != TLBSTATE_OK) {
+	if (!cpumask_test_cpu(smp_processor_id(), mm_cpumask(loaded_mm))) {
 		/*
-		 * leave_mm() is adequate to handle any type of flush, and
-		 * we would prefer not to receive further IPIs.
+		 * We're in lazy mode -- don't flush.  We can get here on
+		 * remote flushes due to races and on local flushes if a
+		 * kernel thread coincidentally flushes the mm it's lazily
+		 * still using.
 		 */
-		leave_mm(smp_processor_id());
 		return;
 	}
 
@@ -314,6 +303,21 @@ void native_flush_tlb_others(const struct cpumask *cpumask,
 				(info->end - info->start) >> PAGE_SHIFT);
 
 	if (is_uv_system()) {
+		/*
+		 * This whole special case is confused.  UV has a "Broadcast
+		 * Assist Unit", which seems to be a fancy way to send IPIs.
+		 * Back when x86 used an explicit TLB flush IPI, UV was
+		 * optimized to use its own mechanism.  These days, x86 uses
+		 * smp_call_function_many(), but UV still uses a manual IPI,
+		 * and that IPI's action is out of date -- it does a manual
+		 * flush instead of calling flush_tlb_func_remote().  This
+		 * means that the percpu tlb_gen variables won't be updated
+		 * and we'll do pointless flushes on future context switches.
+		 *
+		 * Rather than hooking native_flush_tlb_others() here, I think
+		 * that UV should be updated so that smp_call_function_many(),
+		 * etc, are optimal on UV.
+		 */
 		unsigned int cpu;
 
 		cpu = smp_processor_id();
@@ -364,10 +368,15 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 		info.end = TLB_FLUSH_ALL;
 	}
 
-	if (mm == this_cpu_read(cpu_tlbstate.loaded_mm))
+	if (mm == this_cpu_read(cpu_tlbstate.loaded_mm)) {
+		local_irq_disable();
 		flush_tlb_func_local(&info, TLB_LOCAL_MM_SHOOTDOWN);
+		local_irq_enable();
+	}
+
 	if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), &info);
+
 	put_cpu();
 }
 
@@ -376,8 +385,6 @@ static void do_flush_tlb_all(void *info)
 {
 	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
 	__flush_tlb_all();
-	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_LAZY)
-		leave_mm(smp_processor_id());
 }
 
 void flush_tlb_all(void)
@@ -421,10 +428,15 @@ void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch)
 
 	int cpu = get_cpu();
 
-	if (cpumask_test_cpu(cpu, &batch->cpumask))
+	if (cpumask_test_cpu(cpu, &batch->cpumask)) {
+		local_irq_disable();
 		flush_tlb_func_local(&info, TLB_LOCAL_SHOOTDOWN);
+		local_irq_enable();
+	}
+
 	if (cpumask_any_but(&batch->cpumask, cpu) < nr_cpu_ids)
 		flush_tlb_others(&batch->cpumask, &info);
+
 	cpumask_clear(&batch->cpumask);
 
 	put_cpu();
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
