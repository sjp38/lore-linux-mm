Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BFE528D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 09:38:53 -0400 (EDT)
Message-Id: <20110401121725.511787866@chello.nl>
Date: Fri, 01 Apr 2011 14:13:02 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 04/20] s390: mmu_gather rework
References: <20110401121258.211963744@chello.nl>
Content-Disposition: inline; filename=martin_schwidefsky-s390-preemptible_mmu_gather.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

Adapt the stand-alone s390 mmu_gather implementation to the new
preemptible mmu_gather interface.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
LKML-Reference: <20101126145410.881573395@chello.nl>
---
 arch/s390/include/asm/tlb.h |   62 ++++++++++++++++++++++++++------------------
 1 file changed, 37 insertions(+), 25 deletions(-)

Index: linux-2.6/arch/s390/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/s390/include/asm/tlb.h
+++ linux-2.6/arch/s390/include/asm/tlb.h
@@ -29,65 +29,77 @@
 #include <asm/smp.h>
 #include <asm/tlbflush.h>
 
-#ifndef CONFIG_SMP
-#define TLB_NR_PTRS	1
-#else
-#define TLB_NR_PTRS	508
-#endif
-
 struct mmu_gather {
 	struct mm_struct *mm;
 	unsigned int fullmm;
 	unsigned int nr_ptes;
 	unsigned int nr_pxds;
-	void *array[TLB_NR_PTRS];
+	unsigned int max;
+	void **array;
+	void *local[8];
 };
 
-DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
-
-static inline struct mmu_gather *tlb_gather_mmu(struct mm_struct *mm,
-						unsigned int full_mm_flush)
+static inline void __tlb_alloc_page(struct mmu_gather *tlb)
 {
-	struct mmu_gather *tlb = &get_cpu_var(mmu_gathers);
+	unsigned long addr = __get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
 
+	if (addr) {
+		tlb->array = (void *) addr;
+		tlb->max = PAGE_SIZE / sizeof(void *);
+	}
+}
+
+static inline void tlb_gather_mmu(struct mmu_gather *tlb,
+				  struct mm_struct *mm,
+				  unsigned int full_mm_flush)
+{
 	tlb->mm = mm;
+	tlb->max = ARRAY_SIZE(tlb->local);
+	tlb->array = tlb->local;
 	tlb->fullmm = full_mm_flush;
-	tlb->nr_ptes = 0;
-	tlb->nr_pxds = TLB_NR_PTRS;
 	if (tlb->fullmm)
 		__tlb_flush_mm(mm);
-	return tlb;
+	else
+		__tlb_alloc_page(tlb);
+	tlb->nr_ptes = 0;
+	tlb->nr_pxds = tlb->max;
 }
 
-static inline void tlb_flush_mmu(struct mmu_gather *tlb,
-				 unsigned long start, unsigned long end)
+static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 {
-	if (!tlb->fullmm && (tlb->nr_ptes > 0 || tlb->nr_pxds < TLB_NR_PTRS))
+	if (!tlb->fullmm && (tlb->nr_ptes > 0 || tlb->nr_pxds < tlb->max))
 		__tlb_flush_mm(tlb->mm);
 	while (tlb->nr_ptes > 0)
 		page_table_free_rcu(tlb->mm, tlb->array[--tlb->nr_ptes]);
-	while (tlb->nr_pxds < TLB_NR_PTRS)
+	while (tlb->nr_pxds < tlb->max)
 		crst_table_free_rcu(tlb->mm, tlb->array[tlb->nr_pxds++]);
 }
 
 static inline void tlb_finish_mmu(struct mmu_gather *tlb,
 				  unsigned long start, unsigned long end)
 {
-	tlb_flush_mmu(tlb, start, end);
+	tlb_flush_mmu(tlb);
 
 	rcu_table_freelist_finish();
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
 
-	put_cpu_var(mmu_gathers);
+	if (tlb->array != tlb->local)
+		free_pages((unsigned long) tlb->array, 0);
 }
 
 /*
  * Release the page cache reference for a pte removed by
- * tlb_ptep_clear_flush. In both flush modes the tlb fo a page cache page
+ * tlb_ptep_clear_flush. In both flush modes the tlb for a page cache page
  * has already been freed, so just do free_page_and_swap_cache.
  */
+static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+{
+	free_page_and_swap_cache(page);
+	return 1; /* avoid calling tlb_flush_mmu */
+}
+
 static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
 	free_page_and_swap_cache(page);
@@ -103,7 +115,7 @@ static inline void pte_free_tlb(struct m
 	if (!tlb->fullmm) {
 		tlb->array[tlb->nr_ptes++] = pte;
 		if (tlb->nr_ptes >= tlb->nr_pxds)
-			tlb_flush_mmu(tlb, 0, 0);
+			tlb_flush_mmu(tlb);
 	} else
 		page_table_free(tlb->mm, (unsigned long *) pte);
 }
@@ -124,7 +136,7 @@ static inline void pmd_free_tlb(struct m
 	if (!tlb->fullmm) {
 		tlb->array[--tlb->nr_pxds] = pmd;
 		if (tlb->nr_ptes >= tlb->nr_pxds)
-			tlb_flush_mmu(tlb, 0, 0);
+			tlb_flush_mmu(tlb);
 	} else
 		crst_table_free(tlb->mm, (unsigned long *) pmd);
 #endif
@@ -146,7 +158,7 @@ static inline void pud_free_tlb(struct m
 	if (!tlb->fullmm) {
 		tlb->array[--tlb->nr_pxds] = pud;
 		if (tlb->nr_ptes >= tlb->nr_pxds)
-			tlb_flush_mmu(tlb, 0, 0);
+			tlb_flush_mmu(tlb);
 	} else
 		crst_table_free(tlb->mm, (unsigned long *) pud);
 #endif


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
