Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 881676B01B4
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 12:39:21 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 2/2] mm: Implement writeback livelock avoidance using page tagging
Date: Wed, 16 Jun 2010 18:33:51 +0200
Message-Id: <1276706031-29421-3-git-send-email-jack@suse.cz>
In-Reply-To: <1276706031-29421-1-git-send-email-jack@suse.cz>
References: <1276706031-29421-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

We try to avoid livelocks of writeback when some steadily creates
dirty pages in a mapping we are writing out. For memory-cleaning
writeback, using nr_to_write works reasonably well but we cannot
really use it for data integrity writeback. This patch tries to
solve the problem.

The idea is simple: Tag all pages that should be written back
with a special tag (TOWRITE) in the radix tree. This can be done
rather quickly and thus livelocks should not happen in practice.
Then we start doing the hard work of locking pages and sending
them to disk only for those pages that have TOWRITE tag set.

Note: Adding new radix tree tag grows radix tree node from 288 to
296 bytes for 32-bit archs and from 552 to 560 bytes for 64-bit archs.
However, the number of slab/slub items per page remains the same
(13 and 7 respectively).

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/fs.h         |    1 +
 include/linux/radix-tree.h |    2 +-
 mm/page-writeback.c        |   69 +++++++++++++++++++++++++++++++++-----------
 3 files changed, 54 insertions(+), 18 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 471e1ff..664674e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -685,6 +685,7 @@ struct block_device {
  */
 #define PAGECACHE_TAG_DIRTY	0
 #define PAGECACHE_TAG_WRITEBACK	1
+#define PAGECACHE_TAG_TOWRITE	2
 
 int mapping_tagged(struct address_space *mapping, int tag);
 
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index a4b00e9..634b8e6 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -55,7 +55,7 @@ static inline int radix_tree_is_indirect_ptr(void *ptr)
 
 /*** radix-tree API starts here ***/
 
-#define RADIX_TREE_MAX_TAGS 2
+#define RADIX_TREE_MAX_TAGS 3
 
 /* root tags are stored in gfp_mask, shifted by __GFP_BITS_SHIFT */
 struct radix_tree_root {
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index bbd396a..1cb043e 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -807,6 +807,40 @@ void __init page_writeback_init(void)
 }
 
 /**
+ * tag_pages_for_writeback - tag pages to be written by write_cache_pages
+ * @mapping: address space structure to write
+ * @start: starting page index
+ * @end: ending page index (inclusive)
+ *
+ * This function scans the page range from @start to @end (inclusive) and tags
+ * all pages that have DIRTY tag set with a special TOWRITE tag. The idea is
+ * that write_cache_pages (or whoever calls this function) will then use
+ * TOWRITE tag to identify pages eligible for writeback.  This mechanism is
+ * used to avoid livelocking of writeback by a process steadily creating new
+ * dirty pages in the file (thus it is important for this function to be quick
+ * so that it can tag pages faster than a dirtying process can create them).
+ */
+/*
+ * We tag pages in batches of WRITEBACK_TAG_BATCH to reduce tree_lock latency.
+ */
+#define WRITEBACK_TAG_BATCH 4096
+void tag_pages_for_writeback(struct address_space *mapping,
+			     pgoff_t start, pgoff_t end)
+{
+	unsigned long tagged;
+
+	do {
+		spin_lock_irq(&mapping->tree_lock);
+		tagged = radix_tree_range_tag_if_tagged(&mapping->page_tree,
+				&start, end, WRITEBACK_TAG_BATCH,
+				PAGECACHE_TAG_DIRTY, PAGECACHE_TAG_TOWRITE);
+		spin_unlock_irq(&mapping->tree_lock);
+		cond_resched();
+	} while (tagged >= WRITEBACK_TAG_BATCH);
+}
+EXPORT_SYMBOL(tag_pages_for_writeback);
+
+/**
  * write_cache_pages - walk the list of dirty pages of the given address space and write all of them.
  * @mapping: address space structure to write
  * @wbc: subtract the number of written pages from *@wbc->nr_to_write
@@ -820,6 +854,13 @@ void __init page_writeback_init(void)
  * the call was made get new I/O started against them.  If wbc->sync_mode is
  * WB_SYNC_ALL then we were called for data integrity and we must wait for
  * existing IO to complete.
+ *
+ * To avoid livelocks (when other process dirties new pages), we first tag
+ * pages which should be written back with TOWRITE tag and only then start
+ * writing them. For data-integrity sync we have to be careful so that we do
+ * not miss some pages (e.g., because some other process has cleared TOWRITE
+ * tag we set). The rule we follow is that TOWRITE tag can be cleared only
+ * by the process clearing the DIRTY tag (and submitting the page for IO).
  */
 int write_cache_pages(struct address_space *mapping,
 		      struct writeback_control *wbc, writepage_t writepage,
@@ -835,6 +876,7 @@ int write_cache_pages(struct address_space *mapping,
 	pgoff_t done_index;
 	int cycled;
 	int range_whole = 0;
+	int tag;
 
 	pagevec_init(&pvec, 0);
 	if (wbc->range_cyclic) {
@@ -851,29 +893,19 @@ int write_cache_pages(struct address_space *mapping,
 		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
 			range_whole = 1;
 		cycled = 1; /* ignore range_cyclic tests */
-
-		/*
-		 * If this is a data integrity sync, cap the writeback to the
-		 * current end of file. Any extension to the file that occurs
-		 * after this is a new write and we don't need to write those
-		 * pages out to fulfil our data integrity requirements. If we
-		 * try to write them out, we can get stuck in this scan until
-		 * the concurrent writer stops adding dirty pages and extending
-		 * EOF.
-		 */
-		if (wbc->sync_mode == WB_SYNC_ALL &&
-		    wbc->range_end == LLONG_MAX) {
-			end = i_size_read(mapping->host) >> PAGE_CACHE_SHIFT;
-		}
 	}
-
+	if (wbc->sync_mode == WB_SYNC_ALL)
+		tag = PAGECACHE_TAG_TOWRITE;
+	else
+		tag = PAGECACHE_TAG_DIRTY;
 retry:
+	if (wbc->sync_mode == WB_SYNC_ALL)
+		tag_pages_for_writeback(mapping, index, end);
 	done_index = index;
 	while (!done && (index <= end)) {
 		int i;
 
-		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
-			      PAGECACHE_TAG_DIRTY,
+		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index, tag,
 			      min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1);
 		if (nr_pages == 0)
 			break;
@@ -1329,6 +1361,9 @@ int test_set_page_writeback(struct page *page)
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
+		radix_tree_tag_clear(&mapping->page_tree,
+				     page_index(page),
+				     PAGECACHE_TAG_TOWRITE);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 	} else {
 		ret = TestSetPageWriteback(page);
-- 
1.6.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
