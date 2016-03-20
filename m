Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9D70582F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:47:29 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id x3so237546980pfb.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:47:29 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ds16si10308712pac.149.2016.03.20.11.41.50
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 47/71] logfs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:54 +0300
Message-Id: <1458499278-1516-48-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Joern Engel <joern@logfs.org>, Prasad Joshi <prasadjoshi.linux@gmail.com>

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
Cc: Joern Engel <joern@logfs.org>
Cc: Prasad Joshi <prasadjoshi.linux@gmail.com>
---
 fs/logfs/dev_bdev.c  |  2 +-
 fs/logfs/dev_mtd.c   | 10 +++++-----
 fs/logfs/dir.c       | 12 ++++++------
 fs/logfs/file.c      | 26 +++++++++++++-------------
 fs/logfs/readwrite.c | 20 ++++++++++----------
 fs/logfs/segment.c   | 28 ++++++++++++++--------------
 fs/logfs/super.c     | 16 ++++++++--------
 7 files changed, 57 insertions(+), 57 deletions(-)

diff --git a/fs/logfs/dev_bdev.c b/fs/logfs/dev_bdev.c
index a709d80c8ebc..cc26f8f215f5 100644
--- a/fs/logfs/dev_bdev.c
+++ b/fs/logfs/dev_bdev.c
@@ -64,7 +64,7 @@ static void writeseg_end_io(struct bio *bio)
 
 	bio_for_each_segment_all(bvec, bio, i) {
 		end_page_writeback(bvec->bv_page);
-		page_cache_release(bvec->bv_page);
+		put_page(bvec->bv_page);
 	}
 	bio_put(bio);
 	if (atomic_dec_and_test(&super->s_pending_writes))
diff --git a/fs/logfs/dev_mtd.c b/fs/logfs/dev_mtd.c
index 9c501449450d..b76a62b1978f 100644
--- a/fs/logfs/dev_mtd.c
+++ b/fs/logfs/dev_mtd.c
@@ -46,9 +46,9 @@ static int loffs_mtd_write(struct super_block *sb, loff_t ofs, size_t len,
 
 	BUG_ON((ofs >= mtd->size) || (len > mtd->size - ofs));
 	BUG_ON(ofs != (ofs >> super->s_writeshift) << super->s_writeshift);
-	BUG_ON(len > PAGE_CACHE_SIZE);
-	page_start = ofs & PAGE_CACHE_MASK;
-	page_end = PAGE_CACHE_ALIGN(ofs + len) - 1;
+	BUG_ON(len > PAGE_SIZE);
+	page_start = ofs & PAGE_MASK;
+	page_end = PAGE_ALIGN(ofs + len) - 1;
 	ret = mtd_write(mtd, ofs, len, &retlen, buf);
 	if (ret || (retlen != len))
 		return -EIO;
@@ -82,7 +82,7 @@ static int logfs_mtd_erase_mapping(struct super_block *sb, loff_t ofs,
 		if (!page)
 			continue;
 		memset(page_address(page), 0xFF, PAGE_SIZE);
-		page_cache_release(page);
+		put_page(page);
 	}
 	return 0;
 }
@@ -195,7 +195,7 @@ static int __logfs_mtd_writeseg(struct super_block *sb, u64 ofs, pgoff_t index,
 		err = loffs_mtd_write(sb, page->index << PAGE_SHIFT, PAGE_SIZE,
 					page_address(page));
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		if (err)
 			return err;
 	}
diff --git a/fs/logfs/dir.c b/fs/logfs/dir.c
index 542468e9bfb4..ddbed2be5366 100644
--- a/fs/logfs/dir.c
+++ b/fs/logfs/dir.c
@@ -183,7 +183,7 @@ static struct page *logfs_get_dd_page(struct inode *dir, struct dentry *dentry)
 		if (name->len != be16_to_cpu(dd->namelen) ||
 				memcmp(name->name, dd->name, name->len)) {
 			kunmap_atomic(dd);
-			page_cache_release(page);
+			put_page(page);
 			continue;
 		}
 
@@ -238,7 +238,7 @@ static int logfs_unlink(struct inode *dir, struct dentry *dentry)
 		return PTR_ERR(page);
 	}
 	index = page->index;
-	page_cache_release(page);
+	put_page(page);
 
 	mutex_lock(&super->s_dirop_mutex);
 	logfs_add_transaction(dir, ta);
@@ -316,7 +316,7 @@ static int logfs_readdir(struct file *file, struct dir_context *ctx)
 				be16_to_cpu(dd->namelen),
 				be64_to_cpu(dd->ino), dd->type);
 		kunmap(page);
-		page_cache_release(page);
+		put_page(page);
 		if (full)
 			break;
 	}
@@ -349,7 +349,7 @@ static struct dentry *logfs_lookup(struct inode *dir, struct dentry *dentry,
 	dd = kmap_atomic(page);
 	ino = be64_to_cpu(dd->ino);
 	kunmap_atomic(dd);
-	page_cache_release(page);
+	put_page(page);
 
 	inode = logfs_iget(dir->i_sb, ino);
 	if (IS_ERR(inode))
@@ -392,7 +392,7 @@ static int logfs_write_dir(struct inode *dir, struct dentry *dentry,
 
 		err = logfs_write_buf(dir, page, WF_LOCK);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		if (!err)
 			grow_dir(dir, index);
 		return err;
@@ -561,7 +561,7 @@ static int logfs_get_dd(struct inode *dir, struct dentry *dentry,
 	map = kmap_atomic(page);
 	memcpy(dd, map, sizeof(*dd));
 	kunmap_atomic(map);
-	page_cache_release(page);
+	put_page(page);
 	return 0;
 }
 
diff --git a/fs/logfs/file.c b/fs/logfs/file.c
index 61eaeb1b6cac..f01ddfb1a03b 100644
--- a/fs/logfs/file.c
+++ b/fs/logfs/file.c
@@ -15,21 +15,21 @@ static int logfs_write_begin(struct file *file, struct address_space *mapping,
 {
 	struct inode *inode = mapping->host;
 	struct page *page;
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
 		return -ENOMEM;
 	*pagep = page;
 
-	if ((len == PAGE_CACHE_SIZE) || PageUptodate(page))
+	if ((len == PAGE_SIZE) || PageUptodate(page))
 		return 0;
-	if ((pos & PAGE_CACHE_MASK) >= i_size_read(inode)) {
-		unsigned start = pos & (PAGE_CACHE_SIZE - 1);
+	if ((pos & PAGE_MASK) >= i_size_read(inode)) {
+		unsigned start = pos & (PAGE_SIZE - 1);
 		unsigned end = start + len;
 
 		/* Reading beyond i_size is simple: memset to zero */
-		zero_user_segments(page, 0, start, end, PAGE_CACHE_SIZE);
+		zero_user_segments(page, 0, start, end, PAGE_SIZE);
 		return 0;
 	}
 	return logfs_readpage_nolock(page);
@@ -41,11 +41,11 @@ static int logfs_write_end(struct file *file, struct address_space *mapping,
 {
 	struct inode *inode = mapping->host;
 	pgoff_t index = page->index;
-	unsigned start = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned start = pos & (PAGE_SIZE - 1);
 	unsigned end = start + copied;
 	int ret = 0;
 
-	BUG_ON(PAGE_CACHE_SIZE != inode->i_sb->s_blocksize);
+	BUG_ON(PAGE_SIZE != inode->i_sb->s_blocksize);
 	BUG_ON(page->index > I3_BLOCKS);
 
 	if (copied < len) {
@@ -61,8 +61,8 @@ static int logfs_write_end(struct file *file, struct address_space *mapping,
 	if (copied == 0)
 		goto out; /* FIXME: do we need to update inode? */
 
-	if (i_size_read(inode) < (index << PAGE_CACHE_SHIFT) + end) {
-		i_size_write(inode, (index << PAGE_CACHE_SHIFT) + end);
+	if (i_size_read(inode) < (index << PAGE_SHIFT) + end) {
+		i_size_write(inode, (index << PAGE_SHIFT) + end);
 		mark_inode_dirty_sync(inode);
 	}
 
@@ -75,7 +75,7 @@ static int logfs_write_end(struct file *file, struct address_space *mapping,
 	}
 out:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return ret ? ret : copied;
 }
 
@@ -118,7 +118,7 @@ static int logfs_writepage(struct page *page, struct writeback_control *wbc)
 {
 	struct inode *inode = page->mapping->host;
 	loff_t i_size = i_size_read(inode);
-	pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
+	pgoff_t end_index = i_size >> PAGE_SHIFT;
 	unsigned offset;
 	u64 bix;
 	level_t level;
@@ -142,7 +142,7 @@ static int logfs_writepage(struct page *page, struct writeback_control *wbc)
 		return __logfs_writepage(page);
 
 	 /* Is the page fully outside i_size? (truncate in progress) */
-	offset = i_size & (PAGE_CACHE_SIZE-1);
+	offset = i_size & (PAGE_SIZE-1);
 	if (bix > end_index || offset == 0) {
 		unlock_page(page);
 		return 0; /* don't care */
@@ -155,7 +155,7 @@ static int logfs_writepage(struct page *page, struct writeback_control *wbc)
 	 * the  page size, the remaining memory is zeroed when mapped, and
 	 * writes to that region are not written out to the file."
 	 */
-	zero_user_segment(page, offset, PAGE_CACHE_SIZE);
+	zero_user_segment(page, offset, PAGE_SIZE);
 	return __logfs_writepage(page);
 }
 
diff --git a/fs/logfs/readwrite.c b/fs/logfs/readwrite.c
index 20973c9e52f8..3fb8c6d67303 100644
--- a/fs/logfs/readwrite.c
+++ b/fs/logfs/readwrite.c
@@ -281,7 +281,7 @@ static struct page *logfs_get_read_page(struct inode *inode, u64 bix,
 static void logfs_put_read_page(struct page *page)
 {
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 static void logfs_lock_write_page(struct page *page)
@@ -323,7 +323,7 @@ repeat:
 			return NULL;
 		err = add_to_page_cache_lru(page, mapping, index, GFP_NOFS);
 		if (unlikely(err)) {
-			page_cache_release(page);
+			put_page(page);
 			if (err == -EEXIST)
 				goto repeat;
 			return NULL;
@@ -342,7 +342,7 @@ static void logfs_unlock_write_page(struct page *page)
 static void logfs_put_write_page(struct page *page)
 {
 	logfs_unlock_write_page(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 static struct page *logfs_get_page(struct inode *inode, u64 bix, level_t level,
@@ -562,7 +562,7 @@ static void indirect_free_block(struct super_block *sb,
 
 	if (PagePrivate(page)) {
 		ClearPagePrivate(page);
-		page_cache_release(page);
+		put_page(page);
 		set_page_private(page, 0);
 	}
 	__free_block(sb, block);
@@ -655,7 +655,7 @@ static void alloc_data_block(struct inode *inode, struct page *page)
 	block->page = page;
 
 	SetPagePrivate(page);
-	page_cache_get(page);
+	get_page(page);
 	set_page_private(page, (unsigned long) block);
 
 	block->ops = &indirect_block_ops;
@@ -709,7 +709,7 @@ static u64 block_get_pointer(struct page *page, int index)
 
 static int logfs_read_empty(struct page *page)
 {
-	zero_user_segment(page, 0, PAGE_CACHE_SIZE);
+	zero_user_segment(page, 0, PAGE_SIZE);
 	return 0;
 }
 
@@ -1660,7 +1660,7 @@ static int truncate_data_block(struct inode *inode, struct page *page,
 	if (err)
 		return err;
 
-	zero_user_segment(page, size - pageofs, PAGE_CACHE_SIZE);
+	zero_user_segment(page, size - pageofs, PAGE_SIZE);
 	return logfs_segment_write(inode, page, shadow);
 }
 
@@ -1919,7 +1919,7 @@ static void move_page_to_inode(struct inode *inode, struct page *page)
 	block->page = NULL;
 	if (PagePrivate(page)) {
 		ClearPagePrivate(page);
-		page_cache_release(page);
+		put_page(page);
 		set_page_private(page, 0);
 	}
 }
@@ -1940,7 +1940,7 @@ static void move_inode_to_page(struct page *page, struct inode *inode)
 
 	if (!PagePrivate(page)) {
 		SetPagePrivate(page);
-		page_cache_get(page);
+		get_page(page);
 		set_page_private(page, (unsigned long) block);
 	}
 
@@ -1971,7 +1971,7 @@ int logfs_read_inode(struct inode *inode)
 	logfs_disk_to_inode(di, inode);
 	kunmap_atomic(di);
 	move_page_to_inode(inode, page);
-	page_cache_release(page);
+	put_page(page);
 	return 0;
 }
 
diff --git a/fs/logfs/segment.c b/fs/logfs/segment.c
index d270e4b2ab6b..1efd6055f4b0 100644
--- a/fs/logfs/segment.c
+++ b/fs/logfs/segment.c
@@ -90,9 +90,9 @@ int __logfs_buf_write(struct logfs_area *area, u64 ofs, void *buf, size_t len,
 
 		if (!PagePrivate(page)) {
 			SetPagePrivate(page);
-			page_cache_get(page);
+			get_page(page);
 		}
-		page_cache_release(page);
+		put_page(page);
 
 		buf += copylen;
 		len -= copylen;
@@ -117,9 +117,9 @@ static void pad_partial_page(struct logfs_area *area)
 		memset(page_address(page) + offset, 0xff, len);
 		if (!PagePrivate(page)) {
 			SetPagePrivate(page);
-			page_cache_get(page);
+			get_page(page);
 		}
-		page_cache_release(page);
+		put_page(page);
 	}
 }
 
@@ -129,20 +129,20 @@ static void pad_full_pages(struct logfs_area *area)
 	struct logfs_super *super = logfs_super(sb);
 	u64 ofs = dev_ofs(sb, area->a_segno, area->a_used_bytes);
 	u32 len = super->s_segsize - area->a_used_bytes;
-	pgoff_t index = PAGE_CACHE_ALIGN(ofs) >> PAGE_CACHE_SHIFT;
-	pgoff_t no_indizes = len >> PAGE_CACHE_SHIFT;
+	pgoff_t index = PAGE_ALIGN(ofs) >> PAGE_SHIFT;
+	pgoff_t no_indizes = len >> PAGE_SHIFT;
 	struct page *page;
 
 	while (no_indizes) {
 		page = get_mapping_page(sb, index, 0);
 		BUG_ON(!page); /* FIXME: reserve a pool */
 		SetPageUptodate(page);
-		memset(page_address(page), 0xff, PAGE_CACHE_SIZE);
+		memset(page_address(page), 0xff, PAGE_SIZE);
 		if (!PagePrivate(page)) {
 			SetPagePrivate(page);
-			page_cache_get(page);
+			get_page(page);
 		}
-		page_cache_release(page);
+		put_page(page);
 		index++;
 		no_indizes--;
 	}
@@ -411,7 +411,7 @@ int wbuf_read(struct super_block *sb, u64 ofs, size_t len, void *buf)
 		if (IS_ERR(page))
 			return PTR_ERR(page);
 		memcpy(buf, page_address(page) + offset, copylen);
-		page_cache_release(page);
+		put_page(page);
 
 		buf += copylen;
 		len -= copylen;
@@ -499,7 +499,7 @@ static void move_btree_to_page(struct inode *inode, struct page *page,
 
 	if (!PagePrivate(page)) {
 		SetPagePrivate(page);
-		page_cache_get(page);
+		get_page(page);
 		set_page_private(page, (unsigned long) block);
 	}
 	block->ops = &indirect_block_ops;
@@ -554,7 +554,7 @@ void move_page_to_btree(struct page *page)
 
 	if (PagePrivate(page)) {
 		ClearPagePrivate(page);
-		page_cache_release(page);
+		put_page(page);
 		set_page_private(page, 0);
 	}
 	block->ops = &btree_block_ops;
@@ -723,9 +723,9 @@ void freeseg(struct super_block *sb, u32 segno)
 			continue;
 		if (PagePrivate(page)) {
 			ClearPagePrivate(page);
-			page_cache_release(page);
+			put_page(page);
 		}
-		page_cache_release(page);
+		put_page(page);
 	}
 }
 
diff --git a/fs/logfs/super.c b/fs/logfs/super.c
index 54360293bcb5..5751082dba52 100644
--- a/fs/logfs/super.c
+++ b/fs/logfs/super.c
@@ -48,7 +48,7 @@ void emergency_read_end(struct page *page)
 	if (page == emergency_page)
 		mutex_unlock(&emergency_mutex);
 	else
-		page_cache_release(page);
+		put_page(page);
 }
 
 static void dump_segfile(struct super_block *sb)
@@ -206,7 +206,7 @@ static int write_one_sb(struct super_block *sb,
 	logfs_set_segment_erased(sb, segno, ec, 0);
 	logfs_write_ds(sb, ds, segno, ec);
 	err = super->s_devops->write_sb(sb, page);
-	page_cache_release(page);
+	put_page(page);
 	return err;
 }
 
@@ -366,24 +366,24 @@ static struct page *find_super_block(struct super_block *sb)
 		return NULL;
 	last = super->s_devops->find_last_sb(sb, &super->s_sb_ofs[1]);
 	if (!last || IS_ERR(last)) {
-		page_cache_release(first);
+		put_page(first);
 		return NULL;
 	}
 
 	if (!logfs_check_ds(page_address(first))) {
-		page_cache_release(last);
+		put_page(last);
 		return first;
 	}
 
 	/* First one didn't work, try the second superblock */
 	if (!logfs_check_ds(page_address(last))) {
-		page_cache_release(first);
+		put_page(first);
 		return last;
 	}
 
 	/* Neither worked, sorry folks */
-	page_cache_release(first);
-	page_cache_release(last);
+	put_page(first);
+	put_page(last);
 	return NULL;
 }
 
@@ -425,7 +425,7 @@ static int __logfs_read_sb(struct super_block *sb)
 	super->s_data_levels = ds->ds_data_levels;
 	super->s_total_levels = super->s_ifile_levels + super->s_iblock_levels
 		+ super->s_data_levels;
-	page_cache_release(page);
+	put_page(page);
 	return 0;
 }
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
