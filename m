Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 299DA6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 17:01:53 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id yy13so110867038pab.3
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 14:01:53 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id 134si3763676pfb.15.2016.01.04.14.01.51
        for <linux-mm@kvack.org>;
        Mon, 04 Jan 2016 14:01:51 -0800 (PST)
Date: Mon, 4 Jan 2016 17:01:45 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH 7/8] xfs: Support for transparent PUD pages
Message-ID: <20160104220145.GB27351@linux.intel.com>
References: <1450974037-24775-1-git-send-email-matthew.r.wilcox@intel.com>
 <1450974037-24775-8-git-send-email-matthew.r.wilcox@intel.com>
 <20151230233007.GA6682@dastard>
 <20160102164309.GK2457@linux.intel.com>
 <20160103203356.GD6682@dastard>
 <20160104204121.GD13515@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160104204121.GD13515@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On Mon, Jan 04, 2016 at 10:41:21PM +0200, Kirill A. Shutemov wrote:
> On Mon, Jan 04, 2016 at 07:33:56AM +1100, Dave Chinner wrote:
> > Then in __dax_fault() you can check vmf->flags and call the
> > appropriate __dax_p{te,md,ud}_fault function, all without the
> > filesystem having to care about the different fault types. Similar
> > can be done with filemap_fault() - if it gets pmd/pud fault flags
> > set it can just reject them as they should never occur right now...
> 
> I think the first 4 patches of my hugetmpfs RFD patchset[1] are relevant
> here. Looks like it shouldn't be a big deal to extend the approach to
> cover DAX case.

Here's what I've currently got.

I can't quite see how to unify the XFS fault & huge_fault handlers yet.
Dave, did you want to do that piece?

DAX now has one dax_fault handler; no __ variations since all callers
were using the __, we can just drop the unused wrappers.

This patch is relative to the patchset I put out before, so there's a lot
of deleting the PUD cases that I had put in.  I'll resplit it for merging.

diff --git a/Documentation/filesystems/dax.txt b/Documentation/filesystems/dax.txt
index 7bde640..7c613fa 100644
--- a/Documentation/filesystems/dax.txt
+++ b/Documentation/filesystems/dax.txt
@@ -49,6 +49,7 @@ These block devices may be used for inspiration:
 - axonram: Axon DDR2 device driver
 - brd: RAM backed block device driver
 - dcssblk: s390 dcss block device driver
+- pmem: NV-DIMM Persistent Memory driver
 
 
 Implementation Tips for Filesystem Writers
@@ -61,9 +62,9 @@ Filesystem support consists of
   dax_do_io() instead of blockdev_direct_IO() if S_DAX is set
 - implementing an mmap file operation for DAX files which sets the
   VM_MIXEDMAP and VM_HUGEPAGE flags on the VMA, and setting the vm_ops to
-  include handlers for fault, pmd_fault and page_mkwrite (which should
-  probably call dax_fault(), dax_pmd_fault() and dax_mkwrite(), passing the
-  appropriate get_block() callback)
+  include handlers for fault, huge_fault and page_mkwrite (which should
+  probably call dax_fault(), and dax_mkwrite(), passing the appropriate
+  get_block() callback)
 - calling dax_truncate_page() instead of block_truncate_page() for DAX files
 - calling dax_zero_page_range() instead of zero_user() for DAX files
 - ensuring that there is sufficient locking between reads, writes,
@@ -77,6 +78,7 @@ or a write()) work correctly.
 These filesystems may be used for inspiration:
 - ext2: the second extended filesystem, see Documentation/filesystems/ext2.txt
 - ext4: the fourth extended filesystem, see Documentation/filesystems/ext4.txt
+- xfs: see Documentation/filesystems/xfs.txt
 
 
 Shortcomings
diff --git a/fs/block_dev.c b/fs/block_dev.c
index ed73fdf..3be3149 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -1730,19 +1730,7 @@ static const struct address_space_operations def_blk_aops = {
  */
 static int blkdev_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	return __dax_fault(vma, vmf, blkdev_get_block, NULL);
-}
-
-static int blkdev_dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
-		pmd_t *pmd, unsigned int flags)
-{
-	return __dax_pmd_fault(vma, addr, pmd, flags, blkdev_get_block, NULL);
-}
-
-static int blkdev_dax_pud_fault(struct vm_area_struct *vma, unsigned long addr,
-		pud_t *pud, unsigned int flags)
-{
-	return __dax_pud_fault(vma, addr, pud, flags, blkdev_get_block, NULL);
+	return dax_fault(vma, vmf, blkdev_get_block, NULL);
 }
 
 static void blkdev_vm_open(struct vm_area_struct *vma)
@@ -1769,8 +1757,7 @@ static const struct vm_operations_struct blkdev_dax_vm_ops = {
 	.open		= blkdev_vm_open,
 	.close		= blkdev_vm_close,
 	.fault		= blkdev_dax_fault,
-	.pmd_fault	= blkdev_dax_pmd_fault,
-	.pud_fault	= blkdev_dax_pud_fault,
+	.huge_fault	= blkdev_dax_fault,
 	.pfn_mkwrite	= blkdev_dax_fault,
 };
 
diff --git a/fs/dax.c b/fs/dax.c
index 63ca298..49bede0 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -370,23 +370,7 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	return error;
 }
 
-/**
- * __dax_fault - handle a page fault on a DAX file
- * @vma: The virtual memory area where the fault occurred
- * @vmf: The description of the fault
- * @get_block: The filesystem method used to translate file offsets to blocks
- * @complete_unwritten: The filesystem method used to convert unwritten blocks
- *	to written so the data written to them is exposed. This is required for
- *	required by write faults for filesystems that will return unwritten
- *	extent mappings from @get_block, but it is optional for reads as
- *	dax_insert_mapping() will always zero unwritten blocks. If the fs does
- *	not support unwritten extents, the it should pass NULL.
- *
- * When a page fault occurs, filesystems may call this helper in their
- * fault handler for DAX files. __dax_fault() assumes the caller has done all
- * the necessary locking for the page fault to proceed successfully.
- */
-int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
+static int dax_pte_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 			get_block_t get_block, dax_iodone_t complete_unwritten)
 {
 	struct file *file = vma->vm_file;
@@ -521,34 +505,6 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	}
 	goto out;
 }
-EXPORT_SYMBOL(__dax_fault);
-
-/**
- * dax_fault - handle a page fault on a DAX file
- * @vma: The virtual memory area where the fault occurred
- * @vmf: The description of the fault
- * @get_block: The filesystem method used to translate file offsets to blocks
- *
- * When a page fault occurs, filesystems may call this helper in their
- * fault handler for DAX files.
- */
-int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
-	      get_block_t get_block, dax_iodone_t complete_unwritten)
-{
-	int result;
-	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
-
-	if (vmf->flags & FAULT_FLAG_WRITE) {
-		sb_start_pagefault(sb);
-		file_update_time(vma->vm_file);
-	}
-	result = __dax_fault(vma, vmf, get_block, complete_unwritten);
-	if (vmf->flags & FAULT_FLAG_WRITE)
-		sb_end_pagefault(sb);
-
-	return result;
-}
-EXPORT_SYMBOL_GPL(dax_fault);
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 /*
@@ -575,7 +531,7 @@ static void __dax_dbg(struct buffer_head *bh, unsigned long address,
 
 #define dax_pmd_dbg(bh, address, reason)	__dax_dbg(bh, address, reason, "dax_pmd")
 
-int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
+static int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		pmd_t *pmd, unsigned int flags, get_block_t get_block,
 		dax_iodone_t complete_unwritten)
 {
@@ -753,36 +709,14 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	result = VM_FAULT_FALLBACK;
 	goto out;
 }
-EXPORT_SYMBOL_GPL(__dax_pmd_fault);
-
-/**
- * dax_pmd_fault - handle a PMD fault on a DAX file
- * @vma: The virtual memory area where the fault occurred
- * @vmf: The description of the fault
- * @get_block: The filesystem method used to translate file offsets to blocks
- *
- * When a page fault occurs, filesystems may call this helper in their
- * pmd_fault handler for DAX files.
- */
-int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
-			pmd_t *pmd, unsigned int flags, get_block_t get_block,
-			dax_iodone_t complete_unwritten)
+#else /* !CONFIG_TRANSPARENT_HUGEPAGE */
+static int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
+		pmd_t *pmd, unsigned int flags, get_block_t get_block,
+		dax_iodone_t complete_unwritten)
 {
-	int result;
-	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
-
-	if (flags & FAULT_FLAG_WRITE) {
-		sb_start_pagefault(sb);
-		file_update_time(vma->vm_file);
-	}
-	result = __dax_pmd_fault(vma, address, pmd, flags, get_block,
-				complete_unwritten);
-	if (flags & FAULT_FLAG_WRITE)
-		sb_end_pagefault(sb);
-
-	return result;
+	return VM_FAULT_FALLBACK;
 }
-EXPORT_SYMBOL_GPL(dax_pmd_fault);
+#endif /* !CONFIG_TRANSPARENT_HUGEPAGE */
 
 #ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
 /*
@@ -793,7 +727,7 @@ EXPORT_SYMBOL_GPL(dax_pmd_fault);
 
 #define dax_pud_dbg(bh, address, reason)	__dax_dbg(bh, address, reason, "dax_pud")
 
-int __dax_pud_fault(struct vm_area_struct *vma, unsigned long address,
+static int dax_pud_fault(struct vm_area_struct *vma, unsigned long address,
 		pud_t *pud, unsigned int flags, get_block_t get_block,
 		dax_iodone_t complete_unwritten)
 {
@@ -947,38 +881,52 @@ int __dax_pud_fault(struct vm_area_struct *vma, unsigned long address,
 	result = VM_FAULT_FALLBACK;
 	goto out;
 }
-EXPORT_SYMBOL_GPL(__dax_pud_fault);
+#else /* !CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
+static int dax_pud_fault(struct vm_area_struct *vma, unsigned long address,
+		pud_t *pud, unsigned int flags, get_block_t get_block,
+		dax_iodone_t complete_unwritten)
+{
+	return VM_FAULT_FALLBACK;
+}
+#endif /* !CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
 
 /**
- * dax_pud_fault - handle a PUD fault on a DAX file
+ * dax_fault - handle a page fault on a DAX file
  * @vma: The virtual memory area where the fault occurred
  * @vmf: The description of the fault
  * @get_block: The filesystem method used to translate file offsets to blocks
+ * @iodone: The filesystem method used to convert unwritten blocks
+ *	to written so the data written to them is exposed. This is required
+ *	by write faults for filesystems that will return unwritten extent
+ *	mappings from @get_block, but it is optional for reads as
+ *	dax_insert_mapping() will always zero unwritten blocks. If the fs
+ *	does not support unwritten extents, then it should pass NULL.
  *
  * When a page fault occurs, filesystems may call this helper in their
- * pud_fault handler for DAX files.
+ * fault handler for DAX files.  dax_fault() assumes the caller has done all
+ * the necessary locking for the page fault to proceed successfully.
  */
-int dax_pud_fault(struct vm_area_struct *vma, unsigned long address,
-			pud_t *pud, unsigned int flags, get_block_t get_block,
-			dax_iodone_t complete_unwritten)
+int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
+			get_block_t get_block, dax_iodone_t iodone)
 {
-	int result;
-	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
-
-	if (flags & FAULT_FLAG_WRITE) {
-		sb_start_pagefault(sb);
-		file_update_time(vma->vm_file);
+	unsigned long address = (unsigned long)vmf->virtual_address;
+	switch (vmf->flags & FAULT_FLAG_SIZE_MASK) {
+	case FAULT_FLAG_SIZE_PTE:
+		return dax_pte_fault(vma, vmf, get_block, iodone);
+	case FAULT_FLAG_SIZE_PMD:
+		return dax_pmd_fault(vma, address, vmf->pmd, vmf->flags,
+						get_block, iodone);
+	case FAULT_FLAG_SIZE_PUD:
+		return dax_pud_fault(vma, address, vmf->pud, vmf->flags,
+						get_block, iodone);
+	default:
+		printk(KERN_EMERG "%s: Unknown page size.  Flags %x\n",
+						__func__, vmf->flags);
+		VM_BUG_ON_VMA(1, vma);
+		return VM_FAULT_SIGBUS;
 	}
-	result = __dax_pud_fault(vma, address, pud, flags, get_block,
-				complete_unwritten);
-	if (flags & FAULT_FLAG_WRITE)
-		sb_end_pagefault(sb);
-
-	return result;
 }
-EXPORT_SYMBOL_GPL(dax_pud_fault);
-#endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+EXPORT_SYMBOL_GPL(dax_fault);
 
 /**
  * dax_pfn_mkwrite - handle first write to DAX page
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index 11a42c5..ad0a57a 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -51,7 +51,7 @@ static int ext2_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	}
 	down_read(&ei->dax_sem);
 
-	ret = __dax_fault(vma, vmf, ext2_get_block, NULL);
+	ret = dax_fault(vma, vmf, ext2_get_block, NULL);
 
 	up_read(&ei->dax_sem);
 	if (vmf->flags & FAULT_FLAG_WRITE)
@@ -59,27 +59,6 @@ static int ext2_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return ret;
 }
 
-static int ext2_dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
-						pmd_t *pmd, unsigned int flags)
-{
-	struct inode *inode = file_inode(vma->vm_file);
-	struct ext2_inode_info *ei = EXT2_I(inode);
-	int ret;
-
-	if (flags & FAULT_FLAG_WRITE) {
-		sb_start_pagefault(inode->i_sb);
-		file_update_time(vma->vm_file);
-	}
-	down_read(&ei->dax_sem);
-
-	ret = __dax_pmd_fault(vma, addr, pmd, flags, ext2_get_block, NULL);
-
-	up_read(&ei->dax_sem);
-	if (flags & FAULT_FLAG_WRITE)
-		sb_end_pagefault(inode->i_sb);
-	return ret;
-}
-
 static int ext2_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct inode *inode = file_inode(vma->vm_file);
@@ -90,7 +69,7 @@ static int ext2_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	file_update_time(vma->vm_file);
 	down_read(&ei->dax_sem);
 
-	ret = __dax_mkwrite(vma, vmf, ext2_get_block, NULL);
+	ret = dax_mkwrite(vma, vmf, ext2_get_block, NULL);
 
 	up_read(&ei->dax_sem);
 	sb_end_pagefault(inode->i_sb);
@@ -121,7 +100,7 @@ static int ext2_dax_pfn_mkwrite(struct vm_area_struct *vma,
 
 static const struct vm_operations_struct ext2_dax_vm_ops = {
 	.fault		= ext2_dax_fault,
-	.pmd_fault	= ext2_dax_pmd_fault,
+	.huge_fault	= ext2_dax_fault,
 	.page_mkwrite	= ext2_dax_mkwrite,
 	.pfn_mkwrite	= ext2_dax_pfn_mkwrite,
 };
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index b0cba51..5eda31e 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -202,90 +202,31 @@ static int ext4_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	bool write = vmf->flags & FAULT_FLAG_WRITE;
 
 	if (write) {
-		sb_start_pagefault(sb);
-		file_update_time(vma->vm_file);
-		down_read(&EXT4_I(inode)->i_mmap_sem);
-		handle = ext4_journal_start_sb(sb, EXT4_HT_WRITE_PAGE,
-						EXT4_DATA_TRANS_BLOCKS(sb));
-	} else
-		down_read(&EXT4_I(inode)->i_mmap_sem);
-
-	if (IS_ERR(handle))
-		result = VM_FAULT_SIGBUS;
-	else
-		result = __dax_fault(vma, vmf, ext4_dax_mmap_get_block, NULL);
-
-	if (write) {
-		if (!IS_ERR(handle))
-			ext4_journal_stop(handle);
-		up_read(&EXT4_I(inode)->i_mmap_sem);
-		sb_end_pagefault(sb);
-	} else
-		up_read(&EXT4_I(inode)->i_mmap_sem);
-
-	return result;
-}
-
-static int ext4_dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
-						pmd_t *pmd, unsigned int flags)
-{
-	int result;
-	handle_t *handle = NULL;
-	struct inode *inode = file_inode(vma->vm_file);
-	struct super_block *sb = inode->i_sb;
-	bool write = flags & FAULT_FLAG_WRITE;
-
-	if (write) {
-		sb_start_pagefault(sb);
-		file_update_time(vma->vm_file);
-		down_read(&EXT4_I(inode)->i_mmap_sem);
-		handle = ext4_journal_start_sb(sb, EXT4_HT_WRITE_PAGE,
-				ext4_chunk_trans_blocks(inode,
-							PMD_SIZE / PAGE_SIZE));
-	} else
-		down_read(&EXT4_I(inode)->i_mmap_sem);
-
-	if (IS_ERR(handle))
-		result = VM_FAULT_SIGBUS;
-	else
-		result = __dax_pmd_fault(vma, addr, pmd, flags,
-				ext4_dax_mmap_get_block, NULL);
-
-	if (write) {
-		if (!IS_ERR(handle))
-			ext4_journal_stop(handle);
-		up_read(&EXT4_I(inode)->i_mmap_sem);
-		sb_end_pagefault(sb);
-	} else
-		up_read(&EXT4_I(inode)->i_mmap_sem);
-
-	return result;
-}
-
-static int ext4_dax_pud_fault(struct vm_area_struct *vma, unsigned long addr,
-						pud_t *pud, unsigned int flags)
-{
-	int result;
-	handle_t *handle = NULL;
-	struct inode *inode = file_inode(vma->vm_file);
-	struct super_block *sb = inode->i_sb;
-	bool write = flags & FAULT_FLAG_WRITE;
+		unsigned nblocks = EXT4_DATA_TRANS_BLOCKS(sb);
+		switch (vmf->flags & FAULT_FLAG_SIZE_MASK) {
+		case FAULT_FLAG_SIZE_PMD:
+			nblocks = ext4_chunk_trans_blocks(inode,
+							PMD_SIZE / PAGE_SIZE);
+			break;
+		case FAULT_FLAG_SIZE_PUD:
+			nblocks = ext4_chunk_trans_blocks(inode,
+							PUD_SIZE / PAGE_SIZE);
+			break;
+		default:
+			BUG();
+		}
 
-	if (write) {
 		sb_start_pagefault(sb);
 		file_update_time(vma->vm_file);
 		down_read(&EXT4_I(inode)->i_mmap_sem);
-		handle = ext4_journal_start_sb(sb, EXT4_HT_WRITE_PAGE,
-				ext4_chunk_trans_blocks(inode,
-							PMD_SIZE / PAGE_SIZE));
+		handle = ext4_journal_start_sb(sb, EXT4_HT_WRITE_PAGE, nblocks);
 	} else
 		down_read(&EXT4_I(inode)->i_mmap_sem);
 
 	if (IS_ERR(handle))
 		result = VM_FAULT_SIGBUS;
 	else
-		result = __dax_pud_fault(vma, addr, pud, flags,
-				ext4_dax_mmap_get_block, NULL);
+		result = dax_fault(vma, vmf, ext4_dax_mmap_get_block, NULL);
 
 	if (write) {
 		if (!IS_ERR(handle))
@@ -306,7 +247,7 @@ static int ext4_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	sb_start_pagefault(inode->i_sb);
 	file_update_time(vma->vm_file);
 	down_read(&EXT4_I(inode)->i_mmap_sem);
-	err = __dax_mkwrite(vma, vmf, ext4_dax_mmap_get_block, NULL);
+	err = dax_mkwrite(vma, vmf, ext4_dax_mmap_get_block, NULL);
 	up_read(&EXT4_I(inode)->i_mmap_sem);
 	sb_end_pagefault(inode->i_sb);
 
@@ -344,8 +285,7 @@ static int ext4_dax_pfn_mkwrite(struct vm_area_struct *vma,
 
 static const struct vm_operations_struct ext4_dax_vm_ops = {
 	.fault		= ext4_dax_fault,
-	.pmd_fault	= ext4_dax_pmd_fault,
-	.pud_fault	= ext4_dax_pud_fault,
+	.huge_fault	= ext4_dax_fault,
 	.page_mkwrite	= ext4_dax_mkwrite,
 	.pfn_mkwrite	= ext4_dax_pfn_mkwrite,
 };
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index a81b942..142f144 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1519,7 +1519,7 @@ xfs_filemap_page_mkwrite(
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 
 	if (IS_DAX(inode)) {
-		ret = __dax_mkwrite(vma, vmf, xfs_get_blocks_dax_fault, NULL);
+		ret = dax_mkwrite(vma, vmf, xfs_get_blocks_dax_fault, NULL);
 	} else {
 		ret = block_page_mkwrite(vma, vmf, xfs_get_blocks);
 		ret = block_page_mkwrite_return(ret);
@@ -1553,7 +1553,7 @@ xfs_filemap_fault(
 		 * changes to xfs_get_blocks_direct() to map unwritten extent
 		 * ioend for conversion on read-only mappings.
 		 */
-		ret = __dax_fault(vma, vmf, xfs_get_blocks_dax_fault, NULL);
+		ret = dax_fault(vma, vmf, xfs_get_blocks_dax_fault, NULL);
 	} else
 		ret = filemap_fault(vma, vmf);
 	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
@@ -1564,48 +1564,14 @@ xfs_filemap_fault(
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
 	struct vm_area_struct	*vma,
-	unsigned long		addr,
-	pmd_t			*pmd,
-	unsigned int		flags)
-{
-	struct inode		*inode = file_inode(vma->vm_file);
-	struct xfs_inode	*ip = XFS_I(inode);
-	int			ret;
-
-	if (!IS_DAX(inode))
-		return VM_FAULT_FALLBACK;
-
-	trace_xfs_filemap_pmd_fault(ip);
-
-	if (flags & FAULT_FLAG_WRITE) {
-		sb_start_pagefault(inode->i_sb);
-		file_update_time(vma->vm_file);
-	}
-
-	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
-	ret = __dax_pmd_fault(vma, addr, pmd, flags, xfs_get_blocks_dax_fault,
-			      NULL);
-	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
-
-	if (flags & FAULT_FLAG_WRITE)
-		sb_end_pagefault(inode->i_sb);
-
-	return ret;
-}
-
-STATIC int
-xfs_filemap_pud_fault(
-	struct vm_area_struct	*vma,
-	unsigned long		addr,
-	pud_t			*pud,
-	unsigned int		flags)
+	struct vm_fault		*vmf)
 {
 	struct inode		*inode = file_inode(vma->vm_file);
 	struct xfs_inode	*ip = XFS_I(inode);
@@ -1614,19 +1580,18 @@ xfs_filemap_pud_fault(
 	if (!IS_DAX(inode))
 		return VM_FAULT_FALLBACK;
 
-	trace_xfs_filemap_pud_fault(ip);
+	trace_xfs_filemap_huge_fault(ip);
 
-	if (flags & FAULT_FLAG_WRITE) {
+	if (vmf->flags & FAULT_FLAG_WRITE) {
 		sb_start_pagefault(inode->i_sb);
 		file_update_time(vma->vm_file);
 	}
 
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
-	ret = __dax_pud_fault(vma, addr, pud, flags, xfs_get_blocks_dax_fault,
-			      NULL);
+	ret = dax_fault(vma, vmf, xfs_get_blocks_dax_fault, NULL);
 	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 
-	if (flags & FAULT_FLAG_WRITE)
+	if (vmf->flags & FAULT_FLAG_WRITE)
 		sb_end_pagefault(inode->i_sb);
 
 	return ret;
@@ -1668,8 +1633,7 @@ xfs_filemap_pfn_mkwrite(
 
 static const struct vm_operations_struct xfs_file_vm_ops = {
 	.fault		= xfs_filemap_fault,
-	.pmd_fault	= xfs_filemap_pmd_fault,
-	.pud_fault	= xfs_filemap_pud_fault,
+	.huge_fault	= xfs_filemap_huge_fault,
 	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= xfs_filemap_page_mkwrite,
 	.pfn_mkwrite	= xfs_filemap_pfn_mkwrite,
diff --git a/fs/xfs/xfs_trace.h b/fs/xfs/xfs_trace.h
index 16442bb..8f810db 100644
--- a/fs/xfs/xfs_trace.h
+++ b/fs/xfs/xfs_trace.h
@@ -687,8 +687,7 @@ DEFINE_INODE_EVENT(xfs_inode_clear_eofblocks_tag);
 DEFINE_INODE_EVENT(xfs_inode_free_eofblocks_invalid);
 
 DEFINE_INODE_EVENT(xfs_filemap_fault);
-DEFINE_INODE_EVENT(xfs_filemap_pmd_fault);
-DEFINE_INODE_EVENT(xfs_filemap_pud_fault);
+DEFINE_INODE_EVENT(xfs_filemap_huge_fault);
 DEFINE_INODE_EVENT(xfs_filemap_page_mkwrite);
 DEFINE_INODE_EVENT(xfs_filemap_pfn_mkwrite);
 
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 5c74c8e..8b5000a 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -12,46 +12,8 @@ int dax_zero_page_range(struct inode *, loff_t from, unsigned len, get_block_t);
 int dax_truncate_page(struct inode *, loff_t from, get_block_t);
 int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t,
 		dax_iodone_t);
-int __dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t,
-		dax_iodone_t);
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-int dax_pmd_fault(struct vm_area_struct *, unsigned long addr, pmd_t *,
-				unsigned int flags, get_block_t, dax_iodone_t);
-int __dax_pmd_fault(struct vm_area_struct *, unsigned long addr, pmd_t *,
-				unsigned int flags, get_block_t, dax_iodone_t);
-#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
-int dax_pud_fault(struct vm_area_struct *, unsigned long addr, pud_t *,
-				unsigned int flags, get_block_t, dax_iodone_t);
-int __dax_pud_fault(struct vm_area_struct *, unsigned long addr, pud_t *,
-				unsigned int flags, get_block_t, dax_iodone_t);
-#else
-static inline int dax_pud_fault(struct vm_area_struct *vma, unsigned long addr,
-				pud_t *pud, unsigned int flags, get_block_t gb,
-				dax_iodone_t di)
-{
-	return VM_FAULT_FALLBACK;
-}
-#define __dax_pud_fault dax_pud_fault
-#endif
-#else
-static inline int dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
-				pmd_t *pmd, unsigned int flags, get_block_t gb,
-				dax_iodone_t di)
-{
-	return VM_FAULT_FALLBACK;
-}
-#define __dax_pmd_fault dax_pmd_fault
-static inline int dax_pud_fault(struct vm_area_struct *vma, unsigned long addr,
-				pud_t *pud, unsigned int flags, get_block_t gb,
-				dax_iodone_t di)
-{
-	return VM_FAULT_FALLBACK;
-}
-#define __dax_pud_fault dax_pud_fault
-#endif
 int dax_pfn_mkwrite(struct vm_area_struct *, struct vm_fault *);
-#define dax_mkwrite(vma, vmf, gb, iod)		dax_fault(vma, vmf, gb, iod)
-#define __dax_mkwrite(vma, vmf, gb, iod)	__dax_fault(vma, vmf, gb, iod)
+#define dax_mkwrite(vma, vmf, gb, iod)	dax_fault(vma, vmf, gb, iod)
 
 static inline bool vma_is_dax(struct vm_area_struct *vma)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e14634f..e63780b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -233,15 +233,21 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_TRIED	0x20	/* Second try */
 #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
 
+#define FAULT_FLAG_SIZE_MASK	0x700	/* Support up to 8-level page tables */
+#define FAULT_FLAG_SIZE_PTE	0x000	/* First level (eg 4k) */
+#define FAULT_FLAG_SIZE_PMD	0x100	/* Second level (eg 2MB) */
+#define FAULT_FLAG_SIZE_PUD	0x200	/* Third level (eg 1GB) */
+#define FAULT_FLAG_SIZE_PGD	0x300	/* Fourth level (eg 512GB) */
+
 /*
- * vm_fault is filled by the the pagefault handler and passed to the vma's
+ * vm_fault is filled in by the pagefault handler and passed to the vma's
  * ->fault function. The vma's ->fault is responsible for returning a bitmask
  * of VM_FAULT_xxx flags that give details about how the fault was handled.
  *
  * MM layer fills up gfp_mask for page allocations but fault handler might
  * alter it if its implementation requires a different allocation context.
  *
- * pgoff should be used in favour of virtual_address, if possible.
+ * pgoff should be used instead of virtual_address, if possible.
  */
 struct vm_fault {
 	unsigned int flags;		/* FAULT_FLAG_xxx flags */
@@ -258,7 +264,11 @@ struct vm_fault {
 	/* for ->map_pages() only */
 	pgoff_t max_pgoff;		/* map pages for offset from pgoff till
 					 * max_pgoff inclusive */
-	pte_t *pte;			/* pte entry associated with ->pgoff */
+	union {
+		pte_t *pte;		/* pte entry associated with ->pgoff */
+		pmd_t *pmd;
+		pud_t *pud;
+	};
 };
 
 /*
@@ -271,10 +281,7 @@ struct vm_operations_struct {
 	void (*close)(struct vm_area_struct * area);
 	int (*mremap)(struct vm_area_struct * area);
 	int (*fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
-	int (*pmd_fault)(struct vm_area_struct *, unsigned long address,
-						pmd_t *, unsigned int flags);
-	int (*pud_fault)(struct vm_area_struct *, unsigned long address,
-						pud_t *, unsigned int flags);
+	int (*huge_fault)(struct vm_area_struct *, struct vm_fault *vmf);
 	void (*map_pages)(struct vm_area_struct *vma, struct vm_fault *vmf);
 
 	/* notification that a previously read-only page is about to become
diff --git a/mm/memory.c b/mm/memory.c
index 7328df0..9382f92 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3264,10 +3264,16 @@ out:
 static int create_huge_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, pmd_t *pmd, unsigned int flags)
 {
+	struct vm_fault vmf = {
+		.virtual_address = (void __user *)address,
+		.flags = flags | FAULT_FLAG_SIZE_PUD,
+		.pmd = pmd,
+	};
+
 	if (vma_is_anonymous(vma))
 		return do_huge_pmd_anonymous_page(mm, vma, address, pmd, flags);
-	if (vma->vm_ops->pmd_fault)
-		return vma->vm_ops->pmd_fault(vma, address, pmd, flags);
+	if (vma->vm_ops->huge_fault)
+		return vma->vm_ops->huge_fault(vma, &vmf);
 	return VM_FAULT_FALLBACK;
 }
 
@@ -3275,21 +3281,33 @@ static int wp_huge_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, pmd_t *pmd, pmd_t orig_pmd,
 			unsigned int flags)
 {
+	struct vm_fault vmf = {
+		.virtual_address = (void __user *)address,
+		.flags = flags | FAULT_FLAG_SIZE_PUD,
+		.pmd = pmd,
+	};
+
 	if (vma_is_anonymous(vma))
 		return do_huge_pmd_wp_page(mm, vma, address, pmd, orig_pmd);
-	if (vma->vm_ops->pmd_fault)
-		return vma->vm_ops->pmd_fault(vma, address, pmd, flags);
+	if (vma->vm_ops->huge_fault)
+		return vma->vm_ops->huge_fault(vma, &vmf);
 	return VM_FAULT_FALLBACK;
 }
 
 static int create_huge_pud(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, pud_t *pud, unsigned int flags)
 {
+	struct vm_fault vmf = {
+		.virtual_address = (void __user *)address,
+		.flags = flags | FAULT_FLAG_SIZE_PUD,
+		.pud = pud,
+	};
+
 	/* No support for anonymous transparent PUD pages yet */
 	if (vma_is_anonymous(vma))
 		return VM_FAULT_FALLBACK;
-	if (vma->vm_ops->pud_fault)
-		return vma->vm_ops->pud_fault(vma, address, pud, flags);
+	if (vma->vm_ops->huge_fault)
+		return vma->vm_ops->huge_fault(vma, &vmf);
 	return VM_FAULT_FALLBACK;
 }
 
@@ -3297,11 +3315,17 @@ static int wp_huge_pud(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, pud_t *pud, pud_t orig_pud,
 			unsigned int flags)
 {
+	struct vm_fault vmf = {
+		.virtual_address = (void __user *)address,
+		.flags = flags | FAULT_FLAG_SIZE_PUD,
+		.pud = pud,
+	};
+
 	/* No support for anonymous transparent PUD pages yet */
 	if (vma_is_anonymous(vma))
 		return VM_FAULT_FALLBACK;
-	if (vma->vm_ops->pud_fault)
-		return vma->vm_ops->pud_fault(vma, address, pud, flags);
+	if (vma->vm_ops->huge_fault)
+		return vma->vm_ops->huge_fault(vma, &vmf);
 	return VM_FAULT_FALLBACK;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
