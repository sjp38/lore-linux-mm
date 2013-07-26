Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 6C5766B0036
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 12:04:30 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v5.1 3/8] vmscan, memcg: Do softlimit reclaim also for targeted reclaim
Date: Fri, 26 Jul 2013 18:04:13 +0200
Message-Id: <1374854658-26990-4-git-send-email-mhocko@suse.cz>
In-Reply-To: <1374854658-26990-1-git-send-email-mhocko@suse.cz>
References: <1374854658-26990-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@gmail.com>

Soft reclaim has been done only for the global reclaim (both background
and direct). Since "memcg: integrate soft reclaim tighter with zone
shrinking code" there is no reason for this limitation anymore as the
soft limit reclaim doesn't use any special code paths and it is a
part of the zone shrinking code which is used by both global and
targeted reclaims.

>From semantic point of view it is even natural to consider soft limit
before touching all groups in the hierarchy tree which is touching the
hard limit because soft limit tells us where to push back when there is
a  memory pressure. It is not important whether the pressure comes from
the limit or imbalanced zones.

This patch simply enables soft reclaim unconditionally in
mem_cgroup_should_soft_reclaim so it is enabled for both global and
targeted reclaim paths. mem_cgroup_soft_reclaim_eligible needs to learn
about the root of the reclaim to know where to stop checking soft limit
state of parents up the hierarchy.
Say we have
A (over soft limit)
 \
  B (below s.l., hit the hard limit)
 / \
C   D (below s.l.)

B is the source of the outside memory pressure now for D but we
shouldn't soft reclaim it because it is behaving well under B subtree
and we can still reclaim from C (pressumably it is over the limit).
mem_cgroup_soft_reclaim_eligible should therefore stop climbing up the
hierarchy at B (root of the memory pressure).

Changes since v1
- add sc->target_mem_cgroup handling into mem_cgroup_soft_reclaim_eligible

Signed-off-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: Glauber Costa <glommer@openvz.org>
Reviewed-by: Tejun Heo <tj@kernel.org>
---
 include/linux/memcontrol.h |  6 ++++--
 mm/memcontrol.c            | 14 +++++++++-----
 mm/vmscan.c                |  4 ++--
 3 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d495b9e..065ecef 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -180,7 +180,8 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 	mem_cgroup_update_page_stat(page, idx, -1);
 }
 
-bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg);
+bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
+		struct mem_cgroup *root);
 
 void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
 static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
@@ -357,7 +358,8 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 }
 
 static inline
-bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg)
+bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
+		struct mem_cgroup *root)
 {
 	return false;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2104343..441b81a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1792,11 +1792,13 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
 #endif
 
 /*
- * A group is eligible for the soft limit reclaim if it is
- * 	a) is over its soft limit
+ * A group is eligible for the soft limit reclaim under the given root
+ * hierarchy if
+ * 	a) it is over its soft limit
  * 	b) any parent up the hierarchy is over its soft limit
  */
-bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg)
+bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
+		struct mem_cgroup *root)
 {
 	struct mem_cgroup *parent = memcg;
 
@@ -1804,12 +1806,14 @@ bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg)
 		return true;
 
 	/*
-	 * If any parent up the hierarchy is over its soft limit then we
-	 * have to obey and reclaim from this group as well.
+	 * If any parent up to the root in the hierarchy is over its soft limit
+	 * then we have to obey and reclaim from this group as well.
 	 */
 	while((parent = parent_mem_cgroup(parent))) {
 		if (res_counter_soft_limit_excess(&parent->res))
 			return true;
+		if (parent == root)
+			break;
 	}
 
 	return false;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 14ecbdb..bb591fa 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -142,7 +142,7 @@ static bool global_reclaim(struct scan_control *sc)
 
 static bool mem_cgroup_should_soft_reclaim(struct scan_control *sc)
 {
-	return !mem_cgroup_disabled() && global_reclaim(sc);
+	return !mem_cgroup_disabled();
 }
 #else
 static bool global_reclaim(struct scan_control *sc)
@@ -2176,7 +2176,7 @@ __shrink_zone(struct zone *zone, struct scan_control *sc, bool soft_reclaim)
 			struct lruvec *lruvec;
 
 			if (soft_reclaim &&
-			    !mem_cgroup_soft_reclaim_eligible(memcg)) {
+			    !mem_cgroup_soft_reclaim_eligible(memcg, root)) {
 				memcg = mem_cgroup_iter(root, memcg, &reclaim);
 				continue;
 			}
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
