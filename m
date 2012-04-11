Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id A7D236B0083
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 18:00:07 -0400 (EDT)
Received: by ghbg15 with SMTP id g15so179811ghb.2
        for <linux-mm@kvack.org>; Wed, 11 Apr 2012 15:00:06 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V2 2/5] memcg: add function should_reclaim_mem_cgroup()
Date: Wed, 11 Apr 2012 15:00:06 -0700
Message-Id: <1334181606-26777-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-mm@kvack.org

Add the filter function should_reclaim_mem_cgroup() under the common function
shrink_zone(). The later one is being called both from per-memcg reclaim as
well as global reclaim.

Today the softlimit takes effect only under global memory pressure. The memcgs
get free run above their softlimit until there is a global memory contention.
This patch doesn't change the semantics.

Under the global reclaim, we skip reclaiming from a memcg under its softlimit.
To prevent reclaim from trying too hard on hitting memcgs (above softlimit) w/
only hard-to-reclaim pages, the reclaim proirity is used to skip the softlimit
check. This is a trade-off of system performance and resource isolation.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |    7 +++++++
 mm/memcontrol.c            |   10 +++++++++-
 mm/vmscan.c                |   25 ++++++++++++++++++++++++-
 3 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index db71193..3d14f90 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -110,6 +110,8 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
 				   struct mem_cgroup_reclaim_cookie *);
 void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
 
+bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *);
+
 /*
  * For memory reclaim.
  */
@@ -295,6 +297,11 @@ static inline void mem_cgroup_iter_break(struct mem_cgroup *root,
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
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9a64093..cffcded 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -358,12 +358,12 @@ enum charge_type {
 static void mem_cgroup_get(struct mem_cgroup *memcg);
 static void mem_cgroup_put(struct mem_cgroup *memcg);
 
+static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
 /* Writing them here to avoid exposing memcg's inner layout */
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
 #include <net/sock.h>
 #include <net/ip.h>
 
-static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
 void sock_update_memcg(struct sock *sk)
 {
 	if (mem_cgroup_sockets_enabled) {
@@ -757,6 +757,14 @@ void mem_cgroup_iter_break(struct mem_cgroup *root,
 		css_put(&prev->css);
 }
 
+bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *mem)
+{
+	if (mem_cgroup_disabled() || mem_cgroup_is_root(mem))
+		return true;
+
+	return res_counter_soft_limit_excess(&mem->res) > 0;
+}
+
 /*
  * Iteration constructs for visiting all cgroups (under a tree).  If
  * loops are exited prematurely (break), mem_cgroup_iter_break() must
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5f98a34..2dbc300 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2133,6 +2133,27 @@ restart:
 	throttle_vm_writeout(sc->gfp_mask);
 }
 
+static bool should_reclaim_mem_cgroup(struct mem_cgroup *target_mem_cgroup,
+				      struct mem_cgroup *memcg,
+				      int priority)
+{
+	/* Reclaim from mem_cgroup if any of these conditions are met:
+	 * - This is a global reclaim
+	 * - reclaim priority is higher than DEF_PRIORITY - 3
+	 * - mem_cgroup exceeds its soft limit
+	 *
+	 * The priority check is a balance of how hard to preserve the pages
+	 * under softlimit. If the memcgs of the zone having trouble to reclaim
+	 * pages above their softlimit, we have to reclaim under softlimit
+	 * instead of burning more cpu cycles.
+	 */
+	if (target_mem_cgroup || priority <= DEF_PRIORITY - 3 ||
+			mem_cgroup_soft_limit_exceeded(memcg))
+		return true;
+
+	return false;
+}
+
 static void shrink_zone(int priority, struct zone *zone,
 			struct scan_control *sc)
 {
@@ -2150,7 +2171,9 @@ static void shrink_zone(int priority, struct zone *zone,
 			.zone = zone,
 		};
 
-		shrink_mem_cgroup_zone(priority, &mz, sc);
+		if (should_reclaim_mem_cgroup(root, memcg, priority))
+			shrink_mem_cgroup_zone(priority, &mz, sc);
+
 		/*
 		 * Limit reclaim has historically picked one memcg and
 		 * scanned it with decreasing priority levels until
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
