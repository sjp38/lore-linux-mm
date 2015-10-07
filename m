Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 67B8C6B0253
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 18:58:55 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so33934613pab.3
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 15:58:55 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id yi1si61140198pbb.246.2015.10.07.15.58.54
        for <linux-mm@kvack.org>;
        Wed, 07 Oct 2015 15:58:54 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v5] mm, dax: fix DAX deadlocks
Date: Wed,  7 Oct 2015 16:58:49 -0600
Message-Id: <1444258729-21974-2-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1444258729-21974-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1444258729-21974-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <matthew.r.wilcox@intel.com>

The following two locking commits in the DAX code:

commit 843172978bb9 ("dax: fix race between simultaneous faults")
commit 46c043ede471 ("mm: take i_mmap_lock in unmap_mapping_range() for DAX")

introduced a number of deadlocks and other issues which need to be fixed
for the v4.3 kernel. The list of issues in DAX after these commits (some
newly introduced by the commits, some preexisting) can be found here:

https://lkml.org/lkml/2015/9/25/602

This undoes most of the changes introduced by those two commits,
essentially returning us to the DAX locking scheme that was used in v4.2.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c    | 70 +++++++++++++++++++++++++------------------------------------
 mm/memory.c |  2 ++
 2 files changed, 31 insertions(+), 41 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index bcfb14b..a86d3cc 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -285,6 +285,7 @@ static int copy_user_bh(struct page *to, struct buffer_head *bh,
 static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 			struct vm_area_struct *vma, struct vm_fault *vmf)
 {
+	struct address_space *mapping = inode->i_mapping;
 	sector_t sector = bh->b_blocknr << (inode->i_blkbits - 9);
 	unsigned long vaddr = (unsigned long)vmf->virtual_address;
 	void __pmem *addr;
@@ -292,6 +293,8 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	pgoff_t size;
 	int error;
 
+	i_mmap_lock_read(mapping);
+
 	/*
 	 * Check truncate didn't happen while we were allocating a block.
 	 * If it did, this block may or may not be still allocated to the
@@ -321,6 +324,8 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	error = vm_insert_mixed(vma, vaddr, pfn);
 
  out:
+	i_mmap_unlock_read(mapping);
+
 	return error;
 }
 
@@ -382,17 +387,15 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 			 * from a read fault and we've raced with a truncate
 			 */
 			error = -EIO;
-			goto unlock;
+			goto unlock_page;
 		}
-	} else {
-		i_mmap_lock_write(mapping);
 	}
 
 	error = get_block(inode, block, &bh, 0);
 	if (!error && (bh.b_size < PAGE_SIZE))
 		error = -EIO;		/* fs corruption? */
 	if (error)
-		goto unlock;
+		goto unlock_page;
 
 	if (!buffer_mapped(&bh) && !buffer_unwritten(&bh) && !vmf->cow_page) {
 		if (vmf->flags & FAULT_FLAG_WRITE) {
@@ -403,9 +406,8 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 			if (!error && (bh.b_size < PAGE_SIZE))
 				error = -EIO;
 			if (error)
-				goto unlock;
+				goto unlock_page;
 		} else {
-			i_mmap_unlock_write(mapping);
 			return dax_load_hole(mapping, page, vmf);
 		}
 	}
@@ -417,15 +419,17 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		else
 			clear_user_highpage(new_page, vaddr);
 		if (error)
-			goto unlock;
+			goto unlock_page;
 		vmf->page = page;
 		if (!page) {
+			i_mmap_lock_read(mapping);
 			/* Check we didn't race with truncate */
 			size = (i_size_read(inode) + PAGE_SIZE - 1) >>
 								PAGE_SHIFT;
 			if (vmf->pgoff >= size) {
+				i_mmap_unlock_read(mapping);
 				error = -EIO;
-				goto unlock;
+				goto out;
 			}
 		}
 		return VM_FAULT_LOCKED;
@@ -461,8 +465,6 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 			WARN_ON_ONCE(!(vmf->flags & FAULT_FLAG_WRITE));
 	}
 
-	if (!page)
-		i_mmap_unlock_write(mapping);
  out:
 	if (error == -ENOMEM)
 		return VM_FAULT_OOM | major;
@@ -471,14 +473,11 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		return VM_FAULT_SIGBUS | major;
 	return VM_FAULT_NOPAGE | major;
 
- unlock:
+ unlock_page:
 	if (page) {
 		unlock_page(page);
 		page_cache_release(page);
-	} else {
-		i_mmap_unlock_write(mapping);
 	}
-
 	goto out;
 }
 EXPORT_SYMBOL(__dax_fault);
@@ -556,10 +555,10 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	block = (sector_t)pgoff << (PAGE_SHIFT - blkbits);
 
 	bh.b_size = PMD_SIZE;
-	i_mmap_lock_write(mapping);
 	length = get_block(inode, block, &bh, write);
 	if (length)
 		return VM_FAULT_SIGBUS;
+	i_mmap_lock_read(mapping);
 
 	/*
 	 * If the filesystem isn't willing to tell us the length of a hole,
@@ -569,36 +568,14 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE)
 		goto fallback;
 
-	sector = bh.b_blocknr << (blkbits - 9);
-
-	if (buffer_unwritten(&bh) || buffer_new(&bh)) {
-		int i;
-
-		length = bdev_direct_access(bh.b_bdev, sector, &kaddr, &pfn,
-						bh.b_size);
-		if (length < 0) {
-			result = VM_FAULT_SIGBUS;
-			goto out;
-		}
-		if ((length < PMD_SIZE) || (pfn & PG_PMD_COLOUR))
-			goto fallback;
-
-		for (i = 0; i < PTRS_PER_PMD; i++)
-			clear_pmem(kaddr + i * PAGE_SIZE, PAGE_SIZE);
-		wmb_pmem();
-		count_vm_event(PGMAJFAULT);
-		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
-		result |= VM_FAULT_MAJOR;
-	}
-
 	/*
 	 * If we allocated new storage, make sure no process has any
 	 * zero pages covering this hole
 	 */
 	if (buffer_new(&bh)) {
-		i_mmap_unlock_write(mapping);
+		i_mmap_unlock_read(mapping);
 		unmap_mapping_range(mapping, pgoff << PAGE_SHIFT, PMD_SIZE, 0);
-		i_mmap_lock_write(mapping);
+		i_mmap_lock_read(mapping);
 	}
 
 	/*
@@ -635,6 +612,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		result = VM_FAULT_NOPAGE;
 		spin_unlock(ptl);
 	} else {
+		sector = bh.b_blocknr << (blkbits - 9);
 		length = bdev_direct_access(bh.b_bdev, sector, &kaddr, &pfn,
 						bh.b_size);
 		if (length < 0) {
@@ -644,15 +622,25 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		if ((length < PMD_SIZE) || (pfn & PG_PMD_COLOUR))
 			goto fallback;
 
+		if (buffer_unwritten(&bh) || buffer_new(&bh)) {
+			int i;
+			for (i = 0; i < PTRS_PER_PMD; i++)
+				clear_pmem(kaddr + i * PAGE_SIZE, PAGE_SIZE);
+			wmb_pmem();
+			count_vm_event(PGMAJFAULT);
+			mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
+			result |= VM_FAULT_MAJOR;
+		}
+
 		result |= vmf_insert_pfn_pmd(vma, address, pmd, pfn, write);
 	}
 
  out:
+	i_mmap_unlock_read(mapping);
+
 	if (buffer_unwritten(&bh))
 		complete_unwritten(&bh, !(result & VM_FAULT_ERROR));
 
-	i_mmap_unlock_write(mapping);
-
 	return result;
 
  fallback:
diff --git a/mm/memory.c b/mm/memory.c
index 9cb2747..deb679c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2426,6 +2426,8 @@ void unmap_mapping_range(struct address_space *mapping,
 	if (details.last_index < details.first_index)
 		details.last_index = ULONG_MAX;
 
+
+	/* DAX uses i_mmap_lock to serialise file truncate vs page fault */
 	i_mmap_lock_write(mapping);
 	if (unlikely(!RB_EMPTY_ROOT(&mapping->i_mmap)))
 		unmap_mapping_range_tree(&mapping->i_mmap, &details);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
