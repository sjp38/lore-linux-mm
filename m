Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail2.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAUAvYfx031144
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 30 Nov 2008 19:57:34 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 04E0045DD7C
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 19:57:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D7E2445DD79
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 19:57:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BC27E1DB803A
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 19:57:33 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 73BA31DB803B
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 19:57:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 03/09] introduce zone_reclaim struct
In-Reply-To: <20081130193502.8145.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081130193502.8145.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081130195637.814E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun, 30 Nov 2008 19:57:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

make zone_reclam_stat strcut for latter enhancement.
latter patch use this.

this patch doesn't any functional change.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/mmzone.h |   24 ++++++++++++++----------
 mm/page_alloc.c        |    8 ++++----
 mm/swap.c              |   12 ++++++++----
 mm/vmscan.c            |   47 ++++++++++++++++++++++++++++++-----------------
 4 files changed, 56 insertions(+), 35 deletions(-)

Index: b/include/linux/mmzone.h
===================================================================
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -263,6 +263,19 @@ enum zone_type {
 #error ZONES_SHIFT -- too many zones configured adjust calculation
 #endif
 
+struct zone_reclaim_stat {
+	/*
+	 * The pageout code in vmscan.c keeps track of how many of the
+	 * mem/swap backed and file backed pages are refeferenced.
+	 * The higher the rotated/scanned ratio, the more valuable
+	 * that cache is.
+	 *
+	 * The anon LRU stats live in [0], file LRU stats in [1]
+	 */
+	unsigned long		recent_rotated[2];
+	unsigned long		recent_scanned[2];
+};
+
 struct zone {
 	/* Fields commonly accessed by the page allocator */
 	unsigned long		pages_min, pages_low, pages_high;
@@ -315,16 +328,7 @@ struct zone {
 		unsigned long nr_scan;
 	} lru[NR_LRU_LISTS];
 
-	/*
-	 * The pageout code in vmscan.c keeps track of how many of the
-	 * mem/swap backed and file backed pages are refeferenced.
-	 * The higher the rotated/scanned ratio, the more valuable
-	 * that cache is.
-	 *
-	 * The anon LRU stats live in [0], file LRU stats in [1]
-	 */
-	unsigned long		recent_rotated[2];
-	unsigned long		recent_scanned[2];
+	struct zone_reclaim_stat reclaim_stat;
 
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	unsigned long		slab_defrag_counter; /* since last defrag */
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3522,10 +3522,10 @@ static void __paginginit free_area_init_
 			INIT_LIST_HEAD(&zone->lru[l].list);
 			zone->lru[l].nr_scan = 0;
 		}
-		zone->recent_rotated[0] = 0;
-		zone->recent_rotated[1] = 0;
-		zone->recent_scanned[0] = 0;
-		zone->recent_scanned[1] = 0;
+		zone->reclaim_stat.recent_rotated[0] = 0;
+		zone->reclaim_stat.recent_rotated[1] = 0;
+		zone->reclaim_stat.recent_scanned[0] = 0;
+		zone->reclaim_stat.recent_scanned[1] = 0;
 		zap_zone_vm_stats(zone);
 		zone->flags = 0;
 		if (!size)
Index: b/mm/swap.c
===================================================================
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -157,6 +157,7 @@ void  rotate_reclaimable_page(struct pag
 void activate_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
+	struct zone_reclaim_stat *reclaim_stat = &zone->reclaim_stat;
 
 	spin_lock_irq(&zone->lru_lock);
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
@@ -169,8 +170,8 @@ void activate_page(struct page *page)
 		add_page_to_lru_list(zone, page, lru);
 		__count_vm_event(PGACTIVATE);
 
-		zone->recent_rotated[!!file]++;
-		zone->recent_scanned[!!file]++;
+		reclaim_stat->recent_rotated[!!file]++;
+		reclaim_stat->recent_scanned[!!file]++;
 	}
 	spin_unlock_irq(&zone->lru_lock);
 }
@@ -398,6 +399,8 @@ void ____pagevec_lru_add(struct pagevec 
 {
 	int i;
 	struct zone *zone = NULL;
+	struct zone_reclaim_stat *reclaim_stat = NULL;
+
 	VM_BUG_ON(is_unevictable_lru(lru));
 
 	for (i = 0; i < pagevec_count(pvec); i++) {
@@ -409,6 +412,7 @@ void ____pagevec_lru_add(struct pagevec 
 			if (zone)
 				spin_unlock_irq(&zone->lru_lock);
 			zone = pagezone;
+			reclaim_stat = &zone->reclaim_stat;
 			spin_lock_irq(&zone->lru_lock);
 		}
 		VM_BUG_ON(PageActive(page));
@@ -416,10 +420,10 @@ void ____pagevec_lru_add(struct pagevec 
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 		file = is_file_lru(lru);
-		zone->recent_scanned[file]++;
+		reclaim_stat->recent_scanned[file]++;
 		if (is_active_lru(lru)) {
 			SetPageActive(page);
-			zone->recent_rotated[file]++;
+			reclaim_stat->recent_rotated[file]++;
 		}
 		add_page_to_lru_list(zone, page, lru);
 	}
Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -131,6 +131,12 @@ static DECLARE_RWSEM(shrinker_rwsem);
 #define scan_global_lru(sc)	(1)
 #endif
 
+static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
+						  struct scan_control *sc)
+{
+	return &zone->reclaim_stat;
+}
+
 /*
  * Add a shrinker callback to be called from the vm
  */
@@ -1083,6 +1089,7 @@ static unsigned long shrink_inactive_lis
 	struct pagevec pvec;
 	unsigned long nr_scanned = 0;
 	unsigned long nr_reclaimed = 0;
+	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 
 	pagevec_init(&pvec, 1);
 
@@ -1126,10 +1133,14 @@ static unsigned long shrink_inactive_lis
 
 		if (scan_global_lru(sc)) {
 			zone->pages_scanned += nr_scan;
-			zone->recent_scanned[0] += count[LRU_INACTIVE_ANON];
-			zone->recent_scanned[0] += count[LRU_ACTIVE_ANON];
-			zone->recent_scanned[1] += count[LRU_INACTIVE_FILE];
-			zone->recent_scanned[1] += count[LRU_ACTIVE_FILE];
+			reclaim_stat->recent_scanned[0] +=
+						      count[LRU_INACTIVE_ANON];
+			reclaim_stat->recent_scanned[0] +=
+						      count[LRU_ACTIVE_ANON];
+			reclaim_stat->recent_scanned[1] +=
+						      count[LRU_INACTIVE_FILE];
+			reclaim_stat->recent_scanned[1] +=
+						      count[LRU_ACTIVE_FILE];
 		}
 		spin_unlock_irq(&zone->lru_lock);
 
@@ -1190,7 +1201,7 @@ static unsigned long shrink_inactive_lis
 			add_page_to_lru_list(zone, page, lru);
 			if (PageActive(page) && scan_global_lru(sc)) {
 				int file = !!page_is_file_cache(page);
-				zone->recent_rotated[file]++;
+				reclaim_stat->recent_rotated[file]++;
 			}
 			if (!pagevec_add(&pvec, page)) {
 				spin_unlock_irq(&zone->lru_lock);
@@ -1255,6 +1266,7 @@ static void shrink_active_list(unsigned 
 	struct page *page;
 	struct pagevec pvec;
 	enum lru_list lru;
+	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
@@ -1267,7 +1279,7 @@ static void shrink_active_list(unsigned 
 	 */
 	if (scan_global_lru(sc)) {
 		zone->pages_scanned += pgscanned;
-		zone->recent_scanned[!!file] += pgmoved;
+		reclaim_stat->recent_scanned[!!file] += pgmoved;
 	}
 
 	if (file)
@@ -1302,7 +1314,7 @@ static void shrink_active_list(unsigned 
 	 * pages in get_scan_ratio.
 	 */
 	if (scan_global_lru(sc))
-		zone->recent_rotated[!!file] += pgmoved;
+		reclaim_stat->recent_rotated[!!file] += pgmoved;
 
 	/*
 	 * Move the pages to the [file or anon] inactive list.
@@ -1415,6 +1427,7 @@ static void get_scan_ratio(struct zone *
 	unsigned long anon, file, free;
 	unsigned long anon_prio, file_prio;
 	unsigned long ap, fp;
+	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 
 	/* If we have no swap space, do not bother scanning anon pages. */
 	if (nr_swap_pages <= 0) {
@@ -1447,17 +1460,17 @@ static void get_scan_ratio(struct zone *
 	 *
 	 * anon in [0], file in [1]
 	 */
-	if (unlikely(zone->recent_scanned[0] > anon / 4)) {
+	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
 		spin_lock_irq(&zone->lru_lock);
-		zone->recent_scanned[0] /= 2;
-		zone->recent_rotated[0] /= 2;
+		reclaim_stat->recent_scanned[0] /= 2;
+		reclaim_stat->recent_rotated[0] /= 2;
 		spin_unlock_irq(&zone->lru_lock);
 	}
 
-	if (unlikely(zone->recent_scanned[1] > file / 4)) {
+	if (unlikely(reclaim_stat->recent_scanned[1] > file / 4)) {
 		spin_lock_irq(&zone->lru_lock);
-		zone->recent_scanned[1] /= 2;
-		zone->recent_rotated[1] /= 2;
+		reclaim_stat->recent_scanned[1] /= 2;
+		reclaim_stat->recent_rotated[1] /= 2;
 		spin_unlock_irq(&zone->lru_lock);
 	}
 
@@ -1473,11 +1486,11 @@ static void get_scan_ratio(struct zone *
 	 * proportional to the fraction of recently scanned pages on
 	 * each list that were recently referenced and in active use.
 	 */
-	ap = (anon_prio + 1) * (zone->recent_scanned[0] + 1);
-	ap /= zone->recent_rotated[0] + 1;
+	ap = (anon_prio + 1) * (reclaim_stat->recent_scanned[0] + 1);
+	ap /= reclaim_stat->recent_rotated[0] + 1;
 
-	fp = (file_prio + 1) * (zone->recent_scanned[1] + 1);
-	fp /= zone->recent_rotated[1] + 1;
+	fp = (file_prio + 1) * (reclaim_stat->recent_scanned[1] + 1);
+	fp /= reclaim_stat->recent_rotated[1] + 1;
 
 	/* Normalize to percentages */
 	percent[0] = 100 * ap / (ap + fp + 1);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
