Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 48B90280251
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 18:50:38 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ry6so57661455pac.1
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 15:50:38 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m6si9442179pab.331.2016.10.12.15.50.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 15:50:37 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v6 10/17] dax: correct dax iomap code namespace
Date: Wed, 12 Oct 2016 16:50:15 -0600
Message-Id: <20161012225022.15507-11-ross.zwisler@linux.intel.com>
In-Reply-To: <20161012225022.15507-1-ross.zwisler@linux.intel.com>
References: <20161012225022.15507-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

The recently added DAX functions that use the new struct iomap data
structure were named iomap_dax_rw(), iomap_dax_fault() and
iomap_dax_actor().  These are actually defined in fs/dax.c, though, so
should be part of the "dax" namespace and not the "iomap" namespace.
Rename them to dax_iomap_rw(), dax_iomap_fault() and dax_iomap_actor()
respectively.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Suggested-by: Dave Chinner <david@fromorbit.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c            | 16 ++++++++--------
 fs/ext2/file.c      |  6 +++---
 fs/xfs/xfs_file.c   |  8 ++++----
 include/linux/dax.h |  4 ++--
 4 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 3d0b103..fdbd7a1 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1031,7 +1031,7 @@ EXPORT_SYMBOL_GPL(dax_truncate_page);
 
 #ifdef CONFIG_FS_IOMAP
 static loff_t
-iomap_dax_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
+dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 		struct iomap *iomap)
 {
 	struct iov_iter *iter = data;
@@ -1088,7 +1088,7 @@ iomap_dax_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 }
 
 /**
- * iomap_dax_rw - Perform I/O to a DAX file
+ * dax_iomap_rw - Perform I/O to a DAX file
  * @iocb:	The control block for this I/O
  * @iter:	The addresses to do I/O from or to
  * @ops:	iomap ops passed from the file system
@@ -1098,7 +1098,7 @@ iomap_dax_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
  * and evicting any page cache pages in the region under I/O.
  */
 ssize_t
-iomap_dax_rw(struct kiocb *iocb, struct iov_iter *iter,
+dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
 		struct iomap_ops *ops)
 {
 	struct address_space *mapping = iocb->ki_filp->f_mapping;
@@ -1128,7 +1128,7 @@ iomap_dax_rw(struct kiocb *iocb, struct iov_iter *iter,
 
 	while (iov_iter_count(iter)) {
 		ret = iomap_apply(inode, pos, iov_iter_count(iter), flags, ops,
-				iter, iomap_dax_actor);
+				iter, dax_iomap_actor);
 		if (ret <= 0)
 			break;
 		pos += ret;
@@ -1138,10 +1138,10 @@ iomap_dax_rw(struct kiocb *iocb, struct iov_iter *iter,
 	iocb->ki_pos += done;
 	return done ? done : ret;
 }
-EXPORT_SYMBOL_GPL(iomap_dax_rw);
+EXPORT_SYMBOL_GPL(dax_iomap_rw);
 
 /**
- * iomap_dax_fault - handle a page fault on a DAX file
+ * dax_iomap_fault - handle a page fault on a DAX file
  * @vma: The virtual memory area where the fault occurred
  * @vmf: The description of the fault
  * @ops: iomap ops passed from the file system
@@ -1150,7 +1150,7 @@ EXPORT_SYMBOL_GPL(iomap_dax_rw);
  * or mkwrite handler for DAX files. Assumes the caller has done all the
  * necessary locking for the page fault to proceed successfully.
  */
-int iomap_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
+int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 			struct iomap_ops *ops)
 {
 	struct address_space *mapping = vma->vm_file->f_mapping;
@@ -1252,5 +1252,5 @@ int iomap_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		return VM_FAULT_SIGBUS | major;
 	return VM_FAULT_NOPAGE | major;
 }
-EXPORT_SYMBOL_GPL(iomap_dax_fault);
+EXPORT_SYMBOL_GPL(dax_iomap_fault);
 #endif /* CONFIG_FS_IOMAP */
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index 0f257f8..32a4913 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -38,7 +38,7 @@ static ssize_t ext2_dax_read_iter(struct kiocb *iocb, struct iov_iter *to)
 		return 0; /* skip atime */
 
 	inode_lock_shared(inode);
-	ret = iomap_dax_rw(iocb, to, &ext2_iomap_ops);
+	ret = dax_iomap_rw(iocb, to, &ext2_iomap_ops);
 	inode_unlock_shared(inode);
 
 	file_accessed(iocb->ki_filp);
@@ -62,7 +62,7 @@ static ssize_t ext2_dax_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	if (ret)
 		goto out_unlock;
 
-	ret = iomap_dax_rw(iocb, from, &ext2_iomap_ops);
+	ret = dax_iomap_rw(iocb, from, &ext2_iomap_ops);
 	if (ret > 0 && iocb->ki_pos > i_size_read(inode)) {
 		i_size_write(inode, iocb->ki_pos);
 		mark_inode_dirty(inode);
@@ -99,7 +99,7 @@ static int ext2_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	}
 	down_read(&ei->dax_sem);
 
-	ret = iomap_dax_fault(vma, vmf, &ext2_iomap_ops);
+	ret = dax_iomap_fault(vma, vmf, &ext2_iomap_ops);
 
 	up_read(&ei->dax_sem);
 	if (vmf->flags & FAULT_FLAG_WRITE)
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index de7c53c..8f12152 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -344,7 +344,7 @@ xfs_file_dax_read(
 		return 0; /* skip atime */
 
 	xfs_rw_ilock(ip, XFS_IOLOCK_SHARED);
-	ret = iomap_dax_rw(iocb, to, &xfs_iomap_ops);
+	ret = dax_iomap_rw(iocb, to, &xfs_iomap_ops);
 	xfs_rw_iunlock(ip, XFS_IOLOCK_SHARED);
 
 	file_accessed(iocb->ki_filp);
@@ -730,7 +730,7 @@ xfs_file_dax_write(
 
 	trace_xfs_file_dax_write(ip, count, pos);
 
-	ret = iomap_dax_rw(iocb, from, &xfs_iomap_ops);
+	ret = dax_iomap_rw(iocb, from, &xfs_iomap_ops);
 	if (ret > 0 && iocb->ki_pos > i_size_read(inode)) {
 		i_size_write(inode, iocb->ki_pos);
 		error = xfs_setfilesize(ip, pos, ret);
@@ -1679,7 +1679,7 @@ xfs_filemap_page_mkwrite(
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 
 	if (IS_DAX(inode)) {
-		ret = iomap_dax_fault(vma, vmf, &xfs_iomap_ops);
+		ret = dax_iomap_fault(vma, vmf, &xfs_iomap_ops);
 	} else {
 		ret = iomap_page_mkwrite(vma, vmf, &xfs_iomap_ops);
 		ret = block_page_mkwrite_return(ret);
@@ -1713,7 +1713,7 @@ xfs_filemap_fault(
 		 * changes to xfs_get_blocks_direct() to map unwritten extent
 		 * ioend for conversion on read-only mappings.
 		 */
-		ret = iomap_dax_fault(vma, vmf, &xfs_iomap_ops);
+		ret = dax_iomap_fault(vma, vmf, &xfs_iomap_ops);
 	} else
 		ret = filemap_fault(vma, vmf);
 	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 0f74866..a3dfee4 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -11,13 +11,13 @@ struct iomap_ops;
 /* We use lowest available exceptional entry bit for locking */
 #define RADIX_DAX_ENTRY_LOCK (1 << RADIX_TREE_EXCEPTIONAL_SHIFT)
 
-ssize_t iomap_dax_rw(struct kiocb *iocb, struct iov_iter *iter,
+ssize_t dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
 		struct iomap_ops *ops);
 ssize_t dax_do_io(struct kiocb *, struct inode *, struct iov_iter *,
 		  get_block_t, dio_iodone_t, int flags);
 int dax_zero_page_range(struct inode *, loff_t from, unsigned len, get_block_t);
 int dax_truncate_page(struct inode *, loff_t from, get_block_t);
-int iomap_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
+int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 			struct iomap_ops *ops);
 int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
 int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index);
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
