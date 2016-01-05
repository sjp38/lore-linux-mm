Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 767226B000A
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 13:30:23 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id cy9so219031665pac.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 10:30:23 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id kp14si37265756pab.99.2016.01.05.10.30.15
        for <linux-mm@kvack.org>;
        Tue, 05 Jan 2016 10:30:16 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v2 7/8] dax: Support for transparent PUD pages
Date: Tue,  5 Jan 2016 13:30:09 -0500
Message-Id: <1452018610-26090-8-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1452018610-26090-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1452018610-26090-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

From: Matthew Wilcox <willy@linux.intel.com>

The DAX support for transparent huge PUD pages

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 fs/dax.c | 221 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 203 insertions(+), 18 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index b82831a..0a841b6 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -513,14 +513,24 @@ static int dax_pte_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
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
 static int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		pmd_t *pmd, unsigned int flags, get_block_t get_block,
 		dax_iodone_t complete_unwritten)
@@ -532,7 +542,7 @@ static int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	unsigned blkbits = inode->i_blkbits;
 	unsigned long pmd_addr = address & PMD_MASK;
 	bool write = flags & FAULT_FLAG_WRITE;
-	struct block_device *bdev = NULL;
+	struct block_device *bdev;
 	pgoff_t size, pgoff;
 	sector_t block;
 	int result = 0;
@@ -544,16 +554,16 @@ static int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
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
 
@@ -563,7 +573,7 @@ static int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		return VM_FAULT_SIGBUS;
 	/* If the PMD would cover blocks out of the file */
 	if ((pgoff | PG_PMD_COLOUR) >= size) {
-		dax_pmd_dbg(bdev, address,
+		dax_pmd_dbg(NULL, address,
 				"offset + huge page size > file size");
 		return VM_FAULT_FALLBACK;
 	}
@@ -583,7 +593,7 @@ static int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	 * would be silly.
 	 */
 	if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE) {
-		dax_pmd_dbg(bdev, address, "block allocation size invalid");
+		dax_pmd_dbg(&bh, address, "allocated block too small");
 		goto fallback;
 	}
 
@@ -609,7 +619,7 @@ static int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		goto out;
 	}
 	if ((pgoff | PG_PMD_COLOUR) >= size) {
-		dax_pmd_dbg(bdev, address, "pgoff unaligned");
+		dax_pmd_dbg(&bh, address, "pgoff unaligned");
 		goto fallback;
 	}
 
@@ -619,14 +629,14 @@ static int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
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
 
@@ -652,19 +662,19 @@ static int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
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
 
@@ -708,6 +718,178 @@ static int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 }
 #endif /* !CONFIG_TRANSPARENT_HUGEPAGE */
 
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+/*
+ * The 'colour' (ie low bits) within a PUD of a page offset.  This comes up
+ * more often than one might expect in the below function.
+ */
+#define PG_PUD_COLOUR	((PUD_SIZE >> PAGE_SHIFT) - 1)
+
+#define dax_pud_dbg(bh, address, reason)	__dax_dbg(bh, address, reason, "dax_pud")
+
+static int dax_pud_fault(struct vm_area_struct *vma, unsigned long address,
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
+#else /* !CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
+static int dax_pud_fault(struct vm_area_struct *vma, unsigned long address,
+		pud_t *pud, unsigned int flags, get_block_t get_block,
+		dax_iodone_t complete_unwritten)
+{
+	return VM_FAULT_FALLBACK;
+}
+#endif /* !CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
+
 /**
  * dax_fault - handle a page fault on a DAX file
  * @vma: The virtual memory area where the fault occurred
@@ -725,7 +907,7 @@ static int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
  * the necessary locking for the page fault to proceed successfully.
  */
 int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
-	      get_block_t get_block, dax_iodone_t iodone)
+			get_block_t get_block, dax_iodone_t iodone)
 {
 	unsigned long address = (unsigned long)vmf->virtual_address;
 	switch (vmf->flags & FAULT_FLAG_SIZE_MASK) {
@@ -734,6 +916,9 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	case FAULT_FLAG_SIZE_PMD:
 		return dax_pmd_fault(vma, address, vmf->pmd, vmf->flags,
 						get_block, iodone);
+	case FAULT_FLAG_SIZE_PUD:
+		return dax_pud_fault(vma, address, vmf->pud, vmf->flags,
+						get_block, iodone);
 	default:
 		return VM_FAULT_FALLBACK;
 	}
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
