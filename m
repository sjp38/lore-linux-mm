Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 522749000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 17:01:50 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 02/10] mm: vmscan: distinguish global reclaim from global LRU scanning
Date: Thu, 29 Sep 2011 23:00:56 +0200
Message-Id: <1317330064-28893-3-git-send-email-jweiner@redhat.com>
In-Reply-To: <1317330064-28893-1-git-send-email-jweiner@redhat.com>
References: <1317330064-28893-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The traditional zone reclaim code is scanning the per-zone LRU lists
during direct reclaim and kswapd, and the per-zone per-memory cgroup
LRU lists when reclaiming on behalf of a memory cgroup limit.

Subsequent patches will convert the traditional reclaim code to
reclaim exclusively from the per-memory cgroup LRU lists.  As a
result, using the predicate for which LRU list is scanned will no
longer be appropriate to tell global reclaim from limit reclaim.

This patch adds a global_reclaim() predicate to tell direct/kswapd
reclaim from memory cgroup limit reclaim and substitutes it in all
places where currently scanning_global_lru() is used for that.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 mm/vmscan.c |   62 +++++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 37 insertions(+), 25 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 71b5616..4bb7f78 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -153,9 +153,25 @@ static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
-#define scanning_global_lru(sc)	(!(sc)->mem_cgroup)
+static bool global_reclaim(struct scan_control *sc)
+{
+	return !sc->mem_cgroup;
+}
+
+static bool scanning_global_lru(struct scan_control *sc)
+{
+	return !sc->mem_cgroup;
+}
 #else
-#define scanning_global_lru(sc)	(1)
+static bool global_reclaim(struct scan_control *sc)
+{
+	return true;
+}
+
+static bool scanning_global_lru(struct scan_control *sc)
+{
+	return true;
+}
 #endif
 
 static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
@@ -1011,7 +1027,7 @@ keep_lumpy:
 	 * back off and wait for congestion to clear because further reclaim
 	 * will encounter the same problem
 	 */
-	if (nr_dirty && nr_dirty == nr_congested && scanning_global_lru(sc))
+	if (nr_dirty && nr_dirty == nr_congested && global_reclaim(sc))
 		zone_set_flag(zone, ZONE_CONGESTED);
 
 	free_page_list(&free_pages);
@@ -1330,7 +1346,7 @@ static int too_many_isolated(struct zone *zone, int file,
 	if (current_is_kswapd())
 		return 0;
 
-	if (!scanning_global_lru(sc))
+	if (!global_reclaim(sc))
 		return 0;
 
 	if (file) {
@@ -1508,6 +1524,12 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	if (scanning_global_lru(sc)) {
 		nr_taken = isolate_pages_global(nr_to_scan, &page_list,
 			&nr_scanned, sc->order, reclaim_mode, zone, 0, file);
+	} else {
+		nr_taken = mem_cgroup_isolate_pages(nr_to_scan, &page_list,
+			&nr_scanned, sc->order, reclaim_mode, zone,
+			sc->mem_cgroup, 0, file);
+	}
+	if (global_reclaim(sc)) {
 		zone->pages_scanned += nr_scanned;
 		if (current_is_kswapd())
 			__count_zone_vm_events(PGSCAN_KSWAPD, zone,
@@ -1515,14 +1537,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 		else
 			__count_zone_vm_events(PGSCAN_DIRECT, zone,
 					       nr_scanned);
-	} else {
-		nr_taken = mem_cgroup_isolate_pages(nr_to_scan, &page_list,
-			&nr_scanned, sc->order, reclaim_mode, zone,
-			sc->mem_cgroup, 0, file);
-		/*
-		 * mem_cgroup_isolate_pages() keeps track of
-		 * scanned pages on its own.
-		 */
 	}
 
 	if (nr_taken == 0) {
@@ -1647,18 +1661,16 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 						&pgscanned, sc->order,
 						reclaim_mode, zone,
 						1, file);
-		zone->pages_scanned += pgscanned;
 	} else {
 		nr_taken = mem_cgroup_isolate_pages(nr_pages, &l_hold,
 						&pgscanned, sc->order,
 						reclaim_mode, zone,
 						sc->mem_cgroup, 1, file);
-		/*
-		 * mem_cgroup_isolate_pages() keeps track of
-		 * scanned pages on its own.
-		 */
 	}
 
+	if (global_reclaim(sc))
+		zone->pages_scanned += pgscanned;
+
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
@@ -1828,7 +1840,7 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 
 static int vmscan_swappiness(struct scan_control *sc)
 {
-	if (scanning_global_lru(sc))
+	if (global_reclaim(sc))
 		return vm_swappiness;
 	return mem_cgroup_swappiness(sc->mem_cgroup);
 }
@@ -1863,9 +1875,9 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 	 * latencies, so it's better to scan a minimum amount there as
 	 * well.
 	 */
-	if (scanning_global_lru(sc) && current_is_kswapd())
+	if (current_is_kswapd())
 		force_scan = true;
-	if (!scanning_global_lru(sc))
+	if (!global_reclaim(sc))
 		force_scan = true;
 
 	/* If we have no swap space, do not bother scanning anon pages. */
@@ -1882,7 +1894,7 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 	file  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +
 		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
 
-	if (scanning_global_lru(sc)) {
+	if (global_reclaim(sc)) {
 		free  = zone_page_state(zone, NR_FREE_PAGES);
 		/* If we have very few page cache pages,
 		   force-scan anon pages. */
@@ -2109,7 +2121,7 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
 		 * Take care memory controller reclaiming has small influence
 		 * to global LRU.
 		 */
-		if (scanning_global_lru(sc)) {
+		if (global_reclaim(sc)) {
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 				continue;
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
@@ -2188,7 +2200,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	get_mems_allowed();
 	delayacct_freepages_start();
 
-	if (scanning_global_lru(sc))
+	if (global_reclaim(sc))
 		count_vm_event(ALLOCSTALL);
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
@@ -2200,7 +2212,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		 * Don't shrink slabs when reclaiming memory from
 		 * over limit cgroups
 		 */
-		if (scanning_global_lru(sc)) {
+		if (global_reclaim(sc)) {
 			unsigned long lru_pages = 0;
 			for_each_zone_zonelist(zone, z, zonelist,
 					gfp_zone(sc->gfp_mask)) {
@@ -2261,7 +2273,7 @@ out:
 		return 0;
 
 	/* top priority shrink_zones still had more to do? don't OOM, then */
-	if (scanning_global_lru(sc) && !all_unreclaimable(zonelist, sc))
+	if (global_reclaim(sc) && !all_unreclaimable(zonelist, sc))
 		return 1;
 
 	return 0;
-- 
1.7.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
