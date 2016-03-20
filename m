Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB5282F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:49:39 -0400 (EDT)
Received: by mail-pf0-f176.google.com with SMTP id n5so237576165pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:49:39 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ol15si14265943pab.45.2016.03.20.11.41.53
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 61/71] ubifs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:41:08 +0300
Message-Id: <1458499278-1516-62-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Richard Weinberger <richard@nod.at>, Artem Bityutskiy <dedekind1@gmail.com>, Adrian Hunter <adrian.hunter@intel.com>

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
Cc: Richard Weinberger <richard@nod.at>
Cc: Artem Bityutskiy <dedekind1@gmail.com>
Cc: Adrian Hunter <adrian.hunter@intel.com>
---
 fs/ubifs/file.c  | 54 +++++++++++++++++++++++++++---------------------------
 fs/ubifs/super.c |  6 +++---
 fs/ubifs/ubifs.h |  4 ++--
 3 files changed, 32 insertions(+), 32 deletions(-)

diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 065c88f8e4b8..446753d8ac34 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -121,7 +121,7 @@ static int do_readpage(struct page *page)
 	if (block >= beyond) {
 		/* Reading beyond inode */
 		SetPageChecked(page);
-		memset(addr, 0, PAGE_CACHE_SIZE);
+		memset(addr, 0, PAGE_SIZE);
 		goto out;
 	}
 
@@ -223,7 +223,7 @@ static int write_begin_slow(struct address_space *mapping,
 {
 	struct inode *inode = mapping->host;
 	struct ubifs_info *c = inode->i_sb->s_fs_info;
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 	struct ubifs_budget_req req = { .new_page = 1 };
 	int uninitialized_var(err), appending = !!(pos + len > inode->i_size);
 	struct page *page;
@@ -254,13 +254,13 @@ static int write_begin_slow(struct address_space *mapping,
 	}
 
 	if (!PageUptodate(page)) {
-		if (!(pos & ~PAGE_CACHE_MASK) && len == PAGE_CACHE_SIZE)
+		if (!(pos & ~PAGE_MASK) && len == PAGE_SIZE)
 			SetPageChecked(page);
 		else {
 			err = do_readpage(page);
 			if (err) {
 				unlock_page(page);
-				page_cache_release(page);
+				put_page(page);
 				ubifs_release_budget(c, &req);
 				return err;
 			}
@@ -428,7 +428,7 @@ static int ubifs_write_begin(struct file *file, struct address_space *mapping,
 	struct inode *inode = mapping->host;
 	struct ubifs_info *c = inode->i_sb->s_fs_info;
 	struct ubifs_inode *ui = ubifs_inode(inode);
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 	int uninitialized_var(err), appending = !!(pos + len > inode->i_size);
 	int skipped_read = 0;
 	struct page *page;
@@ -446,7 +446,7 @@ static int ubifs_write_begin(struct file *file, struct address_space *mapping,
 
 	if (!PageUptodate(page)) {
 		/* The page is not loaded from the flash */
-		if (!(pos & ~PAGE_CACHE_MASK) && len == PAGE_CACHE_SIZE) {
+		if (!(pos & ~PAGE_MASK) && len == PAGE_SIZE) {
 			/*
 			 * We change whole page so no need to load it. But we
 			 * do not know whether this page exists on the media or
@@ -462,7 +462,7 @@ static int ubifs_write_begin(struct file *file, struct address_space *mapping,
 			err = do_readpage(page);
 			if (err) {
 				unlock_page(page);
-				page_cache_release(page);
+				put_page(page);
 				return err;
 			}
 		}
@@ -494,7 +494,7 @@ static int ubifs_write_begin(struct file *file, struct address_space *mapping,
 			mutex_unlock(&ui->ui_mutex);
 		}
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 
 		return write_begin_slow(mapping, pos, len, pagep, flags);
 	}
@@ -549,12 +549,12 @@ static int ubifs_write_end(struct file *file, struct address_space *mapping,
 	dbg_gen("ino %lu, pos %llu, pg %lu, len %u, copied %d, i_size %lld",
 		inode->i_ino, pos, page->index, len, copied, inode->i_size);
 
-	if (unlikely(copied < len && len == PAGE_CACHE_SIZE)) {
+	if (unlikely(copied < len && len == PAGE_SIZE)) {
 		/*
 		 * VFS copied less data to the page that it intended and
 		 * declared in its '->write_begin()' call via the @len
 		 * argument. If the page was not up-to-date, and @len was
-		 * @PAGE_CACHE_SIZE, the 'ubifs_write_begin()' function did
+		 * @PAGE_SIZE, the 'ubifs_write_begin()' function did
 		 * not load it from the media (for optimization reasons). This
 		 * means that part of the page contains garbage. So read the
 		 * page now.
@@ -593,7 +593,7 @@ static int ubifs_write_end(struct file *file, struct address_space *mapping,
 
 out:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return copied;
 }
 
@@ -621,10 +621,10 @@ static int populate_page(struct ubifs_info *c, struct page *page,
 
 	addr = zaddr = kmap(page);
 
-	end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
+	end_index = (i_size - 1) >> PAGE_SHIFT;
 	if (!i_size || page->index > end_index) {
 		hole = 1;
-		memset(addr, 0, PAGE_CACHE_SIZE);
+		memset(addr, 0, PAGE_SIZE);
 		goto out_hole;
 	}
 
@@ -673,7 +673,7 @@ static int populate_page(struct ubifs_info *c, struct page *page,
 	}
 
 	if (end_index == page->index) {
-		int len = i_size & (PAGE_CACHE_SIZE - 1);
+		int len = i_size & (PAGE_SIZE - 1);
 
 		if (len && len < read)
 			memset(zaddr + len, 0, read - len);
@@ -773,7 +773,7 @@ static int ubifs_do_bulk_read(struct ubifs_info *c, struct bu_info *bu,
 	isize = i_size_read(inode);
 	if (isize == 0)
 		goto out_free;
-	end_index = ((isize - 1) >> PAGE_CACHE_SHIFT);
+	end_index = ((isize - 1) >> PAGE_SHIFT);
 
 	for (page_idx = 1; page_idx < page_cnt; page_idx++) {
 		pgoff_t page_offset = offset + page_idx;
@@ -788,7 +788,7 @@ static int ubifs_do_bulk_read(struct ubifs_info *c, struct bu_info *bu,
 		if (!PageUptodate(page))
 			err = populate_page(c, page, bu, &n);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		if (err)
 			break;
 	}
@@ -905,7 +905,7 @@ static int do_writepage(struct page *page, int len)
 #ifdef UBIFS_DEBUG
 	struct ubifs_inode *ui = ubifs_inode(inode);
 	spin_lock(&ui->ui_lock);
-	ubifs_assert(page->index <= ui->synced_i_size >> PAGE_CACHE_SHIFT);
+	ubifs_assert(page->index <= ui->synced_i_size >> PAGE_SHIFT);
 	spin_unlock(&ui->ui_lock);
 #endif
 
@@ -1001,8 +1001,8 @@ static int ubifs_writepage(struct page *page, struct writeback_control *wbc)
 	struct inode *inode = page->mapping->host;
 	struct ubifs_inode *ui = ubifs_inode(inode);
 	loff_t i_size =  i_size_read(inode), synced_i_size;
-	pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
-	int err, len = i_size & (PAGE_CACHE_SIZE - 1);
+	pgoff_t end_index = i_size >> PAGE_SHIFT;
+	int err, len = i_size & (PAGE_SIZE - 1);
 	void *kaddr;
 
 	dbg_gen("ino %lu, pg %lu, pg flags %#lx",
@@ -1021,7 +1021,7 @@ static int ubifs_writepage(struct page *page, struct writeback_control *wbc)
 
 	/* Is the page fully inside @i_size? */
 	if (page->index < end_index) {
-		if (page->index >= synced_i_size >> PAGE_CACHE_SHIFT) {
+		if (page->index >= synced_i_size >> PAGE_SHIFT) {
 			err = inode->i_sb->s_op->write_inode(inode, NULL);
 			if (err)
 				goto out_unlock;
@@ -1034,7 +1034,7 @@ static int ubifs_writepage(struct page *page, struct writeback_control *wbc)
 			 * with this.
 			 */
 		}
-		return do_writepage(page, PAGE_CACHE_SIZE);
+		return do_writepage(page, PAGE_SIZE);
 	}
 
 	/*
@@ -1045,7 +1045,7 @@ static int ubifs_writepage(struct page *page, struct writeback_control *wbc)
 	 * writes to that region are not written out to the file."
 	 */
 	kaddr = kmap_atomic(page);
-	memset(kaddr + len, 0, PAGE_CACHE_SIZE - len);
+	memset(kaddr + len, 0, PAGE_SIZE - len);
 	flush_dcache_page(page);
 	kunmap_atomic(kaddr);
 
@@ -1138,7 +1138,7 @@ static int do_truncation(struct ubifs_info *c, struct inode *inode,
 	truncate_setsize(inode, new_size);
 
 	if (offset) {
-		pgoff_t index = new_size >> PAGE_CACHE_SHIFT;
+		pgoff_t index = new_size >> PAGE_SHIFT;
 		struct page *page;
 
 		page = find_lock_page(inode->i_mapping, index);
@@ -1157,9 +1157,9 @@ static int do_truncation(struct ubifs_info *c, struct inode *inode,
 				clear_page_dirty_for_io(page);
 				if (UBIFS_BLOCKS_PER_PAGE_SHIFT)
 					offset = new_size &
-						 (PAGE_CACHE_SIZE - 1);
+						 (PAGE_SIZE - 1);
 				err = do_writepage(page, offset);
-				page_cache_release(page);
+				put_page(page);
 				if (err)
 					goto out_budg;
 				/*
@@ -1173,7 +1173,7 @@ static int do_truncation(struct ubifs_info *c, struct inode *inode,
 				 * having to read it.
 				 */
 				unlock_page(page);
-				page_cache_release(page);
+				put_page(page);
 			}
 		}
 	}
@@ -1285,7 +1285,7 @@ static void ubifs_invalidatepage(struct page *page, unsigned int offset,
 	struct ubifs_info *c = inode->i_sb->s_fs_info;
 
 	ubifs_assert(PagePrivate(page));
-	if (offset || length < PAGE_CACHE_SIZE)
+	if (offset || length < PAGE_SIZE)
 		/* Partial page remains dirty */
 		return;
 
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index a233ba913be4..e98c24ee25a1 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -2237,12 +2237,12 @@ static int __init ubifs_init(void)
 	BUILD_BUG_ON(UBIFS_COMPR_TYPES_CNT > 4);
 
 	/*
-	 * We require that PAGE_CACHE_SIZE is greater-than-or-equal-to
+	 * We require that PAGE_SIZE is greater-than-or-equal-to
 	 * UBIFS_BLOCK_SIZE. It is assumed that both are powers of 2.
 	 */
-	if (PAGE_CACHE_SIZE < UBIFS_BLOCK_SIZE) {
+	if (PAGE_SIZE < UBIFS_BLOCK_SIZE) {
 		pr_err("UBIFS error (pid %d): VFS page cache size is %u bytes, but UBIFS requires at least 4096 bytes",
-		       current->pid, (unsigned int)PAGE_CACHE_SIZE);
+		       current->pid, (unsigned int)PAGE_SIZE);
 		return -EINVAL;
 	}
 
diff --git a/fs/ubifs/ubifs.h b/fs/ubifs/ubifs.h
index a5697de763f5..425e6a36637f 100644
--- a/fs/ubifs/ubifs.h
+++ b/fs/ubifs/ubifs.h
@@ -70,8 +70,8 @@
 #define UBIFS_SUPER_MAGIC 0x24051905
 
 /* Number of UBIFS blocks per VFS page */
-#define UBIFS_BLOCKS_PER_PAGE (PAGE_CACHE_SIZE / UBIFS_BLOCK_SIZE)
-#define UBIFS_BLOCKS_PER_PAGE_SHIFT (PAGE_CACHE_SHIFT - UBIFS_BLOCK_SHIFT)
+#define UBIFS_BLOCKS_PER_PAGE (PAGE_SIZE / UBIFS_BLOCK_SIZE)
+#define UBIFS_BLOCKS_PER_PAGE_SHIFT (PAGE_SHIFT - UBIFS_BLOCK_SHIFT)
 
 /* "File system end of life" sequence number watermark */
 #define SQNUM_WARN_WATERMARK 0xFFFFFFFF00000000ULL
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
