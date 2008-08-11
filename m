Date: Mon, 11 Aug 2008 16:06:37 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC PATCH for -mm 3/5] kill unnecessary locked_vm adjustment
In-Reply-To: <20080811151313.9456.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080811151313.9456.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080811160542.945F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Now, __mlock_vma_pages_range never return positive value.
So, locked_vm adjustment code is unnecessary.

also, related comment fixed.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/mlock.c |   18 +++++-------------
 mm/mmap.c  |   10 +++++-----
 2 files changed, 10 insertions(+), 18 deletions(-)

Index: b/mm/mlock.c
===================================================================
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -276,7 +276,7 @@ int mlock_vma_pages_range(struct vm_area
 			unsigned long start, unsigned long end)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	int nr_pages = (end - start) / PAGE_SIZE;
+	int error = 0;
 	BUG_ON(!(vma->vm_flags & VM_LOCKED));
 
 	/*
@@ -289,8 +289,7 @@ int mlock_vma_pages_range(struct vm_area
 			is_vm_hugetlb_page(vma) ||
 			vma == get_gate_vma(current))) {
 		downgrade_write(&mm->mmap_sem);
-		nr_pages = __mlock_vma_pages_range(vma, start, end, 1);
-
+		error = __mlock_vma_pages_range(vma, start, end, 1);
 		up_read(&mm->mmap_sem);
 		/* vma can change or disappear */
 		down_write(&mm->mmap_sem);
@@ -298,22 +297,19 @@ int mlock_vma_pages_range(struct vm_area
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
+	 * fall thru' to reset VM_LOCKED--no need to unlock.
 	 */
 	make_pages_present(start, end);
 
 no_mlock:
 	vma->vm_flags &= ~VM_LOCKED;	/* and don't come back! */
-	return nr_pages;		/* pages NOT mlocked */
+	return error;			/* pages NOT mlocked */
 }
 
 
@@ -402,10 +398,6 @@ success:
 		downgrade_write(&mm->mmap_sem);
 
 		ret = __mlock_vma_pages_range(vma, start, end, 1);
-		if (ret > 0) {
-			mm->locked_vm -= ret;
-			ret = 0;
-		}
 		/*
 		 * Need to reacquire mmap sem in write mode, as our callers
 		 * expect this.  We have no support for atomically upgrading
Index: b/mm/mmap.c
===================================================================
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1229,10 +1229,10 @@ out:
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
@@ -2087,7 +2087,7 @@ out:
 	if (flags & VM_LOCKED) {
 		int nr_pages = mlock_vma_pages_range(vma, addr, addr + len);
 		if (nr_pages >= 0)
-			mm->locked_vm += (len >> PAGE_SHIFT) - nr_pages;
+			mm->locked_vm += (len >> PAGE_SHIFT);
 	}
 	return addr;
 undo_charge:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
