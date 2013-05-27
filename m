Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 1585A6B0034
	for <linux-mm@kvack.org>; Mon, 27 May 2013 13:13:37 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 1/3] memcg: track children in soft limit excess to improve soft limit
Date: Mon, 27 May 2013 19:13:09 +0200
Message-Id: <1369674791-13861-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1369674791-13861-1-git-send-email-mhocko@suse.cz>
References: <20130517160247.GA10023@cmpxchg.org>
 <1369674791-13861-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Soft limit reclaim has to check the whole reclaim hierarchy while doing
the first pass of the reclaim. This leads to a higher system time which
can be visible especially when there are many groups in the hierarchy.

- TODO put testing results here

This patch adds a per-memcg counter of children in excess. It also
restores MEM_CGROUP_TARGET_SOFTLIMIT into mem_cgroup_event_ratelimit for
a proper batching.
If a group crosses soft limit for the first time it increases parent's
children_in_excess up the hierarchy. The similarly if a group gets below
the limit it will decrease the counter. The transition phase is recorded
in soft_contributed flag.

mem_cgroup_soft_reclaim_eligible then uses this information to better
decide whether to skip the node or the whole subtree. The rule is
simple. Skip the node with a children in excess or skip the whole subtree
otherwise.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   51 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 981ee12..60b48bc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -136,6 +136,7 @@ static const char * const mem_cgroup_lru_names[] = {
  */
 enum mem_cgroup_events_target {
 	MEM_CGROUP_TARGET_THRESH,
+	MEM_CGROUP_TARGET_SOFTLIMIT,
 	MEM_CGROUP_TARGET_NUMAINFO,
 	MEM_CGROUP_NTARGETS,
 };
@@ -355,6 +356,10 @@ struct mem_cgroup {
 	atomic_t	numainfo_updating;
 #endif
 
+	spinlock_t soft_lock;
+	bool soft_contributed;
+	atomic_t children_in_excess;
+
 	/*
 	 * Per cgroup active and inactive list, similar to the
 	 * per zone LRU lists.
@@ -890,6 +895,9 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
 		case MEM_CGROUP_TARGET_THRESH:
 			next = val + THRESHOLDS_EVENTS_TARGET;
 			break;
+		case MEM_CGROUP_TARGET_SOFTLIMIT:
+			next = val + SOFTLIMIT_EVENTS_TARGET;
+			break;
 		case MEM_CGROUP_TARGET_NUMAINFO:
 			next = val + NUMAINFO_EVENTS_TARGET;
 			break;
@@ -902,6 +910,34 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
 	return false;
 }
 
+static void mem_cgroup_update_soft_limit(struct mem_cgroup *memcg)
+{
+	unsigned long long excess = res_counter_soft_limit_excess(&memcg->res);
+	struct mem_cgroup *parent = memcg;
+	int delta = 0;
+
+	spin_lock(&memcg->soft_lock);
+	if (excess) {
+		if (!memcg->soft_contributed) {
+			delta = 1;
+			memcg->soft_contributed = true;
+		}
+	} else {
+		if (memcg->soft_contributed) {
+			delta = -1;
+			memcg->soft_contributed = false;
+		}
+	}
+
+	/*
+	 * Necessary to update all ancestors when hierarchy is used
+	 * because their event counter is not touched.
+	 */
+	while (delta && (parent = parent_mem_cgroup(parent)))
+		atomic_add(delta, &parent->children_in_excess);
+	spin_unlock(&memcg->soft_lock);
+}
+
 /*
  * Check events in order.
  *
@@ -912,8 +948,11 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
 	/* threshold event is triggered in finer grain than soft limit */
 	if (unlikely(mem_cgroup_event_ratelimit(memcg,
 						MEM_CGROUP_TARGET_THRESH))) {
+		bool do_softlimit;
 		bool do_numainfo __maybe_unused;
 
+		do_softlimit = mem_cgroup_event_ratelimit(memcg,
+						MEM_CGROUP_TARGET_SOFTLIMIT);
 #if MAX_NUMNODES > 1
 		do_numainfo = mem_cgroup_event_ratelimit(memcg,
 						MEM_CGROUP_TARGET_NUMAINFO);
@@ -921,6 +960,8 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
 		preempt_enable();
 
 		mem_cgroup_threshold(memcg);
+		if (unlikely(do_softlimit))
+			mem_cgroup_update_soft_limit(memcg);
 #if MAX_NUMNODES > 1
 		if (unlikely(do_numainfo))
 			atomic_inc(&memcg->numainfo_events);
@@ -1894,6 +1935,9 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
  * hierarchy if
  * 	a) it is over its soft limit
  * 	b) any parent up the hierarchy is over its soft limit
+ *
+ * If the given group doesn't have any children over the limit then it
+ * doesn't make any sense to iterate its subtree.
  */
 enum mem_cgroup_filter_t
 mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
@@ -1915,6 +1959,8 @@ mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
 			break;
 	}
 
+	if (!atomic_read(&memcg->children_in_excess))
+		return SKIP_TREE;
 	return SKIP;
 }
 
@@ -6061,6 +6107,7 @@ mem_cgroup_css_alloc(struct cgroup *cont)
 	mutex_init(&memcg->thresholds_lock);
 	spin_lock_init(&memcg->move_lock);
 	vmpressure_init(&memcg->vmpressure);
+	spin_lock_init(&memcg->soft_lock);
 
 	return &memcg->css;
 
@@ -6150,6 +6197,10 @@ static void mem_cgroup_css_offline(struct cgroup *cont)
 
 	mem_cgroup_invalidate_reclaim_iterators(memcg);
 	mem_cgroup_reparent_charges(memcg);
+	if (memcg->soft_contributed) {
+		while ((memcg = parent_mem_cgroup(memcg)))
+			atomic_dec(&memcg->children_in_excess);
+	}
 	mem_cgroup_destroy_all_caches(memcg);
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
