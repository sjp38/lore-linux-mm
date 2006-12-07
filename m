Message-Id: <20061207162735.576346000@chello.nl>
References: <20061207161800.426936000@chello.nl>
Date: Thu, 07 Dec 2006 17:18:08 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 08/16] mm: speculative page get for PREEMPT_RT
Content-Disposition: inline; filename=mm-lockless-preempt-rt-fixup.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Since most of the locks are sleeping locks with PREEMPT_RT provide
a sleeping implementation of wait_on_new_refs(). This also solves
the preempt livelock and thus we can remove the preempt_disable()/
preempt_enable() from the PG_nonewrefs functions.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/pagemap.h |   51 +++++++++++++++++++++++++++++++++++++++++++++++-
 mm/filemap.c            |   17 ++--------------
 2 files changed, 53 insertions(+), 15 deletions(-)

Index: linux-2.6-rt/include/linux/pagemap.h
===================================================================
--- linux-2.6-rt.orig/include/linux/pagemap.h	2006-11-29 14:20:55.000000000 +0100
+++ linux-2.6-rt/include/linux/pagemap.h	2006-11-29 14:20:58.000000000 +0100
@@ -13,6 +13,8 @@
 #include <linux/gfp.h>
 #include <linux/page-flags.h>
 #include <linux/hardirq.h> /* for in_interrupt() */
+#include <linux/wait.h>
+#include <linux/hash.h>
 
 /*
  * Bits in mapping->flags.  The lower __GFP_BITS_SHIFT bits are the page
@@ -53,6 +55,26 @@ static inline void mapping_set_gfp_mask(
 #define page_cache_release(page)	put_page(page)
 void release_pages(struct page **pages, int nr, int cold);
 
+/*
+ * In order to wait for pages to become available there must be
+ * waitqueues associated with pages. By using a hash table of
+ * waitqueues where the bucket discipline is to maintain all
+ * waiters on the same queue and wake all when any of the pages
+ * become available, and for the woken contexts to check to be
+ * sure the appropriate page became available, this saves space
+ * at a cost of "thundering herd" phenomena during rare hash
+ * collisions.
+ */
+static inline wait_queue_head_t *page_waitqueue(struct page *page)
+{
+	const struct zone *zone = page_zone(page);
+
+	return &zone->wait_table[hash_ptr(page, zone->wait_table_bits)];
+}
+
+extern int __sleep_on_page(void *);
+
+#ifndef CONFIG_PREEMPT_RT
 static inline void set_page_no_new_refs(struct page *page)
 {
 	VM_BUG_ON(PageNoNewRefs(page));
@@ -74,6 +96,33 @@ static inline void wait_on_new_refs(stru
 	while (unlikely(PageNoNewRefs(page)))
 		cpu_relax();
 }
+#else
+static inline void set_page_no_new_refs(struct page *page)
+{
+	VM_BUG_ON(PageNoNewRefs(page));
+	SetPageNoNewRefs(page);
+	smp_wmb();
+}
+
+static inline void end_page_no_new_refs(struct page *page)
+{
+	VM_BUG_ON(!PageNoNewRefs(page));
+	smp_wmb();
+	ClearPageNoNewRefs(page);
+	smp_mb__after_clear_bit();
+	__wake_up_bit(page_waitqueue(page), &page->flags, PG_nonewrefs);
+}
+
+static inline void wait_on_new_refs(struct page *page)
+{
+	might_sleep();
+	if (unlikely(PageNoNewRefs(page))) {
+		DEFINE_WAIT_BIT(wait, &page->flags, PG_nonewrefs);
+		__wait_on_bit(page_waitqueue(page), &wait, __sleep_on_page,
+				TASK_UNINTERRUPTIBLE);
+	}
+}
+#endif
 
 /*
  * speculatively take a reference to a page.
@@ -124,7 +173,7 @@ static inline int page_cache_get_specula
 {
 	VM_BUG_ON(in_interrupt());
 
-#ifndef CONFIG_SMP
+#if !defined(CONFIG_SMP) && !defined(CONFIG_PREEMPT_RT)
 # ifdef CONFIG_PREEMPT
 	VM_BUG_ON(!in_atomic());
 # endif
Index: linux-2.6-rt/mm/filemap.c
===================================================================
--- linux-2.6-rt.orig/mm/filemap.c	2006-11-29 14:20:55.000000000 +0100
+++ linux-2.6-rt/mm/filemap.c	2006-11-29 14:20:58.000000000 +0100
@@ -486,21 +486,10 @@ static int __sleep_on_page_lock(void *wo
 	return 0;
 }
 
-/*
- * In order to wait for pages to become available there must be
- * waitqueues associated with pages. By using a hash table of
- * waitqueues where the bucket discipline is to maintain all
- * waiters on the same queue and wake all when any of the pages
- * become available, and for the woken contexts to check to be
- * sure the appropriate page became available, this saves space
- * at a cost of "thundering herd" phenomena during rare hash
- * collisions.
- */
-static wait_queue_head_t *page_waitqueue(struct page *page)
+int __sleep_on_page(void *word)
 {
-	const struct zone *zone = page_zone(page);
-
-	return &zone->wait_table[hash_ptr(page, zone->wait_table_bits)];
+	schedule();
+	return 0;
 }
 
 static inline void wake_up_page(struct page *page, int bit)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
