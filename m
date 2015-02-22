Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD2A6B0075
	for <linux-mm@kvack.org>; Sun, 22 Feb 2015 08:42:46 -0500 (EST)
Received: by wevk48 with SMTP id k48so13491811wev.0
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 05:42:45 -0800 (PST)
Received: from mellanox.co.il ([193.47.165.129])
        by mx.google.com with ESMTP id i17si12524943wiv.66.2015.02.22.05.42.43
        for <linux-mm@kvack.org>;
        Sun, 22 Feb 2015 05:42:44 -0800 (PST)
From: Shachar Raindel <raindel@mellanox.com>
Subject: [PATCH V5 1/4] mm: Refactor do_wp_page, extract the reuse case
Date: Sun, 22 Feb 2015 15:42:15 +0200
Message-Id: <1424612538-25889-2-git-send-email-raindel@mellanox.com>
In-Reply-To: <1424612538-25889-1-git-send-email-raindel@mellanox.com>
References: <1424612538-25889-1-git-send-email-raindel@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com, raindel@mellanox.com, Dave Hansen <dave.hansen@intel.com>

When do_wp_page is ending, in several cases it needs to reuse the
existing page. This is achieved by making the page table writable,
and possibly updating the page-cache state.

Currently, this logic was "called" by using a goto jump. This makes
following the control flow of the function harder. It is also
against the coding style guidelines for using goto.

As the code can easily be refactored into a specialized function,
refactor it out and simplify the code flow in do_wp_page.

Signed-off-by: Shachar Raindel <raindel@mellanox.com>
Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Andi Kleen <ak@linux.intel.com>
Acked-by: Haggai Eran <haggaie@mellanox.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Feiner <pfeiner@google.com>
Cc: Michel Lespinasse <walken@google.com>
---
 mm/memory.c | 117 +++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 68 insertions(+), 49 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 8068893..7a04414 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1983,6 +1983,65 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
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
+			 struct page *page, int page_mkwrite,
+			 int dirty_shared)
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
+	if (dirty_shared) {
+		struct address_space *mapping;
+		int dirtied;
+
+		if (!page_mkwrite)
+			lock_page(page);
+
+		dirtied = set_page_dirty(page);
+		VM_BUG_ON_PAGE(PageAnon(page), page);
+		mapping = page->mapping;
+		unlock_page(page);
+		page_cache_release(page);
+
+		if ((dirtied || page_mkwrite) && mapping) {
+			/*
+			 * Some device drivers do not set page.mapping
+			 * but still dirty their pages
+			 */
+			balance_dirty_pages_ratelimited(mapping);
+		}
+
+		if (!page_mkwrite)
+			file_update_time(vma->vm_file);
+	}
+
+	return VM_FAULT_WRITE;
+}
+
+/*
  * This routine handles present pages, when users try to write
  * to a shared page. It is done by copying the page to a new address
  * and decrementing the shared-page counter for the old page.
@@ -2008,8 +2067,6 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *old_page, *new_page = NULL;
 	pte_t entry;
 	int ret = 0;
-	int page_mkwrite = 0;
-	bool dirty_shared = false;
 	unsigned long mmun_start = 0;	/* For mmu_notifiers */
 	unsigned long mmun_end = 0;	/* For mmu_notifiers */
 	struct mem_cgroup *memcg;
@@ -2026,7 +2083,8 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 */
 		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 				     (VM_WRITE|VM_SHARED))
-			goto reuse;
+			return wp_page_reuse(mm, vma, address, page_table, ptl,
+					     orig_pte, old_page, 0, 0);
 		goto gotten;
 	}
 
@@ -2055,12 +2113,16 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
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
 		page_cache_get(old_page);
+
 		/*
 		 * Only catch write-faults on shared writable pages,
 		 * read-only shared pages can get COWed by
@@ -2091,51 +2153,8 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			page_mkwrite = 1;
 		}
 
-		dirty_shared = true;
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
-		if (dirty_shared) {
-			struct address_space *mapping;
-			int dirtied;
-
-			if (!page_mkwrite)
-				lock_page(old_page);
-
-			dirtied = set_page_dirty(old_page);
-			VM_BUG_ON_PAGE(PageAnon(old_page), old_page);
-			mapping = old_page->mapping;
-			unlock_page(old_page);
-			page_cache_release(old_page);
-
-			if ((dirtied || page_mkwrite) && mapping) {
-				/*
-				 * Some device drivers do not set page.mapping
-				 * but still dirty their pages
-				 */
-				balance_dirty_pages_ratelimited(mapping);
-			}
-
-			if (!page_mkwrite)
-				file_update_time(vma->vm_file);
-		}
-
-		return ret;
+		return wp_page_reuse(mm, vma, address, page_table, ptl,
+				     orig_pte, old_page, page_mkwrite, 1);
 	}
 
 	/*
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
