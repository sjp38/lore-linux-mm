Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 84DF26B0258
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 15:58:22 -0400 (EDT)
Received: by iodd187 with SMTP id d187so28270643iod.2
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 12:58:22 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ox5si882960pbc.7.2015.08.04.12.58.13
        for <linux-mm@kvack.org>;
        Tue, 04 Aug 2015 12:58:13 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 06/11] dax: Fix race between simultaneous faults
Date: Tue,  4 Aug 2015 15:58:00 -0400
Message-Id: <1438718285-21168-7-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

If two threads write-fault on the same hole at the same time, the winner
of the race will return to userspace and complete their store, only to
have the loser overwrite their store with zeroes.  Fix this for now by
taking the i_mmap_sem for write instead of read, and do so outside the
call to get_block().  Now the loser of the race will see the block has
already been zeroed, and will not zero it again.

This severely limits our scalability.  I have ideas for improving it,
but those can wait for a later patch.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 fs/dax.c    | 33 +++++++++++++++++----------------
 mm/memory.c | 11 ++++++++---
 2 files changed, 25 insertions(+), 19 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 0a13118..9daf005 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -272,7 +272,6 @@ static int copy_user_bh(struct page *to, struct buffer_head *bh,
 static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 			struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	struct address_space *mapping = inode->i_mapping;
 	sector_t sector = bh->b_blocknr << (inode->i_blkbits - 9);
 	unsigned long vaddr = (unsigned long)vmf->virtual_address;
 	void *addr;
@@ -280,8 +279,6 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	pgoff_t size;
 	int error;
 
-	i_mmap_lock_read(mapping);
-
 	/*
 	 * Check truncate didn't happen while we were allocating a block.
 	 * If it did, this block may or may not be still allocated to the
@@ -309,8 +306,6 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	error = vm_insert_mixed(vma, vaddr, pfn);
 
  out:
-	i_mmap_unlock_read(mapping);
-
 	return error;
 }
 
@@ -372,15 +367,17 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 			 * from a read fault and we've raced with a truncate
 			 */
 			error = -EIO;
-			goto unlock_page;
+			goto unlock;
 		}
+	} else {
+		i_mmap_lock_write(mapping);
 	}
 
 	error = get_block(inode, block, &bh, 0);
 	if (!error && (bh.b_size < PAGE_SIZE))
 		error = -EIO;		/* fs corruption? */
 	if (error)
-		goto unlock_page;
+		goto unlock;
 
 	if (!buffer_mapped(&bh) && !buffer_unwritten(&bh) && !vmf->cow_page) {
 		if (vmf->flags & FAULT_FLAG_WRITE) {
@@ -391,8 +388,9 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 			if (!error && (bh.b_size < PAGE_SIZE))
 				error = -EIO;
 			if (error)
-				goto unlock_page;
+				goto unlock;
 		} else {
+			i_mmap_unlock_write(mapping);
 			return dax_load_hole(mapping, page, vmf);
 		}
 	}
@@ -404,17 +402,15 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		else
 			clear_user_highpage(new_page, vaddr);
 		if (error)
-			goto unlock_page;
+			goto unlock;
 		vmf->page = page;
 		if (!page) {
-			i_mmap_lock_read(mapping);
 			/* Check we didn't race with truncate */
 			size = (i_size_read(inode) + PAGE_SIZE - 1) >>
 								PAGE_SHIFT;
 			if (vmf->pgoff >= size) {
-				i_mmap_unlock_read(mapping);
 				error = -EIO;
-				goto out;
+				goto unlock;
 			}
 		}
 		return VM_FAULT_LOCKED;
@@ -450,6 +446,8 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 			WARN_ON_ONCE(!(vmf->flags & FAULT_FLAG_WRITE));
 	}
 
+	if (!page)
+		i_mmap_unlock_write(mapping);
  out:
 	if (error == -ENOMEM)
 		return VM_FAULT_OOM | major;
@@ -458,11 +456,14 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		return VM_FAULT_SIGBUS | major;
 	return VM_FAULT_NOPAGE | major;
 
- unlock_page:
+ unlock:
 	if (page) {
 		unlock_page(page);
 		page_cache_release(page);
+	} else {
+		i_mmap_unlock_write(mapping);
 	}
+
 	goto out;
 }
 EXPORT_SYMBOL(__dax_fault);
@@ -540,10 +541,10 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	block = (sector_t)pgoff << (PAGE_SHIFT - blkbits);
 
 	bh.b_size = PMD_SIZE;
+	i_mmap_lock_write(mapping);
 	length = get_block(inode, block, &bh, write);
 	if (length)
 		return VM_FAULT_SIGBUS;
-	i_mmap_lock_read(mapping);
 
 	/*
 	 * If the filesystem isn't willing to tell us the length of a hole,
@@ -607,11 +608,11 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	}
 
  out:
-	i_mmap_unlock_read(mapping);
-
 	if (buffer_unwritten(&bh))
 		complete_unwritten(&bh, !(result & VM_FAULT_ERROR));
 
+	i_mmap_unlock_write(mapping);
+
 	return result;
 
  fallback:
diff --git a/mm/memory.c b/mm/memory.c
index b94b587..5f46350 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2426,11 +2426,16 @@ void unmap_mapping_range(struct address_space *mapping,
 		details.last_index = ULONG_MAX;
 
 
-	/* DAX uses i_mmap_lock to serialise file truncate vs page fault */
-	i_mmap_lock_write(mapping);
+	/*
+	 * DAX already holds i_mmap_lock to serialise file truncate vs
+	 * page fault and page fault vs page fault.
+	 */
+	if (!IS_DAX(mapping->host))
+		i_mmap_lock_write(mapping);
 	if (unlikely(!RB_EMPTY_ROOT(&mapping->i_mmap)))
 		unmap_mapping_range_tree(&mapping->i_mmap, &details);
-	i_mmap_unlock_write(mapping);
+	if (!IS_DAX(mapping->host))
+		i_mmap_unlock_write(mapping);
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
