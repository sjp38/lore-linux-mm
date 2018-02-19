Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id D3E456B0293
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 14:46:22 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id 4so6715364plb.1
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 11:46:22 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t76si3969284pgc.489.2018.02.19.11.46.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Feb 2018 11:46:21 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v7 33/61] mm: Convert page-writeback to XArray
Date: Mon, 19 Feb 2018 11:45:28 -0800
Message-Id: <20180219194556.6575-34-willy@infradead.org>
In-Reply-To: <20180219194556.6575-1-willy@infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Includes moving mapping_tagged() to fs.h as a static inline, and
changing it to return bool.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/fs.h  | 17 +++++++++------
 mm/page-writeback.c | 62 +++++++++++++++++++----------------------------------
 2 files changed, 32 insertions(+), 47 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index b9ea6961947a..b134f80ca498 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -470,15 +470,18 @@ struct block_device {
 	struct mutex		bd_fsfreeze_mutex;
 } __randomize_layout;
 
+/* XArray tags, for tagging dirty and writeback pages in the pagecache. */
+#define PAGECACHE_TAG_DIRTY	XA_TAG_0
+#define PAGECACHE_TAG_WRITEBACK	XA_TAG_1
+#define PAGECACHE_TAG_TOWRITE	XA_TAG_2
+
 /*
- * Radix-tree tags, for tagging dirty and writeback pages within the pagecache
- * radix trees
+ * Returns true if any of the pages in the mapping are marked with the tag.
  */
-#define PAGECACHE_TAG_DIRTY	0
-#define PAGECACHE_TAG_WRITEBACK	1
-#define PAGECACHE_TAG_TOWRITE	2
-
-int mapping_tagged(struct address_space *mapping, int tag);
+static inline bool mapping_tagged(struct address_space *mapping, xa_tag_t tag)
+{
+	return xa_tagged(&mapping->pages, tag);
+}
 
 static inline void i_mmap_lock_write(struct address_space *mapping)
 {
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 588ce729d199..0407436a8305 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2098,33 +2098,25 @@ void __init page_writeback_init(void)
  * dirty pages in the file (thus it is important for this function to be quick
  * so that it can tag pages faster than a dirtying process can create them).
  */
-/*
- * We tag pages in batches of WRITEBACK_TAG_BATCH to reduce xa_lock latency.
- */
 void tag_pages_for_writeback(struct address_space *mapping,
 			     pgoff_t start, pgoff_t end)
 {
-#define WRITEBACK_TAG_BATCH 4096
-	unsigned long tagged = 0;
-	struct radix_tree_iter iter;
-	void **slot;
+	XA_STATE(xas, &mapping->pages, start);
+	unsigned int tagged = 0;
+	void *page;
 
-	xa_lock_irq(&mapping->pages);
-	radix_tree_for_each_tagged(slot, &mapping->pages, &iter, start,
-							PAGECACHE_TAG_DIRTY) {
-		if (iter.index > end)
-			break;
-		radix_tree_iter_tag_set(&mapping->pages, &iter,
-							PAGECACHE_TAG_TOWRITE);
-		tagged++;
-		if ((tagged % WRITEBACK_TAG_BATCH) != 0)
+	xas_lock_irq(&xas);
+	xas_for_each_tag(&xas, page, end, PAGECACHE_TAG_DIRTY) {
+		xas_set_tag(&xas, PAGECACHE_TAG_TOWRITE);
+		if (++tagged % XA_CHECK_SCHED)
 			continue;
-		slot = radix_tree_iter_resume(slot, &iter);
-		xa_unlock_irq(&mapping->pages);
+
+		xas_pause(&xas);
+		xas_unlock_irq(&xas);
 		cond_resched();
-		xa_lock_irq(&mapping->pages);
+		xas_lock_irq(&xas);
 	}
-	xa_unlock_irq(&mapping->pages);
+	xas_unlock_irq(&xas);
 }
 EXPORT_SYMBOL(tag_pages_for_writeback);
 
@@ -2164,7 +2156,7 @@ int write_cache_pages(struct address_space *mapping,
 	pgoff_t done_index;
 	int cycled;
 	int range_whole = 0;
-	int tag;
+	xa_tag_t tag;
 
 	pagevec_init(&pvec);
 	if (wbc->range_cyclic) {
@@ -2445,7 +2437,7 @@ void account_page_cleaned(struct page *page, struct address_space *mapping,
 
 /*
  * For address_spaces which do not use buffers.  Just tag the page as dirty in
- * its radix tree.
+ * the xarray.
  *
  * This is also used when a single buffer is being dirtied: we want to set the
  * page dirty in that case, but not all the buffers.  This is a "bottom-up"
@@ -2471,7 +2463,7 @@ int __set_page_dirty_nobuffers(struct page *page)
 		BUG_ON(page_mapping(page) != mapping);
 		WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
 		account_page_dirtied(page, mapping);
-		radix_tree_tag_set(&mapping->pages, page_index(page),
+		__xa_set_tag(&mapping->pages, page_index(page),
 				   PAGECACHE_TAG_DIRTY);
 		xa_unlock_irqrestore(&mapping->pages, flags);
 		unlock_page_memcg(page);
@@ -2634,13 +2626,13 @@ EXPORT_SYMBOL(__cancel_dirty_page);
  * Returns true if the page was previously dirty.
  *
  * This is for preparing to put the page under writeout.  We leave the page
- * tagged as dirty in the radix tree so that a concurrent write-for-sync
+ * tagged as dirty in the xarray so that a concurrent write-for-sync
  * can discover it via a PAGECACHE_TAG_DIRTY walk.  The ->writepage
  * implementation will run either set_page_writeback() or set_page_dirty(),
- * at which stage we bring the page's dirty flag and radix-tree dirty tag
+ * at which stage we bring the page's dirty flag and xarray dirty tag
  * back into sync.
  *
- * This incoherency between the page's dirty flag and radix-tree tag is
+ * This incoherency between the page's dirty flag and xarray tag is
  * unfortunate, but it only exists while the page is locked.
  */
 int clear_page_dirty_for_io(struct page *page)
@@ -2721,7 +2713,7 @@ int test_clear_page_writeback(struct page *page)
 		xa_lock_irqsave(&mapping->pages, flags);
 		ret = TestClearPageWriteback(page);
 		if (ret) {
-			radix_tree_tag_clear(&mapping->pages, page_index(page),
+			__xa_clear_tag(&mapping->pages, page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
 			if (bdi_cap_account_writeback(bdi)) {
 				struct bdi_writeback *wb = inode_to_wb(inode);
@@ -2773,7 +2765,7 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 			on_wblist = mapping_tagged(mapping,
 						   PAGECACHE_TAG_WRITEBACK);
 
-			radix_tree_tag_set(&mapping->pages, page_index(page),
+			__xa_set_tag(&mapping->pages, page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
 			if (bdi_cap_account_writeback(bdi))
 				inc_wb_stat(inode_to_wb(inode), WB_WRITEBACK);
@@ -2787,10 +2779,10 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 				sb_mark_inode_writeback(mapping->host);
 		}
 		if (!PageDirty(page))
-			radix_tree_tag_clear(&mapping->pages, page_index(page),
+			__xa_clear_tag(&mapping->pages, page_index(page),
 						PAGECACHE_TAG_DIRTY);
 		if (!keep_write)
-			radix_tree_tag_clear(&mapping->pages, page_index(page),
+			__xa_clear_tag(&mapping->pages, page_index(page),
 						PAGECACHE_TAG_TOWRITE);
 		xa_unlock_irqrestore(&mapping->pages, flags);
 	} else {
@@ -2806,16 +2798,6 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 }
 EXPORT_SYMBOL(__test_set_page_writeback);
 
-/*
- * Return true if any of the pages in the mapping are marked with the
- * passed tag.
- */
-int mapping_tagged(struct address_space *mapping, int tag)
-{
-	return radix_tree_tagged(&mapping->pages, tag);
-}
-EXPORT_SYMBOL(mapping_tagged);
-
 /**
  * wait_for_stable_page() - wait for writeback to finish, if necessary.
  * @page:	The page to wait on.
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
