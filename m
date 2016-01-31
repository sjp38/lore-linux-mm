Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id F2E51828DF
	for <linux-mm@kvack.org>; Sun, 31 Jan 2016 07:10:01 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id n128so67172351pfn.3
        for <linux-mm@kvack.org>; Sun, 31 Jan 2016 04:10:01 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id o9si24278982pfa.130.2016.01.31.04.09.50
        for <linux-mm@kvack.org>;
        Sun, 31 Jan 2016 04:09:50 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v4 7/8] dax: Support for transparent PUD pages
Date: Sun, 31 Jan 2016 23:09:34 +1100
Message-Id: <1454242175-16870-8-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1454242175-16870-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1454242175-16870-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

From: Matthew Wilcox <willy@linux.intel.com>

The DAX support for transparent huge PUD pages

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 fs/dax.c | 185 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 185 insertions(+)

diff --git a/fs/dax.c b/fs/dax.c
index b2ad0ce..2f9bb89 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -958,6 +958,189 @@ static int dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
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
+static int dax_pud_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
+		get_block_t get_block, dax_iodone_t complete_unwritten)
+{
+	struct file *file = vma->vm_file;
+	struct address_space *mapping = file->f_mapping;
+	struct inode *inode = mapping->host;
+	struct buffer_head bh;
+	unsigned blkbits = inode->i_blkbits;
+	unsigned long address = (unsigned long)vmf->virtual_address;
+	unsigned long pud_addr = address & PUD_MASK;
+	bool write = vmf->flags & FAULT_FLAG_WRITE;
+	struct block_device *bdev;
+	pgoff_t size, pgoff;
+	sector_t block;
+	int result = 0;
+	bool alloc = false;
+
+	/* dax pud mappings require pfn_t_devmap() */
+	if (!IS_ENABLED(CONFIG_FS_DAX_PMD))
+		return VM_FAULT_FALLBACK;
+
+	/* Fall back to PTEs if we're going to COW */
+	if (write && !(vma->vm_flags & VM_SHARED)) {
+		split_huge_pud(vma, vmf->pud, address);
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
+	bh.b_bdev = inode->i_sb->s_bdev;
+	block = (sector_t)pgoff << (PAGE_SHIFT - blkbits);
+
+	bh.b_size = PUD_SIZE;
+
+	if (get_block(inode, block, &bh, 0) != 0)
+		return VM_FAULT_SIGBUS;
+
+	if (!buffer_mapped(&bh) && write) {
+		if (get_block(inode, block, &bh, 1) != 0)
+			return VM_FAULT_SIGBUS;
+		alloc = true;
+	}
+
+	bdev = bh.b_bdev;
+
+	/*
+	 * If the filesystem isn't willing to tell us the length of a hole,
+	 * just fall back to PMDs.  Calling get_block 512 times in a loop
+	 * would be silly.
+	 */
+	if (!buffer_size_valid(&bh) || bh.b_size < PUD_SIZE) {
+		dax_pud_dbg(&bh, address, "allocated block too small");
+		return VM_FAULT_FALLBACK;
+	}
+
+	/*
+	 * If we allocated new storage, make sure no process has any
+	 * zero pages covering this hole
+	 */
+	if (alloc) {
+		loff_t lstart = pgoff << PAGE_SHIFT;
+		loff_t lend = lstart + PUD_SIZE - 1; /* inclusive */
+
+		truncate_pagecache_range(inode, lstart, lend);
+	}
+
+	i_mmap_lock_read(mapping);
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
+		dax_pud_dbg(&bh, address, "page extends outside VMA");
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
+		result |= vmf_insert_pfn_pud(vma, address, vmf->pud,
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
+static int dax_pud_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
+		get_block_t get_block, dax_iodone_t complete_unwritten)
+{
+	return VM_FAULT_FALLBACK;
+}
+#endif /* !CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
+
 /**
  * dax_fault - handle a page fault on a DAX file
  * @vma: The virtual memory area where the fault occurred
@@ -982,6 +1165,8 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		return dax_pte_fault(vma, vmf, get_block, iodone);
 	case FAULT_FLAG_SIZE_PMD:
 		return dax_pmd_fault(vma, vmf, get_block, iodone);
+	case FAULT_FLAG_SIZE_PUD:
+		return dax_pud_fault(vma, vmf, get_block, iodone);
 	default:
 		return VM_FAULT_FALLBACK;
 	}
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
