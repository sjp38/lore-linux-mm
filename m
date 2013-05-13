Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 5AA6B6B003A
	for <linux-mm@kvack.org>; Mon, 13 May 2013 03:46:38 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [patch v3 -mm 3/3] vmscan, memcg: Do softlimit reclaim also for targeted reclaim
Date: Mon, 13 May 2013 09:46:12 +0200
Message-Id: <1368431172-6844-4-git-send-email-mhocko@suse.cz>
In-Reply-To: <1368431172-6844-1-git-send-email-mhocko@suse.cz>
References: <1368431172-6844-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>

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
---
 include/linux/memcontrol.h |    6 ++++--
 mm/memcontrol.c            |   14 +++++++++-----
 mm/vmscan.c                |    4 ++--
 3 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1833c95..80ed1b6 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -179,7 +179,8 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 	mem_cgroup_update_page_stat(page, idx, -1);
 }
 
-bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg);
+bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
+		struct mem_cgroup *root);
 
 void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
 static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
@@ -356,7 +357,8 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 }
 
 static inline
-bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg)
+bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
+		struct mem_cgroup *root)
 {
 	return false;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1223aaa..163567b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1891,11 +1891,13 @@ static bool mem_cgroup_reclaimable(struct mem_cgroup *memcg, bool noswap)
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
 
@@ -1903,12 +1905,14 @@ bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg)
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
index fe63a43..d738802 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -142,7 +142,7 @@ static bool global_reclaim(struct scan_control *sc)
 
 static bool mem_cgroup_should_soft_reclaim(struct scan_control *sc)
 {
-	return global_reclaim(sc);
+	return true;
 }
 #else
 static bool global_reclaim(struct scan_control *sc)
@@ -1974,7 +1974,7 @@ __shrink_zone(struct zone *zone, struct scan_control *sc, bool soft_reclaim)
 			struct lruvec *lruvec;
 
 			if (soft_reclaim &&
-					!mem_cgroup_soft_reclaim_eligible(memcg)) {
+					!mem_cgroup_soft_reclaim_eligible(memcg, root)) {
 				memcg = mem_cgroup_iter(root, memcg, &reclaim);
 				continue;
 			}
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
