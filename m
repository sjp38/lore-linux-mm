Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9793C6B0036
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 15:41:17 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id y10so6549453pdj.40
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 12:41:17 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id pg10si16605351pbb.54.2014.02.10.12.41.16
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 12:41:16 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/8] mm: do_fault(): extract to call vm_ops->do_fault() to separate function
Date: Mon, 10 Feb 2014 22:41:01 +0200
Message-Id: <1392064866-11840-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1392064866-11840-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1392064866-11840-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch extract code to vm_ops->do_fault() and basic error handling to
separate function. The code will be reused.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c | 76 ++++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 45 insertions(+), 31 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index e626283089ca..d3317ac02a5b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3286,6 +3286,37 @@ oom:
 	return VM_FAULT_OOM;
 }
 
+static int __do_fault(struct vm_area_struct *vma, unsigned long address,
+		pgoff_t pgoff, unsigned int flags, struct page **page)
+{
+	struct vm_fault vmf;
+	int ret;
+
+	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
+	vmf.pgoff = pgoff;
+	vmf.flags = flags;
+	vmf.page = NULL;
+
+	ret = vma->vm_ops->fault(vma, &vmf);
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
+		return ret;
+
+	if (unlikely(PageHWPoison(vmf.page))) {
+		if (ret & VM_FAULT_LOCKED)
+			unlock_page(vmf.page);
+		page_cache_release(vmf.page);
+		return VM_FAULT_HWPOISON;
+	}
+
+	if (unlikely(!(ret & VM_FAULT_LOCKED)))
+		lock_page(vmf.page);
+	else
+		VM_BUG_ON_PAGE(!PageLocked(vmf.page), vmf.page);
+
+	*page = vmf.page;
+	return ret;
+}
+
 /*
  * do_fault() tries to create a new page mapping. It aggressively
  * tries to share with existing pages, but makes a separate copy if
@@ -3305,12 +3336,11 @@ static int do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	pte_t *page_table;
 	spinlock_t *ptl;
-	struct page *page;
+	struct page *page, *fault_page;
 	struct page *cow_page;
 	pte_t entry;
 	int anon = 0;
 	struct page *dirty_page = NULL;
-	struct vm_fault vmf;
 	int ret;
 	int page_mkwrite = 0;
 
@@ -3334,42 +3364,19 @@ static int do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	} else
 		cow_page = NULL;
 
-	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
-	vmf.pgoff = pgoff;
-	vmf.flags = flags;
-	vmf.page = NULL;
-
-	ret = vma->vm_ops->fault(vma, &vmf);
-	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
-			    VM_FAULT_RETRY)))
+	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		goto uncharge_out;
 
-	if (unlikely(PageHWPoison(vmf.page))) {
-		if (ret & VM_FAULT_LOCKED)
-			unlock_page(vmf.page);
-		ret = VM_FAULT_HWPOISON;
-		page_cache_release(vmf.page);
-		goto uncharge_out;
-	}
-
-	/*
-	 * For consistency in subsequent calls, make the faulted page always
-	 * locked.
-	 */
-	if (unlikely(!(ret & VM_FAULT_LOCKED)))
-		lock_page(vmf.page);
-	else
-		VM_BUG_ON_PAGE(!PageLocked(vmf.page), vmf.page);
-
 	/*
 	 * Should we do an early C-O-W break?
 	 */
-	page = vmf.page;
+	page = fault_page;
 	if (flags & FAULT_FLAG_WRITE) {
 		if (!(vma->vm_flags & VM_SHARED)) {
 			page = cow_page;
 			anon = 1;
-			copy_user_highpage(page, vmf.page, address, vma);
+			copy_user_highpage(page, fault_page, address, vma);
 			__SetPageUptodate(page);
 		} else {
 			/*
@@ -3378,8 +3385,15 @@ static int do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			 * to become writable
 			 */
 			if (vma->vm_ops->page_mkwrite) {
+				struct vm_fault vmf;
 				int tmp;
 
+				vmf.virtual_address =
+					(void __user *)(address & PAGE_MASK);
+				vmf.pgoff = pgoff;
+				vmf.flags = flags;
+				vmf.page = fault_page;
+
 				unlock_page(page);
 				vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
 				tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
@@ -3469,9 +3483,9 @@ static int do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (vma->vm_file && !page_mkwrite)
 			file_update_time(vma->vm_file);
 	} else {
-		unlock_page(vmf.page);
+		unlock_page(fault_page);
 		if (anon)
-			page_cache_release(vmf.page);
+			page_cache_release(fault_page);
 	}
 
 	return ret;
-- 
1.8.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
