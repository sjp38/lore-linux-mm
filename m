Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4AFB58D003E
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 12:10:42 -0500 (EST)
Message-Id: <20110217163235.245158823@chello.nl>
Date: Thu, 17 Feb 2011 17:23:35 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 08/17] um: mmu_gather rework
References: <20110217162327.434629380@chello.nl>
Content-Disposition: inline; filename=peter_zijlstra-um-preemptible_mmu_gather.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Jeff Dike <jdike@addtoit.com>

Fix up the um mmu_gather code to conform to the new API.

Cc: Jeff Dike <jdike@addtoit.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/um/include/asm/tlb.h |   29 +++++++++++------------------
 1 file changed, 11 insertions(+), 18 deletions(-)

Index: linux-2.6/arch/um/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/um/include/asm/tlb.h
+++ linux-2.6/arch/um/include/asm/tlb.h
@@ -22,9 +22,6 @@ struct mmu_gather {
 	unsigned int		fullmm; /* non-zero means full mm flush */
 };
 
-/* Users of the generic TLB shootdown code must declare this storage space. */
-DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 static inline void __tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep,
 					  unsigned long address)
 {
@@ -47,27 +44,20 @@ static inline void init_tlb_gather(struc
 	}
 }
 
-/* tlb_gather_mmu
- *	Return a pointer to an initialized struct mmu_gather.
- */
-static inline struct mmu_gather *
-tlb_gather_mmu(struct mm_struct *mm, unsigned int full_mm_flush)
+static inline void
+tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned int full_mm_flush)
 {
-	struct mmu_gather *tlb = &get_cpu_var(mmu_gathers);
-
 	tlb->mm = mm;
 	tlb->fullmm = full_mm_flush;
 
 	init_tlb_gather(tlb);
-
-	return tlb;
 }
 
 extern void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 			       unsigned long end);
 
 static inline void
-tlb_flush_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
+tlb_flush_mmu(struct mmu_gather *tlb)
 {
 	if (!tlb->need_flush)
 		return;
@@ -83,12 +73,10 @@ tlb_flush_mmu(struct mmu_gather *tlb, un
 static inline void
 tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
-	tlb_flush_mmu(tlb, start, end);
+	tlb_flush_mmu(tlb);
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
-
-	put_cpu_var(mmu_gathers);
 }
 
 /* tlb_remove_page
@@ -96,11 +84,16 @@ tlb_finish_mmu(struct mmu_gather *tlb, u
  *	while handling the additional races in SMP caused by other CPUs
  *	caching valid mappings in their TLBs.
  */
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
 	tlb->need_flush = 1;
 	free_page_and_swap_cache(page);
-	return;
+	return 0;
+}
+
+static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+{
+	__tlb_remove_page(tlb, page);
 }
 
 /**


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
