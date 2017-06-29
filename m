Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7B2426B0350
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 11:53:35 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id q184so22052250oih.5
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 08:53:35 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h72si3606678oic.337.2017.06.29.08.53.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 08:53:34 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v4 05/10] x86/mm: Rework lazy TLB mode and TLB freshness tracking
Date: Thu, 29 Jun 2017 08:53:17 -0700
Message-Id: <ddf2c92962339f4ba39d8fc41b853936ec0b44f1.1498751203.git.luto@kernel.org>
In-Reply-To: <cover.1498751203.git.luto@kernel.org>
References: <cover.1498751203.git.luto@kernel.org>
In-Reply-To: <cover.1498751203.git.luto@kernel.org>
References: <cover.1498751203.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

x86's lazy TLB mode used to be fairly weak -- it would switch to
init_mm the first time it tried to flush a lazy TLB.  This meant an
unnecessary CR3 write and, if the flush was remote, an unnecessary
IPI.

Rewrite it entirely.  When we enter lazy mode, we simply remove the
CPU from mm_cpumask.  This means that we need a way to figure out
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

Here are some benchmark results, done on a Skylake laptop at 2.3 GHz
(turbo off, intel_pstate requesting max performance) under KVM with
the guest using idle=poll (to avoid artifacts when bouncing between
CPUs).  I haven't done any real statistics here -- I just ran them
in a loop and picked the fastest results that didn't look like
outliers.  Unpatched means commit a4eb8b993554, so all the
bookkeeping overhead is gone.

MADV_DONTNEED; touch the page; switch CPUs using sched_setaffinity.  In
an unpatched kernel, MADV_DONTNEED will send an IPI to the previous CPU.
This is intended to be a nearly worst-case test.
patched:         13.4Aus
unpatched:       21.6Aus

Vitaly's pthread_mmap microbenchmark with 8 threads (on four cores),
nrounds = 100, 256M data
patched:         1.1 seconds or so
unpatched:       1.9 seconds or so

The sleepup on Vitaly's test appearss to be because it spends a lot
of time blocked on mmap_sem, and this patch avoids sending IPIs to
blocked CPUs.

Reviewed-by: Nadav Amit <nadav.amit@gmail.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
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
 arch/x86/mm/tlb.c                  | 197 ++++++++++++++++++++++---------------
 arch/x86/xen/mmu_pv.c              |   5 +-
 5 files changed, 124 insertions(+), 89 deletions(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index ae19b9d11259..85f6b5575aad 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -128,8 +128,10 @@ static inline void switch_ldt(struct mm_struct *prev, struct mm_struct *next)
 
 static inline void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk)
 {
-	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK)
-		this_cpu_write(cpu_tlbstate.state, TLBSTATE_LAZY);
+	int cpu = smp_processor_id();
+
+	if (cpumask_test_cpu(cpu, mm_cpumask(mm)))
+		cpumask_clear_cpu(cpu, mm_cpumask(mm));
 }
 
 static inline int init_new_context(struct task_struct *tsk,
diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index d7df54cc7e4d..06e997a36d49 100644
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
index 673541eb3b3f..4d353efb2838 100644
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
index 4e5a5ddb9e4d..0982c997d36f 100644
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
@@ -65,94 +65,117 @@ void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 			struct task_struct *tsk)
 {
-	unsigned cpu = smp_processor_id();
 	struct mm_struct *real_prev = this_cpu_read(cpu_tlbstate.loaded_mm);
+	unsigned cpu = smp_processor_id();
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
+	/*
+	 * Verify that CR3 is what we think it is.  This will catch
+	 * hypothetical buggy code that directly switches to swapper_pg_dir
+	 * without going through leave_mm() / switch_mm_irqs_off().
+	 */
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
+		VM_BUG_ON(this_cpu_read(cpu_tlbstate.ctxs[0].ctx_id) !=
+			  next->context.ctx_id);
+
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
+		if (this_cpu_read(cpu_tlbstate.ctxs[0].tlb_gen) < next_tlb_gen) {
+			/*
+			 * Ideally, we'd have a flush_tlb() variant that
+			 * takes the known CR3 value as input.  This would
+			 * be faster on Xen PV and on hypothetical CPUs
+			 * on which INVPCID is fast.
+			 */
+			this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen,
+				       next_tlb_gen);
+			write_cr3(__pa(next->pgd));
+
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
-
-		if (unlikely(pgd_none(*pgd)))
-			set_pgd(pgd, init_mm.pgd[stack_pgd_index]);
-	}
+	} else {
+		VM_BUG_ON(this_cpu_read(cpu_tlbstate.ctxs[0].ctx_id) ==
+			  next->context.ctx_id);
+
+		if (IS_ENABLED(CONFIG_VMAP_STACK)) {
+			/*
+			 * If our current stack is in vmalloc space and isn't
+			 * mapped in the new pgd, we'll double-fault.  Forcibly
+			 * map it.
+			 */
+			unsigned int index = pgd_index(current_stack_pointer());
+			pgd_t *pgd = next->pgd + index;
+
+			if (unlikely(pgd_none(*pgd)))
+				set_pgd(pgd, init_mm.pgd[index]);
+		}
 
-	this_cpu_write(cpu_tlbstate.loaded_mm, next);
-	this_cpu_write(cpu_tlbstate.ctxs[0].ctx_id, next->context.ctx_id);
-	this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen, atomic64_read(&next->context.tlb_gen));
+		/* Stop remote flushes for the previous mm */
+		if (cpumask_test_cpu(cpu, mm_cpumask(real_prev)))
+			cpumask_clear_cpu(cpu, mm_cpumask(real_prev));
 
-	WARN_ON_ONCE(cpumask_test_cpu(cpu, mm_cpumask(next)));
-	cpumask_set_cpu(cpu, mm_cpumask(next));
+		VM_WARN_ON_ONCE(cpumask_test_cpu(cpu, mm_cpumask(next)));
 
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
+		/*
+		 * Start remote flushes and then read tlb_gen.
+		 */
+		cpumask_set_cpu(cpu, mm_cpumask(next));
+		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
 
-	/*
-	 * This gets called via leave_mm() in the idle path where RCU
-	 * functions differently.  Tracing normally uses RCU, so we have to
-	 * call the tracepoint specially here.
-	 */
-	trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
+		this_cpu_write(cpu_tlbstate.ctxs[0].ctx_id, next->context.ctx_id);
+		this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen, next_tlb_gen);
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
@@ -186,13 +209,13 @@ static void flush_tlb_func_common(const struct flush_tlb_info *f,
 	VM_WARN_ON(this_cpu_read(cpu_tlbstate.ctxs[0].ctx_id) !=
 		   loaded_mm->context.ctx_id);
 
-	if (this_cpu_read(cpu_tlbstate.state) != TLBSTATE_OK) {
+	if (!cpumask_test_cpu(smp_processor_id(), mm_cpumask(loaded_mm))) {
 		/*
-		 * leave_mm() is adequate to handle any type of flush, and
-		 * we would prefer not to receive further IPIs.  leave_mm()
-		 * clears this CPU's bit in mm_cpumask().
+		 * We're in lazy mode -- don't flush.  We can get here on
+		 * remote flushes due to races and on local flushes if a
+		 * kernel thread coincidentally flushes the mm it's lazily
+		 * still using.
 		 */
-		leave_mm(smp_processor_id());
 		return;
 	}
 
@@ -203,6 +226,7 @@ static void flush_tlb_func_common(const struct flush_tlb_info *f,
 		 * be handled can catch us all the way up, leaving no work for
 		 * the second flush.
 		 */
+		trace_tlb_flush(reason, 0);
 		return;
 	}
 
@@ -304,6 +328,21 @@ void native_flush_tlb_others(const struct cpumask *cpumask,
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
@@ -363,6 +402,7 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 
 	if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), &info);
+
 	put_cpu();
 }
 
@@ -371,8 +411,6 @@ static void do_flush_tlb_all(void *info)
 {
 	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
 	__flush_tlb_all();
-	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_LAZY)
-		leave_mm(smp_processor_id());
 }
 
 void flush_tlb_all(void)
@@ -425,6 +463,7 @@ void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch)
 
 	if (cpumask_any_but(&batch->cpumask, cpu) < nr_cpu_ids)
 		flush_tlb_others(&batch->cpumask, &info);
+
 	cpumask_clear(&batch->cpumask);
 
 	put_cpu();
diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
index 1d7a7213a310..0472790ec20b 100644
--- a/arch/x86/xen/mmu_pv.c
+++ b/arch/x86/xen/mmu_pv.c
@@ -1005,14 +1005,12 @@ static void xen_drop_mm_ref(struct mm_struct *mm)
 	/* Get the "official" set of cpus referring to our pagetable. */
 	if (!alloc_cpumask_var(&mask, GFP_ATOMIC)) {
 		for_each_online_cpu(cpu) {
-			if (!cpumask_test_cpu(cpu, mm_cpumask(mm))
-			    && per_cpu(xen_current_cr3, cpu) != __pa(mm->pgd))
+			if (per_cpu(xen_current_cr3, cpu) != __pa(mm->pgd))
 				continue;
 			smp_call_function_single(cpu, drop_mm_ref_this_cpu, mm, 1);
 		}
 		return;
 	}
-	cpumask_copy(mask, mm_cpumask(mm));
 
 	/*
 	 * It's possible that a vcpu may have a stale reference to our
@@ -1021,6 +1019,7 @@ static void xen_drop_mm_ref(struct mm_struct *mm)
 	 * look at its actual current cr3 value, and force it to flush
 	 * if needed.
 	 */
+	cpumask_clear(mask);
 	for_each_online_cpu(cpu) {
 		if (per_cpu(xen_current_cr3, cpu) == __pa(mm->pgd))
 			cpumask_set_cpu(cpu, mask);
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
