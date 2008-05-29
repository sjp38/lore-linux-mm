From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 29 May 2008 15:51:08 -0400
Message-Id: <20080529195108.27159.5746.sendpatchset@lts-notebook>
In-Reply-To: <20080529195030.27159.66161.sendpatchset@lts-notebook>
References: <20080529195030.27159.66161.sendpatchset@lts-notebook>
Subject: [PATCH 18/25] Downgrade mmap sem while populating mlocked regions
Sender: owner-linux-mm@kvack.org
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Against:  2.6.26-rc2-mm1

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
locked down.  However, I occassionally see delays while unlocking or
unmapping a large mlocked region.  Should we also downgrade the mmap_sem
for the unlock path?

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Rik van Riel <riel@redhat.com>

 mm/mlock.c |   43 +++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 41 insertions(+), 2 deletions(-)

Index: linux-2.6.26-rc2-mm1/mm/mlock.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/mlock.c	2008-05-21 13:58:40.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/mlock.c	2008-05-21 13:58:42.000000000 -0400
@@ -309,6 +309,7 @@ static void __munlock_vma_pages_range(st
 int mlock_vma_pages_range(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end)
 {
+	struct mm_struct *mm = vma->vm_mm;
 	int nr_pages = (end - start) / PAGE_SIZE;
 	BUG_ON(!(vma->vm_flags & VM_LOCKED));
 
@@ -323,7 +324,17 @@ int mlock_vma_pages_range(struct vm_area
 			vma == get_gate_vma(current))
 		goto make_present;
 
-	return __mlock_vma_pages_range(vma, start, end);
+	downgrade_write(&mm->mmap_sem);
+	nr_pages = __mlock_vma_pages_range(vma, start, end);
+
+	up_read(&mm->mmap_sem);
+	/* vma can change or disappear */
+	down_write(&mm->mmap_sem);
+	vma = find_vma(mm, start);
+	/* non-NULL vma must contain @start, but need to check @end */
+	if (!vma ||  end > vma->vm_end)
+		return -EAGAIN;
+	return nr_pages;
 
 make_present:
 	/*
@@ -418,13 +429,41 @@ success:
 	vma->vm_flags = newflags;
 
 	if (lock) {
+		/*
+		 * mmap_sem is currently held for write.  Downgrade the write
+		 * lock to a read lock so that other faults, mmap scans, ...
+		 * while we fault in all pages.
+		 */
+		downgrade_write(&mm->mmap_sem);
+
 		ret = __mlock_vma_pages_range(vma, start, end);
 		if (ret > 0) {
 			mm->locked_vm -= ret;
 			ret = 0;
 		}
-	} else
+		/*
+		 * Need to reacquire mmap sem in write mode, as our callers
+		 * expect this.  We have no support for atomically upgrading
+		 * a sem to write, so we need to check for ranges while sem
+		 * is unlocked.
+		 */
+		up_read(&mm->mmap_sem);
+		/* vma can change or disappear */
+		down_write(&mm->mmap_sem);
+		*prev = find_vma(mm, start);
+		/* non-NULL *prev must contain @start, but need to check @end */
+		if (!(*prev) || end > (*prev)->vm_end)
+			ret = -EAGAIN;
+	} else {
+		/*
+		 * TODO:  for unlocking, pages will already be resident, so
+		 * we don't need to wait for allocations/reclaim/pagein, ...
+		 * However, unlocking a very large region can still take a
+		 * while.  Should we downgrade the semaphore for both lock
+		 * AND unlock ?
+		 */
 		__munlock_vma_pages_range(vma, start, end);
+	}
 
 out:
 	*prev = vma;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
