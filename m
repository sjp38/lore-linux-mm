Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id A821A82F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:48:37 -0400 (EDT)
Received: by mail-pf0-f174.google.com with SMTP id u190so238332074pfb.3
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:48:37 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id i62si14046921pfi.222.2016.03.20.11.41.46
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:46 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 19/71] 9p: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:26 +0300
Message-Id: <1458499278-1516-20-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>

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
Cc: Eric Van Hensbergen <ericvh@gmail.com>
Cc: Ron Minnich <rminnich@sandia.gov>
Cc: Latchesar Ionkov <lucho@ionkov.net>
---
 fs/9p/vfs_addr.c  | 18 +++++++++---------
 fs/9p/vfs_file.c  |  4 ++--
 fs/9p/vfs_super.c |  2 +-
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/9p/vfs_addr.c b/fs/9p/vfs_addr.c
index e9e04376c52c..ac9225e86bf3 100644
--- a/fs/9p/vfs_addr.c
+++ b/fs/9p/vfs_addr.c
@@ -153,7 +153,7 @@ static void v9fs_invalidate_page(struct page *page, unsigned int offset,
 	 * If called with zero offset, we should release
 	 * the private state assocated with the page
 	 */
-	if (offset == 0 && length == PAGE_CACHE_SIZE)
+	if (offset == 0 && length == PAGE_SIZE)
 		v9fs_fscache_invalidate_page(page);
 }
 
@@ -166,10 +166,10 @@ static int v9fs_vfs_writepage_locked(struct page *page)
 	struct bio_vec bvec;
 	int err, len;
 
-	if (page->index == size >> PAGE_CACHE_SHIFT)
-		len = size & ~PAGE_CACHE_MASK;
+	if (page->index == size >> PAGE_SHIFT)
+		len = size & ~PAGE_MASK;
 	else
-		len = PAGE_CACHE_SIZE;
+		len = PAGE_SIZE;
 
 	bvec.bv_page = page;
 	bvec.bv_offset = 0;
@@ -271,7 +271,7 @@ static int v9fs_write_begin(struct file *filp, struct address_space *mapping,
 	int retval = 0;
 	struct page *page;
 	struct v9fs_inode *v9inode;
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 	struct inode *inode = mapping->host;
 
 
@@ -288,11 +288,11 @@ start:
 	if (PageUptodate(page))
 		goto out;
 
-	if (len == PAGE_CACHE_SIZE)
+	if (len == PAGE_SIZE)
 		goto out;
 
 	retval = v9fs_fid_readpage(v9inode->writeback_fid, page);
-	page_cache_release(page);
+	put_page(page);
 	if (!retval)
 		goto start;
 out:
@@ -313,7 +313,7 @@ static int v9fs_write_end(struct file *filp, struct address_space *mapping,
 		/*
 		 * zero out the rest of the area
 		 */
-		unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+		unsigned from = pos & (PAGE_SIZE - 1);
 
 		zero_user(page, from + copied, len - copied);
 		flush_dcache_page(page);
@@ -331,7 +331,7 @@ static int v9fs_write_end(struct file *filp, struct address_space *mapping,
 	}
 	set_page_dirty(page);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return copied;
 }
diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
index eadc894faea2..b84c291ba1eb 100644
--- a/fs/9p/vfs_file.c
+++ b/fs/9p/vfs_file.c
@@ -421,8 +421,8 @@ v9fs_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 		struct inode *inode = file_inode(file);
 		loff_t i_size;
 		unsigned long pg_start, pg_end;
-		pg_start = origin >> PAGE_CACHE_SHIFT;
-		pg_end = (origin + retval - 1) >> PAGE_CACHE_SHIFT;
+		pg_start = origin >> PAGE_SHIFT;
+		pg_end = (origin + retval - 1) >> PAGE_SHIFT;
 		if (inode->i_mapping && inode->i_mapping->nrpages)
 			invalidate_inode_pages2_range(inode->i_mapping,
 						      pg_start, pg_end);
diff --git a/fs/9p/vfs_super.c b/fs/9p/vfs_super.c
index bf495cedec26..de3ed8629196 100644
--- a/fs/9p/vfs_super.c
+++ b/fs/9p/vfs_super.c
@@ -87,7 +87,7 @@ v9fs_fill_super(struct super_block *sb, struct v9fs_session_info *v9ses,
 		sb->s_op = &v9fs_super_ops;
 	sb->s_bdi = &v9ses->bdi;
 	if (v9ses->cache)
-		sb->s_bdi->ra_pages = (VM_MAX_READAHEAD * 1024)/PAGE_CACHE_SIZE;
+		sb->s_bdi->ra_pages = (VM_MAX_READAHEAD * 1024)/PAGE_SIZE;
 
 	sb->s_flags |= MS_ACTIVE | MS_DIRSYNC | MS_NOATIME;
 	if (!v9ses->cache)
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
