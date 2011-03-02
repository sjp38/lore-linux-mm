Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 322F78D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 12:54:23 -0500 (EST)
Message-Id: <20110302175200.883953013@chello.nl>
Date: Wed, 02 Mar 2011 18:50:13 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 09/13] unicore: mmu_gather rework
References: <20110302175004.222724818@chello.nl>
Content-Disposition: inline; filename=peter_zijlstra-unicore-mmu_gather.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>

Fix up the unicore mmu_gather code to conform to the new API.

Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/unicore32/include/asm/tlb.h |   32 ++++++++++++++++++++------------
 1 file changed, 20 insertions(+), 12 deletions(-)

Index: linux-2.6/arch/unicore32/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/unicore32/include/asm/tlb.h
+++ linux-2.6/arch/unicore32/include/asm/tlb.h
@@ -27,17 +27,11 @@ struct mmu_gather {
 	unsigned long		range_end;
 };
 
-DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
-
-static inline struct mmu_gather *
-tlb_gather_mmu(struct mm_struct *mm, unsigned int full_mm_flush)
+static inline void
+tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned int fullmm)
 {
-	struct mmu_gather *tlb = &get_cpu_var(mmu_gathers);
-
 	tlb->mm = mm;
-	tlb->fullmm = full_mm_flush;
-
-	return tlb;
+	tlb->fullmm = fullmm;
 }
 
 static inline void
@@ -48,8 +42,6 @@ tlb_finish_mmu(struct mmu_gather *tlb, u
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
-
-	put_cpu_var(mmu_gathers);
 }
 
 /*
@@ -88,7 +80,23 @@ tlb_end_vma(struct mmu_gather *tlb, stru
 		flush_tlb_range(vma, tlb->range_start, tlb->range_end);
 }
 
-#define tlb_remove_page(tlb, page)	free_page_and_swap_cache(page)
+static inline void tlb_flush_mmu(struct mmu_gather *tlb)
+{
+}
+
+static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+{
+	free_page_and_swap_cache(page);
+	return 0;
+}
+
+static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+{
+	if (__tlb_remove_page(tlb, page))
+		tlb_flush_mmu(tlb);
+}
+
+
 #define pte_free_tlb(tlb, ptep, addr)	pte_free((tlb)->mm, ptep)
 #define pmd_free_tlb(tlb, pmdp, addr)	pmd_free((tlb)->mm, pmdp)
 #define pud_free_tlb(tlb, x, addr)      do { } while (0)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
