Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id BD74D6B0031
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 10:37:56 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id x10so1874762pdj.23
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 07:37:56 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id xs1si3176198pab.401.2014.04.03.07.37.55
        for <linux-mm@kvack.org>;
        Thu, 03 Apr 2014 07:37:55 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 4/5] mm: extract code to fault in a page from __get_user_pages()
Date: Thu,  3 Apr 2014 17:35:21 +0300
Message-Id: <1396535722-31108-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1396535722-31108-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1396535722-31108-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Nesting level in __get_user_pages() is just insane. Let's try to fix it
a bit.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/gup.c | 130 +++++++++++++++++++++++++++++++++------------------------------
 1 file changed, 69 insertions(+), 61 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 6e2cd0ddb79f..6ee33a6744af 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -261,6 +261,61 @@ out:
 	return 0;
 }
 
+static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
+		unsigned long address, unsigned int *flags, int *nonblocking)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned int fault_flags = 0;
+	int ret;
+
+	/* For mlock, just skip the stack guard page. */
+	if ((*flags & FOLL_MLOCK) && stack_guard_page(vma, address))
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
@@ -388,69 +443,22 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
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
-						return i ? i : -EFAULT;
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
+					BUILD_BUG();
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
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
