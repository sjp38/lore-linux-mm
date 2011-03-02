Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E121A8D0042
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 12:54:36 -0500 (EST)
Message-Id: <20110302175201.185727583@chello.nl>
Date: Wed, 02 Mar 2011 18:50:17 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 13/13] mm: Extended batches for generic mmu_gather
References: <20110302175004.222724818@chello.nl>
Content-Disposition: inline; filename=peter_zijlstra-mm-extended_batches_for_generic_mmu_gather.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Hugh Dickins <hughd@google.com>

Instead of using a single batch (the small on-stack, or an allocated
page), try and extend the batch every time it runs out and only flush
once either the extend fails or we're done.

Requested-by: Nick Piggin <npiggin@suse.de>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/asm-generic/tlb.h |  121 ++++++++++++++++++++++++++++++----------------
 1 file changed, 80 insertions(+), 41 deletions(-)

Index: linux-2.6/include/asm-generic/tlb.h
===================================================================
--- linux-2.6.orig/include/asm-generic/tlb.h
+++ linux-2.6/include/asm-generic/tlb.h
@@ -19,16 +19,6 @@
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 
-/*
- * For UP we don't need to worry about TLB flush
- * and page free order so much..
- */
-#ifdef CONFIG_SMP
-  #define tlb_fast_mode(tlb) ((tlb)->nr == ~0U)
-#else
-  #define tlb_fast_mode(tlb) 1
-#endif
-
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 /*
  * Semi RCU freeing of the page directories.
@@ -78,6 +68,16 @@ extern void tlb_remove_table(struct mmu_
  */
 #define MMU_GATHER_BUNDLE	8
 
+struct mmu_gather_batch {
+	struct mmu_gather_batch	*next;
+	unsigned int		nr;
+	unsigned int		max;
+	struct page		*pages[0];
+};
+
+#define MAX_GATHER_BATCH	\
+	((PAGE_SIZE - sizeof(struct mmu_gather_batch)) / sizeof(void *))
+
 /* struct mmu_gather is an opaque type used by the mm code for passing around
  * any data needed by arch specific code for tlb_remove_page.
  */
@@ -86,22 +86,48 @@ struct mmu_gather {
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	struct mmu_table_batch	*batch;
 #endif
-	unsigned int		nr;	/* set to ~0U means fast mode */
-	unsigned int		max;	/* nr < max */
-	unsigned int		need_flush;/* Really unmapped some ptes? */
-	unsigned int		fullmm; /* non-zero means full mm flush */
-	struct page		**pages;
-	struct page		*local[MMU_GATHER_BUNDLE];
+	unsigned int		need_flush : 1,	/* Did free PTEs */
+				fast_mode  : 1; /* No batching   */
+
+	unsigned int		fullmm;
+
+	struct mmu_gather_batch *active;
+	struct mmu_gather_batch	local;
+	struct page		*__pages[MMU_GATHER_BUNDLE];
 };
 
-static inline void __tlb_alloc_page(struct mmu_gather *tlb)
+/*
+ * For UP we don't need to worry about TLB flush
+ * and page free order so much..
+ */
+#ifdef CONFIG_SMP
+  #define tlb_fast_mode(tlb) (tlb->fast_mode)
+#else
+  #define tlb_fast_mode(tlb) 1
+#endif
+
+static inline int tlb_next_batch(struct mmu_gather *tlb)
 {
-	unsigned long addr = __get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
+	struct mmu_gather_batch *batch;
 
-	if (addr) {
-		tlb->pages = (void *)addr;
-		tlb->max = PAGE_SIZE / sizeof(struct page *);
+	batch = tlb->active;
+	if (batch->next) {
+		tlb->active = batch->next;
+		return 1;
 	}
+
+	batch = (void *)__get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
+	if (!batch)
+		return 0;
+
+	batch->next = NULL;
+	batch->nr   = 0;
+	batch->max  = MAX_GATHER_BATCH;
+
+	tlb->active->next = batch;
+	tlb->active = batch;
+
+	return 1;
 }
 
 /* tlb_gather_mmu
@@ -112,16 +138,13 @@ tlb_gather_mmu(struct mmu_gather *tlb, s
 {
 	tlb->mm = mm;
 
-	tlb->max = ARRAY_SIZE(tlb->local);
-	tlb->pages = tlb->local;
-
-	if (num_online_cpus() > 1) {
-		tlb->nr = 0;
-		__tlb_alloc_page(tlb);
-	} else /* Use fast mode if only one CPU is online */
-		tlb->nr = ~0U;
-
-	tlb->fullmm = fullmm;
+	tlb->fullmm     = fullmm;
+	tlb->need_flush = 0;
+	tlb->fast_mode  = (num_possible_cpus() == 1);
+	tlb->local.next = NULL;
+	tlb->local.nr   = 0;
+	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
+	tlb->active     = &tlb->local;
 
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb->batch = NULL;
@@ -131,6 +154,8 @@ tlb_gather_mmu(struct mmu_gather *tlb, s
 static inline void
 tlb_flush_mmu(struct mmu_gather *tlb)
 {
+	struct mmu_gather_batch *batch;
+
 	if (!tlb->need_flush)
 		return;
 	tlb->need_flush = 0;
@@ -138,12 +163,14 @@ tlb_flush_mmu(struct mmu_gather *tlb)
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb_table_flush(tlb);
 #endif
-	if (!tlb_fast_mode(tlb)) {
-		free_pages_and_swap_cache(tlb->pages, tlb->nr);
-		tlb->nr = 0;
-		if (tlb->pages == tlb->local)
-			__tlb_alloc_page(tlb);
+	if (tlb_fast_mode(tlb))
+		return;
+
+	for (batch = &tlb->local; batch; batch = batch->next) {
+		free_pages_and_swap_cache(batch->pages, batch->nr);
+		batch->nr = 0;
 	}
+	tlb->active = &tlb->local;
 }
 
 /* tlb_finish_mmu
@@ -153,13 +180,18 @@ tlb_flush_mmu(struct mmu_gather *tlb)
 static inline void
 tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
+	struct mmu_gather_batch *batch, *next;
+
 	tlb_flush_mmu(tlb);
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
 
-	if (tlb->pages != tlb->local)
-		free_pages((unsigned long)tlb->pages, 0);
+	for (batch = tlb->local.next; batch; batch = next) {
+		next = batch->next;
+		free_pages((unsigned long)batch, 0);
+	}
+	tlb->local.next = NULL;
 }
 
 /* tlb_remove_page
@@ -169,14 +201,21 @@ tlb_finish_mmu(struct mmu_gather *tlb, u
  */
 static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
+	struct mmu_gather_batch *batch;
+
 	tlb->need_flush = 1;
+
 	if (tlb_fast_mode(tlb)) {
 		free_page_and_swap_cache(page);
 		return 0;
 	}
-	tlb->pages[tlb->nr++] = page;
-	if (tlb->nr >= tlb->max)
-		return 1;
+
+	batch = tlb->active;
+	batch->pages[batch->nr++] = page;
+	if (batch->nr == batch->max) {
+		if (!tlb_next_batch(tlb))
+			return 1;
+	}
 
 	return 0;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
