Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 26D126B005A
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 18:32:20 -0400 (EDT)
Received: by obbun3 with SMTP id un3so3982695obb.2
        for <linux-mm@kvack.org>; Mon, 30 Jul 2012 15:32:19 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V7 2/2] mm: memcg detect no memcgs above softlimit under zone reclaim
Date: Mon, 30 Jul 2012 15:32:18 -0700
Message-Id: <1343687538-24284-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

In memcg kernel, cgroup under its softlimit is not targeted under global
reclaim. It could be possible that all memcgs are under their softlimit for
a particular zone. If that is the case, the current implementation will
burn extra cpu cycles without making forward progress.

The idea is from LSF discussion where we detect it after the first round of
scanning and restart the reclaim by not looking at softlimit at all. This
allows us to make forward progress on shrink_zone().

Signed-off-by: Ying Han <yinghan@google.com>
---
 mm/vmscan.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 59e633c..747d903 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1861,6 +1861,10 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 		.priority = sc->priority,
 	};
 	struct mem_cgroup *memcg;
+	bool over_softlimit, ignore_softlimit = false;
+
+restart:
+	over_softlimit = false;
 
 	memcg = mem_cgroup_iter(root, NULL, &reclaim);
 	do {
@@ -1879,10 +1883,14 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 		 * we have to reclaim under softlimit instead of burning more
 		 * cpu cycles.
 		 */
-		if (!global_reclaim(sc) || sc->priority < DEF_PRIORITY - 2 ||
-				mem_cgroup_over_soft_limit(memcg))
+		if (ignore_softlimit || !global_reclaim(sc) ||
+				sc->priority < DEF_PRIORITY - 2 ||
+				mem_cgroup_over_soft_limit(memcg)) {
 			shrink_lruvec(lruvec, sc);
 
+			over_softlimit = true;
+		}
+
 		/*
 		 * Limit reclaim has historically picked one memcg and
 		 * scanned it with decreasing priority levels until
@@ -1899,6 +1907,11 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 		}
 		memcg = mem_cgroup_iter(root, memcg, &reclaim);
 	} while (memcg);
+
+	if (!over_softlimit) {
+		ignore_softlimit = true;
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
