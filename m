Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5176B00EB
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 12:59:11 -0500 (EST)
Message-Id: <20110125174908.531253165@chello.nl>
Date: Tue, 25 Jan 2011 18:31:36 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 25/25] mm, arch: Ensure we never tlb_flush_mmu() from atomic context
References: <20110125173111.720927511@chello.nl>
Content-Disposition: inline; filename=mm-flush-vs-pte_lock.patch
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Hugh noted that we could still end up flushing the batch from atomic
context because we do tlb_remove_page() while holding the pte_lock.

This will still generate immense latencies, more so now than ever
before due to the larger batches. Break tlb_remove_page() into two
functions, one that queues the page and one that flushes the queue.

Leave the tlb_remove_page() interface for now with the old semantics
but add a might_sleep() in there to detect callers from atomic
contexts.

XXX should probably fold back into the mmu_gather preempt patches for
the various architectures.

Reported-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/arm/include/asm/tlb.h  |   17 ++++++++++++++++-
 arch/ia64/include/asm/tlb.h |   22 ++++++++++++++++++----
 arch/s390/include/asm/tlb.h |   18 ++++++++++++------
 arch/sh/include/asm/tlb.h   |   17 ++++++++++++++++-
 arch/um/include/asm/tlb.h   |   15 +++++++++++----
 include/asm-generic/tlb.h   |   22 +++++++++++++++-------
 mm/memory.c                 |   14 +++++++++++---
 7 files changed, 99 insertions(+), 26 deletions(-)

Index: linux-2.6/include/asm-generic/tlb.h
===================================================================
--- linux-2.6.orig/include/asm-generic/tlb.h
+++ linux-2.6/include/asm-generic/tlb.h
@@ -146,7 +146,7 @@ tlb_gather_mmu(struct mmu_gather *tlb, s
 }
 
 static inline void
-tlb_flush_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
+tlb_flush_mmu(struct mmu_gather *tlb)
 {
 	struct mmu_gather_batch *batch;
 
@@ -176,7 +176,7 @@ tlb_finish_mmu(struct mmu_gather *tlb, u
 {
 	struct mmu_gather_batch *batch, *next;
 
-	tlb_flush_mmu(tlb, start, end);
+	tlb_flush_mmu(tlb);
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
@@ -193,7 +193,7 @@ tlb_finish_mmu(struct mmu_gather *tlb, u
  *	handling the additional races in SMP caused by other CPUs caching valid
  *	mappings in their TLBs.
  */
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
 	struct mmu_gather_batch *batch;
 
@@ -201,17 +201,25 @@ static inline void tlb_remove_page(struc
 
 	if (tlb_fast_mode(tlb)) {
 		free_page_and_swap_cache(page);
-		return;
+		return 0;
 	}
 
 	batch = tlb->active;
+	batch->pages[batch->nr++] = page;
 	if (batch->nr == batch->max) {
 		if (!tlb_next_batch(tlb))
-			tlb_flush_mmu(tlb, 0, 0);
-		batch = tlb->active;
+			return 1;
 	}
 
-	batch->pages[batch->nr++] = page;
+	return 0;
+}
+
+static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+{
+	might_sleep();
+
+	if (__tlb_remove_page(tlb, page))
+		tlb_flush_mmu(tlb);
 }
 
 /**
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -990,11 +990,12 @@ static unsigned long zap_pte_range(struc
 {
 	struct mm_struct *mm = tlb->mm;
 	int rss[NR_MM_COUNTERS];
+	int need_flush = 0;
 	spinlock_t *ptl;
 	pte_t *pte;
 
 	init_rss_vec(rss);
-
+again:
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
 	do {
@@ -1048,7 +1049,7 @@ static unsigned long zap_pte_range(struc
 			page_remove_rmap(page);
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
-			tlb_remove_page(tlb, page);
+			need_flush = __tlb_remove_page(tlb, page);
 			continue;
 		}
 		/*
@@ -1069,12 +1070,19 @@ static unsigned long zap_pte_range(struc
 				print_bad_pte(vma, addr, ptent, NULL);
 		}
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
-	} while (pte++, addr += PAGE_SIZE, addr != end);
+	} while (pte++, addr += PAGE_SIZE, (addr != end && !need_flush));
 
 	add_mm_rss_vec(mm, rss);
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
 
+	if (need_flush) {
+		need_flush = 0;
+		tlb_flush_mmu(tlb);
+		if (addr != end)
+			goto again;
+	}
+
 	return addr;
 }
 
Index: linux-2.6/arch/arm/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/arm/include/asm/tlb.h
+++ linux-2.6/arch/arm/include/asm/tlb.h
@@ -93,7 +93,22 @@ tlb_end_vma(struct mmu_gather *tlb, stru
 		flush_tlb_range(vma, tlb->range_start, tlb->range_end);
 }
 
-#define tlb_remove_page(tlb,page)	free_page_and_swap_cache(page)
+static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+{
+	free_page_and_swap_cache(page);
+	return 0;
+}
+
+static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+{
+	might_sleep();
+	__tlb_remove_page(tlb, page);
+}
+
+static inline void tlb_flush_mmu(struct mmu_gather *tlb)
+{
+}
+
 #define pte_free_tlb(tlb, ptep, addr)	pte_free((tlb)->mm, ptep)
 #define pmd_free_tlb(tlb, pmdp, addr)	pmd_free((tlb)->mm, pmdp)
 
Index: linux-2.6/arch/ia64/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/ia64/include/asm/tlb.h
+++ linux-2.6/arch/ia64/include/asm/tlb.h
@@ -204,14 +204,13 @@ tlb_finish_mmu(struct mmu_gather *tlb, u
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
+		return 0;
 	}
 
 	if (!tlb->nr && tlb->pages == tlb->local)
@@ -219,7 +218,22 @@ tlb_remove_page (struct mmu_gather *tlb,
 
 	tlb->pages[tlb->nr++] = page;
 	if (tlb->nr >= tlb->max)
-		ia64_tlb_flush_mmu(tlb, tlb->start_addr, tlb->end_addr);
+		return 1;
+
+	return 0;
+}
+
+static inline void tlb_flush_mmu(struct mmu_gather *tlb)
+{
+	ia64_tlb_flush_mmu(tlb, tlb->start_addr, tlb->end_addr);
+}
+
+static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+{
+	might_sleep();
+
+	if (__tlb_remove_page(tlb, page))
+		tlb_flush_mmu(tlb);
 }
 
 /*
Index: linux-2.6/arch/s390/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/s390/include/asm/tlb.h
+++ linux-2.6/arch/s390/include/asm/tlb.h
@@ -64,8 +64,7 @@ static inline void tlb_gather_mmu(struct
 	tlb->nr_pxds = tlb->max;
 }
 
-static inline void tlb_flush_mmu(struct mmu_gather *tlb,
-				 unsigned long start, unsigned long end)
+static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 {
 	if (!tlb->fullmm && (tlb->nr_ptes > 0 || tlb->nr_pxds < tlb->max))
 		__tlb_flush_mm(tlb->mm);
@@ -78,7 +77,7 @@ static inline void tlb_flush_mmu(struct 
 static inline void tlb_finish_mmu(struct mmu_gather *tlb,
 				  unsigned long start, unsigned long end)
 {
-	tlb_flush_mmu(tlb, start, end);
+	tlb_flush_mmu(tlb);
 
 	rcu_table_freelist_finish();
 
@@ -94,8 +93,15 @@ static inline void tlb_finish_mmu(struct
  * tlb_ptep_clear_flush. In both flush modes the tlb fo a page cache page
  * has already been freed, so just do free_page_and_swap_cache.
  */
+static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+{
+	free_page_and_swap_cache(page);
+	return 0;
+}
+
 static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
+	might_sleep();
 	free_page_and_swap_cache(page);
 }
 
@@ -109,7 +115,7 @@ static inline void pte_free_tlb(struct m
 	if (!tlb->fullmm) {
 		tlb->array[tlb->nr_ptes++] = pte;
 		if (tlb->nr_ptes >= tlb->nr_pxds)
-			tlb_flush_mmu(tlb, 0, 0);
+			tlb_flush_mmu(tlb);
 	} else
 		page_table_free(tlb->mm, (unsigned long *) pte);
 }
@@ -130,7 +136,7 @@ static inline void pmd_free_tlb(struct m
 	if (!tlb->fullmm) {
 		tlb->array[--tlb->nr_pxds] = pmd;
 		if (tlb->nr_ptes >= tlb->nr_pxds)
-			tlb_flush_mmu(tlb, 0, 0);
+			tlb_flush_mmu(tlb);
 	} else
 		crst_table_free(tlb->mm, (unsigned long *) pmd);
 #endif
@@ -152,7 +158,7 @@ static inline void pud_free_tlb(struct m
 	if (!tlb->fullmm) {
 		tlb->array[--tlb->nr_pxds] = pud;
 		if (tlb->nr_ptes >= tlb->nr_pxds)
-			tlb_flush_mmu(tlb, 0, 0);
+			tlb_flush_mmu(tlb);
 	} else
 		crst_table_free(tlb->mm, (unsigned long *) pud);
 #endif
Index: linux-2.6/arch/sh/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/sh/include/asm/tlb.h
+++ linux-2.6/arch/sh/include/asm/tlb.h
@@ -83,7 +83,22 @@ tlb_end_vma(struct mmu_gather *tlb, stru
 	}
 }
 
-#define tlb_remove_page(tlb,page)	free_page_and_swap_cache(page)
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
+	might_sleep();
+	__tlb_remove_page(tlb, page);
+}
+
 #define pte_free_tlb(tlb, ptep, addr)	pte_free((tlb)->mm, ptep)
 #define pmd_free_tlb(tlb, pmdp, addr)	pmd_free((tlb)->mm, pmdp)
 #define pud_free_tlb(tlb, pudp, addr)	pud_free((tlb)->mm, pudp)
Index: linux-2.6/arch/um/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/um/include/asm/tlb.h
+++ linux-2.6/arch/um/include/asm/tlb.h
@@ -57,7 +57,7 @@ extern void flush_tlb_mm_range(struct mm
 			       unsigned long end);
 
 static inline void
-tlb_flush_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
+tlb_flush_mmu(struct mmu_gather *tlb)
 {
 	if (!tlb->need_flush)
 		return;
@@ -73,7 +73,7 @@ tlb_flush_mmu(struct mmu_gather *tlb, un
 static inline void
 tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
-	tlb_flush_mmu(tlb, start, end);
+	tlb_flush_mmu(tlb);
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
@@ -84,11 +84,18 @@ tlb_finish_mmu(struct mmu_gather *tlb, u
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
+	might_sleep();
+
+	__tlb_remove_page(tlb, page);
 }
 
 /**


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
