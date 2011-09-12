Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8EAD06B0276
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 06:58:24 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 08/11] mm: vmscan: convert global reclaim to per-memcg LRU lists
Date: Mon, 12 Sep 2011 12:57:25 +0200
Message-Id: <1315825048-3437-9-git-send-email-jweiner@redhat.com>
In-Reply-To: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The global per-zone LRU lists are about to go away on memcg-enabled
kernels, global reclaim must be able to find its pages on the
per-memcg LRU lists.

Since the LRU pages of a zone are distributed over all existing memory
cgroups, a scan target for a zone is complete when all memory cgroups
are scanned for their proportional share of a zone's memory.

The forced scanning of small scan targets from kswapd is limited to
zones marked unreclaimable, otherwise kswapd can quickly overreclaim
by force-scanning the LRU lists of multiple memory cgroups.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 mm/vmscan.c |   39 ++++++++++++++++++++++-----------------
 1 files changed, 22 insertions(+), 17 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index bb4d8b8..053609e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1887,7 +1887,7 @@ static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
 	 * latencies, so it's better to scan a minimum amount there as
 	 * well.
 	 */
-	if (current_is_kswapd())
+	if (current_is_kswapd() && mz->zone->all_unreclaimable)
 		force_scan = true;
 	if (!global_reclaim(sc))
 		force_scan = true;
@@ -2111,16 +2111,6 @@ static void shrink_zone(int priority, struct zone *zone,
 	};
 	struct mem_cgroup *mem;
 
-	if (global_reclaim(sc)) {
-		struct mem_cgroup_zone mz = {
-			.mem_cgroup = NULL,
-			.zone = zone,
-		};
-
-		shrink_mem_cgroup_zone(priority, &mz, sc);
-		return;
-	}
-
 	mem = mem_cgroup_iter(root, NULL, &iter);
 	do {
 		struct mem_cgroup_zone mz = {
@@ -2134,6 +2124,10 @@ static void shrink_zone(int priority, struct zone *zone,
 		 * scanned it with decreasing priority levels until
 		 * nr_to_reclaim had been reclaimed.  This priority
 		 * cycle is thus over after a single memcg.
+		 *
+		 * Direct reclaim and kswapd, on the other hand, have
+		 * to scan all memory cgroups to fulfill the overall
+		 * scan target for the zone.
 		 */
 		if (!global_reclaim(sc)) {
 			mem_cgroup_iter_break(root, mem);
@@ -2451,13 +2445,24 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 static void age_active_anon(struct zone *zone, struct scan_control *sc,
 			    int priority)
 {
-	struct mem_cgroup_zone mz = {
-		.mem_cgroup = NULL,
-		.zone = zone,
-	};
+	struct mem_cgroup *mem;
+
+	if (!total_swap_pages)
+		return;
+
+	mem = mem_cgroup_iter(NULL, NULL, NULL);
+	do {
+		struct mem_cgroup_zone mz = {
+			.mem_cgroup = mem,
+			.zone = zone,
+		};
 
-	if (inactive_anon_is_low(&mz))
-		shrink_active_list(SWAP_CLUSTER_MAX, &mz, sc, priority, 0);
+		if (inactive_anon_is_low(&mz))
+			shrink_active_list(SWAP_CLUSTER_MAX, &mz,
+					   sc, priority, 0);
+
+		mem = mem_cgroup_iter(NULL, mem, NULL);
+	} while (mem);
 }
 
 /*
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
