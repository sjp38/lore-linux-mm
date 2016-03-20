Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2A22D82F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:48:16 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id x3so237559920pfb.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:48:16 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id oi7si1467849pab.183.2016.03.20.11.41.52
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:52 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 63/71] ufs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:41:10 +0300
Message-Id: <1458499278-1516-64-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Evgeniy Dushistov <dushistov@mail.ru>

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
Cc: Evgeniy Dushistov <dushistov@mail.ru>
---
 fs/ufs/balloc.c |  6 +++---
 fs/ufs/dir.c    | 32 ++++++++++++++++----------------
 fs/ufs/inode.c  |  4 ++--
 fs/ufs/namei.c  |  6 +++---
 fs/ufs/util.c   |  4 ++--
 fs/ufs/util.h   |  2 +-
 6 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/fs/ufs/balloc.c b/fs/ufs/balloc.c
index dc5fae601c24..0447b949c7f5 100644
--- a/fs/ufs/balloc.c
+++ b/fs/ufs/balloc.c
@@ -237,7 +237,7 @@ static void ufs_change_blocknr(struct inode *inode, sector_t beg,
 			       sector_t newb, struct page *locked_page)
 {
 	const unsigned blks_per_page =
-		1 << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+		1 << (PAGE_SHIFT - inode->i_blkbits);
 	const unsigned mask = blks_per_page - 1;
 	struct address_space * const mapping = inode->i_mapping;
 	pgoff_t index, cur_index, last_index;
@@ -255,9 +255,9 @@ static void ufs_change_blocknr(struct inode *inode, sector_t beg,
 
 	cur_index = locked_page->index;
 	end = count + beg;
-	last_index = end >> (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	last_index = end >> (PAGE_SHIFT - inode->i_blkbits);
 	for (i = beg; i < end; i = (i | mask) + 1) {
-		index = i >> (PAGE_CACHE_SHIFT - inode->i_blkbits);
+		index = i >> (PAGE_SHIFT - inode->i_blkbits);
 
 		if (likely(cur_index != index)) {
 			page = ufs_get_locked_page(mapping, index);
diff --git a/fs/ufs/dir.c b/fs/ufs/dir.c
index 74f2e80288bf..0b1457292734 100644
--- a/fs/ufs/dir.c
+++ b/fs/ufs/dir.c
@@ -62,7 +62,7 @@ static int ufs_commit_chunk(struct page *page, loff_t pos, unsigned len)
 static inline void ufs_put_page(struct page *page)
 {
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 ino_t ufs_inode_by_name(struct inode *dir, const struct qstr *qstr)
@@ -111,13 +111,13 @@ static void ufs_check_page(struct page *page)
 	struct super_block *sb = dir->i_sb;
 	char *kaddr = page_address(page);
 	unsigned offs, rec_len;
-	unsigned limit = PAGE_CACHE_SIZE;
+	unsigned limit = PAGE_SIZE;
 	const unsigned chunk_mask = UFS_SB(sb)->s_uspi->s_dirblksize - 1;
 	struct ufs_dir_entry *p;
 	char *error;
 
-	if ((dir->i_size >> PAGE_CACHE_SHIFT) == page->index) {
-		limit = dir->i_size & ~PAGE_CACHE_MASK;
+	if ((dir->i_size >> PAGE_SHIFT) == page->index) {
+		limit = dir->i_size & ~PAGE_MASK;
 		if (limit & chunk_mask)
 			goto Ebadsize;
 		if (!limit)
@@ -170,7 +170,7 @@ Einumber:
 bad_entry:
 	ufs_error (sb, "ufs_check_page", "bad entry in directory #%lu: %s - "
 		   "offset=%lu, rec_len=%d, name_len=%d",
-		   dir->i_ino, error, (page->index<<PAGE_CACHE_SHIFT)+offs,
+		   dir->i_ino, error, (page->index<<PAGE_SHIFT)+offs,
 		   rec_len, ufs_get_de_namlen(sb, p));
 	goto fail;
 Eend:
@@ -178,7 +178,7 @@ Eend:
 	ufs_error(sb, __func__,
 		   "entry in directory #%lu spans the page boundary"
 		   "offset=%lu",
-		   dir->i_ino, (page->index<<PAGE_CACHE_SHIFT)+offs);
+		   dir->i_ino, (page->index<<PAGE_SHIFT)+offs);
 fail:
 	SetPageChecked(page);
 	SetPageError(page);
@@ -211,9 +211,9 @@ ufs_last_byte(struct inode *inode, unsigned long page_nr)
 {
 	unsigned last_byte = inode->i_size;
 
-	last_byte -= page_nr << PAGE_CACHE_SHIFT;
-	if (last_byte > PAGE_CACHE_SIZE)
-		last_byte = PAGE_CACHE_SIZE;
+	last_byte -= page_nr << PAGE_SHIFT;
+	if (last_byte > PAGE_SIZE)
+		last_byte = PAGE_SIZE;
 	return last_byte;
 }
 
@@ -341,7 +341,7 @@ int ufs_add_link(struct dentry *dentry, struct inode *inode)
 		kaddr = page_address(page);
 		dir_end = kaddr + ufs_last_byte(dir, n);
 		de = (struct ufs_dir_entry *)kaddr;
-		kaddr += PAGE_CACHE_SIZE - reclen;
+		kaddr += PAGE_SIZE - reclen;
 		while ((char *)de <= kaddr) {
 			if ((char *)de == dir_end) {
 				/* We hit i_size */
@@ -432,8 +432,8 @@ ufs_readdir(struct file *file, struct dir_context *ctx)
 	loff_t pos = ctx->pos;
 	struct inode *inode = file_inode(file);
 	struct super_block *sb = inode->i_sb;
-	unsigned int offset = pos & ~PAGE_CACHE_MASK;
-	unsigned long n = pos >> PAGE_CACHE_SHIFT;
+	unsigned int offset = pos & ~PAGE_MASK;
+	unsigned long n = pos >> PAGE_SHIFT;
 	unsigned long npages = dir_pages(inode);
 	unsigned chunk_mask = ~(UFS_SB(sb)->s_uspi->s_dirblksize - 1);
 	int need_revalidate = file->f_version != inode->i_version;
@@ -454,14 +454,14 @@ ufs_readdir(struct file *file, struct dir_context *ctx)
 			ufs_error(sb, __func__,
 				  "bad page in #%lu",
 				  inode->i_ino);
-			ctx->pos += PAGE_CACHE_SIZE - offset;
+			ctx->pos += PAGE_SIZE - offset;
 			return -EIO;
 		}
 		kaddr = page_address(page);
 		if (unlikely(need_revalidate)) {
 			if (offset) {
 				offset = ufs_validate_entry(sb, kaddr, offset, chunk_mask);
-				ctx->pos = (n<<PAGE_CACHE_SHIFT) + offset;
+				ctx->pos = (n<<PAGE_SHIFT) + offset;
 			}
 			file->f_version = inode->i_version;
 			need_revalidate = 0;
@@ -574,7 +574,7 @@ int ufs_make_empty(struct inode * inode, struct inode *dir)
 
 	kmap(page);
 	base = (char*)page_address(page);
-	memset(base, 0, PAGE_CACHE_SIZE);
+	memset(base, 0, PAGE_SIZE);
 
 	de = (struct ufs_dir_entry *) base;
 
@@ -594,7 +594,7 @@ int ufs_make_empty(struct inode * inode, struct inode *dir)
 
 	err = ufs_commit_chunk(page, 0, chunk_size);
 fail:
-	page_cache_release(page);
+	put_page(page);
 	return err;
 }
 
diff --git a/fs/ufs/inode.c b/fs/ufs/inode.c
index d897e169ab9c..9f49431e798d 100644
--- a/fs/ufs/inode.c
+++ b/fs/ufs/inode.c
@@ -1051,13 +1051,13 @@ static int ufs_alloc_lastblock(struct inode *inode, loff_t size)
 	lastfrag--;
 
 	lastpage = ufs_get_locked_page(mapping, lastfrag >>
-				       (PAGE_CACHE_SHIFT - inode->i_blkbits));
+				       (PAGE_SHIFT - inode->i_blkbits));
        if (IS_ERR(lastpage)) {
                err = -EIO;
                goto out;
        }
 
-       end = lastfrag & ((1 << (PAGE_CACHE_SHIFT - inode->i_blkbits)) - 1);
+       end = lastfrag & ((1 << (PAGE_SHIFT - inode->i_blkbits)) - 1);
        bh = page_buffers(lastpage);
        for (i = 0; i < end; ++i)
                bh = bh->b_this_page;
diff --git a/fs/ufs/namei.c b/fs/ufs/namei.c
index acf4a3b61b81..a1559f762805 100644
--- a/fs/ufs/namei.c
+++ b/fs/ufs/namei.c
@@ -305,7 +305,7 @@ static int ufs_rename(struct inode *old_dir, struct dentry *old_dentry,
 			ufs_set_link(old_inode, dir_de, dir_page, new_dir, 0);
 		else {
 			kunmap(dir_page);
-			page_cache_release(dir_page);
+			put_page(dir_page);
 		}
 		inode_dec_link_count(old_dir);
 	}
@@ -315,11 +315,11 @@ static int ufs_rename(struct inode *old_dir, struct dentry *old_dentry,
 out_dir:
 	if (dir_de) {
 		kunmap(dir_page);
-		page_cache_release(dir_page);
+		put_page(dir_page);
 	}
 out_old:
 	kunmap(old_page);
-	page_cache_release(old_page);
+	put_page(old_page);
 out:
 	return err;
 }
diff --git a/fs/ufs/util.c b/fs/ufs/util.c
index b6c2f94e041e..a409e3e7827a 100644
--- a/fs/ufs/util.c
+++ b/fs/ufs/util.c
@@ -261,14 +261,14 @@ struct page *ufs_get_locked_page(struct address_space *mapping,
 		if (unlikely(page->mapping == NULL)) {
 			/* Truncate got there first */
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			page = NULL;
 			goto out;
 		}
 
 		if (!PageUptodate(page) || PageError(page)) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 
 			printk(KERN_ERR "ufs_change_blocknr: "
 			       "can not read page: ino %lu, index: %lu\n",
diff --git a/fs/ufs/util.h b/fs/ufs/util.h
index 954175928240..b7fbf53dbc81 100644
--- a/fs/ufs/util.h
+++ b/fs/ufs/util.h
@@ -283,7 +283,7 @@ extern struct page *ufs_get_locked_page(struct address_space *mapping,
 static inline void ufs_put_locked_page(struct page *page)
 {
        unlock_page(page);
-       page_cache_release(page);
+       put_page(page);
 }
 
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
