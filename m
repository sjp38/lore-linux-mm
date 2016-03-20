Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7C97882F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:49:45 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id 4so106673983pfd.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:49:45 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id oi7si1467849pab.183.2016.03.20.11.41.47
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 34/71] f2fs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:41 +0300
Message-Id: <1458499278-1516-35-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Changman Lee <cm224.lee@samsung.com>, Chao Yu <chao2.yu@samsung.com>

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
Cc: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Changman Lee <cm224.lee@samsung.com>
Cc: Chao Yu <chao2.yu@samsung.com>
---
 fs/f2fs/crypto.c        |  6 ++--
 fs/f2fs/data.c          | 50 ++++++++++++++++-----------------
 fs/f2fs/debug.c         |  6 ++--
 fs/f2fs/dir.c           |  4 +--
 fs/f2fs/f2fs.h          |  2 +-
 fs/f2fs/file.c          | 74 ++++++++++++++++++++++++-------------------------
 fs/f2fs/inline.c        | 12 ++++----
 fs/f2fs/namei.c         |  4 +--
 fs/f2fs/node.c          | 10 +++----
 fs/f2fs/recovery.c      |  2 +-
 fs/f2fs/segment.c       | 18 ++++++------
 fs/f2fs/super.c         |  4 +--
 include/linux/f2fs_fs.h |  4 +--
 13 files changed, 98 insertions(+), 98 deletions(-)

diff --git a/fs/f2fs/crypto.c b/fs/f2fs/crypto.c
index 95c5cf039711..da186961a5f0 100644
--- a/fs/f2fs/crypto.c
+++ b/fs/f2fs/crypto.c
@@ -350,10 +350,10 @@ static int f2fs_page_crypto(struct f2fs_crypto_ctx *ctx,
 			F2FS_XTS_TWEAK_SIZE - sizeof(index));
 
 	sg_init_table(&dst, 1);
-	sg_set_page(&dst, dest_page, PAGE_CACHE_SIZE, 0);
+	sg_set_page(&dst, dest_page, PAGE_SIZE, 0);
 	sg_init_table(&src, 1);
-	sg_set_page(&src, src_page, PAGE_CACHE_SIZE, 0);
-	skcipher_request_set_crypt(req, &src, &dst, PAGE_CACHE_SIZE,
+	sg_set_page(&src, src_page, PAGE_SIZE, 0);
+	skcipher_request_set_crypt(req, &src, &dst, PAGE_SIZE,
 				   xts_tweak);
 	if (rw == F2FS_DECRYPT)
 		res = crypto_skcipher_decrypt(req);
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 5c06db17e41f..8654e83bcea1 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -153,7 +153,7 @@ int f2fs_submit_page_bio(struct f2fs_io_info *fio)
 	/* Allocate a new bio */
 	bio = __bio_alloc(fio->sbi, fio->blk_addr, 1, is_read_io(fio->rw));
 
-	if (bio_add_page(bio, page, PAGE_CACHE_SIZE, 0) < PAGE_CACHE_SIZE) {
+	if (bio_add_page(bio, page, PAGE_SIZE, 0) < PAGE_SIZE) {
 		bio_put(bio);
 		return -EFAULT;
 	}
@@ -192,8 +192,8 @@ alloc_new:
 
 	bio_page = fio->encrypted_page ? fio->encrypted_page : fio->page;
 
-	if (bio_add_page(io->bio, bio_page, PAGE_CACHE_SIZE, 0) <
-							PAGE_CACHE_SIZE) {
+	if (bio_add_page(io->bio, bio_page, PAGE_SIZE, 0) <
+							PAGE_SIZE) {
 		__submit_merged_bio(io);
 		goto alloc_new;
 	}
@@ -326,7 +326,7 @@ got_it:
 	 * see, f2fs_add_link -> get_new_data_page -> init_inode_metadata.
 	 */
 	if (dn.data_blkaddr == NEW_ADDR) {
-		zero_user_segment(page, 0, PAGE_CACHE_SIZE);
+		zero_user_segment(page, 0, PAGE_SIZE);
 		SetPageUptodate(page);
 		unlock_page(page);
 		return page;
@@ -437,7 +437,7 @@ struct page *get_new_data_page(struct inode *inode,
 		goto got_it;
 
 	if (dn.data_blkaddr == NEW_ADDR) {
-		zero_user_segment(page, 0, PAGE_CACHE_SIZE);
+		zero_user_segment(page, 0, PAGE_SIZE);
 		SetPageUptodate(page);
 	} else {
 		f2fs_put_page(page, 1);
@@ -450,8 +450,8 @@ struct page *get_new_data_page(struct inode *inode,
 	}
 got_it:
 	if (new_i_size && i_size_read(inode) <
-				((loff_t)(index + 1) << PAGE_CACHE_SHIFT)) {
-		i_size_write(inode, ((loff_t)(index + 1) << PAGE_CACHE_SHIFT));
+				((loff_t)(index + 1) << PAGE_SHIFT)) {
+		i_size_write(inode, ((loff_t)(index + 1) << PAGE_SHIFT));
 		/* Only the directory inode sets new_i_size */
 		set_inode_flag(F2FS_I(inode), FI_UPDATE_DIR);
 	}
@@ -491,9 +491,9 @@ alloc:
 	/* update i_size */
 	fofs = start_bidx_of_node(ofs_of_node(dn->node_page), fi) +
 							dn->ofs_in_node;
-	if (i_size_read(dn->inode) < ((loff_t)(fofs + 1) << PAGE_CACHE_SHIFT))
+	if (i_size_read(dn->inode) < ((loff_t)(fofs + 1) << PAGE_SHIFT))
 		i_size_write(dn->inode,
-				((loff_t)(fofs + 1) << PAGE_CACHE_SHIFT));
+				((loff_t)(fofs + 1) << PAGE_SHIFT));
 	return 0;
 }
 
@@ -940,7 +940,7 @@ got_it:
 				goto confused;
 			}
 		} else {
-			zero_user_segment(page, 0, PAGE_CACHE_SIZE);
+			zero_user_segment(page, 0, PAGE_SIZE);
 			SetPageUptodate(page);
 			unlock_page(page);
 			goto next_page;
@@ -990,7 +990,7 @@ submit_and_realloc:
 		goto next_page;
 set_error_page:
 		SetPageError(page);
-		zero_user_segment(page, 0, PAGE_CACHE_SIZE);
+		zero_user_segment(page, 0, PAGE_SIZE);
 		unlock_page(page);
 		goto next_page;
 confused:
@@ -1001,7 +1001,7 @@ confused:
 		unlock_page(page);
 next_page:
 		if (pages)
-			page_cache_release(page);
+			put_page(page);
 	}
 	BUG_ON(pages && !list_empty(pages));
 	if (bio)
@@ -1107,7 +1107,7 @@ static int f2fs_write_data_page(struct page *page,
 	struct f2fs_sb_info *sbi = F2FS_I_SB(inode);
 	loff_t i_size = i_size_read(inode);
 	const pgoff_t end_index = ((unsigned long long) i_size)
-							>> PAGE_CACHE_SHIFT;
+							>> PAGE_SHIFT;
 	unsigned offset = 0;
 	bool need_balance_fs = false;
 	int err = 0;
@@ -1128,11 +1128,11 @@ static int f2fs_write_data_page(struct page *page,
 	 * If the offset is out-of-range of file size,
 	 * this page does not have to be written to disk.
 	 */
-	offset = i_size & (PAGE_CACHE_SIZE - 1);
+	offset = i_size & (PAGE_SIZE - 1);
 	if ((page->index >= end_index + 1) || !offset)
 		goto out;
 
-	zero_user_segment(page, offset, PAGE_CACHE_SIZE);
+	zero_user_segment(page, offset, PAGE_SIZE);
 write:
 	if (unlikely(is_sbi_flag_set(sbi, SBI_POR_DOING)))
 		goto redirty_out;
@@ -1232,8 +1232,8 @@ next:
 			cycled = 0;
 		end = -1;
 	} else {
-		index = wbc->range_start >> PAGE_CACHE_SHIFT;
-		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		index = wbc->range_start >> PAGE_SHIFT;
+		end = wbc->range_end >> PAGE_SHIFT;
 		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
 			range_whole = 1;
 		cycled = 1; /* ignore range_cyclic tests */
@@ -1407,7 +1407,7 @@ static int prepare_write_begin(struct f2fs_sb_info *sbi,
 	int err = 0;
 
 	if (f2fs_has_inline_data(inode) ||
-			(pos & PAGE_CACHE_MASK) >= i_size_read(inode)) {
+			(pos & PAGE_MASK) >= i_size_read(inode)) {
 		f2fs_lock_op(sbi);
 		locked = true;
 	}
@@ -1472,7 +1472,7 @@ static int f2fs_write_begin(struct file *file, struct address_space *mapping,
 	struct inode *inode = mapping->host;
 	struct f2fs_sb_info *sbi = F2FS_I_SB(inode);
 	struct page *page = NULL;
-	pgoff_t index = ((unsigned long long) pos) >> PAGE_CACHE_SHIFT;
+	pgoff_t index = ((unsigned long long) pos) >> PAGE_SHIFT;
 	bool need_balance = false;
 	block_t blkaddr = NULL_ADDR;
 	int err = 0;
@@ -1520,22 +1520,22 @@ repeat:
 	if (f2fs_encrypted_inode(inode) && S_ISREG(inode->i_mode))
 		f2fs_wait_on_encrypted_page_writeback(sbi, blkaddr);
 
-	if (len == PAGE_CACHE_SIZE)
+	if (len == PAGE_SIZE)
 		goto out_update;
 	if (PageUptodate(page))
 		goto out_clear;
 
-	if ((pos & PAGE_CACHE_MASK) >= i_size_read(inode)) {
-		unsigned start = pos & (PAGE_CACHE_SIZE - 1);
+	if ((pos & PAGE_MASK) >= i_size_read(inode)) {
+		unsigned start = pos & (PAGE_SIZE - 1);
 		unsigned end = start + len;
 
 		/* Reading beyond i_size is simple: memset to zero */
-		zero_user_segments(page, 0, start, end, PAGE_CACHE_SIZE);
+		zero_user_segments(page, 0, start, end, PAGE_SIZE);
 		goto out_update;
 	}
 
 	if (blkaddr == NEW_ADDR) {
-		zero_user_segment(page, 0, PAGE_CACHE_SIZE);
+		zero_user_segment(page, 0, PAGE_SIZE);
 	} else {
 		struct f2fs_io_info fio = {
 			.sbi = sbi,
@@ -1660,7 +1660,7 @@ void f2fs_invalidate_page(struct page *page, unsigned int offset,
 	struct f2fs_sb_info *sbi = F2FS_I_SB(inode);
 
 	if (inode->i_ino >= F2FS_ROOT_INO(sbi) &&
-		(offset % PAGE_CACHE_SIZE || length != PAGE_CACHE_SIZE))
+		(offset % PAGE_SIZE || length != PAGE_SIZE))
 		return;
 
 	if (PageDirty(page)) {
diff --git a/fs/f2fs/debug.c b/fs/f2fs/debug.c
index 4fb6ef88a34f..f4a61a5ff79f 100644
--- a/fs/f2fs/debug.c
+++ b/fs/f2fs/debug.c
@@ -164,7 +164,7 @@ static void update_mem_info(struct f2fs_sb_info *sbi)
 
 	/* build curseg */
 	si->base_mem += sizeof(struct curseg_info) * NR_CURSEG_TYPE;
-	si->base_mem += PAGE_CACHE_SIZE * NR_CURSEG_TYPE;
+	si->base_mem += PAGE_SIZE * NR_CURSEG_TYPE;
 
 	/* build dirty segmap */
 	si->base_mem += sizeof(struct dirty_seglist_info);
@@ -201,9 +201,9 @@ get_cache:
 
 	si->page_mem = 0;
 	npages = NODE_MAPPING(sbi)->nrpages;
-	si->page_mem += (unsigned long long)npages << PAGE_CACHE_SHIFT;
+	si->page_mem += (unsigned long long)npages << PAGE_SHIFT;
 	npages = META_MAPPING(sbi)->nrpages;
-	si->page_mem += (unsigned long long)npages << PAGE_CACHE_SHIFT;
+	si->page_mem += (unsigned long long)npages << PAGE_SHIFT;
 }
 
 static int stat_show(struct seq_file *s, void *v)
diff --git a/fs/f2fs/dir.c b/fs/f2fs/dir.c
index faa7495e2d7e..8e07acbaeae6 100644
--- a/fs/f2fs/dir.c
+++ b/fs/f2fs/dir.c
@@ -17,8 +17,8 @@
 
 static unsigned long dir_blocks(struct inode *inode)
 {
-	return ((unsigned long long) (i_size_read(inode) + PAGE_CACHE_SIZE - 1))
-							>> PAGE_CACHE_SHIFT;
+	return ((unsigned long long) (i_size_read(inode) + PAGE_SIZE - 1))
+							>> PAGE_SHIFT;
 }
 
 static unsigned int dir_buckets(unsigned int level, int dir_level)
diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index ff79054c6cf6..0de2ee482828 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -1306,7 +1306,7 @@ static inline void f2fs_put_page(struct page *page, int unlock)
 		f2fs_bug_on(F2FS_P_SB(page), !PageLocked(page));
 		unlock_page(page);
 	}
-	page_cache_release(page);
+	put_page(page);
 }
 
 static inline void f2fs_put_dnode(struct dnode_of_data *dn)
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index ea272be62677..eafaa6dceefc 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -74,11 +74,11 @@ static int f2fs_vm_page_mkwrite(struct vm_area_struct *vma,
 		goto mapped;
 
 	/* page is wholly or partially inside EOF */
-	if (((loff_t)(page->index + 1) << PAGE_CACHE_SHIFT) >
+	if (((loff_t)(page->index + 1) << PAGE_SHIFT) >
 						i_size_read(inode)) {
 		unsigned offset;
-		offset = i_size_read(inode) & ~PAGE_CACHE_MASK;
-		zero_user_segment(page, offset, PAGE_CACHE_SIZE);
+		offset = i_size_read(inode) & ~PAGE_MASK;
+		zero_user_segment(page, offset, PAGE_SIZE);
 	}
 	set_page_dirty(page);
 	SetPageUptodate(page);
@@ -346,11 +346,11 @@ static loff_t f2fs_seek_block(struct file *file, loff_t offset, int whence)
 		goto found;
 	}
 
-	pgofs = (pgoff_t)(offset >> PAGE_CACHE_SHIFT);
+	pgofs = (pgoff_t)(offset >> PAGE_SHIFT);
 
 	dirty = __get_first_dirty_index(inode->i_mapping, pgofs, whence);
 
-	for (; data_ofs < isize; data_ofs = (loff_t)pgofs << PAGE_CACHE_SHIFT) {
+	for (; data_ofs < isize; data_ofs = (loff_t)pgofs << PAGE_SHIFT) {
 		set_new_dnode(&dn, inode, NULL, NULL, 0);
 		err = get_dnode_of_data(&dn, pgofs, LOOKUP_NODE_RA);
 		if (err && err != -ENOENT) {
@@ -371,7 +371,7 @@ static loff_t f2fs_seek_block(struct file *file, loff_t offset, int whence)
 		/* find data/hole in dnode block */
 		for (; dn.ofs_in_node < end_offset;
 				dn.ofs_in_node++, pgofs++,
-				data_ofs = (loff_t)pgofs << PAGE_CACHE_SHIFT) {
+				data_ofs = (loff_t)pgofs << PAGE_SHIFT) {
 			block_t blkaddr;
 			blkaddr = datablock_addr(dn.node_page, dn.ofs_in_node);
 
@@ -501,8 +501,8 @@ void truncate_data_blocks(struct dnode_of_data *dn)
 static int truncate_partial_data_page(struct inode *inode, u64 from,
 								bool cache_only)
 {
-	unsigned offset = from & (PAGE_CACHE_SIZE - 1);
-	pgoff_t index = from >> PAGE_CACHE_SHIFT;
+	unsigned offset = from & (PAGE_SIZE - 1);
+	pgoff_t index = from >> PAGE_SHIFT;
 	struct address_space *mapping = inode->i_mapping;
 	struct page *page;
 
@@ -522,7 +522,7 @@ static int truncate_partial_data_page(struct inode *inode, u64 from,
 		return 0;
 truncate_out:
 	f2fs_wait_on_page_writeback(page, DATA);
-	zero_user(page, offset, PAGE_CACHE_SIZE - offset);
+	zero_user(page, offset, PAGE_SIZE - offset);
 	if (!cache_only || !f2fs_encrypted_inode(inode) || !S_ISREG(inode->i_mode))
 		set_page_dirty(page);
 	f2fs_put_page(page, 1);
@@ -791,11 +791,11 @@ static int punch_hole(struct inode *inode, loff_t offset, loff_t len)
 	if (ret)
 		return ret;
 
-	pg_start = ((unsigned long long) offset) >> PAGE_CACHE_SHIFT;
-	pg_end = ((unsigned long long) offset + len) >> PAGE_CACHE_SHIFT;
+	pg_start = ((unsigned long long) offset) >> PAGE_SHIFT;
+	pg_end = ((unsigned long long) offset + len) >> PAGE_SHIFT;
 
-	off_start = offset & (PAGE_CACHE_SIZE - 1);
-	off_end = (offset + len) & (PAGE_CACHE_SIZE - 1);
+	off_start = offset & (PAGE_SIZE - 1);
+	off_end = (offset + len) & (PAGE_SIZE - 1);
 
 	if (pg_start == pg_end) {
 		ret = fill_zero(inode, pg_start, off_start,
@@ -805,7 +805,7 @@ static int punch_hole(struct inode *inode, loff_t offset, loff_t len)
 	} else {
 		if (off_start) {
 			ret = fill_zero(inode, pg_start++, off_start,
-						PAGE_CACHE_SIZE - off_start);
+						PAGE_SIZE - off_start);
 			if (ret)
 				return ret;
 		}
@@ -822,8 +822,8 @@ static int punch_hole(struct inode *inode, loff_t offset, loff_t len)
 
 			f2fs_balance_fs(sbi, true);
 
-			blk_start = (loff_t)pg_start << PAGE_CACHE_SHIFT;
-			blk_end = (loff_t)pg_end << PAGE_CACHE_SHIFT;
+			blk_start = (loff_t)pg_start << PAGE_SHIFT;
+			blk_end = (loff_t)pg_end << PAGE_SHIFT;
 			truncate_inode_pages_range(mapping, blk_start,
 					blk_end - 1);
 
@@ -950,8 +950,8 @@ static int f2fs_collapse_range(struct inode *inode, loff_t offset, loff_t len)
 	if (ret)
 		return ret;
 
-	pg_start = offset >> PAGE_CACHE_SHIFT;
-	pg_end = (offset + len) >> PAGE_CACHE_SHIFT;
+	pg_start = offset >> PAGE_SHIFT;
+	pg_end = (offset + len) >> PAGE_SHIFT;
 
 	/* write out all dirty pages from offset */
 	ret = filemap_write_and_wait_range(inode->i_mapping, offset, LLONG_MAX);
@@ -1002,11 +1002,11 @@ static int f2fs_zero_range(struct inode *inode, loff_t offset, loff_t len,
 
 	truncate_pagecache_range(inode, offset, offset + len - 1);
 
-	pg_start = ((unsigned long long) offset) >> PAGE_CACHE_SHIFT;
-	pg_end = ((unsigned long long) offset + len) >> PAGE_CACHE_SHIFT;
+	pg_start = ((unsigned long long) offset) >> PAGE_SHIFT;
+	pg_end = ((unsigned long long) offset + len) >> PAGE_SHIFT;
 
-	off_start = offset & (PAGE_CACHE_SIZE - 1);
-	off_end = (offset + len) & (PAGE_CACHE_SIZE - 1);
+	off_start = offset & (PAGE_SIZE - 1);
+	off_end = (offset + len) & (PAGE_SIZE - 1);
 
 	if (pg_start == pg_end) {
 		ret = fill_zero(inode, pg_start, off_start,
@@ -1020,12 +1020,12 @@ static int f2fs_zero_range(struct inode *inode, loff_t offset, loff_t len,
 	} else {
 		if (off_start) {
 			ret = fill_zero(inode, pg_start++, off_start,
-						PAGE_CACHE_SIZE - off_start);
+						PAGE_SIZE - off_start);
 			if (ret)
 				return ret;
 
 			new_size = max_t(loff_t, new_size,
-					(loff_t)pg_start << PAGE_CACHE_SHIFT);
+					(loff_t)pg_start << PAGE_SHIFT);
 		}
 
 		for (index = pg_start; index < pg_end; index++) {
@@ -1061,7 +1061,7 @@ static int f2fs_zero_range(struct inode *inode, loff_t offset, loff_t len,
 			f2fs_unlock_op(sbi);
 
 			new_size = max_t(loff_t, new_size,
-				(loff_t)(index + 1) << PAGE_CACHE_SHIFT);
+				(loff_t)(index + 1) << PAGE_SHIFT);
 		}
 
 		if (off_end) {
@@ -1118,8 +1118,8 @@ static int f2fs_insert_range(struct inode *inode, loff_t offset, loff_t len)
 
 	truncate_pagecache(inode, offset);
 
-	pg_start = offset >> PAGE_CACHE_SHIFT;
-	pg_end = (offset + len) >> PAGE_CACHE_SHIFT;
+	pg_start = offset >> PAGE_SHIFT;
+	pg_end = (offset + len) >> PAGE_SHIFT;
 	delta = pg_end - pg_start;
 	nrpages = (i_size_read(inode) + PAGE_SIZE - 1) / PAGE_SIZE;
 
@@ -1159,11 +1159,11 @@ static int expand_inode_data(struct inode *inode, loff_t offset,
 
 	f2fs_balance_fs(sbi, true);
 
-	pg_start = ((unsigned long long) offset) >> PAGE_CACHE_SHIFT;
-	pg_end = ((unsigned long long) offset + len) >> PAGE_CACHE_SHIFT;
+	pg_start = ((unsigned long long) offset) >> PAGE_SHIFT;
+	pg_end = ((unsigned long long) offset + len) >> PAGE_SHIFT;
 
-	off_start = offset & (PAGE_CACHE_SIZE - 1);
-	off_end = (offset + len) & (PAGE_CACHE_SIZE - 1);
+	off_start = offset & (PAGE_SIZE - 1);
+	off_end = (offset + len) & (PAGE_SIZE - 1);
 
 	f2fs_lock_op(sbi);
 
@@ -1181,12 +1181,12 @@ noalloc:
 		if (pg_start == pg_end)
 			new_size = offset + len;
 		else if (index == pg_start && off_start)
-			new_size = (loff_t)(index + 1) << PAGE_CACHE_SHIFT;
+			new_size = (loff_t)(index + 1) << PAGE_SHIFT;
 		else if (index == pg_end)
-			new_size = ((loff_t)index << PAGE_CACHE_SHIFT) +
+			new_size = ((loff_t)index << PAGE_SHIFT) +
 								off_end;
 		else
-			new_size += PAGE_CACHE_SIZE;
+			new_size += PAGE_SIZE;
 	}
 
 	if (!(mode & FALLOC_FL_KEEP_SIZE) &&
@@ -1662,8 +1662,8 @@ static int f2fs_defragment_range(struct f2fs_sb_info *sbi,
 	if (need_inplace_update(inode))
 		return -EINVAL;
 
-	pg_start = range->start >> PAGE_CACHE_SHIFT;
-	pg_end = (range->start + range->len) >> PAGE_CACHE_SHIFT;
+	pg_start = range->start >> PAGE_SHIFT;
+	pg_end = (range->start + range->len) >> PAGE_SHIFT;
 
 	f2fs_balance_fs(sbi, true);
 
@@ -1780,7 +1780,7 @@ clear_out:
 out:
 	inode_unlock(inode);
 	if (!err)
-		range->len = (u64)total << PAGE_CACHE_SHIFT;
+		range->len = (u64)total << PAGE_SHIFT;
 	return err;
 }
 
diff --git a/fs/f2fs/inline.c b/fs/f2fs/inline.c
index c3f0b7d4cfca..b42042e79558 100644
--- a/fs/f2fs/inline.c
+++ b/fs/f2fs/inline.c
@@ -51,7 +51,7 @@ void read_inline_data(struct page *page, struct page *ipage)
 
 	f2fs_bug_on(F2FS_P_SB(page), page->index);
 
-	zero_user_segment(page, MAX_INLINE_DATA, PAGE_CACHE_SIZE);
+	zero_user_segment(page, MAX_INLINE_DATA, PAGE_SIZE);
 
 	/* Copy the whole inline data block */
 	src_addr = inline_data_addr(ipage);
@@ -93,7 +93,7 @@ int f2fs_read_inline_data(struct inode *inode, struct page *page)
 	}
 
 	if (page->index)
-		zero_user_segment(page, 0, PAGE_CACHE_SIZE);
+		zero_user_segment(page, 0, PAGE_SIZE);
 	else
 		read_inline_data(page, ipage);
 
@@ -129,7 +129,7 @@ int f2fs_convert_inline_page(struct dnode_of_data *dn, struct page *page)
 	if (PageUptodate(page))
 		goto no_update;
 
-	zero_user_segment(page, MAX_INLINE_DATA, PAGE_CACHE_SIZE);
+	zero_user_segment(page, MAX_INLINE_DATA, PAGE_SIZE);
 
 	/* Copy the whole inline data block */
 	src_addr = inline_data_addr(dn->inode_page);
@@ -390,7 +390,7 @@ static int f2fs_convert_inline_dir(struct inode *dir, struct page *ipage,
 		goto out;
 
 	f2fs_wait_on_page_writeback(page, DATA);
-	zero_user_segment(page, MAX_INLINE_DATA, PAGE_CACHE_SIZE);
+	zero_user_segment(page, MAX_INLINE_DATA, PAGE_SIZE);
 
 	dentry_blk = kmap_atomic(page);
 
@@ -420,8 +420,8 @@ static int f2fs_convert_inline_dir(struct inode *dir, struct page *ipage,
 	stat_dec_inline_dir(dir);
 	clear_inode_flag(F2FS_I(dir), FI_INLINE_DENTRY);
 
-	if (i_size_read(dir) < PAGE_CACHE_SIZE) {
-		i_size_write(dir, PAGE_CACHE_SIZE);
+	if (i_size_read(dir) < PAGE_SIZE) {
+		i_size_write(dir, PAGE_SIZE);
 		set_inode_flag(F2FS_I(dir), FI_UPDATE_DIR);
 	}
 
diff --git a/fs/f2fs/namei.c b/fs/f2fs/namei.c
index 6f944e5eb76e..5a5538f2b53b 100644
--- a/fs/f2fs/namei.c
+++ b/fs/f2fs/namei.c
@@ -1007,13 +1007,13 @@ static const char *f2fs_encrypted_get_link(struct dentry *dentry,
 	/* Null-terminate the name */
 	paddr[res] = '\0';
 
-	page_cache_release(cpage);
+	put_page(cpage);
 	set_delayed_call(done, kfree_link, paddr);
 	return paddr;
 errout:
 	kfree(cstr.name);
 	f2fs_fname_crypto_free_buffer(&pstr);
-	page_cache_release(cpage);
+	put_page(cpage);
 	return ERR_PTR(res);
 }
 
diff --git a/fs/f2fs/node.c b/fs/f2fs/node.c
index 342597a5897f..7b9ff127093a 100644
--- a/fs/f2fs/node.c
+++ b/fs/f2fs/node.c
@@ -46,11 +46,11 @@ bool available_free_memory(struct f2fs_sb_info *sbi, int type)
 	 */
 	if (type == FREE_NIDS) {
 		mem_size = (nm_i->fcnt * sizeof(struct free_nid)) >>
-							PAGE_CACHE_SHIFT;
+							PAGE_SHIFT;
 		res = mem_size < ((avail_ram * nm_i->ram_thresh / 100) >> 2);
 	} else if (type == NAT_ENTRIES) {
 		mem_size = (nm_i->nat_cnt * sizeof(struct nat_entry)) >>
-							PAGE_CACHE_SHIFT;
+							PAGE_SHIFT;
 		res = mem_size < ((avail_ram * nm_i->ram_thresh / 100) >> 2);
 	} else if (type == DIRTY_DENTS) {
 		if (sbi->sb->s_bdi->wb.dirty_exceeded)
@@ -62,13 +62,13 @@ bool available_free_memory(struct f2fs_sb_info *sbi, int type)
 
 		for (i = 0; i <= UPDATE_INO; i++)
 			mem_size += (sbi->im[i].ino_num *
-				sizeof(struct ino_entry)) >> PAGE_CACHE_SHIFT;
+				sizeof(struct ino_entry)) >> PAGE_SHIFT;
 		res = mem_size < ((avail_ram * nm_i->ram_thresh / 100) >> 1);
 	} else if (type == EXTENT_CACHE) {
 		mem_size = (atomic_read(&sbi->total_ext_tree) *
 				sizeof(struct extent_tree) +
 				atomic_read(&sbi->total_ext_node) *
-				sizeof(struct extent_node)) >> PAGE_CACHE_SHIFT;
+				sizeof(struct extent_node)) >> PAGE_SHIFT;
 		res = mem_size < ((avail_ram * nm_i->ram_thresh / 100) >> 1);
 	} else {
 		if (!sbi->sb->s_bdi->wb.dirty_exceeded)
@@ -121,7 +121,7 @@ static struct page *get_next_nat_page(struct f2fs_sb_info *sbi, nid_t nid)
 
 	src_addr = page_address(src_page);
 	dst_addr = page_address(dst_page);
-	memcpy(dst_addr, src_addr, PAGE_CACHE_SIZE);
+	memcpy(dst_addr, src_addr, PAGE_SIZE);
 	set_page_dirty(dst_page);
 	f2fs_put_page(src_page, 1);
 
diff --git a/fs/f2fs/recovery.c b/fs/f2fs/recovery.c
index 589b20b8677b..45f53f27a5f6 100644
--- a/fs/f2fs/recovery.c
+++ b/fs/f2fs/recovery.c
@@ -593,7 +593,7 @@ out:
 
 	/* truncate meta pages to be used by the recovery */
 	truncate_inode_pages_range(META_MAPPING(sbi),
-			(loff_t)MAIN_BLKADDR(sbi) << PAGE_CACHE_SHIFT, -1);
+			(loff_t)MAIN_BLKADDR(sbi) << PAGE_SHIFT, -1);
 
 	if (err) {
 		truncate_inode_pages_final(NODE_MAPPING(sbi));
diff --git a/fs/f2fs/segment.c b/fs/f2fs/segment.c
index 5904a411c86f..89ba77786772 100644
--- a/fs/f2fs/segment.c
+++ b/fs/f2fs/segment.c
@@ -804,12 +804,12 @@ int npages_for_summary_flush(struct f2fs_sb_info *sbi, bool for_ra)
 		}
 	}
 
-	sum_in_page = (PAGE_CACHE_SIZE - 2 * SUM_JOURNAL_SIZE -
+	sum_in_page = (PAGE_SIZE - 2 * SUM_JOURNAL_SIZE -
 			SUM_FOOTER_SIZE) / SUMMARY_SIZE;
 	if (valid_sum_count <= sum_in_page)
 		return 1;
 	else if ((valid_sum_count - sum_in_page) <=
-		(PAGE_CACHE_SIZE - SUM_FOOTER_SIZE) / SUMMARY_SIZE)
+		(PAGE_SIZE - SUM_FOOTER_SIZE) / SUMMARY_SIZE)
 		return 2;
 	return 3;
 }
@@ -828,9 +828,9 @@ void update_meta_page(struct f2fs_sb_info *sbi, void *src, block_t blk_addr)
 	void *dst = page_address(page);
 
 	if (src)
-		memcpy(dst, src, PAGE_CACHE_SIZE);
+		memcpy(dst, src, PAGE_SIZE);
 	else
-		memset(dst, 0, PAGE_CACHE_SIZE);
+		memset(dst, 0, PAGE_SIZE);
 	set_page_dirty(page);
 	f2fs_put_page(page, 1);
 }
@@ -1527,7 +1527,7 @@ static int read_compacted_summaries(struct f2fs_sb_info *sbi)
 			s = (struct f2fs_summary *)(kaddr + offset);
 			seg_i->sum_blk->entries[j] = *s;
 			offset += SUMMARY_SIZE;
-			if (offset + SUMMARY_SIZE <= PAGE_CACHE_SIZE -
+			if (offset + SUMMARY_SIZE <= PAGE_SIZE -
 						SUM_FOOTER_SIZE)
 				continue;
 
@@ -1599,7 +1599,7 @@ static int read_normal_summaries(struct f2fs_sb_info *sbi, int type)
 	/* set uncompleted segment to curseg */
 	curseg = CURSEG_I(sbi, type);
 	mutex_lock(&curseg->curseg_mutex);
-	memcpy(curseg->sum_blk, sum, PAGE_CACHE_SIZE);
+	memcpy(curseg->sum_blk, sum, PAGE_SIZE);
 	curseg->next_segno = segno;
 	reset_curseg(sbi, type, 0);
 	curseg->alloc_type = ckpt->alloc_type[type];
@@ -1682,7 +1682,7 @@ static void write_compacted_summaries(struct f2fs_sb_info *sbi, block_t blkaddr)
 			*summary = seg_i->sum_blk->entries[j];
 			written_size += SUMMARY_SIZE;
 
-			if (written_size + SUMMARY_SIZE <= PAGE_CACHE_SIZE -
+			if (written_size + SUMMARY_SIZE <= PAGE_SIZE -
 							SUM_FOOTER_SIZE)
 				continue;
 
@@ -1773,7 +1773,7 @@ static struct page *get_next_sit_page(struct f2fs_sb_info *sbi,
 
 	src_addr = page_address(src_page);
 	dst_addr = page_address(dst_page);
-	memcpy(dst_addr, src_addr, PAGE_CACHE_SIZE);
+	memcpy(dst_addr, src_addr, PAGE_SIZE);
 
 	set_page_dirty(dst_page);
 	f2fs_put_page(src_page, 1);
@@ -2096,7 +2096,7 @@ static int build_curseg(struct f2fs_sb_info *sbi)
 
 	for (i = 0; i < NR_CURSEG_TYPE; i++) {
 		mutex_init(&array[i].curseg_mutex);
-		array[i].sum_blk = kzalloc(PAGE_CACHE_SIZE, GFP_KERNEL);
+		array[i].sum_blk = kzalloc(PAGE_SIZE, GFP_KERNEL);
 		if (!array[i].sum_blk)
 			return -ENOMEM;
 		array[i].segno = NULL_SEGNO;
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 6134832baaaf..6d35862ce113 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -1012,10 +1012,10 @@ static int sanity_check_raw_super(struct super_block *sb,
 	}
 
 	/* Currently, support only 4KB page cache size */
-	if (F2FS_BLKSIZE != PAGE_CACHE_SIZE) {
+	if (F2FS_BLKSIZE != PAGE_SIZE) {
 		f2fs_msg(sb, KERN_INFO,
 			"Invalid page_cache_size (%lu), supports only 4KB\n",
-			PAGE_CACHE_SIZE);
+			PAGE_SIZE);
 		return 1;
 	}
 
diff --git a/include/linux/f2fs_fs.h b/include/linux/f2fs_fs.h
index e59c3be92106..4a793b045efa 100644
--- a/include/linux/f2fs_fs.h
+++ b/include/linux/f2fs_fs.h
@@ -262,7 +262,7 @@ struct f2fs_node {
 /*
  * For NAT entries
  */
-#define NAT_ENTRY_PER_BLOCK (PAGE_CACHE_SIZE / sizeof(struct f2fs_nat_entry))
+#define NAT_ENTRY_PER_BLOCK (PAGE_SIZE / sizeof(struct f2fs_nat_entry))
 
 struct f2fs_nat_entry {
 	__u8 version;		/* latest version of cached nat entry */
@@ -282,7 +282,7 @@ struct f2fs_nat_block {
  * Not allow to change this.
  */
 #define SIT_VBLOCK_MAP_SIZE 64
-#define SIT_ENTRY_PER_BLOCK (PAGE_CACHE_SIZE / sizeof(struct f2fs_sit_entry))
+#define SIT_ENTRY_PER_BLOCK (PAGE_SIZE / sizeof(struct f2fs_sit_entry))
 
 /*
  * Note that f2fs_sit_entry->vblocks has the following bit-field information.
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
