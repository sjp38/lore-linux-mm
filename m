Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2A9486B025B
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 00:09:23 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so172348842pac.3
        for <linux-mm@kvack.org>; Sun, 29 Nov 2015 21:09:22 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id e64si25119949pfd.15.2015.11.29.21.09.22
        for <linux-mm@kvack.org>;
        Sun, 29 Nov 2015 21:09:22 -0800 (PST)
Subject: [RFC PATCH 4/5] dax: provide diagnostics for pmd mapping failures
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 29 Nov 2015 21:08:55 -0800
Message-ID: <20151130050854.18366.17076.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151130050833.18366.21963.stgit@dwillia2-desk3.jf.intel.com>
References: <20151130050833.18366.21963.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: toshi.kani@hp.com, linux-nvdimm@lists.01.org

There is a wide gamut of conditions that can trigger the dax pmd path to
fallback to pte mappings.  Ideally we'd have a syscall interface to
determine mapping characteristics after the fact.  In the meantime
provide debug messages.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/dax.c |   47 ++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 38 insertions(+), 9 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 9eb46f4b6e38..a429a00628c5 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -567,8 +567,9 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	unsigned blkbits = inode->i_blkbits;
 	unsigned long pmd_addr = address & PMD_MASK;
 	bool write = flags & FAULT_FLAG_WRITE;
-	struct block_device *bdev;
+	struct block_device *bdev = NULL;
 	pgoff_t size, pgoff;
+	const char *reason;
 	sector_t block;
 	int result = 0;
 
@@ -579,21 +580,28 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	/* Fall back to PTEs if we're going to COW */
 	if (write && !(vma->vm_flags & VM_SHARED)) {
 		split_huge_page_pmd(vma, address, pmd);
+		reason = "cow write";
 		return VM_FAULT_FALLBACK;
 	}
 	/* If the PMD would extend outside the VMA */
-	if (pmd_addr < vma->vm_start)
-		return VM_FAULT_FALLBACK;
-	if ((pmd_addr + PMD_SIZE) > vma->vm_end)
-		return VM_FAULT_FALLBACK;
+	if (pmd_addr < vma->vm_start) {
+		reason = "vma start unaligned";
+		goto fallback;
+	}
+	if ((pmd_addr + PMD_SIZE) > vma->vm_end) {
+		reason = "vma end unaligned";
+		goto fallback;
+	}
 
 	pgoff = linear_page_index(vma, pmd_addr);
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (pgoff >= size)
 		return VM_FAULT_SIGBUS;
 	/* If the PMD would cover blocks out of the file */
-	if ((pgoff | PG_PMD_COLOUR) >= size)
+	if ((pgoff | PG_PMD_COLOUR) >= size) {
+		reason = "offset + huge page size > file size";
 		return VM_FAULT_FALLBACK;
+	}
 
 	memset(&bh, 0, sizeof(bh));
 	block = (sector_t)pgoff << (PAGE_SHIFT - blkbits);
@@ -609,8 +617,10 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	 * just fall back to PTEs.  Calling get_block 512 times in a loop
 	 * would be silly.
 	 */
-	if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE)
+	if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE) {
+		reason = "block allocation size invalid";
 		goto fallback;
+	}
 
 	/*
 	 * If we allocated new storage, make sure no process has any
@@ -633,23 +643,33 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		result = VM_FAULT_SIGBUS;
 		goto out;
 	}
-	if ((pgoff | PG_PMD_COLOUR) >= size)
+	if ((pgoff | PG_PMD_COLOUR) >= size) {
+		reason = "pgoff unaligned";
 		goto fallback;
+	}
 
 	if (!write && !buffer_mapped(&bh) && buffer_uptodate(&bh)) {
 		spinlock_t *ptl;
 		pmd_t entry;
 		struct page *zero_page = get_huge_zero_page();
 
-		if (unlikely(!zero_page))
+		if (unlikely(!zero_page)) {
+			reason = "no zero page";
 			goto fallback;
+		}
 
 		ptl = pmd_lock(vma->vm_mm, pmd);
 		if (!pmd_none(*pmd)) {
 			spin_unlock(ptl);
+			reason = "pmd already present";
 			goto fallback;
 		}
 
+		dev_dbg(part_to_dev(bdev->bd_part),
+				"%s: %s addr: %lx pfn: <zero> sect: %llx\n",
+				__func__, current->comm, address,
+				(unsigned long long) to_sector(&bh, inode));
+
 		entry = mk_pmd(zero_page, vma->vm_page_prot);
 		entry = pmd_mkhuge(entry);
 		set_pmd_at(vma->vm_mm, pmd_addr, pmd, entry);
@@ -678,6 +698,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		 */
 		if (pfn_t_has_page(dax.pfn)) {
 			dax_unmap_atomic(bdev, &dax);
+			reason = "pfn not in memmap";
 			goto fallback;
 		}
 
@@ -690,6 +711,11 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		}
 		dax_unmap_atomic(bdev, &dax);
 
+		dev_dbg(part_to_dev(bdev->bd_part),
+				"%s: %s addr: %lx pfn: %lx sect: %llx\n",
+				__func__, current->comm, address,
+				pfn_t_to_pfn(dax.pfn),
+				(unsigned long long) dax.sector);
 		result |= vmf_insert_pfn_pmd(vma, address, pmd,
 				dax.pfn, write);
 	}
@@ -703,6 +729,9 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	return result;
 
  fallback:
+	pr_debug("%s%s %s: %s addr: %lx fallback: %s\n", bdev
+			? dev_name(part_to_dev(bdev->bd_part)) : "", bdev
+			? ": " : "", __func__, current->comm, address, reason);
 	count_vm_event(THP_FAULT_FALLBACK);
 	result = VM_FAULT_FALLBACK;
 	goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
