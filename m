Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7A5E6828DF
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:42:12 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id u190so238222330pfb.3
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:42:12 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qx12si13425508pab.169.2016.03.20.11.41.48
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:48 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 35/71] freevxfs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:42 +0300
Message-Id: <1458499278-1516-36-git-send-email-kirill.shutemov@linux.intel.com>
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
 fs/freevxfs/vxfs_immed.c  |  4 ++--
 fs/freevxfs/vxfs_lookup.c | 12 ++++++------
 fs/freevxfs/vxfs_subr.c   |  2 +-
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/freevxfs/vxfs_immed.c b/fs/freevxfs/vxfs_immed.c
index cb84f0fcc72a..bfc780c682fb 100644
--- a/fs/freevxfs/vxfs_immed.c
+++ b/fs/freevxfs/vxfs_immed.c
@@ -66,11 +66,11 @@ static int
 vxfs_immed_readpage(struct file *fp, struct page *pp)
 {
 	struct vxfs_inode_info	*vip = VXFS_INO(pp->mapping->host);
-	u_int64_t	offset = (u_int64_t)pp->index << PAGE_CACHE_SHIFT;
+	u_int64_t	offset = (u_int64_t)pp->index << PAGE_SHIFT;
 	caddr_t		kaddr;
 
 	kaddr = kmap(pp);
-	memcpy(kaddr, vip->vii_immed.vi_immed + offset, PAGE_CACHE_SIZE);
+	memcpy(kaddr, vip->vii_immed.vi_immed + offset, PAGE_SIZE);
 	kunmap(pp);
 	
 	flush_dcache_page(pp);
diff --git a/fs/freevxfs/vxfs_lookup.c b/fs/freevxfs/vxfs_lookup.c
index 1cff72df0389..a49e0cfbb686 100644
--- a/fs/freevxfs/vxfs_lookup.c
+++ b/fs/freevxfs/vxfs_lookup.c
@@ -45,7 +45,7 @@
 /*
  * Number of VxFS blocks per page.
  */
-#define VXFS_BLOCK_PER_PAGE(sbp)  ((PAGE_CACHE_SIZE / (sbp)->s_blocksize))
+#define VXFS_BLOCK_PER_PAGE(sbp)  ((PAGE_SIZE / (sbp)->s_blocksize))
 
 
 static struct dentry *	vxfs_lookup(struct inode *, struct dentry *, unsigned int);
@@ -175,7 +175,7 @@ vxfs_inode_by_name(struct inode *dip, struct dentry *dp)
 	if (de) {
 		ino = de->d_ino;
 		kunmap(pp);
-		page_cache_release(pp);
+		put_page(pp);
 	}
 	
 	return (ino);
@@ -255,8 +255,8 @@ vxfs_readdir(struct file *fp, struct dir_context *ctx)
 	nblocks = dir_blocks(ip);
 	pblocks = VXFS_BLOCK_PER_PAGE(sbp);
 
-	page = pos >> PAGE_CACHE_SHIFT;
-	offset = pos & ~PAGE_CACHE_MASK;
+	page = pos >> PAGE_SHIFT;
+	offset = pos & ~PAGE_MASK;
 	block = (u_long)(pos >> sbp->s_blocksize_bits) % pblocks;
 
 	for (; page < npages; page++, block = 0) {
@@ -289,7 +289,7 @@ vxfs_readdir(struct file *fp, struct dir_context *ctx)
 					continue;
 
 				offset = (char *)de - kaddr;
-				ctx->pos = ((page << PAGE_CACHE_SHIFT) | offset) + 2;
+				ctx->pos = ((page << PAGE_SHIFT) | offset) + 2;
 				if (!dir_emit(ctx, de->d_name, de->d_namelen,
 					de->d_ino, DT_UNKNOWN)) {
 					vxfs_put_page(pp);
@@ -301,6 +301,6 @@ vxfs_readdir(struct file *fp, struct dir_context *ctx)
 		vxfs_put_page(pp);
 		offset = 0;
 	}
-	ctx->pos = ((page << PAGE_CACHE_SHIFT) | offset) + 2;
+	ctx->pos = ((page << PAGE_SHIFT) | offset) + 2;
 	return 0;
 }
diff --git a/fs/freevxfs/vxfs_subr.c b/fs/freevxfs/vxfs_subr.c
index 5d318c44f855..e806694d4145 100644
--- a/fs/freevxfs/vxfs_subr.c
+++ b/fs/freevxfs/vxfs_subr.c
@@ -50,7 +50,7 @@ inline void
 vxfs_put_page(struct page *pp)
 {
 	kunmap(pp);
-	page_cache_release(pp);
+	put_page(pp);
 }
 
 /**
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
