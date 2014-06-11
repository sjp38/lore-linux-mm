Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 92AC66B013B
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 04:00:59 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id n15so563028wiw.11
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 01:00:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r3si40523633wjw.87.2014.06.11.01.00.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 01:00:56 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 2/2] memcg: Allow guarantee reclaim
Date: Wed, 11 Jun 2014 10:00:24 +0200
Message-Id: <1402473624-13827-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1402473624-13827-1-git-send-email-mhocko@suse.cz>
References: <20140611075729.GA4520@dhcp22.suse.cz>
 <1402473624-13827-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <klamm@yandex-team.ru>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Some users (e.g. Google) would like to have stronger semantic than low
limit offers currently. The fallback mode is not desirable and they
prefer hitting OOM killer rather than ignoring low limit for protected
groups.

There are other possible usecases which can benefit from hard
guarantees. There are loads which will simply start trashing if the
memory working set drops under certain level and it is more appropriate
to simply kill and restart such a load if the required memory cannot
be provided. Another usecase would be a hard memory isolation for
containers.

The min_limit is initialized to 0 and it has precedence over low_limit.
If the reclaim is not able to find any memcg in the reclaimed hierarchy
above min_limit then OOM killer is triggered to resolve the situation.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 Documentation/cgroups/memory.txt | 26 ++++++++++++++++++--------
 include/linux/memcontrol.h       | 14 ++++++++------
 include/linux/res_counter.h      | 32 ++++++++++++++++++++++++++++++--
 mm/memcontrol.c                  | 18 +++++++++++-------
 mm/oom_kill.c                    |  6 ++++--
 mm/vmscan.c                      | 38 ++++++++++++++++++++++----------------
 6 files changed, 93 insertions(+), 41 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index bf895d7e1363..6929a06c9e5d 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -61,6 +61,7 @@ Brief summary of control files.
  memory.low_limit_breached	 # number of times low_limit has been
 				 # ignored and the cgroup reclaimed even
 				 # when it was above the limit
+ memory.min_limit_in_bytes	 # set/show min limit for memory reclaim
  memory.memsw.limit_in_bytes	 # set/show limit of memory+Swap usage
  memory.failcnt			 # show the number of memory usage hits limits
  memory.memsw.failcnt		 # show the number of memory+Swap hits limits
@@ -248,14 +249,23 @@ global VM. Cgroups can get reclaimed basically under two conditions
    to select and kill the bulkiest task in the hiearchy. (See 10. OOM Control
    below.)
 
-Groups might be also protected from both global and limit reclaim by
-low_limit_in_bytes knob. If the limit is non-zero the reclaim logic
-doesn't include groups (and their subgroups - see 6. Hierarchy support)
-which are below the low limit if there is other eligible cgroup in the
-reclaimed hierarchy. If all groups which participate reclaim are under
-their low limits then all of them are reclaimed and the low limit is
-ignored. low_limit_breached counter in memory.stat file can be checked
-to see how many times such an event occurred.
+Groups might be also protected from both global and limit reclaim
+by low_limit_in_bytes and min_limit_in_bytes knobs. The first one
+provides an optimistic reclaim protection while the later one provides
+hard memory reclaim protection guarantee. Both limits are 0 by default
+and min watermark has always precedence to low watermark.
+
+If the low limit is non-zero the reclaim logic doesn't include
+groups (and their subgroups - see 6. Hierarchy support) which are
+below low_limit if there is other eligible cgroup in the reclaimed
+hierarchy. If all groups which participate reclaim are under their low
+limits then all of them are reclaimed and the low limit is ignored.
+low_limit_breached counter in memory.stat file can be checked to see how
+many times such an event occurred.
+
+If, however, all the groups under reclaimed hierarchy are under their min
+limits then no reclaim is done and OOM killer is triggered to resolve the
+situation. In other words low_limit is never breached by the reclaim.
 
 Note2: When panic_on_oom is set to "2", the whole system will panic.
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5e2ca2163b12..ddb96729a6b6 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -93,10 +93,11 @@ bool task_in_mem_cgroup(struct task_struct *task,
 			const struct mem_cgroup *memcg);
 
 extern bool mem_cgroup_within_guarantee(struct mem_cgroup *memcg,
-		struct mem_cgroup *root);
+		struct mem_cgroup *root, bool soft_guarantee);
 
-extern void mem_cgroup_guarantee_breached(struct mem_cgroup *memcg);
-extern bool mem_cgroup_all_within_guarantee(struct mem_cgroup *root);
+extern void mem_cgroup_soft_guarantee_breached(struct mem_cgroup *memcg);
+extern bool mem_cgroup_all_within_guarantee(struct mem_cgroup *root,
+		bool soft_guarantee);
 
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
@@ -295,14 +296,15 @@ static inline struct lruvec *mem_cgroup_page_lruvec(struct page *page,
 }
 
 static inline bool mem_cgroup_within_guarantee(struct mem_cgroup *memcg,
-		struct mem_cgroup *root)
+		struct mem_cgroup *root, bool soft_guarantee)
 {
 	return false;
 }
-static inline  void mem_cgroup_guarantee_breached(struct mem_cgroup *memcg)
+static inline  void mem_cgroup_soft_guarantee_breached(struct mem_cgroup *memcg)
 {
 }
-static inline bool mem_cgroup_all_within_guarantee(struct mem_cgroup *root)
+static inline bool mem_cgroup_all_within_guarantee(struct mem_cgroup *root,
+		bool soft_guarantee)
 {
 	return false;
 }
diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index b810855024f9..21dff6507aa7 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -40,11 +40,17 @@ struct res_counter {
 	 */
 	unsigned long long soft_limit;
 	/*
-	 * the limit under which the usage cannot be pushed
-	 * due to external pressure.
+	 * the limit under which the usage shouldn't be pushed
+	 * due to external pressure if it is possible.
 	 */
 	unsigned long long low_limit;
 	/*
+	 * the limit under with the usage cannot be pushed
+	 * due to external pressure.
+	 */
+	unsigned long long min_limit;
+
+	/*
 	 * the number of unsuccessful attempts to consume the resource
 	 */
 	unsigned long long failcnt;
@@ -203,6 +209,28 @@ res_counter_low_limit_excess(struct res_counter *cnt)
 	return excess;
 }
 
+/**
+ * Get the difference between the usage and the min limit
+ * @cnt: The counter
+ *
+ * Returns 0 if usage is less than or equal to min limit
+ * The difference between usage and min limit, otherwise.
+ */
+static inline unsigned long long
+res_counter_min_limit_excess(struct res_counter *cnt)
+{
+	unsigned long long excess;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	if (cnt->usage <= cnt->min_limit)
+		excess = 0;
+	else
+		excess = cnt->usage - cnt->min_limit;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return excess;
+}
+
 static inline void res_counter_reset_max(struct res_counter *cnt)
 {
 	unsigned long flags;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7f62b6533f60..26f137175f1c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2816,19 +2816,23 @@ static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
  * memory guarantee
  * @memcg: target memcg for the reclaim
  * @root: root of the reclaim hierarchy (null for the global reclaim)
+ * @soft_guarantee: is the guarantee soft (allows fallback).
  *
- * The given group is within its reclaim gurantee if it is below its low limit
- * or the same applies for any parent up the hierarchy until root (including).
+ * The given group is within its reclaim gurantee if it is below its min limit
+ * and if soft_guarantee is true then also below its low limit.
+ * Or the same applies for any parent up the hierarchy until root (including).
  * Such a group might be excluded from the reclaim.
  */
 bool mem_cgroup_within_guarantee(struct mem_cgroup *memcg,
-		struct mem_cgroup *root)
+		struct mem_cgroup *root, bool soft_guarantee)
 {
 	if (mem_cgroup_disabled())
 		return false;
 
 	do {
-		if (!res_counter_low_limit_excess(&memcg->res))
+		if (!res_counter_min_limit_excess(&memcg->res))
+			return true;
+		if (soft_guarantee && !res_counter_low_limit_excess(&memcg->res))
 			return true;
 		if (memcg == root)
 			break;
@@ -2838,17 +2842,17 @@ bool mem_cgroup_within_guarantee(struct mem_cgroup *memcg,
 	return false;
 }
 
-void mem_cgroup_guarantee_breached(struct mem_cgroup *memcg)
+void mem_cgroup_soft_guarantee_breached(struct mem_cgroup *memcg)
 {
 	this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_LOW_LIMIT_FALLBACK]);
 }
 
-bool mem_cgroup_all_within_guarantee(struct mem_cgroup *root)
+bool mem_cgroup_all_within_guarantee(struct mem_cgroup *root, bool soft_guarantee)
 {
 	struct mem_cgroup *iter;
 
 	for_each_mem_cgroup_tree(iter, root)
-		if (!mem_cgroup_within_guarantee(iter, root)) {
+		if (!mem_cgroup_within_guarantee(iter, root, soft_guarantee)) {
 			mem_cgroup_iter_break(root, iter);
 			return false;
 		}
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3291e82d4352..e44b471af476 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -392,9 +392,11 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 {
 	task_lock(current);
 	pr_warning("%s invoked oom-killer: gfp_mask=0x%x, order=%d, "
-		"oom_score_adj=%hd\n",
+		"oom_score_adj=%hd%s\n",
 		current->comm, gfp_mask, order,
-		current->signal->oom_score_adj);
+		current->signal->oom_score_adj,
+		mem_cgroup_all_within_guarantee(memcg, false) ?
+		" because all groups are withing min_limit guarantee":"");
 	cpuset_print_task_mems_allowed(current);
 	task_unlock(current);
 	dump_stack();
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 99137aecd95f..8e844bd42c51 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2220,13 +2220,12 @@ static inline bool should_continue_reclaim(struct zone *zone,
  *
  * @zone: zone to shrink
  * @sc: scan control with additional reclaim parameters
- * @honor_memcg_guarantee: do not reclaim memcgs which are within their memory
- * guarantee
+ * @soft_guarantee: Use soft guarantee reclaim target for memcg reclaim.
  *
  * Returns the number of reclaimed memcgs.
  */
 static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
-		bool honor_memcg_guarantee)
+		bool soft_guarantee)
 {
 	unsigned long nr_reclaimed, nr_scanned;
 	unsigned nr_scanned_groups = 0;
@@ -2245,11 +2244,10 @@ static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
 		memcg = mem_cgroup_iter(root, NULL, &reclaim);
 		do {
 			struct lruvec *lruvec;
-			bool within_guarantee;
 
 			/* Memcg might be protected from the reclaim */
-			within_guarantee = mem_cgroup_within_guarantee(memcg, root);
-			if (honor_memcg_guarantee && within_guarantee) {
+			if (mem_cgroup_within_guarantee(memcg, root,
+						soft_guarantee)) {
 				/*
 				 * It would be more optimal to skip the memcg
 				 * subtree now but we do not have a memcg iter
@@ -2259,8 +2257,8 @@ static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
 				continue;
 			}
 
-			if (within_guarantee)
-				mem_cgroup_guarantee_breached(memcg);
+			if (!soft_guarantee)
+				mem_cgroup_soft_guarantee_breached(memcg);
 
 			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 			nr_scanned_groups++;
@@ -2297,20 +2295,27 @@ static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
 
 static void shrink_zone(struct zone *zone, struct scan_control *sc)
 {
-	bool honor_guarantee = true;
+	bool soft_guarantee = true;
 
-	while (!__shrink_zone(zone, sc, honor_guarantee)) {
+	while (!__shrink_zone(zone, sc, soft_guarantee)) {
 		/*
 		 * The previous round of reclaim didn't find anything to scan
 		 * because
-		 * a) the whole reclaimed hierarchy is within guarantee so
-		 *    we fallback to ignore the guarantee because other option
-		 *    would be the OOM
+		 * a) the whole reclaimed hierarchy is within soft guarantee so
+		 *    we are switching to the hard guarantee reclaim target
 		 * b) multiple reclaimers are racing and so the first round
 		 *    should be retried
 		 */
-		if (mem_cgroup_all_within_guarantee(sc->target_mem_cgroup))
-			honor_guarantee = false;
+		if (mem_cgroup_all_within_guarantee(sc->target_mem_cgroup,
+					soft_guarantee)) {
+			/*
+			 * Nothing to reclaim even with hard guarantees so
+			 * we have to OOM
+			 */
+			if (!soft_guarantee)
+				break;
+			soft_guarantee = false;
+		}
 	}
 }
 
@@ -2574,7 +2579,8 @@ out:
 	 * If the target memcg is not eligible for reclaim then we have no option
 	 * but OOM
 	 */
-	if (!sc->nr_scanned && mem_cgroup_all_within_guarantee(sc->target_mem_cgroup))
+	if (!sc->nr_scanned &&
+			mem_cgroup_all_within_guarantee(sc->target_mem_cgroup, false))
 		return 0;
 
 	/* top priority shrink_zones still had more to do? don't OOM, then */
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
