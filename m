Message-Id: <20080108210016.685326347@redhat.com>
References: <20080108205939.323955454@redhat.com>
Date: Tue, 08 Jan 2008 15:59:56 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 17/19] handle mlocked pages during map/unmap and truncate
Content-Disposition: inline; filename=noreclaim-04.2-move-mlocked-pages-off-the-LRU.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

V2 -> V3:
+ rebase to 23-mm1 atop RvR's split lru series [no changes]

V1 -> V2:
+  modified mmap.c:mmap_region() to return error if mlock_vma_pages_range()
   does.  This can only occur if the vma gets removed/changed while
   we're switching mmap_sem lock modes.   Most callers don't care, but
   sys_remap_file_pages() appears to.

Rework of Nick Piggins's "mm: move mlocked pages off the LRU" patch
-- part 2 0f 2.

Remove mlocked pages from the LRU using "NoReclaim infrastructure"
during mmap()/mremap().  Try to move back to normal LRU lists on
munmap() when last locked mapping removed.  Removed PageMlocked()
status when page truncated from file.


Originally Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by:  Rik van Riel <riel@redhat.com>

Index: linux-2.6.24-rc6-mm1/mm/mmap.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/mmap.c	2007-12-23 23:45:44.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/mmap.c	2008-01-02 15:08:07.000000000 -0500
@@ -32,6 +32,8 @@
 #include <asm/tlb.h>
 #include <asm/mmu_context.h>
 
+#include "internal.h"
+
 #ifndef arch_mmap_check
 #define arch_mmap_check(addr, len, flags)	(0)
 #endif
@@ -1201,9 +1203,13 @@ out:	
 	vm_stat_account(mm, vm_flags, file, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
-		make_pages_present(addr, addr + len);
-	}
-	if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
+		/*
+		 * makes pages present; downgrades, drops, requires mmap_sem
+		 */
+		error = mlock_vma_pages_range(vma, addr, addr + len);
+		if (error)
+			return error;	/* vma gone! */
+	} else if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
 		make_pages_present(addr, addr + len);
 	return addr;
 
@@ -1886,6 +1892,19 @@ int do_munmap(struct mm_struct *mm, unsi
 	vma = prev? prev->vm_next: mm->mmap;
 
 	/*
+	 * unlock any mlock()ed ranges before detaching vmas
+	 */
+	if (mm->locked_vm) {
+		struct vm_area_struct *tmp = vma;
+		while (tmp && tmp->vm_start < end) {
+			if (tmp->vm_flags & VM_LOCKED)
+				munlock_vma_pages_range(tmp,
+						 tmp->vm_start, tmp->vm_end);
+			tmp = tmp->vm_next;
+		}
+	}
+
+	/*
 	 * Remove the vma's, and unmap the actual pages
 	 */
 	detach_vmas_to_be_unmapped(mm, vma, prev, end);
@@ -2021,7 +2040,7 @@ out:
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
-		make_pages_present(addr, addr + len);
+		mlock_vma_pages_range(vma, addr, addr + len);
 	}
 	return addr;
 }
@@ -2032,13 +2051,26 @@ EXPORT_SYMBOL(do_brk);
 void exit_mmap(struct mm_struct *mm)
 {
 	struct mmu_gather *tlb;
-	struct vm_area_struct *vma = mm->mmap;
+	struct vm_area_struct *vma;
 	unsigned long nr_accounted = 0;
 	unsigned long end;
 
 	/* mm's last user has gone, and its about to be pulled down */
 	arch_exit_mmap(mm);
 
+	if (mm->locked_vm) {
+		vma = mm->mmap;
+		while (vma) {
+			if (vma->vm_flags & VM_LOCKED)
+				munlock_vma_pages_range(vma,
+						vma->vm_start, vma->vm_end);
+			vma = vma->vm_next;
+		}
+	}
+
+	vma = mm->mmap;
+
+
 	lru_add_drain();
 	flush_cache_mm(mm);
 	tlb = tlb_gather_mmu(mm, 1);
Index: linux-2.6.24-rc6-mm1/mm/mremap.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/mremap.c	2007-12-23 23:45:36.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/mremap.c	2008-01-02 15:08:07.000000000 -0500
@@ -23,6 +23,8 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
+#include "internal.h"
+
 static pmd_t *get_old_pmd(struct mm_struct *mm, unsigned long addr)
 {
 	pgd_t *pgd;
@@ -232,8 +234,8 @@ static unsigned long move_vma(struct vm_
 	if (vm_flags & VM_LOCKED) {
 		mm->locked_vm += new_len >> PAGE_SHIFT;
 		if (new_len > old_len)
-			make_pages_present(new_addr + old_len,
-					   new_addr + new_len);
+			mlock_vma_pages_range(vma, new_addr + old_len,
+						   new_addr + new_len);
 	}
 
 	return new_addr;
@@ -373,7 +375,7 @@ unsigned long do_mremap(unsigned long ad
 			vm_stat_account(mm, vma->vm_flags, vma->vm_file, pages);
 			if (vma->vm_flags & VM_LOCKED) {
 				mm->locked_vm += pages;
-				make_pages_present(addr + old_len,
+				mlock_vma_pages_range(vma, addr + old_len,
 						   addr + new_len);
 			}
 			ret = addr;
Index: linux-2.6.24-rc6-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/vmscan.c	2008-01-02 15:04:11.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/vmscan.c	2008-01-02 15:08:07.000000000 -0500
@@ -540,6 +540,10 @@ static unsigned long shrink_page_list(st
 				goto activate_locked;
 			case SWAP_AGAIN:
 				goto keep_locked;
+			case SWAP_MLOCK:
+				ClearPageActive(page);
+				SetPageNoreclaim(page);
+				goto keep_locked;	/* to noreclaim list */
 			case SWAP_SUCCESS:
 				; /* try to free the page below */
 			}
Index: linux-2.6.24-rc6-mm1/mm/filemap.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/filemap.c	2008-01-02 12:37:38.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/filemap.c	2008-01-02 15:08:07.000000000 -0500
@@ -2525,8 +2525,16 @@ generic_file_direct_IO(int rw, struct ki
 	if (rw == WRITE) {
 		write_len = iov_length(iov, nr_segs);
 		end = (offset + write_len - 1) >> PAGE_CACHE_SHIFT;
-	       	if (mapping_mapped(mapping))
+		if (mapping_mapped(mapping)) {
+			/*
+			 * Calling unmap_mapping_range like this is wrong,
+			 * because it can lead to mlocked pages being
+			 * discarded (this is true even before the Noreclaim
+			 * mlock work). direct-IO vs pagecache is a load of
+			 * junk anyway, so who cares.
+			 */
 			unmap_mapping_range(mapping, offset, write_len, 0);
+		}
 	}
 
 	retval = filemap_write_and_wait(mapping);
Index: linux-2.6.24-rc6-mm1/mm/truncate.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/truncate.c	2007-12-23 23:45:44.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/truncate.c	2008-01-02 15:08:07.000000000 -0500
@@ -18,6 +18,7 @@
 #include <linux/task_io_accounting_ops.h>
 #include <linux/buffer_head.h>	/* grr. try_to_release_page,
 				   do_invalidatepage */
+#include "internal.h"
 
 
 /**
@@ -104,6 +105,7 @@ truncate_complete_page(struct address_sp
 	cancel_dirty_page(page, PAGE_CACHE_SIZE);
 
 	remove_from_page_cache(page);
+	clear_page_mlock(page);
 	ClearPageUptodate(page);
 	ClearPageMappedToDisk(page);
 	page_cache_release(page);	/* pagecache ref */
@@ -128,6 +130,7 @@ invalidate_complete_page(struct address_
 	if (PagePrivate(page) && !try_to_release_page(page, 0))
 		return 0;
 
+	clear_page_mlock(page);
 	ret = remove_mapping(mapping, page);
 
 	return ret;
@@ -354,6 +357,7 @@ invalidate_complete_page2(struct address
 	if (PageDirty(page))
 		goto failed;
 
+	clear_page_mlock(page);
 	BUG_ON(PagePrivate(page));
 	__remove_from_page_cache(page);
 	write_unlock_irq(&mapping->tree_lock);

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
