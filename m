Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 488638D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 12:59:16 -0500 (EST)
Message-Id: <20110302175200.589884709@chello.nl>
Date: Wed, 02 Mar 2011 18:50:09 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 05/13] arm: mmu_gather rework
References: <20110302175004.222724818@chello.nl>
Content-Disposition: inline; filename=peter_zijlstra-arm-preemptible_mmu_gather.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Russell King <rmk@arm.linux.org.uk>

Fix up the arm mmu_gather code to conform to the new API.

Cc: Russell King <rmk@arm.linux.org.uk>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/arm/include/asm/tlb.h |   49 ++++++++++++++++++++++++++++++++-------------
 1 file changed, 35 insertions(+), 14 deletions(-)

Index: linux-2.6/arch/arm/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/arm/include/asm/tlb.h
+++ linux-2.6/arch/arm/include/asm/tlb.h
@@ -41,12 +41,12 @@
  */
 #if defined(CONFIG_SMP) || defined(CONFIG_CPU_32v7)
 #define tlb_fast_mode(tlb)	0
-#define FREE_PTE_NR		500
 #else
 #define tlb_fast_mode(tlb)	1
-#define FREE_PTE_NR		0
 #endif
 
+#define MMU_GATHER_BUNDLE	8
+
 /*
  * TLB handling.  This allows us to remove pages from the page
  * tables, and efficiently handle the TLB issues.
@@ -58,7 +58,9 @@ struct mmu_gather {
 	unsigned long		range_start;
 	unsigned long		range_end;
 	unsigned int		nr;
-	struct page		*pages[FREE_PTE_NR];
+	unsigned int		max;
+	struct page		**pages;
+	struct page		*local[MMU_GATHER_BUNDLE];
 };
 
 DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
@@ -97,26 +99,37 @@ static inline void tlb_add_flush(struct 
 	}
 }
 
+static inline void __tlb_alloc_page(struct mmu_gather *tlb)
+{
+	unsigned long addr = __get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
+
+	if (addr) {
+		tlb->pages = (void *)addr;
+		tlb->max = PAGE_SIZE / sizeof(struct page *);
+	}
+}
+
 static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 {
 	tlb_flush(tlb);
 	if (!tlb_fast_mode(tlb)) {
 		free_pages_and_swap_cache(tlb->pages, tlb->nr);
 		tlb->nr = 0;
+		if (tlb->pages == tlb->local)
+			__tlb_alloc_page(tlb);
 	}
 }
 
-static inline struct mmu_gather *
-tlb_gather_mmu(struct mm_struct *mm, unsigned int full_mm_flush)
+static inline void
+tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned int fullmm)
 {
-	struct mmu_gather *tlb = &get_cpu_var(mmu_gathers);
-
 	tlb->mm = mm;
-	tlb->fullmm = full_mm_flush;
+	tlb->fullmm = fullmm;
 	tlb->vma = NULL;
+	tlb->max = ARRAY_SIZE(tlb->local);
+	tlb->pages = tlb->local;
 	tlb->nr = 0;
-
-	return tlb;
+	__tlb_alloc_page(tlb);
 }
 
 static inline void
@@ -127,7 +140,8 @@ tlb_finish_mmu(struct mmu_gather *tlb, u
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
 
-	put_cpu_var(mmu_gathers);
+	if (tlb->pages != tlb->local)
+		free_pages((unsigned long)tlb->pages, 0);
 }
 
 /*
@@ -162,15 +176,22 @@ tlb_end_vma(struct mmu_gather *tlb, stru
 		tlb_flush(tlb);
 }
 
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
 	if (tlb_fast_mode(tlb)) {
 		free_page_and_swap_cache(page);
 	} else {
 		tlb->pages[tlb->nr++] = page;
-		if (tlb->nr >= FREE_PTE_NR)
-			tlb_flush_mmu(tlb);
+		if (tlb->nr >= tlb->max)
+			return 1;
 	}
+	return 0;
+}
+
+static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+{
+	if (__tlb_remove_page(tlb, page))
+		tlb_flush_mmu(tlb);
 }
 
 static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
