Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 0D14E6B0072
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:41:46 -0400 (EDT)
Message-Id: <20120627212830.766804364@chello.nl>
Date: Wed, 27 Jun 2012 23:15:43 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 03/20] mm, tlb: Remove a few #ifdefs
References: <20120627211540.459910855@chello.nl>
Content-Disposition: inline; filename=mm-cleanup-generic-rcu-ifdeffery.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>


Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/asm-generic/tlb.h |   85 ++++++++++++++++++++++++++--------------------
 mm/memory.c               |    6 ---
 2 files changed, 50 insertions(+), 41 deletions(-)
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -21,6 +21,40 @@
 
 static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page);
 
+/*
+ * If we can't allocate a page to make a big batch of page pointers
+ * to work on, then just handle a few from the on-stack structure.
+ */
+#define MMU_GATHER_BUNDLE	8
+
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
+/* struct mmu_gather is an opaque type used by the mm code for passing around
+ * any data needed by arch specific code for tlb_remove_page.
+ */
+struct mmu_gather {
+	struct mm_struct	*mm;
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+	struct mmu_table_batch	*batch;
+#endif
+	unsigned int		need_flush : 1,	/* Did free PTEs */
+				fast_mode  : 1; /* No batching   */
+
+	unsigned int		fullmm;
+
+	struct mmu_gather_batch *active;
+	struct mmu_gather_batch	local;
+	struct page		*__pages[MMU_GATHER_BUNDLE];
+};
+
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 /*
  * Semi RCU freeing of the page directories.
@@ -59,51 +93,30 @@ struct mmu_table_batch {
 #define MAX_TABLE_BATCH		\
 	((PAGE_SIZE - sizeof(struct mmu_table_batch)) / sizeof(void *))
 
+static inline void tlb_table_init(struct mmu_gather *tlb)
+{
+	tlb->batch = NULL;
+}
+
 extern void tlb_table_flush(struct mmu_gather *tlb);
 extern void tlb_remove_table(struct mmu_gather *tlb, void *table);
 
-#else
+#else /* CONFIG_HAVE_RCU_TABLE_FREE */
 
-static inline void tlb_remove_table(struct mmu_gather *tlb, void *table)
+static inline void tlb_table_init(struct mmu_gather *tlb)
 {
-	tlb_remove_page(tlb, table);
 }
 
-#endif
-
-/*
- * If we can't allocate a page to make a big batch of page pointers
- * to work on, then just handle a few from the on-stack structure.
- */
-#define MMU_GATHER_BUNDLE	8
-
-struct mmu_gather_batch {
-	struct mmu_gather_batch	*next;
-	unsigned int		nr;
-	unsigned int		max;
-	struct page		*pages[0];
-};
-
-#define MAX_GATHER_BATCH	\
-	((PAGE_SIZE - sizeof(struct mmu_gather_batch)) / sizeof(void *))
-
-/* struct mmu_gather is an opaque type used by the mm code for passing around
- * any data needed by arch specific code for tlb_remove_page.
- */
-struct mmu_gather {
-	struct mm_struct	*mm;
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-	struct mmu_table_batch	*batch;
-#endif
-	unsigned int		need_flush : 1,	/* Did free PTEs */
-				fast_mode  : 1; /* No batching   */
+static inline void tlb_table_flush(struct mmu_gather *tlb)
+{
+}
 
-	unsigned int		fullmm;
+static inline void tlb_remove_table(struct mmu_gather *tlb, void *table)
+{
+	tlb_remove_page(tlb, table);
+}
 
-	struct mmu_gather_batch *active;
-	struct mmu_gather_batch	local;
-	struct page		*__pages[MMU_GATHER_BUNDLE];
-};
+#endif /* CONFIG_HAVE_RCU_TABLE_FREE */
 
 #define HAVE_GENERIC_MMU_GATHER
 
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -214,9 +214,7 @@ void tlb_gather_mmu(struct mmu_gather *t
 	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
 	tlb->active     = &tlb->local;
 
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-	tlb->batch = NULL;
-#endif
+	tlb_table_init(tlb);
 }
 
 void tlb_flush_mmu(struct mmu_gather *tlb)
@@ -227,9 +225,7 @@ void tlb_flush_mmu(struct mmu_gather *tl
 		return;
 	tlb->need_flush = 0;
 	tlb_flush(tlb);
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb_table_flush(tlb);
-#endif
 
 	if (tlb_fast_mode(tlb))
 		return;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
