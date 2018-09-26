Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id B9E2A8E000F
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 07:55:13 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id s5-v6so52117825iop.3
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 04:55:13 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id b6-v6si2349054jam.65.2018.09.26.04.55.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 26 Sep 2018 04:55:12 -0700 (PDT)
Message-ID: <20180926114801.314124744@infradead.org>
Date: Wed, 26 Sep 2018 13:36:38 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 15/18] asm-generic/tlb: Remove arch_tlb*_mmu()
References: <20180926113623.863696043@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, peterz@infradead.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, riel@surriel.com

Now that all architectures are converted to the generic code, remove
the arch hooks.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 mm/mmu_gather.c |   93 +++++++++++++++++++++++++-------------------------------
 1 file changed, 42 insertions(+), 51 deletions(-)

--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -93,33 +93,6 @@ bool __tlb_remove_page_size(struct mmu_g
 
 #endif /* HAVE_MMU_GATHER_NO_GATHER */
 
-void arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-				unsigned long start, unsigned long end)
-{
-	tlb->mm = mm;
-
-	/* Is it from 0 to ~0? */
-	tlb->fullmm     = !(start | (end+1));
-
-#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
-	tlb->need_flush_all = 0;
-	tlb->local.next = NULL;
-	tlb->local.nr   = 0;
-	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
-	tlb->active     = &tlb->local;
-	tlb->batch_count = 0;
-#endif
-
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-	tlb->batch = NULL;
-#endif
-#ifdef CONFIG_HAVE_MMU_GATHER_PAGE_SIZE
-	tlb->page_size = 0;
-#endif
-
-	__tlb_reset_range(tlb);
-}
-
 void tlb_flush_mmu_free(struct mmu_gather *tlb)
 {
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
@@ -136,27 +109,6 @@ void tlb_flush_mmu(struct mmu_gather *tl
 	tlb_flush_mmu_free(tlb);
 }
 
-/* tlb_finish_mmu
- *	Called at the end of the shootdown operation to free up any resources
- *	that were required.
- */
-void arch_tlb_finish_mmu(struct mmu_gather *tlb,
-		unsigned long start, unsigned long end, bool force)
-{
-	if (force) {
-		__tlb_reset_range(tlb);
-		__tlb_adjust_range(tlb, start, end - start);
-	}
-
-	tlb_flush_mmu(tlb);
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
-	tlb_batch_list_free(tlb);
-#endif
-}
-
 #endif /* HAVE_GENERIC_MMU_GATHER */
 
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
@@ -258,10 +210,40 @@ void tlb_remove_table(struct mmu_gather
 void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
 			unsigned long start, unsigned long end)
 {
-	arch_tlb_gather_mmu(tlb, mm, start, end);
+	tlb->mm = mm;
+
+	/* Is it from 0 to ~0? */
+	tlb->fullmm     = !(start | (end+1));
+
+#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
+	tlb->need_flush_all = 0;
+	tlb->local.next = NULL;
+	tlb->local.nr   = 0;
+	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
+	tlb->active     = &tlb->local;
+	tlb->batch_count = 0;
+#endif
+
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+	tlb->batch = NULL;
+#endif
+#ifdef CONFIG_HAVE_MMU_GATHER_PAGE_SIZE
+	tlb->page_size = 0;
+#endif
+
+	__tlb_reset_range(tlb);
 	inc_tlb_flush_pending(tlb->mm);
 }
 
+/**
+ * tlb_finish_mmu - finish an mmu_gather structure
+ * @tlb: the mmu_gather structure to finish
+ * @start: start of the region that will be removed from the page-table
+ * @end: end of the region that will be removed from the page-table
+ *
+ * Called at the end of the shootdown operation to free up any resources that
+ * were required.
+ */
 void tlb_finish_mmu(struct mmu_gather *tlb,
 		unsigned long start, unsigned long end)
 {
@@ -272,8 +254,17 @@ void tlb_finish_mmu(struct mmu_gather *t
 	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
 	 * forcefully if we detect parallel PTE batching threads.
 	 */
-	bool force = mm_tlb_flush_nested(tlb->mm);
+	if (mm_tlb_flush_nested(tlb->mm)) {
+		__tlb_reset_range(tlb);
+		__tlb_adjust_range(tlb, start, end - start);
+	}
 
-	arch_tlb_finish_mmu(tlb, start, end, force);
+	tlb_flush_mmu(tlb);
+
+	/* keep the page table cache within bounds */
+	check_pgt_cache();
+#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
+	tlb_batch_list_free(tlb);
+#endif
 	dec_tlb_flush_pending(tlb->mm);
 }
