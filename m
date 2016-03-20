Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 11323828DF
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:42:07 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id x3so237455041pfb.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:42:07 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id i62si14046921pfi.222.2016.03.20.11.41.45
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:45 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 20/71] affs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:27 +0300
Message-Id: <1458499278-1516-21-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
---
 fs/affs/file.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/fs/affs/file.c b/fs/affs/file.c
index 22fc7c802d69..0cde550050e8 100644
--- a/fs/affs/file.c
+++ b/fs/affs/file.c
@@ -510,9 +510,9 @@ affs_do_readpage_ofs(struct page *page, unsigned to)
 
 	pr_debug("%s(%lu, %ld, 0, %d)\n", __func__, inode->i_ino,
 		 page->index, to);
-	BUG_ON(to > PAGE_CACHE_SIZE);
+	BUG_ON(to > PAGE_SIZE);
 	bsize = AFFS_SB(sb)->s_data_blksize;
-	tmp = page->index << PAGE_CACHE_SHIFT;
+	tmp = page->index << PAGE_SHIFT;
 	bidx = tmp / bsize;
 	boff = tmp % bsize;
 
@@ -613,10 +613,10 @@ affs_readpage_ofs(struct file *file, struct page *page)
 	int err;
 
 	pr_debug("%s(%lu, %ld)\n", __func__, inode->i_ino, page->index);
-	to = PAGE_CACHE_SIZE;
-	if (((page->index + 1) << PAGE_CACHE_SHIFT) > inode->i_size) {
-		to = inode->i_size & ~PAGE_CACHE_MASK;
-		memset(page_address(page) + to, 0, PAGE_CACHE_SIZE - to);
+	to = PAGE_SIZE;
+	if (((page->index + 1) << PAGE_SHIFT) > inode->i_size) {
+		to = inode->i_size & ~PAGE_MASK;
+		memset(page_address(page) + to, 0, PAGE_SIZE - to);
 	}
 
 	err = affs_do_readpage_ofs(page, to);
@@ -646,7 +646,7 @@ static int affs_write_begin_ofs(struct file *file, struct address_space *mapping
 			return err;
 	}
 
-	index = pos >> PAGE_CACHE_SHIFT;
+	index = pos >> PAGE_SHIFT;
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
 		return -ENOMEM;
@@ -656,10 +656,10 @@ static int affs_write_begin_ofs(struct file *file, struct address_space *mapping
 		return 0;
 
 	/* XXX: inefficient but safe in the face of short writes */
-	err = affs_do_readpage_ofs(page, PAGE_CACHE_SIZE);
+	err = affs_do_readpage_ofs(page, PAGE_SIZE);
 	if (err) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	return err;
 }
@@ -677,7 +677,7 @@ static int affs_write_end_ofs(struct file *file, struct address_space *mapping,
 	u32 tmp;
 	int written;
 
-	from = pos & (PAGE_CACHE_SIZE - 1);
+	from = pos & (PAGE_SIZE - 1);
 	to = pos + len;
 	/*
 	 * XXX: not sure if this can handle short copies (len < copied), but
@@ -692,7 +692,7 @@ static int affs_write_end_ofs(struct file *file, struct address_space *mapping,
 
 	bh = NULL;
 	written = 0;
-	tmp = (page->index << PAGE_CACHE_SHIFT) + from;
+	tmp = (page->index << PAGE_SHIFT) + from;
 	bidx = tmp / bsize;
 	boff = tmp % bsize;
 	if (boff) {
@@ -788,13 +788,13 @@ static int affs_write_end_ofs(struct file *file, struct address_space *mapping,
 
 done:
 	affs_brelse(bh);
-	tmp = (page->index << PAGE_CACHE_SHIFT) + from;
+	tmp = (page->index << PAGE_SHIFT) + from;
 	if (tmp > inode->i_size)
 		inode->i_size = AFFS_I(inode)->mmu_private = tmp;
 
 err_first_bh:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return written;
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
