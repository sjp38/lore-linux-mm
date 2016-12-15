Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D35F76B0069
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 15:51:01 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q10so133532666pgq.7
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 12:51:01 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id u10si4055448plu.297.2016.12.15.12.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 12:51:00 -0800 (PST)
Subject: [PATCH v3 1/3] dax: masking off __GFP_FS in fs DAX handlers
From: Dave Jiang <dave.jiang@intel.com>
Date: Thu, 15 Dec 2016 13:50:59 -0700
Message-ID: <148183505925.96369.9987658623875784437.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: jack@suse.cz, linux-nvdimm@lists.01.org, david@fromorbit.com, hch@lst.de, linux-mm@kvack.org, tytso@mit.edu, ross.zwisler@linux.intel.com, dan.j.williams@intel.com

The caller into dax needs to clear __GFP_FS mask bit since it's
responsible for acquiring locks / transactions that blocks __GFP_FS
allocation.  The caller will restore the original mask when dax function
returns.

Signed-off-by: Dave Jiang <dave.jiang@intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c          |    1 +
 fs/ext2/file.c    |    9 ++++++++-
 fs/ext4/file.c    |   10 +++++++++-
 fs/xfs/xfs_file.c |   14 +++++++++++++-
 4 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index d3fe880..6395bc6 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1380,6 +1380,7 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	vmf.pgoff = pgoff;
 	vmf.flags = flags;
 	vmf.gfp_mask = mapping_gfp_mask(mapping) | __GFP_IO;
+	vmf.gfp_mask &= ~__GFP_FS;
 
 	switch (iomap.type) {
 	case IOMAP_MAPPED:
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index b0f2415..8422d5f 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -92,16 +92,19 @@ static int ext2_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct inode *inode = file_inode(vma->vm_file);
 	struct ext2_inode_info *ei = EXT2_I(inode);
 	int ret;
+	gfp_t old_gfp = vmf->gfp_mask;
 
 	if (vmf->flags & FAULT_FLAG_WRITE) {
 		sb_start_pagefault(inode->i_sb);
 		file_update_time(vma->vm_file);
 	}
+	vmf->gfp_mask &= ~__GFP_FS;
 	down_read(&ei->dax_sem);
 
 	ret = dax_iomap_fault(vma, vmf, &ext2_iomap_ops);
 
 	up_read(&ei->dax_sem);
+	vmf->gfp_mask = old_gfp;
 	if (vmf->flags & FAULT_FLAG_WRITE)
 		sb_end_pagefault(inode->i_sb);
 	return ret;
@@ -114,6 +117,7 @@ static int ext2_dax_pfn_mkwrite(struct vm_area_struct *vma,
 	struct ext2_inode_info *ei = EXT2_I(inode);
 	loff_t size;
 	int ret;
+	gfp_t old_gfp = vmf->gfp_mask;
 
 	sb_start_pagefault(inode->i_sb);
 	file_update_time(vma->vm_file);
@@ -123,8 +127,11 @@ static int ext2_dax_pfn_mkwrite(struct vm_area_struct *vma,
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (vmf->pgoff >= size)
 		ret = VM_FAULT_SIGBUS;
-	else
+	else {
+		vmf->gfp_mask &= ~__GFP_FS;
 		ret = dax_pfn_mkwrite(vma, vmf);
+		vmf->gfp_mask = old_gfp;
+	}
 
 	up_read(&ei->dax_sem);
 	sb_end_pagefault(inode->i_sb);
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index d663d3d..a3f2bf0 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -261,14 +261,17 @@ static int ext4_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct inode *inode = file_inode(vma->vm_file);
 	struct super_block *sb = inode->i_sb;
 	bool write = vmf->flags & FAULT_FLAG_WRITE;
+	gfp_t old_gfp = vmf->gfp_mask;
 
 	if (write) {
 		sb_start_pagefault(sb);
 		file_update_time(vma->vm_file);
 	}
+	vmf->gfp_mask &= ~__GFP_FS;
 	down_read(&EXT4_I(inode)->i_mmap_sem);
 	result = dax_iomap_fault(vma, vmf, &ext4_iomap_ops);
 	up_read(&EXT4_I(inode)->i_mmap_sem);
+	vmf->gfp_mask = old_gfp;
 	if (write)
 		sb_end_pagefault(sb);
 
@@ -320,8 +323,13 @@ static int ext4_dax_pfn_mkwrite(struct vm_area_struct *vma,
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (vmf->pgoff >= size)
 		ret = VM_FAULT_SIGBUS;
-	else
+	else {
+		gfp_t old_gfp = vmf->gfp_mask;
+
+		vmf->gfp_mask &= ~__GFP_FS;
 		ret = dax_pfn_mkwrite(vma, vmf);
+		vmf->gfp_mask = old_gfp;
+	}
 	up_read(&EXT4_I(inode)->i_mmap_sem);
 	sb_end_pagefault(sb);
 
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index d818c16..52202b4 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1474,7 +1474,11 @@ xfs_filemap_page_mkwrite(
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 
 	if (IS_DAX(inode)) {
+		gfp_t old_gfp = vmf->gfp_mask;
+
+		vmf->gfp_mask &= ~__GFP_FS;
 		ret = dax_iomap_fault(vma, vmf, &xfs_iomap_ops);
+		vmf->gfp_mask = old_gfp;
 	} else {
 		ret = iomap_page_mkwrite(vma, vmf, &xfs_iomap_ops);
 		ret = block_page_mkwrite_return(ret);
@@ -1502,13 +1506,16 @@ xfs_filemap_fault(
 
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 	if (IS_DAX(inode)) {
+		gfp_t old_gfp = vmf->gfp_mask;
 		/*
 		 * we do not want to trigger unwritten extent conversion on read
 		 * faults - that is unnecessary overhead and would also require
 		 * changes to xfs_get_blocks_direct() to map unwritten extent
 		 * ioend for conversion on read-only mappings.
 		 */
+		vmf->gfp_mask &= ~__GFP_FS;
 		ret = dax_iomap_fault(vma, vmf, &xfs_iomap_ops);
+		vmf->gfp_mask = old_gfp;
 	} else
 		ret = filemap_fault(vma, vmf);
 	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
@@ -1581,8 +1588,13 @@ xfs_filemap_pfn_mkwrite(
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (vmf->pgoff >= size)
 		ret = VM_FAULT_SIGBUS;
-	else if (IS_DAX(inode))
+	else if (IS_DAX(inode)) {
+		gfp_t old_gfp = vmf->gfp_mask;
+
+		vmf->gfp_mask &= ~__GFP_FS;
 		ret = dax_pfn_mkwrite(vma, vmf);
+		vmf->gfp_mask = old_gfp;
+	}
 	xfs_iunlock(ip, XFS_MMAPLOCK_SHARED);
 	sb_end_pagefault(inode->i_sb);
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
