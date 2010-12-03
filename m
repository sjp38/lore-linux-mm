Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 96CE86B0093
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 19:17:29 -0500 (EST)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id oB30HOdX017006
	for <linux-mm@kvack.org>; Thu, 2 Dec 2010 16:17:25 -0800
Received: from pwi7 (pwi7.prod.google.com [10.241.219.7])
	by wpaz33.hot.corp.google.com with ESMTP id oB30HNwY030803
	for <linux-mm@kvack.org>; Thu, 2 Dec 2010 16:17:23 -0800
Received: by pwi7 with SMTP id 7so1347188pwi.3
        for <linux-mm@kvack.org>; Thu, 02 Dec 2010 16:17:23 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 5/6] mlock: do not hold mmap_sem for extended periods of time
Date: Thu,  2 Dec 2010 16:16:51 -0800
Message-Id: <1291335412-16231-6-git-send-email-walken@google.com>
In-Reply-To: <1291335412-16231-1-git-send-email-walken@google.com>
References: <1291335412-16231-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

__get_user_pages gets a new 'nonblocking' parameter to signal that the
caller is prepared to re-acquire mmap_sem and retry the operation if needed.
This is used to split off long operations if they are going to block on
a disk transfer, or when we detect contention on the mmap_sem.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/internal.h |    3 ++-
 mm/memory.c   |   27 ++++++++++++++++++++++-----
 mm/mlock.c    |   34 ++++++++++++++++++++--------------
 mm/nommu.c    |    6 ++++--
 4 files changed, 48 insertions(+), 22 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index dedb0af..bd4f581 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -243,7 +243,8 @@ static inline void mminit_validate_memmodel_limits(unsigned long *start_pfn,
 
 int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		     unsigned long start, int len, unsigned int foll_flags,
-		     struct page **pages, struct vm_area_struct **vmas);
+		     struct page **pages, struct vm_area_struct **vmas,
+		     int *nonblocking);
 
 #define ZONE_RECLAIM_NOSCAN	-2
 #define ZONE_RECLAIM_FULL	-1
diff --git a/mm/memory.c b/mm/memory.c
index f3a9242..85e56dc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1366,7 +1366,8 @@ no_page_table:
 
 int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		     unsigned long start, int nr_pages, unsigned int gup_flags,
-		     struct page **pages, struct vm_area_struct **vmas)
+		     struct page **pages, struct vm_area_struct **vmas,
+		     int *nonblocking)
 {
 	int i;
 	unsigned long vm_flags;
@@ -1465,11 +1466,15 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 
 			cond_resched();
 			while (!(page = follow_page(vma, start, foll_flags))) {
+				int fault_flags = 0;
 				int ret;
 
+				if (foll_flags & FOLL_WRITE)
+					fault_flags |= FAULT_FLAG_WRITE;
+				if (nonblocking)
+					fault_flags |= FAULT_FLAG_ALLOW_RETRY;
 				ret = handle_mm_fault(mm, vma, start,
-					(foll_flags & FOLL_WRITE) ?
-					FAULT_FLAG_WRITE : 0);
+						      fault_flags);
 
 				if (ret & VM_FAULT_ERROR) {
 					if (ret & VM_FAULT_OOM)
@@ -1485,6 +1490,11 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 				else
 					tsk->min_flt++;
 
+				if (ret & VM_FAULT_RETRY) {
+					*nonblocking = 0;
+					return i;
+				}
+
 				/*
 				 * The VM_FAULT_WRITE bit tells us that
 				 * do_wp_page has broken COW when necessary,
@@ -1516,6 +1526,11 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			i++;
 			start += PAGE_SIZE;
 			nr_pages--;
+			if (nonblocking && rwsem_is_contended(&mm->mmap_sem)) {
+				up_read(&mm->mmap_sem);
+				*nonblocking = 0;
+				return i;
+			}
 		} while (nr_pages && start < vma->vm_end);
 	} while (nr_pages);
 	return i;
@@ -1584,7 +1599,8 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 	if (force)
 		flags |= FOLL_FORCE;
 
-	return __get_user_pages(tsk, mm, start, nr_pages, flags, pages, vmas);
+	return __get_user_pages(tsk, mm, start, nr_pages, flags, pages, vmas,
+				NULL);
 }
 EXPORT_SYMBOL(get_user_pages);
 
@@ -1609,7 +1625,8 @@ struct page *get_dump_page(unsigned long addr)
 	struct page *page;
 
 	if (__get_user_pages(current, current->mm, addr, 1,
-			FOLL_FORCE | FOLL_DUMP | FOLL_GET, &page, &vma) < 1)
+			     FOLL_FORCE | FOLL_DUMP | FOLL_GET, &page, &vma,
+			     NULL) < 1)
 		return NULL;
 	flush_cache_page(vma, addr, page_to_pfn(page));
 	return page;
diff --git a/mm/mlock.c b/mm/mlock.c
index 241a5d2..569ae6a 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -155,13 +155,13 @@ static inline int stack_guard_page(struct vm_area_struct *vma, unsigned long add
  * vma->vm_mm->mmap_sem must be held for at least read.
  */
 static long __mlock_vma_pages_range(struct vm_area_struct *vma,
-				    unsigned long start, unsigned long end)
+				    unsigned long start, unsigned long end,
+				    int *nonblocking)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long addr = start;
 	int nr_pages = (end - start) / PAGE_SIZE;
 	int gup_flags;
-	int ret;
 
 	VM_BUG_ON(start & ~PAGE_MASK);
 	VM_BUG_ON(end   & ~PAGE_MASK);
@@ -187,9 +187,8 @@ static long __mlock_vma_pages_range(struct vm_area_struct *vma,
 		nr_pages--;
 	}
 
-	ret = __get_user_pages(current, mm, addr, nr_pages, gup_flags,
-			       NULL, NULL);
-	return max(ret, 0);	/* 0 or negative error code */
+	return __get_user_pages(current, mm, addr, nr_pages, gup_flags,
+				NULL, NULL, nonblocking);
 }
 
 /*
@@ -233,7 +232,7 @@ long mlock_vma_pages_range(struct vm_area_struct *vma,
 			is_vm_hugetlb_page(vma) ||
 			vma == get_gate_vma(current))) {
 
-		__mlock_vma_pages_range(vma, start, end);
+		__mlock_vma_pages_range(vma, start, end, NULL);
 
 		/* Hide errors from mmap() and other callers */
 		return 0;
@@ -429,21 +428,23 @@ static int do_mlock_pages(unsigned long start, size_t len)
 	struct mm_struct *mm = current->mm;
 	unsigned long end, nstart, nend;
 	struct vm_area_struct *vma = NULL;
+	int locked = 0;
 	int ret = 0;
 
 	VM_BUG_ON(start & ~PAGE_MASK);
 	VM_BUG_ON(len != PAGE_ALIGN(len));
 	end = start + len;
 
-	down_read(&mm->mmap_sem);
 	for (nstart = start; nstart < end; nstart = nend) {
 		/*
 		 * We want to fault in pages for [nstart; end) address range.
 		 * Find first corresponding VMA.
 		 */
-		if (!vma)
+		if (!locked) {
+			locked = 1;
+			down_read(&mm->mmap_sem);
 			vma = find_vma(mm, nstart);
-		else
+		} else if (nstart >= vma->vm_end)
 			vma = vma->vm_next;
 		if (!vma || vma->vm_start >= end)
 			break;
@@ -456,16 +457,21 @@ static int do_mlock_pages(unsigned long start, size_t len)
 			continue;
 		if (nstart < vma->vm_start)
 			nstart = vma->vm_start;
 		/*
-		 * Now fault in a range of pages within the first VMA.
+		 * Now fault in a range of pages. __mlock_vma_pages_range()
+		 * double checks the vma flags, so that it won't mlock pages
+		 * if the vma was already munlocked.
 		 */
-		ret = __mlock_vma_pages_range(vma, nstart, nend);
-		if (ret) {
+		ret = __mlock_vma_pages_range(vma, nstart, nend, &locked);
+		if (ret < 0) {
 			ret = __mlock_posix_error_return(ret);
 			break;
 		}
+		nend = nstart + ret * PAGE_SIZE;
+		ret = 0;
 	}
-	up_read(&mm->mmap_sem);
+	if (locked)
+		up_read(&mm->mmap_sem);
 	return ret;	/* 0 or negative error code */
 }
 
diff --git a/mm/nommu.c b/mm/nommu.c
index 27a9ac5..c8b8a7e 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -127,7 +127,8 @@ unsigned int kobjsize(const void *objp)
 
 int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		     unsigned long start, int nr_pages, unsigned int foll_flags,
-		     struct page **pages, struct vm_area_struct **vmas)
+		     struct page **pages, struct vm_area_struct **vmas,
+		     int *retry)
 {
 	struct vm_area_struct *vma;
 	unsigned long vm_flags;
@@ -185,7 +186,8 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 	if (force)
 		flags |= FOLL_FORCE;
 
-	return __get_user_pages(tsk, mm, start, nr_pages, flags, pages, vmas);
+	return __get_user_pages(tsk, mm, start, nr_pages, flags, pages, vmas,
+				NULL);
 }
 EXPORT_SYMBOL(get_user_pages);
 
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
