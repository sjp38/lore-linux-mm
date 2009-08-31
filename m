Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0FB386B004D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 18:55:07 -0400 (EDT)
From: Vincent Li <macli@brc.ubc.ca>
Subject: [PATCH] mm/vsmcan: check shrink_active_list() sc->isolate_pages() return value.
Date: Mon, 31 Aug 2009 15:54:01 -0700
Message-Id: <1251759241-15167-1-git-send-email-macli@brc.ubc.ca>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vincent Li <macli@brc.ubc.ca>
List-ID: <linux-mm.kvack.org>

commit 5343daceec (If sc->isolate_pages() return 0...) make shrink_inactive_list handle
sc->isolate_pages() return value properly. Add similar proper return value check for
shrink_active_list() sc->isolate_pages().

Signed-off-by: Vincent Li <macli@brc.ubc.ca>
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
