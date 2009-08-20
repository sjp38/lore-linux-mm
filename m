Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 018006B004D
	for <linux-mm@kvack.org>; Thu, 20 Aug 2009 14:42:52 -0400 (EDT)
From: Vincent Li <macli@brc.ubc.ca>
Subject: [PATCH] mm/vmscan: rename zone_nr_pages() to zone_lru_nr_pages()
Date: Thu, 20 Aug 2009 11:42:54 -0700
Message-Id: <1250793774-7969-1-git-send-email-macli@brc.ubc.ca>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Vincent Li <macli@brc.ubc.ca>
List-ID: <linux-mm.kvack.org>

Name zone_nr_pages can be mis-read as zone's (total) number pages, but it actually returns
zone's LRU list number pages.

I know reading the code would clear the name confusion, want to know if patch making sense.
 
Signed-off-by: Vincent Li <macli@brc.ubc.ca>
---
 mm/vmscan.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 00596b9..9a55cb3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -148,7 +148,7 @@ static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
 	return &zone->reclaim_stat;
 }
 
-static unsigned long zone_nr_pages(struct zone *zone, struct scan_control *sc,
+static unsigned long zone_lru_nr_pages(struct zone *zone, struct scan_control *sc,
 				   enum lru_list lru)
 {
 	if (!scanning_global_lru(sc))
@@ -1479,10 +1479,10 @@ static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
 	unsigned long ap, fp;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 
-	anon  = zone_nr_pages(zone, sc, LRU_ACTIVE_ANON) +
-		zone_nr_pages(zone, sc, LRU_INACTIVE_ANON);
-	file  = zone_nr_pages(zone, sc, LRU_ACTIVE_FILE) +
-		zone_nr_pages(zone, sc, LRU_INACTIVE_FILE);
+	anon  = zone_lru_nr_pages(zone, sc, LRU_ACTIVE_ANON) +
+		zone_lru_nr_pages(zone, sc, LRU_INACTIVE_ANON);
+	file  = zone_lru_nr_pages(zone, sc, LRU_ACTIVE_FILE) +
+		zone_lru_nr_pages(zone, sc, LRU_INACTIVE_FILE);
 
 	if (scanning_global_lru(sc)) {
 		free  = zone_page_state(zone, NR_FREE_PAGES);
@@ -1590,7 +1590,7 @@ static void shrink_zone(int priority, struct zone *zone,
 		int file = is_file_lru(l);
 		unsigned long scan;
 
-		scan = zone_nr_pages(zone, sc, l);
+		scan = zone_lru_nr_pages(zone, sc, l);
 		if (priority || noswap) {
 			scan >>= priority;
 			scan = (scan * percent[file]) / 100;
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
