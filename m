Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id AF0D782F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 11:20:56 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id e65so17715941pfe.1
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 08:20:56 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id p20si14642665pfi.233.2015.12.24.08.20.45
        for <linux-mm@kvack.org>;
        Thu, 24 Dec 2015 08:20:45 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 5/8] dax: Support for transparent PUD pages
Date: Thu, 24 Dec 2015 11:20:34 -0500
Message-Id: <1450974037-24775-6-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1450974037-24775-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1450974037-24775-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

From: Matthew Wilcox <willy@linux.intel.com>

The DAX support for transparent huge PUD pages

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 fs/dax.c            | 239 ++++++++++++++++++++++++++++++++++++++++++++++++----
 include/linux/dax.h |  21 +++++
 2 files changed, 243 insertions(+), 17 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 82d0bff..63ca298 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -557,14 +557,24 @@ EXPORT_SYMBOL_GPL(dax_fault);
  */
 #define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)
 
-static void dax_pmd_dbg(struct block_device *bdev, unsigned long address,
-		const char *reason)
+static void __dax_dbg(struct buffer_head *bh, unsigned long address,
+		const char *reason, const char *fn)
 {
-	pr_debug("%s%s dax_pmd: %s addr: %lx fallback: %s\n", bdev
-			? dev_name(part_to_dev(bdev->bd_part)) : "", bdev
-			? ": " : "", current->comm, address, reason);
+	if (bh) {
+		char bname[BDEVNAME_SIZE];
+		bdevname(bh->b_bdev, bname);
+		pr_debug("%s: %s addr: %lx dev %s state %lx start %lld "
+			"length %zd fallback: %s\n", fn, current->comm,
+			address, bname, bh->b_state, (u64)bh->b_blocknr,
+			bh->b_size, reason);
+	} else {
+		pr_debug("%s: %s addr: %lx fallback: %s\n", fn,
+			current->comm, address, reason);
+	}
 }
 
+#define dax_pmd_dbg(bh, address, reason)	__dax_dbg(bh, address, reason, "dax_pmd")
+
 int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		pmd_t *pmd, unsigned int flags, get_block_t get_block,
 		dax_iodone_t complete_unwritten)
@@ -576,7 +586,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	unsigned blkbits = inode->i_blkbits;
 	unsigned long pmd_addr = address & PMD_MASK;
 	bool write = flags & FAULT_FLAG_WRITE;
-	struct block_device *bdev = NULL;
+	struct block_device *bdev;
 	pgoff_t size, pgoff;
 	sector_t block;
 	int result = 0;
@@ -588,16 +598,16 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	/* Fall back to PTEs if we're going to COW */
 	if (write && !(vma->vm_flags & VM_SHARED)) {
 		split_huge_pmd(vma, pmd, address);
-		dax_pmd_dbg(bdev, address, "cow write");
+		dax_pmd_dbg(NULL, address, "cow write");
 		return VM_FAULT_FALLBACK;
 	}
 	/* If the PMD would extend outside the VMA */
 	if (pmd_addr < vma->vm_start) {
-		dax_pmd_dbg(bdev, address, "vma start unaligned");
+		dax_pmd_dbg(NULL, address, "vma start unaligned");
 		return VM_FAULT_FALLBACK;
 	}
 	if ((pmd_addr + PMD_SIZE) > vma->vm_end) {
-		dax_pmd_dbg(bdev, address, "vma end unaligned");
+		dax_pmd_dbg(NULL, address, "vma end unaligned");
 		return VM_FAULT_FALLBACK;
 	}
 
@@ -607,7 +617,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		return VM_FAULT_SIGBUS;
 	/* If the PMD would cover blocks out of the file */
 	if ((pgoff | PG_PMD_COLOUR) >= size) {
-		dax_pmd_dbg(bdev, address,
+		dax_pmd_dbg(NULL, address,
 				"offset + huge page size > file size");
 		return VM_FAULT_FALLBACK;
 	}
@@ -627,7 +637,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	 * would be silly.
 	 */
 	if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE) {
-		dax_pmd_dbg(bdev, address, "block allocation size invalid");
+		dax_pmd_dbg(&bh, address, "allocated block too small");
 		goto fallback;
 	}
 
@@ -653,7 +663,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		goto out;
 	}
 	if ((pgoff | PG_PMD_COLOUR) >= size) {
-		dax_pmd_dbg(bdev, address, "pgoff unaligned");
+		dax_pmd_dbg(&bh, address, "pgoff unaligned");
 		goto fallback;
 	}
 
@@ -663,14 +673,14 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		struct page *zero_page = get_huge_zero_page();
 
 		if (unlikely(!zero_page)) {
-			dax_pmd_dbg(bdev, address, "no zero page");
+			dax_pmd_dbg(&bh, address, "no zero page");
 			goto fallback;
 		}
 
 		ptl = pmd_lock(vma->vm_mm, pmd);
 		if (!pmd_none(*pmd)) {
 			spin_unlock(ptl);
-			dax_pmd_dbg(bdev, address, "pmd already present");
+			dax_pmd_dbg(&bh, address, "pmd already present");
 			goto fallback;
 		}
 
@@ -696,19 +706,19 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 			goto out;
 		}
 		if (length < PMD_SIZE) {
-			dax_pmd_dbg(bdev, address, "dax-length too small");
+			dax_pmd_dbg(&bh, address, "dax-length too small");
 			dax_unmap_atomic(bdev, &dax);
 			goto fallback;
 		}
 		if (pfn_t_to_pfn(dax.pfn) & PG_PMD_COLOUR) {
-			dax_pmd_dbg(bdev, address, "pfn unaligned");
+			dax_pmd_dbg(&bh, address, "pfn unaligned");
 			dax_unmap_atomic(bdev, &dax);
 			goto fallback;
 		}
 
 		if (!pfn_t_devmap(dax.pfn)) {
 			dax_unmap_atomic(bdev, &dax);
-			dax_pmd_dbg(bdev, address, "pfn not in memmap");
+			dax_pmd_dbg(&bh, address, "pfn not in memmap");
 			goto fallback;
 		}
 
@@ -773,6 +783,201 @@ int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	return result;
 }
 EXPORT_SYMBOL_GPL(dax_pmd_fault);
+
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+/*
+ * The 'colour' (ie low bits) within a PUD of a page offset.  This comes up
+ * more often than one might expect in the below function.
+ */
+#define PG_PUD_COLOUR	((PUD_SIZE >> PAGE_SHIFT) - 1)
+
+#define dax_pud_dbg(bh, address, reason)	__dax_dbg(bh, address, reason, "dax_pud")
+
+int __dax_pud_fault(struct vm_area_struct *vma, unsigned long address,
+		pud_t *pud, unsigned int flags, get_block_t get_block,
+		dax_iodone_t complete_unwritten)
+{
+	struct file *file = vma->vm_file;
+	struct address_space *mapping = file->f_mapping;
+	struct inode *inode = mapping->host;
+	struct buffer_head bh;
+	unsigned blkbits = inode->i_blkbits;
+	unsigned long pud_addr = address & PUD_MASK;
+	bool write = flags & FAULT_FLAG_WRITE;
+	struct block_device *bdev = NULL;
+	pgoff_t size, pgoff;
+	sector_t block;
+	int result = 0;
+
+	/* dax pud mappings require pfn_t_devmap() */
+	if (!IS_ENABLED(CONFIG_FS_DAX_PMD))
+		return VM_FAULT_FALLBACK;
+
+	/* Fall back to PTEs if we're going to COW */
+	if (write && !(vma->vm_flags & VM_SHARED)) {
+		split_huge_pud(vma, pud, address);
+		dax_pud_dbg(NULL, address, "cow write");
+		return VM_FAULT_FALLBACK;
+	}
+	/* If the PUD would extend outside the VMA */
+	if (pud_addr < vma->vm_start) {
+		dax_pud_dbg(NULL, address, "vma start unaligned");
+		return VM_FAULT_FALLBACK;
+	}
+	if ((pud_addr + PUD_SIZE) > vma->vm_end) {
+		dax_pud_dbg(NULL, address, "vma end unaligned");
+		return VM_FAULT_FALLBACK;
+	}
+
+	pgoff = linear_page_index(vma, pud_addr);
+	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	if (pgoff >= size)
+		return VM_FAULT_SIGBUS;
+	/* If the PUD would cover blocks out of the file */
+	if ((pgoff | PG_PUD_COLOUR) >= size) {
+		dax_pud_dbg(NULL, address,
+				"offset + huge page size > file size");
+		return VM_FAULT_FALLBACK;
+	}
+
+	memset(&bh, 0, sizeof(bh));
+	block = (sector_t)pgoff << (PAGE_SHIFT - blkbits);
+
+	bh.b_size = PUD_SIZE;
+	if (get_block(inode, block, &bh, write) != 0)
+		return VM_FAULT_SIGBUS;
+	bdev = bh.b_bdev;
+	i_mmap_lock_read(mapping);
+
+	/*
+	 * If the filesystem isn't willing to tell us the length of a hole,
+	 * just fall back to PTEs.  Calling get_block 512 times in a loop
+	 * would be silly.
+	 */
+	if (!buffer_size_valid(&bh) || bh.b_size < PUD_SIZE) {
+		dax_pud_dbg(&bh, address, "allocated block too small");
+		goto fallback;
+	}
+
+	/*
+	 * If we allocated new storage, make sure no process has any
+	 * zero pages covering this hole
+	 */
+	if (buffer_new(&bh)) {
+		i_mmap_unlock_read(mapping);
+		unmap_mapping_range(mapping, pgoff << PAGE_SHIFT, PUD_SIZE, 0);
+		i_mmap_lock_read(mapping);
+	}
+
+	/*
+	 * If a truncate happened while we were allocating blocks, we may
+	 * leave blocks allocated to the file that are beyond EOF.  We can't
+	 * take i_mutex here, so just leave them hanging; they'll be freed
+	 * when the file is deleted.
+	 */
+	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	if (pgoff >= size) {
+		result = VM_FAULT_SIGBUS;
+		goto out;
+	}
+	if ((pgoff | PG_PUD_COLOUR) >= size) {
+		dax_pud_dbg(&bh, address, "pgoff unaligned");
+		goto fallback;
+	}
+
+	if (!write && !buffer_mapped(&bh) && buffer_uptodate(&bh)) {
+		dax_pud_dbg(&bh, address, "no zero page");
+		goto fallback;
+	} else {
+		struct blk_dax_ctl dax = {
+			.sector = to_sector(&bh, inode),
+			.size = PUD_SIZE,
+		};
+		long length = dax_map_atomic(bdev, &dax);
+
+		if (length < 0) {
+			result = VM_FAULT_SIGBUS;
+			goto out;
+		}
+		if (length < PUD_SIZE) {
+			dax_pud_dbg(&bh, address, "dax-length too small");
+			dax_unmap_atomic(bdev, &dax);
+			goto fallback;
+		}
+		if (pfn_t_to_pfn(dax.pfn) & PG_PUD_COLOUR) {
+			dax_pud_dbg(&bh, address, "pfn unaligned");
+			dax_unmap_atomic(bdev, &dax);
+			goto fallback;
+		}
+
+		if (!pfn_t_devmap(dax.pfn)) {
+			dax_unmap_atomic(bdev, &dax);
+			dax_pud_dbg(&bh, address, "pfn not in memmap");
+			goto fallback;
+		}
+
+		if (buffer_unwritten(&bh) || buffer_new(&bh)) {
+			clear_pmem(dax.addr, PUD_SIZE);
+			wmb_pmem();
+			count_vm_event(PGMAJFAULT);
+			mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
+			result |= VM_FAULT_MAJOR;
+		}
+		dax_unmap_atomic(bdev, &dax);
+
+		dev_dbg(part_to_dev(bdev->bd_part),
+				"%s: %s addr: %lx pfn: %lx sect: %llx\n",
+				__func__, current->comm, address,
+				pfn_t_to_pfn(dax.pfn),
+				(unsigned long long) dax.sector);
+		result |= vmf_insert_pfn_pud(vma, address, pud,
+				dax.pfn, write);
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
+EXPORT_SYMBOL_GPL(__dax_pud_fault);
+
+/**
+ * dax_pud_fault - handle a PUD fault on a DAX file
+ * @vma: The virtual memory area where the fault occurred
+ * @vmf: The description of the fault
+ * @get_block: The filesystem method used to translate file offsets to blocks
+ *
+ * When a page fault occurs, filesystems may call this helper in their
+ * pud_fault handler for DAX files.
+ */
+int dax_pud_fault(struct vm_area_struct *vma, unsigned long address,
+			pud_t *pud, unsigned int flags, get_block_t get_block,
+			dax_iodone_t complete_unwritten)
+{
+	int result;
+	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
+
+	if (flags & FAULT_FLAG_WRITE) {
+		sb_start_pagefault(sb);
+		file_update_time(vma->vm_file);
+	}
+	result = __dax_pud_fault(vma, address, pud, flags, get_block,
+				complete_unwritten);
+	if (flags & FAULT_FLAG_WRITE)
+		sb_end_pagefault(sb);
+
+	return result;
+}
+EXPORT_SYMBOL_GPL(dax_pud_fault);
+#endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 /**
diff --git a/include/linux/dax.h b/include/linux/dax.h
index b415e52..5c74c8e 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -19,6 +19,20 @@ int dax_pmd_fault(struct vm_area_struct *, unsigned long addr, pmd_t *,
 				unsigned int flags, get_block_t, dax_iodone_t);
 int __dax_pmd_fault(struct vm_area_struct *, unsigned long addr, pmd_t *,
 				unsigned int flags, get_block_t, dax_iodone_t);
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+int dax_pud_fault(struct vm_area_struct *, unsigned long addr, pud_t *,
+				unsigned int flags, get_block_t, dax_iodone_t);
+int __dax_pud_fault(struct vm_area_struct *, unsigned long addr, pud_t *,
+				unsigned int flags, get_block_t, dax_iodone_t);
+#else
+static inline int dax_pud_fault(struct vm_area_struct *vma, unsigned long addr,
+				pud_t *pud, unsigned int flags, get_block_t gb,
+				dax_iodone_t di)
+{
+	return VM_FAULT_FALLBACK;
+}
+#define __dax_pud_fault dax_pud_fault
+#endif
 #else
 static inline int dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
 				pmd_t *pmd, unsigned int flags, get_block_t gb,
@@ -27,6 +41,13 @@ static inline int dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
 	return VM_FAULT_FALLBACK;
 }
 #define __dax_pmd_fault dax_pmd_fault
+static inline int dax_pud_fault(struct vm_area_struct *vma, unsigned long addr,
+				pud_t *pud, unsigned int flags, get_block_t gb,
+				dax_iodone_t di)
+{
+	return VM_FAULT_FALLBACK;
+}
+#define __dax_pud_fault dax_pud_fault
 #endif
 int dax_pfn_mkwrite(struct vm_area_struct *, struct vm_fault *);
 #define dax_mkwrite(vma, vmf, gb, iod)		dax_fault(vma, vmf, gb, iod)
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
