Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id DAA2082F6A
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 21:39:49 -0500 (EST)
Received: by pfu207 with SMTP id 207so39816742pfu.2
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 18:39:49 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id g79si16762852pfj.185.2015.12.09.18.39.48
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 18:39:49 -0800 (PST)
Subject: [-mm PATCH v2 24/25] dax: provide diagnostics for pmd mapping
 failures
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 09 Dec 2015 18:39:22 -0800
Message-ID: <20151210023921.30368.71732.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-nvdimm@lists.01.org

There is a wide gamut of conditions that can trigger the dax pmd path to
fallback to pte mappings.  Ideally we'd have a syscall interface to
determine mapping characteristics after the fact.  In the meantime
provide debug messages.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/dax.c |   57 ++++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 48 insertions(+), 9 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 27ded3c6df64..a8b82a75dfa8 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -557,6 +557,14 @@ EXPORT_SYMBOL_GPL(dax_fault);
  */
 #define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)
 
+static void dax_pmd_dbg(struct block_device *bdev, unsigned long address,
+		const char *reason)
+{
+	pr_debug("%s%s dax_pmd: %s addr: %lx fallback: %s\n", bdev
+			? dev_name(part_to_dev(bdev->bd_part)) : "", bdev
+			? ": " : "", current->comm, address, reason);
+}
+
 int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		pmd_t *pmd, unsigned int flags, get_block_t get_block,
 		dax_iodone_t complete_unwritten)
@@ -568,7 +576,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	unsigned blkbits = inode->i_blkbits;
 	unsigned long pmd_addr = address & PMD_MASK;
 	bool write = flags & FAULT_FLAG_WRITE;
-	struct block_device *bdev;
+	struct block_device *bdev = NULL;
 	pgoff_t size, pgoff;
 	sector_t block;
 	int result = 0;
@@ -580,21 +588,29 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	/* Fall back to PTEs if we're going to COW */
 	if (write && !(vma->vm_flags & VM_SHARED)) {
 		split_huge_pmd(vma, pmd, address);
+		dax_pmd_dbg(bdev, address, "cow write");
 		return VM_FAULT_FALLBACK;
 	}
 	/* If the PMD would extend outside the VMA */
-	if (pmd_addr < vma->vm_start)
+	if (pmd_addr < vma->vm_start) {
+		dax_pmd_dbg(bdev, address, "vma start unaligned");
 		return VM_FAULT_FALLBACK;
-	if ((pmd_addr + PMD_SIZE) > vma->vm_end)
+	}
+	if ((pmd_addr + PMD_SIZE) > vma->vm_end) {
+		dax_pmd_dbg(bdev, address, "vma end unaligned");
 		return VM_FAULT_FALLBACK;
+	}
 
 	pgoff = linear_page_index(vma, pmd_addr);
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (pgoff >= size)
 		return VM_FAULT_SIGBUS;
 	/* If the PMD would cover blocks out of the file */
-	if ((pgoff | PG_PMD_COLOUR) >= size)
+	if ((pgoff | PG_PMD_COLOUR) >= size) {
+		dax_pmd_dbg(bdev, address,
+				"offset + huge page size > file size");
 		return VM_FAULT_FALLBACK;
+	}
 
 	memset(&bh, 0, sizeof(bh));
 	block = (sector_t)pgoff << (PAGE_SHIFT - blkbits);
@@ -610,8 +626,10 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	 * just fall back to PTEs.  Calling get_block 512 times in a loop
 	 * would be silly.
 	 */
-	if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE)
+	if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE) {
+		dax_pmd_dbg(bdev, address, "block allocation size invalid");
 		goto fallback;
+	}
 
 	/*
 	 * If we allocated new storage, make sure no process has any
@@ -634,23 +652,33 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		result = VM_FAULT_SIGBUS;
 		goto out;
 	}
-	if ((pgoff | PG_PMD_COLOUR) >= size)
+	if ((pgoff | PG_PMD_COLOUR) >= size) {
+		dax_pmd_dbg(bdev, address, "pgoff unaligned");
 		goto fallback;
+	}
 
 	if (!write && !buffer_mapped(&bh) && buffer_uptodate(&bh)) {
 		spinlock_t *ptl;
 		pmd_t entry;
 		struct page *zero_page = get_huge_zero_page();
 
-		if (unlikely(!zero_page))
+		if (unlikely(!zero_page)) {
+			dax_pmd_dbg(bdev, address, "no zero page");
 			goto fallback;
+		}
 
 		ptl = pmd_lock(vma->vm_mm, pmd);
 		if (!pmd_none(*pmd)) {
 			spin_unlock(ptl);
+			dax_pmd_dbg(bdev, address, "pmd already present");
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
@@ -667,8 +695,13 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 			result = VM_FAULT_SIGBUS;
 			goto out;
 		}
-		if (length < PMD_SIZE
-				|| (pfn_t_to_pfn(dax.pfn) & PG_PMD_COLOUR)) {
+		if (length < PMD_SIZE) {
+			dax_pmd_dbg(bdev, address, "dax-length too small");
+			dax_unmap_atomic(bdev, &dax);
+			goto fallback;
+		}
+		if (pfn_t_to_pfn(dax.pfn) & PG_PMD_COLOUR) {
+			dax_pmd_dbg(bdev, address, "pfn unaligned");
 			dax_unmap_atomic(bdev, &dax);
 			goto fallback;
 		}
@@ -679,6 +712,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		 */
 		if (pfn_t_has_page(dax.pfn)) {
 			dax_unmap_atomic(bdev, &dax);
+			dax_pmd_dbg(bdev, address, "pfn not in memmap");
 			goto fallback;
 		}
 
@@ -691,6 +725,11 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
