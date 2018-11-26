Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3FE6B4450
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 18:16:32 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id l9so21851267plt.7
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 15:16:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b13sor2463908pls.16.2018.11.26.15.16.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 15:16:31 -0800 (PST)
Date: Mon, 26 Nov 2018 15:16:28 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 01/10] mm/huge_memory: rename freeze_page() to unmap_page()
Message-ID: <alpine.LSU.2.11.1811261514080.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <willy@infradead.org>, Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org

The term "freeze" is used in several ways in the kernel, and in mm it
has the particular meaning of forcing page refcount temporarily to 0.
freeze_page() is just too confusing a name for a function that unmaps
a page: rename it unmap_page(), and rename unfreeze_page() remap_page().

Went to change the mention of freeze_page() added later in mm/rmap.c,
but found it to be incorrect: ordinary page reclaim reaches there too;
but the substance of the comment still seems correct, so edit it down.

Fixes: e9b61f19858a5 ("thp: reintroduce split_huge_page()")
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Jerome Glisse <jglisse@redhat.com>
Cc: stable@vger.kernel.org # 4.8+
---
 mm/huge_memory.c | 12 ++++++------
 mm/rmap.c        | 13 +++----------
 2 files changed, 9 insertions(+), 16 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 55478ab3c83b..30100fac2341 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2350,7 +2350,7 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
 	}
 }
 
-static void freeze_page(struct page *page)
+static void unmap_page(struct page *page)
 {
 	enum ttu_flags ttu_flags = TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS |
 		TTU_RMAP_LOCKED | TTU_SPLIT_HUGE_PMD;
@@ -2365,7 +2365,7 @@ static void freeze_page(struct page *page)
 	VM_BUG_ON_PAGE(!unmap_success, page);
 }
 
-static void unfreeze_page(struct page *page)
+static void remap_page(struct page *page)
 {
 	int i;
 	if (PageTransHuge(page)) {
@@ -2483,7 +2483,7 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 
 	spin_unlock_irqrestore(zone_lru_lock(page_zone(head)), flags);
 
-	unfreeze_page(head);
+	remap_page(head);
 
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		struct page *subpage = head + i;
@@ -2664,7 +2664,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	}
 
 	/*
-	 * Racy check if we can split the page, before freeze_page() will
+	 * Racy check if we can split the page, before unmap_page() will
 	 * split PMDs
 	 */
 	if (!can_split_huge_page(head, &extra_pins)) {
@@ -2673,7 +2673,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	}
 
 	mlocked = PageMlocked(page);
-	freeze_page(head);
+	unmap_page(head);
 	VM_BUG_ON_PAGE(compound_mapcount(head), head);
 
 	/* Make sure the page is not on per-CPU pagevec as it takes pin */
@@ -2727,7 +2727,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 fail:		if (mapping)
 			xa_unlock(&mapping->i_pages);
 		spin_unlock_irqrestore(zone_lru_lock(page_zone(head)), flags);
-		unfreeze_page(head);
+		remap_page(head);
 		ret = -EBUSY;
 	}
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 1e79fac3186b..85b7f9423352 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1627,16 +1627,9 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 						      address + PAGE_SIZE);
 		} else {
 			/*
-			 * We should not need to notify here as we reach this
-			 * case only from freeze_page() itself only call from
-			 * split_huge_page_to_list() so everything below must
-			 * be true:
-			 *   - page is not anonymous
-			 *   - page is locked
-			 *
-			 * So as it is a locked file back page thus it can not
-			 * be remove from the page cache and replace by a new
-			 * page before mmu_notifier_invalidate_range_end so no
+			 * This is a locked file-backed page, thus it cannot
+			 * be removed from the page cache and replaced by a new
+			 * page before mmu_notifier_invalidate_range_end, so no
 			 * concurrent thread might update its page table to
 			 * point at new page while a device still is using this
 			 * page.
-- 
2.20.0.rc0.387.gc7a69e6b6c-goog
