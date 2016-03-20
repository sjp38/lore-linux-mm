Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id DC86B82F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:49:10 -0400 (EDT)
Received: by mail-pf0-f181.google.com with SMTP id x3so237575428pfb.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:49:10 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qx12si13425508pab.169.2016.03.20.11.41.47
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:48 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 33/71] ext4: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:40 +0300
Message-Id: <1458499278-1516-34-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: "Theodore Ts'o" <tytso@mit.edu>
Cc: Andreas Dilger <adilger.kernel@dilger.ca>
---
 fs/ext4/crypto.c      |   8 ++--
 fs/ext4/dir.c         |   4 +-
 fs/ext4/ext4.h        |   4 +-
 fs/ext4/file.c        |   4 +-
 fs/ext4/inline.c      |  18 ++++----
 fs/ext4/inode.c       | 118 +++++++++++++++++++++++++-------------------------
 fs/ext4/mballoc.c     |  40 ++++++++---------
 fs/ext4/move_extent.c |  16 +++----
 fs/ext4/page-io.c     |   4 +-
 fs/ext4/readpage.c    |  12 ++---
 fs/ext4/super.c       |   4 +-
 fs/ext4/symlink.c     |   4 +-
 12 files changed, 118 insertions(+), 118 deletions(-)

diff --git a/fs/ext4/crypto.c b/fs/ext4/crypto.c
index edc053a81914..2580ef3346ca 100644
--- a/fs/ext4/crypto.c
+++ b/fs/ext4/crypto.c
@@ -283,10 +283,10 @@ static int ext4_page_crypto(struct inode *inode,
 	       EXT4_XTS_TWEAK_SIZE - sizeof(index));
 
 	sg_init_table(&dst, 1);
-	sg_set_page(&dst, dest_page, PAGE_CACHE_SIZE, 0);
+	sg_set_page(&dst, dest_page, PAGE_SIZE, 0);
 	sg_init_table(&src, 1);
-	sg_set_page(&src, src_page, PAGE_CACHE_SIZE, 0);
-	skcipher_request_set_crypt(req, &src, &dst, PAGE_CACHE_SIZE,
+	sg_set_page(&src, src_page, PAGE_SIZE, 0);
+	skcipher_request_set_crypt(req, &src, &dst, PAGE_SIZE,
 				   xts_tweak);
 	if (rw == EXT4_DECRYPT)
 		res = crypto_skcipher_decrypt(req);
@@ -396,7 +396,7 @@ int ext4_encrypted_zeroout(struct inode *inode, ext4_lblk_t lblk,
 		 (unsigned long) inode->i_ino, lblk, len);
 #endif
 
-	BUG_ON(inode->i_sb->s_blocksize != PAGE_CACHE_SIZE);
+	BUG_ON(inode->i_sb->s_blocksize != PAGE_SIZE);
 
 	ctx = ext4_get_crypto_ctx(inode);
 	if (IS_ERR(ctx))
diff --git a/fs/ext4/dir.c b/fs/ext4/dir.c
index 33f5e2a50cf8..a887efeb7027 100644
--- a/fs/ext4/dir.c
+++ b/fs/ext4/dir.c
@@ -155,13 +155,13 @@ static int ext4_readdir(struct file *file, struct dir_context *ctx)
 		err = ext4_map_blocks(NULL, inode, &map, 0);
 		if (err > 0) {
 			pgoff_t index = map.m_pblk >>
-					(PAGE_CACHE_SHIFT - inode->i_blkbits);
+					(PAGE_SHIFT - inode->i_blkbits);
 			if (!ra_has_index(&file->f_ra, index))
 				page_cache_sync_readahead(
 					sb->s_bdev->bd_inode->i_mapping,
 					&file->f_ra, file,
 					index, 1);
-			file->f_ra.prev_pos = (loff_t)index << PAGE_CACHE_SHIFT;
+			file->f_ra.prev_pos = (loff_t)index << PAGE_SHIFT;
 			bh = ext4_bread(NULL, inode, map.m_lblk, 0);
 			if (IS_ERR(bh)) {
 				err = PTR_ERR(bh);
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 393689dfa1af..d96ec1dd22a9 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -1970,7 +1970,7 @@ ext4_rec_len_from_disk(__le16 dlen, unsigned blocksize)
 {
 	unsigned len = le16_to_cpu(dlen);
 
-#if (PAGE_CACHE_SIZE >= 65536)
+#if (PAGE_SIZE >= 65536)
 	if (len == EXT4_MAX_REC_LEN || len == 0)
 		return blocksize;
 	return (len & 65532) | ((len & 3) << 16);
@@ -1983,7 +1983,7 @@ static inline __le16 ext4_rec_len_to_disk(unsigned len, unsigned blocksize)
 {
 	if ((len > blocksize) || (blocksize > (1 << 18)) || (len & 3))
 		BUG();
-#if (PAGE_CACHE_SIZE >= 65536)
+#if (PAGE_SIZE >= 65536)
 	if (len < 65536)
 		return cpu_to_le16(len);
 	if (len == blocksize) {
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 6659e216385e..0caece398eb8 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -428,8 +428,8 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 	lastoff = startoff;
 	endoff = (loff_t)end_blk << blkbits;
 
-	index = startoff >> PAGE_CACHE_SHIFT;
-	end = endoff >> PAGE_CACHE_SHIFT;
+	index = startoff >> PAGE_SHIFT;
+	end = endoff >> PAGE_SHIFT;
 
 	pagevec_init(&pvec, 0);
 	do {
diff --git a/fs/ext4/inline.c b/fs/ext4/inline.c
index 7cbdd3752ba5..7bc6c855cc18 100644
--- a/fs/ext4/inline.c
+++ b/fs/ext4/inline.c
@@ -482,7 +482,7 @@ static int ext4_read_inline_page(struct inode *inode, struct page *page)
 	ret = ext4_read_inline_data(inode, kaddr, len, &iloc);
 	flush_dcache_page(page);
 	kunmap_atomic(kaddr);
-	zero_user_segment(page, len, PAGE_CACHE_SIZE);
+	zero_user_segment(page, len, PAGE_SIZE);
 	SetPageUptodate(page);
 	brelse(iloc.bh);
 
@@ -507,7 +507,7 @@ int ext4_readpage_inline(struct inode *inode, struct page *page)
 	if (!page->index)
 		ret = ext4_read_inline_page(inode, page);
 	else if (!PageUptodate(page)) {
-		zero_user_segment(page, 0, PAGE_CACHE_SIZE);
+		zero_user_segment(page, 0, PAGE_SIZE);
 		SetPageUptodate(page);
 	}
 
@@ -595,7 +595,7 @@ retry:
 
 	if (ret) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		page = NULL;
 		ext4_orphan_add(handle, inode);
 		up_write(&EXT4_I(inode)->xattr_sem);
@@ -621,7 +621,7 @@ retry:
 out:
 	if (page) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	if (sem_held)
 		up_write(&EXT4_I(inode)->xattr_sem);
@@ -690,7 +690,7 @@ int ext4_try_to_write_inline_data(struct address_space *mapping,
 	if (!ext4_has_inline_data(inode)) {
 		ret = 0;
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		goto out_up_read;
 	}
 
@@ -815,7 +815,7 @@ static int ext4_da_convert_inline_data_to_extent(struct address_space *mapping,
 	if (ret) {
 		up_read(&EXT4_I(inode)->xattr_sem);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		ext4_truncate_failed_write(inode);
 		return ret;
 	}
@@ -829,7 +829,7 @@ out:
 	up_read(&EXT4_I(inode)->xattr_sem);
 	if (page) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	return ret;
 }
@@ -919,7 +919,7 @@ retry_journal:
 out_release_page:
 	up_read(&EXT4_I(inode)->xattr_sem);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 out_journal:
 	ext4_journal_stop(handle);
 out:
@@ -947,7 +947,7 @@ int ext4_da_write_inline_data_end(struct inode *inode, loff_t pos,
 		i_size_changed = 1;
 	}
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	/*
 	 * Don't mark the inode dirty under page lock. First, it unnecessarily
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index b2e9576450eb..58ec44be2f42 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1057,7 +1057,7 @@ int do_journal_get_write_access(handle_t *handle,
 static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
 				  get_block_t *get_block)
 {
-	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned from = pos & (PAGE_SIZE - 1);
 	unsigned to = from + len;
 	struct inode *inode = page->mapping->host;
 	unsigned block_start, block_end;
@@ -1069,15 +1069,15 @@ static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
 	bool decrypt = false;
 
 	BUG_ON(!PageLocked(page));
-	BUG_ON(from > PAGE_CACHE_SIZE);
-	BUG_ON(to > PAGE_CACHE_SIZE);
+	BUG_ON(from > PAGE_SIZE);
+	BUG_ON(to > PAGE_SIZE);
 	BUG_ON(from > to);
 
 	if (!page_has_buffers(page))
 		create_empty_buffers(page, blocksize, 0);
 	head = page_buffers(page);
 	bbits = ilog2(blocksize);
-	block = (sector_t)page->index << (PAGE_CACHE_SHIFT - bbits);
+	block = (sector_t)page->index << (PAGE_SHIFT - bbits);
 
 	for (bh = head, block_start = 0; bh != head || !block_start;
 	    block++, block_start = block_end, bh = bh->b_this_page) {
@@ -1159,8 +1159,8 @@ static int ext4_write_begin(struct file *file, struct address_space *mapping,
 	 * we allocate blocks but write fails for some reason
 	 */
 	needed_blocks = ext4_writepage_trans_blocks(inode) + 1;
-	index = pos >> PAGE_CACHE_SHIFT;
-	from = pos & (PAGE_CACHE_SIZE - 1);
+	index = pos >> PAGE_SHIFT;
+	from = pos & (PAGE_SIZE - 1);
 	to = from + len;
 
 	if (ext4_test_inode_state(inode, EXT4_STATE_MAY_INLINE_DATA)) {
@@ -1188,7 +1188,7 @@ retry_grab:
 retry_journal:
 	handle = ext4_journal_start(inode, EXT4_HT_WRITE_PAGE, needed_blocks);
 	if (IS_ERR(handle)) {
-		page_cache_release(page);
+		put_page(page);
 		return PTR_ERR(handle);
 	}
 
@@ -1196,7 +1196,7 @@ retry_journal:
 	if (page->mapping != mapping) {
 		/* The page got truncated from under us */
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		ext4_journal_stop(handle);
 		goto retry_grab;
 	}
@@ -1252,7 +1252,7 @@ retry_journal:
 		if (ret == -ENOSPC &&
 		    ext4_should_retry_alloc(inode->i_sb, &retries))
 			goto retry_journal;
-		page_cache_release(page);
+		put_page(page);
 		return ret;
 	}
 	*pagep = page;
@@ -1295,7 +1295,7 @@ static int ext4_write_end(struct file *file,
 		ret = ext4_jbd2_file_inode(handle, inode);
 		if (ret) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			goto errout;
 		}
 	}
@@ -1315,7 +1315,7 @@ static int ext4_write_end(struct file *file,
 	 */
 	i_size_changed = ext4_update_inode_size(inode, pos + copied);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	if (old_size < pos)
 		pagecache_isize_extended(inode, old_size, pos);
@@ -1399,7 +1399,7 @@ static int ext4_journalled_write_end(struct file *file,
 	int size_changed = 0;
 
 	trace_ext4_journalled_write_end(inode, pos, len, copied);
-	from = pos & (PAGE_CACHE_SIZE - 1);
+	from = pos & (PAGE_SIZE - 1);
 	to = from + len;
 
 	BUG_ON(!ext4_handle_valid(handle));
@@ -1423,7 +1423,7 @@ static int ext4_journalled_write_end(struct file *file,
 	ext4_set_inode_state(inode, EXT4_STATE_JDATA);
 	EXT4_I(inode)->i_datasync_tid = handle->h_transaction->t_tid;
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	if (old_size < pos)
 		pagecache_isize_extended(inode, old_size, pos);
@@ -1537,7 +1537,7 @@ static void ext4_da_page_release_reservation(struct page *page,
 	int num_clusters;
 	ext4_fsblk_t lblk;
 
-	BUG_ON(stop > PAGE_CACHE_SIZE || stop < length);
+	BUG_ON(stop > PAGE_SIZE || stop < length);
 
 	head = page_buffers(page);
 	bh = head;
@@ -1553,7 +1553,7 @@ static void ext4_da_page_release_reservation(struct page *page,
 			clear_buffer_delay(bh);
 		} else if (contiguous_blks) {
 			lblk = page->index <<
-			       (PAGE_CACHE_SHIFT - inode->i_blkbits);
+			       (PAGE_SHIFT - inode->i_blkbits);
 			lblk += (curr_off >> inode->i_blkbits) -
 				contiguous_blks;
 			ext4_es_remove_extent(inode, lblk, contiguous_blks);
@@ -1563,7 +1563,7 @@ static void ext4_da_page_release_reservation(struct page *page,
 	} while ((bh = bh->b_this_page) != head);
 
 	if (contiguous_blks) {
-		lblk = page->index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+		lblk = page->index << (PAGE_SHIFT - inode->i_blkbits);
 		lblk += (curr_off >> inode->i_blkbits) - contiguous_blks;
 		ext4_es_remove_extent(inode, lblk, contiguous_blks);
 	}
@@ -1572,7 +1572,7 @@ static void ext4_da_page_release_reservation(struct page *page,
 	 * need to release the reserved space for that cluster. */
 	num_clusters = EXT4_NUM_B2C(sbi, to_release);
 	while (num_clusters > 0) {
-		lblk = (page->index << (PAGE_CACHE_SHIFT - inode->i_blkbits)) +
+		lblk = (page->index << (PAGE_SHIFT - inode->i_blkbits)) +
 			((num_clusters - 1) << sbi->s_cluster_bits);
 		if (sbi->s_cluster_ratio == 1 ||
 		    !ext4_find_delalloc_cluster(inode, lblk))
@@ -1619,8 +1619,8 @@ static void mpage_release_unused_pages(struct mpage_da_data *mpd,
 	end   = mpd->next_page - 1;
 	if (invalidate) {
 		ext4_lblk_t start, last;
-		start = index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
-		last = end << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+		start = index << (PAGE_SHIFT - inode->i_blkbits);
+		last = end << (PAGE_SHIFT - inode->i_blkbits);
 		ext4_es_remove_extent(inode, start, last - start + 1);
 	}
 
@@ -1636,7 +1636,7 @@ static void mpage_release_unused_pages(struct mpage_da_data *mpd,
 			BUG_ON(!PageLocked(page));
 			BUG_ON(PageWriteback(page));
 			if (invalidate) {
-				block_invalidatepage(page, 0, PAGE_CACHE_SIZE);
+				block_invalidatepage(page, 0, PAGE_SIZE);
 				ClearPageUptodate(page);
 			}
 			unlock_page(page);
@@ -2007,10 +2007,10 @@ static int ext4_writepage(struct page *page,
 
 	trace_ext4_writepage(page);
 	size = i_size_read(inode);
-	if (page->index == size >> PAGE_CACHE_SHIFT)
-		len = size & ~PAGE_CACHE_MASK;
+	if (page->index == size >> PAGE_SHIFT)
+		len = size & ~PAGE_MASK;
 	else
-		len = PAGE_CACHE_SIZE;
+		len = PAGE_SIZE;
 
 	page_bufs = page_buffers(page);
 	/*
@@ -2034,7 +2034,7 @@ static int ext4_writepage(struct page *page,
 				   ext4_bh_delay_or_unwritten)) {
 		redirty_page_for_writepage(wbc, page);
 		if ((current->flags & PF_MEMALLOC) ||
-		    (inode->i_sb->s_blocksize == PAGE_CACHE_SIZE)) {
+		    (inode->i_sb->s_blocksize == PAGE_SIZE)) {
 			/*
 			 * For memory cleaning there's no point in writing only
 			 * some buffers. So just bail out. Warn if we came here
@@ -2076,10 +2076,10 @@ static int mpage_submit_page(struct mpage_da_data *mpd, struct page *page)
 	int err;
 
 	BUG_ON(page->index != mpd->first_page);
-	if (page->index == size >> PAGE_CACHE_SHIFT)
-		len = size & ~PAGE_CACHE_MASK;
+	if (page->index == size >> PAGE_SHIFT)
+		len = size & ~PAGE_MASK;
 	else
-		len = PAGE_CACHE_SIZE;
+		len = PAGE_SIZE;
 	clear_page_dirty_for_io(page);
 	err = ext4_bio_write_page(&mpd->io_submit, page, len, mpd->wbc, false);
 	if (!err)
@@ -2213,7 +2213,7 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
 	int nr_pages, i;
 	struct inode *inode = mpd->inode;
 	struct buffer_head *head, *bh;
-	int bpp_bits = PAGE_CACHE_SHIFT - inode->i_blkbits;
+	int bpp_bits = PAGE_SHIFT - inode->i_blkbits;
 	pgoff_t start, end;
 	ext4_lblk_t lblk;
 	sector_t pblock;
@@ -2274,7 +2274,7 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
 			 * supports blocksize < pagesize as we will try to
 			 * convert potentially unmapped parts of inode.
 			 */
-			mpd->io_submit.io_end->size += PAGE_CACHE_SIZE;
+			mpd->io_submit.io_end->size += PAGE_SIZE;
 			/* Page fully mapped - let IO run! */
 			err = mpage_submit_page(mpd, page);
 			if (err < 0) {
@@ -2426,7 +2426,7 @@ update_disksize:
 	 * Update on-disk size after IO is submitted.  Races with
 	 * truncate are avoided by checking i_size under i_data_sem.
 	 */
-	disksize = ((loff_t)mpd->first_page) << PAGE_CACHE_SHIFT;
+	disksize = ((loff_t)mpd->first_page) << PAGE_SHIFT;
 	if (disksize > EXT4_I(inode)->i_disksize) {
 		int err2;
 		loff_t i_size;
@@ -2562,7 +2562,7 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 			mpd->next_page = page->index + 1;
 			/* Add all dirty buffers to mpd */
 			lblk = ((ext4_lblk_t)page->index) <<
-				(PAGE_CACHE_SHIFT - blkbits);
+				(PAGE_SHIFT - blkbits);
 			head = page_buffers(page);
 			err = mpage_process_page_bufs(mpd, head, head, lblk);
 			if (err <= 0)
@@ -2647,7 +2647,7 @@ static int ext4_writepages(struct address_space *mapping,
 		 * We may need to convert up to one extent per block in
 		 * the page and we may dirty the inode.
 		 */
-		rsv_blocks = 1 + (PAGE_CACHE_SIZE >> inode->i_blkbits);
+		rsv_blocks = 1 + (PAGE_SIZE >> inode->i_blkbits);
 	}
 
 	/*
@@ -2678,8 +2678,8 @@ static int ext4_writepages(struct address_space *mapping,
 		mpd.first_page = writeback_index;
 		mpd.last_page = -1;
 	} else {
-		mpd.first_page = wbc->range_start >> PAGE_CACHE_SHIFT;
-		mpd.last_page = wbc->range_end >> PAGE_CACHE_SHIFT;
+		mpd.first_page = wbc->range_start >> PAGE_SHIFT;
+		mpd.last_page = wbc->range_end >> PAGE_SHIFT;
 	}
 
 	mpd.inode = inode;
@@ -2838,7 +2838,7 @@ static int ext4_da_write_begin(struct file *file, struct address_space *mapping,
 	struct inode *inode = mapping->host;
 	handle_t *handle;
 
-	index = pos >> PAGE_CACHE_SHIFT;
+	index = pos >> PAGE_SHIFT;
 
 	if (ext4_nonda_switch(inode->i_sb)) {
 		*fsdata = (void *)FALL_BACK_TO_NONDELALLOC;
@@ -2881,7 +2881,7 @@ retry_journal:
 	handle = ext4_journal_start(inode, EXT4_HT_WRITE_PAGE,
 				ext4_da_write_credits(inode, pos, len));
 	if (IS_ERR(handle)) {
-		page_cache_release(page);
+		put_page(page);
 		return PTR_ERR(handle);
 	}
 
@@ -2889,7 +2889,7 @@ retry_journal:
 	if (page->mapping != mapping) {
 		/* The page got truncated from under us */
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		ext4_journal_stop(handle);
 		goto retry_grab;
 	}
@@ -2917,7 +2917,7 @@ retry_journal:
 		    ext4_should_retry_alloc(inode->i_sb, &retries))
 			goto retry_journal;
 
-		page_cache_release(page);
+		put_page(page);
 		return ret;
 	}
 
@@ -2965,7 +2965,7 @@ static int ext4_da_write_end(struct file *file,
 				      len, copied, page, fsdata);
 
 	trace_ext4_da_write_end(inode, pos, len, copied);
-	start = pos & (PAGE_CACHE_SIZE - 1);
+	start = pos & (PAGE_SIZE - 1);
 	end = start + copied - 1;
 
 	/*
@@ -3187,7 +3187,7 @@ static int __ext4_journalled_invalidatepage(struct page *page,
 	/*
 	 * If it's a full truncate we just forget about the pending dirtying
 	 */
-	if (offset == 0 && length == PAGE_CACHE_SIZE)
+	if (offset == 0 && length == PAGE_SIZE)
 		ClearPageChecked(page);
 
 	return jbd2_journal_invalidatepage(journal, page, offset, length);
@@ -3546,8 +3546,8 @@ void ext4_set_aops(struct inode *inode)
 static int __ext4_block_zero_page_range(handle_t *handle,
 		struct address_space *mapping, loff_t from, loff_t length)
 {
-	ext4_fsblk_t index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	ext4_fsblk_t index = from >> PAGE_SHIFT;
+	unsigned offset = from & (PAGE_SIZE-1);
 	unsigned blocksize, pos;
 	ext4_lblk_t iblock;
 	struct inode *inode = mapping->host;
@@ -3555,14 +3555,14 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 	struct page *page;
 	int err = 0;
 
-	page = find_or_create_page(mapping, from >> PAGE_CACHE_SHIFT,
+	page = find_or_create_page(mapping, from >> PAGE_SHIFT,
 				   mapping_gfp_constraint(mapping, ~__GFP_FS));
 	if (!page)
 		return -ENOMEM;
 
 	blocksize = inode->i_sb->s_blocksize;
 
-	iblock = index << (PAGE_CACHE_SHIFT - inode->i_sb->s_blocksize_bits);
+	iblock = index << (PAGE_SHIFT - inode->i_sb->s_blocksize_bits);
 
 	if (!page_has_buffers(page))
 		create_empty_buffers(page, blocksize, 0);
@@ -3604,7 +3604,7 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 		    ext4_encrypted_inode(inode)) {
 			/* We expect the key to be set. */
 			BUG_ON(!ext4_has_encryption_key(inode));
-			BUG_ON(blocksize != PAGE_CACHE_SIZE);
+			BUG_ON(blocksize != PAGE_SIZE);
 			WARN_ON_ONCE(ext4_decrypt(page));
 		}
 	}
@@ -3628,7 +3628,7 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 
 unlock:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return err;
 }
 
@@ -3643,7 +3643,7 @@ static int ext4_block_zero_page_range(handle_t *handle,
 		struct address_space *mapping, loff_t from, loff_t length)
 {
 	struct inode *inode = mapping->host;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	unsigned offset = from & (PAGE_SIZE-1);
 	unsigned blocksize = inode->i_sb->s_blocksize;
 	unsigned max = blocksize - (offset & (blocksize - 1));
 
@@ -3668,7 +3668,7 @@ static int ext4_block_zero_page_range(handle_t *handle,
 static int ext4_block_truncate_page(handle_t *handle,
 		struct address_space *mapping, loff_t from)
 {
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	unsigned offset = from & (PAGE_SIZE-1);
 	unsigned length;
 	unsigned blocksize;
 	struct inode *inode = mapping->host;
@@ -3806,7 +3806,7 @@ int ext4_punch_hole(struct inode *inode, loff_t offset, loff_t length)
 	 */
 	if (offset + length > inode->i_size) {
 		length = inode->i_size +
-		   PAGE_CACHE_SIZE - (inode->i_size & (PAGE_CACHE_SIZE - 1)) -
+		   PAGE_SIZE - (inode->i_size & (PAGE_SIZE - 1)) -
 		   offset;
 	}
 
@@ -4881,23 +4881,23 @@ static void ext4_wait_for_tail_page_commit(struct inode *inode)
 	tid_t commit_tid = 0;
 	int ret;
 
-	offset = inode->i_size & (PAGE_CACHE_SIZE - 1);
+	offset = inode->i_size & (PAGE_SIZE - 1);
 	/*
 	 * All buffers in the last page remain valid? Then there's nothing to
-	 * do. We do the check mainly to optimize the common PAGE_CACHE_SIZE ==
+	 * do. We do the check mainly to optimize the common PAGE_SIZE ==
 	 * blocksize case
 	 */
-	if (offset > PAGE_CACHE_SIZE - (1 << inode->i_blkbits))
+	if (offset > PAGE_SIZE - (1 << inode->i_blkbits))
 		return;
 	while (1) {
 		page = find_lock_page(inode->i_mapping,
-				      inode->i_size >> PAGE_CACHE_SHIFT);
+				      inode->i_size >> PAGE_SHIFT);
 		if (!page)
 			return;
 		ret = __ext4_journalled_invalidatepage(page, offset,
-						PAGE_CACHE_SIZE - offset);
+						PAGE_SIZE - offset);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		if (ret != -EBUSY)
 			return;
 		commit_tid = 0;
@@ -5536,10 +5536,10 @@ int ext4_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 		goto out;
 	}
 
-	if (page->index == size >> PAGE_CACHE_SHIFT)
-		len = size & ~PAGE_CACHE_MASK;
+	if (page->index == size >> PAGE_SHIFT)
+		len = size & ~PAGE_MASK;
 	else
-		len = PAGE_CACHE_SIZE;
+		len = PAGE_SIZE;
 	/*
 	 * Return if we have all the buffers mapped. This avoids the need to do
 	 * journal_start/journal_stop which can block and take a long time
@@ -5570,7 +5570,7 @@ retry_alloc:
 	ret = block_page_mkwrite(vma, vmf, get_block);
 	if (!ret && ext4_should_journal_data(inode)) {
 		if (ext4_walk_page_buffers(handle, page_buffers(page), 0,
-			  PAGE_CACHE_SIZE, NULL, do_journal_get_write_access)) {
+			  PAGE_SIZE, NULL, do_journal_get_write_access)) {
 			unlock_page(page);
 			ret = VM_FAULT_SIGBUS;
 			ext4_journal_stop(handle);
diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
index 50e05df28f66..eeeade76012e 100644
--- a/fs/ext4/mballoc.c
+++ b/fs/ext4/mballoc.c
@@ -119,7 +119,7 @@ MODULE_PARM_DESC(mballoc_debug, "Debugging level for ext4's mballoc");
  *
  *
  * one block each for bitmap and buddy information.  So for each group we
- * take up 2 blocks. A page can contain blocks_per_page (PAGE_CACHE_SIZE /
+ * take up 2 blocks. A page can contain blocks_per_page (PAGE_SIZE /
  * blocksize) blocks.  So it can have information regarding groups_per_page
  * which is blocks_per_page/2
  *
@@ -807,7 +807,7 @@ static void mb_regenerate_buddy(struct ext4_buddy *e4b)
  *
  * one block each for bitmap and buddy information.
  * So for each group we take up 2 blocks. A page can
- * contain blocks_per_page (PAGE_CACHE_SIZE / blocksize)  blocks.
+ * contain blocks_per_page (PAGE_SIZE / blocksize)  blocks.
  * So it can have information regarding groups_per_page which
  * is blocks_per_page/2
  *
@@ -839,7 +839,7 @@ static int ext4_mb_init_cache(struct page *page, char *incore, gfp_t gfp)
 	sb = inode->i_sb;
 	ngroups = ext4_get_groups_count(sb);
 	blocksize = 1 << inode->i_blkbits;
-	blocks_per_page = PAGE_CACHE_SIZE / blocksize;
+	blocks_per_page = PAGE_SIZE / blocksize;
 
 	groups_per_page = blocks_per_page >> 1;
 	if (groups_per_page == 0)
@@ -993,7 +993,7 @@ static int ext4_mb_get_buddy_page_lock(struct super_block *sb,
 	e4b->bd_buddy_page = NULL;
 	e4b->bd_bitmap_page = NULL;
 
-	blocks_per_page = PAGE_CACHE_SIZE / sb->s_blocksize;
+	blocks_per_page = PAGE_SIZE / sb->s_blocksize;
 	/*
 	 * the buddy cache inode stores the block bitmap
 	 * and buddy information in consecutive blocks.
@@ -1028,11 +1028,11 @@ static void ext4_mb_put_buddy_page_lock(struct ext4_buddy *e4b)
 {
 	if (e4b->bd_bitmap_page) {
 		unlock_page(e4b->bd_bitmap_page);
-		page_cache_release(e4b->bd_bitmap_page);
+		put_page(e4b->bd_bitmap_page);
 	}
 	if (e4b->bd_buddy_page) {
 		unlock_page(e4b->bd_buddy_page);
-		page_cache_release(e4b->bd_buddy_page);
+		put_page(e4b->bd_buddy_page);
 	}
 }
 
@@ -1125,7 +1125,7 @@ ext4_mb_load_buddy_gfp(struct super_block *sb, ext4_group_t group,
 	might_sleep();
 	mb_debug(1, "load group %u\n", group);
 
-	blocks_per_page = PAGE_CACHE_SIZE / sb->s_blocksize;
+	blocks_per_page = PAGE_SIZE / sb->s_blocksize;
 	grp = ext4_get_group_info(sb, group);
 
 	e4b->bd_blkbits = sb->s_blocksize_bits;
@@ -1167,7 +1167,7 @@ ext4_mb_load_buddy_gfp(struct super_block *sb, ext4_group_t group,
 			 * is yet to initialize the same. So
 			 * wait for it to initialize.
 			 */
-			page_cache_release(page);
+			put_page(page);
 		page = find_or_create_page(inode->i_mapping, pnum, gfp);
 		if (page) {
 			BUG_ON(page->mapping != inode->i_mapping);
@@ -1203,7 +1203,7 @@ ext4_mb_load_buddy_gfp(struct super_block *sb, ext4_group_t group,
 	page = find_get_page_flags(inode->i_mapping, pnum, FGP_ACCESSED);
 	if (page == NULL || !PageUptodate(page)) {
 		if (page)
-			page_cache_release(page);
+			put_page(page);
 		page = find_or_create_page(inode->i_mapping, pnum, gfp);
 		if (page) {
 			BUG_ON(page->mapping != inode->i_mapping);
@@ -1238,11 +1238,11 @@ ext4_mb_load_buddy_gfp(struct super_block *sb, ext4_group_t group,
 
 err:
 	if (page)
-		page_cache_release(page);
+		put_page(page);
 	if (e4b->bd_bitmap_page)
-		page_cache_release(e4b->bd_bitmap_page);
+		put_page(e4b->bd_bitmap_page);
 	if (e4b->bd_buddy_page)
-		page_cache_release(e4b->bd_buddy_page);
+		put_page(e4b->bd_buddy_page);
 	e4b->bd_buddy = NULL;
 	e4b->bd_bitmap = NULL;
 	return ret;
@@ -1257,9 +1257,9 @@ static int ext4_mb_load_buddy(struct super_block *sb, ext4_group_t group,
 static void ext4_mb_unload_buddy(struct ext4_buddy *e4b)
 {
 	if (e4b->bd_bitmap_page)
-		page_cache_release(e4b->bd_bitmap_page);
+		put_page(e4b->bd_bitmap_page);
 	if (e4b->bd_buddy_page)
-		page_cache_release(e4b->bd_buddy_page);
+		put_page(e4b->bd_buddy_page);
 }
 
 
@@ -2833,8 +2833,8 @@ static void ext4_free_data_callback(struct super_block *sb,
 		/* No more items in the per group rb tree
 		 * balance refcounts from ext4_mb_free_metadata()
 		 */
-		page_cache_release(e4b.bd_buddy_page);
-		page_cache_release(e4b.bd_bitmap_page);
+		put_page(e4b.bd_buddy_page);
+		put_page(e4b.bd_bitmap_page);
 	}
 	ext4_unlock_group(sb, entry->efd_group);
 	kmem_cache_free(ext4_free_data_cachep, entry);
@@ -4385,9 +4385,9 @@ static int ext4_mb_release_context(struct ext4_allocation_context *ac)
 		ext4_mb_put_pa(ac, ac->ac_sb, pa);
 	}
 	if (ac->ac_bitmap_page)
-		page_cache_release(ac->ac_bitmap_page);
+		put_page(ac->ac_bitmap_page);
 	if (ac->ac_buddy_page)
-		page_cache_release(ac->ac_buddy_page);
+		put_page(ac->ac_buddy_page);
 	if (ac->ac_flags & EXT4_MB_HINT_GROUP_ALLOC)
 		mutex_unlock(&ac->ac_lg->lg_mutex);
 	ext4_mb_collect_stats(ac);
@@ -4599,8 +4599,8 @@ ext4_mb_free_metadata(handle_t *handle, struct ext4_buddy *e4b,
 		 * otherwise we'll refresh it from
 		 * on-disk bitmap and lose not-yet-available
 		 * blocks */
-		page_cache_get(e4b->bd_buddy_page);
-		page_cache_get(e4b->bd_bitmap_page);
+		get_page(e4b->bd_buddy_page);
+		get_page(e4b->bd_bitmap_page);
 	}
 	while (*n) {
 		parent = *n;
diff --git a/fs/ext4/move_extent.c b/fs/ext4/move_extent.c
index 4098acc701c3..675b67e5d5c2 100644
--- a/fs/ext4/move_extent.c
+++ b/fs/ext4/move_extent.c
@@ -156,7 +156,7 @@ mext_page_double_lock(struct inode *inode1, struct inode *inode2,
 	page[1] = grab_cache_page_write_begin(mapping[1], index2, fl);
 	if (!page[1]) {
 		unlock_page(page[0]);
-		page_cache_release(page[0]);
+		put_page(page[0]);
 		return -ENOMEM;
 	}
 	/*
@@ -192,7 +192,7 @@ mext_page_mkuptodate(struct page *page, unsigned from, unsigned to)
 		create_empty_buffers(page, blocksize, 0);
 
 	head = page_buffers(page);
-	block = (sector_t)page->index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	block = (sector_t)page->index << (PAGE_SHIFT - inode->i_blkbits);
 	for (bh = head, block_start = 0; bh != head || !block_start;
 	     block++, block_start = block_end, bh = bh->b_this_page) {
 		block_end = block_start + blocksize;
@@ -268,7 +268,7 @@ move_extent_per_page(struct file *o_filp, struct inode *donor_inode,
 	int i, err2, jblocks, retries = 0;
 	int replaced_count = 0;
 	int from = data_offset_in_page << orig_inode->i_blkbits;
-	int blocks_per_page = PAGE_CACHE_SIZE >> orig_inode->i_blkbits;
+	int blocks_per_page = PAGE_SIZE >> orig_inode->i_blkbits;
 	struct super_block *sb = orig_inode->i_sb;
 	struct buffer_head *bh = NULL;
 
@@ -404,9 +404,9 @@ data_copy:
 
 unlock_pages:
 	unlock_page(pagep[0]);
-	page_cache_release(pagep[0]);
+	put_page(pagep[0]);
 	unlock_page(pagep[1]);
-	page_cache_release(pagep[1]);
+	put_page(pagep[1]);
 stop_journal:
 	ext4_journal_stop(handle);
 	if (*err == -ENOSPC &&
@@ -554,7 +554,7 @@ ext4_move_extents(struct file *o_filp, struct file *d_filp, __u64 orig_blk,
 	struct inode *orig_inode = file_inode(o_filp);
 	struct inode *donor_inode = file_inode(d_filp);
 	struct ext4_ext_path *path = NULL;
-	int blocks_per_page = PAGE_CACHE_SIZE >> orig_inode->i_blkbits;
+	int blocks_per_page = PAGE_SIZE >> orig_inode->i_blkbits;
 	ext4_lblk_t o_end, o_start = orig_blk;
 	ext4_lblk_t d_start = donor_blk;
 	int ret;
@@ -648,9 +648,9 @@ ext4_move_extents(struct file *o_filp, struct file *d_filp, __u64 orig_blk,
 		if (o_end - o_start < cur_len)
 			cur_len = o_end - o_start;
 
-		orig_page_index = o_start >> (PAGE_CACHE_SHIFT -
+		orig_page_index = o_start >> (PAGE_SHIFT -
 					       orig_inode->i_blkbits);
-		donor_page_index = d_start >> (PAGE_CACHE_SHIFT -
+		donor_page_index = d_start >> (PAGE_SHIFT -
 					       donor_inode->i_blkbits);
 		offset_in_page = o_start % blocks_per_page;
 		if (cur_len > blocks_per_page- offset_in_page)
diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index 349d7aa04fe7..741599a011c1 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -442,8 +442,8 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 	 * the page size, the remaining memory is zeroed when mapped, and
 	 * writes to that region are not written out to the file."
 	 */
-	if (len < PAGE_CACHE_SIZE)
-		zero_user_segment(page, len, PAGE_CACHE_SIZE);
+	if (len < PAGE_SIZE)
+		zero_user_segment(page, len, PAGE_SIZE);
 	/*
 	 * In the first loop we prepare and mark buffers to submit. We have to
 	 * mark all buffers in the page before submitting so that
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index 5dc5e95063de..f24e7299e1c8 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -23,7 +23,7 @@
  *
  * then this code just gives up and calls the buffer_head-based read function.
  * It does handle a page which has holes at the end - that is a common case:
- * the end-of-file on blocksize < PAGE_CACHE_SIZE setups.
+ * the end-of-file on blocksize < PAGE_SIZE setups.
  *
  */
 
@@ -140,7 +140,7 @@ int ext4_mpage_readpages(struct address_space *mapping,
 
 	struct inode *inode = mapping->host;
 	const unsigned blkbits = inode->i_blkbits;
-	const unsigned blocks_per_page = PAGE_CACHE_SIZE >> blkbits;
+	const unsigned blocks_per_page = PAGE_SIZE >> blkbits;
 	const unsigned blocksize = 1 << blkbits;
 	sector_t block_in_file;
 	sector_t last_block;
@@ -173,7 +173,7 @@ int ext4_mpage_readpages(struct address_space *mapping,
 		if (page_has_buffers(page))
 			goto confused;
 
-		block_in_file = (sector_t)page->index << (PAGE_CACHE_SHIFT - blkbits);
+		block_in_file = (sector_t)page->index << (PAGE_SHIFT - blkbits);
 		last_block = block_in_file + nr_pages * blocks_per_page;
 		last_block_in_file = (i_size_read(inode) + blocksize - 1) >> blkbits;
 		if (last_block > last_block_in_file)
@@ -217,7 +217,7 @@ int ext4_mpage_readpages(struct address_space *mapping,
 				set_error_page:
 					SetPageError(page);
 					zero_user_segment(page, 0,
-							  PAGE_CACHE_SIZE);
+							  PAGE_SIZE);
 					unlock_page(page);
 					goto next_page;
 				}
@@ -250,7 +250,7 @@ int ext4_mpage_readpages(struct address_space *mapping,
 		}
 		if (first_hole != blocks_per_page) {
 			zero_user_segment(page, first_hole << blkbits,
-					  PAGE_CACHE_SIZE);
+					  PAGE_SIZE);
 			if (first_hole == 0) {
 				SetPageUptodate(page);
 				unlock_page(page);
@@ -319,7 +319,7 @@ int ext4_mpage_readpages(struct address_space *mapping,
 			unlock_page(page);
 	next_page:
 		if (pages)
-			page_cache_release(page);
+			put_page(page);
 	}
 	BUG_ON(pages && !list_empty(pages));
 	if (bio)
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 99996e9a8f57..75b229414ee8 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1782,7 +1782,7 @@ static int parse_options(char *options, struct super_block *sb,
 		int blocksize =
 			BLOCK_SIZE << le32_to_cpu(sbi->s_es->s_log_block_size);
 
-		if (blocksize < PAGE_CACHE_SIZE) {
+		if (blocksize < PAGE_SIZE) {
 			ext4_msg(sb, KERN_ERR, "can't mount with "
 				 "dioread_nolock if block size != PAGE_SIZE");
 			return 0;
@@ -3806,7 +3806,7 @@ no_journal:
 	}
 
 	if ((DUMMY_ENCRYPTION_ENABLED(sbi) || ext4_has_feature_encrypt(sb)) &&
-	    (blocksize != PAGE_CACHE_SIZE)) {
+	    (blocksize != PAGE_SIZE)) {
 		ext4_msg(sb, KERN_ERR,
 			 "Unsupported blocksize for fs encryption");
 		goto failed_mount_wq;
diff --git a/fs/ext4/symlink.c b/fs/ext4/symlink.c
index 6f7ee30a89ce..75ed5c2f0c16 100644
--- a/fs/ext4/symlink.c
+++ b/fs/ext4/symlink.c
@@ -80,12 +80,12 @@ static const char *ext4_encrypted_get_link(struct dentry *dentry,
 	if (res <= plen)
 		paddr[res] = '\0';
 	if (cpage)
-		page_cache_release(cpage);
+		put_page(cpage);
 	set_delayed_call(done, kfree_link, paddr);
 	return paddr;
 errout:
 	if (cpage)
-		page_cache_release(cpage);
+		put_page(cpage);
 	kfree(paddr);
 	return ERR_PTR(res);
 }
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
