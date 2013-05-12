Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id AF0606B0089
	for <linux-mm@kvack.org>; Sat, 11 May 2013 21:21:42 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 35/39] mm: decomposite do_wp_page() and get rid of some 'goto' logic
Date: Sun, 12 May 2013 04:23:32 +0300
Message-Id: <1368321816-17719-36-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Let's extract some 'reuse' path to separate function and use it instead
of ugly goto.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c |  110 ++++++++++++++++++++++++++++++++---------------------------
 1 file changed, 59 insertions(+), 51 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 8997cd8..eb99ab1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2594,6 +2594,52 @@ static inline void cow_user_page(struct page *dst, struct page *src, unsigned lo
 		copy_user_highpage(dst, src, va, vma);
 }
 
+static void dirty_page(struct vm_area_struct *vma, struct page *page,
+		bool page_mkwrite)
+{
+	/*
+	 * Yes, Virginia, this is actually required to prevent a race
+	 * with clear_page_dirty_for_io() from clearing the page dirty
+	 * bit after it clear all dirty ptes, but before a racing
+	 * do_wp_page installs a dirty pte.
+	 *
+	 * __do_fault is protected similarly.
+	 */
+	if (!page_mkwrite) {
+		wait_on_page_locked(page);
+		set_page_dirty_balance(page, page_mkwrite);
+		/* file_update_time outside page_lock */
+		if (vma->vm_file)
+			file_update_time(vma->vm_file);
+	}
+	put_page(page);
+	if (page_mkwrite) {
+		struct address_space *mapping = page->mapping;
+
+		set_page_dirty(page);
+		unlock_page(page);
+		page_cache_release(page);
+		if (mapping)	{
+			/*
+			 * Some device drivers do not set page.mapping
+			 * but still dirty their pages
+			 */
+			balance_dirty_pages_ratelimited(mapping);
+		}
+	}
+}
+
+static void mkwrite_pte(struct vm_area_struct *vma, unsigned long address,
+		pte_t *page_table, pte_t orig_pte)
+{
+	pte_t entry;
+	flush_cache_page(vma, address, pte_pfn(orig_pte));
+	entry = pte_mkyoung(orig_pte);
+	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	if (ptep_set_access_flags(vma, address, page_table, entry, 1))
+		update_mmu_cache(vma, address, page_table);
+}
+
 /*
  * This routine handles present pages, when users try to write
  * to a shared page. It is done by copying the page to a new address
@@ -2618,10 +2664,8 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	__releases(ptl)
 {
 	struct page *old_page, *new_page = NULL;
-	pte_t entry;
 	int ret = 0;
 	int page_mkwrite = 0;
-	struct page *dirty_page = NULL;
 	unsigned long mmun_start = 0;	/* For mmu_notifiers */
 	unsigned long mmun_end = 0;	/* For mmu_notifiers */
 
@@ -2635,8 +2679,11 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * accounting on raw pfn maps.
 		 */
 		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
-				     (VM_WRITE|VM_SHARED))
-			goto reuse;
+				     (VM_WRITE|VM_SHARED)) {
+			mkwrite_pte(vma, address, page_table, orig_pte);
+			pte_unmap_unlock(page_table, ptl);
+			return VM_FAULT_WRITE;
+		}
 		goto gotten;
 	}
 
@@ -2665,7 +2712,9 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			 */
 			page_move_anon_rmap(old_page, vma, address);
 			unlock_page(old_page);
-			goto reuse;
+			mkwrite_pte(vma, address, page_table, orig_pte);
+			pte_unmap_unlock(page_table, ptl);
+			return VM_FAULT_WRITE;
 		}
 		unlock_page(old_page);
 	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
@@ -2727,53 +2776,11 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 			page_mkwrite = 1;
 		}
-		dirty_page = old_page;
-		get_page(dirty_page);
-
-reuse:
-		flush_cache_page(vma, address, pte_pfn(orig_pte));
-		entry = pte_mkyoung(orig_pte);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		if (ptep_set_access_flags(vma, address, page_table, entry,1))
-			update_mmu_cache(vma, address, page_table);
+		get_page(old_page);
+		mkwrite_pte(vma, address, page_table, orig_pte);
 		pte_unmap_unlock(page_table, ptl);
-		ret |= VM_FAULT_WRITE;
-
-		if (!dirty_page)
-			return ret;
-
-		/*
-		 * Yes, Virginia, this is actually required to prevent a race
-		 * with clear_page_dirty_for_io() from clearing the page dirty
-		 * bit after it clear all dirty ptes, but before a racing
-		 * do_wp_page installs a dirty pte.
-		 *
-		 * __do_fault is protected similarly.
-		 */
-		if (!page_mkwrite) {
-			wait_on_page_locked(dirty_page);
-			set_page_dirty_balance(dirty_page, page_mkwrite);
-			/* file_update_time outside page_lock */
-			if (vma->vm_file)
-				file_update_time(vma->vm_file);
-		}
-		put_page(dirty_page);
-		if (page_mkwrite) {
-			struct address_space *mapping = dirty_page->mapping;
-
-			set_page_dirty(dirty_page);
-			unlock_page(dirty_page);
-			page_cache_release(dirty_page);
-			if (mapping)	{
-				/*
-				 * Some device drivers do not set page.mapping
-				 * but still dirty their pages
-				 */
-				balance_dirty_pages_ratelimited(mapping);
-			}
-		}
-
-		return ret;
+		dirty_page(vma, old_page, page_mkwrite);
+		return ret | VM_FAULT_WRITE;
 	}
 
 	/*
@@ -2810,6 +2817,7 @@ gotten:
 	 */
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 	if (likely(pte_same(*page_table, orig_pte))) {
+		pte_t entry;
 		if (old_page) {
 			if (!PageAnon(old_page)) {
 				dec_mm_counter_fast(mm, MM_FILEPAGES);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
