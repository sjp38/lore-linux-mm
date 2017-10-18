Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 59ADB6B025F
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 07:16:58 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v91so2266632wrc.11
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 04:16:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o111si9166795wrc.248.2017.10.18.04.16.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Oct 2017 04:16:56 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH] mm: Convert delete_from_page_cache_batch() to pagevec
Date: Wed, 18 Oct 2017 13:16:48 +0200
Message-Id: <20171018111648.13714-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/pagemap.h |  6 ++++--
 mm/filemap.c            | 43 +++++++++++++++++++++----------------------
 mm/truncate.c           | 18 +++++++++---------
 3 files changed, 34 insertions(+), 33 deletions(-)

This is a patch to use pagevec instead of page array - to be folded into the
last patch of my batched truncate series: "mm: Batch radix tree operations
when truncating pages". Thanks!

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e857c62aef06..280aabe3ab75 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -616,6 +616,8 @@ static inline int fault_in_pages_readable(const char __user *uaddr, int size)
 	return 0;
 }
 
+struct pagevec;
+
 int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
 int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
@@ -623,8 +625,8 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 extern void delete_from_page_cache(struct page *page);
 extern void __delete_from_page_cache(struct page *page, void *shadow);
 int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask);
-void delete_from_page_cache_batch(struct address_space *mapping, int count,
-				  struct page **pages);
+void delete_from_page_cache_batch(struct address_space *mapping,
+				  struct pagevec *pvec);
 
 /*
  * Like add_to_page_cache_locked, but used to add newly allocated pages:
diff --git a/mm/filemap.c b/mm/filemap.c
index 38fc390d51a2..b9f858c54502 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -307,21 +307,20 @@ EXPORT_SYMBOL(delete_from_page_cache);
 /*
  * page_cache_tree_delete_batch - delete several pages from page cache
  * @mapping: the mapping to which pages belong
- * @count: the number of pages to delete
- * @pages: pages that should be deleted
+ * @pvec: pagevec with pages to delete
  *
- * The function walks over mapping->page_tree and removes pages passed in
- * @pages array from the radix tree. The function expects @pages array to
- * sorted by page index. It tolerates holes in @pages array (radix tree
- * entries at those indices are not modified). The function expects only THP
- * head pages to be present in the @pages array and takes care to delete all
- * corresponding tail pages from the radix tree as well.
+ * The function walks over mapping->page_tree and removes pages passed in @pvec
+ * from the radix tree. The function expects @pvec to be sorted by page index.
+ * It tolerates holes in @pvec (radix tree entries at those indices are not
+ * modified). The function expects only THP head pages to be present in the
+ * @pvec and takes care to delete all corresponding tail pages from the radix
+ * tree as well.
  *
  * The function expects mapping->tree_lock to be held.
  */
 static void
-page_cache_tree_delete_batch(struct address_space *mapping, int count,
-			     struct page **pages)
+page_cache_tree_delete_batch(struct address_space *mapping,
+			     struct pagevec *pvec)
 {
 	struct radix_tree_iter iter;
 	void **slot;
@@ -330,9 +329,9 @@ page_cache_tree_delete_batch(struct address_space *mapping, int count,
 	struct page *page;
 	pgoff_t start;
 
-	start = pages[0]->index;
+	start = pvec->pages[0]->index;
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
-		if (i >= count && !tail_pages)
+		if (i >= pagevec_count(pvec) && !tail_pages)
 			break;
 		page = radix_tree_deref_slot_protected(slot,
 						       &mapping->tree_lock);
@@ -344,7 +343,7 @@ page_cache_tree_delete_batch(struct address_space *mapping, int count,
 			 * have our pages locked so they are protected from
 			 * being removed.
 			 */
-			if (page != pages[i])
+			if (page != pvec->pages[i])
 				continue;
 			WARN_ON_ONCE(!PageLocked(page));
 			if (PageTransHuge(page) && !PageHuge(page))
@@ -366,26 +365,26 @@ page_cache_tree_delete_batch(struct address_space *mapping, int count,
 	mapping->nrpages -= total_pages;
 }
 
-void delete_from_page_cache_batch(struct address_space *mapping, int count,
-				  struct page **pages)
+void delete_from_page_cache_batch(struct address_space *mapping,
+				  struct pagevec *pvec)
 {
 	int i;
 	unsigned long flags;
 
-	if (!count)
+	if (!pagevec_count(pvec))
 		return;
 
 	spin_lock_irqsave(&mapping->tree_lock, flags);
-	for (i = 0; i < count; i++) {
-		trace_mm_filemap_delete_from_page_cache(pages[i]);
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		trace_mm_filemap_delete_from_page_cache(pvec->pages[i]);
 
-		unaccount_page_cache_page(mapping, pages[i]);
+		unaccount_page_cache_page(mapping, pvec->pages[i]);
 	}
-	page_cache_tree_delete_batch(mapping, count, pages);
+	page_cache_tree_delete_batch(mapping, pvec);
 	spin_unlock_irqrestore(&mapping->tree_lock, flags);
 
-	for (i = 0; i < count; i++)
-		page_cache_free_page(mapping, pages[i]);
+	for (i = 0; i < pagevec_count(pvec); i++)
+		page_cache_free_page(mapping, pvec->pages[i]);
 }
 
 int filemap_check_errors(struct address_space *mapping)
diff --git a/mm/truncate.c b/mm/truncate.c
index 3dfa2d5e642e..4a39a3150ee2 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -297,11 +297,11 @@ void truncate_inode_pages_range(struct address_space *mapping,
 		/*
 		 * Pagevec array has exceptional entries and we may also fail
 		 * to lock some pages. So we store pages that can be deleted
-		 * in an extra array.
+		 * in a new pagevec.
 		 */
-		struct page *pages[PAGEVEC_SIZE];
-		int batch_count = 0;
+		struct pagevec locked_pvec;
 
+		pagevec_init(&locked_pvec, 0);
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
@@ -327,13 +327,13 @@ void truncate_inode_pages_range(struct address_space *mapping,
 				unlock_page(page);
 				continue;
 			}
-			pages[batch_count++] = page;
+			pagevec_add(&locked_pvec, page);
 		}
-		for (i = 0; i < batch_count; i++)
-			truncate_cleanup_page(mapping, pages[i]);
-		delete_from_page_cache_batch(mapping, batch_count, pages);
-		for (i = 0; i < batch_count; i++)
-			unlock_page(pages[i]);
+		for (i = 0; i < pagevec_count(&locked_pvec); i++)
+			truncate_cleanup_page(mapping, locked_pvec.pages[i]);
+		delete_from_page_cache_batch(mapping, &locked_pvec);
+		for (i = 0; i < pagevec_count(&locked_pvec); i++)
+			unlock_page(locked_pvec.pages[i]);
 		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		cond_resched();
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
