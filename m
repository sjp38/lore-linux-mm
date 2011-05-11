Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8AED690010F
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:17:27 -0400 (EDT)
Received: by mail-px0-f169.google.com with SMTP id 9so599232pxi.14
        for <linux-mm@kvack.org>; Wed, 11 May 2011 10:17:26 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v1 06/10] vmscan: make isolate_lru_page with filter aware
Date: Thu, 12 May 2011 02:16:45 +0900
Message-Id: <40d48d7e8bf3e003efdc3974c4cfcf90c60f6508.1305132792.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1305132792.git.minchan.kim@gmail.com>
References: <cover.1305132792.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1305132792.git.minchan.kim@gmail.com>
References: <cover.1305132792.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

In some __zone_reclaim case, we don't want to shrink mapped page.
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
index 4bd5513..88c6baf 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1402,6 +1402,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	unsigned long nr_taken;
 	unsigned long nr_anon;
 	unsigned long nr_file;
+	enum ISOLATE_PAGE_MODE mode = ISOLATE_NONE;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1413,13 +1414,20 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
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
@@ -1430,9 +1438,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
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
@@ -1536,19 +1542,26 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
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
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
