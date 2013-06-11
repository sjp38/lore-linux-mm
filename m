Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id C6C6E6B003A
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 11:32:45 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/8] thp, mm: avoid PageUnevictable on active/inactive lru lists
Date: Tue, 11 Jun 2013 18:35:13 +0300
Message-Id: <1370964919-16187-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1370964919-16187-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1370964919-16187-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

active/inactive lru lists can contain unevicable pages (i.e. ramfs pages
that have been placed on the LRU lists when first allocated), but these
pages must not have PageUnevictable set - otherwise shrink_[in]active_list
goes crazy:

kernel BUG at /home/space/kas/git/public/linux-next/mm/vmscan.c:1122!

1090 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
1091                 struct lruvec *lruvec, struct list_head *dst,
1092                 unsigned long *nr_scanned, struct scan_control *sc,
1093                 isolate_mode_t mode, enum lru_list lru)
1094 {
...
1108                 switch (__isolate_lru_page(page, mode)) {
1109                 case 0:
...
1116                 case -EBUSY:
...
1121                 default:
1122                         BUG();
1123                 }
1124         }
...
1130 }

__isolate_lru_page() returns EINVAL for PageUnevictable(page).

For lru_add_page_tail(), it means we should not set PageUnevictable()
for tail pages unless we're sure that it will go to LRU_UNEVICTABLE.
Let's just copy PG_active and PG_unevictable from head page in
__split_huge_page_refcount(), it will simplify lru_add_page_tail().

This will fix one more bug in lru_add_page_tail():
if page_evictable(page_tail) is false and PageLRU(page) is true, page_tail
will go to the same lru as page, but nobody cares to sync page_tail
active/inactive state with page. So we can end up with inactive page on
active lru.
The patch will fix it as well since we copy PG_active from head page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
---
 mm/huge_memory.c |    4 +++-
 mm/swap.c        |   20 ++------------------
 2 files changed, 5 insertions(+), 19 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index ed26ccb..d94f7de 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1625,7 +1625,9 @@ static void __split_huge_page_refcount(struct page *page,
 				     ((1L << PG_referenced) |
 				      (1L << PG_swapbacked) |
 				      (1L << PG_mlocked) |
-				      (1L << PG_uptodate)));
+				      (1L << PG_uptodate) |
+				      (1L << PG_active) |
+				      (1L << PG_unevictable)));
 		page_tail->flags |= (1L << PG_dirty);
 
 		/* clear PageTail before overwriting first_page */
diff --git a/mm/swap.c b/mm/swap.c
index 2056d54..a19d4e5 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -770,8 +770,6 @@ EXPORT_SYMBOL(__pagevec_release);
 void lru_add_page_tail(struct page *page, struct page *page_tail,
 		       struct lruvec *lruvec, struct list_head *list)
 {
-	int uninitialized_var(active);
-	enum lru_list lru;
 	const int file = 0;
 
 	VM_BUG_ON(!PageHead(page));
@@ -783,20 +781,6 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 	if (!list)
 		SetPageLRU(page_tail);
 
-	if (page_evictable(page_tail)) {
-		if (PageActive(page)) {
-			SetPageActive(page_tail);
-			active = 1;
-			lru = LRU_ACTIVE_ANON;
-		} else {
-			active = 0;
-			lru = LRU_INACTIVE_ANON;
-		}
-	} else {
-		SetPageUnevictable(page_tail);
-		lru = LRU_UNEVICTABLE;
-	}
-
 	if (likely(PageLRU(page)))
 		list_add_tail(&page_tail->lru, &page->lru);
 	else if (list) {
@@ -812,13 +796,13 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 		 * Use the standard add function to put page_tail on the list,
 		 * but then correct its position so they all end up in order.
 		 */
-		add_page_to_lru_list(page_tail, lruvec, lru);
+		add_page_to_lru_list(page_tail, lruvec, page_lru(page_tail));
 		list_head = page_tail->lru.prev;
 		list_move_tail(&page_tail->lru, list_head);
 	}
 
 	if (!PageUnevictable(page))
-		update_page_reclaim_stat(lruvec, file, active);
+		update_page_reclaim_stat(lruvec, file, PageActive(page_tail));
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
