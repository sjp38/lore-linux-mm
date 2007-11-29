Message-Id: <20071129011148.032437954@sgi.com>
References: <20071129011052.866354847@sgi.com>
Date: Wed, 28 Nov 2007 17:11:08 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 16/19] Use page_cache_xxx in fs/ext4
Content-Disposition: inline; filename=0017-Use-page_cache_xxx-in-fs-ext4.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

Use page_cache_xxx in fs/ext4

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/ext4/dir.c   |    3 ++-
 fs/ext4/inode.c |   33 +++++++++++++++++----------------
 2 files changed, 19 insertions(+), 17 deletions(-)

Index: mm/fs/ext4/dir.c
===================================================================
--- mm.orig/fs/ext4/dir.c	2007-11-28 12:24:24.767962686 -0800
+++ mm/fs/ext4/dir.c	2007-11-28 14:11:23.532977270 -0800
@@ -132,7 +132,8 @@ static int ext4_readdir(struct file * fi
 		err = ext4_get_blocks_wrap(NULL, inode, blk, 1, &map_bh, 0, 0);
 		if (err > 0) {
 			pgoff_t index = map_bh.b_blocknr >>
-					(PAGE_CACHE_SHIFT - inode->i_blkbits);
+				(page_cache_size(inode->i_mapping)
+					- inode->i_blkbits);
 			if (!ra_has_index(&filp->f_ra, index))
 				page_cache_sync_readahead(
 					sb->s_bdev->bd_inode->i_mapping,
Index: mm/fs/ext4/inode.c
===================================================================
--- mm.orig/fs/ext4/inode.c	2007-11-28 12:24:24.965213091 -0800
+++ mm/fs/ext4/inode.c	2007-11-28 14:12:47.716740818 -0800
@@ -1110,8 +1110,8 @@ static int ext4_write_begin(struct file 
  	pgoff_t index;
  	unsigned from, to;
 
- 	index = pos >> PAGE_CACHE_SHIFT;
- 	from = pos & (PAGE_CACHE_SIZE - 1);
+ 	index = page_cache_index(mapping, pos);
+ 	from = page_cache_offset(mapping, pos);
  	to = from + len;
 
 retry:
@@ -1206,7 +1206,7 @@ static int ext4_ordered_write_end(struct
 	unsigned from, to;
 	int ret = 0, ret2;
 
-	from = pos & (PAGE_CACHE_SIZE - 1);
+	from = page_cache_offset(mapping, pos);
 	to = from + len;
 
 	ret = walk_page_buffers(handle, page_buffers(page),
@@ -1276,7 +1276,7 @@ static int ext4_journalled_write_end(str
 	int partial = 0;
 	unsigned from, to;
 
-	from = pos & (PAGE_CACHE_SIZE - 1);
+	from = page_cache_offset(mapping, pos);
 	to = from + len;
 
 	if (copied < len) {
@@ -1579,6 +1579,7 @@ static int ext4_ordered_writepage(struct
 	handle_t *handle = NULL;
 	int ret = 0;
 	int err;
+	int pagesize = page_cache_size(inode->i_mapping);
 
 	J_ASSERT(PageLocked(page));
 
@@ -1601,8 +1602,7 @@ static int ext4_ordered_writepage(struct
 				(1 << BH_Dirty)|(1 << BH_Uptodate));
 	}
 	page_bufs = page_buffers(page);
-	walk_page_buffers(handle, page_bufs, 0,
-			PAGE_CACHE_SIZE, NULL, bget_one);
+	walk_page_buffers(handle, page_bufs, 0, pagesize, NULL, bget_one);
 
 	ret = block_write_full_page(page, ext4_get_block, wbc);
 
@@ -1619,13 +1619,12 @@ static int ext4_ordered_writepage(struct
 	 * and generally junk.
 	 */
 	if (ret == 0) {
-		err = walk_page_buffers(handle, page_bufs, 0, PAGE_CACHE_SIZE,
+		err = walk_page_buffers(handle, page_bufs, 0, pagesize,
 					NULL, jbd2_journal_dirty_data_fn);
 		if (!ret)
 			ret = err;
 	}
-	walk_page_buffers(handle, page_bufs, 0,
-			PAGE_CACHE_SIZE, NULL, bput_one);
+	walk_page_buffers(handle, page_bufs, 0, pagesize, NULL, bput_one);
 	err = ext4_journal_stop(handle);
 	if (!ret)
 		ret = err;
@@ -1677,6 +1676,7 @@ static int ext4_journalled_writepage(str
 	handle_t *handle = NULL;
 	int ret = 0;
 	int err;
+	int pagesize = page_cache_size(inode->i_mapping);
 
 	if (ext4_journal_current_handle())
 		goto no_write;
@@ -1693,17 +1693,17 @@ static int ext4_journalled_writepage(str
 		 * doesn't seem much point in redirtying the page here.
 		 */
 		ClearPageChecked(page);
-		ret = block_prepare_write(page, 0, PAGE_CACHE_SIZE,
+		ret = block_prepare_write(page, 0, page_cache_size(mapping),
 					ext4_get_block);
 		if (ret != 0) {
 			ext4_journal_stop(handle);
 			goto out_unlock;
 		}
 		ret = walk_page_buffers(handle, page_buffers(page), 0,
-			PAGE_CACHE_SIZE, NULL, do_journal_get_write_access);
+			page_cache_size(mapping), NULL, do_journal_get_write_access);
 
 		err = walk_page_buffers(handle, page_buffers(page), 0,
-				PAGE_CACHE_SIZE, NULL, write_end_fn);
+			page_cache_size(mapping), NULL, write_end_fn);
 		if (ret == 0)
 			ret = err;
 		EXT4_I(inode)->i_state |= EXT4_STATE_JDATA;
@@ -1936,8 +1936,8 @@ void ext4_set_aops(struct inode *inode)
 int ext4_block_truncate_page(handle_t *handle, struct page *page,
 		struct address_space *mapping, loff_t from)
 {
-	ext4_fsblk_t index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	ext4_fsblk_t index = page_cache_index(mapping, from);
+	unsigned offset = page_cache_offset(mapping, from);
 	unsigned blocksize, length, pos;
 	ext4_lblk_t iblock;
 	struct inode *inode = mapping->host;
@@ -1946,7 +1946,8 @@ int ext4_block_truncate_page(handle_t *h
 
 	blocksize = inode->i_sb->s_blocksize;
 	length = blocksize - (offset & (blocksize - 1));
-	iblock = index << (PAGE_CACHE_SHIFT - inode->i_sb->s_blocksize_bits);
+	iblock = index <<
+		(page_cache_shift(mapping) - inode->i_sb->s_blocksize_bits);
 
 	/*
 	 * For "nobh" option,  we can only work if we don't need to
@@ -2426,7 +2427,7 @@ void ext4_truncate(struct inode *inode)
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
