Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA2B26B0343
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 11:53:34 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id n2so22052231oig.12
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 08:53:34 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a67si3919343oih.233.2017.06.29.08.53.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 08:53:33 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v4 04/10] x86/mm: Track the TLB's tlb_gen and update the flushing algorithm
Date: Thu, 29 Jun 2017 08:53:16 -0700
Message-Id: <1210fb244bc9cbe7677f7f0b72db4d359675f24b.1498751203.git.luto@kernel.org>
In-Reply-To: <cover.1498751203.git.luto@kernel.org>
References: <cover.1498751203.git.luto@kernel.org>
In-Reply-To: <cover.1498751203.git.luto@kernel.org>
References: <cover.1498751203.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>

There are two kernel features that would benefit from tracking
how up-to-date each CPU's TLB is in the case where IPIs aren't keeping
it up to date in real time:

 - Lazy mm switching currently works by switching to init_mm when
   it would otherwise flush.  This is wasteful: there isn't fundamentally
   any need to update CR3 at all when going lazy or when returning from
   lazy mode, nor is there any need to receive flush IPIs at all.  Instead,
   we should just stop trying to keep the TLB coherent when we go lazy and,
   when unlazying, check whether we missed any flushes.

 - PCID will let us keep recent user contexts alive in the TLB.  If we
   start doing this, we need a way to decide whether those contexts are
   up to date.

On some paravirt systems, remote TLBs can be flushed without IPIs.
This won't update the target CPUs' tlb_gens, which may cause
unnecessary local flushes later on.  We can address this if it becomes
a problem by carefully updating the target CPU's tlb_gen directly.

By itself, this patch is a very minor optimization that avoids
unnecessary flushes when multiple TLB flushes targetting the same CPU
race.  The complexity in this patch would not be worth it on its own,
but it will enable improved lazy TLB tracking and PCID.

Reviewed-by: Nadav Amit <nadav.amit@gmail.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/tlbflush.h |  43 +++++++++++++++--
 arch/x86/mm/tlb.c               | 102 +++++++++++++++++++++++++++++++++++++---
 2 files changed, 135 insertions(+), 10 deletions(-)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index ad2135385699..d7df54cc7e4d 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -82,6 +82,11 @@ static inline u64 inc_mm_tlb_gen(struct mm_struct *mm)
 #define __flush_tlb_single(addr) __native_flush_tlb_single(addr)
 #endif
 
+struct tlb_context {
+	u64 ctx_id;
+	u64 tlb_gen;
+};
+
 struct tlb_state {
 	/*
 	 * cpu_tlbstate.loaded_mm should match CR3 whenever interrupts
@@ -97,6 +102,21 @@ struct tlb_state {
 	 * disabling interrupts when modifying either one.
 	 */
 	unsigned long cr4;
+
+	/*
+	 * This is a list of all contexts that might exist in the TLB.
+	 * Since we don't yet use PCID, there is only one context.
+	 *
+	 * For each context, ctx_id indicates which mm the TLB's user
+	 * entries came from.  As an invariant, the TLB will never
+	 * contain entries that are out-of-date as when that mm reached
+	 * the tlb_gen in the list.
+	 *
+	 * To be clear, this means that it's legal for the TLB code to
+	 * flush the TLB without updating tlb_gen.  This can happen
+	 * (for now, at least) due to paravirt remote flushes.
+	 */
+	struct tlb_context ctxs[1];
 };
 DECLARE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate);
 
@@ -248,9 +268,26 @@ static inline void __flush_tlb_one(unsigned long addr)
  * and page-granular flushes are available only on i486 and up.
  */
 struct flush_tlb_info {
-	struct mm_struct *mm;
-	unsigned long start;
-	unsigned long end;
+	/*
+	 * We support several kinds of flushes.
+	 *
+	 * - Fully flush a single mm.  .mm will be set, .end will be
+	 *   TLB_FLUSH_ALL, and .new_tlb_gen will be the tlb_gen to
+	 *   which the IPI sender is trying to catch us up.
+	 *
+	 * - Partially flush a single mm.  .mm will be set, .start and
+	 *   .end will indicate the range, and .new_tlb_gen will be set
+	 *   such that the changes between generation .new_tlb_gen-1 and
+	 *   .new_tlb_gen are entirely contained in the indicated range.
+	 *
+	 * - Fully flush all mms whose tlb_gens have been updated.  .mm
+	 *   will be NULL, .end will be TLB_FLUSH_ALL, and .new_tlb_gen
+	 *   will be zero.
+	 */
+	struct mm_struct	*mm;
+	unsigned long		start;
+	unsigned long		end;
+	u64			new_tlb_gen;
 };
 
 #define local_flush_tlb() __flush_tlb()
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 14f4f8f66aa8..4e5a5ddb9e4d 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -105,6 +105,8 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 	}
 
 	this_cpu_write(cpu_tlbstate.loaded_mm, next);
+	this_cpu_write(cpu_tlbstate.ctxs[0].ctx_id, next->context.ctx_id);
+	this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen, atomic64_read(&next->context.tlb_gen));
 
 	WARN_ON_ONCE(cpumask_test_cpu(cpu, mm_cpumask(next)));
 	cpumask_set_cpu(cpu, mm_cpumask(next));
@@ -155,25 +157,102 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 	switch_ldt(real_prev, next);
 }
 
+/*
+ * flush_tlb_func_common()'s memory ordering requirement is that any
+ * TLB fills that happen after we flush the TLB are ordered after we
+ * read active_mm's tlb_gen.  We don't need any explicit barriers
+ * because all x86 flush operations are serializing and the
+ * atomic64_read operation won't be reordered by the compiler.
+ */
 static void flush_tlb_func_common(const struct flush_tlb_info *f,
 				  bool local, enum tlb_flush_reason reason)
 {
+	/*
+	 * We have three different tlb_gen values in here.  They are:
+	 *
+	 * - mm_tlb_gen:     the latest generation.
+	 * - local_tlb_gen:  the generation that this CPU has already caught
+	 *                   up to.
+	 * - f->new_tlb_gen: the generation that the requester of the flush
+	 *                   wants us to catch up to.
+	 */
+	struct mm_struct *loaded_mm = this_cpu_read(cpu_tlbstate.loaded_mm);
+	u64 mm_tlb_gen = atomic64_read(&loaded_mm->context.tlb_gen);
+	u64 local_tlb_gen = this_cpu_read(cpu_tlbstate.ctxs[0].tlb_gen);
+
 	/* This code cannot presently handle being reentered. */
 	VM_WARN_ON(!irqs_disabled());
 
+	VM_WARN_ON(this_cpu_read(cpu_tlbstate.ctxs[0].ctx_id) !=
+		   loaded_mm->context.ctx_id);
+
 	if (this_cpu_read(cpu_tlbstate.state) != TLBSTATE_OK) {
+		/*
+		 * leave_mm() is adequate to handle any type of flush, and
+		 * we would prefer not to receive further IPIs.  leave_mm()
+		 * clears this CPU's bit in mm_cpumask().
+		 */
 		leave_mm(smp_processor_id());
 		return;
 	}
 
-	if (f->end == TLB_FLUSH_ALL) {
-		local_flush_tlb();
-		if (local)
-			count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
-		trace_tlb_flush(reason, TLB_FLUSH_ALL);
-	} else {
+	if (unlikely(local_tlb_gen == mm_tlb_gen)) {
+		/*
+		 * There's nothing to do: we're already up to date.  This can
+		 * happen if two concurrent flushes happen -- the first flush to
+		 * be handled can catch us all the way up, leaving no work for
+		 * the second flush.
+		 */
+		return;
+	}
+
+	WARN_ON_ONCE(local_tlb_gen > mm_tlb_gen);
+	WARN_ON_ONCE(f->new_tlb_gen > mm_tlb_gen);
+
+	/*
+	 * If we get to this point, we know that our TLB is out of date.
+	 * This does not strictly imply that we need to flush (it's
+	 * possible that f->new_tlb_gen <= local_tlb_gen), but we're
+	 * going to need to flush in the very near future, so we might
+	 * as well get it over with.
+	 *
+	 * The only question is whether to do a full or partial flush.
+	 *
+	 * We do a partial flush if requested and two extra conditions
+	 * are met:
+	 *
+	 * 1. f->new_tlb_gen == local_tlb_gen + 1.  We have an invariant that
+	 *    we've always done all needed flushes to catch up to
+	 *    local_tlb_gen.  If, for example, local_tlb_gen == 2 and
+	 *    f->new_tlb_gen == 3, then we know that the flush needed to bring
+	 *    us up to date for tlb_gen 3 is the partial flush we're
+	 *    processing.
+	 *
+	 *    As an example of why this check is needed, suppose that there
+	 *    are two concurrent flushes.  The first is a full flush that
+	 *    changes context.tlb_gen from 1 to 2.  The second is a partial
+	 *    flush that changes context.tlb_gen from 2 to 3.  If they get
+	 *    processed on this CPU in reverse order, we'll see
+	 *     local_tlb_gen == 1, mm_tlb_gen == 3, and end != TLB_FLUSH_ALL.
+	 *    If we were to use __flush_tlb_single() and set local_tlb_gen to
+	 *    3, we'd be break the invariant: we'd update local_tlb_gen above
+	 *    1 without the full flush that's needed for tlb_gen 2.
+	 *
+	 * 2. f->new_tlb_gen == mm_tlb_gen.  This is purely an optimiation.
+	 *    Partial TLB flushes are not all that much cheaper than full TLB
+	 *    flushes, so it seems unlikely that it would be a performance win
+	 *    to do a partial flush if that won't bring our TLB fully up to
+	 *    date.  By doing a full flush instead, we can increase
+	 *    local_tlb_gen all the way to mm_tlb_gen and we can probably
+	 *    avoid another flush in the very near future.
+	 */
+	if (f->end != TLB_FLUSH_ALL &&
+	    f->new_tlb_gen == local_tlb_gen + 1 &&
+	    f->new_tlb_gen == mm_tlb_gen) {
+		/* Partial flush */
 		unsigned long addr;
 		unsigned long nr_pages = (f->end - f->start) >> PAGE_SHIFT;
+
 		addr = f->start;
 		while (addr < f->end) {
 			__flush_tlb_single(addr);
@@ -182,7 +261,16 @@ static void flush_tlb_func_common(const struct flush_tlb_info *f,
 		if (local)
 			count_vm_tlb_events(NR_TLB_LOCAL_FLUSH_ONE, nr_pages);
 		trace_tlb_flush(reason, nr_pages);
+	} else {
+		/* Full flush. */
+		local_flush_tlb();
+		if (local)
+			count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
+		trace_tlb_flush(reason, TLB_FLUSH_ALL);
 	}
+
+	/* Both paths above update our state to mm_tlb_gen. */
+	this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen, mm_tlb_gen);
 }
 
 static void flush_tlb_func_local(void *info, enum tlb_flush_reason reason)
@@ -253,7 +341,7 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 	cpu = get_cpu();
 
 	/* This is also a barrier that synchronizes with switch_mm(). */
-	inc_mm_tlb_gen(mm);
+	info.new_tlb_gen = inc_mm_tlb_gen(mm);
 
 	/* Should we flush just the requested range? */
 	if ((end != TLB_FLUSH_ALL) &&
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
