Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id B7EB66B004D
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 19:00:05 -0500 (EST)
Received: by yenq10 with SMTP id q10so62509yen.2
        for <linux-mm@kvack.org>; Tue, 06 Dec 2011 16:00:04 -0800 (PST)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 1/3] memcg: rework softlimit reclaim
Date: Tue,  6 Dec 2011 15:59:57 -0800
Message-Id: <1323215999-29164-2-git-send-email-yinghan@google.com>
In-Reply-To: <1323215999-29164-1-git-send-email-yinghan@google.com>
References: <1323215999-29164-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>
Cc: linux-mm@kvack.org

Under the shrink_zone, we examine whether or not to reclaim from a memcg
based on its softlimit. We skip scanning the memcg for the first 3 priority.
This is to balance between isolation and efficiency. we don't want to halt
the system by skipping memcgs with low-hanging fruits forever.

Another change is to set soft_limit_in_bytes to 0 by default. This is needed
for both functional and performance:

1. If soft_limit are all set to MAX, it wastes first three periority iterations
without scanning anything.

2. By default every memcg is eligibal for softlimit reclaim, and we can also
set the value to MAX for special memcg which is immune to soft limit reclaim.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |    7 ++++
 kernel/res_counter.c       |    1 -
 mm/memcontrol.c            |    8 +++++
 mm/vmscan.c                |   67 ++++++++++++++++++++++++++-----------------
 4 files changed, 55 insertions(+), 28 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 81aabfb..53d483b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -107,6 +107,8 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
 				   struct mem_cgroup_reclaim_cookie *);
 void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
 
+bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *);
+
 /*
  * For memory reclaim.
  */
@@ -293,6 +295,11 @@ static inline void mem_cgroup_iter_break(struct mem_cgroup *root,
 {
 }
 
+static inline bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *mem)
+{
+	return true;
+}
+
 static inline int mem_cgroup_get_reclaim_priority(struct mem_cgroup *memcg)
 {
 	return 0;
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index b814d6c..92afdc1 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -18,7 +18,6 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent)
 {
 	spin_lock_init(&counter->lock);
 	counter->limit = RESOURCE_MAX;
-	counter->soft_limit = RESOURCE_MAX;
 	counter->parent = parent;
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4425f62..7c6cade 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -926,6 +926,14 @@ out:
 }
 EXPORT_SYMBOL(mem_cgroup_count_vm_event);
 
+bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *mem)
+{
+	if (mem_cgroup_disabled() || mem_cgroup_is_root(mem))
+		return true;
+
+	return res_counter_soft_limit_excess(&mem->res) > 0;
+}
+
 /**
  * mem_cgroup_zone_lruvec - get the lru list vector for a zone and memcg
  * @zone: zone of the wanted lruvec
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0ba7d35..b36d91b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2091,6 +2091,17 @@ restart:
 	throttle_vm_writeout(sc->gfp_mask);
 }
 
+static bool should_reclaim_mem_cgroup(struct scan_control *sc,
+				      struct mem_cgroup *mem,
+				      int priority)
+{
+	if (!global_reclaim(sc) || priority <= DEF_PRIORITY - 3 ||
+			mem_cgroup_soft_limit_exceeded(mem))
+		return true;
+
+	return false;
+}
+
 static void shrink_zone(int priority, struct zone *zone,
 			struct scan_control *sc)
 {
@@ -2108,7 +2119,9 @@ static void shrink_zone(int priority, struct zone *zone,
 			.zone = zone,
 		};
 
-		shrink_mem_cgroup_zone(priority, &mz, sc);
+		if (should_reclaim_mem_cgroup(sc, memcg, priority))
+			shrink_mem_cgroup_zone(priority, &mz, sc);
+
 		/*
 		 * Limit reclaim has historically picked one memcg and
 		 * scanned it with decreasing priority levels until
@@ -2152,8 +2165,8 @@ static bool shrink_zones(int priority, struct zonelist *zonelist,
 {
 	struct zoneref *z;
 	struct zone *zone;
-	unsigned long nr_soft_reclaimed;
-	unsigned long nr_soft_scanned;
+//	unsigned long nr_soft_reclaimed;
+//	unsigned long nr_soft_scanned;
 	bool should_abort_reclaim = false;
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
@@ -2186,19 +2199,19 @@ static bool shrink_zones(int priority, struct zonelist *zonelist,
 					continue;
 				}
 			}
-			/*
-			 * This steals pages from memory cgroups over softlimit
-			 * and returns the number of reclaimed pages and
-			 * scanned pages. This works for global memory pressure
-			 * and balancing, not for a memcg's limit.
-			 */
-			nr_soft_scanned = 0;
-			nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
-						sc->order, sc->gfp_mask,
-						&nr_soft_scanned);
-			sc->nr_reclaimed += nr_soft_reclaimed;
-			sc->nr_scanned += nr_soft_scanned;
-			/* need some check for avoid more shrink_zone() */
+//			/*
+//			 * This steals pages from memory cgroups over softlimit
+//			 * and returns the number of reclaimed pages and
+//			 * scanned pages. This works for global memory pressure
+//			 * and balancing, not for a memcg's limit.
+//			 */
+//			nr_soft_scanned = 0;
+//			nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
+//						sc->order, sc->gfp_mask,
+//						&nr_soft_scanned);
+//			sc->nr_reclaimed += nr_soft_reclaimed;
+//			sc->nr_scanned += nr_soft_scanned;
+//			/* need some check for avoid more shrink_zone() */
 		}
 
 		shrink_zone(priority, zone, sc);
@@ -2590,8 +2603,8 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 	unsigned long total_scanned;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
-	unsigned long nr_soft_reclaimed;
-	unsigned long nr_soft_scanned;
+//	unsigned long nr_soft_reclaimed;
+//	unsigned long nr_soft_scanned;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.may_unmap = 1,
@@ -2683,15 +2696,15 @@ loop_again:
 
 			sc.nr_scanned = 0;
 
-			nr_soft_scanned = 0;
-			/*
-			 * Call soft limit reclaim before calling shrink_zone.
-			 */
-			nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
-							order, sc.gfp_mask,
-							&nr_soft_scanned);
-			sc.nr_reclaimed += nr_soft_reclaimed;
-			total_scanned += nr_soft_scanned;
+//			nr_soft_scanned = 0;
+//			/*
+//			 * Call soft limit reclaim before calling shrink_zone.
+//			 */
+//			nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
+//							order, sc.gfp_mask,
+//							&nr_soft_scanned);
+//			sc.nr_reclaimed += nr_soft_reclaimed;
+//			total_scanned += nr_soft_scanned;
 
 			/*
 			 * We put equal pressure on every zone, unless
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
