Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id ABCC4828DF
	for <linux-mm@kvack.org>; Sun, 31 Jan 2016 07:20:03 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id uo6so67491547pac.1
        for <linux-mm@kvack.org>; Sun, 31 Jan 2016 04:20:03 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id 63si3586992pft.59.2016.01.31.04.19.58
        for <linux-mm@kvack.org>;
        Sun, 31 Jan 2016 04:19:59 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 2/6] dax: Remove unnecessary rechecking of i_size
Date: Sun, 31 Jan 2016 23:19:51 +1100
Message-Id: <1454242795-18038-3-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1454242795-18038-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1454242795-18038-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

When i_mmap_lock (or the page lock) was the only protection against
truncate, we checked i_size at the beginning of the fault handler,
then rechecked it after acquiring the lock.  Since the fliesystems now
exclude truncate from racing with the fault handler, we no longer need
to recheck i_size.  We do, of course, still need to check i_size at the
entry to the fault handler.

Also remove the now-unnecessary acquisitions of i_mmap_lock.  One of
the acquisitions is still needed, so put a big fat comment beside it to
prevent the well-intentioned from removing it.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/dax.c | 98 +++++++---------------------------------------------------------
 1 file changed, 10 insertions(+), 88 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 11be8c7..696ff90 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -288,21 +288,11 @@ EXPORT_SYMBOL_GPL(dax_do_io);
 static int dax_load_hole(struct address_space *mapping, struct page *page,
 							struct vm_fault *vmf)
 {
-	unsigned long size;
-	struct inode *inode = mapping->host;
 	if (!page)
 		page = find_or_create_page(mapping, vmf->pgoff,
 						vmf->gfp_mask | __GFP_ZERO);
 	if (!page)
 		return VM_FAULT_OOM;
-	/* Recheck i_size under page lock to avoid truncate race */
-	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	if (vmf->pgoff >= size) {
-		unlock_page(page);
-		page_cache_release(page);
-		return VM_FAULT_SIGBUS;
-	}
-
 	vmf->page = page;
 	return VM_FAULT_LOCKED;
 }
@@ -529,24 +519,8 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 		.sector = to_sector(bh, inode),
 		.size = bh->b_size,
 	};
-	pgoff_t size;
 	int error;
 
-	i_mmap_lock_read(mapping);
-
-	/*
-	 * Check truncate didn't happen while we were allocating a block.
-	 * If it did, this block may or may not be still allocated to the
-	 * file.  We can't tell the filesystem to free it because we can't
-	 * take i_mutex here.  In the worst case, the file still has blocks
-	 * allocated past the end of the file.
-	 */
-	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	if (unlikely(vmf->pgoff >= size)) {
-		error = -EIO;
-		goto out;
-	}
-
 	if (dax_map_atomic(bdev, &dax) < 0) {
 		error = PTR_ERR(dax.addr);
 		goto out;
@@ -566,8 +540,6 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	error = vm_insert_mixed(vma, vaddr, dax.pfn);
 
  out:
-	i_mmap_unlock_read(mapping);
-
 	return error;
 }
 
@@ -607,15 +579,6 @@ static int dax_pte_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 			page_cache_release(page);
 			goto repeat;
 		}
-		size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
-		if (unlikely(vmf->pgoff >= size)) {
-			/*
-			 * We have a struct page covering a hole in the file
-			 * from a read fault and we've raced with a truncate
-			 */
-			error = -EIO;
-			goto unlock_page;
-		}
 	}
 
 	error = get_block(inode, block, &bh, 0);
@@ -648,17 +611,17 @@ static int dax_pte_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		if (error)
 			goto unlock_page;
 		vmf->page = page;
-		if (!page) {
+
+		/*
+		 * A truncate must remove COWs of pages that are removed
+		 * from the file.  If we have a struct page, the normal
+		 * page lock mechanism prevents truncate from missing the
+		 * COWed page.  If not, the i_mmap_lock can provide the
+		 * same guarantee.  It is dropped by the caller after the
+		 * page is safely in the page tables.
+		 */
+		if (!page)
 			i_mmap_lock_read(mapping);
-			/* Check we didn't race with truncate */
-			size = (i_size_read(inode) + PAGE_SIZE - 1) >>
-								PAGE_SHIFT;
-			if (vmf->pgoff >= size) {
-				i_mmap_unlock_read(mapping);
-				error = -EIO;
-				goto out;
-			}
-		}
 		return VM_FAULT_LOCKED;
 	}
 
@@ -820,25 +783,6 @@ static int dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		truncate_pagecache_range(inode, lstart, lend);
 	}
 
-	i_mmap_lock_read(mapping);
-
-	/*
-	 * If a truncate happened while we were allocating blocks, we may
-	 * leave blocks allocated to the file that are beyond EOF.  We can't
-	 * take i_mutex here, so just leave them hanging; they'll be freed
-	 * when the file is deleted.
-	 */
-	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	if (pgoff >= size) {
-		result = VM_FAULT_SIGBUS;
-		goto out;
-	}
-	if ((pgoff | PG_PMD_COLOUR) >= size) {
-		dax_pmd_dbg(&bh, address,
-				"offset + huge page size > file size");
-		goto fallback;
-	}
-
 	if (!write && !buffer_mapped(&bh) && buffer_uptodate(&bh)) {
 		spinlock_t *ptl;
 		pmd_t entry, *pmd = vmf->pmd;
@@ -938,8 +882,6 @@ static int dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	}
 
  out:
-	i_mmap_unlock_read(mapping);
-
 	if (buffer_unwritten(&bh))
 		complete_unwritten(&bh, !(result & VM_FAULT_ERROR));
 
@@ -1053,24 +995,6 @@ static int dax_pud_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		truncate_pagecache_range(inode, lstart, lend);
 	}
 
-	i_mmap_lock_read(mapping);
-
-	/*
-	 * If a truncate happened while we were allocating blocks, we may
-	 * leave blocks allocated to the file that are beyond EOF.  We can't
-	 * take i_mutex here, so just leave them hanging; they'll be freed
-	 * when the file is deleted.
-	 */
-	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	if (pgoff >= size) {
-		result = VM_FAULT_SIGBUS;
-		goto out;
-	}
-	if ((pgoff | PG_PUD_COLOUR) >= size) {
-		dax_pud_dbg(&bh, address, "page extends outside VMA");
-		goto fallback;
-	}
-
 	if (!write && !buffer_mapped(&bh) && buffer_uptodate(&bh)) {
 		dax_pud_dbg(&bh, address, "no zero page");
 		goto fallback;
@@ -1121,8 +1045,6 @@ static int dax_pud_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	}
 
  out:
-	i_mmap_unlock_read(mapping);
-
 	if (buffer_unwritten(&bh))
 		complete_unwritten(&bh, !(result & VM_FAULT_ERROR));
 
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
