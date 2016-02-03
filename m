Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id AA7146B0005
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 07:15:39 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id ho8so12791458pac.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 04:15:39 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id q82si9104678pfq.25.2016.02.03.04.15.38
        for <linux-mm@kvack.org>;
        Wed, 03 Feb 2016 04:15:38 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] thp: cleanup split_huge_page()
Date: Wed,  3 Feb 2016 15:14:42 +0300
Message-Id: <1454501682-78445-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

After one of bugfixes to freeze_page(), we don't have freezed pages in
rmap, therefore mapcount of all subpages of freezed THP is zero. And we
have assert for that.

Let's drop code which deal with non-zero mapcount of subpages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1632e02f859c..edcc8ac07338 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3539,28 +3539,26 @@ static void unfreeze_page(struct anon_vma *anon_vma, struct page *page)
 	}
 }
 
-static int __split_huge_page_tail(struct page *head, int tail,
+static void __split_huge_page_tail(struct page *head, int tail,
 		struct lruvec *lruvec, struct list_head *list)
 {
-	int mapcount;
 	struct page *page_tail = head + tail;
 
-	mapcount = atomic_read(&page_tail->_mapcount) + 1;
+	VM_BUG_ON_PAGE(atomic_read(&page_tail->_mapcount) != -1, page_tail);
 	VM_BUG_ON_PAGE(atomic_read(&page_tail->_count) != 0, page_tail);
 
 	/*
 	 * tail_page->_count is zero and not changing from under us. But
 	 * get_page_unless_zero() may be running from under us on the
-	 * tail_page. If we used atomic_set() below instead of atomic_add(), we
+	 * tail_page. If we used atomic_set() below instead of atomic_inc(), we
 	 * would then run atomic_set() concurrently with
 	 * get_page_unless_zero(), and atomic_set() is implemented in C not
 	 * using locked ops. spin_unlock on x86 sometime uses locked ops
 	 * because of PPro errata 66, 92, so unless somebody can guarantee
 	 * atomic_set() here would be safe on all archs (and not only on x86),
-	 * it's safer to use atomic_add().
+	 * it's safer to use atomic_inc().
 	 */
-	atomic_add(mapcount + 1, &page_tail->_count);
-
+	atomic_inc(&page_tail->_count);
 
 	page_tail->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	page_tail->flags |= (head->flags &
@@ -3594,8 +3592,6 @@ static int __split_huge_page_tail(struct page *head, int tail,
 	page_tail->index = head->index + tail;
 	page_cpupid_xchg_last(page_tail, page_cpupid_last(head));
 	lru_add_page_tail(head, page_tail, lruvec, list);
-
-	return mapcount;
 }
 
 static void __split_huge_page(struct page *page, struct list_head *list)
@@ -3603,7 +3599,7 @@ static void __split_huge_page(struct page *page, struct list_head *list)
 	struct page *head = compound_head(page);
 	struct zone *zone = page_zone(head);
 	struct lruvec *lruvec;
-	int i, tail_mapcount;
+	int i;
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
 	spin_lock_irq(&zone->lru_lock);
@@ -3612,10 +3608,8 @@ static void __split_huge_page(struct page *page, struct list_head *list)
 	/* complete memcg works before add pages to LRU */
 	mem_cgroup_split_huge_fixup(head);
 
-	tail_mapcount = 0;
 	for (i = HPAGE_PMD_NR - 1; i >= 1; i--)
-		tail_mapcount += __split_huge_page_tail(head, i, lruvec, list);
-	atomic_sub(tail_mapcount, &head->_count);
+		__split_huge_page_tail(head, i, lruvec, list);
 
 	ClearPageCompound(head);
 	spin_unlock_irq(&zone->lru_lock);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
