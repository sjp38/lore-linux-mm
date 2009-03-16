Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BAD506B008C
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 05:44:30 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 18/35] Do not disable interrupts in free_page_mlock()
Date: Mon, 16 Mar 2009 09:46:13 +0000
Message-Id: <1237196790-7268-19-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

free_page_mlock() tests and clears PG_mlocked using locked versions of the
bit operations. If set, it disables interrupts to update counters and this
happens on every page free even though interrupts are disabled very shortly
afterwards a second time.  This is wasteful.

This patch splits what free_page_mlock() does. The bit check is still
made. However, the update of counters is delayed until the interrupts are
disabled and the non-lock version for clearing the bit is used. One potential
weirdness with this split is that the counters do not get updated if the
bad_page() check is triggered but a system showing bad pages is getting
screwed already.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/internal.h   |   11 +++--------
 mm/page_alloc.c |    8 +++++++-
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 478223b..7f775a1 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -155,14 +155,9 @@ static inline void mlock_migrate_page(struct page *newpage, struct page *page)
  */
 static inline void free_page_mlock(struct page *page)
 {
-	if (unlikely(TestClearPageMlocked(page))) {
-		unsigned long flags;
-
-		local_irq_save(flags);
-		__dec_zone_page_state(page, NR_MLOCK);
-		__count_vm_event(UNEVICTABLE_MLOCKFREED);
-		local_irq_restore(flags);
-	}
+	__ClearPageMlocked(page);
+	__dec_zone_page_state(page, NR_MLOCK);
+	__count_vm_event(UNEVICTABLE_MLOCKFREED);
 }
 
 #else /* CONFIG_UNEVICTABLE_LRU */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 349c64d..a068589 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -498,7 +498,6 @@ static inline void __free_one_page(struct page *page,
 
 static inline int free_pages_check(struct page *page)
 {
-	free_page_mlock(page);
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
 		(page_count(page) != 0)  |
@@ -555,6 +554,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	unsigned long flags;
 	int i;
 	int bad = 0;
+	int clearMlocked = PageMlocked(page);
 
 	for (i = 0 ; i < (1 << order) ; ++i)
 		bad += free_pages_check(page + i);
@@ -570,6 +570,8 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	kernel_map_pages(page, 1 << order, 0);
 
 	local_irq_save(flags);
+	if (clearMlocked)
+		free_page_mlock(page);
 	__count_vm_events(PGFREE, 1 << order);
 	free_one_page(page_zone(page), page, order,
 					get_pageblock_migratetype(page));
@@ -1020,6 +1022,7 @@ static void free_hot_cold_page(struct page *page, int cold)
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
+	int clearMlocked = PageMlocked(page);
 
 	if (PageAnon(page))
 		page->mapping = NULL;
@@ -1036,6 +1039,9 @@ static void free_hot_cold_page(struct page *page, int cold)
 	pcp = &zone_pcp(zone, get_cpu())->pcp;
 	local_irq_save(flags);
 	__count_vm_event(PGFREE);
+	if (clearMlocked)
+		free_page_mlock(page);
+
 	if (cold)
 		list_add_tail(&page->lru, &pcp->list);
 	else
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
