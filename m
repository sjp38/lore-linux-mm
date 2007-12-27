Message-Id: <20071227053403.020081632@sgi.com>
References: <20071227053246.902699851@sgi.com>
Date: Wed, 26 Dec 2007 21:33:01 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 15/18] Use page_cache_xxx in fs/ext3
Content-Disposition: inline; filename=0016-Use-page_cache_xxx-in-fs-ext3.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

Use page_cache_xxx in fs/ext3

Reviewed-by: Dave Chinner <dgc@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/ext3/dir.c   |    3 ++-
 fs/ext3/inode.c |   39 ++++++++++++++++++++-------------------
 2 files changed, 22 insertions(+), 20 deletions(-)

Index: linux-2.6.24-rc6-mm1/fs/ext3/dir.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/ext3/dir.c	2007-12-20 17:25:48.000000000 -0800
+++ linux-2.6.24-rc6-mm1/fs/ext3/dir.c	2007-12-26 19:51:08.038145100 -0800
@@ -133,7 +133,8 @@ static int ext3_readdir(struct file * fi
 						&map_bh, 0, 0);
 		if (err > 0) {
 			pgoff_t index = map_bh.b_blocknr >>
-					(PAGE_CACHE_SHIFT - inode->i_blkbits);
+				(page_cache_shift(inode->i_mapping)
+					- inode->i_blkbits);
 			if (!ra_has_index(&filp->f_ra, index))
 				page_cache_sync_readahead(
 					sb->s_bdev->bd_inode->i_mapping,
Index: linux-2.6.24-rc6-mm1/fs/ext3/inode.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/ext3/inode.c	2007-12-26 17:47:01.991405709 -0800
+++ linux-2.6.24-rc6-mm1/fs/ext3/inode.c	2007-12-26 19:51:08.106145500 -0800
@@ -1157,8 +1157,8 @@ static int ext3_write_begin(struct file 
 	pgoff_t index;
 	unsigned from, to;
 
-	index = pos >> PAGE_CACHE_SHIFT;
-	from = pos & (PAGE_CACHE_SIZE - 1);
+	index = page_cache_index(mapping, pos);
+	from = page_cache_offset(mapping, pos);
 	to = from + len;
 
 retry:
@@ -1254,7 +1254,7 @@ static int ext3_ordered_write_end(struct
 	unsigned from, to;
 	int ret = 0, ret2;
 
-	from = pos & (PAGE_CACHE_SIZE - 1);
+	from = page_cache_offset(mapping, pos);
 	to = from + len;
 
 	ret = walk_page_buffers(handle, page_buffers(page),
@@ -1324,7 +1324,7 @@ static int ext3_journalled_write_end(str
 	int partial = 0;
 	unsigned from, to;
 
-	from = pos & (PAGE_CACHE_SIZE - 1);
+	from = page_cache_offset(mapping, pos);
 	to = from + len;
 
 	if (copied < len) {
@@ -1487,6 +1487,7 @@ static int ext3_ordered_writepage(struct
 	handle_t *handle = NULL;
 	int ret = 0;
 	int err;
+	int pagesize = page_cache_size(inode->i_mapping);
 
 	J_ASSERT(PageLocked(page));
 
@@ -1509,8 +1510,7 @@ static int ext3_ordered_writepage(struct
 				(1 << BH_Dirty)|(1 << BH_Uptodate));
 	}
 	page_bufs = page_buffers(page);
-	walk_page_buffers(handle, page_bufs, 0,
-			PAGE_CACHE_SIZE, NULL, bget_one);
+	walk_page_buffers(handle, page_bufs, 0, pagesize, NULL, bget_one);
 
 	ret = block_write_full_page(page, ext3_get_block, wbc);
 
@@ -1527,13 +1527,12 @@ static int ext3_ordered_writepage(struct
 	 * and generally junk.
 	 */
 	if (ret == 0) {
-		err = walk_page_buffers(handle, page_bufs, 0, PAGE_CACHE_SIZE,
-					NULL, journal_dirty_data_fn);
+		err = walk_page_buffers(handle, page_bufs, 0, pagesize,
+			NULL, journal_dirty_data_fn);
 		if (!ret)
 			ret = err;
 	}
-	walk_page_buffers(handle, page_bufs, 0,
-			PAGE_CACHE_SIZE, NULL, bput_one);
+	walk_page_buffers(handle, page_bufs, 0, pagesize, NULL, bput_one);
 	err = ext3_journal_stop(handle);
 	if (!ret)
 		ret = err;
@@ -1581,10 +1580,12 @@ out_fail:
 static int ext3_journalled_writepage(struct page *page,
 				struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct address_space *mapping = page->mapping;
+	struct inode *inode = mapping->host;
 	handle_t *handle = NULL;
 	int ret = 0;
 	int err;
+	int pagesize = page_cache_size(inode->i_mapping);
 
 	if (ext3_journal_current_handle())
 		goto no_write;
@@ -1601,17 +1602,16 @@ static int ext3_journalled_writepage(str
 		 * doesn't seem much point in redirtying the page here.
 		 */
 		ClearPageChecked(page);
-		ret = block_prepare_write(page, 0, PAGE_CACHE_SIZE,
-					ext3_get_block);
+		ret = block_prepare_write(page, 0, pagesize, ext3_get_block);
 		if (ret != 0) {
 			ext3_journal_stop(handle);
 			goto out_unlock;
 		}
 		ret = walk_page_buffers(handle, page_buffers(page), 0,
-			PAGE_CACHE_SIZE, NULL, do_journal_get_write_access);
+			pagesize, NULL, do_journal_get_write_access);
 
 		err = walk_page_buffers(handle, page_buffers(page), 0,
-				PAGE_CACHE_SIZE, NULL, write_end_fn);
+			pagesize, NULL, write_end_fn);
 		if (ret == 0)
 			ret = err;
 		EXT3_I(inode)->i_state |= EXT3_STATE_JDATA;
@@ -1826,8 +1826,8 @@ void ext3_set_aops(struct inode *inode)
 static int ext3_block_truncate_page(handle_t *handle, struct page *page,
 		struct address_space *mapping, loff_t from)
 {
-	ext3_fsblk_t index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	ext3_fsblk_t index = page_cache_index(mapping, from);
+	unsigned offset = page_cache_offset(mapping, from);
 	unsigned blocksize, iblock, length, pos;
 	struct inode *inode = mapping->host;
 	struct buffer_head *bh;
@@ -1835,7 +1835,8 @@ static int ext3_block_truncate_page(hand
 
 	blocksize = inode->i_sb->s_blocksize;
 	length = blocksize - (offset & (blocksize - 1));
-	iblock = index << (PAGE_CACHE_SHIFT - inode->i_sb->s_blocksize_bits);
+	iblock = index <<
+		(page_cache_shift(mapping) - inode->i_sb->s_blocksize_bits);
 
 	/*
 	 * For "nobh" option,  we can only work if we don't need to
@@ -2314,7 +2315,7 @@ void ext3_truncate(struct inode *inode)
 		page = NULL;
 	} else {
 		page = grab_cache_page(mapping,
-				inode->i_size >> PAGE_CACHE_SHIFT);
+				page_cache_index(mapping, inode->i_size));
 		if (!page)
 			return;
 	}

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
