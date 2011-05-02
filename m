Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DD8D96B0011
	for <linux-mm@kvack.org>; Mon,  2 May 2011 12:51:37 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V2 1/2] Add the soft_limit reclaim in global direct reclaim.
Date: Mon,  2 May 2011 09:50:24 -0700
Message-Id: <1304355025-1421-2-git-send-email-yinghan@google.com>
In-Reply-To: <1304355025-1421-1-git-send-email-yinghan@google.com>
References: <1304355025-1421-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

We recently added the change in global background reclaim which
counts the return value of soft_limit reclaim. Now this patch adds
the similar logic on global direct reclaim.

We should skip scanning global LRU on shrink_zone if soft_limit reclaim
does enough work. This is the first step where we start with counting
the nr_scanned and nr_reclaimed from soft_limit reclaim into global
scan_control.

no change since v1.

Signed-off-by: Ying Han <yinghan@google.com>
---
 mm/vmscan.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b3a569f..84003cc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1959,11 +1959,14 @@ restart:
  * If a zone is deemed to be full of pinned pages then just give it a light
  * scan then give up on it.
  */
-static void shrink_zones(int priority, struct zonelist *zonelist,
+static unsigned long shrink_zones(int priority, struct zonelist *zonelist,
 					struct scan_control *sc)
 {
 	struct zoneref *z;
 	struct zone *zone;
+	unsigned long nr_soft_reclaimed;
+	unsigned long nr_soft_scanned;
+	unsigned long total_scanned = 0;
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 					gfp_zone(sc->gfp_mask), sc->nodemask) {
@@ -1980,8 +1983,17 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
 				continue;	/* Let kswapd poll it */
 		}
 
+		nr_soft_scanned = 0;
+		nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
+							sc->order, sc->gfp_mask,
+							&nr_soft_scanned);
+		sc->nr_reclaimed += nr_soft_reclaimed;
+		total_scanned += nr_soft_scanned;
+
 		shrink_zone(priority, zone, sc);
 	}
+
+	return total_scanned;
 }
 
 static bool zone_reclaimable(struct zone *zone)
@@ -2045,7 +2057,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		sc->nr_scanned = 0;
 		if (!priority)
 			disable_swap_token();
-		shrink_zones(priority, zonelist, sc);
+		total_scanned += shrink_zones(priority, zonelist, sc);
 		/*
 		 * Don't shrink slabs when reclaiming memory from
 		 * over limit cgroups
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
