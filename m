Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8351E8D004C
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 09:38:58 -0400 (EDT)
Message-Id: <20110401121725.653631940@chello.nl>
Date: Fri, 01 Apr 2011 14:13:05 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 07/20] ia64: mmu_gather rework
References: <20110401121258.211963744@chello.nl>
Content-Disposition: inline; filename=peter_zijlstra-ia64-preemptible_mmu_gather.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Tony Luck <tony.luck@intel.com>

Fix up the ia64 mmu_gather code to conform to the new API.

Acked-by: Tony Luck <tony.luck@intel.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
LKML-Reference: <new-submission>
---
 arch/ia64/include/asm/tlb.h |   66 ++++++++++++++++++++++++++++++--------------
 1 file changed, 46 insertions(+), 20 deletions(-)

Index: linux-2.6/arch/ia64/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/ia64/include/asm/tlb.h
+++ linux-2.6/arch/ia64/include/asm/tlb.h
@@ -47,21 +47,27 @@
 #include <asm/machvec.h>
 
 #ifdef CONFIG_SMP
-# define FREE_PTE_NR		2048
 # define tlb_fast_mode(tlb)	((tlb)->nr == ~0U)
 #else
-# define FREE_PTE_NR		0
 # define tlb_fast_mode(tlb)	(1)
 #endif
 
+/*
+ * If we can't allocate a page to make a big batch of page pointers
+ * to work on, then just handle a few from the on-stack structure.
+ */
+#define	IA64_GATHER_BUNDLE	8
+
 struct mmu_gather {
 	struct mm_struct	*mm;
 	unsigned int		nr;		/* == ~0U => fast mode */
+	unsigned int		max;
 	unsigned char		fullmm;		/* non-zero means full mm flush */
 	unsigned char		need_flush;	/* really unmapped some PTEs? */
 	unsigned long		start_addr;
 	unsigned long		end_addr;
-	struct page 		*pages[FREE_PTE_NR];
+	struct page		**pages;
+	struct page		*local[IA64_GATHER_BUNDLE];
 };
 
 struct ia64_tr_entry {
@@ -90,9 +96,6 @@ extern struct ia64_tr_entry *ia64_idtrs[
 #define RR_RID_MASK	0x00000000ffffff00L
 #define RR_TO_RID(val) 	((val >> 8) & 0xffffff)
 
-/* Users of the generic TLB shootdown code must declare this storage space. */
-DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 /*
  * Flush the TLB for address range START to END and, if not in fast mode, release the
  * freed pages that where gathered up to this point.
@@ -147,15 +150,23 @@ ia64_tlb_flush_mmu (struct mmu_gather *t
 	}
 }
 
-/*
- * Return a pointer to an initialized struct mmu_gather.
- */
-static inline struct mmu_gather *
-tlb_gather_mmu (struct mm_struct *mm, unsigned int full_mm_flush)
+static inline void __tlb_alloc_page(struct mmu_gather *tlb)
 {
-	struct mmu_gather *tlb = &get_cpu_var(mmu_gathers);
+	unsigned long addr = __get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
 
+	if (addr) {
+		tlb->pages = (void *)addr;
+		tlb->max = PAGE_SIZE / sizeof(void *);
+	}
+}
+
+
+static inline void
+tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned int full_mm_flush)
+{
 	tlb->mm = mm;
+	tlb->max = ARRAY_SIZE(tlb->local);
+	tlb->pages = tlb->local;
 	/*
 	 * Use fast mode if only 1 CPU is online.
 	 *
@@ -172,7 +183,6 @@ tlb_gather_mmu (struct mm_struct *mm, un
 	tlb->nr = (num_online_cpus() == 1) ? ~0U : 0;
 	tlb->fullmm = full_mm_flush;
 	tlb->start_addr = ~0UL;
-	return tlb;
 }
 
 /*
@@ -180,7 +190,7 @@ tlb_gather_mmu (struct mm_struct *mm, un
  * collected.
  */
 static inline void
-tlb_finish_mmu (struct mmu_gather *tlb, unsigned long start, unsigned long end)
+tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
 	/*
 	 * Note: tlb->nr may be 0 at this point, so we can't rely on tlb->start_addr and
@@ -191,7 +201,8 @@ tlb_finish_mmu (struct mmu_gather *tlb, 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
 
-	put_cpu_var(mmu_gathers);
+	if (tlb->pages != tlb->local)
+		free_pages((unsigned long)tlb->pages, 0);
 }
 
 /*
@@ -199,18 +210,33 @@ tlb_finish_mmu (struct mmu_gather *tlb, 
  * must be delayed until after the TLB has been flushed (see comments at the beginning of
  * this file).
  */
-static inline void
-tlb_remove_page (struct mmu_gather *tlb, struct page *page)
+static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
 	tlb->need_flush = 1;
 
 	if (tlb_fast_mode(tlb)) {
 		free_page_and_swap_cache(page);
-		return;
+		return 1; /* avoid calling tlb_flush_mmu */
 	}
+
+	if (!tlb->nr && tlb->pages == tlb->local)
+		__tlb_alloc_page(tlb);
+
 	tlb->pages[tlb->nr++] = page;
-	if (tlb->nr >= FREE_PTE_NR)
-		ia64_tlb_flush_mmu(tlb, tlb->start_addr, tlb->end_addr);
+	VM_BUG_ON(tlb->nr > tlb->max);
+
+	return tlb->max - tlb->nr;
+}
+
+static inline void tlb_flush_mmu(struct mmu_gather *tlb)
+{
+	ia64_tlb_flush_mmu(tlb, tlb->start_addr, tlb->end_addr);
+}
+
+static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+{
+	if (!__tlb_remove_page(tlb, page))
+		tlb_flush_mmu(tlb);
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
