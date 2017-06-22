Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 12F606B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 08:22:07 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z81so4081596wrc.2
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 05:22:07 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id g89si1357285wrd.274.2017.06.22.05.22.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 22 Jun 2017 05:22:05 -0700 (PDT)
Date: Thu, 22 Jun 2017 14:21:49 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 11/11] x86/mm: Try to preserve old TLB entries using
 PCID
In-Reply-To: <CALCETrUrwyMt+k4a-Tyh85Xiidr3zgEW7LKLnGDz90Z6jL9XtA@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1706221037320.1885@nanos>
References: <cover.1498022414.git.luto@kernel.org> <a8cdfbbb17785aed10980d24692745f68615a584.1498022414.git.luto@kernel.org> <alpine.DEB.2.20.1706211159430.2328@nanos> <CALCETrUrwyMt+k4a-Tyh85Xiidr3zgEW7LKLnGDz90Z6jL9XtA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, 21 Jun 2017, Andy Lutomirski wrote:
> On Wed, Jun 21, 2017 at 6:38 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > That requires a conditional branch
> >
> >         if (asid >= NR_DYNAMIC_ASIDS) {
> >                 asid = 0;
> >                 ....
> >         }
> >
> > The question is whether 4 IDs would be sufficient which trades the branch
> > for a mask operation. Or you go for 8 and spend another cache line.
> 
> Interesting.  I'm inclined to either leave it at 6 or reduce it to 4
> for now and to optimize later.

:)

> > Hmm. So this loop needs to be taken unconditionally even if the task stays
> > on the same CPU. And of course the number of dynamic IDs has to be short in
> > order to makes this loop suck performance wise.
> >
> > Something like the completely disfunctional below might be worthwhile to
> > explore. At least arch/x86/mm/ compiles :)
> >
> > It gets rid of the loop search and lifts the limit of dynamic ids by
> > trading it with a percpu variable in mm_context_t.
> 
> That would work, but it would take a lot more memory on large systems
> with lots of processes, and I'd also be concerned that we might run
> out of dynamic percpu space.

Yeah, did not think about the dynamic percpu space.
 
> How about a different idea: make the percpu data structure look like a
> 4-way set associative cache.  The ctxs array could be, say, 1024
> entries long without using crazy amounts of memory.  We'd divide it
> into 256 buckets, so you'd index it like ctxs[4*bucket + slot].  For
> each mm, we choose a random bucket (from 0 through 256), and then we'd
> just loop over the four slots in the bucket in choose_asid().  This
> would require very slightly more arithmetic (I'd guess only one or two
> cycles, though) but, critically, wouldn't touch any more cachelines.
> 
> The downside of both of these approaches over the one in this patch is
> that the change that the percpu cacheline we need is not in the cache
> is quite a bit higher since it's potentially a different cacheline for
> each mm.  It would probably still be a win because avoiding the flush
> is really quite valuable.
> 
> What do you think?  The added code would be tiny.

That might be worth a try.

Now one other optimization which should be trivial to add is to keep the 4
asid context entries in cpu_tlbstate and cache the last asid in thread
info. If that's still valid then use it otherwise unconditionally get a new
one. That avoids the whole loop machinery and thread info is cache hot in
the context switch anyway. Delta patch on top of your version below.

> (P.S. Why doesn't random_p32() try arch_random_int()?)

Could you please ask questions which do not require crystalballs for
answering?

Thanks,

	tglx

8<-------------------
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -159,8 +159,16 @@ static inline void destroy_context(struc
 extern void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 		      struct task_struct *tsk);
 
-extern void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
-			       struct task_struct *tsk);
+extern void __switch_mm_irqs_off(struct mm_struct *prev,
+				 struct mm_struct *next, u32 *last_asid);
+
+static inline void switch_mm_irqs_off(struct mm_struct *prev,
+				      struct mm_struct *next,
+				      struct task_struct *tsk)
+{
+	__switch_mm_irqs_off(prev, next, &tsk->thread_info.asid);
+}
+
 #define switch_mm_irqs_off switch_mm_irqs_off
 
 #define activate_mm(prev, next)			\
--- a/arch/x86/include/asm/thread_info.h
+++ b/arch/x86/include/asm/thread_info.h
@@ -54,6 +54,7 @@ struct task_struct;
 
 struct thread_info {
 	unsigned long		flags;		/* low level flags */
+	u32			asid;
 };
 
 #define INIT_THREAD_INFO(tsk)			\
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -83,10 +83,13 @@ static inline u64 bump_mm_tlb_gen(struct
 #endif
 
 /*
- * 6 because 6 should be plenty and struct tlb_state will fit in
- * two cache lines.
+ * NR_DYNAMIC_ASIDS must be a power of 2. 4 makes tlb_state fit into two
+ * cache lines.
  */
-#define NR_DYNAMIC_ASIDS 6
+#define NR_DYNAMIC_ASIDS_BITS	2
+#define NR_DYNAMIC_ASIDS	(1U << NR_DYNAMIC_ASIDS_BITS)
+#define DYNAMIC_ASIDS_MASK	(NR_DYNAMIC_ASIDS - 1)
+#define ASID_NEEDS_FLUSH	(1U << 16)
 
 struct tlb_context {
 	u64 ctx_id;
@@ -102,7 +105,8 @@ struct tlb_state {
 	 */
 	struct mm_struct *loaded_mm;
 	u16 loaded_mm_asid;
-	u16 next_asid;
+	u16 curr_asid;
+	u32 notask_asid;
 
 	/*
 	 * Access to this CR4 shadow and to H/W CR4 is protected by
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -812,7 +812,7 @@ void __init zone_sizes_init(void)
 
 DEFINE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate) = {
 	.loaded_mm = &init_mm,
-	.next_asid = 1,
+	.curr_asid = 0,
 	.cr4 = ~0UL,	/* fail hard if we screw up cr4 shadow initialization */
 };
 EXPORT_SYMBOL_GPL(cpu_tlbstate);
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -30,43 +30,32 @@
 
 atomic64_t last_mm_ctx_id = ATOMIC64_INIT(1);
 
-static void choose_new_asid(struct mm_struct *next, u64 next_tlb_gen,
-			    u16 *new_asid, bool *need_flush)
+static u32 choose_new_asid(mm_context_t *nctx, u32 *last_asid, u64 next_tlb_gen)
 {
-	u16 asid;
+	struct tlb_context *tctx;
+	u32 asid;
 
-	if (!static_cpu_has(X86_FEATURE_PCID)) {
-		*new_asid = 0;
-		*need_flush = true;
-		return;
-	}
+	if (!static_cpu_has(X86_FEATURE_PCID))
+		return ASID_NEEDS_FLUSH;
 
-	for (asid = 0; asid < NR_DYNAMIC_ASIDS; asid++) {
-		if (this_cpu_read(cpu_tlbstate.ctxs[asid].ctx_id) !=
-		    next->context.ctx_id)
-			continue;
-
-		*new_asid = asid;
-		*need_flush = (this_cpu_read(cpu_tlbstate.ctxs[asid].tlb_gen) <
-			       next_tlb_gen);
-		return;
+	asid = *last_asid;
+	tctx = this_cpu_ptr(cpu_tlbstate.ctxs + asid);
+	if (likely(tctx->ctx_id == nctx->ctx_id)) {
+		if (tctx->tlb_gen != next_tlb_gen)
+			asid |= ASID_NEEDS_FLUSH;
+		return asid;
 	}
 
-	/*
-	 * We don't currently own an ASID slot on this CPU.
-	 * Allocate a slot.
-	 */
-	*new_asid = this_cpu_add_return(cpu_tlbstate.next_asid, 1) - 1;
-	if (*new_asid >= NR_DYNAMIC_ASIDS) {
-		*new_asid = 0;
-		this_cpu_write(cpu_tlbstate.next_asid, 1);
-	}
-	*need_flush = true;
+	asid = this_cpu_inc_return(cpu_tlbstate.curr_asid);
+	asid &= DYNAMIC_ASIDS_MASK;
+	*last_asid = asid;
+	return asid | ASID_NEEDS_FLUSH;
 }
 
 void leave_mm(int cpu)
 {
 	struct mm_struct *loaded_mm = this_cpu_read(cpu_tlbstate.loaded_mm);
+	unsigned long flags;
 
 	/*
 	 * It's plausible that we're in lazy TLB mode while our mm is init_mm.
@@ -82,21 +71,27 @@ void leave_mm(int cpu)
 	/* Warn if we're not lazy. */
 	WARN_ON(cpumask_test_cpu(smp_processor_id(), mm_cpumask(loaded_mm)));
 
-	switch_mm(NULL, &init_mm, NULL);
+	local_irq_save(flags);
+	switch_mm_irqs_off(NULL, &init_mm, NULL);
+	local_irq_restore(flags);
 }
 
 void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 	       struct task_struct *tsk)
 {
 	unsigned long flags;
+	u32 *last_asid;
+
+	last_asid = tsk ? &tsk->thread_info.asid :
+			this_cpu_ptr(&cpu_tlbstate.notask_asid);
 
 	local_irq_save(flags);
-	switch_mm_irqs_off(prev, next, tsk);
+	__switch_mm_irqs_off(prev, next, last_asid);
 	local_irq_restore(flags);
 }
 
-void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
-			struct task_struct *tsk)
+void __switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
+			u32 *last_asid)
 {
 	unsigned cpu = smp_processor_id();
 	struct mm_struct *real_prev = this_cpu_read(cpu_tlbstate.loaded_mm);
@@ -157,8 +152,7 @@ void switch_mm_irqs_off(struct mm_struct
 		 * are not reflected in tlb_gen.)
 		 */
 	} else {
-		u16 new_asid;
-		bool need_flush;
+		u32 new_asid;
 
 		if (IS_ENABLED(CONFIG_VMAP_STACK)) {
 			/*
@@ -187,9 +181,11 @@ void switch_mm_irqs_off(struct mm_struct
 		cpumask_set_cpu(cpu, mm_cpumask(next));
 		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
 
-		choose_new_asid(next, next_tlb_gen, &new_asid, &need_flush);
+		new_asid = choose_new_asid(&next->context, last_asid,
+					   next_tlb_gen);
 
-		if (need_flush) {
+		if (new_asid & ASID_NEEDS_FLUSH) {
+			new_asid &= DYNAMIC_ASIDS_MASK;
 			this_cpu_write(cpu_tlbstate.ctxs[new_asid].ctx_id,
 				       next->context.ctx_id);
 			this_cpu_write(cpu_tlbstate.ctxs[new_asid].tlb_gen,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
