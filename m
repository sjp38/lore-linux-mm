Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1D41182F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:48:32 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id u190so238330477pfb.3
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:48:32 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id oi7si1467849pab.183.2016.03.20.11.41.52
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:52 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 60/71] sysv: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:41:07 +0300
Message-Id: <1458499278-1516-61-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Hellwig <hch@infradead.org>

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
Cc: Christoph Hellwig <hch@infradead.org>
---
 fs/sysv/dir.c   | 18 +++++++++---------
 fs/sysv/namei.c |  4 ++--
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/fs/sysv/dir.c b/fs/sysv/dir.c
index 63c1bcb224ee..c0f0a3e643eb 100644
--- a/fs/sysv/dir.c
+++ b/fs/sysv/dir.c
@@ -30,7 +30,7 @@ const struct file_operations sysv_dir_operations = {
 static inline void dir_put_page(struct page *page)
 {
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 static int dir_commit_chunk(struct page *page, loff_t pos, unsigned len)
@@ -73,8 +73,8 @@ static int sysv_readdir(struct file *file, struct dir_context *ctx)
 	if (pos >= inode->i_size)
 		return 0;
 
-	offset = pos & ~PAGE_CACHE_MASK;
-	n = pos >> PAGE_CACHE_SHIFT;
+	offset = pos & ~PAGE_MASK;
+	n = pos >> PAGE_SHIFT;
 
 	for ( ; n < npages; n++, offset = 0) {
 		char *kaddr, *limit;
@@ -85,7 +85,7 @@ static int sysv_readdir(struct file *file, struct dir_context *ctx)
 			continue;
 		kaddr = (char *)page_address(page);
 		de = (struct sysv_dir_entry *)(kaddr+offset);
-		limit = kaddr + PAGE_CACHE_SIZE - SYSV_DIRSIZE;
+		limit = kaddr + PAGE_SIZE - SYSV_DIRSIZE;
 		for ( ;(char*)de <= limit; de++, ctx->pos += sizeof(*de)) {
 			char *name = de->name;
 
@@ -146,7 +146,7 @@ struct sysv_dir_entry *sysv_find_entry(struct dentry *dentry, struct page **res_
 		if (!IS_ERR(page)) {
 			kaddr = (char*)page_address(page);
 			de = (struct sysv_dir_entry *) kaddr;
-			kaddr += PAGE_CACHE_SIZE - SYSV_DIRSIZE;
+			kaddr += PAGE_SIZE - SYSV_DIRSIZE;
 			for ( ; (char *) de <= kaddr ; de++) {
 				if (!de->inode)
 					continue;
@@ -190,7 +190,7 @@ int sysv_add_link(struct dentry *dentry, struct inode *inode)
 			goto out;
 		kaddr = (char*)page_address(page);
 		de = (struct sysv_dir_entry *)kaddr;
-		kaddr += PAGE_CACHE_SIZE - SYSV_DIRSIZE;
+		kaddr += PAGE_SIZE - SYSV_DIRSIZE;
 		while ((char *)de <= kaddr) {
 			if (!de->inode)
 				goto got_it;
@@ -261,7 +261,7 @@ int sysv_make_empty(struct inode *inode, struct inode *dir)
 	kmap(page);
 
 	base = (char*)page_address(page);
-	memset(base, 0, PAGE_CACHE_SIZE);
+	memset(base, 0, PAGE_SIZE);
 
 	de = (struct sysv_dir_entry *) base;
 	de->inode = cpu_to_fs16(SYSV_SB(inode->i_sb), inode->i_ino);
@@ -273,7 +273,7 @@ int sysv_make_empty(struct inode *inode, struct inode *dir)
 	kunmap(page);
 	err = dir_commit_chunk(page, 0, 2 * SYSV_DIRSIZE);
 fail:
-	page_cache_release(page);
+	put_page(page);
 	return err;
 }
 
@@ -296,7 +296,7 @@ int sysv_empty_dir(struct inode * inode)
 
 		kaddr = (char *)page_address(page);
 		de = (struct sysv_dir_entry *)kaddr;
-		kaddr += PAGE_CACHE_SIZE-SYSV_DIRSIZE;
+		kaddr += PAGE_SIZE-SYSV_DIRSIZE;
 
 		for ( ;(char *)de <= kaddr; de++) {
 			if (!de->inode)
diff --git a/fs/sysv/namei.c b/fs/sysv/namei.c
index 11e83ed0b4bf..90b60c03b588 100644
--- a/fs/sysv/namei.c
+++ b/fs/sysv/namei.c
@@ -264,11 +264,11 @@ static int sysv_rename(struct inode * old_dir, struct dentry * old_dentry,
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
