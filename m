Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 18F7A6B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 10:44:52 -0400 (EDT)
Date: Tue, 7 Jul 2009 16:46:00 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 2/4] fs: use new truncate helpers
Message-ID: <20090707144600.GD2714@wotan.suse.de>
References: <20090707144423.GC2714@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090707144423.GC2714@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Update some fs code to make use of new helper functions introduced
in the previous patch. Should be no significant change in behaviour
(except CIFS now calls send_sig under i_lock, via inode_newsize_ok).

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 fs/buffer.c           |   10 +--------
 fs/cifs/inode.c       |   51 ++++++++-----------------------------------------
 fs/fuse/dir.c         |   14 +++----------
 fs/fuse/fuse_i.h      |    2 -
 fs/fuse/inode.c       |   11 ----------
 fs/nfs/inode.c        |   52 +++++++++++---------------------------------------
 fs/ramfs/file-nommu.c |   18 ++++-------------
 7 files changed, 33 insertions(+), 125 deletions(-)

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -2225,16 +2225,10 @@ int generic_cont_expand_simple(struct in
 	struct address_space *mapping = inode->i_mapping;
 	struct page *page;
 	void *fsdata;
-	unsigned long limit;
 	int err;
 
-	err = -EFBIG;
-        limit = current->signal->rlim[RLIMIT_FSIZE].rlim_cur;
-	if (limit != RLIM_INFINITY && size > (loff_t)limit) {
-		send_sig(SIGXFSZ, current, 0);
-		goto out;
-	}
-	if (size > inode->i_sb->s_maxbytes)
+	err = inode_newsize_ok(inode, size);
+	if (err)
 		goto out;
 
 	err = pagecache_write_begin(NULL, mapping, size, 0,
Index: linux-2.6/fs/cifs/inode.c
===================================================================
--- linux-2.6.orig/fs/cifs/inode.c
+++ linux-2.6/fs/cifs/inode.c
@@ -1645,57 +1645,24 @@ static int cifs_truncate_page(struct add
 
 static int cifs_vmtruncate(struct inode *inode, loff_t offset)
 {
-	struct address_space *mapping = inode->i_mapping;
-	unsigned long limit;
+	loff_t oldsize;
+	int err;
 
 	spin_lock(&inode->i_lock);
-	if (inode->i_size < offset)
-		goto do_expand;
-	/*
-	 * truncation of in-use swapfiles is disallowed - it would cause
-	 * subsequent swapout to scribble on the now-freed blocks.
-	 */
-	if (IS_SWAPFILE(inode)) {
+	err = inode_newsize_ok(inode, offset);
+	if (err) {
 		spin_unlock(&inode->i_lock);
-		goto out_busy;
+		goto out;
 	}
-	i_size_write(inode, offset);
-	spin_unlock(&inode->i_lock);
-	/*
-	 * unmap_mapping_range is called twice, first simply for efficiency
-	 * so that truncate_inode_pages does fewer single-page unmaps. However
-	 * after this first call, and before truncate_inode_pages finishes,
-	 * it is possible for private pages to be COWed, which remain after
-	 * truncate_inode_pages finishes, hence the second unmap_mapping_range
-	 * call must be made for correctness.
-	 */
-	unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
-	truncate_inode_pages(mapping, offset);
-	unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
-	goto out_truncate;
 
-do_expand:
-	limit = current->signal->rlim[RLIMIT_FSIZE].rlim_cur;
-	if (limit != RLIM_INFINITY && offset > limit) {
-		spin_unlock(&inode->i_lock);
-		goto out_sig;
-	}
-	if (offset > inode->i_sb->s_maxbytes) {
-		spin_unlock(&inode->i_lock);
-		goto out_big;
-	}
+	oldsize = inode->i_size;
 	i_size_write(inode, offset);
 	spin_unlock(&inode->i_lock);
-out_truncate:
+	truncate_pagecache(inode, oldsize, offset);
 	if (inode->i_op->truncate)
 		inode->i_op->truncate(inode);
-	return 0;
-out_sig:
-	send_sig(SIGXFSZ, current, 0);
-out_big:
-	return -EFBIG;
-out_busy:
-	return -ETXTBSY;
+out:
+	return err;
 }
 
 static int
Index: linux-2.6/fs/fuse/dir.c
===================================================================
--- linux-2.6.orig/fs/fuse/dir.c
+++ linux-2.6/fs/fuse/dir.c
@@ -1225,14 +1225,9 @@ static int fuse_do_setattr(struct dentry
 		return 0;
 
 	if (attr->ia_valid & ATTR_SIZE) {
-		unsigned long limit;
-		if (IS_SWAPFILE(inode))
-			return -ETXTBSY;
-		limit = current->signal->rlim[RLIMIT_FSIZE].rlim_cur;
-		if (limit != RLIM_INFINITY && attr->ia_size > (loff_t) limit) {
-			send_sig(SIGXFSZ, current, 0);
-			return -EFBIG;
-		}
+		err = inode_newsize_ok(inode, attr->ia_size);
+		if (err)
+			return err;
 		is_truncate = true;
 	}
 
@@ -1299,8 +1294,7 @@ static int fuse_do_setattr(struct dentry
 	 * FUSE_NOWRITE, otherwise fuse_launder_page() would deadlock.
 	 */
 	if (S_ISREG(inode->i_mode) && oldsize != outarg.attr.size) {
-		if (outarg.attr.size < oldsize)
-			fuse_truncate(inode->i_mapping, outarg.attr.size);
+		truncate_pagecache(inode, oldsize, outarg.attr.size);
 		invalidate_inode_pages2(inode->i_mapping);
 	}
 
Index: linux-2.6/fs/nfs/inode.c
===================================================================
--- linux-2.6.orig/fs/nfs/inode.c
+++ linux-2.6/fs/nfs/inode.c
@@ -427,49 +427,21 @@ nfs_setattr(struct dentry *dentry, struc
  */
 static int nfs_vmtruncate(struct inode * inode, loff_t offset)
 {
-	if (i_size_read(inode) < offset) {
-		unsigned long limit;
+	loff_t oldsize;
+	int err;
 
-		limit = current->signal->rlim[RLIMIT_FSIZE].rlim_cur;
-		if (limit != RLIM_INFINITY && offset > limit)
-			goto out_sig;
-		if (offset > inode->i_sb->s_maxbytes)
-			goto out_big;
-		spin_lock(&inode->i_lock);
-		i_size_write(inode, offset);
-		spin_unlock(&inode->i_lock);
-	} else {
-		struct address_space *mapping = inode->i_mapping;
+	err = inode_newsize_ok(inode, offset);
+	if (err)
+		goto out;
 
-		/*
-		 * truncation of in-use swapfiles is disallowed - it would
-		 * cause subsequent swapout to scribble on the now-freed
-		 * blocks.
-		 */
-		if (IS_SWAPFILE(inode))
-			return -ETXTBSY;
-		spin_lock(&inode->i_lock);
-		i_size_write(inode, offset);
-		spin_unlock(&inode->i_lock);
+	spin_lock(&inode->i_lock);
+	oldsize = inode->i_size;
+	i_size_write(inode, offset);
+	spin_unlock(&inode->i_lock);
 
-		/*
-		 * unmap_mapping_range is called twice, first simply for
-		 * efficiency so that truncate_inode_pages does fewer
-		 * single-page unmaps.  However after this first call, and
-		 * before truncate_inode_pages finishes, it is possible for
-		 * private pages to be COWed, which remain after
-		 * truncate_inode_pages finishes, hence the second
-		 * unmap_mapping_range call must be made for correctness.
-		 */
-		unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
-		truncate_inode_pages(mapping, offset);
-		unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
-	}
-	return 0;
-out_sig:
-	send_sig(SIGXFSZ, current, 0);
-out_big:
-	return -EFBIG;
+	truncate_pagecache(inode, oldsize, offset);
+out:
+	return err;
 }
 
 /**
Index: linux-2.6/fs/ramfs/file-nommu.c
===================================================================
--- linux-2.6.orig/fs/ramfs/file-nommu.c
+++ linux-2.6/fs/ramfs/file-nommu.c
@@ -68,14 +68,11 @@ int ramfs_nommu_expand_for_mapping(struc
 	/* make various checks */
 	order = get_order(newsize);
 	if (unlikely(order >= MAX_ORDER))
-		goto too_big;
+		return -EFBIG;
 
-	limit = current->signal->rlim[RLIMIT_FSIZE].rlim_cur;
-	if (limit != RLIM_INFINITY && newsize > limit)
-		goto fsize_exceeded;
-
-	if (newsize > inode->i_sb->s_maxbytes)
-		goto too_big;
+	ret = inode_newsize_ok(inode, newsize);
+	if (ret)
+		return ret;
 
 	i_size_write(inode, newsize);
 
@@ -117,12 +114,7 @@ int ramfs_nommu_expand_for_mapping(struc
 
 	return 0;
 
- fsize_exceeded:
-	send_sig(SIGXFSZ, current, 0);
- too_big:
-	return -EFBIG;
-
- add_error:
+add_error:
 	while (loop < npages)
 		__free_page(pages + loop++);
 	return ret;
Index: linux-2.6/fs/fuse/fuse_i.h
===================================================================
--- linux-2.6.orig/fs/fuse/fuse_i.h
+++ linux-2.6/fs/fuse/fuse_i.h
@@ -588,8 +588,6 @@ void fuse_change_attributes(struct inode
 void fuse_change_attributes_common(struct inode *inode, struct fuse_attr *attr,
 				   u64 attr_valid);
 
-void fuse_truncate(struct address_space *mapping, loff_t offset);
-
 /**
  * Initialize the client device
  */
Index: linux-2.6/fs/fuse/inode.c
===================================================================
--- linux-2.6.orig/fs/fuse/inode.c
+++ linux-2.6/fs/fuse/inode.c
@@ -115,14 +115,6 @@ static int fuse_remount_fs(struct super_
 	return 0;
 }
 
-void fuse_truncate(struct address_space *mapping, loff_t offset)
-{
-	/* See vmtruncate() */
-	unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
-	truncate_inode_pages(mapping, offset);
-	unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
-}
-
 void fuse_change_attributes_common(struct inode *inode, struct fuse_attr *attr,
 				   u64 attr_valid)
 {
@@ -180,8 +172,7 @@ void fuse_change_attributes(struct inode
 	spin_unlock(&fc->lock);
 
 	if (S_ISREG(inode->i_mode) && oldsize != attr->size) {
-		if (attr->size < oldsize)
-			fuse_truncate(inode->i_mapping, attr->size);
+		truncate_pagecache(inode, oldsize, attr->size);
 		invalidate_inode_pages2(inode->i_mapping);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
