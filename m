Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5AC496B0039
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 15:41:20 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id rr13so6735572pbb.7
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 12:41:19 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id pg10si16605351pbb.54.2014.02.10.12.41.18
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 12:41:19 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 7/8] mm: consolidate code to call vm_ops->page_mkwrite()
Date: Mon, 10 Feb 2014 22:41:05 +0200
Message-Id: <1392064866-11840-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1392064866-11840-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1392064866-11840-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

There're two functions which need to call vm_ops->page_mkwrite():
do_shared_fault() and do_wp_page(). We can consolidate preparation code.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c | 104 +++++++++++++++++++++++++-----------------------------------
 1 file changed, 44 insertions(+), 60 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 288a351c6dd0..c36a21b912e1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2587,6 +2587,37 @@ static inline void cow_user_page(struct page *dst, struct page *src, unsigned lo
 }
 
 /*
+ * Notify the address space that the page is about to become writable so that
+ * it can prohibit this or wait for the page to get into an appropriate state.
+ *
+ * We do this without the lock held, so that it can sleep if it needs to.
+ */
+static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
+	       unsigned long address)
+{
+	struct vm_fault vmf;
+	int ret;
+
+	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
+	vmf.pgoff = page->index;
+	vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
+	vmf.page = page;
+
+	ret = vma->vm_ops->page_mkwrite(vma, &vmf);
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
+		return ret;
+	if (unlikely(!(ret & VM_FAULT_LOCKED))) {
+		lock_page(page);
+		if (!page->mapping) {
+			unlock_page(page);
+			return 0; /* retry */
+		}
+	} else
+		VM_BUG_ON_PAGE(!PageLocked(page), page);
+	return ret;
+}
+
+/*
  * This routine handles present pages, when users try to write
  * to a shared page. It is done by copying the page to a new address
  * and decrementing the shared-page counter for the old page.
@@ -2668,42 +2699,15 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * get_user_pages(.write=1, .force=1).
 		 */
 		if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
-			struct vm_fault vmf;
 			int tmp;
-
-			vmf.virtual_address = (void __user *)(address &
-								PAGE_MASK);
-			vmf.pgoff = old_page->index;
-			vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
-			vmf.page = old_page;
-
-			/*
-			 * Notify the address space that the page is about to
-			 * become writable so that it can prohibit this or wait
-			 * for the page to get into an appropriate state.
-			 *
-			 * We do this without the lock held, so that it can
-			 * sleep if it needs to.
-			 */
 			page_cache_get(old_page);
 			pte_unmap_unlock(page_table, ptl);
-
-			tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
-			if (unlikely(tmp &
-					(VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
-				ret = tmp;
-				goto unwritable_page;
+			tmp = do_page_mkwrite(vma, old_page, address);
+			if (unlikely(!tmp || (tmp &
+					(VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
+				page_cache_release(old_page);
+				return tmp;
 			}
-			if (unlikely(!(tmp & VM_FAULT_LOCKED))) {
-				lock_page(old_page);
-				if (!old_page->mapping) {
-					ret = 0; /* retry the fault */
-					unlock_page(old_page);
-					goto unwritable_page;
-				}
-			} else
-				VM_BUG_ON_PAGE(!PageLocked(old_page), old_page);
-
 			/*
 			 * Since we dropped the lock we need to revalidate
 			 * the PTE as someone else may have changed it.  If
@@ -2892,10 +2896,6 @@ oom:
 	if (old_page)
 		page_cache_release(old_page);
 	return VM_FAULT_OOM;
-
-unwritable_page:
-	page_cache_release(old_page);
-	return ret;
 }
 
 static void unmap_mapping_range_vma(struct vm_area_struct *vma,
@@ -3418,7 +3418,6 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	pte_t entry, *pte;
 	int dirtied = 0;
-	struct vm_fault vmf;
 	int ret, tmp;
 
 	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
@@ -3429,31 +3428,16 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * Check if the backing address space wants to know that the page is
 	 * about to become writable
 	 */
-	if (!vma->vm_ops->page_mkwrite)
-		goto set_pte;
-
-	unlock_page(fault_page);
-	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
-	vmf.pgoff = pgoff;
-	vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
-	vmf.page = fault_page;
-
-	tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
-	if (unlikely(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
-		page_cache_release(fault_page);
-		return tmp;
-	}
-
-	if (unlikely(!(tmp & VM_FAULT_LOCKED))) {
-		lock_page(fault_page);
-		if (!fault_page->mapping) {
-			unlock_page(fault_page);
+	if (vma->vm_ops->page_mkwrite) {
+		unlock_page(fault_page);
+		tmp = do_page_mkwrite(vma, fault_page, address);
+		if (unlikely(!tmp ||
+				(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
 			page_cache_release(fault_page);
-			return 0; /* retry */
+			return tmp;
 		}
-	} else
-		VM_BUG_ON_PAGE(!PageLocked(fault_page), fault_page);
-set_pte:
+	}
+
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 	if (unlikely(!pte_same(*pte, orig_pte))) {
 		pte_unmap_unlock(pte, ptl);
-- 
1.8.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
