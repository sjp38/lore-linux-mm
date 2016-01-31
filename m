Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id C5C9C828DF
	for <linux-mm@kvack.org>; Sun, 31 Jan 2016 07:20:06 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id cy9so66376909pac.0
        for <linux-mm@kvack.org>; Sun, 31 Jan 2016 04:20:06 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id tc5si16572412pab.176.2016.01.31.04.20.04
        for <linux-mm@kvack.org>;
        Sun, 31 Jan 2016 04:20:04 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 6/6] dax: Factor dax_insert_pud_mapping out of dax_pud_fault
Date: Sun, 31 Jan 2016 23:19:55 +1100
Message-Id: <1454242795-18038-7-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1454242795-18038-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1454242795-18038-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

Follow the factoring done for dax_pmd_fault.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/dax.c | 100 +++++++++++++++++++++++++++++++++------------------------------
 1 file changed, 53 insertions(+), 47 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index ec31e6e..e9701d6 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -915,6 +915,57 @@ static int dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 
 #define dax_pud_dbg(bh, address, reason)	__dax_dbg(bh, address, reason, "dax_pud")
 
+static int dax_insert_pud_mapping(struct inode *inode, struct buffer_head *bh,
+			struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	int major = 0;
+	struct blk_dax_ctl dax = {
+		.sector = to_sector(bh, inode),
+		.size = PUD_SIZE,
+	};
+	struct block_device *bdev = bh->b_bdev;
+	bool write = vmf->flags & FAULT_FLAG_WRITE;
+	unsigned long address = (unsigned long)vmf->virtual_address;
+	long length = dax_map_atomic(bdev, &dax);
+
+	if (length < 0)
+		return VM_FAULT_SIGBUS;
+	if (length < PUD_SIZE) {
+		dax_pud_dbg(bh, address, "dax-length too small");
+		goto unmap;
+	}
+	if (pfn_t_to_pfn(dax.pfn) & PG_PUD_COLOUR) {
+		dax_pud_dbg(bh, address, "pfn unaligned");
+		goto unmap;
+	}
+
+	if (!pfn_t_devmap(dax.pfn)) {
+		dax_pud_dbg(bh, address, "pfn not in memmap");
+		goto unmap;
+	}
+
+	if (buffer_unwritten(bh) || buffer_new(bh)) {
+		clear_pmem(dax.addr, PUD_SIZE);
+		wmb_pmem();
+		count_vm_event(PGMAJFAULT);
+		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
+		major = VM_FAULT_MAJOR;
+	}
+	dax_unmap_atomic(bdev, &dax);
+
+	dev_dbg(part_to_dev(bdev->bd_part),
+			"%s: %s addr: %lx pfn: %lx sect: %llx\n",
+			__func__, current->comm, address,
+			pfn_t_to_pfn(dax.pfn),
+			(unsigned long long) dax.sector);
+	return major | vmf_insert_pfn_pud(vma, address, vmf->pud,
+						dax.pfn, write);
+ unmap:
+	dax_unmap_atomic(bdev, &dax);
+	count_vm_event(THP_FAULT_FALLBACK);
+	return VM_FAULT_FALLBACK;
+}
+
 static int dax_pud_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		get_block_t get_block, dax_iodone_t complete_unwritten)
 {
@@ -926,10 +977,9 @@ static int dax_pud_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	unsigned long address = (unsigned long)vmf->virtual_address;
 	unsigned long pud_addr = address & PUD_MASK;
 	bool write = vmf->flags & FAULT_FLAG_WRITE;
-	struct block_device *bdev;
 	pgoff_t size;
 	sector_t block;
-	int result = 0;
+	int result;
 	bool alloc = false;
 
 	/* dax pud mappings require pfn_t_devmap() */
@@ -977,8 +1027,6 @@ static int dax_pud_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		alloc = true;
 	}
 
-	bdev = bh.b_bdev;
-
 	/*
 	 * If the filesystem isn't willing to tell us the length of a hole,
 	 * just fall back to PMDs.  Calling get_block 512 times in a loop
@@ -1004,49 +1052,7 @@ static int dax_pud_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		dax_pud_dbg(&bh, address, "no zero page");
 		goto fallback;
 	} else {
-		struct blk_dax_ctl dax = {
-			.sector = to_sector(&bh, inode),
-			.size = PUD_SIZE,
-		};
-		long length = dax_map_atomic(bdev, &dax);
-
-		if (length < 0) {
-			result = VM_FAULT_SIGBUS;
-			goto out;
-		}
-		if (length < PUD_SIZE) {
-			dax_pud_dbg(&bh, address, "dax-length too small");
-			dax_unmap_atomic(bdev, &dax);
-			goto fallback;
-		}
-		if (pfn_t_to_pfn(dax.pfn) & PG_PUD_COLOUR) {
-			dax_pud_dbg(&bh, address, "pfn unaligned");
-			dax_unmap_atomic(bdev, &dax);
-			goto fallback;
-		}
-
-		if (!pfn_t_devmap(dax.pfn)) {
-			dax_unmap_atomic(bdev, &dax);
-			dax_pud_dbg(&bh, address, "pfn not in memmap");
-			goto fallback;
-		}
-
-		if (buffer_unwritten(&bh) || buffer_new(&bh)) {
-			clear_pmem(dax.addr, PUD_SIZE);
-			wmb_pmem();
-			count_vm_event(PGMAJFAULT);
-			mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
-			result |= VM_FAULT_MAJOR;
-		}
-		dax_unmap_atomic(bdev, &dax);
-
-		dev_dbg(part_to_dev(bdev->bd_part),
-				"%s: %s addr: %lx pfn: %lx sect: %llx\n",
-				__func__, current->comm, address,
-				pfn_t_to_pfn(dax.pfn),
-				(unsigned long long) dax.sector);
-		result |= vmf_insert_pfn_pud(vma, address, vmf->pud,
-				dax.pfn, write);
+		result = dax_insert_pud_mapping(inode, &bh, vma, vmf);
 	}
 
  out:
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
