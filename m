Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C7C136B025E
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 15:51:07 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q10so133538392pgq.7
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 12:51:07 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id z1si4025539pfi.275.2016.12.15.12.51.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 12:51:06 -0800 (PST)
Subject: [PATCH v3 2/3] mm,
 dax: make pmd_fault() and friends to be the same as fault()
From: Dave Jiang <dave.jiang@intel.com>
Date: Thu, 15 Dec 2016 13:51:05 -0700
Message-ID: <148183506511.96369.3577733318086932161.stgit@djiang5-desk3.ch.intel.com>
In-Reply-To: <148183505925.96369.9987658623875784437.stgit@djiang5-desk3.ch.intel.com>
References: <148183505925.96369.9987658623875784437.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: jack@suse.cz, linux-nvdimm@lists.01.org, david@fromorbit.com, hch@lst.de, linux-mm@kvack.org, tytso@mit.edu, ross.zwisler@linux.intel.com, dan.j.williams@intel.com

Instead of passing in multiple parameters in the pmd_fault() handler,
a vmf can be passed in just like a fault() handler. This will simplify
code and remove the need for the actual pmd fault handlers to allocate a
vmf. Related functions are also modified to do the same.

Signed-off-by: Dave Jiang <dave.jiang@intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 drivers/dax/dax.c             |   16 ++++++---------
 fs/dax.c                      |   45 ++++++++++++++++++-----------------------
 fs/ext4/file.c                |   14 ++++++++-----
 fs/xfs/xfs_file.c             |   14 +++++++------
 include/linux/dax.h           |    7 +++---
 include/linux/mm.h            |    3 +--
 include/trace/events/fs_dax.h |   15 ++++++--------
 mm/memory.c                   |    6 ++---
 8 files changed, 57 insertions(+), 63 deletions(-)

diff --git a/drivers/dax/dax.c b/drivers/dax/dax.c
index c753a4c..947e49a 100644
--- a/drivers/dax/dax.c
+++ b/drivers/dax/dax.c
@@ -379,10 +379,9 @@ static int dax_dev_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 }
 
 static int __dax_dev_pmd_fault(struct dax_dev *dax_dev,
-		struct vm_area_struct *vma, unsigned long addr, pmd_t *pmd,
-		unsigned int flags)
+		struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	unsigned long pmd_addr = addr & PMD_MASK;
+	unsigned long pmd_addr = vmf->address & PMD_MASK;
 	struct device *dev = &dax_dev->dev;
 	struct dax_region *dax_region;
 	phys_addr_t phys;
@@ -414,23 +413,22 @@ static int __dax_dev_pmd_fault(struct dax_dev *dax_dev,
 
 	pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
 
-	return vmf_insert_pfn_pmd(vma, addr, pmd, pfn,
-			flags & FAULT_FLAG_WRITE);
+	return vmf_insert_pfn_pmd(vma, vmf->address, vmf->pmd, pfn,
+			vmf->flags & FAULT_FLAG_WRITE);
 }
 
-static int dax_dev_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
-		pmd_t *pmd, unsigned int flags)
+static int dax_dev_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	int rc;
 	struct file *filp = vma->vm_file;
 	struct dax_dev *dax_dev = filp->private_data;
 
 	dev_dbg(&dax_dev->dev, "%s: %s: %s (%#lx - %#lx)\n", __func__,
-			current->comm, (flags & FAULT_FLAG_WRITE)
+			current->comm, (vmf->flags & FAULT_FLAG_WRITE)
 			? "write" : "read", vma->vm_start, vma->vm_end);
 
 	rcu_read_lock();
-	rc = __dax_dev_pmd_fault(dax_dev, vma, addr, pmd, flags);
+	rc = __dax_dev_pmd_fault(dax_dev, vma, vmf);
 	rcu_read_unlock();
 
 	return rc;
diff --git a/fs/dax.c b/fs/dax.c
index 6395bc6..157f77f 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1310,18 +1310,17 @@ static int dax_pmd_load_hole(struct vm_area_struct *vma, pmd_t *pmd,
 	return VM_FAULT_FALLBACK;
 }
 
-int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
-		pmd_t *pmd, unsigned int flags, struct iomap_ops *ops)
+int dax_iomap_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
+		struct iomap_ops *ops)
 {
 	struct address_space *mapping = vma->vm_file->f_mapping;
-	unsigned long pmd_addr = address & PMD_MASK;
-	bool write = flags & FAULT_FLAG_WRITE;
+	unsigned long pmd_addr = vmf->address & PMD_MASK;
+	bool write = vmf->flags & FAULT_FLAG_WRITE;
 	unsigned int iomap_flags = (write ? IOMAP_WRITE : 0) | IOMAP_FAULT;
 	struct inode *inode = mapping->host;
 	int result = VM_FAULT_FALLBACK;
 	struct iomap iomap = { 0 };
-	pgoff_t max_pgoff, pgoff;
-	struct vm_fault vmf;
+	pgoff_t max_pgoff, old_pgoff;
 	void *entry;
 	loff_t pos;
 	int error;
@@ -1331,10 +1330,11 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	 * supposed to hold locks serializing us with truncate / punch hole so
 	 * this is a reliable test.
 	 */
-	pgoff = linear_page_index(vma, pmd_addr);
+	old_pgoff = vmf->pgoff;
+	vmf->pgoff = linear_page_index(vma, pmd_addr);
 	max_pgoff = (i_size_read(inode) - 1) >> PAGE_SHIFT;
 
-	trace_dax_pmd_fault(inode, vma, address, flags, pgoff, max_pgoff, 0);
+	trace_dax_pmd_fault(inode, vma, vmf, max_pgoff, 0);
 
 	/* Fall back to PTEs if we're going to COW */
 	if (write && !(vma->vm_flags & VM_SHARED))
@@ -1346,13 +1346,13 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	if ((pmd_addr + PMD_SIZE) > vma->vm_end)
 		goto fallback;
 
-	if (pgoff > max_pgoff) {
+	if (vmf->pgoff > max_pgoff) {
 		result = VM_FAULT_SIGBUS;
 		goto out;
 	}
 
 	/* If the PMD would extend beyond the file size */
-	if ((pgoff | PG_PMD_COLOUR) > max_pgoff)
+	if ((vmf->pgoff | PG_PMD_COLOUR) > max_pgoff)
 		goto fallback;
 
 	/*
@@ -1360,7 +1360,7 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	 * setting up a mapping, so really we're using iomap_begin() as a way
 	 * to look up our filesystem block.
 	 */
-	pos = (loff_t)pgoff << PAGE_SHIFT;
+	pos = (loff_t)vmf->pgoff << PAGE_SHIFT;
 	error = ops->iomap_begin(inode, pos, PMD_SIZE, iomap_flags, &iomap);
 	if (error)
 		goto fallback;
@@ -1370,29 +1370,24 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	 * the tree, for instance), it will return -EEXIST and we just fall
 	 * back to 4k entries.
 	 */
-	entry = grab_mapping_entry(mapping, pgoff, RADIX_DAX_PMD);
+	entry = grab_mapping_entry(mapping, vmf->pgoff, RADIX_DAX_PMD);
 	if (IS_ERR(entry))
 		goto finish_iomap;
 
 	if (iomap.offset + iomap.length < pos + PMD_SIZE)
 		goto unlock_entry;
 
-	vmf.pgoff = pgoff;
-	vmf.flags = flags;
-	vmf.gfp_mask = mapping_gfp_mask(mapping) | __GFP_IO;
-	vmf.gfp_mask &= ~__GFP_FS;
-
 	switch (iomap.type) {
 	case IOMAP_MAPPED:
-		result = dax_pmd_insert_mapping(vma, pmd, &vmf, address,
-				&iomap, pos, write, &entry);
+		result = dax_pmd_insert_mapping(vma, vmf->pmd, vmf,
+				vmf->address, &iomap, pos, write, &entry);
 		break;
 	case IOMAP_UNWRITTEN:
 	case IOMAP_HOLE:
 		if (WARN_ON_ONCE(write))
 			goto unlock_entry;
-		result = dax_pmd_load_hole(vma, pmd, &vmf, address, &iomap,
-				&entry);
+		result = dax_pmd_load_hole(vma, vmf->pmd, vmf, vmf->address,
+				&iomap, &entry);
 		break;
 	default:
 		WARN_ON_ONCE(1);
@@ -1400,7 +1395,7 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	}
 
  unlock_entry:
-	put_locked_mapping_entry(mapping, pgoff, entry);
+	put_locked_mapping_entry(mapping, vmf->pgoff, entry);
  finish_iomap:
 	if (ops->iomap_end) {
 		int copied = PMD_SIZE;
@@ -1418,12 +1413,12 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	}
  fallback:
 	if (result == VM_FAULT_FALLBACK) {
-		split_huge_pmd(vma, pmd, address);
+		split_huge_pmd(vma, vmf->pmd, vmf->address);
 		count_vm_event(THP_FAULT_FALLBACK);
 	}
 out:
-	trace_dax_pmd_fault_done(inode, vma, address, flags, pgoff, max_pgoff,
-			result);
+	trace_dax_pmd_fault_done(inode, vma, vmf, max_pgoff, result);
+	vmf->pgoff = old_pgoff;
 	return result;
 }
 EXPORT_SYMBOL_GPL(dax_iomap_pmd_fault);
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index a3f2bf0..e6cdb78 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -278,22 +278,26 @@ static int ext4_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return result;
 }
 
-static int ext4_dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
-						pmd_t *pmd, unsigned int flags)
+static int
+ext4_dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	int result;
 	struct inode *inode = file_inode(vma->vm_file);
 	struct super_block *sb = inode->i_sb;
-	bool write = flags & FAULT_FLAG_WRITE;
+	bool write = vmf->flags & FAULT_FLAG_WRITE;
+	gfp_t old_mask;
 
 	if (write) {
 		sb_start_pagefault(sb);
 		file_update_time(vma->vm_file);
 	}
+
+	old_mask = vmf->gfp_mask;
+	vmf->gfp_mask &= ~__GFP_FS;
 	down_read(&EXT4_I(inode)->i_mmap_sem);
-	result = dax_iomap_pmd_fault(vma, addr, pmd, flags,
-				     &ext4_iomap_ops);
+	result = dax_iomap_pmd_fault(vma, vmf, &ext4_iomap_ops);
 	up_read(&EXT4_I(inode)->i_mmap_sem);
+	vmf->gfp_mask = old_mask;
 	if (write)
 		sb_end_pagefault(sb);
 
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 52202b4..b1b8524 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1533,29 +1533,31 @@ xfs_filemap_fault(
 STATIC int
 xfs_filemap_pmd_fault(
 	struct vm_area_struct	*vma,
-	unsigned long		addr,
-	pmd_t			*pmd,
-	unsigned int		flags)
+	struct vm_fault *vmf)
 {
 	struct inode		*inode = file_inode(vma->vm_file);
 	struct xfs_inode	*ip = XFS_I(inode);
 	int			ret;
+	gfp_t			old_mask;
 
 	if (!IS_DAX(inode))
 		return VM_FAULT_FALLBACK;
 
 	trace_xfs_filemap_pmd_fault(ip);
 
-	if (flags & FAULT_FLAG_WRITE) {
+	if (vmf->flags & FAULT_FLAG_WRITE) {
 		sb_start_pagefault(inode->i_sb);
 		file_update_time(vma->vm_file);
 	}
 
+	old_mask = vmf->gfp_mask;
+	vmf->gfp_mask &= ~__GFP_FS;
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
-	ret = dax_iomap_pmd_fault(vma, addr, pmd, flags, &xfs_iomap_ops);
+	ret = dax_iomap_pmd_fault(vma, vmf, &xfs_iomap_ops);
 	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
+	vmf->gfp_mask = old_mask;
 
-	if (flags & FAULT_FLAG_WRITE)
+	if (vmf->flags & FAULT_FLAG_WRITE)
 		sb_end_pagefault(inode->i_sb);
 
 	return ret;
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 6e36b11..9761c90 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -71,16 +71,15 @@ static inline unsigned int dax_radix_order(void *entry)
 		return PMD_SHIFT - PAGE_SHIFT;
 	return 0;
 }
-int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
-		pmd_t *pmd, unsigned int flags, struct iomap_ops *ops);
+int dax_iomap_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
+		struct iomap_ops *ops);
 #else
 static inline unsigned int dax_radix_order(void *entry)
 {
 	return 0;
 }
 static inline int dax_iomap_pmd_fault(struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd, unsigned int flags,
-		struct iomap_ops *ops)
+		struct vm_fault *vmf, struct iomap_ops *ops)
 {
 	return VM_FAULT_FALLBACK;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 30f416a..aef645b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -347,8 +347,7 @@ struct vm_operations_struct {
 	void (*close)(struct vm_area_struct * area);
 	int (*mremap)(struct vm_area_struct * area);
 	int (*fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
-	int (*pmd_fault)(struct vm_area_struct *, unsigned long address,
-						pmd_t *, unsigned int flags);
+	int (*pmd_fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
 	void (*map_pages)(struct vm_fault *vmf,
 			pgoff_t start_pgoff, pgoff_t end_pgoff);
 
diff --git a/include/trace/events/fs_dax.h b/include/trace/events/fs_dax.h
index c3b0aae..a98665b 100644
--- a/include/trace/events/fs_dax.h
+++ b/include/trace/events/fs_dax.h
@@ -8,9 +8,8 @@
 
 DECLARE_EVENT_CLASS(dax_pmd_fault_class,
 	TP_PROTO(struct inode *inode, struct vm_area_struct *vma,
-		unsigned long address, unsigned int flags, pgoff_t pgoff,
-		pgoff_t max_pgoff, int result),
-	TP_ARGS(inode, vma, address, flags, pgoff, max_pgoff, result),
+		struct vm_fault *vmf, pgoff_t max_pgoff, int result),
+	TP_ARGS(inode, vma, vmf, max_pgoff, result),
 	TP_STRUCT__entry(
 		__field(unsigned long, ino)
 		__field(unsigned long, vm_start)
@@ -29,9 +28,9 @@ DECLARE_EVENT_CLASS(dax_pmd_fault_class,
 		__entry->vm_start = vma->vm_start;
 		__entry->vm_end = vma->vm_end;
 		__entry->vm_flags = vma->vm_flags;
-		__entry->address = address;
-		__entry->flags = flags;
-		__entry->pgoff = pgoff;
+		__entry->address = vmf->address;
+		__entry->flags = vmf->flags;
+		__entry->pgoff = vmf->pgoff;
 		__entry->max_pgoff = max_pgoff;
 		__entry->result = result;
 	),
@@ -54,9 +53,9 @@ DECLARE_EVENT_CLASS(dax_pmd_fault_class,
 #define DEFINE_PMD_FAULT_EVENT(name) \
 DEFINE_EVENT(dax_pmd_fault_class, name, \
 	TP_PROTO(struct inode *inode, struct vm_area_struct *vma, \
-		unsigned long address, unsigned int flags, pgoff_t pgoff, \
+		struct vm_fault *vmf, \
 		pgoff_t max_pgoff, int result), \
-	TP_ARGS(inode, vma, address, flags, pgoff, max_pgoff, result))
+	TP_ARGS(inode, vma, vmf, max_pgoff, result))
 
 DEFINE_PMD_FAULT_EVENT(dax_pmd_fault);
 DEFINE_PMD_FAULT_EVENT(dax_pmd_fault_done);
diff --git a/mm/memory.c b/mm/memory.c
index e37250f..8ec36cf 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3447,8 +3447,7 @@ static int create_huge_pmd(struct vm_fault *vmf)
 	if (vma_is_anonymous(vma))
 		return do_huge_pmd_anonymous_page(vmf);
 	if (vma->vm_ops->pmd_fault)
-		return vma->vm_ops->pmd_fault(vma, vmf->address, vmf->pmd,
-				vmf->flags);
+		return vma->vm_ops->pmd_fault(vma, vmf);
 	return VM_FAULT_FALLBACK;
 }
 
@@ -3457,8 +3456,7 @@ static int wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
 	if (vma_is_anonymous(vmf->vma))
 		return do_huge_pmd_wp_page(vmf, orig_pmd);
 	if (vmf->vma->vm_ops->pmd_fault)
-		return vmf->vma->vm_ops->pmd_fault(vmf->vma, vmf->address,
-				vmf->pmd, vmf->flags);
+		return vmf->vma->vm_ops->pmd_fault(vmf->vma, vmf);
 
 	/* COW handled on pte level: split pmd */
 	VM_BUG_ON_VMA(vmf->vma->vm_flags & VM_SHARED, vmf->vma);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
