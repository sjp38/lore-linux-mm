From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Tue, 19 Aug 2008 17:05:27 -0400
Message-Id: <20080819210527.27199.85273.sendpatchset@lts-notebook>
In-Reply-To: <20080819210509.27199.6626.sendpatchset@lts-notebook>
References: <20080819210509.27199.6626.sendpatchset@lts-notebook>
Subject: [PATCH 3/6] Mlock: resubmit locked_vm adjustment as separate patch
Sender: owner-linux-mm@kvack.org
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: riel@redhat.com, linux-mm <linux-mm@kvack.org>, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Against:  2.6.27-rc3-mmotm-080816-0202

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
by the vma.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/internal.h |    2 +-
 mm/mlock.c    |   26 +++++++++++++++++---------
 mm/mmap.c     |    8 ++++----
 3 files changed, 22 insertions(+), 14 deletions(-)

Index: linux-2.6.27-rc3-mmotm/mm/mlock.c
===================================================================
--- linux-2.6.27-rc3-mmotm.orig/mm/mlock.c	2008-08-18 13:59:22.000000000 -0400
+++ linux-2.6.27-rc3-mmotm/mm/mlock.c	2008-08-18 14:02:43.000000000 -0400
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
@@ -242,11 +242,11 @@ static int __mlock_vma_pages_range(struc
 /*
  * mlock all pages in this vma range.  For mmap()/mremap()/...
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
@@ -259,7 +259,9 @@ int mlock_vma_pages_range(struct vm_area
 			is_vm_hugetlb_page(vma) ||
 			vma == get_gate_vma(current))) {
 		downgrade_write(&mm->mmap_sem);
-		error = __mlock_vma_pages_range(vma, start, end, 1);
+
+		nr_pages = __mlock_vma_pages_range(vma, start, end, 1);
+
 		up_read(&mm->mmap_sem);
 		/* vma can change or disappear */
 		down_write(&mm->mmap_sem);
@@ -267,20 +269,22 @@ int mlock_vma_pages_range(struct vm_area
 		/* non-NULL vma must contain @start, but need to check @end */
 		if (!vma ||  end > vma->vm_end)
 			return -EAGAIN;
-		return error;
+		return nr_pages;
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
 
 
@@ -369,6 +373,10 @@ success:
 		downgrade_write(&mm->mmap_sem);
 
 		ret = __mlock_vma_pages_range(vma, start, end, 1);
+		if (ret > 0) {
+			mm->locked_vm -= ret;
+			ret = 0;
+		}
 		/*
 		 * Need to reacquire mmap sem in write mode, as our callers
 		 * expect this.  We have no support for atomically upgrading
Index: linux-2.6.27-rc3-mmotm/mm/mmap.c
===================================================================
--- linux-2.6.27-rc3-mmotm.orig/mm/mmap.c	2008-08-18 13:59:22.000000000 -0400
+++ linux-2.6.27-rc3-mmotm/mm/mmap.c	2008-08-18 14:01:36.000000000 -0400
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
Index: linux-2.6.27-rc3-mmotm/mm/internal.h
===================================================================
--- linux-2.6.27-rc3-mmotm.orig/mm/internal.h	2008-08-18 13:59:22.000000000 -0400
+++ linux-2.6.27-rc3-mmotm/mm/internal.h	2008-08-18 14:01:36.000000000 -0400
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
