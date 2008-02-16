Message-Id: <20080216004807.998395280@sgi.com>
References: <20080216004718.047808297@sgi.com>
Date: Fri, 15 Feb 2008 16:47:29 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 11/18] Use page_cache_xxx in mm/mpage.c
Content-Disposition: inline; filename=0012-Use-page_cache_xxx-in-mm-mpage.c.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

Use page_cache_xxx in mm/mpage.c

Reviewed-by: Dave Chinner <dgc@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/mpage.c |   28 ++++++++++++++++------------
 1 file changed, 16 insertions(+), 12 deletions(-)

Index: linux-2.6/fs/mpage.c
===================================================================
--- linux-2.6.orig/fs/mpage.c	2008-02-14 15:19:12.989511284 -0800
+++ linux-2.6/fs/mpage.c	2008-02-15 16:14:58.093049603 -0800
@@ -125,7 +125,8 @@ mpage_alloc(struct block_device *bdev,
 static void 
 map_buffer_to_page(struct page *page, struct buffer_head *bh, int page_block) 
 {
-	struct inode *inode = page->mapping->host;
+	struct address_space *mapping = page->mapping;
+	struct inode *inode = mapping->host;
 	struct buffer_head *page_bh, *head;
 	int block = 0;
 
@@ -134,9 +135,9 @@ map_buffer_to_page(struct page *page, st
 		 * don't make any buffers if there is only one buffer on
 		 * the page and the page just needs to be set up to date
 		 */
-		if (inode->i_blkbits == PAGE_CACHE_SHIFT && 
+		if (inode->i_blkbits == page_cache_shift(mapping) &&
 		    buffer_uptodate(bh)) {
-			SetPageUptodate(page);    
+			SetPageUptodate(page);
 			return;
 		}
 		create_empty_buffers(page, 1 << inode->i_blkbits, 0);
@@ -169,9 +170,10 @@ do_mpage_readpage(struct bio *bio, struc
 		sector_t *last_block_in_bio, struct buffer_head *map_bh,
 		unsigned long *first_logical_block, get_block_t get_block)
 {
-	struct inode *inode = page->mapping->host;
+	struct address_space *mapping = page->mapping;
+	struct inode *inode = mapping->host;
 	const unsigned blkbits = inode->i_blkbits;
-	const unsigned blocks_per_page = PAGE_CACHE_SIZE >> blkbits;
+	const unsigned blocks_per_page = page_cache_size(mapping) >> blkbits;
 	const unsigned blocksize = 1 << blkbits;
 	sector_t block_in_file;
 	sector_t last_block;
@@ -188,7 +190,7 @@ do_mpage_readpage(struct bio *bio, struc
 	if (page_has_buffers(page))
 		goto confused;
 
-	block_in_file = (sector_t)page->index << (PAGE_CACHE_SHIFT - blkbits);
+	block_in_file = (sector_t)page->index << (page_cache_shift(mapping) - blkbits);
 	last_block = block_in_file + nr_pages * blocks_per_page;
 	last_block_in_file = (i_size_read(inode) + blocksize - 1) >> blkbits;
 	if (last_block > last_block_in_file)
@@ -276,7 +278,8 @@ do_mpage_readpage(struct bio *bio, struc
 	}
 
 	if (first_hole != blocks_per_page) {
-		zero_user_segment(page, first_hole << blkbits, PAGE_CACHE_SIZE);
+		zero_user_segment(page, first_hole << blkbits,
+					page_cache_size(mapping));
 		if (first_hole == 0) {
 			SetPageUptodate(page);
 			unlock_page(page);
@@ -454,7 +457,7 @@ static int __mpage_writepage(struct page
 	struct inode *inode = page->mapping->host;
 	const unsigned blkbits = inode->i_blkbits;
 	unsigned long end_index;
-	const unsigned blocks_per_page = PAGE_CACHE_SIZE >> blkbits;
+	const unsigned blocks_per_page = page_cache_size(mapping) >> blkbits;
 	sector_t last_block;
 	sector_t block_in_file;
 	sector_t blocks[MAX_BUF_PER_PAGE];
@@ -523,7 +526,8 @@ static int __mpage_writepage(struct page
 	 * The page has no buffers: map it to disk
 	 */
 	BUG_ON(!PageUptodate(page));
-	block_in_file = (sector_t)page->index << (PAGE_CACHE_SHIFT - blkbits);
+	block_in_file = (sector_t)page->index <<
+			(page_cache_shift(mapping) - blkbits);
 	last_block = (i_size - 1) >> blkbits;
 	map_bh.b_page = page;
 	for (page_block = 0; page_block < blocks_per_page; ) {
@@ -555,7 +559,7 @@ static int __mpage_writepage(struct page
 	first_unmapped = page_block;
 
 page_is_mapped:
-	end_index = i_size >> PAGE_CACHE_SHIFT;
+	end_index = page_cache_index(mapping, i_size);
 	if (page->index >= end_index) {
 		/*
 		 * The page straddles i_size.  It must be zeroed out on each
@@ -565,11 +569,11 @@ page_is_mapped:
 		 * is zeroed when mapped, and writes to that region are not
 		 * written out to the file."
 		 */
-		unsigned offset = i_size & (PAGE_CACHE_SIZE - 1);
+		unsigned offset = page_cache_offset(mapping, i_size);
 
 		if (page->index > end_index || !offset)
 			goto confused;
-		zero_user_segment(page, offset, PAGE_CACHE_SIZE);
+		zero_user_segment(page, offset, page_cache_size(mapping));
 	}
 
 	/*

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
