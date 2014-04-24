Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6FDAD6B0037
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 16:49:59 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so2341192pdj.27
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 13:49:59 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id iw3si3344137pac.383.2014.04.24.13.49.58
        for <linux-mm@kvack.org>;
        Thu, 24 Apr 2014 13:49:58 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 5/5] mm: cleanup __get_user_pages()
Date: Thu, 24 Apr 2014 23:45:18 +0300
Message-Id: <1398372318-26612-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1398372318-26612-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1398372318-26612-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Get rid of two nested loops over nr_pages, extract vma flags checking to
separate function and other random cleanups.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/gup.c | 218 +++++++++++++++++++++++++++++++--------------------------------
 1 file changed, 107 insertions(+), 111 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 8a4815380401..22036c28c6ec 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -315,6 +315,44 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 	return 0;
 }
 
+static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
+{
+	vm_flags_t vm_flags = vma->vm_flags;
+
+	if (vm_flags & (VM_IO | VM_PFNMAP))
+		return -EFAULT;
+
+	if (gup_flags & FOLL_WRITE) {
+		if (!(vm_flags & VM_WRITE)) {
+			if (!(gup_flags & FOLL_FORCE))
+				return -EFAULT;
+			/*
+			 * We used to let the write,force case do COW in a
+			 * VM_MAYWRITE VM_SHARED !VM_WRITE vma, so ptrace could
+			 * set a breakpoint in a read-only mapping of an
+			 * executable, without corrupting the file (yet only
+			 * when that file had been opened for writing!).
+			 * Anon pages in shared mappings are surprising: now
+			 * just reject it.
+			 */
+			if (!is_cow_mapping(vm_flags)) {
+				WARN_ON_ONCE(vm_flags & VM_MAYWRITE);
+				return -EFAULT;
+			}
+		}
+	} else if (!(vm_flags & VM_READ)) {
+		if (!(gup_flags & FOLL_FORCE))
+			return -EFAULT;
+		/*
+		 * Is there actually any vma we can reach here which does not
+		 * have VM_MAYREAD set?
+		 */
+		if (!(vm_flags & VM_MAYREAD))
+			return -EFAULT;
+	}
+	return 0;
+}
+
 /**
  * __get_user_pages() - pin user pages in memory
  * @tsk:	task_struct of target task
@@ -369,9 +407,9 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned int gup_flags, struct page **pages,
 		struct vm_area_struct **vmas, int *nonblocking)
 {
-	long i;
-	unsigned long vm_flags;
+	long i = 0;
 	unsigned int page_mask;
+	struct vm_area_struct *vma = NULL;
 
 	if (!nr_pages)
 		return 0;
@@ -390,124 +428,82 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 	if (!(gup_flags & FOLL_FORCE))
 		gup_flags |= FOLL_NUMA;
 
-	i = 0;
-
 	do {
-		struct vm_area_struct *vma;
-
-		vma = find_extend_vma(mm, start);
-		if (!vma && in_gate_area(mm, start)) {
-			int ret;
-			ret = get_gate_page(mm, start & PAGE_MASK, gup_flags,
-					&vma, pages ? &pages[i] : NULL);
-			if (ret)
-				goto efault;
-			page_mask = 0;
-			goto next_page;
-		}
+		struct page *page;
+		unsigned int foll_flags = gup_flags;
+		unsigned int page_increm;
+
+		/* first iteration or cross vma bound */
+		if (!vma || start >= vma->vm_end) {
+			vma = find_extend_vma(mm, start);
+			if (!vma && in_gate_area(mm, start)) {
+				int ret;
+				ret = get_gate_page(mm, start & PAGE_MASK,
+						gup_flags, &vma,
+						pages ? &pages[i] : NULL);
+				if (ret)
+					return i ? : ret;
+				page_mask = 0;
+				goto next_page;
+			}
 
-		if (!vma)
-			goto efault;
-		vm_flags = vma->vm_flags;
-		if (vm_flags & (VM_IO | VM_PFNMAP))
-			goto efault;
-
-		if (gup_flags & FOLL_WRITE) {
-			if (!(vm_flags & VM_WRITE)) {
-				if (!(gup_flags & FOLL_FORCE))
-					goto efault;
-				/*
-				 * We used to let the write,force case do COW
-				 * in a VM_MAYWRITE VM_SHARED !VM_WRITE vma, so
-				 * ptrace could set a breakpoint in a read-only
-				 * mapping of an executable, without corrupting
-				 * the file (yet only when that file had been
-				 * opened for writing!).  Anon pages in shared
-				 * mappings are surprising: now just reject it.
-				 */
-				if (!is_cow_mapping(vm_flags)) {
-					WARN_ON_ONCE(vm_flags & VM_MAYWRITE);
-					goto efault;
-				}
+			if (!vma || check_vma_flags(vma, gup_flags))
+				return i ? : -EFAULT;
+			if (is_vm_hugetlb_page(vma)) {
+				i = follow_hugetlb_page(mm, vma, pages, vmas,
+						&start, &nr_pages, i,
+						gup_flags);
+				continue;
 			}
-		} else {
-			if (!(vm_flags & VM_READ)) {
-				if (!(gup_flags & FOLL_FORCE))
-					goto efault;
-				/*
-				 * Is there actually any vma we can reach here
-				 * which does not have VM_MAYREAD set?
-				 */
-				if (!(vm_flags & VM_MAYREAD))
-					goto efault;
+		}
+retry:
+		/*
+		 * If we have a pending SIGKILL, don't keep faulting pages and
+		 * potentially allocating memory.
+		 */
+		if (unlikely(fatal_signal_pending(current)))
+			return i ? i : -ERESTARTSYS;
+		cond_resched();
+		page = follow_page_mask(vma, start, foll_flags, &page_mask);
+		if (!page) {
+			int ret;
+			ret = faultin_page(tsk, vma, start, &foll_flags,
+					nonblocking);
+			switch (ret) {
+			case 0:
+				goto retry;
+			case -EFAULT:
+			case -ENOMEM:
+			case -EHWPOISON:
+				return i ? i : ret;
+			case -EBUSY:
+				return i;
+			case -ENOENT:
+				goto next_page;
 			}
+			BUG();
 		}
-
-		if (is_vm_hugetlb_page(vma)) {
-			i = follow_hugetlb_page(mm, vma, pages, vmas,
-					&start, &nr_pages, i, gup_flags);
-			continue;
+		if (IS_ERR(page))
+			return i ? i : PTR_ERR(page);
+		if (pages) {
+			pages[i] = page;
+			flush_anon_page(vma, page, start);
+			flush_dcache_page(page);
+			page_mask = 0;
 		}
-
-		do {
-			struct page *page;
-			unsigned int foll_flags = gup_flags;
-			unsigned int page_increm;
-
-			/*
-			 * If we have a pending SIGKILL, don't keep faulting
-			 * pages and potentially allocating memory.
-			 */
-			if (unlikely(fatal_signal_pending(current)))
-				return i ? i : -ERESTARTSYS;
-
-			cond_resched();
-			while (!(page = follow_page_mask(vma, start,
-						foll_flags, &page_mask))) {
-				int ret;
-				ret = faultin_page(tsk, vma, start, &foll_flags,
-						nonblocking);
-				switch (ret) {
-				case 0:
-					break;
-				case -EFAULT:
-				case -ENOMEM:
-				case -EHWPOISON:
-					return i ? i : ret;
-				case -EBUSY:
-					return i;
-				case -ENOENT:
-					goto next_page;
-				default:
-					BUG();
-				}
-				cond_resched();
-			}
-			if (IS_ERR(page))
-				return i ? i : PTR_ERR(page);
-			if (pages) {
-				pages[i] = page;
-
-				flush_anon_page(vma, page, start);
-				flush_dcache_page(page);
-				page_mask = 0;
-			}
 next_page:
-			if (vmas) {
-				vmas[i] = vma;
-				page_mask = 0;
-			}
-			page_increm = 1 + (~(start >> PAGE_SHIFT) & page_mask);
-			if (page_increm > nr_pages)
-				page_increm = nr_pages;
-			i += page_increm;
-			start += page_increm * PAGE_SIZE;
-			nr_pages -= page_increm;
-		} while (nr_pages && start < vma->vm_end);
+		if (vmas) {
+			vmas[i] = vma;
+			page_mask = 0;
+		}
+		page_increm = 1 + (~(start >> PAGE_SHIFT) & page_mask);
+		if (page_increm > nr_pages)
+			page_increm = nr_pages;
+		i += page_increm;
+		start += page_increm * PAGE_SIZE;
+		nr_pages -= page_increm;
 	} while (nr_pages);
 	return i;
-efault:
-	return i ? : -EFAULT;
 }
 EXPORT_SYMBOL(__get_user_pages);
 
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
