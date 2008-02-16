Message-Id: <20080216004808.994697478@sgi.com>
References: <20080216004718.047808297@sgi.com>
Date: Fri, 15 Feb 2008 16:47:33 -0800
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

Index: linux-2.6/fs/ext3/dir.c
===================================================================
--- linux-2.6.orig/fs/ext3/dir.c	2008-02-14 15:19:11.977504226 -0800
+++ linux-2.6/fs/ext3/dir.c	2008-02-15 16:15:13.021174127 -0800
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
Index: linux-2.6/fs/ext3/inode.c
===================================================================
--- linux-2.6.orig/fs/ext3/inode.c	2008-02-14 15:19:11.977504226 -0800
+++ linux-2.6/fs/ext3/inode.c	2008-02-15 16:15:13.049174361 -0800
@@ -1147,8 +1147,8 @@ static int ext3_write_begin(struct file 
 	pgoff_t index;
 	unsigned from, to;
 
-	index = pos >> PAGE_CACHE_SHIFT;
-	from = pos & (PAGE_CACHE_SIZE - 1);
+	index = page_cache_index(mapping, pos);
+	from = page_cache_offset(mapping, pos);
 	to = from + len;
 
 retry:
@@ -1244,7 +1244,7 @@ static int ext3_ordered_write_end(struct
 	unsigned from, to;
 	int ret = 0, ret2;
 
-	from = pos & (PAGE_CACHE_SIZE - 1);
+	from = page_cache_offset(mapping, pos);
 	to = from + len;
 
 	ret = walk_page_buffers(handle, page_buffers(page),
@@ -1314,7 +1314,7 @@ static int ext3_journalled_write_end(str
 	int partial = 0;
 	unsigned from, to;
 
-	from = pos & (PAGE_CACHE_SIZE - 1);
+	from = page_cache_offset(mapping, pos);
 	to = from + len;
 
 	if (copied < len) {
@@ -1477,6 +1477,7 @@ static int ext3_ordered_writepage(struct
 	handle_t *handle = NULL;
 	int ret = 0;
 	int err;
+	int pagesize = page_cache_size(inode->i_mapping);
 
 	J_ASSERT(PageLocked(page));
 
@@ -1499,8 +1500,7 @@ static int ext3_ordered_writepage(struct
 				(1 << BH_Dirty)|(1 << BH_Uptodate));
 	}
 	page_bufs = page_buffers(page);
-	walk_page_buffers(handle, page_bufs, 0,
-			PAGE_CACHE_SIZE, NULL, bget_one);
+	walk_page_buffers(handle, page_bufs, 0, pagesize, NULL, bget_one);
 
 	ret = block_write_full_page(page, ext3_get_block, wbc);
 
@@ -1517,13 +1517,12 @@ static int ext3_ordered_writepage(struct
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
@@ -1571,10 +1570,12 @@ out_fail:
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
@@ -1591,17 +1592,16 @@ static int ext3_journalled_writepage(str
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
@@ -1824,8 +1824,8 @@ void ext3_set_aops(struct inode *inode)
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
@@ -1833,7 +1833,8 @@ static int ext3_block_truncate_page(hand
 
 	blocksize = inode->i_sb->s_blocksize;
 	length = blocksize - (offset & (blocksize - 1));
-	iblock = index << (PAGE_CACHE_SHIFT - inode->i_sb->s_blocksize_bits);
+	iblock = index <<
+		(page_cache_shift(mapping) - inode->i_sb->s_blocksize_bits);
 
 	/*
 	 * For "nobh" option,  we can only work if we don't need to
@@ -2312,7 +2313,7 @@ void ext3_truncate(struct inode *inode)
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
