Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id C77906B0036
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 10:37:57 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so1930223pbb.25
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 07:37:57 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id xs1si3176198pab.401.2014.04.03.07.37.56
        for <linux-mm@kvack.org>;
        Thu, 03 Apr 2014 07:37:57 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 5/5] mm: cleanup __get_user_pages()
Date: Thu,  3 Apr 2014 17:35:22 +0300
Message-Id: <1396535722-31108-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1396535722-31108-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1396535722-31108-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Get rid of two nested loops over nr_pages and other random cleanups.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/gup.c | 148 +++++++++++++++++++++++++++++++--------------------------------
 1 file changed, 72 insertions(+), 76 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 6ee33a6744af..6f5c5944f1a4 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -370,9 +370,10 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned int gup_flags, struct page **pages,
 		struct vm_area_struct **vmas, int *nonblocking)
 {
-	long i;
+	long i = 0;
 	unsigned long vm_flags;
 	unsigned int page_mask;
+	struct vm_area_struct *vma = NULL;
 
 	if (!nr_pages)
 		return 0;
@@ -400,88 +401,83 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
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
-				return i ? : ret;
-			page_mask = 0;
-			goto next_page;
-		}
-
-		if (!vma ||
-		    (vma->vm_flags & (VM_IO | VM_PFNMAP)) ||
-		    !(vm_flags & vma->vm_flags))
-			return i ? : -EFAULT;
-
-		if (is_vm_hugetlb_page(vma)) {
-			i = follow_hugetlb_page(mm, vma, pages, vmas,
-					&start, &nr_pages, i, gup_flags);
-			continue;
-		}
-
-		do {
-			struct page *page;
-			unsigned int foll_flags = gup_flags;
-			unsigned int page_increm;
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
 
-			/*
-			 * If we have a pending SIGKILL, don't keep faulting
-			 * pages and potentially allocating memory.
-			 */
-			if (unlikely(fatal_signal_pending(current)))
-				return i ? i : -ERESTARTSYS;
+			if (!vma || (vma->vm_flags & (VM_IO | VM_PFNMAP)) ||
+					!(vm_flags & vma->vm_flags))
+				return i ? : -EFAULT;
 
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
-					BUILD_BUG();
-				}
-				cond_resched();
+			if (is_vm_hugetlb_page(vma)) {
+				i = follow_hugetlb_page(mm, vma, pages, vmas,
+						&start, &nr_pages, i,
+						gup_flags);
+				continue;
 			}
-			if (IS_ERR(page))
-				return i ? i : PTR_ERR(page);
-			if (pages) {
-				pages[i] = page;
+		}
 
-				flush_anon_page(vma, page, start);
-				flush_dcache_page(page);
-				page_mask = 0;
+		/*
+		 * If we have a pending SIGKILL, don't keep faulting pages and
+		 * potentially allocating memory.
+		 */
+		if (unlikely(fatal_signal_pending(current)))
+			return i ? i : -ERESTARTSYS;
+retry:
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
+			BUILD_BUG();
+		}
+		if (IS_ERR(page))
+			return i ? i : PTR_ERR(page);
+		if (pages) {
+			pages[i] = page;
+			flush_anon_page(vma, page, start);
+			flush_dcache_page(page);
+			page_mask = 0;
+		}
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
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
