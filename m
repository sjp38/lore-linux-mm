Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 73A0C6B0081
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 05:53:15 -0400 (EDT)
Date: Tue, 4 Jun 2013 11:52:58 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: TLB and PTE coherency during munmap
Message-ID: <20130604095258.GL8923@twins.programming.kicks-ass.net>
References: <CAMo8BfL4QfJrfejNKmBDhAVdmE=_Ys6MVUH5Xa3w_mU41hwx0A@mail.gmail.com>
 <CAMo8BfJie1Y49QeSJ+JTQb9WsYJkMMkb1BkKz2Gzy3T7V6ogHA@mail.gmail.com>
 <51A45861.1010008@gmail.com>
 <20130529122728.GA27176@twins.programming.kicks-ass.net>
 <51A5F7A7.5020604@synopsys.com>
 <20130529175125.GJ12193@twins.programming.kicks-ass.net>
 <CAMo8BfJtkEtf9RKsGRnOnZ5zbJQz5tW4HeDfydFq_ZnrFr8opw@mail.gmail.com>
 <20130603090501.GI5910@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130603090501.GI5910@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Max Filippov <jcmvbkbc@gmail.com>
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, Ralf Baechle <ralf@linux-mips.org>, Chris Zankel <chris@zankel.net>, Marc Gauthier <Marc.Gauthier@tensilica.com>, linux-xtensa@linux-xtensa.org, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Tony Luck <tony.luck@intel.com>

On Mon, Jun 03, 2013 at 11:05:01AM +0200, Peter Zijlstra wrote:
> On Fri, May 31, 2013 at 08:09:17AM +0400, Max Filippov wrote:
> > Hi Peter,
> > 
> > On Wed, May 29, 2013 at 9:51 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> > > What about something like this?
> > 
> > With that patch I still get mtest05 firing my TLB/PTE incoherency check
> > in the UP PREEMPT_VOLUNTARY configuration. This happens after
> > zap_pte_range completion in the end of unmap_region because of
> > rescheduling called in the following call chain:
> 
> OK, so there two options; completely kill off fast-mode or something like the
> below where we add magic to the scheduler :/
> 
> I'm aware people might object to something like the below -- but since its a
> possibility I thought we ought to at least mention it.
> 
> For those new to the thread; the problem is that since the introduction of
> preemptible mmu_gather the traditional UP fast-mode is broken. Fast-mode is
> where we free the pages first and flush TLBs later. This is not a problem if
> there's no concurrency, but obviously if you can preempt there now is.
> 
> I think I prefer completely killing off fast-mode esp. since UP seems to go the
> way of the Dodo and it does away with an exception in the mmu_gather code.
> 
> Anyway; opinions? Linus, Thomas, Ingo?

And here's the patch that makes fast mode go *poof*..

---
 arch/arm/include/asm/tlb.h  | 27 ++++-----------------------
 arch/ia64/include/asm/tlb.h | 41 ++++++++---------------------------------
 include/asm-generic/tlb.h   | 17 +----------------
 mm/memory.c                 |  9 ---------
 4 files changed, 13 insertions(+), 81 deletions(-)

diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index 99a1951..bdf2b84 100644
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
@@ -112,12 +100,10 @@ static inline void __tlb_alloc_page(struct mmu_gather *tlb)
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
@@ -178,11 +164,6 @@ tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
 
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
diff --git a/arch/ia64/include/asm/tlb.h b/arch/ia64/include/asm/tlb.h
index c3ffe3e..ef3a9de 100644
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
@@ -103,6 +97,7 @@ extern struct ia64_tr_entry *ia64_idtrs[NR_CPUS];
 static inline void
 ia64_tlb_flush_mmu (struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
+	unsigned long i;
 	unsigned int nr;
 
 	if (!tlb->need_flush)
@@ -141,13 +136,11 @@ ia64_tlb_flush_mmu (struct mmu_gather *tlb, unsigned long start, unsigned long e
 
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
@@ -167,20 +160,7 @@ tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned int full_m
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
@@ -214,11 +194,6 @@ static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
 	tlb->need_flush = 1;
 
-	if (tlb_fast_mode(tlb)) {
-		free_page_and_swap_cache(page);
-		return 1; /* avoid calling tlb_flush_mmu */
-	}
-
 	if (!tlb->nr && tlb->pages == tlb->local)
 		__tlb_alloc_page(tlb);
 
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index b1b1fa6..13821c3 100644
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
diff --git a/mm/memory.c b/mm/memory.c
index d7d54a1..95d0cce 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -220,7 +220,6 @@ void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, bool fullmm)
 	tlb->start	= -1UL;
 	tlb->end	= 0;
 	tlb->need_flush = 0;
-	tlb->fast_mode  = (num_possible_cpus() == 1);
 	tlb->local.next = NULL;
 	tlb->local.nr   = 0;
 	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
@@ -244,9 +243,6 @@ void tlb_flush_mmu(struct mmu_gather *tlb)
 	tlb_table_flush(tlb);
 #endif
 
-	if (tlb_fast_mode(tlb))
-		return;
-
 	for (batch = &tlb->local; batch; batch = batch->next) {
 		free_pages_and_swap_cache(batch->pages, batch->nr);
 		batch->nr = 0;
@@ -288,11 +284,6 @@ int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 
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
