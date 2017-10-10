Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BCCA76B027E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 11:19:53 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a84so6563126pfk.5
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 08:19:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u13si8503759pgq.234.2017.10.10.08.19.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 08:19:52 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 7/7] mm: Batch radix tree operations when truncating pages
Date: Tue, 10 Oct 2017 17:19:37 +0200
Message-Id: <20171010151937.26984-8-jack@suse.cz>
In-Reply-To: <20171010151937.26984-1-jack@suse.cz>
References: <20171010151937.26984-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>

Currently we remove pages from the radix tree one by one. To speed up
page cache truncation, lock several pages at once and free them in one
go. This allows us to batch radix tree operations in a more efficient
way and also save round-trips on mapping->tree_lock. As a result we gain
about 20% speed improvement in page cache truncation.

Data from a simple benchmark timing 10000 truncates of 1024 pages (on
ext4 on ramdisk but the filesystem is barely visible in the profiles).
The range shows 1% and 95% percentiles of the measured times:

4.14-rc2	4.14-rc2 + batched truncation
248-256		209-219
249-258		209-217
248-255		211-239
248-255		209-217
247-256		210-218

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/pagemap.h |  2 ++
 mm/filemap.c            | 84 +++++++++++++++++++++++++++++++++++++++++++++++++
 mm/truncate.c           | 20 ++++++++++--
 3 files changed, 104 insertions(+), 2 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 75cd074a23b4..e857c62aef06 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -623,6 +623,8 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 extern void delete_from_page_cache(struct page *page);
 extern void __delete_from_page_cache(struct page *page, void *shadow);
 int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask);
+void delete_from_page_cache_batch(struct address_space *mapping, int count,
+				  struct page **pages);
 
 /*
  * Like add_to_page_cache_locked, but used to add newly allocated pages:
diff --git a/mm/filemap.c b/mm/filemap.c
index 6fb01b2404a7..38fc390d51a2 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -304,6 +304,90 @@ void delete_from_page_cache(struct page *page)
 }
 EXPORT_SYMBOL(delete_from_page_cache);
 
+/*
+ * page_cache_tree_delete_batch - delete several pages from page cache
+ * @mapping: the mapping to which pages belong
+ * @count: the number of pages to delete
+ * @pages: pages that should be deleted
+ *
+ * The function walks over mapping->page_tree and removes pages passed in
+ * @pages array from the radix tree. The function expects @pages array to
+ * sorted by page index. It tolerates holes in @pages array (radix tree
+ * entries at those indices are not modified). The function expects only THP
+ * head pages to be present in the @pages array and takes care to delete all
+ * corresponding tail pages from the radix tree as well.
+ *
+ * The function expects mapping->tree_lock to be held.
+ */
+static void
+page_cache_tree_delete_batch(struct address_space *mapping, int count,
+			     struct page **pages)
+{
+	struct radix_tree_iter iter;
+	void **slot;
+	int total_pages = 0;
+	int i = 0, tail_pages = 0;
+	struct page *page;
+	pgoff_t start;
+
+	start = pages[0]->index;
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
+		if (i >= count && !tail_pages)
+			break;
+		page = radix_tree_deref_slot_protected(slot,
+						       &mapping->tree_lock);
+		if (radix_tree_exceptional_entry(page))
+			continue;
+		if (!tail_pages) {
+			/*
+			 * Some page got inserted in our range? Skip it. We
+			 * have our pages locked so they are protected from
+			 * being removed.
+			 */
+			if (page != pages[i])
+				continue;
+			WARN_ON_ONCE(!PageLocked(page));
+			if (PageTransHuge(page) && !PageHuge(page))
+				tail_pages = HPAGE_PMD_NR - 1;
+			page->mapping = NULL;
+			/*
+			 * Leave page->index set: truncation lookup relies
+			 * upon it
+			 */
+			i++;
+		} else {
+			tail_pages--;
+		}
+		radix_tree_clear_tags(&mapping->page_tree, iter.node, slot);
+		__radix_tree_replace(&mapping->page_tree, iter.node, slot, NULL,
+				     workingset_update_node, mapping);
+		total_pages++;
+	}
+	mapping->nrpages -= total_pages;
+}
+
+void delete_from_page_cache_batch(struct address_space *mapping, int count,
+				  struct page **pages)
+{
+	int i;
+	unsigned long flags;
+
+	if (!count)
+		return;
+
+	spin_lock_irqsave(&mapping->tree_lock, flags);
+	for (i = 0; i < count; i++) {
+		trace_mm_filemap_delete_from_page_cache(pages[i]);
+
+		unaccount_page_cache_page(mapping, pages[i]);
+	}
+	page_cache_tree_delete_batch(mapping, count, pages);
+	spin_unlock_irqrestore(&mapping->tree_lock, flags);
+
+	for (i = 0; i < count; i++)
+		page_cache_free_page(mapping, pages[i]);
+}
+
 int filemap_check_errors(struct address_space *mapping)
 {
 	int ret = 0;
diff --git a/mm/truncate.c b/mm/truncate.c
index 383a530d511e..3dfa2d5e642e 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -294,6 +294,14 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	while (index < end && pagevec_lookup_entries(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE),
 			indices)) {
+		/*
+		 * Pagevec array has exceptional entries and we may also fail
+		 * to lock some pages. So we store pages that can be deleted
+		 * in an extra array.
+		 */
+		struct page *pages[PAGEVEC_SIZE];
+		int batch_count = 0;
+
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
@@ -315,9 +323,17 @@ void truncate_inode_pages_range(struct address_space *mapping,
 				unlock_page(page);
 				continue;
 			}
-			truncate_inode_page(mapping, page);
-			unlock_page(page);
+			if (page->mapping != mapping) {
+				unlock_page(page);
+				continue;
+			}
+			pages[batch_count++] = page;
 		}
+		for (i = 0; i < batch_count; i++)
+			truncate_cleanup_page(mapping, pages[i]);
+		delete_from_page_cache_batch(mapping, batch_count, pages);
+		for (i = 0; i < batch_count; i++)
+			unlock_page(pages[i]);
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
