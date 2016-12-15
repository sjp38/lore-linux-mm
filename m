Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 30FF26B0261
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 15:51:13 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id y71so133517072pgd.0
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 12:51:13 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id m66si4099641pld.72.2016.12.15.12.51.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 12:51:11 -0800 (PST)
Subject: [PATCH v3 3/3] mm, dax: move pmd_fault() to take only vmf parameter
From: Dave Jiang <dave.jiang@intel.com>
Date: Thu, 15 Dec 2016 13:51:11 -0700
Message-ID: <148183507090.96369.1341372300913394127.stgit@djiang5-desk3.ch.intel.com>
In-Reply-To: <148183505925.96369.9987658623875784437.stgit@djiang5-desk3.ch.intel.com>
References: <148183505925.96369.9987658623875784437.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: jack@suse.cz, linux-nvdimm@lists.01.org, david@fromorbit.com, hch@lst.de, linux-mm@kvack.org, tytso@mit.edu, ross.zwisler@linux.intel.com, dan.j.williams@intel.com

pmd_fault() and related functions really only need the vmf parameter since
the additional parameters are all included in the vmf struct. Removing
additional parameter and simplify pmd_fault() and friends.

Signed-off-by: Dave Jiang <dave.jiang@intel.com>
---
 drivers/dax/dax.c             |   18 +++++++-------
 fs/dax.c                      |   54 +++++++++++++++++++----------------------
 fs/ext4/file.c                |    8 +++---
 fs/xfs/xfs_file.c             |    7 ++---
 include/linux/dax.h           |    7 ++---
 include/linux/mm.h            |    2 +-
 include/trace/events/fs_dax.h |   54 +++++++++++++++++++----------------------
 mm/memory.c                   |    9 +++----
 8 files changed, 74 insertions(+), 85 deletions(-)

diff --git a/drivers/dax/dax.c b/drivers/dax/dax.c
index 947e49a..55160f8 100644
--- a/drivers/dax/dax.c
+++ b/drivers/dax/dax.c
@@ -378,8 +378,7 @@ static int dax_dev_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return rc;
 }
 
-static int __dax_dev_pmd_fault(struct dax_dev *dax_dev,
-		struct vm_area_struct *vma, struct vm_fault *vmf)
+static int __dax_dev_pmd_fault(struct dax_dev *dax_dev, struct vm_fault *vmf)
 {
 	unsigned long pmd_addr = vmf->address & PMD_MASK;
 	struct device *dev = &dax_dev->dev;
@@ -388,7 +387,7 @@ static int __dax_dev_pmd_fault(struct dax_dev *dax_dev,
 	pgoff_t pgoff;
 	pfn_t pfn;
 
-	if (check_vma(dax_dev, vma, __func__))
+	if (check_vma(dax_dev, vmf->vma, __func__))
 		return VM_FAULT_SIGBUS;
 
 	dax_region = dax_dev->region;
@@ -403,7 +402,7 @@ static int __dax_dev_pmd_fault(struct dax_dev *dax_dev,
 		return VM_FAULT_SIGBUS;
 	}
 
-	pgoff = linear_page_index(vma, pmd_addr);
+	pgoff = linear_page_index(vmf->vma, pmd_addr);
 	phys = pgoff_to_phys(dax_dev, pgoff, PMD_SIZE);
 	if (phys == -1) {
 		dev_dbg(dev, "%s: phys_to_pgoff(%#lx) failed\n", __func__,
@@ -413,22 +412,23 @@ static int __dax_dev_pmd_fault(struct dax_dev *dax_dev,
 
 	pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
 
-	return vmf_insert_pfn_pmd(vma, vmf->address, vmf->pmd, pfn,
+	return vmf_insert_pfn_pmd(vmf->vma, vmf->address, vmf->pmd, pfn,
 			vmf->flags & FAULT_FLAG_WRITE);
 }
 
-static int dax_dev_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
+static int dax_dev_pmd_fault(struct vm_fault *vmf)
 {
 	int rc;
-	struct file *filp = vma->vm_file;
+	struct file *filp = vmf->vma->vm_file;
 	struct dax_dev *dax_dev = filp->private_data;
 
 	dev_dbg(&dax_dev->dev, "%s: %s: %s (%#lx - %#lx)\n", __func__,
 			current->comm, (vmf->flags & FAULT_FLAG_WRITE)
-			? "write" : "read", vma->vm_start, vma->vm_end);
+			? "write" : "read",
+			vmf->vma->vm_start, vmf->vma->vm_end);
 
 	rcu_read_lock();
-	rc = __dax_dev_pmd_fault(dax_dev, vma, vmf);
+	rc = __dax_dev_pmd_fault(dax_dev, vmf);
 	rcu_read_unlock();
 
 	return rc;
diff --git a/fs/dax.c b/fs/dax.c
index 157f77f..bc39809 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1226,11 +1226,10 @@ EXPORT_SYMBOL_GPL(dax_iomap_fault);
  */
 #define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)
 
-static int dax_pmd_insert_mapping(struct vm_area_struct *vma, pmd_t *pmd,
-		struct vm_fault *vmf, unsigned long address,
-		struct iomap *iomap, loff_t pos, bool write, void **entryp)
+static int dax_pmd_insert_mapping(struct vm_fault *vmf, struct iomap *iomap,
+		loff_t pos, void **entryp)
 {
-	struct address_space *mapping = vma->vm_file->f_mapping;
+	struct address_space *mapping = vmf->vma->vm_file->f_mapping;
 	struct block_device *bdev = iomap->bdev;
 	struct inode *inode = mapping->host;
 	struct blk_dax_ctl dax = {
@@ -1257,31 +1256,30 @@ static int dax_pmd_insert_mapping(struct vm_area_struct *vma, pmd_t *pmd,
 		goto fallback;
 	*entryp = ret;
 
-	trace_dax_pmd_insert_mapping(inode, vma, address, write, length,
-			dax.pfn, ret);
-	return vmf_insert_pfn_pmd(vma, address, pmd, dax.pfn, write);
+	trace_dax_pmd_insert_mapping(inode, vmf, length, dax.pfn, ret);
+	return vmf_insert_pfn_pmd(vmf->vma, vmf->address, vmf->pmd,
+			dax.pfn, vmf->flags & FAULT_FLAG_WRITE);
 
  unmap_fallback:
 	dax_unmap_atomic(bdev, &dax);
 fallback:
-	trace_dax_pmd_insert_mapping_fallback(inode, vma, address, write,
-			length, dax.pfn, ret);
+	trace_dax_pmd_insert_mapping_fallback(inode, vmf, length,
+			dax.pfn, ret);
 	return VM_FAULT_FALLBACK;
 }
 
-static int dax_pmd_load_hole(struct vm_area_struct *vma, pmd_t *pmd,
-		struct vm_fault *vmf, unsigned long address,
-		struct iomap *iomap, void **entryp)
+static int dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
+		void **entryp)
 {
-	struct address_space *mapping = vma->vm_file->f_mapping;
-	unsigned long pmd_addr = address & PMD_MASK;
+	struct address_space *mapping = vmf->vma->vm_file->f_mapping;
+	unsigned long pmd_addr = vmf->address & PMD_MASK;
 	struct inode *inode = mapping->host;
 	struct page *zero_page;
 	void *ret = NULL;
 	spinlock_t *ptl;
 	pmd_t pmd_entry;
 
-	zero_page = mm_get_huge_zero_page(vma->vm_mm);
+	zero_page = mm_get_huge_zero_page(vmf->vma->vm_mm);
 
 	if (unlikely(!zero_page))
 		goto fallback;
@@ -1292,27 +1290,27 @@ static int dax_pmd_load_hole(struct vm_area_struct *vma, pmd_t *pmd,
 		goto fallback;
 	*entryp = ret;
 
-	ptl = pmd_lock(vma->vm_mm, pmd);
-	if (!pmd_none(*pmd)) {
+	ptl = pmd_lock(vmf->vma->vm_mm, vmf->pmd);
+	if (!pmd_none(*(vmf->pmd))) {
 		spin_unlock(ptl);
 		goto fallback;
 	}
 
-	pmd_entry = mk_pmd(zero_page, vma->vm_page_prot);
+	pmd_entry = mk_pmd(zero_page, vmf->vma->vm_page_prot);
 	pmd_entry = pmd_mkhuge(pmd_entry);
-	set_pmd_at(vma->vm_mm, pmd_addr, pmd, pmd_entry);
+	set_pmd_at(vmf->vma->vm_mm, pmd_addr, vmf->pmd, pmd_entry);
 	spin_unlock(ptl);
-	trace_dax_pmd_load_hole(inode, vma, address, zero_page, ret);
+	trace_dax_pmd_load_hole(inode, vmf, zero_page, ret);
 	return VM_FAULT_NOPAGE;
 
 fallback:
-	trace_dax_pmd_load_hole_fallback(inode, vma, address, zero_page, ret);
+	trace_dax_pmd_load_hole_fallback(inode, vmf, zero_page, ret);
 	return VM_FAULT_FALLBACK;
 }
 
-int dax_iomap_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
-		struct iomap_ops *ops)
+int dax_iomap_pmd_fault(struct vm_fault *vmf, struct iomap_ops *ops)
 {
+	struct vm_area_struct *vma = vmf->vma;
 	struct address_space *mapping = vma->vm_file->f_mapping;
 	unsigned long pmd_addr = vmf->address & PMD_MASK;
 	bool write = vmf->flags & FAULT_FLAG_WRITE;
@@ -1334,7 +1332,7 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	vmf->pgoff = linear_page_index(vma, pmd_addr);
 	max_pgoff = (i_size_read(inode) - 1) >> PAGE_SHIFT;
 
-	trace_dax_pmd_fault(inode, vma, vmf, max_pgoff, 0);
+	trace_dax_pmd_fault(inode, vmf, max_pgoff, 0);
 
 	/* Fall back to PTEs if we're going to COW */
 	if (write && !(vma->vm_flags & VM_SHARED))
@@ -1379,15 +1377,13 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 
 	switch (iomap.type) {
 	case IOMAP_MAPPED:
-		result = dax_pmd_insert_mapping(vma, vmf->pmd, vmf,
-				vmf->address, &iomap, pos, write, &entry);
+		result = dax_pmd_insert_mapping(vmf, &iomap, pos, &entry);
 		break;
 	case IOMAP_UNWRITTEN:
 	case IOMAP_HOLE:
 		if (WARN_ON_ONCE(write))
 			goto unlock_entry;
-		result = dax_pmd_load_hole(vma, vmf->pmd, vmf, vmf->address,
-				&iomap, &entry);
+		result = dax_pmd_load_hole(vmf, &iomap, &entry);
 		break;
 	default:
 		WARN_ON_ONCE(1);
@@ -1417,7 +1413,7 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		count_vm_event(THP_FAULT_FALLBACK);
 	}
 out:
-	trace_dax_pmd_fault_done(inode, vma, vmf, max_pgoff, result);
+	trace_dax_pmd_fault_done(inode, vmf, max_pgoff, result);
 	vmf->pgoff = old_pgoff;
 	return result;
 }
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index e6cdb78..2f4fd28 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -279,23 +279,23 @@ static int ext4_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 }
 
 static int
-ext4_dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
+ext4_dax_pmd_fault(struct vm_fault *vmf)
 {
 	int result;
-	struct inode *inode = file_inode(vma->vm_file);
+	struct inode *inode = file_inode(vmf->vma->vm_file);
 	struct super_block *sb = inode->i_sb;
 	bool write = vmf->flags & FAULT_FLAG_WRITE;
 	gfp_t old_mask;
 
 	if (write) {
 		sb_start_pagefault(sb);
-		file_update_time(vma->vm_file);
+		file_update_time(vmf->vma->vm_file);
 	}
 
 	old_mask = vmf->gfp_mask;
 	vmf->gfp_mask &= ~__GFP_FS;
 	down_read(&EXT4_I(inode)->i_mmap_sem);
-	result = dax_iomap_pmd_fault(vma, vmf, &ext4_iomap_ops);
+	result = dax_iomap_pmd_fault(vmf, &ext4_iomap_ops);
 	up_read(&EXT4_I(inode)->i_mmap_sem);
 	vmf->gfp_mask = old_mask;
 	if (write)
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index b1b8524..b548fc5 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1532,10 +1532,9 @@ xfs_filemap_fault(
  */
 STATIC int
 xfs_filemap_pmd_fault(
-	struct vm_area_struct	*vma,
 	struct vm_fault *vmf)
 {
-	struct inode		*inode = file_inode(vma->vm_file);
+	struct inode		*inode = file_inode(vmf->vma->vm_file);
 	struct xfs_inode	*ip = XFS_I(inode);
 	int			ret;
 	gfp_t			old_mask;
@@ -1547,13 +1546,13 @@ xfs_filemap_pmd_fault(
 
 	if (vmf->flags & FAULT_FLAG_WRITE) {
 		sb_start_pagefault(inode->i_sb);
-		file_update_time(vma->vm_file);
+		file_update_time(vmf->vma->vm_file);
 	}
 
 	old_mask = vmf->gfp_mask;
 	vmf->gfp_mask &= ~__GFP_FS;
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
-	ret = dax_iomap_pmd_fault(vma, vmf, &xfs_iomap_ops);
+	ret = dax_iomap_pmd_fault(vmf, &xfs_iomap_ops);
 	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 	vmf->gfp_mask = old_mask;
 
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 9761c90..1ffdb4d 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -71,15 +71,14 @@ static inline unsigned int dax_radix_order(void *entry)
 		return PMD_SHIFT - PAGE_SHIFT;
 	return 0;
 }
-int dax_iomap_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
-		struct iomap_ops *ops);
+int dax_iomap_pmd_fault(struct vm_fault *vmf, struct iomap_ops *ops);
 #else
 static inline unsigned int dax_radix_order(void *entry)
 {
 	return 0;
 }
-static inline int dax_iomap_pmd_fault(struct vm_area_struct *vma,
-		struct vm_fault *vmf, struct iomap_ops *ops)
+static inline int dax_iomap_pmd_fault(struct vm_fault *vmf,
+		struct iomap_ops *ops)
 {
 	return VM_FAULT_FALLBACK;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index aef645b..795f03e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -347,7 +347,7 @@ struct vm_operations_struct {
 	void (*close)(struct vm_area_struct * area);
 	int (*mremap)(struct vm_area_struct * area);
 	int (*fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
-	int (*pmd_fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
+	int (*pmd_fault)(struct vm_fault *vmf);
 	void (*map_pages)(struct vm_fault *vmf,
 			pgoff_t start_pgoff, pgoff_t end_pgoff);
 
diff --git a/include/trace/events/fs_dax.h b/include/trace/events/fs_dax.h
index a98665b..c566ddc 100644
--- a/include/trace/events/fs_dax.h
+++ b/include/trace/events/fs_dax.h
@@ -7,9 +7,9 @@
 #include <linux/tracepoint.h>
 
 DECLARE_EVENT_CLASS(dax_pmd_fault_class,
-	TP_PROTO(struct inode *inode, struct vm_area_struct *vma,
-		struct vm_fault *vmf, pgoff_t max_pgoff, int result),
-	TP_ARGS(inode, vma, vmf, max_pgoff, result),
+	TP_PROTO(struct inode *inode, struct vm_fault *vmf,
+		pgoff_t max_pgoff, int result),
+	TP_ARGS(inode, vmf, max_pgoff, result),
 	TP_STRUCT__entry(
 		__field(unsigned long, ino)
 		__field(unsigned long, vm_start)
@@ -25,9 +25,9 @@ DECLARE_EVENT_CLASS(dax_pmd_fault_class,
 	TP_fast_assign(
 		__entry->dev = inode->i_sb->s_dev;
 		__entry->ino = inode->i_ino;
-		__entry->vm_start = vma->vm_start;
-		__entry->vm_end = vma->vm_end;
-		__entry->vm_flags = vma->vm_flags;
+		__entry->vm_start = vmf->vma->vm_start;
+		__entry->vm_end = vmf->vma->vm_end;
+		__entry->vm_flags = vmf->vma->vm_flags;
 		__entry->address = vmf->address;
 		__entry->flags = vmf->flags;
 		__entry->pgoff = vmf->pgoff;
@@ -52,19 +52,18 @@ DECLARE_EVENT_CLASS(dax_pmd_fault_class,
 
 #define DEFINE_PMD_FAULT_EVENT(name) \
 DEFINE_EVENT(dax_pmd_fault_class, name, \
-	TP_PROTO(struct inode *inode, struct vm_area_struct *vma, \
-		struct vm_fault *vmf, \
+	TP_PROTO(struct inode *inode, struct vm_fault *vmf, \
 		pgoff_t max_pgoff, int result), \
-	TP_ARGS(inode, vma, vmf, max_pgoff, result))
+	TP_ARGS(inode, vmf, max_pgoff, result))
 
 DEFINE_PMD_FAULT_EVENT(dax_pmd_fault);
 DEFINE_PMD_FAULT_EVENT(dax_pmd_fault_done);
 
 DECLARE_EVENT_CLASS(dax_pmd_load_hole_class,
-	TP_PROTO(struct inode *inode, struct vm_area_struct *vma,
-		unsigned long address, struct page *zero_page,
+	TP_PROTO(struct inode *inode, struct vm_fault *vmf,
+		struct page *zero_page,
 		void *radix_entry),
-	TP_ARGS(inode, vma, address, zero_page, radix_entry),
+	TP_ARGS(inode, vmf, zero_page, radix_entry),
 	TP_STRUCT__entry(
 		__field(unsigned long, ino)
 		__field(unsigned long, vm_flags)
@@ -76,8 +75,8 @@ DECLARE_EVENT_CLASS(dax_pmd_load_hole_class,
 	TP_fast_assign(
 		__entry->dev = inode->i_sb->s_dev;
 		__entry->ino = inode->i_ino;
-		__entry->vm_flags = vma->vm_flags;
-		__entry->address = address;
+		__entry->vm_flags = vmf->vma->vm_flags;
+		__entry->address = vmf->address;
 		__entry->zero_page = zero_page;
 		__entry->radix_entry = radix_entry;
 	),
@@ -95,19 +94,17 @@ DECLARE_EVENT_CLASS(dax_pmd_load_hole_class,
 
 #define DEFINE_PMD_LOAD_HOLE_EVENT(name) \
 DEFINE_EVENT(dax_pmd_load_hole_class, name, \
-	TP_PROTO(struct inode *inode, struct vm_area_struct *vma, \
-		unsigned long address, struct page *zero_page, \
-		void *radix_entry), \
-	TP_ARGS(inode, vma, address, zero_page, radix_entry))
+	TP_PROTO(struct inode *inode, struct vm_fault *vmf, \
+		struct page *zero_page, void *radix_entry), \
+	TP_ARGS(inode, vmf, zero_page, radix_entry))
 
 DEFINE_PMD_LOAD_HOLE_EVENT(dax_pmd_load_hole);
 DEFINE_PMD_LOAD_HOLE_EVENT(dax_pmd_load_hole_fallback);
 
 DECLARE_EVENT_CLASS(dax_pmd_insert_mapping_class,
-	TP_PROTO(struct inode *inode, struct vm_area_struct *vma,
-		unsigned long address, int write, long length, pfn_t pfn,
-		void *radix_entry),
-	TP_ARGS(inode, vma, address, write, length, pfn, radix_entry),
+	TP_PROTO(struct inode *inode, struct vm_fault *vmf,
+		long length, pfn_t pfn, void *radix_entry),
+	TP_ARGS(inode, vmf, length, pfn, radix_entry),
 	TP_STRUCT__entry(
 		__field(unsigned long, ino)
 		__field(unsigned long, vm_flags)
@@ -121,9 +118,9 @@ DECLARE_EVENT_CLASS(dax_pmd_insert_mapping_class,
 	TP_fast_assign(
 		__entry->dev = inode->i_sb->s_dev;
 		__entry->ino = inode->i_ino;
-		__entry->vm_flags = vma->vm_flags;
-		__entry->address = address;
-		__entry->write = write;
+		__entry->vm_flags = vmf->vma->vm_flags;
+		__entry->address = vmf->address;
+		__entry->write = vmf->flags & FAULT_FLAG_WRITE;
 		__entry->length = length;
 		__entry->pfn_val = pfn.val;
 		__entry->radix_entry = radix_entry;
@@ -146,10 +143,9 @@ DECLARE_EVENT_CLASS(dax_pmd_insert_mapping_class,
 
 #define DEFINE_PMD_INSERT_MAPPING_EVENT(name) \
 DEFINE_EVENT(dax_pmd_insert_mapping_class, name, \
-	TP_PROTO(struct inode *inode, struct vm_area_struct *vma, \
-		unsigned long address, int write, long length, pfn_t pfn, \
-		void *radix_entry), \
-	TP_ARGS(inode, vma, address, write, length, pfn, radix_entry))
+	TP_PROTO(struct inode *inode, struct vm_fault *vmf, \
+		long length, pfn_t pfn, void *radix_entry), \
+	TP_ARGS(inode, vmf, length, pfn, radix_entry))
 
 DEFINE_PMD_INSERT_MAPPING_EVENT(dax_pmd_insert_mapping);
 DEFINE_PMD_INSERT_MAPPING_EVENT(dax_pmd_insert_mapping_fallback);
diff --git a/mm/memory.c b/mm/memory.c
index 8ec36cf..e929c41 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3443,11 +3443,10 @@ static int do_numa_page(struct vm_fault *vmf)
 
 static int create_huge_pmd(struct vm_fault *vmf)
 {
-	struct vm_area_struct *vma = vmf->vma;
-	if (vma_is_anonymous(vma))
+	if (vma_is_anonymous(vmf->vma))
 		return do_huge_pmd_anonymous_page(vmf);
-	if (vma->vm_ops->pmd_fault)
-		return vma->vm_ops->pmd_fault(vma, vmf);
+	if (vmf->vma->vm_ops->pmd_fault)
+		return vmf->vma->vm_ops->pmd_fault(vmf);
 	return VM_FAULT_FALLBACK;
 }
 
@@ -3456,7 +3455,7 @@ static int wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
 	if (vma_is_anonymous(vmf->vma))
 		return do_huge_pmd_wp_page(vmf, orig_pmd);
 	if (vmf->vma->vm_ops->pmd_fault)
-		return vmf->vma->vm_ops->pmd_fault(vmf->vma, vmf);
+		return vmf->vma->vm_ops->pmd_fault(vmf);
 
 	/* COW handled on pte level: split pmd */
 	VM_BUG_ON_VMA(vmf->vma->vm_flags & VM_SHARED, vmf->vma);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
