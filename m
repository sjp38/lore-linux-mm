Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id A933A6B00B0
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 14:23:52 -0400 (EDT)
Received: by yhpp61 with SMTP id p61so878660yhp.2
        for <linux-mm@kvack.org>; Wed, 06 Jun 2012 11:23:51 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 3/5] mm: memcg detect no memcgs above softlimit under zone reclaim.
Date: Wed,  6 Jun 2012 11:23:51 -0700
Message-Id: <1339007031-10527-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
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
 mm/vmscan.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0560783..5d036f5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2142,6 +2142,10 @@ static void shrink_zone(int priority, struct zone *zone,
 		.priority = priority,
 	};
 	struct mem_cgroup *memcg;
+	bool over_softlimit, ignore_softlimit = false;
+
+restart:
+	over_softlimit = false;
 
 	memcg = mem_cgroup_iter(root, NULL, &reclaim);
 	do {
@@ -2163,9 +2167,14 @@ static void shrink_zone(int priority, struct zone *zone,
 		 * we have to reclaim under softlimit instead of burning more
 		 * cpu cycles.
 		 */
-		if (!global_reclaim(sc) || priority < DEF_PRIORITY - 2 ||
-				should_reclaim_mem_cgroup(memcg))
+		if (ignore_softlimit || !global_reclaim(sc) ||
+				priority < DEF_PRIORITY - 2 ||
+				should_reclaim_mem_cgroup(memcg)) {
 			shrink_mem_cgroup_zone(priority, &mz, sc);
+
+			over_softlimit = true;
+		}
+
 		/*
 		 * Limit reclaim has historically picked one memcg and
 		 * scanned it with decreasing priority levels until
@@ -2182,6 +2191,11 @@ static void shrink_zone(int priority, struct zone *zone,
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
