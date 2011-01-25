Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5E5976B00F9
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 12:59:23 -0500 (EST)
Message-Id: <20110125174907.993380420@chello.nl>
Date: Tue, 25 Jan 2011 18:31:26 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 15/25] mm: Extended batches for generic mmu_gather
References: <20110125173111.720927511@chello.nl>
Content-Disposition: inline; filename=peter_zijlstra-mm-extended_batches_for_generic_mmu_gather.patch
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

Instead of using a single batch (the small on-stack, or an allocated
page), try and extend the batch every time it runs out and only flush
once either the extend fails or we're done.

Requested-by: Nick Piggin <npiggin@suse.de>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/asm-generic/tlb.h |  122 ++++++++++++++++++++++++++++++----------------
 1 file changed, 82 insertions(+), 40 deletions(-)

Index: linux-2.6/include/asm-generic/tlb.h
===================================================================
--- linux-2.6.orig/include/asm-generic/tlb.h
+++ linux-2.6/include/asm-generic/tlb.h
@@ -17,16 +17,6 @@
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
@@ -70,31 +60,66 @@ extern void tlb_remove_table(struct mmu_
 
 #endif
 
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
 struct mmu_gather {
 	struct mm_struct	*mm;
-	unsigned int		nr;	/* set to ~0U means fast mode */
-	unsigned int		max;	/* nr < max */
-	unsigned int		need_flush;/* Really unmapped some ptes? */
-	unsigned int		fullmm; /* non-zero means full mm flush */
-	struct page		**pages;
-	struct page		*local[8];
+	unsigned int		need_flush : 1,	/* Did free PTEs */
+				fast_mode  : 1; /* No batching   */
+	unsigned int		fullmm;		/* Flush full mm */
+
+	struct mmu_gather_batch *active;
+	struct mmu_gather_batch	local;
+	struct page		*__pages[8];
 
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	struct mmu_table_batch	*batch;
 #endif
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
@@ -105,17 +130,16 @@ tlb_gather_mmu(struct mmu_gather *tlb, s
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
+	tlb->need_flush = 0;
+	if (num_online_cpus() == 1)
+		tlb->fast_mode = 1;
 	tlb->fullmm = full_mm_flush;
 
+	tlb->local.next = NULL;
+	tlb->local.nr   = 0;
+	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
+	tlb->active     = &tlb->local;
+
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb->batch = NULL;
 #endif
@@ -124,6 +148,8 @@ tlb_gather_mmu(struct mmu_gather *tlb, s
 static inline void
 tlb_flush_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
+	struct mmu_gather_batch *batch;
+
 	if (!tlb->need_flush)
 		return;
 	tlb->need_flush = 0;
@@ -131,12 +157,14 @@ tlb_flush_mmu(struct mmu_gather *tlb, un
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
@@ -146,13 +174,18 @@ tlb_flush_mmu(struct mmu_gather *tlb, un
 static inline void
 tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
+	struct mmu_gather_batch *batch, *next;
+
 	tlb_flush_mmu(tlb, start, end);
 
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
@@ -162,14 +195,23 @@ tlb_finish_mmu(struct mmu_gather *tlb, u
  */
 static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
+	struct mmu_gather_batch *batch;
+
 	tlb->need_flush = 1;
+
 	if (tlb_fast_mode(tlb)) {
 		free_page_and_swap_cache(page);
 		return;
 	}
-	tlb->pages[tlb->nr++] = page;
-	if (tlb->nr >= tlb->max)
-		tlb_flush_mmu(tlb, 0, 0);
+
+	batch = tlb->active;
+	if (batch->nr == batch->max) {
+		if (!tlb_next_batch(tlb))
+			tlb_flush_mmu(tlb, 0, 0);
+		batch = tlb->active;
+	}
+
+	batch->pages[batch->nr++] = page;
 }
 
 /**


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
