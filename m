Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id C6B1D6B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 06:27:10 -0400 (EDT)
Date: Wed, 5 Jun 2013 12:26:50 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH] arch, mm: Remove tlb_fast_mode()
Message-ID: <20130605102650.GU8923@twins.programming.kicks-ass.net>
References: <CAMo8BfL4QfJrfejNKmBDhAVdmE=_Ys6MVUH5Xa3w_mU41hwx0A@mail.gmail.com>
 <CAMo8BfJie1Y49QeSJ+JTQb9WsYJkMMkb1BkKz2Gzy3T7V6ogHA@mail.gmail.com>
 <51A45861.1010008@gmail.com>
 <20130529122728.GA27176@twins.programming.kicks-ass.net>
 <51A5F7A7.5020604@synopsys.com>
 <20130529175125.GJ12193@twins.programming.kicks-ass.net>
 <CAMo8BfJtkEtf9RKsGRnOnZ5zbJQz5tW4HeDfydFq_ZnrFr8opw@mail.gmail.com>
 <20130603090501.GI5910@twins.programming.kicks-ass.net>
 <20130604095258.GL8923@twins.programming.kicks-ass.net>
 <alpine.LFD.2.03.1306050904160.28129@pixel.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.03.1306050904160.28129@pixel.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Max Filippov <jcmvbkbc@gmail.com>, Vineet Gupta <Vineet.Gupta1@synopsys.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, Ralf Baechle <ralf@linux-mips.org>, Chris Zankel <chris@zankel.net>, Marc Gauthier <Marc.Gauthier@tensilica.com>, linux-xtensa@linux-xtensa.org, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Tony Luck <tony.luck@intel.com>

On Wed, Jun 05, 2013 at 09:05:03AM +0900, Linus Torvalds wrote:
> 
> 
> On Tue, 4 Jun 2013, Peter Zijlstra wrote:
> > 
> > And here's the patch that makes fast mode go *poof*..
> 
> Let's just do this. Mind sending a patch with proper changelog and 
> sign-off?

Sure, as an extra I even compile tested it! ;-) (including arm and
ia64).

---
Subject: arch, mm: Remove tlb_fast_mode()
From: Peter Zijlstra <peterz@infradead.org>

Since the introduction of preemptible mmu_gather TLB fast mode has been
broken. TLB fast mode relies on there being absolutely no concurrency;
it frees pages first and invalidates TLBs later.

However now we can get concurrency and stuff goes *bang*.

This patch removes all tlb_fast_mode() code; it was found the better
option vs trying to patch the hole by entangling tlb invalidation with
the scheduler.

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Tony Luck <tony.luck@intel.com>
Reported-by: Max Filippov <jcmvbkbc@gmail.com>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 arch/arm/include/asm/tlb.h  |   27 ++++-----------------------
 arch/ia64/include/asm/tlb.h |   41 ++++++++---------------------------------
 include/asm-generic/tlb.h   |   17 +----------------
 mm/memory.c                 |    9 ---------
 4 files changed, 13 insertions(+), 81 deletions(-)

--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -33,18 +33,6 @@
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 
-/*
- * We need to delay page freeing for SMP as other CPUs can access pages
- * which have been removed but not yet had their TLB entries invalidated.
- * Also, as ARMv7 speculative prefetch can drag new entries into the TLB,
- * we need to apply this same delaying tactic to ensure correct operation.
- */
-#if defined(CONFIG_SMP) || defined(CONFIG_CPU_32v7)
-#define tlb_fast_mode(tlb)	0
-#else
-#define tlb_fast_mode(tlb)	1
-#endif
-
 #define MMU_GATHER_BUNDLE	8
 
 /*
@@ -112,12 +100,10 @@ static inline void __tlb_alloc_page(stru
 static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 {
 	tlb_flush(tlb);
-	if (!tlb_fast_mode(tlb)) {
-		free_pages_and_swap_cache(tlb->pages, tlb->nr);
-		tlb->nr = 0;
-		if (tlb->pages == tlb->local)
-			__tlb_alloc_page(tlb);
-	}
+	free_pages_and_swap_cache(tlb->pages, tlb->nr);
+	tlb->nr = 0;
+	if (tlb->pages == tlb->local)
+		__tlb_alloc_page(tlb);
 }
 
 static inline void
@@ -178,11 +164,6 @@ tlb_end_vma(struct mmu_gather *tlb, stru
 
 static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
-	if (tlb_fast_mode(tlb)) {
-		free_page_and_swap_cache(page);
-		return 1; /* avoid calling tlb_flush_mmu */
-	}
-
 	tlb->pages[tlb->nr++] = page;
 	VM_BUG_ON(tlb->nr > tlb->max);
 	return tlb->max - tlb->nr;
--- a/arch/ia64/include/asm/tlb.h
+++ b/arch/ia64/include/asm/tlb.h
@@ -46,12 +46,6 @@
 #include <asm/tlbflush.h>
 #include <asm/machvec.h>
 
-#ifdef CONFIG_SMP
-# define tlb_fast_mode(tlb)	((tlb)->nr == ~0U)
-#else
-# define tlb_fast_mode(tlb)	(1)
-#endif
-
 /*
  * If we can't allocate a page to make a big batch of page pointers
  * to work on, then just handle a few from the on-stack structure.
@@ -60,7 +54,7 @@
 
 struct mmu_gather {
 	struct mm_struct	*mm;
-	unsigned int		nr;		/* == ~0U => fast mode */
+	unsigned int		nr;
 	unsigned int		max;
 	unsigned char		fullmm;		/* non-zero means full mm flush */
 	unsigned char		need_flush;	/* really unmapped some PTEs? */
@@ -103,6 +97,7 @@ extern struct ia64_tr_entry *ia64_idtrs[
 static inline void
 ia64_tlb_flush_mmu (struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
+	unsigned long i;
 	unsigned int nr;
 
 	if (!tlb->need_flush)
@@ -141,13 +136,11 @@ ia64_tlb_flush_mmu (struct mmu_gather *t
 
 	/* lastly, release the freed pages */
 	nr = tlb->nr;
-	if (!tlb_fast_mode(tlb)) {
-		unsigned long i;
-		tlb->nr = 0;
-		tlb->start_addr = ~0UL;
-		for (i = 0; i < nr; ++i)
-			free_page_and_swap_cache(tlb->pages[i]);
-	}
+
+	tlb->nr = 0;
+	tlb->start_addr = ~0UL;
+	for (i = 0; i < nr; ++i)
+		free_page_and_swap_cache(tlb->pages[i]);
 }
 
 static inline void __tlb_alloc_page(struct mmu_gather *tlb)
@@ -167,20 +160,7 @@ tlb_gather_mmu(struct mmu_gather *tlb, s
 	tlb->mm = mm;
 	tlb->max = ARRAY_SIZE(tlb->local);
 	tlb->pages = tlb->local;
-	/*
-	 * Use fast mode if only 1 CPU is online.
-	 *
-	 * It would be tempting to turn on fast-mode for full_mm_flush as well.  But this
-	 * doesn't work because of speculative accesses and software prefetching: the page
-	 * table of "mm" may (and usually is) the currently active page table and even
-	 * though the kernel won't do any user-space accesses during the TLB shoot down, a
-	 * compiler might use speculation or lfetch.fault on what happens to be a valid
-	 * user-space address.  This in turn could trigger a TLB miss fault (or a VHPT
-	 * walk) and re-insert a TLB entry we just removed.  Slow mode avoids such
-	 * problems.  (We could make fast-mode work by switching the current task to a
-	 * different "mm" during the shootdown.) --davidm 08/02/2002
-	 */
-	tlb->nr = (num_online_cpus() == 1) ? ~0U : 0;
+	tlb->nr = 0;
 	tlb->fullmm = full_mm_flush;
 	tlb->start_addr = ~0UL;
 }
@@ -214,11 +194,6 @@ static inline int __tlb_remove_page(stru
 {
 	tlb->need_flush = 1;
 
-	if (tlb_fast_mode(tlb)) {
-		free_page_and_swap_cache(page);
-		return 1; /* avoid calling tlb_flush_mmu */
-	}
-
 	if (!tlb->nr && tlb->pages == tlb->local)
 		__tlb_alloc_page(tlb);
 
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -97,11 +97,9 @@ struct mmu_gather {
 	unsigned long		start;
 	unsigned long		end;
 	unsigned int		need_flush : 1,	/* Did free PTEs */
-				fast_mode  : 1; /* No batching   */
-
 	/* we are in the middle of an operation to clear
 	 * a full mm and can make some optimizations */
-	unsigned int		fullmm : 1,
+				fullmm : 1,
 	/* we have performed an operation which
 	 * requires a complete flush of the tlb */
 				need_flush_all : 1;
@@ -114,19 +112,6 @@ struct mmu_gather {
 
 #define HAVE_GENERIC_MMU_GATHER
 
-static inline int tlb_fast_mode(struct mmu_gather *tlb)
-{
-#ifdef CONFIG_SMP
-	return tlb->fast_mode;
-#else
-	/*
-	 * For UP we don't need to worry about TLB flush
-	 * and page free order so much..
-	 */
-	return 1;
-#endif
-}
-
 void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, bool fullmm);
 void tlb_flush_mmu(struct mmu_gather *tlb);
 void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start,
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -220,7 +220,6 @@ void tlb_gather_mmu(struct mmu_gather *t
 	tlb->start	= -1UL;
 	tlb->end	= 0;
 	tlb->need_flush = 0;
-	tlb->fast_mode  = (num_possible_cpus() == 1);
 	tlb->local.next = NULL;
 	tlb->local.nr   = 0;
 	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
@@ -244,9 +243,6 @@ void tlb_flush_mmu(struct mmu_gather *tl
 	tlb_table_flush(tlb);
 #endif
 
-	if (tlb_fast_mode(tlb))
-		return;
-
 	for (batch = &tlb->local; batch; batch = batch->next) {
 		free_pages_and_swap_cache(batch->pages, batch->nr);
 		batch->nr = 0;
@@ -288,11 +284,6 @@ int __tlb_remove_page(struct mmu_gather
 
 	VM_BUG_ON(!tlb->need_flush);
 
-	if (tlb_fast_mode(tlb)) {
-		free_page_and_swap_cache(page);
-		return 1; /* avoid calling tlb_flush_mmu() */
-	}
-
 	batch = tlb->active;
 	batch->pages[batch->nr++] = page;
 	if (batch->nr == batch->max) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
