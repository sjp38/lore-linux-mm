From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 22 Aug 2008 17:10:41 -0400
Message-Id: <20080822211041.29898.63572.sendpatchset@murky.usa.hp.com>
In-Reply-To: <20080822211028.29898.82599.sendpatchset@murky.usa.hp.com>
References: <20080822211028.29898.82599.sendpatchset@murky.usa.hp.com>
Subject: [PATCH 2/7] Mlock: backout locked_vm adjustment during mmap()
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: riel@redhat.com, linux-mm <linux-mm@kvack.org>, kosaki.motohiro@jp.fujitsu.com, Eric.Whitney@hp.com
List-ID: <linux-mm.kvack.org>

Against: 2.6.27-rc3-mmotm-080821-0003

can be folded into: mmap-handle-mlocked-pages-during-map-remap-unmap.patch

Backout mmap() path locked_vm accounting adjustment from the "handle
mlocked pages during map/remap/unmap" patch.  Will resubmit as separate
patch with its own description.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mlock.c |   19 ++++++-------------
 mm/mmap.c  |   19 ++++++++-----------
 2 files changed, 14 insertions(+), 24 deletions(-)

Index: linux-2.6.27-rc3-mmotm/mm/mlock.c
===================================================================
--- linux-2.6.27-rc3-mmotm.orig/mm/mlock.c	2008-08-18 12:38:20.000000000 -0400
+++ linux-2.6.27-rc3-mmotm/mm/mlock.c	2008-08-18 12:44:16.000000000 -0400
@@ -246,7 +246,7 @@ int mlock_vma_pages_range(struct vm_area
 			unsigned long start, unsigned long end)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	int nr_pages = (end - start) / PAGE_SIZE;
+	int error = 0;
 	BUG_ON(!(vma->vm_flags & VM_LOCKED));
 
 	/*
@@ -259,8 +259,7 @@ int mlock_vma_pages_range(struct vm_area
 			is_vm_hugetlb_page(vma) ||
 			vma == get_gate_vma(current))) {
 		downgrade_write(&mm->mmap_sem);
-		nr_pages = __mlock_vma_pages_range(vma, start, end, 1);
-
+		error = __mlock_vma_pages_range(vma, start, end, 1);
 		up_read(&mm->mmap_sem);
 		/* vma can change or disappear */
 		down_write(&mm->mmap_sem);
@@ -268,22 +267,20 @@ int mlock_vma_pages_range(struct vm_area
 		/* non-NULL vma must contain @start, but need to check @end */
 		if (!vma ||  end > vma->vm_end)
 			return -EAGAIN;
-		return nr_pages;
+		return error;
 	}
 
 	/*
 	 * User mapped kernel pages or huge pages:
 	 * make these pages present to populate the ptes, but
-	 * fall thru' to reset VM_LOCKED--no need to unlock, and
-	 * return nr_pages so these don't get counted against task's
-	 * locked limit.  huge pages are already counted against
-	 * locked vm limit.
+	 * fall thru' to reset VM_LOCKED so we don't try to munlock
+	 * this vma during munmap()/munlock().
 	 */
 	make_pages_present(start, end);
 
 no_mlock:
 	vma->vm_flags &= ~VM_LOCKED;	/* and don't come back! */
-	return nr_pages;		/* pages NOT mlocked */
+	return error;
 }
 
 
@@ -372,10 +369,6 @@ success:
 		downgrade_write(&mm->mmap_sem);
 
 		ret = __mlock_vma_pages_range(vma, start, end, 1);
-		if (ret > 0) {
-			mm->locked_vm -= ret;
-			ret = 0;
-		}
 		/*
 		 * Need to reacquire mmap sem in write mode, as our callers
 		 * expect this.  We have no support for atomically upgrading
Index: linux-2.6.27-rc3-mmotm/mm/mmap.c
===================================================================
--- linux-2.6.27-rc3-mmotm.orig/mm/mmap.c	2008-08-18 12:38:20.000000000 -0400
+++ linux-2.6.27-rc3-mmotm/mm/mmap.c	2008-08-18 12:52:21.000000000 -0400
@@ -1224,10 +1224,10 @@ out:
 		/*
 		 * makes pages present; downgrades, drops, reacquires mmap_sem
 		 */
-		int nr_pages = mlock_vma_pages_range(vma, addr, addr + len);
-		if (nr_pages < 0)
-			return nr_pages;	/* vma gone! */
-		mm->locked_vm += (len >> PAGE_SHIFT) - nr_pages;
+		int error = mlock_vma_pages_range(vma, addr, addr + len);
+		if (error < 0)
+			return error;	/* vma gone! */
+		mm->locked_vm += (len >> PAGE_SHIFT);
 	} else if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
 		make_pages_present(addr, addr + len);
 	return addr;
@@ -1702,8 +1702,7 @@ find_extend_vma(struct mm_struct *mm, un
 	if (!prev || expand_stack(prev, addr))
 		return NULL;
 	if (prev->vm_flags & VM_LOCKED) {
-		int nr_pages = mlock_vma_pages_range(prev, addr, prev->vm_end);
-		if (nr_pages < 0)
+		if (mlock_vma_pages_range(prev, addr, prev->vm_end) < 0)
 			return NULL;	/* vma gone! */
 	}
 	return prev;
@@ -1732,8 +1731,7 @@ find_extend_vma(struct mm_struct * mm, u
 	if (expand_stack(vma, addr))
 		return NULL;
 	if (vma->vm_flags & VM_LOCKED) {
-		int nr_pages = mlock_vma_pages_range(vma, addr, start);
-		if (nr_pages < 0)
+		if (mlock_vma_pages_range(vma, addr, start) < 0)
 			return NULL;	/* vma gone! */
 	}
 	return vma;
@@ -2068,9 +2066,8 @@ unsigned long do_brk(unsigned long addr,
 out:
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
-		int nr_pages = mlock_vma_pages_range(vma, addr, addr + len);
-		if (nr_pages >= 0)
-			mm->locked_vm += (len >> PAGE_SHIFT) - nr_pages;
+		if (mlock_vma_pages_range(vma, addr, addr + len) >= 0)
+			mm->locked_vm += (len >> PAGE_SHIFT);
 	}
 	return addr;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
