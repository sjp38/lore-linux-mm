Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 31DB96B0037
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 16:49:57 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id fp1so161525pdb.6
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 13:49:56 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id iw3si3344137pac.383.2014.04.24.13.49.55
        for <linux-mm@kvack.org>;
        Thu, 24 Apr 2014 13:49:56 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 4/5] mm: extract code to fault in a page from __get_user_pages()
Date: Thu, 24 Apr 2014 23:45:17 +0300
Message-Id: <1398372318-26612-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1398372318-26612-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1398372318-26612-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Nesting level in __get_user_pages() is just insane. Let's try to fix it
a bit.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/gup.c | 138 ++++++++++++++++++++++++++++++++-------------------------------
 1 file changed, 71 insertions(+), 67 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index e0c648cbeee0..8a4815380401 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -214,12 +214,6 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	return follow_page_pte(vma, address, pmd, flags);
 }
 
-static inline int stack_guard_page(struct vm_area_struct *vma, unsigned long addr)
-{
-	return stack_guard_page_start(vma, addr) ||
-	       stack_guard_page_end(vma, addr+PAGE_SIZE);
-}
-
 static int get_gate_page(struct mm_struct *mm, unsigned long address,
 		unsigned int gup_flags, struct vm_area_struct **vma,
 		struct page **page)
@@ -264,6 +258,63 @@ unmap:
 	return ret;
 }
 
+static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
+		unsigned long address, unsigned int *flags, int *nonblocking)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned int fault_flags = 0;
+	int ret;
+
+	/* For mlock, just skip the stack guard page. */
+	if ((*flags & FOLL_MLOCK) &&
+			(stack_guard_page_start(vma, address) ||
+			 stack_guard_page_end(vma, address + PAGE_SIZE)))
+		return -ENOENT;
+	if (*flags & FOLL_WRITE)
+		fault_flags |= FAULT_FLAG_WRITE;
+	if (nonblocking)
+		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
+	if (*flags & FOLL_NOWAIT)
+		fault_flags |= FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
+
+	ret = handle_mm_fault(mm, vma, address, fault_flags);
+	if (ret & VM_FAULT_ERROR) {
+		if (ret & VM_FAULT_OOM)
+			return -ENOMEM;
+		if (ret & (VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE))
+			return *flags & FOLL_HWPOISON ? -EHWPOISON : -EFAULT;
+		if (ret & VM_FAULT_SIGBUS)
+			return -EFAULT;
+		BUG();
+	}
+
+	if (tsk) {
+		if (ret & VM_FAULT_MAJOR)
+			tsk->maj_flt++;
+		else
+			tsk->min_flt++;
+	}
+
+	if (ret & VM_FAULT_RETRY) {
+		if (nonblocking)
+			*nonblocking = 0;
+		return -EBUSY;
+	}
+
+	/*
+	 * The VM_FAULT_WRITE bit tells us that do_wp_page has broken COW when
+	 * necessary, even if maybe_mkwrite decided not to set pte_write. We
+	 * can thus safely do subsequent page lookups as if they were reads.
+	 * But only do so when looping for pte_write is futile: in some cases
+	 * userspace may also be wanting to write to the gotten user page,
+	 * which a read fault here might prevent (a readonly page might get
+	 * reCOWed by userspace write).
+	 */
+	if ((ret & VM_FAULT_WRITE) && !(vma->vm_flags & VM_WRITE))
+		*flags &= ~FOLL_WRITE;
+	return 0;
+}
+
 /**
  * __get_user_pages() - pin user pages in memory
  * @tsk:	task_struct of target task
@@ -414,69 +465,22 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			while (!(page = follow_page_mask(vma, start,
 						foll_flags, &page_mask))) {
 				int ret;
-				unsigned int fault_flags = 0;
-
-				/* For mlock, just skip the stack guard page. */
-				if (foll_flags & FOLL_MLOCK) {
-					if (stack_guard_page(vma, start))
-						goto next_page;
-				}
-				if (foll_flags & FOLL_WRITE)
-					fault_flags |= FAULT_FLAG_WRITE;
-				if (nonblocking)
-					fault_flags |= FAULT_FLAG_ALLOW_RETRY;
-				if (foll_flags & FOLL_NOWAIT)
-					fault_flags |= (FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT);
-
-				ret = handle_mm_fault(mm, vma, start,
-							fault_flags);
-
-				if (ret & VM_FAULT_ERROR) {
-					if (ret & VM_FAULT_OOM)
-						return i ? i : -ENOMEM;
-					if (ret & (VM_FAULT_HWPOISON |
-						   VM_FAULT_HWPOISON_LARGE)) {
-						if (i)
-							return i;
-						else if (gup_flags & FOLL_HWPOISON)
-							return -EHWPOISON;
-						else
-							return -EFAULT;
-					}
-					if (ret & VM_FAULT_SIGBUS)
-						goto efault;
-					BUG();
-				}
-
-				if (tsk) {
-					if (ret & VM_FAULT_MAJOR)
-						tsk->maj_flt++;
-					else
-						tsk->min_flt++;
-				}
-
-				if (ret & VM_FAULT_RETRY) {
-					if (nonblocking)
-						*nonblocking = 0;
+				ret = faultin_page(tsk, vma, start, &foll_flags,
+						nonblocking);
+				switch (ret) {
+				case 0:
+					break;
+				case -EFAULT:
+				case -ENOMEM:
+				case -EHWPOISON:
+					return i ? i : ret;
+				case -EBUSY:
 					return i;
+				case -ENOENT:
+					goto next_page;
+				default:
+					BUG();
 				}
-
-				/*
-				 * The VM_FAULT_WRITE bit tells us that
-				 * do_wp_page has broken COW when necessary,
-				 * even if maybe_mkwrite decided not to set
-				 * pte_write. We can thus safely do subsequent
-				 * page lookups as if they were reads. But only
-				 * do so when looping for pte_write is futile:
-				 * in some cases userspace may also be wanting
-				 * to write to the gotten user page, which a
-				 * read fault here might prevent (a readonly
-				 * page might get reCOWed by userspace write).
-				 */
-				if ((ret & VM_FAULT_WRITE) &&
-				    !(vma->vm_flags & VM_WRITE))
-					foll_flags &= ~FOLL_WRITE;
-
 				cond_resched();
 			}
 			if (IS_ERR(page))
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
