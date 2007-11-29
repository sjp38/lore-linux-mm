Message-Id: <20071129011145.186725531@sgi.com>
References: <20071129011052.866354847@sgi.com>
Date: Wed, 28 Nov 2007 17:10:56 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 04/19] Use page_cache_xxx in mm/truncate.c
Content-Disposition: inline; filename=0005-Use-page_cache_xxx-in-mm-truncate.c.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

Use page_cache_xxx in mm/truncate.c

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/truncate.c |   35 ++++++++++++++++++-----------------
 1 file changed, 18 insertions(+), 17 deletions(-)

Index: mm/mm/truncate.c
===================================================================
--- mm.orig/mm/truncate.c	2007-11-28 12:27:32.480099915 -0800
+++ mm/mm/truncate.c	2007-11-28 14:10:39.013977394 -0800
@@ -46,9 +46,10 @@ void do_invalidatepage(struct page *page
 		(*invalidatepage)(page, offset);
 }
 
-static inline void truncate_partial_page(struct page *page, unsigned partial)
+static inline void truncate_partial_page(struct address_space *mapping,
+			struct page *page, unsigned partial)
 {
-	zero_user_segment(page, partial, PAGE_CACHE_SIZE);
+	zero_user_segment(page, partial, page_cache_size(mapping));
 	if (PagePrivate(page))
 		do_invalidatepage(page, partial);
 }
@@ -98,7 +99,7 @@ truncate_complete_page(struct address_sp
 	if (page->mapping != mapping)
 		return;
 
-	cancel_dirty_page(page, PAGE_CACHE_SIZE);
+	cancel_dirty_page(page, page_cache_size(mapping));
 
 	if (PagePrivate(page))
 		do_invalidatepage(page, 0);
@@ -160,9 +161,9 @@ invalidate_complete_page(struct address_
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
@@ -170,8 +171,9 @@ void truncate_inode_pages_range(struct a
 	if (mapping->nrpages == 0)
 		return;
 
-	BUG_ON((lend & (PAGE_CACHE_SIZE - 1)) != (PAGE_CACHE_SIZE - 1));
-	end = (lend >> PAGE_CACHE_SHIFT);
+	BUG_ON(page_cache_offset(mapping, lend) !=
+				page_cache_size(mapping) - 1);
+	end = page_cache_index(mapping, lend);
 
 	pagevec_init(&pvec, 0);
 	next = start;
@@ -197,8 +199,8 @@ void truncate_inode_pages_range(struct a
 			}
 			if (page_mapped(page)) {
 				unmap_mapping_range(mapping,
-				  (loff_t)page_index<<PAGE_CACHE_SHIFT,
-				  PAGE_CACHE_SIZE, 0);
+				  page_cache_pos(mapping, page_index, 0),
+				  page_cache_size(mapping), 0);
 			}
 			truncate_complete_page(mapping, page);
 			unlock_page(page);
@@ -211,7 +213,7 @@ void truncate_inode_pages_range(struct a
 		struct page *page = find_lock_page(mapping, start - 1);
 		if (page) {
 			wait_on_page_writeback(page);
-			truncate_partial_page(page, partial);
+			truncate_partial_page(mapping, page, partial);
 			unlock_page(page);
 			page_cache_release(page);
 		}
@@ -239,8 +241,8 @@ void truncate_inode_pages_range(struct a
 			wait_on_page_writeback(page);
 			if (page_mapped(page)) {
 				unmap_mapping_range(mapping,
-				  (loff_t)page->index<<PAGE_CACHE_SHIFT,
-				  PAGE_CACHE_SIZE, 0);
+				  page_cache_pos(mapping, page->index, 0),
+				  page_cache_size(mapping), 0);
 			}
 			if (page->index > next)
 				next = page->index;
@@ -424,9 +426,8 @@ int invalidate_inode_pages2_range(struct
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
@@ -434,8 +435,8 @@ int invalidate_inode_pages2_range(struct
 					 * Just zap this page
 					 */
 					unmap_mapping_range(mapping,
-					  (loff_t)page_index<<PAGE_CACHE_SHIFT,
-					  PAGE_CACHE_SIZE, 0);
+					  page_cache_pos(mapping, page_index, 0),
+					  page_cache_size(mapping), 0);
 				}
 			}
 			BUG_ON(page_mapped(page));

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
