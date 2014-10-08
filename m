Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2767D900014
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 09:26:00 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so9104053pab.2
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 06:25:59 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id pm2si1781125pdb.220.2014.10.08.06.25.56
        for <linux-mm@kvack.org>;
        Wed, 08 Oct 2014 06:25:57 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v1 5/7] dax: Add huge page fault support
Date: Wed,  8 Oct 2014 09:25:27 -0400
Message-Id: <1412774729-23956-6-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1412774729-23956-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1412774729-23956-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.krenel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

This is the support code for DAX-enabled filesystems to allow them to
provide huge pages in response to faults.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 Documentation/filesystems/dax.txt |   7 +-
 fs/dax.c                          | 133 ++++++++++++++++++++++++++++++++++++++
 include/linux/fs.h                |   2 +
 3 files changed, 139 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/dax.txt b/Documentation/filesystems/dax.txt
index be376d9..f958b07 100644
--- a/Documentation/filesystems/dax.txt
+++ b/Documentation/filesystems/dax.txt
@@ -58,9 +58,10 @@ Filesystem support consists of
 - implementing the direct_IO address space operation, and calling
   dax_do_io() instead of blockdev_direct_IO() if S_DAX is set
 - implementing an mmap file operation for DAX files which sets the
-  VM_MIXEDMAP flag on the VMA, and setting the vm_ops to include handlers
-  for fault and page_mkwrite (which should probably call dax_fault() and
-  dax_mkwrite(), passing the appropriate get_block() callback)
+  VM_MIXEDMAP and VM_HUGEPAGE flags on the VMA, and setting the vm_ops to
+  include handlers for fault, pmd_fault and page_mkwrite (which should
+  probably call dax_fault(), dax_pmd_fault() and dax_mkwrite(), passing the
+  appropriate get_block() callback)
 - calling dax_truncate_page() instead of block_truncate_page() for DAX files
 - calling dax_zero_page_range() instead of zero_user() for DAX files
 - ensuring that there is sufficient locking between reads, writes,
diff --git a/fs/dax.c b/fs/dax.c
index 041d237..7be108b 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -461,6 +461,139 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 }
 EXPORT_SYMBOL_GPL(dax_fault);
 
+/*
+ * The 'colour' (ie low bits) within a PMD of a page offset.  This comes up
+ * more often than one might expect in the below function.
+ */
+#define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)
+
+static int do_dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
+			pmd_t *pmd, unsigned int flags, get_block_t get_block)
+{
+	struct file *file = vma->vm_file;
+	struct address_space *mapping = file->f_mapping;
+	struct inode *inode = mapping->host;
+	struct buffer_head bh;
+	unsigned blkbits = inode->i_blkbits;
+	long length;
+	void *kaddr;
+	pgoff_t size, pgoff;
+	sector_t block, sector;
+	unsigned long pfn;
+	int major = 0;
+
+	/* Fall back to PTEs if we're going to COW */
+	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED))
+		return VM_FAULT_FALLBACK;
+	/* If the PMD would extend outside the VMA */
+	if ((address & PMD_MASK) < vma->vm_start)
+		return VM_FAULT_FALLBACK;
+	if (((address & PMD_MASK) + PMD_SIZE) > vma->vm_end)
+		return VM_FAULT_FALLBACK;
+
+	pgoff = ((address - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	if (pgoff >= size)
+		return VM_FAULT_SIGBUS;
+	/* If the PMD would cover blocks out of the file */
+	if ((pgoff | PG_PMD_COLOUR) >= size)
+		return VM_FAULT_FALLBACK;
+
+	memset(&bh, 0, sizeof(bh));
+	block = ((sector_t)pgoff & ~PG_PMD_COLOUR) << (PAGE_SHIFT - blkbits);
+
+	/* Start by seeing if we already have an allocated block */
+	bh.b_size = PMD_SIZE;
+	length = get_block(inode, block, &bh, 0);
+	if (length)
+		return VM_FAULT_SIGBUS;
+
+	if ((!buffer_mapped(&bh) && !buffer_unwritten(&bh)) ||
+						bh.b_size != PMD_SIZE) {
+		bh.b_size = PMD_SIZE;
+		length = get_block(inode, block, &bh, 1);
+		count_vm_event(PGMAJFAULT);
+		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
+		major = VM_FAULT_MAJOR;
+		if (length)
+			return VM_FAULT_SIGBUS;
+		if (bh.b_size != PMD_SIZE)
+			return VM_FAULT_FALLBACK;
+	}
+
+	mutex_lock(&mapping->i_mmap_mutex);
+
+	/* Guard against a race with truncate */
+	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	if (pgoff >= size)
+		goto sigbus;
+	if ((pgoff | PG_PMD_COLOUR) >= size)
+		goto fallback;
+
+	sector = bh.b_blocknr << (blkbits - 9);
+	length = bdev_direct_access(bh.b_bdev, sector, &kaddr, &pfn, bh.b_size);
+	if (length < 0)
+		goto sigbus;
+	if (length < PMD_SIZE)
+		goto fallback;
+	if (pfn & PG_PMD_COLOUR)
+		goto fallback;	/* not aligned */
+
+	if (buffer_unwritten(&bh) || buffer_new(&bh)) {
+		int i;
+		for (i = 0; i < PTRS_PER_PMD; i++)
+			clear_page(kaddr + i * PAGE_SIZE);
+	}
+
+	length = vm_insert_pfn_pmd(vma, address, pmd, pfn);
+	mutex_unlock(&mapping->i_mmap_mutex);
+
+	if (bh.b_end_io)
+		bh.b_end_io(&bh, 1);
+
+	if (length == -ENOMEM)
+		return VM_FAULT_OOM | major;
+	/* -EBUSY is fine, somebody else faulted on the same PMD */
+	if ((length < 0) && (length != -EBUSY))
+		return VM_FAULT_SIGBUS | major;
+	return VM_FAULT_NOPAGE | major;
+
+ fallback:
+	mutex_unlock(&mapping->i_mmap_mutex);
+	return VM_FAULT_FALLBACK | major;
+
+ sigbus:
+	mutex_unlock(&mapping->i_mmap_mutex);
+	return VM_FAULT_SIGBUS | major;
+}
+
+/**
+ * dax_pmd_fault - handle a PMD fault on a DAX file
+ * @vma: The virtual memory area where the fault occurred
+ * @vmf: The description of the fault
+ * @get_block: The filesystem method used to translate file offsets to blocks
+ *
+ * When a page fault occurs, filesystems may call this helper in their
+ * pmd_fault handler for DAX files.
+ */
+int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
+			pmd_t *pmd, unsigned int flags, get_block_t get_block)
+{
+	int result;
+	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
+
+	if (flags & FAULT_FLAG_WRITE) {
+		sb_start_pagefault(sb);
+		file_update_time(vma->vm_file);
+	}
+	result = do_dax_pmd_fault(vma, address, pmd, flags, get_block);
+	if (flags & FAULT_FLAG_WRITE)
+		sb_end_pagefault(sb);
+
+	return result;
+}
+EXPORT_SYMBOL_GPL(dax_pmd_fault);
+
 /**
  * dax_zero_page_range - zero a range within a page of a DAX file
  * @inode: The file being truncated
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 105d0f0..3528597 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2495,6 +2495,8 @@ int dax_truncate_page(struct inode *, loff_t from, get_block_t);
 ssize_t dax_do_io(int rw, struct kiocb *, struct inode *, struct iov_iter *,
 		loff_t, get_block_t, dio_iodone_t, int flags);
 int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
+int dax_pmd_fault(struct vm_area_struct *, unsigned long addr, pmd_t *,
+					unsigned int flags, get_block_t);
 #define dax_mkwrite(vma, vmf, gb)	dax_fault(vma, vmf, gb)
 #else
 static inline int dax_clear_blocks(struct inode *i, sector_t blk, long sz)
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
