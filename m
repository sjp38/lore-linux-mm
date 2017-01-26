Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 009156B0260
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 12:10:14 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 204so318483454pfx.1
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 09:10:13 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id p23si1903337pfl.37.2017.01.26.09.10.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 09:10:12 -0800 (PST)
Subject: [PATCH v2 1/3] mm,fs,dax: Change ->pmd_fault to ->huge_fault
From: Dave Jiang <dave.jiang@intel.com>
Date: Thu, 26 Jan 2017 10:09:47 -0700
Message-ID: <148545058784.17912.6353162518188733642.stgit@djiang5-desk3.ch.intel.com>
In-Reply-To: <148545012634.17912.13951763606410303827.stgit@djiang5-desk3.ch.intel.com>
References: <148545012634.17912.13951763606410303827.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dave.hansen@linux.intel.com, mawilcox@microsoft.com, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, jack@suse.com, dan.j.williams@intel.com, linux-ext4@vger.kernel.org, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com

In preparation for adding the ability to handle PUD pages, convert
->pmd_fault to ->huge_fault.  The vm_fault structure is extended to
include a union of the different page table pointers that may be needed,
and three flag bits are reserved to indicate which type of pointer is in
the union.

[DJ: Forward ported to 4.10-rc]

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Signed-off-by: Dave Jiang <dave.jiang@intel.com>
---
 drivers/dax/dax.c   |   34 +++++++++++++---------------------
 fs/dax.c            |   43 ++++++++++++++++++++++++++++++-------------
 fs/ext2/file.c      |    2 +-
 fs/ext4/file.c      |    6 +++---
 fs/xfs/xfs_file.c   |   10 +++++-----
 fs/xfs/xfs_trace.h  |    2 +-
 include/linux/dax.h |    6 ------
 include/linux/mm.h  |   10 +++++++++-
 mm/memory.c         |   14 ++++++++------
 9 files changed, 70 insertions(+), 57 deletions(-)

diff --git a/drivers/dax/dax.c b/drivers/dax/dax.c
index 0261f33..922ec46 100644
--- a/drivers/dax/dax.c
+++ b/drivers/dax/dax.c
@@ -419,7 +419,7 @@ static phys_addr_t pgoff_to_phys(struct dax_dev *dax_dev, pgoff_t pgoff,
 	return -1;
 }
 
-static int __dax_dev_fault(struct dax_dev *dax_dev, struct vm_fault *vmf)
+static int __dax_dev_pte_fault(struct dax_dev *dax_dev, struct vm_fault *vmf)
 {
 	struct device *dev = &dax_dev->dev;
 	struct dax_region *dax_region;
@@ -455,23 +455,6 @@ static int __dax_dev_fault(struct dax_dev *dax_dev, struct vm_fault *vmf)
 	return VM_FAULT_NOPAGE;
 }
 
-static int dax_dev_fault(struct vm_fault *vmf)
-{
-	struct vm_area_struct *vma = vmf->vma;
-	int rc;
-	struct file *filp = vma->vm_file;
-	struct dax_dev *dax_dev = filp->private_data;
-
-	dev_dbg(&dax_dev->dev, "%s: %s: %s (%#lx - %#lx)\n", __func__,
-			current->comm, (vmf->flags & FAULT_FLAG_WRITE)
-			? "write" : "read", vma->vm_start, vma->vm_end);
-	rcu_read_lock();
-	rc = __dax_dev_fault(dax_dev, vmf);
-	rcu_read_unlock();
-
-	return rc;
-}
-
 static int __dax_dev_pmd_fault(struct dax_dev *dax_dev, struct vm_fault *vmf)
 {
 	unsigned long pmd_addr = vmf->address & PMD_MASK;
@@ -510,7 +493,7 @@ static int __dax_dev_pmd_fault(struct dax_dev *dax_dev, struct vm_fault *vmf)
 			vmf->flags & FAULT_FLAG_WRITE);
 }
 
-static int dax_dev_pmd_fault(struct vm_fault *vmf)
+static int dax_dev_fault(struct vm_fault *vmf)
 {
 	int rc;
 	struct file *filp = vmf->vma->vm_file;
@@ -522,7 +505,16 @@ static int dax_dev_pmd_fault(struct vm_fault *vmf)
 			vmf->vma->vm_start, vmf->vma->vm_end);
 
 	rcu_read_lock();
-	rc = __dax_dev_pmd_fault(dax_dev, vmf);
+	switch (vmf->flags & FAULT_FLAG_SIZE_MASK) {
+	case FAULT_FLAG_SIZE_PTE:
+		rc = __dax_dev_pte_fault(dax_dev, vmf);
+		break;
+	case FAULT_FLAG_SIZE_PMD:
+		rc = __dax_dev_pmd_fault(dax_dev, vmf);
+		break;
+	default:
+		return VM_FAULT_FALLBACK;
+	}
 	rcu_read_unlock();
 
 	return rc;
@@ -530,7 +522,7 @@ static int dax_dev_pmd_fault(struct vm_fault *vmf)
 
 static const struct vm_operations_struct dax_dev_vm_ops = {
 	.fault = dax_dev_fault,
-	.pmd_fault = dax_dev_pmd_fault,
+	.huge_fault = dax_dev_fault,
 };
 
 static int dax_mmap(struct file *filp, struct vm_area_struct *vma)
diff --git a/fs/dax.c b/fs/dax.c
index 7877130..2e90f7a 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1110,16 +1110,7 @@ static int dax_fault_return(int error)
 	return VM_FAULT_SIGBUS;
 }
 
-/**
- * dax_iomap_fault - handle a page fault on a DAX file
- * @vmf: The description of the fault
- * @ops: iomap ops passed from the file system
- *
- * When a page fault occurs, filesystems may call this helper in their fault
- * or mkwrite handler for DAX files. Assumes the caller has done all the
- * necessary locking for the page fault to proceed successfully.
- */
-int dax_iomap_fault(struct vm_fault *vmf, struct iomap_ops *ops)
+static int dax_iomap_pte_fault(struct vm_fault *vmf, struct iomap_ops *ops)
 {
 	struct address_space *mapping = vmf->vma->vm_file->f_mapping;
 	struct inode *inode = mapping->host;
@@ -1236,7 +1227,6 @@ int dax_iomap_fault(struct vm_fault *vmf, struct iomap_ops *ops)
 	}
 	return vmf_ret;
 }
-EXPORT_SYMBOL_GPL(dax_iomap_fault);
 
 #ifdef CONFIG_FS_DAX_PMD
 /*
@@ -1327,7 +1317,7 @@ static int dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
 	return VM_FAULT_FALLBACK;
 }
 
-int dax_iomap_pmd_fault(struct vm_fault *vmf, struct iomap_ops *ops)
+static int dax_iomap_pmd_fault(struct vm_fault *vmf, struct iomap_ops *ops)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct address_space *mapping = vma->vm_file->f_mapping;
@@ -1435,6 +1425,33 @@ int dax_iomap_pmd_fault(struct vm_fault *vmf, struct iomap_ops *ops)
 	trace_dax_pmd_fault_done(inode, vmf, max_pgoff, result);
 	return result;
 }
-EXPORT_SYMBOL_GPL(dax_iomap_pmd_fault);
+#else
+static int dax_iomap_pmd_fault(struct vm_fault *vmf, struct iomap_ops *ops)
+{
+	return VM_FAULT_FALLBACK;
+}
 #endif /* CONFIG_FS_DAX_PMD */
+
+/**
+ * dax_iomap_fault - handle a page fault on a DAX file
+ * @vmf: The description of the fault
+ * @ops: iomap ops passed from the file system
+ *
+ * When a page fault occurs, filesystems may call this helper in
+ * their fault handler for DAX files. dax_iomap_fault() assumes the caller
+ * has done all the necessary locking for page fault to proceed
+ * successfully.
+ */
+int dax_iomap_fault(struct vm_fault *vmf, struct iomap_ops *ops)
+{
+	switch (vmf->flags & FAULT_FLAG_SIZE_MASK) {
+	case FAULT_FLAG_SIZE_PTE:
+		return dax_iomap_pte_fault(vmf, ops);
+	case FAULT_FLAG_SIZE_PMD:
+		return dax_iomap_pmd_fault(vmf, ops);
+	default:
+		return VM_FAULT_FALLBACK;
+	}
+}
+EXPORT_SYMBOL_GPL(dax_iomap_fault);
 #endif /* CONFIG_FS_IOMAP */
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index 0bf0d97..6873883 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -133,7 +133,7 @@ static int ext2_dax_pfn_mkwrite(struct vm_fault *vmf)
 static const struct vm_operations_struct ext2_dax_vm_ops = {
 	.fault		= ext2_dax_fault,
 	/*
-	 * .pmd_fault is not supported for DAX because allocation in ext2
+	 * .huge_fault is not supported for DAX because allocation in ext2
 	 * cannot be reliably aligned to huge page sizes and so pmd faults
 	 * will always fail and fail back to regular faults.
 	 */
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index cc0b111..ed22d20 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -276,7 +276,7 @@ static int ext4_dax_fault(struct vm_fault *vmf)
 }
 
 static int
-ext4_dax_pmd_fault(struct vm_fault *vmf)
+ext4_dax_huge_fault(struct vm_fault *vmf)
 {
 	int result;
 	struct inode *inode = file_inode(vmf->vma->vm_file);
@@ -288,7 +288,7 @@ ext4_dax_pmd_fault(struct vm_fault *vmf)
 		file_update_time(vmf->vma->vm_file);
 	}
 	down_read(&EXT4_I(inode)->i_mmap_sem);
-	result = dax_iomap_pmd_fault(vmf, &ext4_iomap_ops);
+	result = dax_iomap_fault(vmf, &ext4_iomap_ops);
 	up_read(&EXT4_I(inode)->i_mmap_sem);
 	if (write)
 		sb_end_pagefault(sb);
@@ -328,7 +328,7 @@ static int ext4_dax_pfn_mkwrite(struct vm_fault *vmf)
 
 static const struct vm_operations_struct ext4_dax_vm_ops = {
 	.fault		= ext4_dax_fault,
-	.pmd_fault	= ext4_dax_pmd_fault,
+	.huge_fault	= ext4_dax_fault,
 	.page_mkwrite	= ext4_dax_fault,
 	.pfn_mkwrite	= ext4_dax_pfn_mkwrite,
 };
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 34e04cf..c4fe261 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1423,12 +1423,12 @@ xfs_filemap_fault(
 /*
  * Similar to xfs_filemap_fault(), the DAX fault path can call into here on
  * both read and write faults. Hence we need to handle both cases. There is no
- * ->pmd_mkwrite callout for huge pages, so we have a single function here to
+ * ->huge_mkwrite callout for huge pages, so we have a single function here to
  * handle both cases here. @flags carries the information on the type of fault
  * occuring.
  */
 STATIC int
-xfs_filemap_pmd_fault(
+xfs_filemap_huge_fault(
 	struct vm_fault		*vmf)
 {
 	struct inode		*inode = file_inode(vmf->vma->vm_file);
@@ -1438,7 +1438,7 @@ xfs_filemap_pmd_fault(
 	if (!IS_DAX(inode))
 		return VM_FAULT_FALLBACK;
 
-	trace_xfs_filemap_pmd_fault(ip);
+	trace_xfs_filemap_huge_fault(ip);
 
 	if (vmf->flags & FAULT_FLAG_WRITE) {
 		sb_start_pagefault(inode->i_sb);
@@ -1446,7 +1446,7 @@ xfs_filemap_pmd_fault(
 	}
 
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
-	ret = dax_iomap_pmd_fault(vmf, &xfs_iomap_ops);
+	ret = dax_iomap_fault(vmf, &xfs_iomap_ops);
 	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 
 	if (vmf->flags & FAULT_FLAG_WRITE)
@@ -1491,7 +1491,7 @@ xfs_filemap_pfn_mkwrite(
 
 static const struct vm_operations_struct xfs_file_vm_ops = {
 	.fault		= xfs_filemap_fault,
-	.pmd_fault	= xfs_filemap_pmd_fault,
+	.huge_fault	= xfs_filemap_huge_fault,
 	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= xfs_filemap_page_mkwrite,
 	.pfn_mkwrite	= xfs_filemap_pfn_mkwrite,
diff --git a/fs/xfs/xfs_trace.h b/fs/xfs/xfs_trace.h
index 69c5bcd..719b1d4 100644
--- a/fs/xfs/xfs_trace.h
+++ b/fs/xfs/xfs_trace.h
@@ -687,7 +687,7 @@ DEFINE_INODE_EVENT(xfs_inode_clear_cowblocks_tag);
 DEFINE_INODE_EVENT(xfs_inode_free_cowblocks_invalid);
 
 DEFINE_INODE_EVENT(xfs_filemap_fault);
-DEFINE_INODE_EVENT(xfs_filemap_pmd_fault);
+DEFINE_INODE_EVENT(xfs_filemap_huge_fault);
 DEFINE_INODE_EVENT(xfs_filemap_page_mkwrite);
 DEFINE_INODE_EVENT(xfs_filemap_pfn_mkwrite);
 
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 4417700..a3bfa26 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -70,17 +70,11 @@ static inline unsigned int dax_radix_order(void *entry)
 		return PMD_SHIFT - PAGE_SHIFT;
 	return 0;
 }
-int dax_iomap_pmd_fault(struct vm_fault *vmf, struct iomap_ops *ops);
 #else
 static inline unsigned int dax_radix_order(void *entry)
 {
 	return 0;
 }
-static inline int dax_iomap_pmd_fault(struct vm_fault *vmf,
-		struct iomap_ops *ops)
-{
-	return VM_FAULT_FALLBACK;
-}
 #endif
 int dax_pfn_mkwrite(struct vm_fault *vmf);
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 135cc74..19d6f71 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -281,6 +281,11 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
 #define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
 
+#define FAULT_FLAG_SIZE_MASK	0x700	/* Support up to 8-level page tables */
+#define FAULT_FLAG_SIZE_PTE	0x000	/* First level (eg 4k) */
+#define FAULT_FLAG_SIZE_PMD	0x100	/* Second level (eg 2MB) */
+#define FAULT_FLAG_SIZE_PUD	0x200	/* Third level (eg 1GB) */
+
 #define FAULT_FLAG_TRACE \
 	{ FAULT_FLAG_WRITE,		"WRITE" }, \
 	{ FAULT_FLAG_MKWRITE,		"MKWRITE" }, \
@@ -310,6 +315,9 @@ struct vm_fault {
 	unsigned long address;		/* Faulting virtual address */
 	pmd_t *pmd;			/* Pointer to pmd entry matching
 					 * the 'address' */
+	pud_t *pud;			/* Pointer to pud entry matching
+					 * the 'address'
+					 */
 	pte_t orig_pte;			/* Value of PTE at the time of fault */
 
 	struct page *cow_page;		/* Page handler may use for COW fault */
@@ -347,7 +355,7 @@ struct vm_operations_struct {
 	void (*close)(struct vm_area_struct * area);
 	int (*mremap)(struct vm_area_struct * area);
 	int (*fault)(struct vm_fault *vmf);
-	int (*pmd_fault)(struct vm_fault *vmf);
+	int (*huge_fault)(struct vm_fault *vmf);
 	void (*map_pages)(struct vm_fault *vmf,
 			pgoff_t start_pgoff, pgoff_t end_pgoff);
 
diff --git a/mm/memory.c b/mm/memory.c
index 11f11ae..a2acf9e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3473,8 +3473,8 @@ static int create_huge_pmd(struct vm_fault *vmf)
 {
 	if (vma_is_anonymous(vmf->vma))
 		return do_huge_pmd_anonymous_page(vmf);
-	if (vmf->vma->vm_ops->pmd_fault)
-		return vmf->vma->vm_ops->pmd_fault(vmf);
+	if (vmf->vma->vm_ops->huge_fault)
+		return vmf->vma->vm_ops->huge_fault(vmf);
 	return VM_FAULT_FALLBACK;
 }
 
@@ -3482,8 +3482,8 @@ static int wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
 {
 	if (vma_is_anonymous(vmf->vma))
 		return do_huge_pmd_wp_page(vmf, orig_pmd);
-	if (vmf->vma->vm_ops->pmd_fault)
-		return vmf->vma->vm_ops->pmd_fault(vmf);
+	if (vmf->vma->vm_ops->huge_fault)
+		return vmf->vma->vm_ops->huge_fault(vmf);
 
 	/* COW handled on pte level: split pmd */
 	VM_BUG_ON_VMA(vmf->vma->vm_flags & VM_SHARED, vmf->vma);
@@ -3613,6 +3613,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
 	pud_t *pud;
+	int ret;
 
 	pgd = pgd_offset(mm, address);
 	pud = pud_alloc(mm, pgd, address);
@@ -3622,15 +3623,16 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	if (!vmf.pmd)
 		return VM_FAULT_OOM;
 	if (pmd_none(*vmf.pmd) && transparent_hugepage_enabled(vma)) {
-		int ret = create_huge_pmd(&vmf);
+		vmf.flags |= FAULT_FLAG_SIZE_PMD;
+		ret = create_huge_pmd(&vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
 	} else {
 		pmd_t orig_pmd = *vmf.pmd;
-		int ret;
 
 		barrier();
 		if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
+			vmf.flags |= FAULT_FLAG_SIZE_PMD;
 			if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
 				return do_huge_pmd_numa_page(&vmf, orig_pmd);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
