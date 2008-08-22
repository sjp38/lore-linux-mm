From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 22 Aug 2008 17:10:47 -0400
Message-Id: <20080822211047.29898.16176.sendpatchset@murky.usa.hp.com>
In-Reply-To: <20080822211028.29898.82599.sendpatchset@murky.usa.hp.com>
References: <20080822211028.29898.82599.sendpatchset@murky.usa.hp.com>
Subject: [PATCH 3/7] Mlock: resubmit locked_vm adjustment as separate patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: riel@redhat.com, linux-mm <linux-mm@kvack.org>, kosaki.motohiro@jp.fujitsu.com, Eric.Whitney@hp.com
List-ID: <linux-mm.kvack.org>

atop patch:
	mmap-handle-mlocked-pages-during-map-remap-unmap.patch
with locked_vm adjustment backout patch.

Adjust mm->locked_vm in the mmap(MAP_LOCKED) path to match mlock()
behavior and VM_LOCKED flag setting.

Broken out as separate patch.

During mlock*(), mlock_fixup() adjusts locked_vm as appropriate,
based on the type of vma.  For the "special" vmas--those whose 
pages we don't actually mark as PageMlocked()--VM_LOCKED is not
set, so that we don't attempt to munlock the pages during munmap
or munlock, and so we don't need to duplicate the vma type filtering
there.  These vmas are not included in locked_vm by mlock_fixup().

During mmap() and vma extension, locked_vm is adjusted outside of the
mlock functions.  This patch enhances those path to match the behavior
of mlock for the special vmas.  Return number of pages NOT mlocked from
mlock_vma_pages_range() [0 or positive].  Share the return value with
possible error code [negative].  Caller adjusts locked_vm by non-negative
return value.  For "special" vmas, this will include all pages mapped
by the vma.  For "normal" [anon, file-backed] vmas, should always
return 0 adjustment.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/internal.h |    2 +-
 mm/mlock.c    |   42 +++++++++++++++++++++++++++++++++---------
 mm/mmap.c     |   10 +++++-----
 3 files changed, 39 insertions(+), 15 deletions(-)

Index: linux-2.6.27-rc4-mmotm/mm/mlock.c
===================================================================
--- linux-2.6.27-rc4-mmotm.orig/mm/mlock.c	2008-08-21 10:52:24.000000000 -0400
+++ linux-2.6.27-rc4-mmotm/mm/mlock.c	2008-08-21 11:37:45.000000000 -0400
@@ -127,7 +127,7 @@ static void munlock_vma_page(struct page
  *
  * vma->vm_mm->mmap_sem must be held for at least read.
  */
-static int __mlock_vma_pages_range(struct vm_area_struct *vma,
+static long __mlock_vma_pages_range(struct vm_area_struct *vma,
 				   unsigned long start, unsigned long end,
 				   int mlock)
 {
@@ -229,7 +229,7 @@ static int __mlock_vma_pages_range(struc
 /*
  * Just make pages present if VM_LOCKED.  No-op if unlocking.
  */
-static int __mlock_vma_pages_range(struct vm_area_struct *vma,
+static long __mlock_vma_pages_range(struct vm_area_struct *vma,
 				   unsigned long start, unsigned long end,
 				   int mlock)
 {
@@ -240,13 +240,27 @@ static int __mlock_vma_pages_range(struc
 #endif /* CONFIG_UNEVICTABLE_LRU */
 
 /*
- * mlock all pages in this vma range.  For mmap()/mremap()/...
+/**
+ * mlock_vma_pages_range() - mlock pages in specified vma range.
+ * @vma - the vma containing the specfied address range
+ * @start - starting address in @vma to mlock
+ * @end   - end address [+1] in @vma to mlock
+ *
+ * For mmap()/mremap()/expansion of mlocked vma.
+ *
+ * return 0 on success for "normal" vmas.
+ *
+ * return number of pages [> 0] to be removed from locked_vm on success
+ * of "special" vmas.
+ *
+ * return negative error if vma spanning @start-@range disappears while
+ * mmap semaphore is dropped.  Unlikely?
  */
-int mlock_vma_pages_range(struct vm_area_struct *vma,
+long mlock_vma_pages_range(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	int error = 0;
+	int nr_pages = (end - start) / PAGE_SIZE;
 	BUG_ON(!(vma->vm_flags & VM_LOCKED));
 
 	/*
@@ -258,8 +272,11 @@ int mlock_vma_pages_range(struct vm_area
 	if (!((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED)) ||
 			is_vm_hugetlb_page(vma) ||
 			vma == get_gate_vma(current))) {
+		long error;
 		downgrade_write(&mm->mmap_sem);
+
 		error = __mlock_vma_pages_range(vma, start, end, 1);
+
 		up_read(&mm->mmap_sem);
 		/* vma can change or disappear */
 		down_write(&mm->mmap_sem);
@@ -267,20 +284,23 @@ int mlock_vma_pages_range(struct vm_area
 		/* non-NULL vma must contain @start, but need to check @end */
 		if (!vma ||  end > vma->vm_end)
 			return -EAGAIN;
-		return error;
+
+		return 0;	/* hide other errors from mmap(), et al */
 	}
 
 	/*
 	 * User mapped kernel pages or huge pages:
 	 * make these pages present to populate the ptes, but
-	 * fall thru' to reset VM_LOCKED so we don't try to munlock
-	 * this vma during munmap()/munlock().
+	 * fall thru' to reset VM_LOCKED--no need to unlock, and
+	 * return nr_pages so these don't get counted against task's
+	 * locked limit.  huge pages are already counted against
+	 * locked vm limit.
 	 */
 	make_pages_present(start, end);
 
 no_mlock:
 	vma->vm_flags &= ~VM_LOCKED;	/* and don't come back! */
-	return error;
+	return nr_pages;		/* error or pages NOT mlocked */
 }
 
 
@@ -369,6 +389,10 @@ success:
 		downgrade_write(&mm->mmap_sem);
 
 		ret = __mlock_vma_pages_range(vma, start, end, 1);
+		if (ret > 0) {
+			mm->locked_vm -= ret;
+			ret = 0;
+		}
 		/*
 		 * Need to reacquire mmap sem in write mode, as our callers
 		 * expect this.  We have no support for atomically upgrading
Index: linux-2.6.27-rc4-mmotm/mm/mmap.c
===================================================================
--- linux-2.6.27-rc4-mmotm.orig/mm/mmap.c	2008-08-21 10:52:24.000000000 -0400
+++ linux-2.6.27-rc4-mmotm/mm/mmap.c	2008-08-21 11:45:44.000000000 -0400
@@ -1224,10 +1224,10 @@ out:
 		/*
 		 * makes pages present; downgrades, drops, reacquires mmap_sem
 		 */
-		int error = mlock_vma_pages_range(vma, addr, addr + len);
-		if (error < 0)
-			return error;	/* vma gone! */
-		mm->locked_vm += (len >> PAGE_SHIFT);
+		long nr_pages = mlock_vma_pages_range(vma, addr, addr + len);
+		if (nr_pages < 0)
+			return nr_pages;	/* vma gone! */
+		mm->locked_vm += (len >> PAGE_SHIFT) - nr_pages;
 	} else if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
 		make_pages_present(addr, addr + len);
 	return addr;
@@ -2066,7 +2066,7 @@ unsigned long do_brk(unsigned long addr,
 out:
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
-		if (mlock_vma_pages_range(vma, addr, addr + len) >= 0)
+		if (!mlock_vma_pages_range(vma, addr, addr + len))
 			mm->locked_vm += (len >> PAGE_SHIFT);
 	}
 	return addr;
Index: linux-2.6.27-rc4-mmotm/mm/internal.h
===================================================================
--- linux-2.6.27-rc4-mmotm.orig/mm/internal.h	2008-08-21 10:52:00.000000000 -0400
+++ linux-2.6.27-rc4-mmotm/mm/internal.h	2008-08-21 11:10:50.000000000 -0400
@@ -61,7 +61,7 @@ static inline unsigned long page_order(s
 	return page_private(page);
 }
 
-extern int mlock_vma_pages_range(struct vm_area_struct *vma,
+extern long mlock_vma_pages_range(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end);
 extern void munlock_vma_pages_range(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
