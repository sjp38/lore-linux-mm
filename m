Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3ABFD6B0022
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 02:25:46 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 6/8] vmscan: change zone_nr_lru_pages to take memcg instead of scan control
Date: Wed,  1 Jun 2011 08:25:17 +0200
Message-Id: <1306909519-7286-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

This function only uses sc->mem_cgroup from the scan control.  Change
it to take a memcg argument directly, so callsites without an actual
reclaim context can use it as well.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7d74e48..9c51ec8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -205,10 +205,11 @@ static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
 }
 
 static unsigned long zone_nr_lru_pages(struct zone *zone,
-				struct scan_control *sc, enum lru_list lru)
+				       struct mem_cgroup *mem,
+				       enum lru_list lru)
 {
-	if (!scanning_global_lru(sc))
-		return mem_cgroup_zone_nr_pages(sc->mem_cgroup, zone, lru);
+	if (mem)
+		return mem_cgroup_zone_nr_pages(mem, zone, lru);
 
 	return zone_page_state(zone, NR_LRU_BASE + lru);
 }
@@ -1780,10 +1781,10 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 		goto out;
 	}
 
-	anon  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_ANON) +
-		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON);
-	file  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +
-		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
+	anon  = zone_nr_lru_pages(zone, sc->mem_cgroup, LRU_ACTIVE_ANON) +
+		zone_nr_lru_pages(zone, sc->mem_cgroup, LRU_INACTIVE_ANON);
+	file  = zone_nr_lru_pages(zone, sc->mem_cgroup, LRU_ACTIVE_FILE) +
+		zone_nr_lru_pages(zone, sc->mem_cgroup, LRU_INACTIVE_FILE);
 
 	if (global_reclaim(sc)) {
 		free  = zone_page_state(zone, NR_FREE_PAGES);
@@ -1846,7 +1847,7 @@ out:
 		int file = is_file_lru(l);
 		unsigned long scan;
 
-		scan = zone_nr_lru_pages(zone, sc, l);
+		scan = zone_nr_lru_pages(zone, sc->mem_cgroup, l);
 		if (priority || noswap) {
 			scan >>= priority;
 			scan = div64_u64(scan * fraction[file], denominator);
@@ -1903,8 +1904,9 @@ static inline bool should_continue_reclaim(struct zone *zone,
 	 * inactive lists are large enough, continue reclaiming
 	 */
 	pages_for_compaction = (2UL << sc->order);
-	inactive_lru_pages = zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON) +
-				zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
+	inactive_lru_pages =
+		zone_nr_lru_pages(zone, sc->mem_cgroup, LRU_INACTIVE_ANON) +
+		zone_nr_lru_pages(zone, sc->mem_cgroup, LRU_INACTIVE_FILE);
 	if (sc->nr_reclaimed < pages_for_compaction &&
 			inactive_lru_pages > pages_for_compaction)
 		return true;
-- 
1.7.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
