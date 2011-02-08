Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4897C8D0039
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 05:30:42 -0500 (EST)
In-reply-to: <AANLkTimBR=CuMpWE2juJG2jsLsTqK=tc00sRrEjhkHg=@mail.gmail.com>
	(message from Hugh Dickins on Wed, 26 Jan 2011 20:19:15 -0800)
Subject: Re: [PATCH] mm: prevent concurrent unmap_mapping_range() on the same inode
References: <E1PftfG-0007w1-Ek@pomaz-ex.szeredi.hu>
	<20110120124043.GA4347@infradead.org>
	<E1PfvGx-00086O-IA@pomaz-ex.szeredi.hu>
	<alpine.LSU.2.00.1101212014330.4301@sister.anvils>
	<E1PhSO8-0005yN-Dp@pomaz-ex.szeredi.hu> <AANLkTimBR=CuMpWE2juJG2jsLsTqK=tc00sRrEjhkHg=@mail.gmail.com>
Message-Id: <E1Pmkpt-0006Cd-Q6@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 08 Feb 2011 11:30:17 +0100
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: miklos@szeredi.hu, hch@infradead.org, akpm@linux-foundation.org, gurudas.pai@oracle.com, lkml20101129@newton.leun.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 26 Jan 2011, Hugh Dickins wrote:
> I had wanted to propose that for now you modify just fuse to use
> i_alloc_sem for serialization there, and I provide a patch to
> unmap_mapping_range() to give safety to whatever other cases there are
> (I'm now sure there are other cases, but also sure that I cannot
> safely identify them all and fix them correctly at source myself -
> even if I found time to do the patches, they'd need at least a release
> cycle to bed in with BUG_ONs).

Since fuse is the only one where the BUG has actually been triggered,
and since there are problems with all the proposed generic approaches,
I concur.  I didn't want to use i_alloc_sem here as it's more
confusing than a new mutex.

Gurudas, could you please give this patch a go in your testcase?

Thanks,
Miklos
---

From: Miklos Szeredi <mszeredi@suse.cz>
Subject: fuse: prevent concurrent unmap on the same inode

Running a fuse filesystem with multiple open()'s in parallel can
trigger a "kernel BUG at mm/truncate.c:475"

The reason is, unmap_mapping_range() is not prepared for more than
one concurrent invocation per inode.

Truncate and hole punching already serialize with i_mutex.  Other
callers of unmap_mapping_range() do not, and it's difficult to get
i_mutex protection for all callers.  In particular ->d_revalidate(),
which calls invalidate_inode_pages2_range() in fuse, may be called
with or without i_mutex.

This patch adds a new mutex to fuse_inode to prevent running multiple
concurrent unmap_mapping_range() on the same mapping.

Reported-by: Michael Leun <lkml20101129@newton.leun.net>
Cc: Hugh Dickins <hughd@google.com>
Cc: Gurudas Pai <gurudas.pai@oracle.com>
Cc: stable@kernel.org
Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 fs/fuse/dir.c    |    8 +++-----
 fs/fuse/file.c   |   10 +++++++++-
 fs/fuse/fuse_i.h |    3 +++
 fs/fuse/inode.c  |    6 ++++++
 4 files changed, 21 insertions(+), 6 deletions(-)

Index: linux-2.6/fs/fuse/dir.c
===================================================================
--- linux-2.6.orig/fs/fuse/dir.c	2011-02-07 17:52:34.000000000 +0100
+++ linux-2.6/fs/fuse/dir.c	2011-02-07 17:52:35.000000000 +0100
@@ -1255,16 +1255,12 @@ void fuse_release_nowrite(struct inode *
 
 /*
  * Set attributes, and at the same time refresh them.
- *
- * Truncation is slightly complicated, because the 'truncate' request
- * may fail, in which case we don't want to touch the mapping.
- * vmtruncate() doesn't allow for this case, so do the rlimit checking
- * and the actual truncation by hand.
  */
 static int fuse_do_setattr(struct dentry *entry, struct iattr *attr,
 			   struct file *file)
 {
 	struct inode *inode = entry->d_inode;
+	struct fuse_inode *fi = get_fuse_inode(inode);
 	struct fuse_conn *fc = get_fuse_conn(inode);
 	struct fuse_req *req;
 	struct fuse_setattr_in inarg;
@@ -1352,8 +1348,10 @@ static int fuse_do_setattr(struct dentry
 	 * FUSE_NOWRITE, otherwise fuse_launder_page() would deadlock.
 	 */
 	if (S_ISREG(inode->i_mode) && oldsize != outarg.attr.size) {
+		mutex_lock(&fi->unmap_mutex);
 		truncate_pagecache(inode, oldsize, outarg.attr.size);
 		invalidate_inode_pages2(inode->i_mapping);
+		mutex_unlock(&fi->unmap_mutex);
 	}
 
 	return 0;
Index: linux-2.6/fs/fuse/file.c
===================================================================
--- linux-2.6.orig/fs/fuse/file.c	2011-02-07 17:52:34.000000000 +0100
+++ linux-2.6/fs/fuse/file.c	2011-02-07 17:52:35.000000000 +0100
@@ -170,11 +170,15 @@ void fuse_finish_open(struct inode *inod
 {
 	struct fuse_file *ff = file->private_data;
 	struct fuse_conn *fc = get_fuse_conn(inode);
+	struct fuse_inode *fi = get_fuse_inode(inode);
 
 	if (ff->open_flags & FOPEN_DIRECT_IO)
 		file->f_op = &fuse_direct_io_file_operations;
-	if (!(ff->open_flags & FOPEN_KEEP_CACHE))
+	if (!(ff->open_flags & FOPEN_KEEP_CACHE)) {
+		mutex_lock(&fi->unmap_mutex);
 		invalidate_inode_pages2(inode->i_mapping);
+		mutex_unlock(&fi->unmap_mutex);
+	}
 	if (ff->open_flags & FOPEN_NONSEEKABLE)
 		nonseekable_open(inode, file);
 	if (fc->atomic_o_trunc && (file->f_flags & O_TRUNC)) {
@@ -1403,11 +1407,15 @@ static int fuse_file_mmap(struct file *f
 
 static int fuse_direct_mmap(struct file *file, struct vm_area_struct *vma)
 {
+	struct fuse_inode *fi = get_fuse_inode(file->f_mapping->host);
+
 	/* Can't provide the coherency needed for MAP_SHARED */
 	if (vma->vm_flags & VM_MAYSHARE)
 		return -ENODEV;
 
+	mutex_lock(&fi->unmap_mutex);
 	invalidate_inode_pages2(file->f_mapping);
+	mutex_unlock(&fi->unmap_mutex);
 
 	return generic_file_mmap(file, vma);
 }
Index: linux-2.6/fs/fuse/fuse_i.h
===================================================================
--- linux-2.6.orig/fs/fuse/fuse_i.h	2011-02-07 17:52:34.000000000 +0100
+++ linux-2.6/fs/fuse/fuse_i.h	2011-02-07 17:52:35.000000000 +0100
@@ -100,6 +100,9 @@ struct fuse_inode {
 
 	/** List of writepage requestst (pending or sent) */
 	struct list_head writepages;
+
+	/** to protect unmapping */
+	struct mutex unmap_mutex;
 };
 
 struct fuse_conn;
Index: linux-2.6/fs/fuse/inode.c
===================================================================
--- linux-2.6.orig/fs/fuse/inode.c	2011-02-07 17:52:34.000000000 +0100
+++ linux-2.6/fs/fuse/inode.c	2011-02-07 17:54:03.000000000 +0100
@@ -95,6 +95,7 @@ static struct inode *fuse_alloc_inode(st
 	INIT_LIST_HEAD(&fi->queued_writes);
 	INIT_LIST_HEAD(&fi->writepages);
 	init_waitqueue_head(&fi->page_waitq);
+	mutex_init(&fi->unmap_mutex);
 	fi->forget = fuse_alloc_forget();
 	if (!fi->forget) {
 		kmem_cache_free(fuse_inode_cachep, inode);
@@ -197,8 +198,10 @@ void fuse_change_attributes(struct inode
 	spin_unlock(&fc->lock);
 
 	if (S_ISREG(inode->i_mode) && oldsize != attr->size) {
+		mutex_lock(&fi->unmap_mutex);
 		truncate_pagecache(inode, oldsize, attr->size);
 		invalidate_inode_pages2(inode->i_mapping);
+		mutex_unlock(&fi->unmap_mutex);
 	}
 }
 
@@ -286,13 +289,16 @@ int fuse_reverse_inval_inode(struct supe
 
 	fuse_invalidate_attr(inode);
 	if (offset >= 0) {
+		struct fuse_inode *fi = get_fuse_inode(inode);
 		pg_start = offset >> PAGE_CACHE_SHIFT;
 		if (len <= 0)
 			pg_end = -1;
 		else
 			pg_end = (offset + len - 1) >> PAGE_CACHE_SHIFT;
+		mutex_lock(&fi->unmap_mutex);
 		invalidate_inode_pages2_range(inode->i_mapping,
 					      pg_start, pg_end);
+		mutex_unlock(&fi->unmap_mutex);
 	}
 	iput(inode);
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
