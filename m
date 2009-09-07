Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 453356B00B4
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 17:30:45 -0400 (EDT)
Date: Mon, 7 Sep 2009 22:29:55 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 1/8] mm: munlock use follow_page
In-Reply-To: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
Message-ID: <Pine.LNX.4.64.0909072227140.15430@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hiroaki Wakabayashi <primulaelatior@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hiroaki Wakabayashi points out that when mlock() has been interrupted
by SIGKILL, the subsequent munlock() takes unnecessarily long because
its use of __get_user_pages() insists on faulting in all the pages
which mlock() never reached.

It's worse than slowness if mlock() is terminated by Out Of Memory kill:
the munlock_vma_pages_all() in exit_mmap() insists on faulting in all the
pages which mlock() could not find memory for; so innocent bystanders are
killed too, and perhaps the system hangs.

__get_user_pages() does a lot that's silly for munlock(): so remove the
munlock option from __mlock_vma_pages_range(), and use a simple loop of
follow_page()s in munlock_vma_pages_range() instead; ignoring absent
pages, and not marking present pages as accessed or dirty.

(Change munlock() to only go so far as mlock() reached?  That does not
work out, given the convention that mlock() claims complete success even
when it has to give up early - in part so that an underlying file can be
extended later, and those pages locked which earlier would give SIGBUS.)

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: stable@kernel.org
---

 mm/mlock.c |   99 ++++++++++++++++++++-------------------------------
 1 file changed, 40 insertions(+), 59 deletions(-)

--- mm0/mm/mlock.c	2009-06-25 05:18:10.000000000 +0100
+++ mm1/mm/mlock.c	2009-09-07 13:16:15.000000000 +0100
@@ -139,49 +139,36 @@ static void munlock_vma_page(struct page
 }
 
 /**
- * __mlock_vma_pages_range() -  mlock/munlock a range of pages in the vma.
+ * __mlock_vma_pages_range() -  mlock a range of pages in the vma.
  * @vma:   target vma
  * @start: start address
  * @end:   end address
- * @mlock: 0 indicate munlock, otherwise mlock.
  *
- * If @mlock == 0, unlock an mlocked range;
- * else mlock the range of pages.  This takes care of making the pages present ,
- * too.
+ * This takes care of making the pages present too.
  *
  * return 0 on success, negative error code on error.
  *
  * vma->vm_mm->mmap_sem must be held for at least read.
  */
 static long __mlock_vma_pages_range(struct vm_area_struct *vma,
-				   unsigned long start, unsigned long end,
-				   int mlock)
+				    unsigned long start, unsigned long end)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long addr = start;
 	struct page *pages[16]; /* 16 gives a reasonable batch */
 	int nr_pages = (end - start) / PAGE_SIZE;
 	int ret = 0;
-	int gup_flags = 0;
+	int gup_flags;
 
 	VM_BUG_ON(start & ~PAGE_MASK);
 	VM_BUG_ON(end   & ~PAGE_MASK);
 	VM_BUG_ON(start < vma->vm_start);
 	VM_BUG_ON(end   > vma->vm_end);
-	VM_BUG_ON((!rwsem_is_locked(&mm->mmap_sem)) &&
-		  (atomic_read(&mm->mm_users) != 0));
-
-	/*
-	 * mlock:   don't page populate if vma has PROT_NONE permission.
-	 * munlock: always do munlock although the vma has PROT_NONE
-	 *          permission, or SIGKILL is pending.
-	 */
-	if (!mlock)
-		gup_flags |= GUP_FLAGS_IGNORE_VMA_PERMISSIONS |
-			     GUP_FLAGS_IGNORE_SIGKILL;
+	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
 
+	gup_flags = 0;
 	if (vma->vm_flags & VM_WRITE)
-		gup_flags |= GUP_FLAGS_WRITE;
+		gup_flags = GUP_FLAGS_WRITE;
 
 	while (nr_pages > 0) {
 		int i;
@@ -201,19 +188,10 @@ static long __mlock_vma_pages_range(stru
 		 * This can happen for, e.g., VM_NONLINEAR regions before
 		 * a page has been allocated and mapped at a given offset,
 		 * or for addresses that map beyond end of a file.
-		 * We'll mlock the the pages if/when they get faulted in.
+		 * We'll mlock the pages if/when they get faulted in.
 		 */
 		if (ret < 0)
 			break;
-		if (ret == 0) {
-			/*
-			 * We know the vma is there, so the only time
-			 * we cannot get a single page should be an
-			 * error (ret < 0) case.
-			 */
-			WARN_ON(1);
-			break;
-		}
 
 		lru_add_drain();	/* push cached pages to LRU */
 
@@ -224,28 +202,22 @@ static long __mlock_vma_pages_range(stru
 			/*
 			 * Because we lock page here and migration is blocked
 			 * by the elevated reference, we need only check for
-			 * page truncation (file-cache only).
+			 * file-cache page truncation.  This page->mapping
+			 * check also neatly skips over the ZERO_PAGE(),
+			 * though if that's common we'd prefer not to lock it.
 			 */
-			if (page->mapping) {
-				if (mlock)
-					mlock_vma_page(page);
-				else
-					munlock_vma_page(page);
-			}
+			if (page->mapping)
+				mlock_vma_page(page);
 			unlock_page(page);
-			put_page(page);		/* ref from get_user_pages() */
-
-			/*
-			 * here we assume that get_user_pages() has given us
-			 * a list of virtually contiguous pages.
-			 */
-			addr += PAGE_SIZE;	/* for next get_user_pages() */
-			nr_pages--;
+			put_page(page);	/* ref from get_user_pages() */
 		}
+
+		addr += ret * PAGE_SIZE;
+		nr_pages -= ret;
 		ret = 0;
 	}
 
-	return ret;	/* count entire vma as locked_vm */
+	return ret;	/* 0 or negative error code */
 }
 
 /*
@@ -289,7 +261,7 @@ long mlock_vma_pages_range(struct vm_are
 			is_vm_hugetlb_page(vma) ||
 			vma == get_gate_vma(current))) {
 
-		__mlock_vma_pages_range(vma, start, end, 1);
+		__mlock_vma_pages_range(vma, start, end);
 
 		/* Hide errors from mmap() and other callers */
 		return 0;
@@ -310,7 +282,6 @@ no_mlock:
 	return nr_pages;		/* error or pages NOT mlocked */
 }
 
-
 /*
  * munlock_vma_pages_range() - munlock all pages in the vma range.'
  * @vma - vma containing range to be munlock()ed.
@@ -330,10 +301,24 @@ no_mlock:
  * free them.  This will result in freeing mlocked pages.
  */
 void munlock_vma_pages_range(struct vm_area_struct *vma,
-			   unsigned long start, unsigned long end)
+			     unsigned long start, unsigned long end)
 {
+	unsigned long addr;
+
+	lru_add_drain();
 	vma->vm_flags &= ~VM_LOCKED;
-	__mlock_vma_pages_range(vma, start, end, 0);
+
+	for (addr = start; addr < end; addr += PAGE_SIZE) {
+		struct page *page = follow_page(vma, addr, FOLL_GET);
+		if (page) {
+			lock_page(page);
+			if (page->mapping)
+				munlock_vma_page(page);
+			unlock_page(page);
+			put_page(page);
+		}
+		cond_resched();
+	}
 }
 
 /*
@@ -400,18 +385,14 @@ success:
 	 * It's okay if try_to_unmap_one unmaps a page just after we
 	 * set VM_LOCKED, __mlock_vma_pages_range will bring it back.
 	 */
-	vma->vm_flags = newflags;
 
 	if (lock) {
-		ret = __mlock_vma_pages_range(vma, start, end, 1);
-
-		if (ret > 0) {
-			mm->locked_vm -= ret;
-			ret = 0;
-		} else
-			ret = __mlock_posix_error_return(ret); /* translate if needed */
+		vma->vm_flags = newflags;
+		ret = __mlock_vma_pages_range(vma, start, end);
+		if (ret < 0)
+			ret = __mlock_posix_error_return(ret);
 	} else {
-		__mlock_vma_pages_range(vma, start, end, 0);
+		munlock_vma_pages_range(vma, start, end);
 	}
 
 out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
