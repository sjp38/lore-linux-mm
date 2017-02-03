Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E53626B0033
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 16:31:24 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id v184so36641272pgv.6
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 13:31:24 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id p10si9720555pge.292.2017.02.03.13.31.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Feb 2017 13:31:23 -0800 (PST)
Subject: [PATCH] mm: replace FAULT_FLAG_SIZE with parameter to huge_fault
From: Dave Jiang <dave.jiang@intel.com>
Date: Fri, 03 Feb 2017 14:31:22 -0700
Message-ID: <148615748258.43180.1690152053774975329.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mawilcox@microsoft.com, linux-nvdimm@lists.01.org, dave.hansen@linux.intel.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, jack@suse.com, dan.j.williams@intel.com, linux-ext4@vger.kernel.org, ross.zwisler@linux.intel.com, vbabka@suse.cz

Since the introduction of FAULT_FLAG_SIZE to the vm_fault flag, it has
been somewhat painful with getting the flags set and removed at the
correct locations. More than one kernel oops was introduced due to
difficulties of getting the placement correctly. Removing the flag
values and introducing an input parameter to huge_fault that indicates
the size of the page entry. This makes the code easier to trace and
should avoid the issues we see with the fault flags where removal of the
flag was necessary in the fallback paths.

Signed-off-by: Dave Jiang <dave.jiang@intel.com>
---
 drivers/dax/dax.c   |   18 ++++++++++++------
 fs/dax.c            |    9 +++++----
 fs/ext2/file.c      |    2 +-
 fs/ext4/file.c      |   12 +++++++++---
 fs/xfs/xfs_file.c   |    9 +++++----
 include/linux/dax.h |    3 ++-
 include/linux/mm.h  |   14 ++++++++------
 mm/memory.c         |   17 ++++-------------
 8 files changed, 46 insertions(+), 38 deletions(-)

diff --git a/drivers/dax/dax.c b/drivers/dax/dax.c
index b90bb30..b75c772 100644
--- a/drivers/dax/dax.c
+++ b/drivers/dax/dax.c
@@ -538,7 +538,8 @@ static int __dax_dev_pud_fault(struct dax_dev *dax_dev, struct vm_fault *vmf)
 }
 #endif /* !CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
 
-static int dax_dev_fault(struct vm_fault *vmf)
+static int dax_dev_huge_fault(struct vm_fault *vmf,
+		enum page_entry_size pe_size)
 {
 	int rc;
 	struct file *filp = vmf->vma->vm_file;
@@ -550,14 +551,14 @@ static int dax_dev_fault(struct vm_fault *vmf)
 			vmf->vma->vm_start, vmf->vma->vm_end);
 
 	rcu_read_lock();
-	switch (vmf->flags & FAULT_FLAG_SIZE_MASK) {
-	case FAULT_FLAG_SIZE_PTE:
+	switch (pe_size) {
+	case PE_SIZE_PTE:
 		rc = __dax_dev_pte_fault(dax_dev, vmf);
 		break;
-	case FAULT_FLAG_SIZE_PMD:
+	case PE_SIZE_PMD:
 		rc = __dax_dev_pmd_fault(dax_dev, vmf);
 		break;
-	case FAULT_FLAG_SIZE_PUD:
+	case PE_SIZE_PUD:
 		rc = __dax_dev_pud_fault(dax_dev, vmf);
 		break;
 	default:
@@ -568,9 +569,14 @@ static int dax_dev_fault(struct vm_fault *vmf)
 	return rc;
 }
 
+static int dax_dev_fault(struct vm_fault *vmf)
+{
+	return dax_dev_huge_fault(vmf, PE_SIZE_PTE);
+}
+
 static const struct vm_operations_struct dax_dev_vm_ops = {
 	.fault = dax_dev_fault,
-	.huge_fault = dax_dev_fault,
+	.huge_fault = dax_dev_huge_fault,
 };
 
 static int dax_mmap(struct file *filp, struct vm_area_struct *vma)
diff --git a/fs/dax.c b/fs/dax.c
index 25f791d..97b8ecb 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1446,12 +1446,13 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, struct iomap_ops *ops)
  * has done all the necessary locking for page fault to proceed
  * successfully.
  */
-int dax_iomap_fault(struct vm_fault *vmf, struct iomap_ops *ops)
+int dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
+		struct iomap_ops *ops)
 {
-	switch (vmf->flags & FAULT_FLAG_SIZE_MASK) {
-	case FAULT_FLAG_SIZE_PTE:
+	switch (pe_size) {
+	case PE_SIZE_PTE:
 		return dax_iomap_pte_fault(vmf, ops);
-	case FAULT_FLAG_SIZE_PMD:
+	case PE_SIZE_PMD:
 		return dax_iomap_pmd_fault(vmf, ops);
 	default:
 		return VM_FAULT_FALLBACK;
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index 6873883..b21891a 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -99,7 +99,7 @@ static int ext2_dax_fault(struct vm_fault *vmf)
 	}
 	down_read(&ei->dax_sem);
 
-	ret = dax_iomap_fault(vmf, &ext2_iomap_ops);
+	ret = dax_iomap_fault(vmf, PE_SIZE_PTE, &ext2_iomap_ops);
 
 	up_read(&ei->dax_sem);
 	if (vmf->flags & FAULT_FLAG_WRITE)
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 51d7155..e8ab46e 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -255,7 +255,8 @@ ext4_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 }
 
 #ifdef CONFIG_FS_DAX
-static int ext4_dax_fault(struct vm_fault *vmf)
+static int ext4_dax_huge_fault(struct vm_fault *vmf,
+		enum page_entry_size pe_size)
 {
 	int result;
 	struct inode *inode = file_inode(vmf->vma->vm_file);
@@ -267,7 +268,7 @@ static int ext4_dax_fault(struct vm_fault *vmf)
 		file_update_time(vmf->vma->vm_file);
 	}
 	down_read(&EXT4_I(inode)->i_mmap_sem);
-	result = dax_iomap_fault(vmf, &ext4_iomap_ops);
+	result = dax_iomap_fault(vmf, pe_size, &ext4_iomap_ops);
 	up_read(&EXT4_I(inode)->i_mmap_sem);
 	if (write)
 		sb_end_pagefault(sb);
@@ -275,6 +276,11 @@ static int ext4_dax_fault(struct vm_fault *vmf)
 	return result;
 }
 
+static int ext4_dax_fault(struct vm_fault *vmf)
+{
+	return ext4_dax_huge_fault(vmf, PE_SIZE_PTE);
+}
+
 /*
  * Handle write fault for VM_MIXEDMAP mappings. Similarly to ext4_dax_fault()
  * handler we check for races agaist truncate. Note that since we cycle through
@@ -307,7 +313,7 @@ static int ext4_dax_pfn_mkwrite(struct vm_fault *vmf)
 
 static const struct vm_operations_struct ext4_dax_vm_ops = {
 	.fault		= ext4_dax_fault,
-	.huge_fault	= ext4_dax_fault,
+	.huge_fault	= ext4_dax_huge_fault,
 	.page_mkwrite	= ext4_dax_fault,
 	.pfn_mkwrite	= ext4_dax_pfn_mkwrite,
 };
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index c4fe261..c37f435 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1385,7 +1385,7 @@ xfs_filemap_page_mkwrite(
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 
 	if (IS_DAX(inode)) {
-		ret = dax_iomap_fault(vmf, &xfs_iomap_ops);
+		ret = dax_iomap_fault(vmf, PE_SIZE_PTE, &xfs_iomap_ops);
 	} else {
 		ret = iomap_page_mkwrite(vmf, &xfs_iomap_ops);
 		ret = block_page_mkwrite_return(ret);
@@ -1412,7 +1412,7 @@ xfs_filemap_fault(
 
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 	if (IS_DAX(inode))
-		ret = dax_iomap_fault(vmf, &xfs_iomap_ops);
+		ret = dax_iomap_fault(vmf, PE_SIZE_PTE, &xfs_iomap_ops);
 	else
 		ret = filemap_fault(vmf);
 	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
@@ -1429,7 +1429,8 @@ xfs_filemap_fault(
  */
 STATIC int
 xfs_filemap_huge_fault(
-	struct vm_fault		*vmf)
+	struct vm_fault		*vmf,
+	enum page_entry_size	pe_size)
 {
 	struct inode		*inode = file_inode(vmf->vma->vm_file);
 	struct xfs_inode	*ip = XFS_I(inode);
@@ -1446,7 +1447,7 @@ xfs_filemap_huge_fault(
 	}
 
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
-	ret = dax_iomap_fault(vmf, &xfs_iomap_ops);
+	ret = dax_iomap_fault(vmf, pe_size, &xfs_iomap_ops);
 	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 
 	if (vmf->flags & FAULT_FLAG_WRITE)
diff --git a/include/linux/dax.h b/include/linux/dax.h
index a3bfa26..df63730 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -38,7 +38,8 @@ static inline void *dax_radix_locked_entry(sector_t sector, unsigned long flags)
 
 ssize_t dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
 		struct iomap_ops *ops);
-int dax_iomap_fault(struct vm_fault *vmf, struct iomap_ops *ops);
+int dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
+		struct iomap_ops *ops);
 int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index);
 int dax_invalidate_mapping_entry(struct address_space *mapping, pgoff_t index);
 int dax_invalidate_mapping_entry_sync(struct address_space *mapping,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7646ae5..7b11431 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -285,11 +285,6 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
 #define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
 
-#define FAULT_FLAG_SIZE_MASK	0x7000	/* Support up to 8-level page tables */
-#define FAULT_FLAG_SIZE_PTE	0x0000	/* First level (eg 4k) */
-#define FAULT_FLAG_SIZE_PMD	0x1000	/* Second level (eg 2MB) */
-#define FAULT_FLAG_SIZE_PUD	0x2000	/* Third level (eg 1GB) */
-
 #define FAULT_FLAG_TRACE \
 	{ FAULT_FLAG_WRITE,		"WRITE" }, \
 	{ FAULT_FLAG_MKWRITE,		"MKWRITE" }, \
@@ -349,6 +344,13 @@ struct vm_fault {
 					 */
 };
 
+/* page entry size for vm->huge_fault() */
+enum page_entry_size {
+	PE_SIZE_PTE = 0,
+	PE_SIZE_PMD,
+	PE_SIZE_PUD,
+};
+
 /*
  * These are the virtual MM functions - opening of an area, closing and
  * unmapping it (needed to keep files on disk up-to-date etc), pointer
@@ -359,7 +361,7 @@ struct vm_operations_struct {
 	void (*close)(struct vm_area_struct * area);
 	int (*mremap)(struct vm_area_struct * area);
 	int (*fault)(struct vm_fault *vmf);
-	int (*huge_fault)(struct vm_fault *vmf);
+	int (*huge_fault)(struct vm_fault *vmf, enum page_entry_size pe_size);
 	void (*map_pages)(struct vm_fault *vmf,
 			pgoff_t start_pgoff, pgoff_t end_pgoff);
 
diff --git a/mm/memory.c b/mm/memory.c
index 41e2a2d..6040b74 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3489,7 +3489,7 @@ static int create_huge_pmd(struct vm_fault *vmf)
 	if (vma_is_anonymous(vmf->vma))
 		return do_huge_pmd_anonymous_page(vmf);
 	if (vmf->vma->vm_ops->huge_fault)
-		return vmf->vma->vm_ops->huge_fault(vmf);
+		return vmf->vma->vm_ops->huge_fault(vmf, PE_SIZE_PMD);
 	return VM_FAULT_FALLBACK;
 }
 
@@ -3498,7 +3498,7 @@ static int wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
 	if (vma_is_anonymous(vmf->vma))
 		return do_huge_pmd_wp_page(vmf, orig_pmd);
 	if (vmf->vma->vm_ops->huge_fault)
-		return vmf->vma->vm_ops->huge_fault(vmf);
+		return vmf->vma->vm_ops->huge_fault(vmf, PE_SIZE_PMD);
 
 	/* COW handled on pte level: split pmd */
 	VM_BUG_ON_VMA(vmf->vma->vm_flags & VM_SHARED, vmf->vma);
@@ -3519,7 +3519,7 @@ static int create_huge_pud(struct vm_fault *vmf)
 	if (vma_is_anonymous(vmf->vma))
 		return VM_FAULT_FALLBACK;
 	if (vmf->vma->vm_ops->huge_fault)
-		return vmf->vma->vm_ops->huge_fault(vmf);
+		return vmf->vma->vm_ops->huge_fault(vmf, PE_SIZE_PUD);
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 	return VM_FAULT_FALLBACK;
 }
@@ -3531,7 +3531,7 @@ static int wp_huge_pud(struct vm_fault *vmf, pud_t orig_pud)
 	if (vma_is_anonymous(vmf->vma))
 		return VM_FAULT_FALLBACK;
 	if (vmf->vma->vm_ops->huge_fault)
-		return vmf->vma->vm_ops->huge_fault(vmf);
+		return vmf->vma->vm_ops->huge_fault(vmf, PE_SIZE_PUD);
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 	return VM_FAULT_FALLBACK;
 }
@@ -3659,7 +3659,6 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	if (!vmf.pud)
 		return VM_FAULT_OOM;
 	if (pud_none(*vmf.pud) && transparent_hugepage_enabled(vma)) {
-		vmf.flags |= FAULT_FLAG_SIZE_PUD;
 		ret = create_huge_pud(&vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
@@ -3670,8 +3669,6 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		if (pud_trans_huge(orig_pud) || pud_devmap(orig_pud)) {
 			unsigned int dirty = flags & FAULT_FLAG_WRITE;
 
-			vmf.flags |= FAULT_FLAG_SIZE_PUD;
-
 			/* NUMA case for anonymous PUDs would go here */
 
 			if (dirty && !pud_write(orig_pud)) {
@@ -3689,18 +3686,14 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	if (!vmf.pmd)
 		return VM_FAULT_OOM;
 	if (pmd_none(*vmf.pmd) && transparent_hugepage_enabled(vma)) {
-		vmf.flags |= FAULT_FLAG_SIZE_PMD;
 		ret = create_huge_pmd(&vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
-		/* fall through path, remove PMD flag */
-		vmf.flags &= ~FAULT_FLAG_SIZE_PMD;
 	} else {
 		pmd_t orig_pmd = *vmf.pmd;
 
 		barrier();
 		if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
-			vmf.flags |= FAULT_FLAG_SIZE_PMD;
 			if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
 				return do_huge_pmd_numa_page(&vmf, orig_pmd);
 
@@ -3709,8 +3702,6 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 				ret = wp_huge_pmd(&vmf, orig_pmd);
 				if (!(ret & VM_FAULT_FALLBACK))
 					return ret;
-				/* fall through path, remove PUD flag */
-				vmf.flags &= ~FAULT_FLAG_SIZE_PUD;
 			} else {
 				huge_pmd_set_accessed(&vmf, orig_pmd);
 				return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
