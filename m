Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id D30AF82F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:48:48 -0400 (EDT)
Received: by mail-pf0-f169.google.com with SMTP id u190so238335280pfb.3
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:48:48 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qx12si13425508pab.169.2016.03.20.11.41.46
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 32/71] ext2: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:39 +0300
Message-Id: <1458499278-1516-33-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>

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
Cc: Jan Kara <jack@suse.com>
---
 fs/ext2/dir.c   | 36 ++++++++++++++++++------------------
 fs/ext2/namei.c |  6 +++---
 2 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/fs/ext2/dir.c b/fs/ext2/dir.c
index 0c6638b40f21..7ff6fcfa685d 100644
--- a/fs/ext2/dir.c
+++ b/fs/ext2/dir.c
@@ -37,7 +37,7 @@ static inline unsigned ext2_rec_len_from_disk(__le16 dlen)
 {
 	unsigned len = le16_to_cpu(dlen);
 
-#if (PAGE_CACHE_SIZE >= 65536)
+#if (PAGE_SIZE >= 65536)
 	if (len == EXT2_MAX_REC_LEN)
 		return 1 << 16;
 #endif
@@ -46,7 +46,7 @@ static inline unsigned ext2_rec_len_from_disk(__le16 dlen)
 
 static inline __le16 ext2_rec_len_to_disk(unsigned len)
 {
-#if (PAGE_CACHE_SIZE >= 65536)
+#if (PAGE_SIZE >= 65536)
 	if (len == (1 << 16))
 		return cpu_to_le16(EXT2_MAX_REC_LEN);
 	else
@@ -67,7 +67,7 @@ static inline unsigned ext2_chunk_size(struct inode *inode)
 static inline void ext2_put_page(struct page *page)
 {
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 /*
@@ -79,9 +79,9 @@ ext2_last_byte(struct inode *inode, unsigned long page_nr)
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
 
@@ -118,12 +118,12 @@ static void ext2_check_page(struct page *page, int quiet)
 	char *kaddr = page_address(page);
 	u32 max_inumber = le32_to_cpu(EXT2_SB(sb)->s_es->s_inodes_count);
 	unsigned offs, rec_len;
-	unsigned limit = PAGE_CACHE_SIZE;
+	unsigned limit = PAGE_SIZE;
 	ext2_dirent *p;
 	char *error;
 
-	if ((dir->i_size >> PAGE_CACHE_SHIFT) == page->index) {
-		limit = dir->i_size & ~PAGE_CACHE_MASK;
+	if ((dir->i_size >> PAGE_SHIFT) == page->index) {
+		limit = dir->i_size & ~PAGE_MASK;
 		if (limit & (chunk_size - 1))
 			goto Ebadsize;
 		if (!limit)
@@ -176,7 +176,7 @@ bad_entry:
 	if (!quiet)
 		ext2_error(sb, __func__, "bad entry in directory #%lu: : %s - "
 			"offset=%lu, inode=%lu, rec_len=%d, name_len=%d",
-			dir->i_ino, error, (page->index<<PAGE_CACHE_SHIFT)+offs,
+			dir->i_ino, error, (page->index<<PAGE_SHIFT)+offs,
 			(unsigned long) le32_to_cpu(p->inode),
 			rec_len, p->name_len);
 	goto fail;
@@ -186,7 +186,7 @@ Eend:
 		ext2_error(sb, "ext2_check_page",
 			"entry in directory #%lu spans the page boundary"
 			"offset=%lu, inode=%lu",
-			dir->i_ino, (page->index<<PAGE_CACHE_SHIFT)+offs,
+			dir->i_ino, (page->index<<PAGE_SHIFT)+offs,
 			(unsigned long) le32_to_cpu(p->inode));
 	}
 fail:
@@ -287,8 +287,8 @@ ext2_readdir(struct file *file, struct dir_context *ctx)
 	loff_t pos = ctx->pos;
 	struct inode *inode = file_inode(file);
 	struct super_block *sb = inode->i_sb;
-	unsigned int offset = pos & ~PAGE_CACHE_MASK;
-	unsigned long n = pos >> PAGE_CACHE_SHIFT;
+	unsigned int offset = pos & ~PAGE_MASK;
+	unsigned long n = pos >> PAGE_SHIFT;
 	unsigned long npages = dir_pages(inode);
 	unsigned chunk_mask = ~(ext2_chunk_size(inode)-1);
 	unsigned char *types = NULL;
@@ -309,14 +309,14 @@ ext2_readdir(struct file *file, struct dir_context *ctx)
 			ext2_error(sb, __func__,
 				   "bad page in #%lu",
 				   inode->i_ino);
-			ctx->pos += PAGE_CACHE_SIZE - offset;
+			ctx->pos += PAGE_SIZE - offset;
 			return PTR_ERR(page);
 		}
 		kaddr = page_address(page);
 		if (unlikely(need_revalidate)) {
 			if (offset) {
 				offset = ext2_validate_entry(kaddr, offset, chunk_mask);
-				ctx->pos = (n<<PAGE_CACHE_SHIFT) + offset;
+				ctx->pos = (n<<PAGE_SHIFT) + offset;
 			}
 			file->f_version = inode->i_version;
 			need_revalidate = 0;
@@ -406,7 +406,7 @@ struct ext2_dir_entry_2 *ext2_find_entry (struct inode * dir,
 		if (++n >= npages)
 			n = 0;
 		/* next page is past the blocks we've got */
-		if (unlikely(n > (dir->i_blocks >> (PAGE_CACHE_SHIFT - 9)))) {
+		if (unlikely(n > (dir->i_blocks >> (PAGE_SHIFT - 9)))) {
 			ext2_error(dir->i_sb, __func__,
 				"dir %lu size %lld exceeds block count %llu",
 				dir->i_ino, dir->i_size,
@@ -511,7 +511,7 @@ int ext2_add_link (struct dentry *dentry, struct inode *inode)
 		kaddr = page_address(page);
 		dir_end = kaddr + ext2_last_byte(dir, n);
 		de = (ext2_dirent *)kaddr;
-		kaddr += PAGE_CACHE_SIZE - reclen;
+		kaddr += PAGE_SIZE - reclen;
 		while ((char *)de <= kaddr) {
 			if ((char *)de == dir_end) {
 				/* We hit i_size */
@@ -655,7 +655,7 @@ int ext2_make_empty(struct inode *inode, struct inode *parent)
 	kunmap_atomic(kaddr);
 	err = ext2_commit_chunk(page, 0, chunk_size);
 fail:
-	page_cache_release(page);
+	put_page(page);
 	return err;
 }
 
diff --git a/fs/ext2/namei.c b/fs/ext2/namei.c
index 7a2be8f7f3c3..d34843925b23 100644
--- a/fs/ext2/namei.c
+++ b/fs/ext2/namei.c
@@ -398,7 +398,7 @@ static int ext2_rename (struct inode * old_dir, struct dentry * old_dentry,
 			ext2_set_link(old_inode, dir_de, dir_page, new_dir, 0);
 		else {
 			kunmap(dir_page);
-			page_cache_release(dir_page);
+			put_page(dir_page);
 		}
 		inode_dec_link_count(old_dir);
 	}
@@ -408,11 +408,11 @@ static int ext2_rename (struct inode * old_dir, struct dentry * old_dentry,
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
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
