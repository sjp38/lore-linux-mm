Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id F3C566B003B
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 12:04:32 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v5.1 8/8] memcg, vmscan: do not fall into reclaim-all pass too quickly
Date: Fri, 26 Jul 2013 18:04:18 +0200
Message-Id: <1374854658-26990-9-git-send-email-mhocko@suse.cz>
In-Reply-To: <1374854658-26990-1-git-send-email-mhocko@suse.cz>
References: <1374854658-26990-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@gmail.com>

shrink_zone starts with soft reclaim pass first and then falls back to
regular reclaim if nothing has been scanned. This behavior is natural
but there is a catch. Memcg iterators, when used with the reclaim
cookie, are designed to help to prevent from over reclaim by
interleaving reclaimers (per node-zone-priority) so the tree walk might
miss many (even all) nodes in the hierarchy e.g. when there are direct
reclaimers racing with each other or with kswapd in the global case or
multiple allocators reaching the limit for the target reclaim case.
To make it even more complicated, targeted reclaim doesn't do the whole
tree walk because it stops reclaiming once it reclaims sufficient pages.
As a result groups over the limit might be missed, thus nothing is
scanned, and reclaim would fall back to the reclaim all mode.

This patch checks for the incomplete tree walk in shrink_zone. If no
group has been visited and the hierarchy is soft reclaimable then we
must have missed some groups, in which case the __shrink_zone is called
again. This doesn't guarantee there will be some progress of course
because the current reclaimer might be still racing with others but it
would at least give a chance to start the walk without a big risk of
reclaim latencies.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/vmscan.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b45ff5b..6134708 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2157,10 +2157,11 @@ static inline bool should_continue_reclaim(struct zone *zone,
 	}
 }
 
-static void
+static int
 __shrink_zone(struct zone *zone, struct scan_control *sc, bool soft_reclaim)
 {
 	unsigned long nr_reclaimed, nr_scanned;
+	int groups_scanned = 0;
 
 	do {
 		struct mem_cgroup *root = sc->target_mem_cgroup;
@@ -2178,6 +2179,7 @@ __shrink_zone(struct zone *zone, struct scan_control *sc, bool soft_reclaim)
 		while ((memcg = mem_cgroup_iter_cond(root, memcg, &reclaim, filter))) {
 			struct lruvec *lruvec;
 
+			groups_scanned++;
 			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 
 			shrink_lruvec(lruvec, sc);
@@ -2205,6 +2207,8 @@ __shrink_zone(struct zone *zone, struct scan_control *sc, bool soft_reclaim)
 
 	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
 					 sc->nr_scanned - nr_scanned, sc));
+
+	return groups_scanned;
 }
 
 
@@ -2212,8 +2216,19 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 {
 	bool do_soft_reclaim = mem_cgroup_should_soft_reclaim(sc);
 	unsigned long nr_scanned = sc->nr_scanned;
+	int scanned_groups;
 
-	__shrink_zone(zone, sc, do_soft_reclaim);
+	scanned_groups = __shrink_zone(zone, sc, do_soft_reclaim);
+	/*
+         * memcg iterator might race with other reclaimer or start from
+         * a incomplete tree walk so the tree walk in __shrink_zone
+         * might have missed groups that are above the soft limit. Try
+         * another loop to catch up with others. Do it just once to
+         * prevent from reclaim latencies when other reclaimers always
+         * preempt this one.
+	 */
+	if (do_soft_reclaim && !scanned_groups)
+		__shrink_zone(zone, sc, do_soft_reclaim);
 
 	/*
 	 * No group is over the soft limit or those that are do not have
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
