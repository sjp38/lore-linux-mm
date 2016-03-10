Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id A4ABB828E1
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 19:03:29 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id u190so51088064pfb.3
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 16:03:29 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id bz6si9301421pad.30.2016.03.10.15.55.40
        for <linux-mm@kvack.org>;
        Thu, 10 Mar 2016 15:55:41 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v5 14/14] dax: Use vmf->pgoff in fault handlers
Date: Thu, 10 Mar 2016 18:55:31 -0500
Message-Id: <1457654131-4562-15-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1457654131-4562-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1457654131-4562-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, willy@linux.intel.com

Now that the PMD and PUD fault handlers are passed pgoff, there's no
need to calculate it themselves.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/dax.c | 26 ++++++++++++--------------
 1 file changed, 12 insertions(+), 14 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index c5d87be..5db3841 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -736,7 +736,7 @@ static int dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	unsigned long pmd_addr = address & PMD_MASK;
 	bool write = vmf->flags & FAULT_FLAG_WRITE;
 	struct block_device *bdev;
-	pgoff_t size, pgoff;
+	pgoff_t size;
 	sector_t block;
 	int error, result = 0;
 	bool alloc = false;
@@ -761,12 +761,11 @@ static int dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		return VM_FAULT_FALLBACK;
 	}
 
-	pgoff = linear_page_index(vma, pmd_addr);
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	if (pgoff >= size)
+	if (vmf->pgoff >= size)
 		return VM_FAULT_SIGBUS;
 	/* If the PMD would cover blocks out of the file */
-	if ((pgoff | PG_PMD_COLOUR) >= size) {
+	if ((vmf->pgoff | PG_PMD_COLOUR) >= size) {
 		dax_pmd_dbg(NULL, address,
 				"offset + huge page size > file size");
 		return VM_FAULT_FALLBACK;
@@ -774,7 +773,7 @@ static int dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 
 	memset(&bh, 0, sizeof(bh));
 	bh.b_bdev = inode->i_sb->s_bdev;
-	block = (sector_t)pgoff << (PAGE_SHIFT - blkbits);
+	block = (sector_t)vmf->pgoff << (PAGE_SHIFT - blkbits);
 
 	bh.b_size = PMD_SIZE;
 
@@ -804,7 +803,7 @@ static int dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	 * zero pages covering this hole
 	 */
 	if (alloc) {
-		loff_t lstart = pgoff << PAGE_SHIFT;
+		loff_t lstart = vmf->pgoff << PAGE_SHIFT;
 		loff_t lend = lstart + PMD_SIZE - 1; /* inclusive */
 
 		truncate_pagecache_range(inode, lstart, lend);
@@ -890,8 +889,8 @@ static int dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		 * the write to insert a dirty entry.
 		 */
 		if (write) {
-			error = dax_radix_entry(mapping, pgoff, dax.sector,
-					true, true);
+			error = dax_radix_entry(mapping, vmf->pgoff,
+						dax.sector, true, true);
 			if (error) {
 				dax_pmd_dbg(&bh, address,
 						"PMD radix insertion failed");
@@ -942,7 +941,7 @@ static int dax_pud_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	unsigned long pud_addr = address & PUD_MASK;
 	bool write = vmf->flags & FAULT_FLAG_WRITE;
 	struct block_device *bdev;
-	pgoff_t size, pgoff;
+	pgoff_t size;
 	sector_t block;
 	int result = 0;
 	bool alloc = false;
@@ -967,12 +966,11 @@ static int dax_pud_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		return VM_FAULT_FALLBACK;
 	}
 
-	pgoff = linear_page_index(vma, pud_addr);
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	if (pgoff >= size)
+	if (vmf->pgoff >= size)
 		return VM_FAULT_SIGBUS;
 	/* If the PUD would cover blocks out of the file */
-	if ((pgoff | PG_PUD_COLOUR) >= size) {
+	if ((vmf->pgoff | PG_PUD_COLOUR) >= size) {
 		dax_pud_dbg(NULL, address,
 				"offset + huge page size > file size");
 		return VM_FAULT_FALLBACK;
@@ -980,7 +978,7 @@ static int dax_pud_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 
 	memset(&bh, 0, sizeof(bh));
 	bh.b_bdev = inode->i_sb->s_bdev;
-	block = (sector_t)pgoff << (PAGE_SHIFT - blkbits);
+	block = (sector_t)vmf->pgoff << (PAGE_SHIFT - blkbits);
 
 	bh.b_size = PUD_SIZE;
 
@@ -1010,7 +1008,7 @@ static int dax_pud_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	 * zero pages covering this hole
 	 */
 	if (alloc) {
-		loff_t lstart = pgoff << PAGE_SHIFT;
+		loff_t lstart = vmf->pgoff << PAGE_SHIFT;
 		loff_t lend = lstart + PUD_SIZE - 1; /* inclusive */
 
 		truncate_pagecache_range(inode, lstart, lend);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
