Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id A2C176B0044
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 09:38:52 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 04/34] mm: vmscan: fix force-scanning small targets without swap
Date: Mon, 23 Jul 2012 14:38:17 +0100
Message-Id: <1343050727-3045-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1343050727-3045-1-git-send-email-mgorman@suse.de>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Johannes Weiner <jweiner@redhat.com>

commit a4d3e9e76337059406fcf3ead288c0df22a790e9 upstream.

Stable note: Not tracked in Bugzilla. This patch augments an earlier commit
	that avoids scanning priority being artificially raised. The older
	fix was particularly important for small memcgs to avoid calling
	wait_iff_congested() unnecessarily.

Without swap, anonymous pages are not scanned.  As such, they should not
count when considering force-scanning a small target if there is no swap.

Otherwise, targets are not force-scanned even when their effective scan
number is zero and the other conditions--kswapd/memcg--apply.

This fixes 246e87a93934 ("memcg: fix get_scan_count() for small
targets").

[akpm@linux-foundation.org: fix comment]
Signed-off-by: Johannes Weiner <jweiner@redhat.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Cc: Ying Han <yinghan@google.com>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |   27 ++++++++++++---------------
 1 file changed, 12 insertions(+), 15 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 769935d..bdfdec3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1747,23 +1747,15 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
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
+	/* kswapd does zone balancing and needs to scan this zone */
+	if (scanning_global_lru(sc) && current_is_kswapd())
+		force_scan = true;
+	/* memcg may have small limit and need to avoid priority drop */
+	if (!scanning_global_lru(sc))
+		force_scan = true;
 
 	/* If we have no swap space, do not bother scanning anon pages. */
 	if (!sc->may_swap || (nr_swap_pages <= 0)) {
@@ -1776,6 +1768,11 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
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
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
