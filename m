From: linux-kernel@vger.kernel.org
Subject: [patch 16/19] mlock vma pages under mmap_sem held for read
Date: Wed, 02 Jan 2008 17:42:00 -0500
Message-ID: <20080102224155.205510231@redhat.com>
References: <20080102224144.885671949@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760469AbYABX23@vger.kernel.org>
Content-Disposition: inline; filename=noreclaim-04.1a-lock-vma-pages-under-read-lock.patch
Sender: linux-kernel-owner@vger.kernel.org
Cc: linux-mm@kvack.org, lee.schermerhorn@hp.com
List-Id: linux-mm.kvack.org

V2 -> V3:
+ rebase to 23-mm1 atop RvR's split lru series [no change]
+ fix function return types [void -> int] to fix build when
  not configured.

New in V2.

We need to hold the mmap_sem for write to initiatate mlock()/munlock()
because we may need to merge/split vmas.  However, this can lead to
very long lock hold times attempting to fault in a large memory region
to mlock it into memory.   This can hold off other faults against the
mm [multithreaded tasks] and other scans of the mm, such as via /proc.
To alleviate this, downgrade the mmap_sem to read mode during the 
population of the region for locking.  This is especially the case 
if we need to reclaim memory to lock down the region.  We [probably?]
don't need to do this for unlocking as all of the pages should be
resident--they're already mlocked.

Now, the caller's of the mlock functions [mlock_fixup() and 
mlock_vma_pages_range()] expect the mmap_sem to be returned in write
mode.  Changing all callers appears to be way too much effort at this
point.  So, restore write mode before returning.  Note that this opens
a window where the mmap list could change in a multithreaded process.
So, at least for mlock_fixup(), where we could be called in a loop over
multiple vmas, we check that a vma still exists at the start address
and that vma still covers the page range [start,end).  If not, we return
an error, -EAGAIN, and let the caller deal with it.

Return -EAGAIN from mlock_vma_pages_range() function and mlock_fixup()
if the vma at 'start' disappears or changes so that the page range
[start,end) is no longer contained in the vma.  Again, let the caller
deal with it.  Looks like only sys_remap_file_pages() [via mmap_region()]
should actually care.

With this patch, I no longer see processes like ps(1) blocked for seconds
or minutes at a time waiting for a large [multiple gigabyte] region to be
locked down.  

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by:  Rik van Riel <riel@redhat.com>

Index: linux-2.6.24-rc6-mm1/mm/mlock.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/mlock.c	2008-01-02 14:59:18.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/mlock.c	2008-01-02 15:06:32.000000000 -0500
@@ -200,6 +200,37 @@ int __mlock_vma_pages_range(struct vm_ar
 	return ret;
 }
 
+/**
+ * mlock_vma_pages_range
+ * @vma - vm area to mlock into memory
+ * @start - start address in @vma of range to mlock,
+ * @end   - end address in @vma of range
+ *
+ * Called with current->mm->mmap_sem held write locked.  Downgrade to read
+ * for faulting in pages.  This can take a looong time for large segments.
+ *
+ * We need to restore the mmap_sem to write locked because our callers'
+ * callers expect this.	 However, because the mmap could have changed
+ * [in a multi-threaded process], we need to recheck.
+ */
+int mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end)
+{
+	struct mm_struct *mm = vma->vm_mm;
+
+	downgrade_write(&mm->mmap_sem);
+	__mlock_vma_pages_range(vma, start, end, 1);
+
+	up_read(&mm->mmap_sem);
+	/* vma can change or disappear */
+	down_write(&mm->mmap_sem);
+	vma = find_vma(mm, start);
+	/* non-NULL vma must contain @start, but need to check @end */
+	if (!vma ||  end > vma->vm_end)
+		return -EAGAIN;
+	return 0;
+}
+
 #else /* CONFIG_NORECLAIM_MLOCK */
 
 /*
@@ -266,14 +297,38 @@ success:
 	mm->locked_vm += nr_pages;
 
 	/*
-	 * vm_flags is protected by the mmap_sem held in write mode.
+	 * vm_flags is protected by the mmap_sem held for write.
 	 * It's okay if try_to_unmap_one unmaps a page just after we
 	 * set VM_LOCKED, __mlock_vma_pages_range will bring it back.
 	 */
 	vma->vm_flags = newflags;
 
+	/*
+	 * mmap_sem is currently held for write.  If we're locking pages,
+	 * downgrade the write lock to a read lock so that other faults,
+	 * mmap scans, ... while we fault in all pages.
+	 */
+	if (lock)
+		downgrade_write(&mm->mmap_sem);
+
 	__mlock_vma_pages_range(vma, start, end, lock);
 
+	if (lock) {
+		/*
+		 * Need to reacquire mmap sem in write mode, as our callers
+		 * expect this.  We have no support for atomically upgrading
+		 * a sem to write, so we need to check for changes while sem
+		 * is unlocked.
+		 */
+		up_read(&mm->mmap_sem);
+		/* vma can change or disappear */
+		down_write(&mm->mmap_sem);
+		*prev = find_vma(mm, start);
+		/* non-NULL *prev must contain @start, but need to check @end */
+		if (!(*prev) || end > (*prev)->vm_end)
+			ret = -EAGAIN;
+	}
+
 out:
 	if (ret == -ENOMEM)
 		ret = -EAGAIN;
Index: linux-2.6.24-rc6-mm1/mm/internal.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/internal.h	2008-01-02 14:58:22.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/internal.h	2008-01-02 15:07:37.000000000 -0500
@@ -61,24 +61,21 @@ extern int __mlock_vma_pages_range(struc
 /*
  * mlock all pages in this vma range.  For mmap()/mremap()/...
  */
-static inline void mlock_vma_pages_range(struct vm_area_struct *vma,
-			unsigned long start, unsigned long end)
-{
-	__mlock_vma_pages_range(vma, start, end, 1);
-}
+extern int mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end);
 
 /*
  * munlock range of pages.   For munmap() and exit().
  * Always called to operate on a full vma that is being unmapped.
  */
-static inline void munlock_vma_pages_range(struct vm_area_struct *vma,
+static inline int munlock_vma_pages_range(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end)
 {
 // TODO:  verify my assumption.  Should we just drop the start/end args?
 	VM_BUG_ON(start != vma->vm_start || end != vma->vm_end);
 
 	vma->vm_flags &= ~VM_LOCKED;    /* try_to_unlock() needs this */
-	__mlock_vma_pages_range(vma, start, end, 0);
+	return __mlock_vma_pages_range(vma, start, end, 0);
 }
 
 extern void clear_page_mlock(struct page *page);
@@ -90,10 +87,10 @@ static inline int is_mlocked_vma(struct 
 }
 static inline void clear_page_mlock(struct page *page) { }
 static inline void mlock_vma_page(struct page *page) { }
-static inline void mlock_vma_pages_range(struct vm_area_struct *vma,
-			unsigned long start, unsigned long end) { }
-static inline void munlock_vma_pages_range(struct vm_area_struct *vma,
-			unsigned long start, unsigned long end) { }
+static inline int mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end) { return 0; }
+static inline int munlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end) { return 0; }
 
 #endif /* CONFIG_NORECLAIM_MLOCK */
 

-- 
All Rights Reversed

