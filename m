Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3C99782F64
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 00:46:05 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id n128so65969483pfn.0
        for <linux-mm@kvack.org>; Sun, 20 Dec 2015 21:46:05 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id 77si1718638pfj.125.2015.12.20.21.46.04
        for <linux-mm@kvack.org>;
        Sun, 20 Dec 2015 21:46:04 -0800 (PST)
Subject: [-mm PATCH v4 17/18] dax: provide diagnostics for pmd mapping
 failures
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 20 Dec 2015 21:45:37 -0800
Message-ID: <20151221054537.34542.5247.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
References: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, linux-nvdimm@lists.01.org

There is a wide gamut of conditions that can trigger the dax pmd path to
fallback to pte mappings.  Ideally we'd have a syscall interface to
determine mapping characteristics after the fact.  In the meantime
provide debug messages.

Suggested-by: Matthew Wilcox <willy@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/dax.c |   65 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 57 insertions(+), 8 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 96ac3072463d..e1f251dc9654 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -558,6 +558,24 @@ EXPORT_SYMBOL_GPL(dax_fault);
  */
 #define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)
 
+static void __dax_dbg(struct buffer_head *bh, unsigned long address,
+		const char *reason, const char *fn)
+{
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
+}
+
+#define dax_pmd_dbg(bh, address, reason)	__dax_dbg(bh, address, reason, "dax_pmd")
+
 int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		pmd_t *pmd, unsigned int flags, get_block_t get_block,
 		dax_iodone_t complete_unwritten)
@@ -581,21 +599,29 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	/* Fall back to PTEs if we're going to COW */
 	if (write && !(vma->vm_flags & VM_SHARED)) {
 		split_huge_pmd(vma, pmd, address);
+		dax_pmd_dbg(NULL, address, "cow write");
 		return VM_FAULT_FALLBACK;
 	}
 	/* If the PMD would extend outside the VMA */
-	if (pmd_addr < vma->vm_start)
+	if (pmd_addr < vma->vm_start) {
+		dax_pmd_dbg(NULL, address, "vma start unaligned");
 		return VM_FAULT_FALLBACK;
-	if ((pmd_addr + PMD_SIZE) > vma->vm_end)
+	}
+	if ((pmd_addr + PMD_SIZE) > vma->vm_end) {
+		dax_pmd_dbg(NULL, address, "vma end unaligned");
 		return VM_FAULT_FALLBACK;
+	}
 
 	pgoff = linear_page_index(vma, pmd_addr);
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (pgoff >= size)
 		return VM_FAULT_SIGBUS;
 	/* If the PMD would cover blocks out of the file */
-	if ((pgoff | PG_PMD_COLOUR) >= size)
+	if ((pgoff | PG_PMD_COLOUR) >= size) {
+		dax_pmd_dbg(NULL, address,
+				"offset + huge page size > file size");
 		return VM_FAULT_FALLBACK;
+	}
 
 	memset(&bh, 0, sizeof(bh));
 	block = (sector_t)pgoff << (PAGE_SHIFT - blkbits);
@@ -611,8 +637,10 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	 * just fall back to PTEs.  Calling get_block 512 times in a loop
 	 * would be silly.
 	 */
-	if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE)
+	if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE) {
+		dax_pmd_dbg(&bh, address, "allocated block too small");
 		goto fallback;
+	}
 
 	/*
 	 * If we allocated new storage, make sure no process has any
@@ -635,23 +663,33 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		result = VM_FAULT_SIGBUS;
 		goto out;
 	}
-	if ((pgoff | PG_PMD_COLOUR) >= size)
+	if ((pgoff | PG_PMD_COLOUR) >= size) {
+		dax_pmd_dbg(&bh, address, "pgoff unaligned");
 		goto fallback;
+	}
 
 	if (!write && !buffer_mapped(&bh) && buffer_uptodate(&bh)) {
 		spinlock_t *ptl;
 		pmd_t entry;
 		struct page *zero_page = get_huge_zero_page();
 
-		if (unlikely(!zero_page))
+		if (unlikely(!zero_page)) {
+			dax_pmd_dbg(&bh, address, "no zero page");
 			goto fallback;
+		}
 
 		ptl = pmd_lock(vma->vm_mm, pmd);
 		if (!pmd_none(*pmd)) {
 			spin_unlock(ptl);
+			dax_pmd_dbg(&bh, address, "pmd already present");
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
@@ -668,8 +706,13 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 			result = VM_FAULT_SIGBUS;
 			goto out;
 		}
-		if (length < PMD_SIZE
-				|| (pfn_t_to_pfn(dax.pfn) & PG_PMD_COLOUR)) {
+		if (length < PMD_SIZE) {
+			dax_pmd_dbg(&bh, address, "dax-length too small");
+			dax_unmap_atomic(bdev, &dax);
+			goto fallback;
+		}
+		if (pfn_t_to_pfn(dax.pfn) & PG_PMD_COLOUR) {
+			dax_pmd_dbg(&bh, address, "pfn unaligned");
 			dax_unmap_atomic(bdev, &dax);
 			goto fallback;
 		}
@@ -680,6 +723,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		 */
 		if (pfn_t_has_page(dax.pfn)) {
 			dax_unmap_atomic(bdev, &dax);
+			dax_pmd_dbg(&bh, address, "pfn not in memmap");
 			goto fallback;
 		}
 
@@ -692,6 +736,11 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
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
