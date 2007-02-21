Date: Wed, 21 Feb 2007 06:03:06 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] fs: introduce some page/buffer invariants
Message-ID: <20070221050306.GB21997@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

It is a bug to set a page dirty if it is not uptodate unless it has
buffers.  If the page has buffers, then the page may be dirty (some buffers
dirty) but not uptodate (some buffers not uptodate). The exception to this
rule is if the set_page_dirty caller is racing with truncate or invalidate.

A buffer can not be set dirty if it is not uptodate.

If either of these situations occurs, it indicates there could be some data
loss problem. Some of these warnings could be a harmless one where the page
or buffer is set uptodate immediately after it is dirtied, however we should
fix those up, and enforce this ordering.

Bring the order of operations for truncate into line with those of invalidate.
This will prevent a page from being able to go !uptodate while we're holding
the tree_lock, which is probably a good thing anyway.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -683,6 +683,39 @@ void mark_buffer_dirty_inode(struct buff
 EXPORT_SYMBOL(mark_buffer_dirty_inode);
 
 /*
+ * Mark the page dirty, and set it dirty in the radix tree, and mark the inode
+ * dirty.
+ *
+ * If warn is true, then emit a warning if the page is not uptodate and has
+ * not been truncated.
+ */
+static int __set_page_dirty(struct page *page,
+		struct address_space *mapping, int warn)
+{
+	if (unlikely(!mapping))
+		return !TestSetPageDirty(page);
+
+	if (TestSetPageDirty(page))
+		return 0;
+
+	write_lock_irq(&mapping->tree_lock);
+	if (page->mapping) {	/* Race with truncate? */
+		WARN_ON(warn && !PageUptodate(page));
+
+		if (mapping_cap_account_dirty(mapping)) {
+			__inc_zone_page_state(page, NR_FILE_DIRTY);
+			task_io_account_write(PAGE_CACHE_SIZE);
+		}
+		radix_tree_tag_set(&mapping->page_tree,
+				page_index(page), PAGECACHE_TAG_DIRTY);
+	}
+	write_unlock_irq(&mapping->tree_lock);
+	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+
+	return 1;
+}
+
+/*
  * Add a page to the dirty page list.
  *
  * It is a sad fact of life that this function is called from several places
@@ -709,7 +742,7 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
  */
 int __set_page_dirty_buffers(struct page *page)
 {
-	struct address_space * const mapping = page_mapping(page);
+	struct address_space *mapping = page_mapping(page);
 
 	if (unlikely(!mapping))
 		return !TestSetPageDirty(page);
@@ -726,21 +759,7 @@ int __set_page_dirty_buffers(struct page
 	}
 	spin_unlock(&mapping->private_lock);
 
-	if (TestSetPageDirty(page))
-		return 0;
-
-	write_lock_irq(&mapping->tree_lock);
-	if (page->mapping) {	/* Race with truncate? */
-		if (mapping_cap_account_dirty(mapping)) {
-			__inc_zone_page_state(page, NR_FILE_DIRTY);
-			task_io_account_write(PAGE_CACHE_SIZE);
-		}
-		radix_tree_tag_set(&mapping->page_tree,
-				page_index(page), PAGECACHE_TAG_DIRTY);
-	}
-	write_unlock_irq(&mapping->tree_lock);
-	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
-	return 1;
+	return __set_page_dirty(page, mapping, 1);
 }
 EXPORT_SYMBOL(__set_page_dirty_buffers);
 
@@ -1143,8 +1162,9 @@ __getblk_slow(struct block_device *bdev,
  */
 void fastcall mark_buffer_dirty(struct buffer_head *bh)
 {
+	WARN_ON(!buffer_uptodate(bh));
 	if (!buffer_dirty(bh) && !test_set_buffer_dirty(bh))
-		__set_page_dirty_nobuffers(bh->b_page);
+		__set_page_dirty(bh->b_page, page_mapping(bh->b_page), 0);
 }
 
 /*
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -771,6 +771,7 @@ int __set_page_dirty_nobuffers(struct pa
 		mapping2 = page_mapping(page);
 		if (mapping2) { /* Race with truncate? */
 			BUG_ON(mapping2 != mapping);
+			WARN_ON(!PageUptodate(page));
 			if (mapping_cap_account_dirty(mapping)) {
 				__inc_zone_page_state(page, NR_FILE_DIRTY);
 				task_io_account_write(PAGE_CACHE_SIZE);
Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c
+++ linux-2.6/mm/truncate.c
@@ -99,9 +99,9 @@ truncate_complete_page(struct address_sp
 	if (PagePrivate(page))
 		do_invalidatepage(page, 0);
 
+	remove_from_page_cache(page);
 	ClearPageUptodate(page);
 	ClearPageMappedToDisk(page);
-	remove_from_page_cache(page);
 	page_cache_release(page);	/* pagecache ref */
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
