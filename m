Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A9B689000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:25:54 -0400 (EDT)
Received: by mail-iw0-f169.google.com with SMTP id 8so955640iwg.14
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:25:53 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [RFC 3/8] vmscan: make isolate_lru_page with filter aware
Date: Wed, 27 Apr 2011 01:25:20 +0900
Message-Id: <232562452317897b5acb1445803410d74233a923.1303833417.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1303833415.git.minchan.kim@gmail.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1303833415.git.minchan.kim@gmail.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

In some __zone_reclaim case, we don't want to shrink mapped page.
Nonetheless, we have isolated mapped page and re-add it into
LRU's head. It's unnecessary CPU overhead and makes LRU churning.

Of course, when we isolate the page, the page might be mapped but
when we try to migrate the page, the page would be not mapped.
So it could be migrated. But race is rare and although it happens,
it's no big deal.

Cc: Christoph Lameter <cl@linux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/vmscan.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 71d2da9..e8d6190 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1147,7 +1147,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 static unsigned long isolate_pages_global(unsigned long nr,
 					struct list_head *dst,
-					unsigned long *scanned, int order,
+					unsigned long *scanned,
+					struct scan_control *sc,
 					int mode, struct zone *z,
 					int active, int file)
 {
@@ -1156,8 +1157,8 @@ static unsigned long isolate_pages_global(unsigned long nr,
 		lru += LRU_ACTIVE;
 	if (file)
 		lru += LRU_FILE;
-	return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanned, order,
-					mode, file, 0, 0);
+	return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanned, sc->order,
+					mode, file, 0, !sc->may_unmap);
 }
 
 /*
@@ -1407,7 +1408,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	if (scanning_global_lru(sc)) {
 		nr_taken = isolate_pages_global(nr_to_scan,
-			&page_list, &nr_scanned, sc->order,
+			&page_list, &nr_scanned, sc,
 			sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
 					ISOLATE_BOTH : ISOLATE_INACTIVE,
 			zone, 0, file);
@@ -1531,7 +1532,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	spin_lock_irq(&zone->lru_lock);
 	if (scanning_global_lru(sc)) {
 		nr_taken = isolate_pages_global(nr_pages, &l_hold,
-						&pgscanned, sc->order,
+						&pgscanned, sc,
 						ISOLATE_ACTIVE, zone,
 						1, file);
 		zone->pages_scanned += pgscanned;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
