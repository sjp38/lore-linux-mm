Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id D82986B054F
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 09:49:49 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 77so200193065itj.4
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 06:49:49 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id l127si21244293iof.54.2017.07.28.06.49.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 06:49:48 -0700 (PDT)
Date: Fri, 28 Jul 2017 15:49:31 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v4 10/10] x86/mm: Try to preserve old TLB entries using
 PCID
Message-ID: <20170728134931.eeqjp5fffqjpqmln@hirez.programming.kicks-ass.net>
References: <cover.1498751203.git.luto@kernel.org>
 <cf600d28712daa8e2222c08a10f6c914edab54f2.1498751203.git.luto@kernel.org>
 <20170705122506.GG4941@worktop>
 <CALCETrXYQHQm2qQ_4dLx8K2rFfapFUb-eqFdG8bk2377eFnNGg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXYQHQm2qQ_4dLx8K2rFfapFUb-eqFdG8bk2377eFnNGg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>

On Wed, Jul 05, 2017 at 09:10:00AM -0700, Andy Lutomirski wrote:
> On Wed, Jul 5, 2017 at 5:25 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> > On Thu, Jun 29, 2017 at 08:53:22AM -0700, Andy Lutomirski wrote:
> >> +static void choose_new_asid(struct mm_struct *next, u64 next_tlb_gen,
> >> +                         u16 *new_asid, bool *need_flush)
> >> +{
> >> +     u16 asid;
> >> +
> >> +     if (!static_cpu_has(X86_FEATURE_PCID)) {
> >> +             *new_asid = 0;
> >> +             *need_flush = true;
> >> +             return;
> >> +     }
> >> +
> >> +     for (asid = 0; asid < TLB_NR_DYN_ASIDS; asid++) {
> >> +             if (this_cpu_read(cpu_tlbstate.ctxs[asid].ctx_id) !=
> >> +                 next->context.ctx_id)
> >> +                     continue;
> >> +
> >> +             *new_asid = asid;
> >> +             *need_flush = (this_cpu_read(cpu_tlbstate.ctxs[asid].tlb_gen) <
> >> +                            next_tlb_gen);
> >> +             return;
> >> +     }
> >> +
> >> +     /*
> >> +      * We don't currently own an ASID slot on this CPU.
> >> +      * Allocate a slot.
> >> +      */
> >> +     *new_asid = this_cpu_add_return(cpu_tlbstate.next_asid, 1) - 1;
> >
> > So this basically RR the ASID slots. Have you tried slightly more
> > complex replacement policies like CLOCK ?
> 
> No, mainly because I'm lazy and because CLOCK requires scavenging a
> bit.  (Which we can certainly do, but it will further complicate the
> code.)  It could be worth playing with better replacement algorithms
> as a followup, though.
> 
> I've also considered a slight elaboration of RR in which we make sure
> not to reuse the most recent ASID slot, which would guarantee that, if
> we switch from task A to B and back to A, we don't flush on the way
> back to A.  (Currently, if B is not in the cache, there's a 1/6 chance
> we'll flush on the way back.)

How's this?

---
 arch/x86/include/asm/mmu.h         |  2 +-
 arch/x86/include/asm/mmu_context.h |  2 +-
 arch/x86/include/asm/tlbflush.h    |  2 +-
 arch/x86/mm/init.c                 |  2 +-
 arch/x86/mm/tlb.c                  | 47 ++++++++++++++++++++++++++------------
 5 files changed, 36 insertions(+), 19 deletions(-)

diff --git a/arch/x86/include/asm/mmu.h b/arch/x86/include/asm/mmu.h
index bb8c597c2248..9f26ea900df0 100644
--- a/arch/x86/include/asm/mmu.h
+++ b/arch/x86/include/asm/mmu.h
@@ -55,7 +55,7 @@ typedef struct {
 
 #define INIT_MM_CONTEXT(mm)						\
 	.context = {							\
-		.ctx_id = 1,						\
+		.ctx_id = 2,						\
 	}
 
 void leave_mm(int cpu);
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index d25d9f4abb15..f7866733875d 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -137,7 +137,7 @@ static inline void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk)
 static inline int init_new_context(struct task_struct *tsk,
 				   struct mm_struct *mm)
 {
-	mm->context.ctx_id = atomic64_inc_return(&last_mm_ctx_id);
+	mm->context.ctx_id = atomic64_add_return(2, &last_mm_ctx_id);
 	atomic64_set(&mm->context.tlb_gen, 0);
 
 	#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index d23e61dc0640..43a4af25d78a 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -102,7 +102,7 @@ struct tlb_state {
 	 */
 	struct mm_struct *loaded_mm;
 	u16 loaded_mm_asid;
-	u16 next_asid;
+	u16 last_asid;
 
 	/*
 	 * Access to this CR4 shadow and to H/W CR4 is protected by
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 65ae17d45c4a..570979714d49 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -812,7 +812,7 @@ void __init zone_sizes_init(void)
 
 DEFINE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate) = {
 	.loaded_mm = &init_mm,
-	.next_asid = 1,
+	.last_asid = 0,
 	.cr4 = ~0UL,	/* fail hard if we screw up cr4 shadow initialization */
 };
 EXPORT_SYMBOL_GPL(cpu_tlbstate);
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index ce104b962a17..aacb87f03428 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -28,12 +28,28 @@
  *	Implement flush IPI by CALL_FUNCTION_VECTOR, Alex Shi
  */
 
-atomic64_t last_mm_ctx_id = ATOMIC64_INIT(1);
+atomic64_t last_mm_ctx_id = ATOMIC64_INIT(2);
+
+static inline u64 asid_ctx_id(int asid)
+{
+	return this_cpu_read(cpu_tlbstate.ctxs[asid].ctx_id) & ~1ULL;
+}
+
+static inline void asid_hit(int asid)
+{
+	this_cpu_or(cpu_tlbstate.ctxs[asid].ctx_id, 1);
+}
+
+static inline bool asid_age(int asid)
+{
+	return this_cpu_xchg(cpu_tlbstate.ctxs[asid].ctx_id, asid_ctx_id(asid)) & 1ULL;
+}
 
 static void choose_new_asid(struct mm_struct *next, u64 next_tlb_gen,
 			    u16 *new_asid, bool *need_flush)
 {
 	u16 asid;
+	int i;
 
 	if (!static_cpu_has(X86_FEATURE_PCID)) {
 		*new_asid = 0;
@@ -42,10 +58,11 @@ static void choose_new_asid(struct mm_struct *next, u64 next_tlb_gen,
 	}
 
 	for (asid = 0; asid < TLB_NR_DYN_ASIDS; asid++) {
-		if (this_cpu_read(cpu_tlbstate.ctxs[asid].ctx_id) !=
-		    next->context.ctx_id)
+		if (asid_ctx_id(asid) != next->context.ctx_id)
 			continue;
 
+		asid_hit(asid);
+
 		*new_asid = asid;
 		*need_flush = (this_cpu_read(cpu_tlbstate.ctxs[asid].tlb_gen) <
 			       next_tlb_gen);
@@ -53,14 +70,17 @@ static void choose_new_asid(struct mm_struct *next, u64 next_tlb_gen,
 	}
 
 	/*
-	 * We don't currently own an ASID slot on this CPU.
-	 * Allocate a slot.
+	 * CLOCK - each entry has a single 'used' bit. Cycle through the array
+	 * clearing this bit until we find an entry that doesn't have it set.
 	 */
-	*new_asid = this_cpu_add_return(cpu_tlbstate.next_asid, 1) - 1;
-	if (*new_asid >= TLB_NR_DYN_ASIDS) {
-		*new_asid = 0;
-		this_cpu_write(cpu_tlbstate.next_asid, 1);
-	}
+	i = this_cpu_read(cpu_tlbstate.last_asid);
+	do {
+		if (--i < 0)
+			i = TLB_NR_DYN_ASIDS - 1;
+	} while (!asid_age(i));
+	this_cpu_write(cpu_tlbstate.last_asid, i);
+
+	*new_asid = i;
 	*need_flush = true;
 }
 
@@ -125,8 +145,7 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 	VM_BUG_ON(__read_cr3() != (__sme_pa(real_prev->pgd) | prev_asid));
 
 	if (real_prev == next) {
-		VM_BUG_ON(this_cpu_read(cpu_tlbstate.ctxs[prev_asid].ctx_id) !=
-			  next->context.ctx_id);
+		VM_BUG_ON(asid_ctx_id(prev_asid) != next->context.ctx_id);
 
 		if (cpumask_test_cpu(cpu, mm_cpumask(next))) {
 			/*
@@ -239,9 +258,7 @@ static void flush_tlb_func_common(const struct flush_tlb_info *f,
 
 	/* This code cannot presently handle being reentered. */
 	VM_WARN_ON(!irqs_disabled());
-
-	VM_WARN_ON(this_cpu_read(cpu_tlbstate.ctxs[loaded_mm_asid].ctx_id) !=
-		   loaded_mm->context.ctx_id);
+	VM_WARN_ON(asid_ctx_id(loaded_mm_asid) != loaded_mm->context.ctx_id);
 
 	if (!cpumask_test_cpu(smp_processor_id(), mm_cpumask(loaded_mm))) {
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
