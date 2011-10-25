Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0924F6B002D
	for <linux-mm@kvack.org>; Mon, 24 Oct 2011 22:52:03 -0400 (EDT)
Subject: [patch 4/5]thp: correct order in lru list for split huge page
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 25 Oct 2011 10:59:37 +0800
Message-ID: <1319511577.22361.140.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: aarcange@redhat.com, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

If a huge page is split, all the subpages should live in lru list adjacently
because they should be taken as a whole.
In page split, with current code:
a. if huge page is in lru list, the order is: page, page+HPAGE_PMD_NR-1,
page + HPAGE_PMD_NR-2, ..., page + 1(in lru page reclaim order)
b. otherwise, the order is: page, ..other pages.., page + 1, page + 2, ...(in
lru page reclaim order). page + 1 ... page + HPAGE_PMD_NR - 1 are in the lru
reclaim tail.

In case a, the order is wrong. In case b, page is isolated (to be reclaimed),
but other tail pages will not soon.

With below patch:
in case a, the order is: page, page + 1, ... page + HPAGE_PMD_NR-1(in lru page
reclaim order).
in case b, the order is: page + 1, ... page + HPAGE_PMD_NR-1 (in lru page reclaim
order). The tail pages are in the lru reclaim head.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 mm/huge_memory.c |    5 ++---
 mm/swap.c        |    5 +++--
 2 files changed, 5 insertions(+), 5 deletions(-)

Index: linux/mm/huge_memory.c
===================================================================
--- linux.orig/mm/huge_memory.c	2011-10-25 09:06:55.000000000 +0800
+++ linux/mm/huge_memory.c	2011-10-25 09:31:07.000000000 +0800
@@ -1162,7 +1162,6 @@ static int __split_huge_page_splitting(s
 static void __split_huge_page_refcount(struct page *page)
 {
 	int i;
-	unsigned long head_index = page->index;
 	struct zone *zone = page_zone(page);
 	int zonestat;
 
@@ -1170,7 +1169,7 @@ static void __split_huge_page_refcount(s
 	spin_lock_irq(&zone->lru_lock);
 	compound_lock(page);
 
-	for (i = 1; i < HPAGE_PMD_NR; i++) {
+	for (i = HPAGE_PMD_NR - 1; i >= 1; i--) {
 		struct page *page_tail = page + i;
 
 		/* tail_page->_count cannot change */
@@ -1221,7 +1220,7 @@ static void __split_huge_page_refcount(s
 		BUG_ON(page_tail->mapping);
 		page_tail->mapping = page->mapping;
 
-		page_tail->index = ++head_index;
+		page_tail->index = page->index + i;
 
 		BUG_ON(!PageAnon(page_tail));
 		BUG_ON(!PageUptodate(page_tail));
Index: linux/mm/swap.c
===================================================================
--- linux.orig/mm/swap.c	2011-10-25 08:36:09.000000000 +0800
+++ linux/mm/swap.c	2011-10-25 09:31:07.000000000 +0800
@@ -661,11 +661,12 @@ void lru_add_page_tail(struct zone* zone
 		if (likely(PageLRU(page)))
 			head = page->lru.prev;
 		else
-			head = &zone->lru[lru].list;
+			head = zone->lru[lru].list.prev;
 		__add_page_to_lru_list(zone, page_tail, lru, head);
 	} else {
 		SetPageUnevictable(page_tail);
-		add_page_to_lru_list(zone, page_tail, LRU_UNEVICTABLE);
+		head = zone->lru[LRU_UNEVICTABLE].list.prev;
+		__add_page_to_lru_list(zone, page_tail, LRU_UNEVICTABLE, head);
 	}
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
