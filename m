Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7FEBB82F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:48:28 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id 4so106652355pfd.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:48:28 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id i62si14046921pfi.222.2016.03.20.11.41.46
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:46 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 21/71] afs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:28 +0300
Message-Id: <1458499278-1516-22-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Howells <dhowells@redhat.com>

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
Cc: David Howells <dhowells@redhat.com>
---
 fs/afs/dir.c   |  2 +-
 fs/afs/file.c  |  4 ++--
 fs/afs/mntpt.c |  6 +++---
 fs/afs/super.c |  4 ++--
 fs/afs/write.c | 26 +++++++++++++-------------
 5 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index e10e17788f06..5fda2bc53cd7 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -181,7 +181,7 @@ error:
 static inline void afs_dir_put_page(struct page *page)
 {
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 /*
diff --git a/fs/afs/file.c b/fs/afs/file.c
index 999bc3caec92..6344aee4ac4b 100644
--- a/fs/afs/file.c
+++ b/fs/afs/file.c
@@ -164,7 +164,7 @@ int afs_page_filler(void *data, struct page *page)
 		_debug("cache said ENOBUFS");
 	default:
 	go_on:
-		offset = page->index << PAGE_CACHE_SHIFT;
+		offset = page->index << PAGE_SHIFT;
 		len = min_t(size_t, i_size_read(inode) - offset, PAGE_SIZE);
 
 		/* read the contents of the file from the server into the
@@ -319,7 +319,7 @@ static void afs_invalidatepage(struct page *page, unsigned int offset,
 	BUG_ON(!PageLocked(page));
 
 	/* we clean up only if the entire page is being invalidated */
-	if (offset == 0 && length == PAGE_CACHE_SIZE) {
+	if (offset == 0 && length == PAGE_SIZE) {
 #ifdef CONFIG_AFS_FSCACHE
 		if (PageFsCache(page)) {
 			struct afs_vnode *vnode = AFS_FS_I(page->mapping->host);
diff --git a/fs/afs/mntpt.c b/fs/afs/mntpt.c
index ccd0b212e82a..81dd075356b9 100644
--- a/fs/afs/mntpt.c
+++ b/fs/afs/mntpt.c
@@ -93,7 +93,7 @@ int afs_mntpt_check_symlink(struct afs_vnode *vnode, struct key *key)
 
 	kunmap(page);
 out_free:
-	page_cache_release(page);
+	put_page(page);
 out:
 	_leave(" = %d", ret);
 	return ret;
@@ -189,7 +189,7 @@ static struct vfsmount *afs_mntpt_do_automount(struct dentry *mntpt)
 		buf = kmap_atomic(page);
 		memcpy(devname, buf, size);
 		kunmap_atomic(buf);
-		page_cache_release(page);
+		put_page(page);
 		page = NULL;
 	}
 
@@ -211,7 +211,7 @@ static struct vfsmount *afs_mntpt_do_automount(struct dentry *mntpt)
 	return mnt;
 
 error:
-	page_cache_release(page);
+	put_page(page);
 error_no_page:
 	free_page((unsigned long) options);
 error_no_options:
diff --git a/fs/afs/super.c b/fs/afs/super.c
index 81afefe7d8a6..fbdb022b75a2 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -315,8 +315,8 @@ static int afs_fill_super(struct super_block *sb,
 	_enter("");
 
 	/* fill in the superblock */
-	sb->s_blocksize		= PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits	= PAGE_CACHE_SHIFT;
+	sb->s_blocksize		= PAGE_SIZE;
+	sb->s_blocksize_bits	= PAGE_SHIFT;
 	sb->s_magic		= AFS_FS_MAGIC;
 	sb->s_op		= &afs_super_ops;
 	sb->s_bdi		= &as->volume->bdi;
diff --git a/fs/afs/write.c b/fs/afs/write.c
index dfef94f70667..65de439bdc4f 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -93,10 +93,10 @@ static int afs_fill_page(struct afs_vnode *vnode, struct key *key,
 	_enter(",,%llu", (unsigned long long)pos);
 
 	i_size = i_size_read(&vnode->vfs_inode);
-	if (pos + PAGE_CACHE_SIZE > i_size)
+	if (pos + PAGE_SIZE > i_size)
 		len = i_size - pos;
 	else
-		len = PAGE_CACHE_SIZE;
+		len = PAGE_SIZE;
 
 	ret = afs_vnode_fetch_data(vnode, key, pos, len, page);
 	if (ret < 0) {
@@ -123,9 +123,9 @@ int afs_write_begin(struct file *file, struct address_space *mapping,
 	struct afs_vnode *vnode = AFS_FS_I(file_inode(file));
 	struct page *page;
 	struct key *key = file->private_data;
-	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned from = pos & (PAGE_SIZE - 1);
 	unsigned to = from + len;
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 	int ret;
 
 	_enter("{%x:%u},{%lx},%u,%u",
@@ -151,8 +151,8 @@ int afs_write_begin(struct file *file, struct address_space *mapping,
 	*pagep = page;
 	/* page won't leak in error case: it eventually gets cleaned off LRU */
 
-	if (!PageUptodate(page) && len != PAGE_CACHE_SIZE) {
-		ret = afs_fill_page(vnode, key, index << PAGE_CACHE_SHIFT, page);
+	if (!PageUptodate(page) && len != PAGE_SIZE) {
+		ret = afs_fill_page(vnode, key, index << PAGE_SHIFT, page);
 		if (ret < 0) {
 			kfree(candidate);
 			_leave(" = %d [prep]", ret);
@@ -266,7 +266,7 @@ int afs_write_end(struct file *file, struct address_space *mapping,
 	if (PageDirty(page))
 		_debug("dirtied");
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return copied;
 }
@@ -480,7 +480,7 @@ static int afs_writepages_region(struct address_space *mapping,
 
 		if (page->index > end) {
 			*_next = index;
-			page_cache_release(page);
+			put_page(page);
 			_leave(" = 0 [%lx]", *_next);
 			return 0;
 		}
@@ -494,7 +494,7 @@ static int afs_writepages_region(struct address_space *mapping,
 
 		if (page->mapping != mapping) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			continue;
 		}
 
@@ -515,7 +515,7 @@ static int afs_writepages_region(struct address_space *mapping,
 
 		ret = afs_write_back_from_locked_page(wb, page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		if (ret < 0) {
 			_leave(" = %d", ret);
 			return ret;
@@ -551,13 +551,13 @@ int afs_writepages(struct address_space *mapping,
 						    &next);
 		mapping->writeback_index = next;
 	} else if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX) {
-		end = (pgoff_t)(LLONG_MAX >> PAGE_CACHE_SHIFT);
+		end = (pgoff_t)(LLONG_MAX >> PAGE_SHIFT);
 		ret = afs_writepages_region(mapping, wbc, 0, end, &next);
 		if (wbc->nr_to_write > 0)
 			mapping->writeback_index = next;
 	} else {
-		start = wbc->range_start >> PAGE_CACHE_SHIFT;
-		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		start = wbc->range_start >> PAGE_SHIFT;
+		end = wbc->range_end >> PAGE_SHIFT;
 		ret = afs_writepages_region(mapping, wbc, start, end, &next);
 	}
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
