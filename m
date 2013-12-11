Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 336C66B003A
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 09:16:44 -0500 (EST)
Received: by mail-ee0-f52.google.com with SMTP id d17so2925611eek.39
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 06:16:43 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id t6si19229508eeh.129.2013.12.11.06.16.43
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 06:16:43 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 4/4] mm, memcg: expedite OOM if no memcg is reclaimable
Date: Wed, 11 Dec 2013 15:15:55 +0100
Message-Id: <1386771355-21805-5-git-send-email-mhocko@suse.cz>
In-Reply-To: <1386771355-21805-1-git-send-email-mhocko@suse.cz>
References: <1386771355-21805-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>

Let shrink_zone us know that at least one group has been eligible so
that the caller knows that further attempts to reclaim will not help.

All the shrink_zone callers should back off in such a case. Direct
reclaim should hand over to OOM as soon as possible, kswapd should not
raise the priority and prefferably go to sleep, and the zone reclaim
should just give up without re-trying with higher priority.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/vmscan.c | 52 +++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 41 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 234d1690563a..b9e21df2751a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2167,9 +2167,15 @@ static inline bool should_continue_reclaim(struct zone *zone,
 	}
 }
 
-static void shrink_zone(struct zone *zone, struct scan_control *sc)
+/*
+ * Returns true if there is at least one lruvec has been scanned.
+ * Always true for !CONFIG_MEMCG otherwise at least one eligible
+ * memcg has to exist (see mem_cgroup_reclaim_eligible).
+ */
+static bool shrink_zone(struct zone *zone, struct scan_control *sc)
 {
 	unsigned long nr_reclaimed, nr_scanned;
+	int groups_reclaimed = 0;
 
 	do {
 		struct mem_cgroup *root = sc->target_mem_cgroup;
@@ -2200,6 +2206,7 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 				continue;
 			}
 
+			groups_reclaimed++;
 			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 
 			shrink_lruvec(lruvec, sc);
@@ -2226,8 +2233,12 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 			   sc->nr_scanned - nr_scanned,
 			   sc->nr_reclaimed - nr_reclaimed);
 
+		if (!groups_reclaimed)
+			break;
 	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
 					 sc->nr_scanned - nr_scanned, sc));
+
+	return groups_reclaimed > 0;
 }
 
 /* Returns true if compaction should go ahead for a high-order request */
@@ -2347,7 +2358,9 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 			/* need some check for avoid more shrink_zone() */
 		}
 
-		shrink_zone(zone, sc);
+		/* No memcg to reclaim from so bail out */
+		if (!shrink_zone(zone, sc))
+			break;
 	}
 
 	return aborted_reclaim;
@@ -2442,6 +2455,17 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 			goto out;
 
 		/*
+		 * If the target memcg is not eligible for reclaim then we have
+		 * no option but OOM
+		 */
+		if (!sc->nr_scanned &&
+				mem_cgroup_reclaim_no_eligible(
+					sc->target_mem_cgroup)) {
+			delayacct_freepages_end();
+			return 0;
+		}
+
+		/*
 		 * If we're getting trouble reclaiming, start doing
 		 * writepage even in laptop mode.
 		 */
@@ -2481,13 +2505,6 @@ out:
 	if (aborted_reclaim)
 		return 1;
 
-	/*
-	 * If the target memcg is not eligible for reclaim then we have no opetion
-	 * but OOM
-	 */
-	if (!sc->nr_scanned && mem_cgroup_reclaim_no_eligible(sc->target_mem_cgroup))
-		return 0;
-
 	/* top priority shrink_zones still had more to do? don't OOM, then */
 	if (global_reclaim(sc) && !all_unreclaimable(zonelist, sc))
 		return 1;
@@ -2772,6 +2789,17 @@ static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
 	unsigned long balanced_pages = 0;
 	int i;
 
+
+	/*
+	 * If no memcg is eligible to reclaim then we end up scanning nothing
+	 * and so it doesn't make any sense to do any scanning in the first
+	 * place. So let's go to sleep and pretend everything is balanced.
+	 * We rely on the direct reclaim to eventually sort out the situation
+	 * e.g. by triggering OOM killer.
+	 */
+	if (mem_cgroup_reclaim_no_eligible(NULL))
+		return true;
+
 	/* Check the watermark levels */
 	for (i = 0; i <= classzone_idx; i++) {
 		struct zone *zone = pgdat->node_zones + i;
@@ -3115,7 +3143,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 		 * Raise priority if scanning rate is too low or there was no
 		 * progress in reclaiming pages
 		 */
-		if (raise_priority || !sc.nr_reclaimed)
+		if (raise_priority || (sc.nr_scanned && !sc.nr_reclaimed))
 			sc.priority--;
 	} while (sc.priority >= 1 &&
 		 !pgdat_balanced(pgdat, order, *classzone_idx));
@@ -3572,7 +3600,9 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		 * priorities until we have enough memory freed.
 		 */
 		do {
-			shrink_zone(zone, &sc);
+			/* memcg to reclaim from so bail out */
+			if(!shrink_zone(zone, &sc))
+				break;
 		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
 	}
 
-- 
1.8.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
