Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4A47582F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:49:34 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id u190so238347864pfb.3
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:49:34 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id wb2si13830644pab.213.2016.03.20.11.41.49
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:49 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 48/71] minix: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:55 +0300
Message-Id: <1458499278-1516-49-git-send-email-kirill.shutemov@linux.intel.com>
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
 fs/minix/dir.c   | 18 +++++++++---------
 fs/minix/namei.c |  4 ++--
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/fs/minix/dir.c b/fs/minix/dir.c
index d19ac258105a..33957c07cd11 100644
--- a/fs/minix/dir.c
+++ b/fs/minix/dir.c
@@ -28,7 +28,7 @@ const struct file_operations minix_dir_operations = {
 static inline void dir_put_page(struct page *page)
 {
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 /*
@@ -38,10 +38,10 @@ static inline void dir_put_page(struct page *page)
 static unsigned
 minix_last_byte(struct inode *inode, unsigned long page_nr)
 {
-	unsigned last_byte = PAGE_CACHE_SIZE;
+	unsigned last_byte = PAGE_SIZE;
 
-	if (page_nr == (inode->i_size >> PAGE_CACHE_SHIFT))
-		last_byte = inode->i_size & (PAGE_CACHE_SIZE - 1);
+	if (page_nr == (inode->i_size >> PAGE_SHIFT))
+		last_byte = inode->i_size & (PAGE_SIZE - 1);
 	return last_byte;
 }
 
@@ -92,8 +92,8 @@ static int minix_readdir(struct file *file, struct dir_context *ctx)
 	if (pos >= inode->i_size)
 		return 0;
 
-	offset = pos & ~PAGE_CACHE_MASK;
-	n = pos >> PAGE_CACHE_SHIFT;
+	offset = pos & ~PAGE_MASK;
+	n = pos >> PAGE_SHIFT;
 
 	for ( ; n < npages; n++, offset = 0) {
 		char *p, *kaddr, *limit;
@@ -229,7 +229,7 @@ int minix_add_link(struct dentry *dentry, struct inode *inode)
 		lock_page(page);
 		kaddr = (char*)page_address(page);
 		dir_end = kaddr + minix_last_byte(dir, n);
-		limit = kaddr + PAGE_CACHE_SIZE - sbi->s_dirsize;
+		limit = kaddr + PAGE_SIZE - sbi->s_dirsize;
 		for (p = kaddr; p <= limit; p = minix_next_entry(p, sbi)) {
 			de = (minix_dirent *)p;
 			de3 = (minix3_dirent *)p;
@@ -327,7 +327,7 @@ int minix_make_empty(struct inode *inode, struct inode *dir)
 	}
 
 	kaddr = kmap_atomic(page);
-	memset(kaddr, 0, PAGE_CACHE_SIZE);
+	memset(kaddr, 0, PAGE_SIZE);
 
 	if (sbi->s_version == MINIX_V3) {
 		minix3_dirent *de3 = (minix3_dirent *)kaddr;
@@ -350,7 +350,7 @@ int minix_make_empty(struct inode *inode, struct inode *dir)
 
 	err = dir_commit_chunk(page, 0, 2 * sbi->s_dirsize);
 fail:
-	page_cache_release(page);
+	put_page(page);
 	return err;
 }
 
diff --git a/fs/minix/namei.c b/fs/minix/namei.c
index a795a11e50c7..2887d1d95ce2 100644
--- a/fs/minix/namei.c
+++ b/fs/minix/namei.c
@@ -243,11 +243,11 @@ static int minix_rename(struct inode * old_dir, struct dentry *old_dentry,
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
