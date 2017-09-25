Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB6686B0261
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 19:14:32 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q75so15487952pfl.1
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 16:14:32 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id u6si4611766pfh.458.2017.09.25.16.14.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 16:14:31 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH 6/7] mm, fs: introduce file_operations->post_mmap()
Date: Mon, 25 Sep 2017 17:14:03 -0600
Message-Id: <20170925231404.32723-7-ross.zwisler@linux.intel.com>
In-Reply-To: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

When mappings are created the vma->vm_flags that they use vary based on
whether the inode being mapped is using DAX or not.  This setup happens in
XFS via mmap_region()=>call_mmap()=>xfs_file_mmap().

For us to be able to safely use the DAX per-inode flag we need to prevent
S_DAX transitions when any mappings are present, and we will do that by
looking at the address_space->i_mmap tree and returning -EBUSY if any
mappings are present.

Unfortunately at the time that the filesystem's file_operations->mmap()
entry point is called the mapping has not yet been added to the
address_space->i_mmap tree.  This means that at that point in time we
cannot determine whether or not the mapping will be set up to support DAX.

Fix this by adding a new file_operations entry called post_mmap() which is
called after the mapping has been added to the address_space->i_mmap tree.
This post_mmap() op now happens at a time when we can be sure whether the
mapping will use DAX or not, and we can set up the vma->vm_flags
appropriately.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/xfs/xfs_file.c  | 15 ++++++++++++++-
 include/linux/fs.h |  1 +
 mm/mmap.c          |  2 ++
 3 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 2816858..9d66aaa 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1087,9 +1087,21 @@ xfs_file_mmap(
 {
 	file_accessed(filp);
 	vma->vm_ops = &xfs_file_vm_ops;
+	return 0;
+}
+
+/* This call happens during mmap(), after the vma has been inserted into the
+ * inode->i_mapping->i_mmap tree.  At this point the decision on whether or
+ * not to use DAX for this mapping has been set and will not change for the
+ * duration of the mapping.
+ */
+STATIC void
+xfs_file_post_mmap(
+	struct file	*filp,
+	struct vm_area_struct *vma)
+{
 	if (IS_DAX(file_inode(filp)))
 		vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
-	return 0;
 }
 
 const struct file_operations xfs_file_operations = {
@@ -1103,6 +1115,7 @@ const struct file_operations xfs_file_operations = {
 	.compat_ioctl	= xfs_file_compat_ioctl,
 #endif
 	.mmap		= xfs_file_mmap,
+	.post_mmap	= xfs_file_post_mmap,
 	.open		= xfs_file_open,
 	.release	= xfs_file_release,
 	.fsync		= xfs_file_fsync,
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 339e737..7c06838 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1701,6 +1701,7 @@ struct file_operations {
 	long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
 	long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
 	int (*mmap) (struct file *, struct vm_area_struct *);
+	void (*post_mmap) (struct file *, struct vm_area_struct *);
 	int (*open) (struct inode *, struct file *);
 	int (*flush) (struct file *, fl_owner_t id);
 	int (*release) (struct inode *, struct file *);
diff --git a/mm/mmap.c b/mm/mmap.c
index 680506f..ee7458a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1711,6 +1711,8 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	vma_link(mm, vma, prev, rb_link, rb_parent);
 	/* Once vma denies write, undo our temporary denial count */
 	if (file) {
+		if (file->f_op->post_mmap)
+			file->f_op->post_mmap(file, vma);
 		if (vm_flags & VM_SHARED)
 			mapping_unmap_writable(file->f_mapping);
 		if (vm_flags & VM_DENYWRITE)
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
