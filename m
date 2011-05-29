Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1E94C6B0027
	for <linux-mm@kvack.org>; Sun, 29 May 2011 14:14:26 -0400 (EDT)
Received: by pwi12 with SMTP id 12so1720064pwi.14
        for <linux-mm@kvack.org>; Sun, 29 May 2011 11:14:24 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2 06/10] vmscan: make isolate_lru_page with filter aware
Date: Mon, 30 May 2011 03:13:45 +0900
Message-Id: <48bcb7597cd5695f30381715630dc66a5d32c638.1306689214.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1306689214.git.minchan.kim@gmail.com>
References: <cover.1306689214.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1306689214.git.minchan.kim@gmail.com>
References: <cover.1306689214.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>

In __zone_reclaim case, we don't want to shrink mapped page.
Nonetheless, we have isolated mapped page and re-add it into
LRU's head. It's unnecessary CPU overhead and makes LRU churning.

Of course, when we isolate the page, the page might be mapped but
when we try to migrate the page, the page would be not mapped.
So it could be migrated. But race is rare and although it happens,
it's no big deal.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/vmscan.c |   29 +++++++++++++++++++++--------
 1 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9972356..39941c7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1395,6 +1395,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	unsigned long nr_taken;
 	unsigned long nr_anon;
 	unsigned long nr_file;
+	enum ISOLATE_PAGE_MODE mode = ISOLATE_NONE;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1406,13 +1407,20 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	set_reclaim_mode(priority, sc, false);
 	lru_add_drain();
+
+	if (!sc->may_unmap)
+		mode |= ISOLATE_UNMAPPED;
+	if (!sc->may_writepage)
+		mode |= ISOLATE_CLEAN;
+	mode |= sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
+				ISOLATE_BOTH : ISOLATE_INACTIVE;
+
 	spin_lock_irq(&zone->lru_lock);
 
+
 	if (scanning_global_lru(sc)) {
 		nr_taken = isolate_pages_global(nr_to_scan,
-			&page_list, &nr_scanned, sc->order,
-			sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
-					ISOLATE_BOTH : ISOLATE_INACTIVE,
+			&page_list, &nr_scanned, sc->order, mode,
 			zone, 0, file);
 		zone->pages_scanned += nr_scanned;
 		if (current_is_kswapd())
@@ -1423,9 +1431,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 					       nr_scanned);
 	} else {
 		nr_taken = mem_cgroup_isolate_pages(nr_to_scan,
-			&page_list, &nr_scanned, sc->order,
-			sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
-					ISOLATE_BOTH : ISOLATE_INACTIVE,
+			&page_list, &nr_scanned, sc->order, mode,
 			zone, sc->mem_cgroup,
 			0, file);
 		/*
@@ -1529,19 +1535,26 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	struct page *page;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 	unsigned long nr_rotated = 0;
+	enum ISOLATE_PAGE_MODE mode = ISOLATE_ACTIVE;
 
 	lru_add_drain();
+
+	if (!sc->may_unmap)
+		mode |= ISOLATE_UNMAPPED;
+	if (!sc->may_writepage)
+		mode |= ISOLATE_CLEAN;
+
 	spin_lock_irq(&zone->lru_lock);
 	if (scanning_global_lru(sc)) {
 		nr_taken = isolate_pages_global(nr_pages, &l_hold,
 						&pgscanned, sc->order,
-						ISOLATE_ACTIVE, zone,
+						mode, zone,
 						1, file);
 		zone->pages_scanned += pgscanned;
 	} else {
 		nr_taken = mem_cgroup_isolate_pages(nr_pages, &l_hold,
 						&pgscanned, sc->order,
-						ISOLATE_ACTIVE, zone,
+						mode, zone,
 						sc->mem_cgroup, 1, file);
 		/*
 		 * mem_cgroup_isolate_pages() keeps track of
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
