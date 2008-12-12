From: Nick Piggin <npiggin@suse.de>
Subject: [patch] fs: symlink write_begin allocation context fix
Date: Fri, 12 Dec 2008 05:28:20 +0100
Message-ID: <20081212042820.GC15804@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org


With the write_begin/write_end aops, page_symlink was broken because it
could no longer pass a GFP_NOFS type mask into the point where the allocations
happened. They are done in write_begin, which would always assume that the
filesystem can be entered from reclaim. This bug could cause filesystem
deadlocks.

The funny thing with having a gfp_t mask there is that it doesn't really allow
the caller to arbitrarily tinker with the context in which it can be called.
It couldn't ever be GFP_ATOMIC, for example, because it needs to take the
page lock. The only thing any callers care about is __GFP_FS anyway, so turn
that into a single flag.

Add a new flag for write_begin, AOP_FLAG_NOFS. Filesystems can now act on
this flag in their write_begin function. Change __grab_cache_page to accept
a nofs argument as well, to honour that flag (while we're there, change the
name to grab_cache_page_write_begin which is more instructive and does away
with random leading underscores).

This is really a more flexible way to go in the end anyway -- if a filesystem
happens to want any extra allocations aside from the pagecache ones in ints
write_begin function, it may now use GFP_KERNEL (rather than GFP_NOFS) for
common case allocations (eg. ocfs2_alloc_write_ctxt, for a random example).

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
---
 fs/affs/file.c          |    2 +-
 fs/afs/write.c          |    2 +-
 fs/buffer.c             |    6 ++++--
 fs/cifs/file.c          |    3 ++-
 fs/ecryptfs/mmap.c      |    3 ++-
 fs/ext3/inode.c         |    3 ++-
 fs/ext3/namei.c         |    3 +--
 fs/ext4/inode.c         |    6 ++++--
 fs/ext4/namei.c         |    3 +--
 fs/fuse/file.c          |    3 ++-
 fs/gfs2/ops_address.c   |    3 ++-
 fs/hostfs/hostfs_kern.c |    3 ++-
 fs/jffs2/file.c         |    3 ++-
 fs/libfs.c              |    3 ++-
 fs/namei.c              |   13 +++++++++----
 fs/nfs/file.c           |    3 ++-
 fs/reiserfs/inode.c     |    3 ++-
 fs/smbfs/file.c         |    3 ++-
 fs/ubifs/file.c         |    6 ++++--
 include/linux/fs.h      |    5 ++++-
 include/linux/pagemap.h |    3 ++-
 mm/filemap.c            |   13 +++++++++----
 22 files changed, 62 insertions(+), 33 deletions(-)

Index: linux-2.6/fs/namei.c
===================================================================
--- linux-2.6.orig/fs/namei.c
+++ linux-2.6/fs/namei.c
@@ -2786,18 +2786,23 @@ void page_put_link(struct dentry *dentry
 	}
 }
 
-int __page_symlink(struct inode *inode, const char *symname, int len,
-		gfp_t gfp_mask)
+/*
+ * The nofs argument instructs pagecache_write_begin to pass AOP_FLAG_NOFS
+ */
+int __page_symlink(struct inode *inode, const char *symname, int len, int nofs)
 {
 	struct address_space *mapping = inode->i_mapping;
 	struct page *page;
 	void *fsdata;
 	int err;
 	char *kaddr;
+	unsigned int flags = AOP_FLAG_UNINTERRUPTIBLE;
+	if (nofs)
+		flags |= AOP_FLAG_NOFS;
 
 retry:
 	err = pagecache_write_begin(NULL, mapping, 0, len-1,
-				AOP_FLAG_UNINTERRUPTIBLE, &page, &fsdata);
+				flags, &page, &fsdata);
 	if (err)
 		goto fail;
 
@@ -2821,7 +2826,7 @@ fail:
 int page_symlink(struct inode *inode, const char *symname, int len)
 {
 	return __page_symlink(inode, symname, len,
-			mapping_gfp_mask(inode->i_mapping));
+			!(mapping_gfp_mask(inode->i_mapping) & __GFP_FS));
 }
 
 const struct inode_operations page_symlink_inode_operations = {
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -414,6 +414,9 @@ enum positive_aop_returns {
 
 #define AOP_FLAG_UNINTERRUPTIBLE	0x0001 /* will not do a short write */
 #define AOP_FLAG_CONT_EXPAND		0x0002 /* called from cont_expand */
+#define AOP_FLAG_NOFS			0x0004 /* used by filesystem to direct
+						* helper code (eg buffer layer)
+						* to clear GFP_FS from alloc */
 
 /*
  * oh the beauties of C type declarations.
@@ -2023,7 +2026,7 @@ extern int page_readlink(struct dentry *
 extern void *page_follow_link_light(struct dentry *, struct nameidata *);
 extern void page_put_link(struct dentry *, struct nameidata *, void *);
 extern int __page_symlink(struct inode *inode, const char *symname, int len,
-		gfp_t gfp_mask);
+		int nofs);
 extern int page_symlink(struct inode *inode, const char *symname, int len);
 extern const struct inode_operations page_symlink_inode_operations;
 extern int generic_readlink(struct dentry *, char __user *, int);
Index: linux-2.6/fs/ext3/namei.c
===================================================================
--- linux-2.6.orig/fs/ext3/namei.c
+++ linux-2.6/fs/ext3/namei.c
@@ -2170,8 +2170,7 @@ retry:
 		 * We have a transaction open.  All is sweetness.  It also sets
 		 * i_size in generic_commit_write().
 		 */
-		err = __page_symlink(inode, symname, l,
-				mapping_gfp_mask(inode->i_mapping) & ~__GFP_FS);
+		err = __page_symlink(inode, symname, l, 1);
 		if (err) {
 			drop_nlink(inode);
 			ext3_mark_inode_dirty(handle, inode);
Index: linux-2.6/fs/ext4/namei.c
===================================================================
--- linux-2.6.orig/fs/ext4/namei.c
+++ linux-2.6/fs/ext4/namei.c
@@ -2208,8 +2208,7 @@ retry:
 		 * We have a transaction open.  All is sweetness.  It also sets
 		 * i_size in generic_commit_write().
 		 */
-		err = __page_symlink(inode, symname, l,
-				mapping_gfp_mask(inode->i_mapping) & ~__GFP_FS);
+		err = __page_symlink(inode, symname, l, 1);
 		if (err) {
 			clear_nlink(inode);
 			ext4_mark_inode_dirty(handle, inode);
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -241,7 +241,8 @@ unsigned find_get_pages_contig(struct ad
 unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 			int tag, unsigned int nr_pages, struct page **pages);
 
-struct page *__grab_cache_page(struct address_space *mapping, pgoff_t index);
+struct page *grab_cache_page_write_begin(struct address_space *mapping,
+			pgoff_t index, int nofs);
 
 /*
  * Returns locked page at given index in given cache, creating it if needed.
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -2147,19 +2147,24 @@ EXPORT_SYMBOL(generic_file_direct_write)
  * Find or create a page at the given pagecache position. Return the locked
  * page. This function is specifically for buffered writes.
  */
-struct page *__grab_cache_page(struct address_space *mapping, pgoff_t index)
+struct page *grab_cache_page_write_begin(struct address_space *mapping,
+					pgoff_t index, int nofs)
 {
 	int status;
 	struct page *page;
+	gfp_t gfp_notmask = 0;
+	if (nofs)
+		gfp_notmask = __GFP_FS;
 repeat:
 	page = find_lock_page(mapping, index);
 	if (likely(page))
 		return page;
 
-	page = page_cache_alloc(mapping);
+	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~gfp_notmask);
 	if (!page)
 		return NULL;
-	status = add_to_page_cache_lru(page, mapping, index, GFP_KERNEL);
+	status = add_to_page_cache_lru(page, mapping, index,
+						GFP_KERNEL & ~gfp_notmask);
 	if (unlikely(status)) {
 		page_cache_release(page);
 		if (status == -EEXIST)
@@ -2168,7 +2173,7 @@ repeat:
 	}
 	return page;
 }
-EXPORT_SYMBOL(__grab_cache_page);
+EXPORT_SYMBOL(grab_cache_page_write_begin);
 
 static ssize_t generic_perform_write(struct file *file,
 				struct iov_iter *i, loff_t pos)
Index: linux-2.6/fs/affs/file.c
===================================================================
--- linux-2.6.orig/fs/affs/file.c
+++ linux-2.6/fs/affs/file.c
@@ -628,7 +628,7 @@ static int affs_write_begin_ofs(struct f
 	}
 
 	index = pos >> PAGE_CACHE_SHIFT;
-	page = __grab_cache_page(mapping, index);
+	page = grab_cache_page_write_begin(mapping, index, flags&AOP_FLAG_NOFS);
 	if (!page)
 		return -ENOMEM;
 	*pagep = page;
Index: linux-2.6/fs/afs/write.c
===================================================================
--- linux-2.6.orig/fs/afs/write.c
+++ linux-2.6/fs/afs/write.c
@@ -144,7 +144,7 @@ int afs_write_begin(struct file *file, s
 	candidate->state = AFS_WBACK_PENDING;
 	init_waitqueue_head(&candidate->waitq);
 
-	page = __grab_cache_page(mapping, index);
+	page = grab_cache_page_write_begin(mapping, index, flags&AOP_FLAG_NOFS);
 	if (!page) {
 		kfree(candidate);
 		return -ENOMEM;
Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -1988,7 +1988,8 @@ int block_write_begin(struct file *file,
 	page = *pagep;
 	if (page == NULL) {
 		ownpage = 1;
-		page = __grab_cache_page(mapping, index);
+		page = grab_cache_page_write_begin(mapping, index,
+						flags & AOP_FLAG_NOFS);
 		if (!page) {
 			status = -ENOMEM;
 			goto out;
@@ -2494,7 +2495,8 @@ int nobh_write_begin(struct file *file,
 	from = pos & (PAGE_CACHE_SIZE - 1);
 	to = from + len;
 
-	page = __grab_cache_page(mapping, index);
+	page = grab_cache_page_write_begin(mapping, index,
+					flags & AOP_FLAG_NOFS);
 	if (!page)
 		return -ENOMEM;
 	*pagep = page;
Index: linux-2.6/fs/cifs/file.c
===================================================================
--- linux-2.6.orig/fs/cifs/file.c
+++ linux-2.6/fs/cifs/file.c
@@ -2073,7 +2073,8 @@ static int cifs_write_begin(struct file
 
 	cFYI(1, ("write_begin from %lld len %d", (long long)pos, len));
 
-	page = __grab_cache_page(mapping, index);
+	page = grab_cache_page_write_begin(mapping, index,
+			flags & AOP_FLAG_NOFS);
 	if (!page) {
 		rc = -ENOMEM;
 		goto out;
Index: linux-2.6/fs/ecryptfs/mmap.c
===================================================================
--- linux-2.6.orig/fs/ecryptfs/mmap.c
+++ linux-2.6/fs/ecryptfs/mmap.c
@@ -288,7 +288,8 @@ static int ecryptfs_write_begin(struct f
 	loff_t prev_page_end_size;
 	int rc = 0;
 
-	page = __grab_cache_page(mapping, index);
+	page = grab_cache_page_write_begin(mapping, index,
+					flags & AOP_FLAG_NOFS);
 	if (!page)
 		return -ENOMEM;
 	*pagep = page;
Index: linux-2.6/fs/ext3/inode.c
===================================================================
--- linux-2.6.orig/fs/ext3/inode.c
+++ linux-2.6/fs/ext3/inode.c
@@ -1160,7 +1160,8 @@ static int ext3_write_begin(struct file
 	to = from + len;
 
 retry:
-	page = __grab_cache_page(mapping, index);
+	page = grab_cache_page_write_begin(mapping, index,
+					flags & AOP_FLAG_NOFS);
 	if (!page)
 		return -ENOMEM;
 	*pagep = page;
Index: linux-2.6/fs/ext4/inode.c
===================================================================
--- linux-2.6.orig/fs/ext4/inode.c
+++ linux-2.6/fs/ext4/inode.c
@@ -1345,7 +1345,8 @@ retry:
 		goto out;
 	}
 
-	page = __grab_cache_page(mapping, index);
+	page = grab_cache_page_write_begin(mapping, index,
+					flags & AOP_FLAG_NOFS);
 	if (!page) {
 		ext4_journal_stop(handle);
 		ret = -ENOMEM;
@@ -2549,7 +2550,8 @@ retry:
 		goto out;
 	}
 
-	page = __grab_cache_page(mapping, index);
+	page = grab_cache_page_write_begin(mapping, index,
+					flags & AOP_FLAG_NOFS);
 	if (!page) {
 		ext4_journal_stop(handle);
 		ret = -ENOMEM;
Index: linux-2.6/fs/fuse/file.c
===================================================================
--- linux-2.6.orig/fs/fuse/file.c
+++ linux-2.6/fs/fuse/file.c
@@ -646,7 +646,8 @@ static int fuse_write_begin(struct file
 {
 	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
 
-	*pagep = __grab_cache_page(mapping, index);
+	*pagep = grab_cache_page_write_begin(mapping, index,
+					flags & AOP_FLAG_NOFS);
 	if (!*pagep)
 		return -ENOMEM;
 	return 0;
Index: linux-2.6/fs/gfs2/ops_address.c
===================================================================
--- linux-2.6.orig/fs/gfs2/ops_address.c
+++ linux-2.6/fs/gfs2/ops_address.c
@@ -675,7 +675,8 @@ static int gfs2_write_begin(struct file
 		goto out_trans_fail;
 
 	error = -ENOMEM;
-	page = __grab_cache_page(mapping, index);
+	page = grab_cache_page_write_begin(mapping, index,
+					flags & AOP_FLAG_NOFS);
 	*pagep = page;
 	if (unlikely(!page))
 		goto out_endtrans;
Index: linux-2.6/fs/hostfs/hostfs_kern.c
===================================================================
--- linux-2.6.orig/fs/hostfs/hostfs_kern.c
+++ linux-2.6/fs/hostfs/hostfs_kern.c
@@ -501,7 +501,8 @@ int hostfs_write_begin(struct file *file
 {
 	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
 
-	*pagep = __grab_cache_page(mapping, index);
+	*pagep = grab_cache_page_write_begin(mapping, index,
+					flags & AOP_FLAG_NOFS);
 	if (!*pagep)
 		return -ENOMEM;
 	return 0;
Index: linux-2.6/fs/jffs2/file.c
===================================================================
--- linux-2.6.orig/fs/jffs2/file.c
+++ linux-2.6/fs/jffs2/file.c
@@ -132,7 +132,8 @@ static int jffs2_write_begin(struct file
 	uint32_t pageofs = index << PAGE_CACHE_SHIFT;
 	int ret = 0;
 
-	pg = __grab_cache_page(mapping, index);
+	pg = grab_cache_page_write_begin(mapping, index,
+					flags & AOP_FLAG_NOFS);
 	if (!pg)
 		return -ENOMEM;
 	*pagep = pg;
Index: linux-2.6/fs/libfs.c
===================================================================
--- linux-2.6.orig/fs/libfs.c
+++ linux-2.6/fs/libfs.c
@@ -360,7 +360,8 @@ int simple_write_begin(struct file *file
 	index = pos >> PAGE_CACHE_SHIFT;
 	from = pos & (PAGE_CACHE_SIZE - 1);
 
-	page = __grab_cache_page(mapping, index);
+	page = grab_cache_page_write_begin(mapping, index,
+					flags & AOP_FLAG_NOFS);
 	if (!page)
 		return -ENOMEM;
 
Index: linux-2.6/fs/nfs/file.c
===================================================================
--- linux-2.6.orig/fs/nfs/file.c
+++ linux-2.6/fs/nfs/file.c
@@ -354,7 +354,8 @@ static int nfs_write_begin(struct file *
 		file->f_path.dentry->d_name.name,
 		mapping->host->i_ino, len, (long long) pos);
 
-	page = __grab_cache_page(mapping, index);
+	page = grab_cache_page_write_begin(mapping, index,
+					flags & AOP_FLAG_NOFS);
 	if (!page)
 		return -ENOMEM;
 	*pagep = page;
Index: linux-2.6/fs/reiserfs/inode.c
===================================================================
--- linux-2.6.orig/fs/reiserfs/inode.c
+++ linux-2.6/fs/reiserfs/inode.c
@@ -2556,7 +2556,8 @@ static int reiserfs_write_begin(struct f
 	}
 
 	index = pos >> PAGE_CACHE_SHIFT;
-	page = __grab_cache_page(mapping, index);
+	page = grab_cache_page_write_begin(mapping, index,
+					flags & AOP_FLAG_NOFS);
 	if (!page)
 		return -ENOMEM;
 	*pagep = page;
Index: linux-2.6/fs/smbfs/file.c
===================================================================
--- linux-2.6.orig/fs/smbfs/file.c
+++ linux-2.6/fs/smbfs/file.c
@@ -297,7 +297,8 @@ static int smb_write_begin(struct file *
 			struct page **pagep, void **fsdata)
 {
 	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
-	*pagep = __grab_cache_page(mapping, index);
+	*pagep = grab_cache_page_write_begin(mapping, index,
+					flags & AOP_FLAG_NOFS);
 	if (!*pagep)
 		return -ENOMEM;
 	return 0;
Index: linux-2.6/fs/ubifs/file.c
===================================================================
--- linux-2.6.orig/fs/ubifs/file.c
+++ linux-2.6/fs/ubifs/file.c
@@ -247,7 +247,8 @@ static int write_begin_slow(struct addre
 	if (unlikely(err))
 		return err;
 
-	page = __grab_cache_page(mapping, index);
+	page = grab_cache_page_write_begin(mapping, index,
+					flags & AOP_FLAG_NOFS);
 	if (unlikely(!page)) {
 		ubifs_release_budget(c, &req);
 		return -ENOMEM;
@@ -438,7 +439,8 @@ static int ubifs_write_begin(struct file
 		return -EROFS;
 
 	/* Try out the fast-path part first */
-	page = __grab_cache_page(mapping, index);
+	page = grab_cache_page_write_begin(mapping, index,
+					flags & AOP_FLAG_NOFS);
 	if (unlikely(!page))
 		return -ENOMEM;
 
