Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 78E4F6B026E
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 11:25:47 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o44so11949958wrf.0
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 08:25:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 139si353479wmu.267.2017.10.24.08.25.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 08:25:29 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 10/17] dax: Allow dax_iomap_fault() to return pfn
Date: Tue, 24 Oct 2017 17:24:07 +0200
Message-Id: <20171024152415.22864-11-jack@suse.cz>
In-Reply-To: <20171024152415.22864-1-jack@suse.cz>
References: <20171024152415.22864-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

For synchronous page fault dax_iomap_fault() will need to return PFN
which will then need to be inserted into page tables after fsync()
completes. Add necessary parameter to dax_iomap_fault().

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c            | 13 +++++++------
 fs/ext2/file.c      |  2 +-
 fs/ext4/file.c      |  2 +-
 fs/xfs/xfs_file.c   |  4 ++--
 include/linux/dax.h |  2 +-
 5 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 5214ed9ba508..5ddf15161390 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1079,7 +1079,7 @@ static int dax_fault_return(int error)
 	return VM_FAULT_SIGBUS;
 }
 
-static int dax_iomap_pte_fault(struct vm_fault *vmf,
+static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 			       const struct iomap_ops *ops)
 {
 	struct vm_area_struct *vma = vmf->vma;
@@ -1280,7 +1280,7 @@ static int dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
 	return VM_FAULT_FALLBACK;
 }
 
-static int dax_iomap_pmd_fault(struct vm_fault *vmf,
+static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 			       const struct iomap_ops *ops)
 {
 	struct vm_area_struct *vma = vmf->vma;
@@ -1425,7 +1425,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf,
 	return result;
 }
 #else
-static int dax_iomap_pmd_fault(struct vm_fault *vmf,
+static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 			       const struct iomap_ops *ops)
 {
 	return VM_FAULT_FALLBACK;
@@ -1436,6 +1436,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf,
  * dax_iomap_fault - handle a page fault on a DAX file
  * @vmf: The description of the fault
  * @pe_size: Size of the page to fault in
+ * @pfnp: PFN to insert for synchronous faults if fsync is required
  * @ops: Iomap ops passed from the file system
  *
  * When a page fault occurs, filesystems may call this helper in
@@ -1444,13 +1445,13 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf,
  * successfully.
  */
 int dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
-		    const struct iomap_ops *ops)
+		    pfn_t *pfnp, const struct iomap_ops *ops)
 {
 	switch (pe_size) {
 	case PE_SIZE_PTE:
-		return dax_iomap_pte_fault(vmf, ops);
+		return dax_iomap_pte_fault(vmf, pfnp, ops);
 	case PE_SIZE_PMD:
-		return dax_iomap_pmd_fault(vmf, ops);
+		return dax_iomap_pmd_fault(vmf, pfnp, ops);
 	default:
 		return VM_FAULT_FALLBACK;
 	}
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index ff3a3636a5ca..d2bb7c96307d 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -99,7 +99,7 @@ static int ext2_dax_fault(struct vm_fault *vmf)
 	}
 	down_read(&ei->dax_sem);
 
-	ret = dax_iomap_fault(vmf, PE_SIZE_PTE, &ext2_iomap_ops);
+	ret = dax_iomap_fault(vmf, PE_SIZE_PTE, NULL, &ext2_iomap_ops);
 
 	up_read(&ei->dax_sem);
 	if (vmf->flags & FAULT_FLAG_WRITE)
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index b1da660ac3bc..3cec0b95672f 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -306,7 +306,7 @@ static int ext4_dax_huge_fault(struct vm_fault *vmf,
 		down_read(&EXT4_I(inode)->i_mmap_sem);
 	}
 	if (!IS_ERR(handle))
-		result = dax_iomap_fault(vmf, pe_size, &ext4_iomap_ops);
+		result = dax_iomap_fault(vmf, pe_size, NULL, &ext4_iomap_ops);
 	else
 		result = VM_FAULT_SIGBUS;
 	if (write) {
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 309e26c9dddb..7c6b8def6eed 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1040,7 +1040,7 @@ __xfs_filemap_fault(
 
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 	if (IS_DAX(inode)) {
-		ret = dax_iomap_fault(vmf, pe_size, &xfs_iomap_ops);
+		ret = dax_iomap_fault(vmf, pe_size, NULL, &xfs_iomap_ops);
 	} else {
 		if (write_fault)
 			ret = iomap_page_mkwrite(vmf, &xfs_iomap_ops);
@@ -1111,7 +1111,7 @@ xfs_filemap_pfn_mkwrite(
 	if (vmf->pgoff >= size)
 		ret = VM_FAULT_SIGBUS;
 	else if (IS_DAX(inode))
-		ret = dax_iomap_fault(vmf, PE_SIZE_PTE, &xfs_iomap_ops);
+		ret = dax_iomap_fault(vmf, PE_SIZE_PTE, NULL, &xfs_iomap_ops);
 	xfs_iunlock(ip, XFS_MMAPLOCK_SHARED);
 	sb_end_pagefault(inode->i_sb);
 	return ret;
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 122197124b9d..e7fa4b8f45bc 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -95,7 +95,7 @@ bool dax_write_cache_enabled(struct dax_device *dax_dev);
 ssize_t dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
 		const struct iomap_ops *ops);
 int dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
-		    const struct iomap_ops *ops);
+		    pfn_t *pfnp, const struct iomap_ops *ops);
 int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index);
 int dax_invalidate_mapping_entry_sync(struct address_space *mapping,
 				      pgoff_t index);
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
