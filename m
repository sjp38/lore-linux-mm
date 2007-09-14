From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 14 Sep 2007 16:55:25 -0400
Message-Id: <20070914205525.6536.73292.sendpatchset@localhost>
In-Reply-To: <20070914205359.6536.98017.sendpatchset@localhost>
References: <20070914205359.6536.98017.sendpatchset@localhost>
Subject: [PATCH/RFC 13/14] Reclaim Scalability:  Handle Mlock'ed pages during map/unmap and truncate
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

PATCH/RFC  13/14 Reclaim Scalability:  Handle Mlock'ed pages during map/unmap and truncate

Against:  2.6.23-rc4-mm1

Rework of Nick Piggins's "mm: move mlocked pages off the LRU" patch
-- part 2 0f 2.

Remove mlocked pages from the LRU using "NoReclaim infrastructure"
during mmap()/mremap().  Try to move back to normal LRU lists on
munmap() when last locked mapping removed.  Removed PageMlocked()
status when page truncated from file.


Originally Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/filemap.c  |   10 +++++++++-
 mm/mmap.c     |   34 +++++++++++++++++++++++++++++++---
 mm/mremap.c   |    8 +++++---
 mm/truncate.c |    4 ++++
 mm/vmscan.c   |    4 ++++
 5 files changed, 53 insertions(+), 7 deletions(-)

Index: Linux/mm/mmap.c
===================================================================
--- Linux.orig/mm/mmap.c	2007-09-14 10:09:41.000000000 -0400
+++ Linux/mm/mmap.c	2007-09-14 10:24:14.000000000 -0400
@@ -32,6 +32,8 @@
 #include <asm/tlb.h>
 #include <asm/mmu_context.h>
 
+#include "internal.h"
+
 #ifndef arch_mmap_check
 #define arch_mmap_check(addr, len, flags)	(0)
 #endif
@@ -1211,7 +1213,7 @@ out:	
 	vm_stat_account(mm, vm_flags, file, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
-		make_pages_present(addr, addr + len);
+		mlock_vma_pages_range(vma, addr, addr + len);
 	}
 	if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
 		make_pages_present(addr, addr + len);
@@ -1892,6 +1894,19 @@ int do_munmap(struct mm_struct *mm, unsi
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
@@ -2024,7 +2039,7 @@ out:
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
-		make_pages_present(addr, addr + len);
+		mlock_vma_pages_range(vma, addr, addr + len);
 	}
 	return addr;
 }
@@ -2035,13 +2050,26 @@ EXPORT_SYMBOL(do_brk);
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
Index: Linux/mm/mremap.c
===================================================================
--- Linux.orig/mm/mremap.c	2007-09-14 10:09:41.000000000 -0400
+++ Linux/mm/mremap.c	2007-09-14 10:24:14.000000000 -0400
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
Index: Linux/mm/vmscan.c
===================================================================
--- Linux.orig/mm/vmscan.c	2007-09-14 10:23:55.000000000 -0400
+++ Linux/mm/vmscan.c	2007-09-14 10:24:14.000000000 -0400
@@ -543,6 +543,10 @@ static unsigned long shrink_page_list(st
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
Index: Linux/mm/filemap.c
===================================================================
--- Linux.orig/mm/filemap.c	2007-09-14 10:09:41.000000000 -0400
+++ Linux/mm/filemap.c	2007-09-14 10:24:14.000000000 -0400
@@ -2497,8 +2497,16 @@ generic_file_direct_IO(int rw, struct ki
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
Index: Linux/mm/truncate.c
===================================================================
--- Linux.orig/mm/truncate.c	2007-09-14 10:09:41.000000000 -0400
+++ Linux/mm/truncate.c	2007-09-14 10:24:14.000000000 -0400
@@ -18,6 +18,7 @@
 #include <linux/task_io_accounting_ops.h>
 #include <linux/buffer_head.h>	/* grr. try_to_release_page,
 				   do_invalidatepage */
+#include "internal.h"
 
 
 /**
@@ -102,6 +103,7 @@ truncate_complete_page(struct address_sp
 		do_invalidatepage(page, 0);
 
 	remove_from_page_cache(page);
+	clear_page_mlock(page);
 	ClearPageUptodate(page);
 	ClearPageMappedToDisk(page);
 	page_cache_release(page);	/* pagecache ref */
@@ -126,6 +128,7 @@ invalidate_complete_page(struct address_
 	if (PagePrivate(page) && !try_to_release_page(page, 0))
 		return 0;
 
+	clear_page_mlock(page);
 	ret = remove_mapping(mapping, page);
 
 	return ret;
@@ -352,6 +355,7 @@ invalidate_complete_page2(struct address
 	if (PageDirty(page))
 		goto failed;
 
+	clear_page_mlock(page);
 	BUG_ON(PagePrivate(page));
 	__remove_from_page_cache(page);
 	write_unlock_irq(&mapping->tree_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
