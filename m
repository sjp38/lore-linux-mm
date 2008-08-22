From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 22 Aug 2008 17:11:00 -0400
Message-Id: <20080822211100.29898.60644.sendpatchset@murky.usa.hp.com>
In-Reply-To: <20080822211028.29898.82599.sendpatchset@murky.usa.hp.com>
References: <20080822211028.29898.82599.sendpatchset@murky.usa.hp.com>
Subject: [PATCH 5/7] Mlock:  update locked_vm on munmap() of mlocked() region.
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: riel@redhat.com, linux-mm <linux-mm@kvack.org>, kosaki.motohiro@jp.fujitsu.com, Eric.Whitney@hp.com
List-ID: <linux-mm.kvack.org>

against patch:  mmap-handle-mlocked-pages-during-map-remap-unmap.patch

munlock_vma_pages_range() clears VM_LOCKED for munlock_vma_page(), et al
to work.  This causes remove_vma_list(), called from do_munmap(), to skip
updating locked_vm. 

We don't want to restore the VM_LOCKED in munlock_vma_pages_range()
because the pages are still on the lru.  If vmscan attempts to reclaim
any of these pages before we get a chance to unmap them,
try_to_un{lock|map}() may mlock them again.  This will result in freeing
an mlocked page.

	Add comment block to munlock_vma_pages_range() to explain
	this to future would be callers.

Move the accounting of locked_vm from remove_vma_list() to the munlock
loop in do_munmap().  This is where the pages are munlocked and VM_LOCKED
is cleared.  Note that remove_vma_list() is a helper function for
do_munmap(), called only from there.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mlock.c |   17 ++++++++++++++++-
 mm/mmap.c  |    6 +++---
 2 files changed, 19 insertions(+), 4 deletions(-)

Index: linux-2.6.27-rc4-mmotm/mm/mlock.c
===================================================================
--- linux-2.6.27-rc4-mmotm.orig/mm/mlock.c	2008-08-21 12:04:06.000000000 -0400
+++ linux-2.6.27-rc4-mmotm/mm/mlock.c	2008-08-22 15:43:39.000000000 -0400
@@ -305,7 +305,22 @@ no_mlock:
 
 
 /*
- * munlock all pages in the vma range.   For mremap(), munmap() and exit().
+ * munlock_vma_pages_range() - munlock all pages in the vma range.'
+ * @vma - vma containing range to be munlock()ed.
+ * @start - start address in @vma of the range
+ * @end - end of range in @vma.
+ *
+ *  For mremap(), munmap() and exit().
+ *
+ * Called with @vma VM_LOCKED.
+ *
+ * Returns with VM_LOCKED cleared.  Callers must be prepared to
+ * deal with this.
+ *
+ * We don't save and restore VM_LOCKED here because pages are
+ * still on lru.  In unmap path, pages might be scanned by reclaim
+ * and re-mlocked by try_to_{munlock|unmap} before we unmap and
+ * free them.  This will result in freeing mlocked pages.
  */
 void munlock_vma_pages_range(struct vm_area_struct *vma,
 			   unsigned long start, unsigned long end)
Index: linux-2.6.27-rc4-mmotm/mm/mmap.c
===================================================================
--- linux-2.6.27-rc4-mmotm.orig/mm/mmap.c	2008-08-22 09:19:10.000000000 -0400
+++ linux-2.6.27-rc4-mmotm/mm/mmap.c	2008-08-22 15:21:40.000000000 -0400
@@ -1752,8 +1752,6 @@ static void remove_vma_list(struct mm_st
 		long nrpages = vma_pages(vma);
 
 		mm->total_vm -= nrpages;
-		if (vma->vm_flags & VM_LOCKED)
-			mm->locked_vm -= nrpages;
 		vm_stat_account(mm, vma->vm_flags, vma->vm_file, -nrpages);
 		vma = remove_vma(vma);
 	} while (vma);
@@ -1924,8 +1922,10 @@ int do_munmap(struct mm_struct *mm, unsi
 	if (mm->locked_vm) {
 		struct vm_area_struct *tmp = vma;
 		while (tmp && tmp->vm_start < end) {
-			if (tmp->vm_flags & VM_LOCKED)
+			if (tmp->vm_flags & VM_LOCKED) {
+				mm->locked_vm -= vma_pages(tmp);
 				munlock_vma_pages_all(tmp);
+			}
 			tmp = tmp->vm_next;
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
