Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id E93676B0072
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 11:56:31 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id l15so25300541wiw.14
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 08:56:31 -0800 (PST)
Received: from mellanox.co.il ([193.47.165.129])
        by mx.google.com with ESMTP id b12si24017729wic.11.2014.12.01.08.56.30
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 08:56:31 -0800 (PST)
From: Shachar Raindel <raindel@mellanox.com>
Subject: [PATCH v1 1/4] mm: Refactor do_wp_page, extract the reuse case
Date: Mon,  1 Dec 2014 18:56:14 +0200
Message-Id: <1417452977-11337-2-git-send-email-raindel@mellanox.com>
In-Reply-To: <1417452977-11337-1-git-send-email-raindel@mellanox.com>
References: <1417452977-11337-1-git-send-email-raindel@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com, raindel@mellanox.com

When do_wp_page is ending, in several cases it needs to reuse the
existing page. This is achieved by making the page table writable,
and possibly updating the page-cache state.

Currently, this logic was "called" by using a goto jump. This makes
following the control flow of the function harder. It is also
against the coding style guidelines for using goto.

As the code can easily be refactored into a specialized function,
refactor it out and simplify the code flow in do_wp_page.

Signed-off-by: Shachar Raindel <raindel@mellanox.com>
---
 mm/memory.c | 135 ++++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 77 insertions(+), 58 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 3e50383..6bb5d42 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2020,6 +2020,74 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
 }
 
 /*
+ * Handle write page faults for pages that can be reused in the current vma
+ *
+ * This can happen either due to the mapping being with the VM_SHARED flag,
+ * or due to us being the last reference standing to the page. In either
+ * case, all we need to do here is to mark the page as writable and update
+ * any related book-keeping.
+ */
+static int wp_page_reuse(struct mm_struct *mm, struct vm_area_struct *vma,
+			 unsigned long address, pte_t *page_table,
+			 spinlock_t *ptl, pte_t orig_pte,
+			 struct page *page, int dirty_page,
+			 int page_mkwrite)
+	__releases(ptl)
+{
+	pte_t entry;
+	/*
+	 * Clear the pages cpupid information as the existing
+	 * information potentially belongs to a now completely
+	 * unrelated process.
+	 */
+	if (page)
+		page_cpupid_xchg_last(page, (1 << LAST_CPUPID_SHIFT) - 1);
+
+	flush_cache_page(vma, address, pte_pfn(orig_pte));
+	entry = pte_mkyoung(orig_pte);
+	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	if (ptep_set_access_flags(vma, address, page_table, entry, 1))
+		update_mmu_cache(vma, address, page_table);
+	pte_unmap_unlock(page_table, ptl);
+
+	if (!dirty_page || !page)
+		return VM_FAULT_WRITE;
+
+	/*
+	 * Yes, Virginia, this is actually required to prevent a race
+	 * with clear_page_dirty_for_io() from clearing the page dirty
+	 * bit after it clear all dirty ptes, but before a racing
+	 * do_wp_page installs a dirty pte.
+	 *
+	 * do_shared_fault is protected similarly.
+	 */
+	if (!page_mkwrite) {
+		wait_on_page_locked(page);
+		set_page_dirty_balance(page);
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
+
+	return VM_FAULT_WRITE;
+}
+
+/*
  * This routine handles present pages, when users try to write
  * to a shared page. It is done by copying the page to a new address
  * and decrementing the shared-page counter for the old page.
@@ -2045,8 +2113,6 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *old_page, *new_page = NULL;
 	pte_t entry;
 	int ret = 0;
-	int page_mkwrite = 0;
-	struct page *dirty_page = NULL;
 	unsigned long mmun_start = 0;	/* For mmu_notifiers */
 	unsigned long mmun_end = 0;	/* For mmu_notifiers */
 	struct mem_cgroup *memcg;
@@ -2063,7 +2129,8 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 */
 		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 				     (VM_WRITE|VM_SHARED))
-			goto reuse;
+			return wp_page_reuse(mm, vma, address, page_table, ptl,
+					     orig_pte, old_page, 0, 0);
 		goto gotten;
 	}
 
@@ -2092,11 +2159,14 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			 */
 			page_move_anon_rmap(old_page, vma, address);
 			unlock_page(old_page);
-			goto reuse;
+			return wp_page_reuse(mm, vma, address, page_table, ptl,
+					     orig_pte, old_page, 0, 0);
 		}
 		unlock_page(old_page);
 	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 					(VM_WRITE|VM_SHARED))) {
+		int page_mkwrite = 0;
+
 		/*
 		 * Only catch write-faults on shared writable pages,
 		 * read-only shared pages can get COWed by
@@ -2127,61 +2197,10 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 			page_mkwrite = 1;
 		}
-		dirty_page = old_page;
-		get_page(dirty_page);
-
-reuse:
-		/*
-		 * Clear the pages cpupid information as the existing
-		 * information potentially belongs to a now completely
-		 * unrelated process.
-		 */
-		if (old_page)
-			page_cpupid_xchg_last(old_page, (1 << LAST_CPUPID_SHIFT) - 1);
-
-		flush_cache_page(vma, address, pte_pfn(orig_pte));
-		entry = pte_mkyoung(orig_pte);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		if (ptep_set_access_flags(vma, address, page_table, entry,1))
-			update_mmu_cache(vma, address, page_table);
-		pte_unmap_unlock(page_table, ptl);
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
-		 * do_shared_fault is protected similarly.
-		 */
-		if (!page_mkwrite) {
-			wait_on_page_locked(dirty_page);
-			set_page_dirty_balance(dirty_page);
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
+		get_page(old_page);
 
-		return ret;
+		return wp_page_reuse(mm, vma, address, page_table, ptl,
+				     orig_pte, old_page, 1, page_mkwrite);
 	}
 
 	/*
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
