Message-Id: <20070423062130.952242003@sgi.com>
References: <20070423062107.843307112@sgi.com>
Date: Sun, 22 Apr 2007 23:21:19 -0700
From: clameter@sgi.com
Subject: [RFC 12/16] Variable Order Page Cache: Fix up the writeback logic
Content-Disposition: inline; filename=var_pc_writeback
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, Adam Litke <aglitke@gmail.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Avi Kivity <avi@argo.co.il>, Dave Hansen <hansendc@us.ibm.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>
List-ID: <linux-mm.kvack.org>

Nothing special here. Just the usual transformations.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/sync.c           |    8 ++++----
 mm/fadvise.c        |    8 ++++----
 mm/page-writeback.c |    4 ++--
 mm/truncate.c       |   23 ++++++++++++-----------
 4 files changed, 22 insertions(+), 21 deletions(-)

Index: linux-2.6.21-rc7/mm/page-writeback.c
===================================================================
--- linux-2.6.21-rc7.orig/mm/page-writeback.c	2007-04-22 21:47:34.000000000 -0700
+++ linux-2.6.21-rc7/mm/page-writeback.c	2007-04-22 22:08:35.000000000 -0700
@@ -606,8 +606,8 @@ int generic_writepages(struct address_sp
 		index = mapping->writeback_index; /* Start from prev offset */
 		end = -1;
 	} else {
-		index = wbc->range_start >> PAGE_CACHE_SHIFT;
-		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		index = page_cache_index(mapping, wbc->range_start);
+		end = page_cache_index(mapping, wbc->range_end);
 		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
 			range_whole = 1;
 		scanned = 1;
Index: linux-2.6.21-rc7/fs/sync.c
===================================================================
--- linux-2.6.21-rc7.orig/fs/sync.c	2007-04-22 21:47:34.000000000 -0700
+++ linux-2.6.21-rc7/fs/sync.c	2007-04-22 22:08:35.000000000 -0700
@@ -254,8 +254,8 @@ int do_sync_file_range(struct file *file
 	ret = 0;
 	if (flags & SYNC_FILE_RANGE_WAIT_BEFORE) {
 		ret = wait_on_page_writeback_range(mapping,
-					offset >> PAGE_CACHE_SHIFT,
-					endbyte >> PAGE_CACHE_SHIFT);
+					page_cache_index(mapping, offset),
+					page_cache_index(mapping, endbyte));
 		if (ret < 0)
 			goto out;
 	}
@@ -269,8 +269,8 @@ int do_sync_file_range(struct file *file
 
 	if (flags & SYNC_FILE_RANGE_WAIT_AFTER) {
 		ret = wait_on_page_writeback_range(mapping,
-					offset >> PAGE_CACHE_SHIFT,
-					endbyte >> PAGE_CACHE_SHIFT);
+					page_cache_index(mapping, offset),
+					page_cache_index(mapping, endbyte));
 	}
 out:
 	return ret;
Index: linux-2.6.21-rc7/mm/fadvise.c
===================================================================
--- linux-2.6.21-rc7.orig/mm/fadvise.c	2007-04-22 22:04:44.000000000 -0700
+++ linux-2.6.21-rc7/mm/fadvise.c	2007-04-22 22:08:35.000000000 -0700
@@ -79,8 +79,8 @@ asmlinkage long sys_fadvise64_64(int fd,
 		}
 
 		/* First and last PARTIAL page! */
-		start_index = offset >> PAGE_CACHE_SHIFT;
-		end_index = endbyte >> PAGE_CACHE_SHIFT;
+		start_index = page_cache_index(mapping, offset);
+		end_index = page_cache_index(mapping, endbyte);
 
 		/* Careful about overflow on the "+1" */
 		nrpages = end_index - start_index + 1;
@@ -101,8 +101,8 @@ asmlinkage long sys_fadvise64_64(int fd,
 			filemap_flush(mapping);
 
 		/* First and last FULL page! */
-		start_index = (offset+(PAGE_CACHE_SIZE-1)) >> PAGE_CACHE_SHIFT;
-		end_index = (endbyte >> PAGE_CACHE_SHIFT);
+		start_index = page_cache_next(mapping, offset);
+		end_index = page_cache_index(mapping, endbyte);
 
 		if (end_index >= start_index)
 			invalidate_mapping_pages(mapping, start_index,
Index: linux-2.6.21-rc7/mm/truncate.c
===================================================================
--- linux-2.6.21-rc7.orig/mm/truncate.c	2007-04-22 21:47:34.000000000 -0700
+++ linux-2.6.21-rc7/mm/truncate.c	2007-04-22 22:11:19.000000000 -0700
@@ -46,7 +46,8 @@ void do_invalidatepage(struct page *page
 
 static inline void truncate_partial_page(struct page *page, unsigned partial)
 {
-	memclear_highpage_flush(page, partial, PAGE_CACHE_SIZE-partial);
+	memclear_highpage_flush(page, partial,
+		(PAGE_SIZE << compound_order(page)) - partial);
 	if (PagePrivate(page))
 		do_invalidatepage(page, partial);
 }
@@ -94,7 +95,7 @@ truncate_complete_page(struct address_sp
 	if (page->mapping != mapping)
 		return;
 
-	cancel_dirty_page(page, PAGE_CACHE_SIZE);
+	cancel_dirty_page(page, page_cache_size(mapping));
 
 	if (PagePrivate(page))
 		do_invalidatepage(page, 0);
@@ -156,9 +157,9 @@ invalidate_complete_page(struct address_
 void truncate_inode_pages_range(struct address_space *mapping,
 				loff_t lstart, loff_t lend)
 {
-	const pgoff_t start = (lstart + PAGE_CACHE_SIZE-1) >> PAGE_CACHE_SHIFT;
+	const pgoff_t start = page_cache_next(mapping, lstart);
 	pgoff_t end;
-	const unsigned partial = lstart & (PAGE_CACHE_SIZE - 1);
+	const unsigned partial = page_cache_offset(mapping, lstart);
 	struct pagevec pvec;
 	pgoff_t next;
 	int i;
@@ -166,8 +167,9 @@ void truncate_inode_pages_range(struct a
 	if (mapping->nrpages == 0)
 		return;
 
-	BUG_ON((lend & (PAGE_CACHE_SIZE - 1)) != (PAGE_CACHE_SIZE - 1));
-	end = (lend >> PAGE_CACHE_SHIFT);
+	BUG_ON(page_cache_offset(mapping, lend) !=
+				page_cache_size(mapping) - 1);
+	end = page_cache_index(mapping, lend);
 
 	pagevec_init(&pvec, 0);
 	next = start;
@@ -402,9 +404,8 @@ int invalidate_inode_pages2_range(struct
 					 * Zap the rest of the file in one hit.
 					 */
 					unmap_mapping_range(mapping,
-					   (loff_t)page_index<<PAGE_CACHE_SHIFT,
-					   (loff_t)(end - page_index + 1)
-							<< PAGE_CACHE_SHIFT,
+					   page_cache_pos(mapping, page_index, 0),
+					   page_cache_pos(mapping, end - page_index + 1, 0),
 					    0);
 					did_range_unmap = 1;
 				} else {
@@ -412,8 +413,8 @@ int invalidate_inode_pages2_range(struct
 					 * Just zap this page
 					 */
 					unmap_mapping_range(mapping,
-					  (loff_t)page_index<<PAGE_CACHE_SHIFT,
-					  PAGE_CACHE_SIZE, 0);
+					  page_cache_pos(mapping, page_index, 0),
+					  page_cache_size(mapping), 0);
 				}
 			}
 			ret = do_launder_page(mapping, page);

--
