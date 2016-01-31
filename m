Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2A149828DF
	for <linux-mm@kvack.org>; Sun, 31 Jan 2016 07:20:11 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id n128so67243858pfn.3
        for <linux-mm@kvack.org>; Sun, 31 Jan 2016 04:20:11 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id l4si31215097pfi.249.2016.01.31.04.20.04
        for <linux-mm@kvack.org>;
        Sun, 31 Jan 2016 04:20:04 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 4/6] dax: Use PAGE_CACHE_SIZE where appropriate
Date: Sun, 31 Jan 2016 23:19:53 +1100
Message-Id: <1454242795-18038-5-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1454242795-18038-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1454242795-18038-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

We were a little sloppy about using PAGE_SIZE instead of PAGE_CACHE_SIZE.
The important thing to remember is that the VM is gicing us a pgoff_t
and asking us to populate that.  If PAGE_CACHE_SIZE were larger than
PAGE_SIZE, then we would not successfully fill in the PTEs for faults
that occurred in the upper portions of PAGE_CACHE_SIZE.

Of course, we actually only fill in one PTE, so this still doesn't solve
the problem.  I have my doubts we will ever increase PAGE_CACHE_SIZE
now that we have map_pages.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/dax.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index d0e1334..f0c204d 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -558,14 +558,14 @@ static int dax_pte_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	int error;
 	int major = 0;
 
-	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	if (vmf->pgoff >= size)
 		return VM_FAULT_SIGBUS;
 
 	memset(&bh, 0, sizeof(bh));
-	block = (sector_t)vmf->pgoff << (PAGE_SHIFT - blkbits);
+	block = (sector_t)vmf->pgoff << (PAGE_CACHE_SHIFT - blkbits);
 	bh.b_bdev = inode->i_sb->s_bdev;
-	bh.b_size = PAGE_SIZE;
+	bh.b_size = PAGE_CACHE_SIZE;
 
  repeat:
 	page = find_get_page(mapping, vmf->pgoff);
@@ -582,7 +582,7 @@ static int dax_pte_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	}
 
 	error = get_block(inode, block, &bh, 0);
-	if (!error && (bh.b_size < PAGE_SIZE))
+	if (!error && (bh.b_size < PAGE_CACHE_SIZE))
 		error = -EIO;		/* fs corruption? */
 	if (error)
 		goto unlock_page;
@@ -593,7 +593,7 @@ static int dax_pte_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 			count_vm_event(PGMAJFAULT);
 			mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
 			major = VM_FAULT_MAJOR;
-			if (!error && (bh.b_size < PAGE_SIZE))
+			if (!error && (bh.b_size < PAGE_CACHE_SIZE))
 				error = -EIO;
 			if (error)
 				goto unlock_page;
@@ -630,7 +630,7 @@ static int dax_pte_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		page = find_lock_page(mapping, vmf->pgoff);
 
 	if (page) {
-		unmap_mapping_range(mapping, vmf->pgoff << PAGE_SHIFT,
+		unmap_mapping_range(mapping, vmf->pgoff << PAGE_CACHE_SHIFT,
 							PAGE_CACHE_SIZE, 0);
 		delete_from_page_cache(page);
 		unlock_page(page);
@@ -677,7 +677,7 @@ static int dax_pte_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
  * The 'colour' (ie low bits) within a PMD of a page offset.  This comes up
  * more often than one might expect in the below function.
  */
-#define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)
+#define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_CACHE_SHIFT) - 1)
 
 static void __dax_dbg(struct buffer_head *bh, unsigned long address,
 		const char *reason, const char *fn)
@@ -734,7 +734,7 @@ static int dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		return VM_FAULT_FALLBACK;
 	}
 
-	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	if (vmf->pgoff >= size)
 		return VM_FAULT_SIGBUS;
 	/* If the PMD would cover blocks out of the file */
@@ -746,7 +746,7 @@ static int dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 
 	memset(&bh, 0, sizeof(bh));
 	bh.b_bdev = inode->i_sb->s_bdev;
-	block = (sector_t)vmf->pgoff << (PAGE_SHIFT - blkbits);
+	block = (sector_t)vmf->pgoff << (PAGE_CACHE_SHIFT - blkbits);
 
 	bh.b_size = PMD_SIZE;
 
@@ -776,7 +776,7 @@ static int dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	 * zero pages covering this hole
 	 */
 	if (alloc) {
-		loff_t lstart = vmf->pgoff << PAGE_SHIFT;
+		loff_t lstart = vmf->pgoff << PAGE_CACHE_SHIFT;
 		loff_t lend = lstart + PMD_SIZE - 1; /* inclusive */
 
 		truncate_pagecache_range(inode, lstart, lend);
@@ -904,7 +904,7 @@ static int dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
  * The 'colour' (ie low bits) within a PUD of a page offset.  This comes up
  * more often than one might expect in the below function.
  */
-#define PG_PUD_COLOUR	((PUD_SIZE >> PAGE_SHIFT) - 1)
+#define PG_PUD_COLOUR	((PUD_SIZE >> PAGE_CACHE_SHIFT) - 1)
 
 #define dax_pud_dbg(bh, address, reason)	__dax_dbg(bh, address, reason, "dax_pud")
 
@@ -945,7 +945,7 @@ static int dax_pud_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		return VM_FAULT_FALLBACK;
 	}
 
-	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	if (vmf->pgoff >= size)
 		return VM_FAULT_SIGBUS;
 	/* If the PUD would cover blocks out of the file */
@@ -957,7 +957,7 @@ static int dax_pud_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 
 	memset(&bh, 0, sizeof(bh));
 	bh.b_bdev = inode->i_sb->s_bdev;
-	block = (sector_t)vmf->pgoff << (PAGE_SHIFT - blkbits);
+	block = (sector_t)vmf->pgoff << (PAGE_CACHE_SHIFT - blkbits);
 
 	bh.b_size = PUD_SIZE;
 
@@ -987,7 +987,7 @@ static int dax_pud_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	 * zero pages covering this hole
 	 */
 	if (alloc) {
-		loff_t lstart = vmf->pgoff << PAGE_SHIFT;
+		loff_t lstart = vmf->pgoff << PAGE_CACHE_SHIFT;
 		loff_t lend = lstart + PUD_SIZE - 1; /* inclusive */
 
 		truncate_pagecache_range(inode, lstart, lend);
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
