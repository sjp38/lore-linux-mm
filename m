Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 9435C6B006E
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 01:54:43 -0500 (EST)
Subject: [patch v2 4/4]thp: improve order in lru list for split huge page
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 15 Nov 2011 15:04:21 +0800
Message-ID: <1321340661.22361.297.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>

Put the tail subpages of an isolated hugepage under splitting in the
lru reclaim head as they supposedly should be isolated too next.

Queues the subpages in physical order in the lru for non isolated
hugepages under splitting. That might provide some theoretical cache
benefit to the buddy allocator later.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c |    5 ++---
 mm/swap.c        |    2 +-
 2 files changed, 3 insertions(+), 4 deletions(-)

Index: linux/mm/huge_memory.c
===================================================================
--- linux.orig/mm/huge_memory.c	2011-11-15 09:04:26.000000000 +0800
+++ linux/mm/huge_memory.c	2011-11-15 09:13:52.000000000 +0800
@@ -1228,7 +1228,6 @@ static int __split_huge_page_splitting(s
 static void __split_huge_page_refcount(struct page *page)
 {
 	int i;
-	unsigned long head_index = page->index;
 	struct zone *zone = page_zone(page);
 	int zonestat;
 	int tail_count = 0;
@@ -1237,7 +1236,7 @@ static void __split_huge_page_refcount(s
 	spin_lock_irq(&zone->lru_lock);
 	compound_lock(page);
 
-	for (i = 1; i < HPAGE_PMD_NR; i++) {
+	for (i = HPAGE_PMD_NR - 1; i >= 1; i--) {
 		struct page *page_tail = page + i;
 
 		/* tail_page->_mapcount cannot change */
@@ -1300,7 +1299,7 @@ static void __split_huge_page_refcount(s
 		BUG_ON(page_tail->mapping);
 		page_tail->mapping = page->mapping;
 
-		page_tail->index = ++head_index;
+		page_tail->index = page->index + i;
 
 		BUG_ON(!PageAnon(page_tail));
 		BUG_ON(!PageUptodate(page_tail));
Index: linux/mm/swap.c
===================================================================
--- linux.orig/mm/swap.c	2011-11-14 16:12:03.000000000 +0800
+++ linux/mm/swap.c	2011-11-15 09:15:33.000000000 +0800
@@ -684,7 +684,7 @@ void lru_add_page_tail(struct zone* zone
 		if (likely(PageLRU(page)))
 			head = page->lru.prev;
 		else
-			head = &zone->lru[lru].list;
+			head = zone->lru[lru].list.prev;
 		__add_page_to_lru_list(zone, page_tail, lru, head);
 	} else {
 		SetPageUnevictable(page_tail);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
