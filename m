Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3BF3A6B008A
	for <linux-mm@kvack.org>; Sun, 22 Feb 2009 18:16:34 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 15/20] Do not disable interrupts in free_page_mlock()
Date: Sun, 22 Feb 2009 23:17:24 +0000
Message-Id: <1235344649-18265-16-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

free_page_mlock() tests and clears PG_mlocked. If set, it disables interrupts
to update counters and this happens on every page free even though interrupts
are disabled very shortly afterwards a second time.  This is wasteful.

This patch splits what free_page_mlock() does. The bit check is still
made. However, the update of counters is delayed until the interrupts are
disabled. One potential weirdness with this split is that the counters do
not get updated if the bad_page() check is triggered but a system showing
bad pages is getting screwed already.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/internal.h   |   10 ++--------
 mm/page_alloc.c |    8 +++++++-
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 478223b..b52bf86 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -155,14 +155,8 @@ static inline void mlock_migrate_page(struct page *newpage, struct page *page)
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
+	__dec_zone_page_state(page, NR_MLOCK);
+	__count_vm_event(UNEVICTABLE_MLOCKFREED);
 }
 
 #else /* CONFIG_UNEVICTABLE_LRU */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a9e9466..9adafba 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -501,7 +501,6 @@ static inline void __free_one_page(struct page *page,
 
 static inline int free_pages_check(struct page *page)
 {
-	free_page_mlock(page);
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
 		(page_count(page) != 0)  |
@@ -559,6 +558,7 @@ static void __free_pages_ok(struct page *page, unsigned int order,
 	unsigned long flags;
 	int i;
 	int bad = 0;
+	int clearMlocked = TestClearPageMlocked(page);
 
 	for (i = 0 ; i < (1 << order) ; ++i)
 		bad += free_pages_check(page + i);
@@ -574,6 +574,8 @@ static void __free_pages_ok(struct page *page, unsigned int order,
 	kernel_map_pages(page, 1 << order, 0);
 
 	local_irq_save(flags);
+	if (clearMlocked)
+		free_page_mlock(page);
 	__count_vm_events(PGFREE, 1 << order);
 	free_one_page(page_zone(page), page, order, migratetype);
 	local_irq_restore(flags);
@@ -1023,6 +1025,7 @@ static void free_hot_cold_page(struct page *page, int cold)
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
+	int clearMlocked = TestClearPageMlocked(page);
 
 	if (PageAnon(page))
 		page->mapping = NULL;
@@ -1039,6 +1042,9 @@ static void free_hot_cold_page(struct page *page, int cold)
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
