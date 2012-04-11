Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 115BA6B00E7
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 18:00:24 -0400 (EDT)
Received: by lbbgo4 with SMTP id go4so64666lbb.2
        for <linux-mm@kvack.org>; Wed, 11 Apr 2012 15:00:22 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V2 4/5] memcg: detect no memcgs above softlimit under zone reclaim.
Date: Wed, 11 Apr 2012 15:00:20 -0700
Message-Id: <1334181620-26890-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-mm@kvack.org

The function zone_reclaimable() marks zone->all_unreclaimable based on
per-zone pages_scanned and reclaimable_pages. If all_unreclaimable is true,
alloc_pages could go to OOM instead of getting stuck in page reclaim.

In memcg kernel, cgroup under its softlimit is not targeted under global
reclaim. It could be possible that all memcgs are under their softlimit for
a particular zone. So the direct reclaim do_try_to_free_pages() will always
return 1 which causes the caller __alloc_pages_direct_reclaim() enter tight
loop.

The reclaim priority check we put in should_reclaim_mem_cgroup() should help
this case, but we still don't want to burn cpu cycles for first few priorities
to get to that point. The idea is from LSF discussion where we detect it after
the first round of scanning and restart the reclaim by not looking at softlimit
at all. This allows us to make forward progress on shrink_zone() and free some
pages on the zone.

In order to do the detection for scanning all the memcgs under shrink_zone(),
i have to change the mem_cgroup_iter() from shared walk to full walk. Otherwise,
it would be very easy to skip lots of memcgs above softlimit and it causes the
flag "ignore_softlimit" being mistakenly set.

Signed-off-by: Ying Han <yinghan@google.com>
---
 mm/vmscan.c |   23 ++++++++++++++++-------
 1 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2dbc300..d65eae4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2158,21 +2158,25 @@ static void shrink_zone(int priority, struct zone *zone,
 			struct scan_control *sc)
 {
 	struct mem_cgroup *root = sc->target_mem_cgroup;
-	struct mem_cgroup_reclaim_cookie reclaim = {
-		.zone = zone,
-		.priority = priority,
-	};
 	struct mem_cgroup *memcg;
+	int above_softlimit, ignore_softlimit = 0;
+
 
-	memcg = mem_cgroup_iter(root, NULL, &reclaim);
+restart:
+	above_softlimit = 0;
+	memcg = mem_cgroup_iter(root, NULL, NULL);
 	do {
 		struct mem_cgroup_zone mz = {
 			.mem_cgroup = memcg,
 			.zone = zone,
 		};
 
-		if (should_reclaim_mem_cgroup(root, memcg, priority))
+		if (ignore_softlimit ||
+		   should_reclaim_mem_cgroup(root, memcg, priority)) {
+
 			shrink_mem_cgroup_zone(priority, &mz, sc);
+			above_softlimit = 1;
+		}
 
 		/*
 		 * Limit reclaim has historically picked one memcg and
@@ -2188,8 +2192,13 @@ static void shrink_zone(int priority, struct zone *zone,
 			mem_cgroup_iter_break(root, memcg);
 			break;
 		}
-		memcg = mem_cgroup_iter(root, memcg, &reclaim);
+		memcg = mem_cgroup_iter(root, memcg, NULL);
 	} while (memcg);
+
+	if (!above_softlimit) {
+		ignore_softlimit = 1;
+		goto restart;
+	}
 }
 
 /* Returns true if compaction should go ahead for a high-order request */
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
