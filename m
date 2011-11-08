Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EB1C56B006E
	for <linux-mm@kvack.org>; Tue,  8 Nov 2011 16:25:57 -0500 (EST)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 07/10] mm: vmscan: convert global reclaim to per-memcg LRU lists
Date: Tue,  8 Nov 2011 22:23:25 +0100
Message-Id: <1320787408-22866-8-git-send-email-jweiner@redhat.com>
In-Reply-To: <1320787408-22866-1-git-send-email-jweiner@redhat.com>
References: <1320787408-22866-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 mm/vmscan.c |   39 ++++++++++++++++++++++-----------------
 1 files changed, 22 insertions(+), 17 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 10f8ca0..e214e02 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1898,7 +1898,7 @@ static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
 	 * latencies, so it's better to scan a minimum amount there as
 	 * well.
 	 */
-	if (current_is_kswapd())
+	if (current_is_kswapd() && mz->zone->all_unreclaimable)
 		force_scan = true;
 	if (!global_reclaim(sc))
 		force_scan = true;
@@ -2122,16 +2122,6 @@ static void shrink_zone(int priority, struct zone *zone,
 	};
 	struct mem_cgroup *memcg;
 
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
 	memcg = mem_cgroup_iter(root, NULL, &reclaim);
 	do {
 		struct mem_cgroup_zone mz = {
@@ -2145,6 +2135,10 @@ static void shrink_zone(int priority, struct zone *zone,
 		 * scanned it with decreasing priority levels until
 		 * nr_to_reclaim had been reclaimed.  This priority
 		 * cycle is thus over after a single memcg.
+		 *
+		 * Direct reclaim and kswapd, on the other hand, have
+		 * to scan all memory cgroups to fulfill the overall
+		 * scan target for the zone.
 		 */
 		if (!global_reclaim(sc)) {
 			mem_cgroup_iter_break(root, memcg);
@@ -2489,13 +2483,24 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 static void age_active_anon(struct zone *zone, struct scan_control *sc,
 			    int priority)
 {
-	struct mem_cgroup_zone mz = {
-		.mem_cgroup = NULL,
-		.zone = zone,
-	};
+	struct mem_cgroup *memcg;
 
-	if (inactive_anon_is_low(&mz))
-		shrink_active_list(SWAP_CLUSTER_MAX, &mz, sc, priority, 0);
+	if (!total_swap_pages)
+		return;
+
+	memcg = mem_cgroup_iter(NULL, NULL, NULL);
+	do {
+		struct mem_cgroup_zone mz = {
+			.mem_cgroup = memcg,
+			.zone = zone,
+		};
+
+		if (inactive_anon_is_low(&mz))
+			shrink_active_list(SWAP_CLUSTER_MAX, &mz,
+					   sc, priority, 0);
+
+		memcg = mem_cgroup_iter(NULL, memcg, NULL);
+	} while (memcg);
 }
 
 /*
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
