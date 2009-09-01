Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5BD166B004F
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 12:45:50 -0400 (EDT)
From: Vincent Li <macli@brc.ubc.ca>
Subject: [PATCH V1] mm/vsmcan: check shrink_active_list() sc->isolate_pages() return value.
Date: Tue,  1 Sep 2009 09:44:27 -0700
Message-Id: <1251823467-28083-1-git-send-email-macli@brc.ubc.ca>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vincent Li <macli@brc.ubc.ca>
List-ID: <linux-mm.kvack.org>

If we can't isolate pages from LRU list, we don't have to account page movement, either.
Already, in commit 5343daceec, KOSAKI did it about shrink_inactive_list.

This patch removes unnecessary overhead of page accounting
and locking in shrink_active_list as follow-up work of commit 5343daceec.

Signed-off-by: Vincent Li <macli@brc.ubc.ca>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
Acked-by: Rik van Riel <riel@redhat.com>

---
 mm/vmscan.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 460a6f7..2d1c846 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1319,9 +1319,12 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	if (scanning_global_lru(sc)) {
 		zone->pages_scanned += pgscanned;
 	}
-	reclaim_stat->recent_scanned[file] += nr_taken;
-
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
+
+	if (nr_taken == 0)
+		goto done;
+
+	reclaim_stat->recent_scanned[file] += nr_taken;
 	if (file)
 		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -nr_taken);
 	else
@@ -1383,6 +1386,8 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
 	__mod_zone_page_state(zone, LRU_ACTIVE + file * LRU_FILE, nr_rotated);
 	__mod_zone_page_state(zone, LRU_BASE + file * LRU_FILE, nr_deactivated);
+
+done:
 	spin_unlock_irq(&zone->lru_lock);
 }
 
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
