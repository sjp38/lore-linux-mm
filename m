Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 581F36B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 00:01:03 -0500 (EST)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id oAN50wLt020888
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 21:00:58 -0800
Received: from gyd10 (gyd10.prod.google.com [10.243.49.202])
	by wpaz29.hot.corp.google.com with ESMTP id oAN50vxS009141
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 21:00:57 -0800
Received: by gyd10 with SMTP id 10so2416224gyd.30
        for <linux-mm@kvack.org>; Mon, 22 Nov 2010 21:00:57 -0800 (PST)
Date: Mon, 22 Nov 2010 21:00:52 -0800
From: Michel Lespinasse <walken@google.com>
Subject: [RFC] mlock: release mmap_sem every 256 faulted pages
Message-ID: <20101123050052.GA24039@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

I'd like to sollicit comments on this proposal:

Currently mlock() holds mmap_sem in exclusive mode while the pages get
faulted in. In the case of a large mlock, this can potentially take a
very long time.

I propose that mlock() could release mmap_sem after the VM_LOCKED bits
have been set in all appropriate VMAs. Then a second pass could be done
to actually mlock the pages, in small batches, never holding mmap_sem
for longer than it takes to process one single batch. We need to recheck
the vma flags whenever we re-acquire mmap_sem, but this is not difficult.

This is only an RFC rather than an actual submission, as I think this
could / should be completed to handle more than the mlock() and
mlockall() cases (there are many call sites to mlock_vma_pages_range()
that should ideally be converted as well), and maybe use the fault retry
mechanism to drop mmap_sem when blocking on disk access rather than
using an arbitrary page batch size.

Patch is against v2.6.36, but should apply to linus tree too.

------------------------------- 8< -----------------------------

Let mlock / mlockall release mmap_sem after the vmas have been marked
as VM_LOCKED. Then, mark the vmas as mlocked in small batches.
For every batch, we need to grab mmap_sem in read mode, check that the
vma has not been munlocked, and mlock the pages.

In the case where a vma has been munlocked before mlock completes,
pages that were already marked as PageMlocked() are handled by the
munlock() call, and mlock() is careful to not mark new page batches
as PageMlocked() after the munlock() call has cleared the VM_LOCKED
vma flags. So, the end result will be identical to what'd happen if
munlock() had executed after the mlock() call.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/mlock.c |   79 +++++++++++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 63 insertions(+), 16 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index b70919c..0aa4df5 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -373,17 +373,11 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	int lock = newflags & VM_LOCKED;
 
 	if (newflags == vma->vm_flags ||
-			(vma->vm_flags & (VM_IO | VM_PFNMAP)))
+	    (vma->vm_flags & (VM_IO | VM_PFNMAP |
+			      VM_DONTEXPAND | VM_RESERVED)) ||
+	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current))
 		goto out;	/* don't set VM_LOCKED,  don't count */
 
-	if ((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED)) ||
-			is_vm_hugetlb_page(vma) ||
-			vma == get_gate_vma(current)) {
-		if (lock)
-			make_pages_present(start, end);
-		goto out;	/* don't set VM_LOCKED,  don't count */
-	}
-
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*prev = vma_merge(mm, *prev, start, end, newflags, vma->anon_vma,
 			  vma->vm_file, pgoff, vma_policy(vma));
@@ -419,14 +413,10 @@ success:
 	 * set VM_LOCKED, __mlock_vma_pages_range will bring it back.
 	 */
 
-	if (lock) {
+	if (lock)
 		vma->vm_flags = newflags;
-		ret = __mlock_vma_pages_range(vma, start, end);
-		if (ret < 0)
-			ret = __mlock_posix_error_return(ret);
-	} else {
+	else
 		munlock_vma_pages_range(vma, start, end);
-	}
 
 out:
 	*prev = vma;
@@ -439,7 +429,8 @@ static int do_mlock(unsigned long start, size_t len, int on)
 	struct vm_area_struct * vma, * prev;
 	int error;
 
-	len = PAGE_ALIGN(len);
+	VM_BUG_ON(start & ~PAGE_MASK);
+	VM_BUG_ON(len != PAGE_ALIGN(len));
 	end = start + len;
 	if (end < start)
 		return -EINVAL;
@@ -482,6 +473,58 @@ static int do_mlock(unsigned long start, size_t len, int on)
 	return error;
 }
 
+static int do_mlock_pages(unsigned long start, size_t len)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long end, nstart, nend, nfault;
+	struct vm_area_struct *vma;
+	int error = 0;
+
+	VM_BUG_ON(start & ~PAGE_MASK);
+	VM_BUG_ON(len != PAGE_ALIGN(len));
+	end = start + len;
+
+	for (nstart = start; nstart < end; nstart = nend) {
+		down_read(&mm->mmap_sem);
+		nend = end;
+		vma = find_vma_intersection(mm, nstart, nend);
+		if (!vma)
+			goto up;
+		if (vma->vm_end < nend)
+			nend = vma->vm_end;
+		if (vma->vm_flags & (VM_IO | VM_PFNMAP))
+			goto up;
+		if (nstart < vma->vm_start)
+			nstart = vma->vm_start;
+
+		/*
+		 * Limit batch size to 256 pages in order to reduce
+		 * mmap_sem hold time.
+		 */
+		nfault = nstart + 256 * PAGE_SIZE;
+
+		/*
+		 * Now fault in a batch of pages. We need to check the vma
+		 * flags again, as we've not been holding mmap_sem.
+		 */
+		if ((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED)) ||
+		    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current)) {
+			if (nfault < nend)
+				nend = nfault;
+			make_pages_present(nstart, nend);
+		} else if (vma->vm_flags & VM_LOCKED) {
+			if (nfault < nend)
+				nend = nfault;
+			error = __mlock_vma_pages_range(vma, nstart, nend);
+		}
+	up:
+		up_read(&mm->mmap_sem);
+		if (error)
+			return __mlock_posix_error_return(error);
+	}
+	return 0;
+}
+
 SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 {
 	unsigned long locked;
@@ -507,6 +550,8 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
 		error = do_mlock(start, len, 1);
 	up_write(&current->mm->mmap_sem);
+	if (!error)
+		error = do_mlock_pages(start, len);
 	return error;
 }
 
@@ -571,6 +616,8 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	    capable(CAP_IPC_LOCK))
 		ret = do_mlockall(flags);
 	up_write(&current->mm->mmap_sem);
+	if (!ret && (flags & MCL_CURRENT))
+		ret = do_mlock_pages(0, TASK_SIZE);
 out:
 	return ret;
 }

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
