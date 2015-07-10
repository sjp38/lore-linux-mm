Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id C38DE9003C7
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 16:29:54 -0400 (EDT)
Received: by pdbqm3 with SMTP id qm3so45803095pdb.0
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 13:29:54 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id uj2si15991650pab.146.2015.07.10.13.29.37
        for <linux-mm@kvack.org>;
        Fri, 10 Jul 2015 13:29:37 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 07/10] dax: Add huge page fault support
Date: Fri, 10 Jul 2015 16:29:22 -0400
Message-Id: <1436560165-8943-8-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

This is the support code for DAX-enabled filesystems to allow them to
provide huge pages in response to faults.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 Documentation/filesystems/dax.txt |   7 +-
 fs/dax.c                          | 152 ++++++++++++++++++++++++++++++++++++++
 include/linux/dax.h               |  14 ++++
 3 files changed, 170 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/dax.txt b/Documentation/filesystems/dax.txt
index 7af2851..7bde640 100644
--- a/Documentation/filesystems/dax.txt
+++ b/Documentation/filesystems/dax.txt
@@ -60,9 +60,10 @@ Filesystem support consists of
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
index c3e21cc..20cf3b0 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -484,6 +484,158 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 }
 EXPORT_SYMBOL_GPL(dax_fault);
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+/*
+ * The 'colour' (ie low bits) within a PMD of a page offset.  This comes up
+ * more often than one might expect in the below function.
+ */
+#define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)
+
+int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
+		pmd_t *pmd, unsigned int flags, get_block_t get_block,
+		dax_iodone_t complete_unwritten)
+{
+	struct file *file = vma->vm_file;
+	struct address_space *mapping = file->f_mapping;
+	struct inode *inode = mapping->host;
+	struct buffer_head bh;
+	unsigned blkbits = inode->i_blkbits;
+	unsigned long pmd_addr = address & PMD_MASK;
+	bool write = flags & FAULT_FLAG_WRITE;
+	long length;
+	void *kaddr;
+	pgoff_t size, pgoff;
+	sector_t block, sector;
+	unsigned long pfn;
+	int result = 0;
+
+	/* Fall back to PTEs if we're going to COW */
+	if (write && !(vma->vm_flags & VM_SHARED))
+		return VM_FAULT_FALLBACK;
+	/* If the PMD would extend outside the VMA */
+	if (pmd_addr < vma->vm_start)
+		return VM_FAULT_FALLBACK;
+	if ((pmd_addr + PMD_SIZE) > vma->vm_end)
+		return VM_FAULT_FALLBACK;
+
+	pgoff = ((pmd_addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	if (pgoff >= size)
+		return VM_FAULT_SIGBUS;
+	/* If the PMD would cover blocks out of the file */
+	if ((pgoff | PG_PMD_COLOUR) >= size)
+		return VM_FAULT_FALLBACK;
+
+	memset(&bh, 0, sizeof(bh));
+	block = (sector_t)pgoff << (PAGE_SHIFT - blkbits);
+
+	bh.b_size = PMD_SIZE;
+	length = get_block(inode, block, &bh, write);
+	if (length)
+		return VM_FAULT_SIGBUS;
+	i_mmap_lock_read(mapping);
+
+	/*
+	 * If the filesystem isn't willing to tell us the length of a hole,
+	 * just fall back to PTEs.  Calling get_block 512 times in a loop
+	 * would be silly.
+	 */
+	if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE)
+		goto fallback;
+
+	/* Guard against a race with truncate */
+	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	if (pgoff >= size) {
+		result = VM_FAULT_SIGBUS;
+		goto out;
+	}
+	if ((pgoff | PG_PMD_COLOUR) >= size)
+		goto fallback;
+
+	if (is_huge_zero_pmd(*pmd))
+		unmap_mapping_range(mapping, pgoff << PAGE_SHIFT, PMD_SIZE, 0);
+
+	if (!write && !buffer_mapped(&bh) && buffer_uptodate(&bh)) {
+		bool set;
+		spinlock_t *ptl;
+		struct mm_struct *mm = vma->vm_mm;
+		struct page *zero_page = get_huge_zero_page();
+		if (unlikely(!zero_page))
+			goto fallback;
+
+		ptl = pmd_lock(mm, pmd);
+		set = set_huge_zero_page(NULL, mm, vma, pmd_addr, pmd,
+								zero_page);
+		spin_unlock(ptl);
+		result = VM_FAULT_NOPAGE;
+	} else {
+		sector = bh.b_blocknr << (blkbits - 9);
+		length = bdev_direct_access(bh.b_bdev, sector, &kaddr, &pfn,
+						bh.b_size);
+		if (length < 0) {
+			result = VM_FAULT_SIGBUS;
+			goto out;
+		}
+		if ((length < PMD_SIZE) || (pfn & PG_PMD_COLOUR))
+			goto fallback;
+
+		if (buffer_unwritten(&bh) || buffer_new(&bh)) {
+			int i;
+			for (i = 0; i < PTRS_PER_PMD; i++)
+				clear_page(kaddr + i * PAGE_SIZE);
+			count_vm_event(PGMAJFAULT);
+			mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
+			result |= VM_FAULT_MAJOR;
+		}
+
+		result |= vmf_insert_pfn_pmd(vma, address, pmd, pfn, write);
+	}
+
+ out:
+	i_mmap_unlock_read(mapping);
+
+	if (buffer_unwritten(&bh))
+		complete_unwritten(&bh, !(result & VM_FAULT_ERROR));
+
+	return result;
+
+ fallback:
+	count_vm_event(THP_FAULT_FALLBACK);
+	result = VM_FAULT_FALLBACK;
+	goto out;
+}
+EXPORT_SYMBOL_GPL(__dax_pmd_fault);
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
+			pmd_t *pmd, unsigned int flags, get_block_t get_block,
+			dax_iodone_t complete_unwritten)
+{
+	int result;
+	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
+
+	if (flags & FAULT_FLAG_WRITE) {
+		sb_start_pagefault(sb);
+		file_update_time(vma->vm_file);
+	}
+	result = __dax_pmd_fault(vma, address, pmd, flags, get_block,
+				complete_unwritten);
+	if (flags & FAULT_FLAG_WRITE)
+		sb_end_pagefault(sb);
+
+	return result;
+}
+EXPORT_SYMBOL_GPL(dax_pmd_fault);
+#endif /* CONFIG_TRANSPARENT_HUGEPAGES */
+
 /**
  * dax_pfn_mkwrite - handle first write to DAX page
  * @vma: The virtual memory area where the fault occurred
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 9b51f9d..b415e52 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -14,6 +14,20 @@ int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t,
 		dax_iodone_t);
 int __dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t,
 		dax_iodone_t);
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+int dax_pmd_fault(struct vm_area_struct *, unsigned long addr, pmd_t *,
+				unsigned int flags, get_block_t, dax_iodone_t);
+int __dax_pmd_fault(struct vm_area_struct *, unsigned long addr, pmd_t *,
+				unsigned int flags, get_block_t, dax_iodone_t);
+#else
+static inline int dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
+				pmd_t *pmd, unsigned int flags, get_block_t gb,
+				dax_iodone_t di)
+{
+	return VM_FAULT_FALLBACK;
+}
+#define __dax_pmd_fault dax_pmd_fault
+#endif
 int dax_pfn_mkwrite(struct vm_area_struct *, struct vm_fault *);
 #define dax_mkwrite(vma, vmf, gb, iod)		dax_fault(vma, vmf, gb, iod)
 #define __dax_mkwrite(vma, vmf, gb, iod)	__dax_fault(vma, vmf, gb, iod)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
