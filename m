Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 87CBF900137
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 16:32:26 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 1/2] mm: vmscan: fix force-scanning small targets without swap
Date: Thu, 11 Aug 2011 22:31:54 +0200
Message-Id: <1313094715-31187-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Mel Gorman <mel@csn.ul.ie>

Without swap, anonymous pages are not scanned.  As such, they should
not count when considering force-scanning a small target if there is
no swap.

Otherwise, targets are not force-scanned even when their effective
scan number is zero and the other conditions--kswapd/memcg--apply.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Ying Han <yinghan@google.com>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |   27 ++++++++++++---------------
 1 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3153729..96061d7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1830,23 +1830,15 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 	u64 fraction[2], denominator;
 	enum lru_list l;
 	int noswap = 0;
-	int force_scan = 0;
+	bool force_scan = false;
 	unsigned long nr_force_scan[2];
 
-
-	anon  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_ANON) +
-		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON);
-	file  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +
-		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
-
-	if (((anon + file) >> priority) < SWAP_CLUSTER_MAX) {
-		/* kswapd does zone balancing and need to scan this zone */
-		if (scanning_global_lru(sc) && current_is_kswapd())
-			force_scan = 1;
-		/* memcg may have small limit and need to avoid priority drop */
-		if (!scanning_global_lru(sc))
-			force_scan = 1;
-	}
+	/* kswapd does zone balancing and need to scan this zone */
+	if (scanning_global_lru(sc) && current_is_kswapd())
+		force_scan = true;
+	/* memcg may have small limit and need to avoid priority drop */
+	if (!scanning_global_lru(sc))
+		force_scan = true;
 
 	/* If we have no swap space, do not bother scanning anon pages. */
 	if (!sc->may_swap || (nr_swap_pages <= 0)) {
@@ -1859,6 +1851,11 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 		goto out;
 	}
 
+	anon  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_ANON) +
+		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON);
+	file  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +
+		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
+
 	if (scanning_global_lru(sc)) {
 		free  = zone_page_state(zone, NR_FREE_PAGES);
 		/* If we have very few page cache pages,
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
