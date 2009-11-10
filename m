Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C38616B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 17:14:47 -0500 (EST)
Subject: Re: [PATCH 5/6] mm: stop ptlock enlarging struct page
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <Pine.LNX.4.64.0911102200480.2816@sister.anvils>
References: <Pine.LNX.4.64.0911102142570.2272@sister.anvils>
	 <Pine.LNX.4.64.0911102200480.2816@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 10 Nov 2009 23:14:37 +0100
Message-ID: <1257891277.4108.498.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


fwiw, in -rt we carry this, because there spinlock_t is huge even
without lockdep.


---
commit 27909c87933670deead6ab74274cf61ebffad5ac
Author: Peter Zijlstra <peterz@infradead.org>
Date:   Fri Jul 3 08:44:54 2009 -0500

    mm: shrink the page frame to !-rt size
    
    He below is a boot-tested hack to shrink the page frame size back to
    normal.
    
    Should be a net win since there should be many less PTE-pages than
    page-frames.
    
    Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
    Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

diff --git a/include/linux/mm.h b/include/linux/mm.h
index e52dfbb..fb2a7e9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -938,27 +938,85 @@ static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long a
  * overflow into the next struct page (as it might with DEBUG_SPINLOCK).
  * When freeing, reset page->mapping so free_pages_check won't complain.
  */
+#ifndef CONFIG_PREEMPT_RT
+
 #define __pte_lockptr(page)	&((page)->ptl)
-#define pte_lock_init(_page)	do {					\
-	spin_lock_init(__pte_lockptr(_page));				\
-} while (0)
+
+static inline struct page *pte_lock_init(struct page *page)
+{
+	spin_lock_init(__pte_lockptr(page));
+	return page;
+}
+
 #define pte_lock_deinit(page)	((page)->mapping = NULL)
+
+#else /* PREEMPT_RT */
+
+/*
+ * On PREEMPT_RT the spinlock_t's are too large to embed in the
+ * page frame, hence it only has a pointer and we need to dynamically
+ * allocate the lock when we allocate PTE-pages.
+ *
+ * This is an overall win, since only a small fraction of the pages
+ * will be PTE pages under normal circumstances.
+ */
+
+#define __pte_lockptr(page)	((page)->ptl)
+
+/*
+ * Heinous hack, relies on the caller doing something like:
+ *
+ *   pte = alloc_pages(PGALLOC_GFP, 0);
+ *   if (pte)
+ *     pgtable_page_ctor(pte);
+ *   return pte;
+ *
+ * This ensures we release the page and return NULL when the
+ * lock allocation fails.
+ */
+static inline struct page *pte_lock_init(struct page *page)
+{
+	page->ptl = kmalloc(sizeof(spinlock_t), GFP_KERNEL);
+	if (page->ptl) {
+		spin_lock_init(__pte_lockptr(page));
+	} else {
+		__free_page(page);
+		page = NULL;
+	}
+	return page;
+}
+
+static inline void pte_lock_deinit(struct page *page)
+{
+	kfree(page->ptl);
+	page->mapping = NULL;
+}
+
+#endif /* PREEMPT_RT */
+
 #define pte_lockptr(mm, pmd)	({(void)(mm); __pte_lockptr(pmd_page(*(pmd)));})
 #else	/* !USE_SPLIT_PTLOCKS */
 /*
  * We use mm->page_table_lock to guard all pagetable pages of the mm.
  */
-#define pte_lock_init(page)	do {} while (0)
+static inline struct page *pte_lock_init(struct page *page) { return page; }
 #define pte_lock_deinit(page)	do {} while (0)
 #define pte_lockptr(mm, pmd)	({(void)(pmd); &(mm)->page_table_lock;})
 #endif /* USE_SPLIT_PTLOCKS */
 
-static inline void pgtable_page_ctor(struct page *page)
+static inline struct page *__pgtable_page_ctor(struct page *page)
 {
-	pte_lock_init(page);
-	inc_zone_page_state(page, NR_PAGETABLE);
+	page = pte_lock_init(page);
+	if (page)
+		inc_zone_page_state(page, NR_PAGETABLE);
+	return page;
 }
 
+#define pgtable_page_ctor(page)				\
+do {							\
+	page = __pgtable_page_ctor(page);		\
+} while (0)
+
 static inline void pgtable_page_dtor(struct page *page)
 {
 	pte_lock_deinit(page);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index bd79936..2b208da 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -69,7 +69,11 @@ struct page {
 						 */
 	    };
 #if USE_SPLIT_PTLOCKS
+#ifndef CONFIG_PREEMPT_RT
 	    spinlock_t ptl;
+#else
+	    spinlock_t *ptl;
+#endif
 #endif
 	    struct kmem_cache *slab;	/* SLUB: Pointer to slab */
 	    struct page *first_page;	/* Compound tail pages */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
