Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 32BCD6B03F4
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 09:38:23 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id r103so20540974wrb.0
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 06:38:23 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id k7si1169203wrd.230.2017.06.21.06.38.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 06:38:21 -0700 (PDT)
Date: Wed, 21 Jun 2017 15:38:06 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 11/11] x86/mm: Try to preserve old TLB entries using
 PCID
In-Reply-To: <a8cdfbbb17785aed10980d24692745f68615a584.1498022414.git.luto@kernel.org>
Message-ID: <alpine.DEB.2.20.1706211159430.2328@nanos>
References: <cover.1498022414.git.luto@kernel.org> <a8cdfbbb17785aed10980d24692745f68615a584.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, 20 Jun 2017, Andy Lutomirski wrote:
> This patch uses PCID differently.  We use a PCID to identify a
> recently-used mm on a per-cpu basis.  An mm has no fixed PCID
> binding at all; instead, we give it a fresh PCID each time it's
> loaded except in cases where we want to preserve the TLB, in which
> case we reuse a recent value.
> 
> This seems to save about 100ns on context switches between mms.

Depending on the work load I assume. For a CPU switching between a large
number of processes consecutively it won't make a change. In fact it will
be slower due to the extra few cycles required for rotating the asid, but I
doubt that this can be measured.
 
> +/*
> + * 6 because 6 should be plenty and struct tlb_state will fit in
> + * two cache lines.
> + */
> +#define NR_DYNAMIC_ASIDS 6

That requires a conditional branch 

	if (asid >= NR_DYNAMIC_ASIDS) {
		asid = 0;
		....
	}

The question is whether 4 IDs would be sufficient which trades the branch
for a mask operation. Or you go for 8 and spend another cache line.

>  atomic64_t last_mm_ctx_id = ATOMIC64_INIT(1);
>  
> +static void choose_new_asid(struct mm_struct *next, u64 next_tlb_gen,
> +			    u16 *new_asid, bool *need_flush)
> +{
> +	u16 asid;
> +
> +	if (!static_cpu_has(X86_FEATURE_PCID)) {
> +		*new_asid = 0;
> +		*need_flush = true;
> +		return;
> +	}
> +
> +	for (asid = 0; asid < NR_DYNAMIC_ASIDS; asid++) {
> +		if (this_cpu_read(cpu_tlbstate.ctxs[asid].ctx_id) !=
> +		    next->context.ctx_id)
> +			continue;
> +
> +		*new_asid = asid;
> +		*need_flush = (this_cpu_read(cpu_tlbstate.ctxs[asid].tlb_gen) <
> +			       next_tlb_gen);
> +		return;
> +	}

Hmm. So this loop needs to be taken unconditionally even if the task stays
on the same CPU. And of course the number of dynamic IDs has to be short in
order to makes this loop suck performance wise.

Something like the completely disfunctional below might be worthwhile to
explore. At least arch/x86/mm/ compiles :)

It gets rid of the loop search and lifts the limit of dynamic ids by
trading it with a percpu variable in mm_context_t.

Thanks,

	tglx

8<--------------------

--- a/arch/x86/include/asm/mmu.h
+++ b/arch/x86/include/asm/mmu.h
@@ -25,6 +25,8 @@ typedef struct {
 	 */
 	atomic64_t tlb_gen;
 
+	u32 __percpu	*asids;
+
 #ifdef CONFIG_MODIFY_LDT_SYSCALL
 	struct ldt_struct *ldt;
 #endif
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -156,11 +156,23 @@ static inline void destroy_context(struc
 	destroy_context_ldt(mm);
 }
 
-extern void switch_mm(struct mm_struct *prev, struct mm_struct *next,
-		      struct task_struct *tsk);
+extern void __switch_mm(struct mm_struct *prev, struct mm_struct *next);
+
+static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
+			     struct task_struct *tsk)
+{
+	__switch_mm(prev, next);
+}
+
+extern void __switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next);
+
+static inline void switch_mm_irqs_off(struct mm_struct *prev,
+				      struct mm_struct *next,
+				      struct task_struct *tsk)
+{
+	__switch_mm_irqs_off(prev, next);
+}
 
-extern void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
-			       struct task_struct *tsk);
 #define switch_mm_irqs_off switch_mm_irqs_off
 
 #define activate_mm(prev, next)			\
@@ -299,6 +311,9 @@ static inline unsigned long __get_curren
 {
 	unsigned long cr3 = __pa(this_cpu_read(cpu_tlbstate.loaded_mm)->pgd);
 
+	if (static_cpu_has(X86_FEATURE_PCID))
+		cr3 |= this_cpu_read(cpu_tlbstate.loaded_mm_asid);
+
 	/* For now, be very restrictive about when this can be called. */
 	VM_WARN_ON(in_nmi() || !in_atomic());
 
--- a/arch/x86/include/asm/processor-flags.h
+++ b/arch/x86/include/asm/processor-flags.h
@@ -35,6 +35,7 @@
 /* Mask off the address space ID bits. */
 #define CR3_ADDR_MASK 0x7FFFFFFFFFFFF000ull
 #define CR3_PCID_MASK 0xFFFull
+#define CR3_NOFLUSH (1UL << 63)
 #else
 /*
  * CR3_ADDR_MASK needs at least bits 31:5 set on PAE systems, and we save
@@ -42,6 +43,7 @@
  */
 #define CR3_ADDR_MASK 0xFFFFFFFFull
 #define CR3_PCID_MASK 0ull
+#define CR3_NOFLUSH 0
 #endif
 
 #endif /* _ASM_X86_PROCESSOR_FLAGS_H */
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -82,6 +82,15 @@ static inline u64 bump_mm_tlb_gen(struct
 #define __flush_tlb_single(addr) __native_flush_tlb_single(addr)
 #endif
 
+/*
+ * NR_DYNAMIC_ASIDS must be a power of 2. 4 makes tlb_state fit into two
+ * cache lines.
+ */
+#define NR_DYNAMIC_ASIDS_BITS	2
+#define NR_DYNAMIC_ASIDS	(1U << NR_DYNAMIC_ASIDS_BITS)
+#define DYNAMIC_ASIDS_MASK	(NR_DYNAMIC_ASIDS - 1)
+#define ASID_NEEDS_FLUSH	(1U << 16)
+
 struct tlb_context {
 	u64 ctx_id;
 	u64 tlb_gen;
@@ -95,6 +104,8 @@ struct tlb_state {
 	 * mode even if we've already switched back to swapper_pg_dir.
 	 */
 	struct mm_struct *loaded_mm;
+	u16 loaded_mm_asid;
+	u16 next_asid;
 
 	/*
 	 * Access to this CR4 shadow and to H/W CR4 is protected by
@@ -104,7 +115,8 @@ struct tlb_state {
 
 	/*
 	 * This is a list of all contexts that might exist in the TLB.
-	 * Since we don't yet use PCID, there is only one context.
+	 * There is one per ASID that we use, and the ASID (what the
+	 * CPU calls PCID) is the index into ctxts.
 	 *
 	 * For each context, ctx_id indicates which mm the TLB's user
 	 * entries came from.  As an invariant, the TLB will never
@@ -114,8 +126,13 @@ struct tlb_state {
 	 * To be clear, this means that it's legal for the TLB code to
 	 * flush the TLB without updating tlb_gen.  This can happen
 	 * (for now, at least) due to paravirt remote flushes.
+	 *
+	 * NB: context 0 is a bit special, since it's also used by
+	 * various bits of init code.  This is fine -- code that
+	 * isn't aware of PCID will end up harmlessly flushing
+	 * context 0.
 	 */
-	struct tlb_context ctxs[1];
+	struct tlb_context ctxs[NR_DYNAMIC_ASIDS];
 };
 DECLARE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate);
 
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -812,6 +812,7 @@ void __init zone_sizes_init(void)
 
 DEFINE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate) = {
 	.loaded_mm = &init_mm,
+	.next_asid = 1,
 	.cr4 = ~0UL,	/* fail hard if we screw up cr4 shadow initialization */
 };
 EXPORT_SYMBOL_GPL(cpu_tlbstate);
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -30,6 +30,30 @@
 
 atomic64_t last_mm_ctx_id = ATOMIC64_INIT(1);
 
+static u32 choose_new_asid(mm_context_t *mmctx, u64 next_tlb_gen)
+{
+	u64 next_ctx_id = mmctx->ctx_id;
+	struct tlb_context *ctx;
+	u32 asid;
+
+	if (!static_cpu_has(X86_FEATURE_PCID))
+		return ASID_NEEDS_FLUSH;
+
+	asid = this_cpu_read(*mmctx->asids);
+	ctx = this_cpu_ptr(cpu_tlbstate.ctxs + asid);
+	if (likely(ctx->ctx_id == next_ctx_id)) {
+		return ctx->tlb_gen == next_tlb_gen ?
+			asid : asid | ASID_NEEDS_FLUSH ;
+	}
+
+	/* Slot got reused. Get a new one */
+	asid = this_cpu_inc_return(cpu_tlbstate.next_asid) - 1;
+	asid &= DYNAMIC_ASIDS_MASK;
+	this_cpu_write(*mmctx->asids, asid);
+	ctx = this_cpu_ptr(cpu_tlbstate.ctxs + asid);
+	return asid | ASID_NEEDS_FLUSH;
+}
+
 void leave_mm(int cpu)
 {
 	struct mm_struct *loaded_mm = this_cpu_read(cpu_tlbstate.loaded_mm);
@@ -48,24 +72,23 @@ void leave_mm(int cpu)
 	/* Warn if we're not lazy. */
 	WARN_ON(cpumask_test_cpu(smp_processor_id(), mm_cpumask(loaded_mm)));
 
-	switch_mm(NULL, &init_mm, NULL);
+	__switch_mm(NULL, &init_mm);
 }
 
-void switch_mm(struct mm_struct *prev, struct mm_struct *next,
-	       struct task_struct *tsk)
+void __switch_mm(struct mm_struct *prev, struct mm_struct *next)
 {
 	unsigned long flags;
 
 	local_irq_save(flags);
-	switch_mm_irqs_off(prev, next, tsk);
+	__switch_mm_irqs_off(prev, next);
 	local_irq_restore(flags);
 }
 
-void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
-			struct task_struct *tsk)
+void __switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next)
 {
 	unsigned cpu = smp_processor_id();
 	struct mm_struct *real_prev = this_cpu_read(cpu_tlbstate.loaded_mm);
+	u16 prev_asid = this_cpu_read(cpu_tlbstate.loaded_mm_asid);
 	u64 next_tlb_gen;
 
 	/*
@@ -81,7 +104,7 @@ void switch_mm_irqs_off(struct mm_struct
 	if (IS_ENABLED(CONFIG_PROVE_LOCKING))
 		WARN_ON_ONCE(!irqs_disabled());
 
-	VM_BUG_ON(read_cr3_pa() != __pa(real_prev->pgd));
+	VM_BUG_ON(__read_cr3() != (__pa(real_prev->pgd) | prev_asid));
 
 	if (real_prev == next) {
 		if (cpumask_test_cpu(cpu, mm_cpumask(next))) {
@@ -98,10 +121,10 @@ void switch_mm_irqs_off(struct mm_struct
 		cpumask_set_cpu(cpu, mm_cpumask(next));
 		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
 
-		VM_BUG_ON(this_cpu_read(cpu_tlbstate.ctxs[0].ctx_id) !=
+		VM_BUG_ON(this_cpu_read(cpu_tlbstate.ctxs[prev_asid].ctx_id) !=
 			  next->context.ctx_id);
 
-		if (this_cpu_read(cpu_tlbstate.ctxs[0].tlb_gen) <
+		if (this_cpu_read(cpu_tlbstate.ctxs[prev_asid].tlb_gen) <
 		    next_tlb_gen) {
 			/*
 			 * Ideally, we'd have a flush_tlb() variant that
@@ -109,9 +132,9 @@ void switch_mm_irqs_off(struct mm_struct
 			 * be faster on Xen PV and on hypothetical CPUs
 			 * on which INVPCID is fast.
 			 */
-			this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen,
+			this_cpu_write(cpu_tlbstate.ctxs[prev_asid].tlb_gen,
 				       next_tlb_gen);
-			write_cr3(__pa(next->pgd));
+			write_cr3(__pa(next->pgd) | prev_asid);
 			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH,
 					TLB_FLUSH_ALL);
 		}
@@ -122,6 +145,8 @@ void switch_mm_irqs_off(struct mm_struct
 		 * are not reflected in tlb_gen.)
 		 */
 	} else {
+		u32 new_asid;
+
 		if (IS_ENABLED(CONFIG_VMAP_STACK)) {
 			/*
 			 * If our current stack is in vmalloc space and isn't
@@ -141,7 +166,7 @@ void switch_mm_irqs_off(struct mm_struct
 		if (cpumask_test_cpu(cpu, mm_cpumask(real_prev)))
 			cpumask_clear_cpu(cpu, mm_cpumask(real_prev));
 
-		WARN_ON_ONCE(cpumask_test_cpu(cpu, mm_cpumask(next)));
+		VM_WARN_ON_ONCE(cpumask_test_cpu(cpu, mm_cpumask(next)));
 
 		/*
 		 * Start remote flushes and then read tlb_gen.
@@ -149,17 +174,25 @@ void switch_mm_irqs_off(struct mm_struct
 		cpumask_set_cpu(cpu, mm_cpumask(next));
 		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
 
-		VM_BUG_ON(this_cpu_read(cpu_tlbstate.ctxs[0].ctx_id) ==
-			  next->context.ctx_id);
+		new_asid = choose_new_asid(&next->context, next_tlb_gen);
 
-		this_cpu_write(cpu_tlbstate.ctxs[0].ctx_id,
-			       next->context.ctx_id);
-		this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen,
-			       next_tlb_gen);
-		this_cpu_write(cpu_tlbstate.loaded_mm, next);
-		write_cr3(__pa(next->pgd));
+		if (new_asid & ASID_NEEDS_FLUSH) {
+			new_asid &= DYNAMIC_ASIDS_MASK;
+			this_cpu_write(cpu_tlbstate.ctxs[new_asid].ctx_id,
+				       next->context.ctx_id);
+			this_cpu_write(cpu_tlbstate.ctxs[new_asid].tlb_gen,
+				       next_tlb_gen);
+			write_cr3(__pa(next->pgd) | new_asid);
+			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH,
+					TLB_FLUSH_ALL);
+		} else {
+			/* The new ASID is already up to date. */
+			write_cr3(__pa(next->pgd) | new_asid | CR3_NOFLUSH);
+			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, 0);
+		}
 
-		trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
+		this_cpu_write(cpu_tlbstate.loaded_mm, next);
+		this_cpu_write(cpu_tlbstate.loaded_mm_asid, new_asid);
 	}
 
 	load_mm_cr4(next);
@@ -170,6 +203,7 @@ static void flush_tlb_func_common(const
 				  bool local, enum tlb_flush_reason reason)
 {
 	struct mm_struct *loaded_mm = this_cpu_read(cpu_tlbstate.loaded_mm);
+	u32 loaded_mm_asid = this_cpu_read(cpu_tlbstate.loaded_mm_asid);
 
 	/*
 	 * Our memory ordering requirement is that any TLB fills that
@@ -179,12 +213,12 @@ static void flush_tlb_func_common(const
 	 * atomic64_read operation won't be reordered by the compiler.
 	 */
 	u64 mm_tlb_gen = atomic64_read(&loaded_mm->context.tlb_gen);
-	u64 local_tlb_gen = this_cpu_read(cpu_tlbstate.ctxs[0].tlb_gen);
+	u64 local_tlb_gen = this_cpu_read(cpu_tlbstate.ctxs[loaded_mm_asid].tlb_gen);
 
 	/* This code cannot presently handle being reentered. */
 	VM_WARN_ON(!irqs_disabled());
 
-	VM_WARN_ON(this_cpu_read(cpu_tlbstate.ctxs[0].ctx_id) !=
+	VM_WARN_ON(this_cpu_read(cpu_tlbstate.ctxs[loaded_mm_asid].ctx_id) !=
 		   loaded_mm->context.ctx_id);
 
 	if (!cpumask_test_cpu(smp_processor_id(), mm_cpumask(loaded_mm))) {
@@ -256,7 +290,7 @@ static void flush_tlb_func_common(const
 	}
 
 	/* Both paths above update our state to mm_tlb_gen. */
-	this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen, mm_tlb_gen);
+	this_cpu_write(cpu_tlbstate.ctxs[loaded_mm_asid].tlb_gen, mm_tlb_gen);
 }
 
 static void flush_tlb_func_local(void *info, enum tlb_flush_reason reason)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
