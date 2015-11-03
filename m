Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4099E6B0038
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 10:26:34 -0500 (EST)
Received: by pasz6 with SMTP id z6so21330819pas.2
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 07:26:34 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id kd3si42961378pbc.173.2015.11.03.07.26.33
        for <linux-mm@kvack.org>;
        Tue, 03 Nov 2015 07:26:33 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/4] thp: fix split vs. unmap race
Date: Tue,  3 Nov 2015 17:26:14 +0200
Message-Id: <1446564375-72143-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1446564375-72143-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1446564375-72143-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

To stabilize compound page during split we use migration entries.
The code to implement this is buggy: I wrongly assumed that kernel would
wait migration to finish, before zapping ptes.

But turn out that's not true.

As result if zap_pte_range() races with split_huge_page(), we can end up
with page which is not mapped anymore but has _count and _mapcount
elevated. The page is on LRU too. So it's still reachable by vmscan and by
pfn scanners.  It's likely that page->mapping in this case would point to
freed anon_vma.

BOOM!

The patch modify freeze/unfreeze_page() code to match normal migration
entries logic: on setup we remove page from rmap and drop pin, on removing
we get pin back and put page on rmap. This way even if migration entry
will be removed under us we don't corrupt page's state.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Minchan Kim <minchan@kernel.org>
Reported-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/huge_memory.c | 22 ++++++++++++++++++----
 mm/rmap.c        | 19 +++++--------------
 2 files changed, 23 insertions(+), 18 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5009f68786d0..3700981f8035 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2934,6 +2934,13 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 
 	smp_wmb(); /* make pte visible before pmd */
 	pmd_populate(mm, pmd, pgtable);
+
+	if (freeze) {
+		for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
+			page_remove_rmap(page + i, false);
+			put_page(page + i);
+		}
+	}
 }
 
 void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
@@ -3079,6 +3086,8 @@ static void freeze_page_vma(struct vm_area_struct *vma, struct page *page,
 		if (pte_soft_dirty(entry))
 			swp_pte = pte_swp_mksoft_dirty(swp_pte);
 		set_pte_at(vma->vm_mm, address, pte + i, swp_pte);
+		page_remove_rmap(page, false);
+		put_page(page);
 	}
 	pte_unmap_unlock(pte, ptl);
 }
@@ -3117,8 +3126,6 @@ static void unfreeze_page_vma(struct vm_area_struct *vma, struct page *page,
 		return;
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, address, &ptl);
 	for (i = 0; i < HPAGE_PMD_NR; i++, address += PAGE_SIZE, page++) {
-		if (!page_mapped(page))
-			continue;
 		if (!is_swap_pte(pte[i]))
 			continue;
 
@@ -3128,6 +3135,9 @@ static void unfreeze_page_vma(struct vm_area_struct *vma, struct page *page,
 		if (migration_entry_to_page(swp_entry) != page)
 			continue;
 
+		get_page(page);
+		page_add_anon_rmap(page, vma, address, false);
+
 		entry = pte_mkold(mk_pte(page, vma->vm_page_prot));
 		entry = pte_mkdirty(entry);
 		if (is_write_migration_entry(swp_entry))
@@ -3195,8 +3205,6 @@ static int __split_huge_page_tail(struct page *head, int tail,
 	 */
 	atomic_add(mapcount + 1, &page_tail->_count);
 
-	/* after clearing PageTail the gup refcount can be released */
-	smp_mb__after_atomic();
 
 	page_tail->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	page_tail->flags |= (head->flags &
@@ -3209,6 +3217,12 @@ static int __split_huge_page_tail(struct page *head, int tail,
 			 (1L << PG_unevictable)));
 	page_tail->flags |= (1L << PG_dirty);
 
+	/*
+	 * After clearing PageTail the gup refcount can be released.
+	 * Page flags also must be visible before we make the page non-compound.
+	 */
+	smp_wmb();
+
 	clear_compound_head(page_tail);
 
 	if (page_is_young(head))
diff --git a/mm/rmap.c b/mm/rmap.c
index 288622f5f34d..ad9af8b3a381 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1135,20 +1135,12 @@ void do_page_add_anon_rmap(struct page *page,
 	bool compound = flags & RMAP_COMPOUND;
 	bool first;
 
-	if (PageTransCompound(page)) {
+	if (compound) {
+		atomic_t *mapcount;
 		VM_BUG_ON_PAGE(!PageLocked(page), page);
-		if (compound) {
-			atomic_t *mapcount;
-
-			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-			mapcount = compound_mapcount_ptr(page);
-			first = atomic_inc_and_test(mapcount);
-		} else {
-			/* Anon THP always mapped first with PMD */
-			first = 0;
-			VM_BUG_ON_PAGE(!page_mapcount(page), page);
-			atomic_inc(&page->_mapcount);
-		}
+		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+		mapcount = compound_mapcount_ptr(page);
+		first = atomic_inc_and_test(mapcount);
 	} else {
 		VM_BUG_ON_PAGE(compound, page);
 		first = atomic_inc_and_test(&page->_mapcount);
@@ -1163,7 +1155,6 @@ void do_page_add_anon_rmap(struct page *page,
 		 * disabled.
 		 */
 		if (compound) {
-			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 			__inc_zone_page_state(page,
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
 		}
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
