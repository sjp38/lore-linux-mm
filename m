Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id DD6516B0087
	for <linux-mm@kvack.org>; Sat, 11 May 2013 21:21:42 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 36/39] mm: do_wp_page(): extract VM_WRITE|VM_SHARED case to separate function
Date: Sun, 12 May 2013 04:23:33 +0300
Message-Id: <1368321816-17719-37-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The code will be shared with transhuge pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c |  142 ++++++++++++++++++++++++++++++-----------------------------
 1 file changed, 73 insertions(+), 69 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index eb99ab1..4685dd1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2641,6 +2641,76 @@ static void mkwrite_pte(struct vm_area_struct *vma, unsigned long address,
 }
 
 /*
+ * Only catch write-faults on shared writable pages, read-only shared pages can
+ * get COWed by get_user_pages(.write=1, .force=1).
+ */
+static int do_wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		spinlock_t *ptl, pte_t orig_pte, struct page *page)
+{
+	struct vm_fault vmf;
+	bool page_mkwrite = false;
+	int tmp, ret = 0;
+
+	if (vma->vm_ops && vma->vm_ops->page_mkwrite)
+		goto mkwrite_done;
+
+	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
+	vmf.pgoff = page->index;
+	vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
+	vmf.page = page;
+
+	/*
+	 * Notify the address space that the page is about to
+	 * become writable so that it can prohibit this or wait
+	 * for the page to get into an appropriate state.
+	 *
+	 * We do this without the lock held, so that it can
+	 * sleep if it needs to.
+	 */
+	page_cache_get(page);
+	pte_unmap_unlock(page_table, ptl);
+
+	tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
+	if (unlikely(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
+		ret = tmp;
+		page_cache_release(page);
+		return ret;
+	}
+	if (unlikely(!(tmp & VM_FAULT_LOCKED))) {
+		lock_page(page);
+		if (!page->mapping) {
+			unlock_page(page);
+			page_cache_release(page);
+			return ret;
+		}
+	} else
+		VM_BUG_ON(!PageLocked(page));
+
+	/*
+	 * Since we dropped the lock we need to revalidate
+	 * the PTE as someone else may have changed it.  If
+	 * they did, we just return, as we can count on the
+	 * MMU to tell us if they didn't also make it writable.
+	 */
+	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (!pte_same(*page_table, orig_pte)) {
+		unlock_page(page);
+		pte_unmap_unlock(page_table, ptl);
+		page_cache_release(page);
+		return ret;
+	}
+
+	page_mkwrite = true;
+mkwrite_done:
+	get_page(page);
+	mkwrite_pte(vma, address, page_table, orig_pte);
+	pte_unmap_unlock(page_table, ptl);
+	dirty_page(vma, page, page_mkwrite);
+	return ret | VM_FAULT_WRITE;
+}
+
+/*
  * This routine handles present pages, when users try to write
  * to a shared page. It is done by copying the page to a new address
  * and decrementing the shared-page counter for the old page.
@@ -2665,7 +2735,6 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct page *old_page, *new_page = NULL;
 	int ret = 0;
-	int page_mkwrite = 0;
 	unsigned long mmun_start = 0;	/* For mmu_notifiers */
 	unsigned long mmun_end = 0;	/* For mmu_notifiers */
 
@@ -2718,70 +2787,9 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 		unlock_page(old_page);
 	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
-					(VM_WRITE|VM_SHARED))) {
-		/*
-		 * Only catch write-faults on shared writable pages,
-		 * read-only shared pages can get COWed by
-		 * get_user_pages(.write=1, .force=1).
-		 */
-		if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
-			struct vm_fault vmf;
-			int tmp;
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
-			page_cache_get(old_page);
-			pte_unmap_unlock(page_table, ptl);
-
-			tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
-			if (unlikely(tmp &
-					(VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
-				ret = tmp;
-				goto unwritable_page;
-			}
-			if (unlikely(!(tmp & VM_FAULT_LOCKED))) {
-				lock_page(old_page);
-				if (!old_page->mapping) {
-					ret = 0; /* retry the fault */
-					unlock_page(old_page);
-					goto unwritable_page;
-				}
-			} else
-				VM_BUG_ON(!PageLocked(old_page));
-
-			/*
-			 * Since we dropped the lock we need to revalidate
-			 * the PTE as someone else may have changed it.  If
-			 * they did, we just return, as we can count on the
-			 * MMU to tell us if they didn't also make it writable.
-			 */
-			page_table = pte_offset_map_lock(mm, pmd, address,
-							 &ptl);
-			if (!pte_same(*page_table, orig_pte)) {
-				unlock_page(old_page);
-				goto unlock;
-			}
-
-			page_mkwrite = 1;
-		}
-		get_page(old_page);
-		mkwrite_pte(vma, address, page_table, orig_pte);
-		pte_unmap_unlock(page_table, ptl);
-		dirty_page(vma, old_page, page_mkwrite);
-		return ret | VM_FAULT_WRITE;
-	}
+					(VM_WRITE|VM_SHARED)))
+		return do_wp_page_shared(mm, vma, address, page_table, pmd, ptl,
+				orig_pte, old_page);
 
 	/*
 	 * Ok, we need to copy. Oh, well..
@@ -2900,10 +2908,6 @@ oom:
 	if (old_page)
 		page_cache_release(old_page);
 	return VM_FAULT_OOM;
-
-unwritable_page:
-	page_cache_release(old_page);
-	return ret;
 }
 
 static void unmap_mapping_range_vma(struct vm_area_struct *vma,
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
