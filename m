Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 363AE6B0026
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 02:25:48 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 4/8] memcg: rework soft limit reclaim
Date: Wed,  1 Jun 2011 08:25:15 +0200
Message-Id: <1306909519-7286-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, soft limit reclaim is entered from kswapd, where it selects
the memcg with the biggest soft limit excess in absolute bytes, and
reclaims pages from it with maximum aggressiveness (priority 0).

This has the following disadvantages:

    1. because of the aggressiveness, kswapd can be stalled on a memcg
    that is hard to reclaim from for a long time, sending the rest of
    the allocators into direct reclaim in the meantime.

    2. it only considers the biggest offender (in absolute bytes, no
    less, so very unhandy for setups with different-sized memcgs) and
    does not apply any pressure at all on other memcgs in excess.

    3. because it is only invoked from kswapd, the soft limit is
    meaningful during global memory pressure, but it is not taken into
    account during hierarchical target reclaim where it could allow
    prioritizing memcgs as well.  So while it does hierarchical
    reclaim once triggered, it is not a truly hierarchical mechanism.

Here is a different approach.  Instead of having a soft limit reclaim
cycle separate from the rest of reclaim, this patch ensures that each
time a group of memcgs is reclaimed - be it because of global memory
pressure or because of a hard limit - memcgs that exceed their soft
limit, or contribute to the soft limit excess of one their parents,
are reclaimed from at a higher priority than their siblings.

This results in the following:

    1. all relevant memcgs are scanned with increasing priority during
    memory pressure.  The primary goal is to free pages, not to punish
    soft limit offenders.

    2. increased pressure is applied to all memcgs in excess of their
    soft limit, not only the biggest offender.

    3. the soft limit becomes meaningful for target reclaim as well,
    where it allows prioritizing children of a hierarchy when the
    parent hits its limit.

    4. direct reclaim now also applies increased soft limit pressure,
    not just kswapd anymore.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |    7 +++++++
 mm/memcontrol.c            |   26 ++++++++++++++++++++++++++
 mm/vmscan.c                |    8 ++++++--
 3 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 8f402b9..7d99e87 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -104,6 +104,7 @@ extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
 struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *,
 					     struct mem_cgroup *);
 void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *, struct mem_cgroup *);
+bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *, struct mem_cgroup *);
 
 /*
  * For memory reclaim.
@@ -345,6 +346,12 @@ static inline void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *r,
 {
 }
 
+static inline bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *root,
+						  struct mem_cgroup *mem)
+{
+	return false;
+}
+
 static inline void
 mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 983efe4..94f77cc3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1460,6 +1460,32 @@ void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *root,
 		css_put(&mem->css);
 }
 
+/**
+ * mem_cgroup_soft_limit_exceeded - check if a memcg (hierarchically)
+ *                                  exceeds a soft limit
+ * @root: highest ancestor of @mem to consider
+ * @mem: memcg to check for excess
+ *
+ * The function indicates whether @mem has exceeded its own soft
+ * limit, or contributes to the soft limit excess of one of its
+ * parents in the hierarchy below @root.
+ */
+bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *root,
+				    struct mem_cgroup *mem)
+{
+	for (;;) {
+		if (mem == root_mem_cgroup)
+			return false;
+		if (res_counter_soft_limit_excess(&mem->res))
+			return true;
+		if (mem == root)
+			return false;		
+		mem = parent_mem_cgroup(mem);
+		if (!mem)
+			return false;
+	}
+}
+
 static unsigned long mem_cgroup_reclaim(struct mem_cgroup *mem,
 					gfp_t gfp_mask,
 					unsigned long flags)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c7d4b44..0163840 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1988,9 +1988,13 @@ static void shrink_zone(int priority, struct zone *zone,
 		unsigned long reclaimed = sc->nr_reclaimed;
 		unsigned long scanned = sc->nr_scanned;
 		unsigned long nr_reclaimed;
+		int epriority = priority;
+
+		if (mem_cgroup_soft_limit_exceeded(root, mem))
+			epriority -= 1;
 
 		sc->mem_cgroup = mem;
-		do_shrink_zone(priority, zone, sc);
+		do_shrink_zone(epriority, zone, sc);
 		mem_cgroup_count_reclaim(mem, current_is_kswapd(),
 					 mem != root, /* limit or hierarchy? */
 					 sc->nr_scanned - scanned,
@@ -2480,7 +2484,7 @@ loop_again:
 			 * Call soft limit reclaim before calling shrink_zone.
 			 * For now we ignore the return value
 			 */
-			mem_cgroup_soft_limit_reclaim(zone, order, sc.gfp_mask);
+			//mem_cgroup_soft_limit_reclaim(zone, order, sc.gfp_mask);
 
 			/*
 			 * We put equal pressure on every zone, unless
-- 
1.7.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
