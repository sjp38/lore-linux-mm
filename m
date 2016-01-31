Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 10297828DF
	for <linux-mm@kvack.org>; Sun, 31 Jan 2016 07:20:09 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id ho8so66266068pac.2
        for <linux-mm@kvack.org>; Sun, 31 Jan 2016 04:20:09 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id tc5si16572412pab.176.2016.01.31.04.20.04
        for <linux-mm@kvack.org>;
        Sun, 31 Jan 2016 04:20:04 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 5/6] dax: Factor dax_insert_pmd_mapping out of dax_pmd_fault
Date: Sun, 31 Jan 2016 23:19:54 +1100
Message-Id: <1454242795-18038-6-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1454242795-18038-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1454242795-18038-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

These two functios are still large, but they're no longer quite so
ludicrously large

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/dax.c | 153 +++++++++++++++++++++++++++++++++------------------------------
 1 file changed, 80 insertions(+), 73 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index f0c204d..ec31e6e 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -697,6 +697,83 @@ static void __dax_dbg(struct buffer_head *bh, unsigned long address,
 
 #define dax_pmd_dbg(bh, address, reason)	__dax_dbg(bh, address, reason, "dax_pmd")
 
+static int dax_insert_pmd_mapping(struct inode *inode, struct buffer_head *bh,
+			struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	int major = 0;
+	struct blk_dax_ctl dax = {
+		.sector = to_sector(bh, inode),
+		.size = PMD_SIZE,
+	};
+	struct block_device *bdev = bh->b_bdev;
+	bool write = vmf->flags & FAULT_FLAG_WRITE;
+	unsigned long address = (unsigned long)vmf->virtual_address;
+	long length = dax_map_atomic(bdev, &dax);
+
+	if (length < 0)
+		return VM_FAULT_SIGBUS;
+	if (length < PMD_SIZE) {
+		dax_pmd_dbg(bh, address, "dax-length too small");
+		goto unmap;
+	}
+
+	if (pfn_t_to_pfn(dax.pfn) & PG_PMD_COLOUR) {
+		dax_pmd_dbg(bh, address, "pfn unaligned");
+		goto unmap;
+	}
+
+	if (!pfn_t_devmap(dax.pfn)) {
+		dax_pmd_dbg(bh, address, "pfn not in memmap");
+		goto unmap;
+	}
+
+	if (buffer_unwritten(bh) || buffer_new(bh)) {
+		clear_pmem(dax.addr, PMD_SIZE);
+		wmb_pmem();
+		count_vm_event(PGMAJFAULT);
+		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
+		major = VM_FAULT_MAJOR;
+	}
+	dax_unmap_atomic(bdev, &dax);
+
+	/*
+	 * For PTE faults we insert a radix tree entry for reads, and leave
+	 * it clean.  Then on the first write we dirty the radix tree entry
+	 * via the dax_pfn_mkwrite() path.  This sequence allows the
+	 * dax_pfn_mkwrite() call to be simpler and avoid a call into
+	 * get_block() to translate the pgoff to a sector in order to be able
+	 * to create a new radix tree entry.
+	 *
+	 * The PMD path doesn't have an equivalent to dax_pfn_mkwrite(),
+	 * though, so for a read followed by a write we traverse all the way
+	 * through dax_pmd_fault() twice.  This means we can just skip
+	 * inserting a radix tree entry completely on the initial read and
+	 * just wait until the write to insert a dirty entry.
+	 */
+	if (write) {
+		int error = dax_radix_entry(vma->vm_file->f_mapping, vmf->pgoff,
+						dax.sector, true, true);
+		if (error) {
+			dax_pmd_dbg(bh, address,
+					"PMD radix insertion failed");
+			goto fallback;
+		}
+	}
+
+	dev_dbg(part_to_dev(bdev->bd_part),
+			"%s: %s addr: %lx pfn: %lx sect: %llx\n",
+			__func__, current->comm, address,
+			pfn_t_to_pfn(dax.pfn),
+			(unsigned long long) dax.sector);
+	return major | vmf_insert_pfn_pmd(vma, address, vmf->pmd,
+						dax.pfn, write);
+ unmap:
+	dax_unmap_atomic(bdev, &dax);
+ fallback:
+	count_vm_event(THP_FAULT_FALLBACK);
+	return VM_FAULT_FALLBACK;
+}
+
 static int dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		get_block_t get_block, dax_iodone_t complete_unwritten)
 {
@@ -708,10 +785,9 @@ static int dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	unsigned long address = (unsigned long)vmf->virtual_address;
 	unsigned long pmd_addr = address & PMD_MASK;
 	bool write = vmf->flags & FAULT_FLAG_WRITE;
-	struct block_device *bdev;
 	pgoff_t size;
 	sector_t block;
-	int error, result = 0;
+	int result;
 	bool alloc = false;
 
 	/* dax pmd mappings require pfn_t_devmap() */
@@ -759,8 +835,6 @@ static int dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		alloc = true;
 	}
 
-	bdev = bh.b_bdev;
-
 	/*
 	 * If the filesystem isn't willing to tell us the length of a hole,
 	 * just fall back to PTEs.  Calling get_block 512 times in a loop
@@ -799,7 +873,7 @@ static int dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 			goto fallback;
 		}
 
-		dev_dbg(part_to_dev(bdev->bd_part),
+		dev_dbg(part_to_dev(bh.b_bdev->bd_part),
 				"%s: %s addr: %lx pfn: <zero> sect: %llx\n",
 				__func__, current->comm, address,
 				(unsigned long long) to_sector(&bh, inode));
@@ -810,74 +884,7 @@ static int dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		result = VM_FAULT_NOPAGE;
 		spin_unlock(ptl);
 	} else {
-		struct blk_dax_ctl dax = {
-			.sector = to_sector(&bh, inode),
-			.size = PMD_SIZE,
-		};
-		long length = dax_map_atomic(bdev, &dax);
-
-		if (length < 0) {
-			result = VM_FAULT_SIGBUS;
-			goto out;
-		}
-		if (length < PMD_SIZE) {
-			dax_pmd_dbg(&bh, address, "dax-length too small");
-			dax_unmap_atomic(bdev, &dax);
-			goto fallback;
-		}
-		if (pfn_t_to_pfn(dax.pfn) & PG_PMD_COLOUR) {
-			dax_pmd_dbg(&bh, address, "pfn unaligned");
-			dax_unmap_atomic(bdev, &dax);
-			goto fallback;
-		}
-
-		if (!pfn_t_devmap(dax.pfn)) {
-			dax_unmap_atomic(bdev, &dax);
-			dax_pmd_dbg(&bh, address, "pfn not in memmap");
-			goto fallback;
-		}
-
-		if (buffer_unwritten(&bh) || buffer_new(&bh)) {
-			clear_pmem(dax.addr, PMD_SIZE);
-			wmb_pmem();
-			count_vm_event(PGMAJFAULT);
-			mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
-			result |= VM_FAULT_MAJOR;
-		}
-		dax_unmap_atomic(bdev, &dax);
-
-		/*
-		 * For PTE faults we insert a radix tree entry for reads, and
-		 * leave it clean.  Then on the first write we dirty the radix
-		 * tree entry via the dax_pfn_mkwrite() path.  This sequence
-		 * allows the dax_pfn_mkwrite() call to be simpler and avoid a
-		 * call into get_block() to translate the pgoff to a sector in
-		 * order to be able to create a new radix tree entry.
-		 *
-		 * The PMD path doesn't have an equivalent to
-		 * dax_pfn_mkwrite(), though, so for a read followed by a
-		 * write we traverse all the way through dax_pmd_fault()
-		 * twice.  This means we can just skip inserting a radix tree
-		 * entry completely on the initial read and just wait until
-		 * the write to insert a dirty entry.
-		 */
-		if (write) {
-			error = dax_radix_entry(mapping, vmf->pgoff,
-						dax.sector, true, true);
-			if (error) {
-				dax_pmd_dbg(&bh, address,
-						"PMD radix insertion failed");
-				goto fallback;
-			}
-		}
-
-		dev_dbg(part_to_dev(bdev->bd_part),
-				"%s: %s addr: %lx pfn: %lx sect: %llx\n",
-				__func__, current->comm, address,
-				pfn_t_to_pfn(dax.pfn),
-				(unsigned long long) dax.sector);
-		result |= vmf_insert_pfn_pmd(vma, address, vmf->pmd,
-				dax.pfn, write);
+		result = dax_insert_pmd_mapping(inode, &bh, vma, vmf);
 	}
 
  out:
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
