Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 56E708E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 08:52:04 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id y135-v6so1579345oie.11
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 05:52:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c20-v6si5914090otl.156.2018.09.18.05.52.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Sep 2018 05:52:02 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8ICnZXq043427
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 08:52:01 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mk14uhq2c-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 08:52:01 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Tue, 18 Sep 2018 13:51:59 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH 1/2] asm-generic/tlb: introduce HAVE_MMU_GATHER_NO_GATHER
Date: Tue, 18 Sep 2018 14:51:50 +0200
In-Reply-To: <20180918125151.31744-1-schwidefsky@de.ibm.com>
References: <20180918125151.31744-1-schwidefsky@de.ibm.com>
Message-Id: <20180918125151.31744-2-schwidefsky@de.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, Linus Torvalds <torvalds@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>

Add the Kconfig option HAVE_MMU_GATHER_NO_GATHER to the generic
mmu_gather code. If the option is set the mmu_gather will not
track individual pages for delayed page free anymore. A platform
that enables the option needs to provide its own implementation
of the __tlb_remove_page_size function to free pages.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/Kconfig              |   3 ++
 include/asm-generic/tlb.h |   9 +++-
 mm/mmu_gather.c           | 114 +++++++++++++++++++++++++++-------------------
 3 files changed, 77 insertions(+), 49 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 053c44703539..edb338b66f16 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -368,6 +368,9 @@ config HAVE_RCU_TABLE_INVALIDATE
 config HAVE_MMU_GATHER_PAGE_SIZE
 	bool
 
+config HAVE_MMU_GATHER_NO_GATHER
+	bool
+
 config ARCH_HAVE_NMI_SAFE_CMPXCHG
 	bool
 
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index 21c751cd751e..9e714e1b6695 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -179,6 +179,7 @@ extern void tlb_remove_table(struct mmu_gather *tlb, void *table);
 
 #endif
 
+#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
 /*
  * If we can't allocate a page to make a big batch of page pointers
  * to work on, then just handle a few from the on-stack structure.
@@ -203,6 +204,10 @@ struct mmu_gather_batch {
  */
 #define MAX_GATHER_BATCH_COUNT	(10000UL/MAX_GATHER_BATCH)
 
+extern bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page,
+				   int page_size);
+#endif
+
 /*
  * struct mmu_gather is an opaque type used by the mm code for passing around
  * any data needed by arch specific code for tlb_remove_page.
@@ -249,6 +254,7 @@ struct mmu_gather {
 
 	unsigned int		batch_count;
 
+#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
 	struct mmu_gather_batch *active;
 	struct mmu_gather_batch	local;
 	struct page		*__pages[MMU_GATHER_BUNDLE];
@@ -256,6 +262,7 @@ struct mmu_gather {
 #ifdef CONFIG_HAVE_MMU_GATHER_PAGE_SIZE
 	unsigned int page_size;
 #endif
+#endif
 };
 
 void arch_tlb_gather_mmu(struct mmu_gather *tlb,
@@ -264,8 +271,6 @@ void tlb_flush_mmu(struct mmu_gather *tlb);
 void arch_tlb_finish_mmu(struct mmu_gather *tlb,
 			 unsigned long start, unsigned long end, bool force);
 void tlb_flush_mmu_free(struct mmu_gather *tlb);
-extern bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page,
-				   int page_size);
 
 static inline void __tlb_adjust_range(struct mmu_gather *tlb,
 				      unsigned long address,
diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
index 2d5e617131f6..6d5d812a040b 100644
--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -13,6 +13,8 @@
 
 #ifdef HAVE_GENERIC_MMU_GATHER
 
+#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
+
 static bool tlb_next_batch(struct mmu_gather *tlb)
 {
 	struct mmu_gather_batch *batch;
@@ -41,6 +43,63 @@ static bool tlb_next_batch(struct mmu_gather *tlb)
 	return true;
 }
 
+static void tlb_batch_pages_flush(struct mmu_gather *tlb)
+{
+	struct mmu_gather_batch *batch;
+
+	for (batch = &tlb->local; batch && batch->nr; batch = batch->next) {
+		free_pages_and_swap_cache(batch->pages, batch->nr);
+		batch->nr = 0;
+	}
+	tlb->active = &tlb->local;
+}
+
+static void tlb_batch_list_free(struct mmu_gather *tlb)
+{
+	struct mmu_gather_batch *batch, *next;
+
+	for (batch = tlb->local.next; batch; batch = next) {
+		next = batch->next;
+		free_pages((unsigned long)batch, 0);
+	}
+	tlb->local.next = NULL;
+}
+
+/* __tlb_remove_page
+ *	Must perform the equivalent to __free_pte(pte_get_and_clear(ptep)), while
+ *	handling the additional races in SMP caused by other CPUs caching valid
+ *	mappings in their TLBs. Returns the number of free page slots left.
+ *	When out of page slots we must call tlb_flush_mmu().
+ *returns true if the caller should flush.
+ */
+bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page, int page_size)
+{
+	struct mmu_gather_batch *batch;
+
+	VM_BUG_ON(!tlb->end);
+
+#ifdef CONFIG_HAVE_MMU_GATHER_PAGE_SIZE
+	VM_WARN_ON(tlb->page_size != page_size);
+#endif
+
+	batch = tlb->active;
+	/*
+	 * Add the page and check if we are full. If so
+	 * force a flush.
+	 */
+	batch->pages[batch->nr++] = page;
+	if (batch->nr == batch->max) {
+		if (!tlb_next_batch(tlb))
+			return true;
+		batch = tlb->active;
+	}
+	VM_BUG_ON_PAGE(batch->nr > batch->max, page);
+
+	return false;
+}
+
+#endif
+
 void arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
 				unsigned long start, unsigned long end)
 {
@@ -48,12 +107,15 @@ void arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
 
 	/* Is it from 0 to ~0? */
 	tlb->fullmm     = !(start | (end+1));
+
+#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
 	tlb->need_flush_all = 0;
 	tlb->local.next = NULL;
 	tlb->local.nr   = 0;
 	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
 	tlb->active     = &tlb->local;
 	tlb->batch_count = 0;
+#endif
 
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb->batch = NULL;
@@ -67,16 +129,12 @@ void arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
 
 void tlb_flush_mmu_free(struct mmu_gather *tlb)
 {
-	struct mmu_gather_batch *batch;
-
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb_table_flush(tlb);
 #endif
-	for (batch = &tlb->local; batch && batch->nr; batch = batch->next) {
-		free_pages_and_swap_cache(batch->pages, batch->nr);
-		batch->nr = 0;
-	}
-	tlb->active = &tlb->local;
+#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
+	tlb_batch_pages_flush(tlb);
+#endif
 }
 
 void tlb_flush_mmu(struct mmu_gather *tlb)
@@ -92,8 +150,6 @@ void tlb_flush_mmu(struct mmu_gather *tlb)
 void arch_tlb_finish_mmu(struct mmu_gather *tlb,
 		unsigned long start, unsigned long end, bool force)
 {
-	struct mmu_gather_batch *batch, *next;
-
 	if (force) {
 		__tlb_reset_range(tlb);
 		__tlb_adjust_range(tlb, start, end - start);
@@ -103,45 +159,9 @@ void arch_tlb_finish_mmu(struct mmu_gather *tlb,
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
-
-	for (batch = tlb->local.next; batch; batch = next) {
-		next = batch->next;
-		free_pages((unsigned long)batch, 0);
-	}
-	tlb->local.next = NULL;
-}
-
-/* __tlb_remove_page
- *	Must perform the equivalent to __free_pte(pte_get_and_clear(ptep)), while
- *	handling the additional races in SMP caused by other CPUs caching valid
- *	mappings in their TLBs. Returns the number of free page slots left.
- *	When out of page slots we must call tlb_flush_mmu().
- *returns true if the caller should flush.
- */
-bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page, int page_size)
-{
-	struct mmu_gather_batch *batch;
-
-	VM_BUG_ON(!tlb->end);
-
-#ifdef CONFIG_HAVE_MMU_GATHER_PAGE_SIZE
-	VM_WARN_ON(tlb->page_size != page_size);
+#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
+	tlb_batch_list_free(tlb);
 #endif
-
-	batch = tlb->active;
-	/*
-	 * Add the page and check if we are full. If so
-	 * force a flush.
-	 */
-	batch->pages[batch->nr++] = page;
-	if (batch->nr == batch->max) {
-		if (!tlb_next_batch(tlb))
-			return true;
-		batch = tlb->active;
-	}
-	VM_BUG_ON_PAGE(batch->nr > batch->max, page);
-
-	return false;
 }
 
 #endif /* HAVE_GENERIC_MMU_GATHER */
-- 
2.16.4
