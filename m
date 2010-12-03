Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CA9B76B0089
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 19:17:19 -0500 (EST)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id oB30HGTX018192
	for <linux-mm@kvack.org>; Thu, 2 Dec 2010 16:17:17 -0800
Received: from pzk27 (pzk27.prod.google.com [10.243.19.155])
	by kpbe18.cbf.corp.google.com with ESMTP id oB30HDeg003632
	for <linux-mm@kvack.org>; Thu, 2 Dec 2010 16:17:15 -0800
Received: by pzk27 with SMTP id 27so3754989pzk.0
        for <linux-mm@kvack.org>; Thu, 02 Dec 2010 16:17:13 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 1/6] mlock: only hold mmap_sem in shared mode when faulting in pages
Date: Thu,  2 Dec 2010 16:16:47 -0800
Message-Id: <1291335412-16231-2-git-send-email-walken@google.com>
In-Reply-To: <1291335412-16231-1-git-send-email-walken@google.com>
References: <1291335412-16231-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Before this change, mlock() holds mmap_sem in exclusive mode while the
pages get faulted in. In the case of a large mlock, this can potentially
take a very long time. Various things will block while mmap_sem is held,
including 'ps auxw'. This can make sysadmins angry.

I propose that mlock() could release mmap_sem after the VM_LOCKED bits
have been set in all appropriate VMAs. Then a second pass could be done
to actually mlock the pages with mmap_sem held for reads only. We need
to recheck the vma flags after we re-acquire mmap_sem, but this is easy.

In the case where a vma has been munlocked before mlock completes,
pages that were already marked as PageMlocked() are handled by the
munlock() call, and mlock() is careful to not mark new page batches
as PageMlocked() after the munlock() call has cleared the VM_LOCKED
vma flags. So, the end result will be identical to what'd happen if
munlock() had executed after the mlock() call.

In a later change, I will allow the second pass to release mmap_sem when
blocking on disk accesses or when it is otherwise contended, so that
it won't be held for long periods of time even in shared mode.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/mlock.c |   75 ++++++++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 58 insertions(+), 17 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 4f31864..8d6b702 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -377,18 +377,10 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	int ret = 0;
 	int lock = newflags & VM_LOCKED;
 
-	if (newflags == vma->vm_flags ||
-			(vma->vm_flags & (VM_IO | VM_PFNMAP)))
+	if (newflags == vma->vm_flags || (vma->vm_flags & VM_SPECIAL) ||
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
@@ -424,14 +416,10 @@ success:
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
@@ -444,7 +432,8 @@ static int do_mlock(unsigned long start, size_t len, int on)
 	struct vm_area_struct * vma, * prev;
 	int error;
 
-	len = PAGE_ALIGN(len);
+	VM_BUG_ON(start & ~PAGE_MASK);
+	VM_BUG_ON(len != PAGE_ALIGN(len));
 	end = start + len;
 	if (end < start)
 		return -EINVAL;
@@ -487,6 +476,54 @@ static int do_mlock(unsigned long start, size_t len, int on)
 	return error;
 }
 
+static int do_mlock_pages(unsigned long start, size_t len)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long end, nstart, nend;
+	struct vm_area_struct *vma = NULL;
+	int ret = 0;
+
+	VM_BUG_ON(start & ~PAGE_MASK);
+	VM_BUG_ON(len != PAGE_ALIGN(len));
+	end = start + len;
+
+	down_read(&mm->mmap_sem);
+	for (nstart = start; nstart < end; nstart = nend) {
+		/*
+		 * We want to fault in pages for [nstart; end) address range.
+		 * Find first corresponding VMA.
+		 */
+		if (!vma)
+			vma = find_vma(mm, nstart);
+		else
+			vma = vma->vm_next;
+		if (!vma || vma->vm_start >= end)
+			break;
+		/*
+		 * Set [nstart; nend) to intersection of desired address
+		 * range with the first VMA. Also, skip undesirable VMA types.
+		 */
+		nend = min(end, vma->vm_end);
+		if (vma->vm_flags & (VM_IO | VM_PFNMAP))
+			continue;
+		if (nstart < vma->vm_start)
+			nstart = vma->vm_start;
+		/*
+		 * Now fault in a range of pages within the first VMA.
+		 */
+		if (vma->vm_flags & VM_LOCKED) {
+			ret = __mlock_vma_pages_range(vma, nstart, nend);
+			if (ret) {
+				ret = __mlock_posix_error_return(ret);
+				break;
+			}
+		} else
+			make_pages_present(nstart, nend);
+	}
+	up_read(&mm->mmap_sem);
+	return ret;	/* 0 or negative error code */
+}
+
 SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 {
 	unsigned long locked;
@@ -512,6 +549,8 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
 		error = do_mlock(start, len, 1);
 	up_write(&current->mm->mmap_sem);
+	if (!error)
+		error = do_mlock_pages(start, len);
 	return error;
 }
 
@@ -576,6 +615,8 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	    capable(CAP_IPC_LOCK))
 		ret = do_mlockall(flags);
 	up_write(&current->mm->mmap_sem);
+	if (!ret && (flags & MCL_CURRENT))
+		ret = do_mlock_pages(0, TASK_SIZE);
 out:
 	return ret;
 }
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
