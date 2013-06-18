Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id E94416B003A
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 08:10:26 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v5 5/8] memcg: track children in soft limit excess to improve soft limit
Date: Tue, 18 Jun 2013 14:09:44 +0200
Message-Id: <1371557387-22434-6-git-send-email-mhocko@suse.cz>
In-Reply-To: <1371557387-22434-1-git-send-email-mhocko@suse.cz>
References: <1371557387-22434-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@gmail.com>

Soft limit reclaim has to check the whole reclaim hierarchy while doing
the first pass of the reclaim. This leads to a higher system time which
can be visible especially when there are many groups in the hierarchy.

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

This has been tested by a stream IO (dd if=/dev/zero of=file with
4*MemTotal size) which is quite sensitive to overhead during reclaim.
The load is running in a group with soft limit set to 0 and without any
limit. Apart from that there was a hierarchy with ~500, 2k and 8k groups
(two groups on each level) without any pages in them. base denotes to
the kernel on which the whole series is based on, rework is the kernel
before this patch and reworkoptim is with this patch applied:

* Run with soft limit set to 0
Elapsed
0-0-limit/base: min: 88.21 max: 94.61 avg: 91.73 std: 2.65 runs: 3
0-0-limit/rework: min: 76.05 [86.2%] max: 79.08 [83.6%] avg: 77.84 [84.9%] std: 1.30 runs: 3
0-0-limit/reworkoptim: min: 77.98 [88.4%] max: 80.36 [84.9%] avg: 78.92 [86.0%] std: 1.03 runs: 3
System
0.5k-0-limit/base: min: 34.86 max: 36.42 avg: 35.89 std: 0.73 runs: 3
0.5k-0-limit/rework: min: 43.26 [124.1%] max: 48.95 [134.4%] avg: 46.09 [128.4%] std: 2.32 runs: 3
0.5k-0-limit/reworkoptim: min: 46.98 [134.8%] max: 50.98 [140.0%] avg: 48.49 [135.1%] std: 1.77 runs: 3
Elapsed
0.5k-0-limit/base: min: 88.50 max: 97.52 avg: 93.92 std: 3.90 runs: 3
0.5k-0-limit/rework: min: 75.92 [85.8%] max: 78.45 [80.4%] avg: 77.34 [82.3%] std: 1.06 runs: 3
0.5k-0-limit/reworkoptim: min: 75.79 [85.6%] max: 79.37 [81.4%] avg: 77.55 [82.6%] std: 1.46 runs: 3
System
2k-0-limit/base: min: 34.57 max: 37.65 avg: 36.34 std: 1.30 runs: 3
2k-0-limit/rework: min: 64.17 [185.6%] max: 68.20 [181.1%] avg: 66.21 [182.2%] std: 1.65 runs: 3
2k-0-limit/reworkoptim: min: 49.78 [144.0%] max: 52.99 [140.7%] avg: 51.00 [140.3%] std: 1.42 runs: 3
Elapsed
2k-0-limit/base: min: 92.61 max: 97.83 avg: 95.03 std: 2.15 runs: 3
2k-0-limit/rework: min: 78.33 [84.6%] max: 84.08 [85.9%] avg: 81.09 [85.3%] std: 2.35 runs: 3
2k-0-limit/reworkoptim: min: 75.72 [81.8%] max: 78.57 [80.3%] avg: 76.73 [80.7%] std: 1.30 runs: 3
System
8k-0-limit/base: min: 39.78 max: 42.09 avg: 41.09 std: 0.97 runs: 3
8k-0-limit/rework: min: 200.86 [504.9%] max: 265.42 [630.6%] avg: 241.80 [588.5%] std: 29.06 runs: 3
8k-0-limit/reworkoptim: min: 53.70 [135.0%] max: 54.89 [130.4%] avg: 54.43 [132.5%] std: 0.52 runs: 3
Elapsed
8k-0-limit/base: min: 95.11 max: 98.61 avg: 96.81 std: 1.43 runs: 3
8k-0-limit/rework: min: 246.96 [259.7%] max: 331.47 [336.1%] avg: 301.32 [311.2%] std: 38.52 runs: 3
8k-0-limit/reworkoptim: min: 76.79 [80.7%] max: 81.71 [82.9%] avg: 78.97 [81.6%] std: 2.05 runs: 3

System time is increased by 30-40% but it is reduced a lot comparing
to kernel without this patch. The higher time can be explained by the
fact that the original soft reclaim scanned at priority 0 so it was much
more effective for this workload (which is basically touch once and
writeback). The Elapsed time looks better though (~20%).

* Run with no soft limit set
System
0-no-limit/base: min: 42.18 max: 50.38 avg: 46.44 std: 3.36 runs: 3
0-no-limit/rework: min: 40.57 [96.2%] max: 47.04 [93.4%] avg: 43.82 [94.4%] std: 2.64 runs: 3
0-no-limit/reworkoptim: min: 40.45 [95.9%] max: 45.28 [89.9%] avg: 42.10 [90.7%] std: 2.25 runs: 3
Elapsed
0-no-limit/base: min: 75.97 max: 78.21 avg: 76.87 std: 0.96 runs: 3
0-no-limit/rework: min: 75.59 [99.5%] max: 80.73 [103.2%] avg: 77.64 [101.0%] std: 2.23 runs: 3
0-no-limit/reworkoptim: min: 77.85 [102.5%] max: 82.42 [105.4%] avg: 79.64 [103.6%] std: 1.99 runs: 3
System
0.5k-no-limit/base: min: 44.54 max: 46.93 avg: 46.12 std: 1.12 runs: 3
0.5k-no-limit/rework: min: 42.09 [94.5%] max: 46.16 [98.4%] avg: 43.92 [95.2%] std: 1.69 runs: 3
0.5k-no-limit/reworkoptim: min: 42.47 [95.4%] max: 45.67 [97.3%] avg: 44.06 [95.5%] std: 1.31 runs: 3
Elapsed
0.5k-no-limit/base: min: 78.26 max: 81.49 avg: 79.65 std: 1.36 runs: 3
0.5k-no-limit/rework: min: 77.01 [98.4%] max: 80.43 [98.7%] avg: 78.30 [98.3%] std: 1.52 runs: 3
0.5k-no-limit/reworkoptim: min: 76.13 [97.3%] max: 77.87 [95.6%] avg: 77.18 [96.9%] std: 0.75 runs: 3
System
2k-no-limit/base: min: 62.96 max: 69.14 avg: 66.14 std: 2.53 runs: 3
2k-no-limit/rework: min: 76.01 [120.7%] max: 81.06 [117.2%] avg: 78.17 [118.2%] std: 2.12 runs: 3
2k-no-limit/reworkoptim: min: 62.57 [99.4%] max: 66.10 [95.6%] avg: 64.53 [97.6%] std: 1.47 runs: 3
Elapsed
2k-no-limit/base: min: 76.47 max: 84.22 avg: 79.12 std: 3.60 runs: 3
2k-no-limit/rework: min: 89.67 [117.3%] max: 93.26 [110.7%] avg: 91.10 [115.1%] std: 1.55 runs: 3
2k-no-limit/reworkoptim: min: 76.94 [100.6%] max: 79.21 [94.1%] avg: 78.45 [99.2%] std: 1.07 runs: 3
System
8k-no-limit/base: min: 104.74 max: 151.34 avg: 129.21 std: 19.10 runs: 3
8k-no-limit/rework: min: 205.23 [195.9%] max: 285.94 [188.9%] avg: 258.98 [200.4%] std: 38.01 runs: 3
8k-no-limit/reworkoptim: min: 161.16 [153.9%] max: 184.54 [121.9%] avg: 174.52 [135.1%] std: 9.83 runs: 3
Elapsed
8k-no-limit/base: min: 125.43 max: 181.00 avg: 154.81 std: 22.80 runs: 3
8k-no-limit/rework: min: 254.05 [202.5%] max: 355.67 [196.5%] avg: 321.46 [207.6%] std: 47.67 runs: 3
8k-no-limit/reworkoptim: min: 193.77 [154.5%] max: 222.72 [123.0%] avg: 210.18 [135.8%] std: 12.13 runs: 3

Both System and Elapsed are in stdev with the base kernel for all
configurations except for 8k where both System and Elapsed are up by
35%. I do not have a good explanation for this because there is no soft
reclaim pass going on as no group is above the limit which is checked in
mem_cgroup_should_soft_reclaim.

Then I have tested kernel build with the same configuration to see the
behavior with a more general behavior.

* Soft limit set to 0 for the build
System
0-0-limit/base: min: 242.70 max: 245.17 avg: 243.85 std: 1.02 runs: 3
0-0-limit/rework min: 237.86 [98.0%] max: 240.22 [98.0%] avg: 239.00 [98.0%] std: 0.97 runs: 3
0-0-limit/reworkoptim: min: 241.11 [99.3%] max: 243.53 [99.3%] avg: 242.01 [99.2%] std: 1.08 runs: 3
Elapsed
0-0-limit/base: min: 348.48 max: 360.86 avg: 356.04 std: 5.41 runs: 3
0-0-limit/rework min: 286.95 [82.3%] max: 290.26 [80.4%] avg: 288.27 [81.0%] std: 1.43 runs: 3
0-0-limit/reworkoptim: min: 286.55 [82.2%] max: 289.00 [80.1%] avg: 287.69 [80.8%] std: 1.01 runs: 3
System
0.5k-0-limit/base: min: 251.77 max: 254.41 avg: 252.70 std: 1.21 runs: 3
0.5k-0-limit/rework min: 286.44 [113.8%] max: 289.30 [113.7%] avg: 287.60 [113.8%] std: 1.23 runs: 3
0.5k-0-limit/reworkoptim: min: 252.18 [100.2%] max: 253.16 [99.5%] avg: 252.62 [100.0%] std: 0.41 runs: 3
Elapsed
0.5k-0-limit/base: min: 347.83 max: 353.06 avg: 350.04 std: 2.21 runs: 3
0.5k-0-limit/rework min: 290.19 [83.4%] max: 295.62 [83.7%] avg: 293.12 [83.7%] std: 2.24 runs: 3
0.5k-0-limit/reworkoptim: min: 293.91 [84.5%] max: 294.87 [83.5%] avg: 294.29 [84.1%] std: 0.42 runs: 3
System
2k-0-limit/base: min: 263.05 max: 271.52 avg: 267.94 std: 3.58 runs: 3
2k-0-limit/rework min: 458.99 [174.5%] max: 468.31 [172.5%] avg: 464.45 [173.3%] std: 3.97 runs: 3
2k-0-limit/reworkoptim: min: 267.10 [101.5%] max: 279.38 [102.9%] avg: 272.78 [101.8%] std: 5.05 runs: 3
Elapsed
2k-0-limit/base: min: 372.33 max: 379.32 avg: 375.47 std: 2.90 runs: 3
2k-0-limit/rework min: 334.40 [89.8%] max: 339.52 [89.5%] avg: 337.44 [89.9%] std: 2.20 runs: 3
2k-0-limit/reworkoptim: min: 301.47 [81.0%] max: 319.19 [84.1%] avg: 307.90 [82.0%] std: 8.01 runs: 3
System
8k-0-limit/base: min: 320.50 max: 332.10 avg: 325.46 std: 4.88 runs: 3
8k-0-limit/rework min: 1115.76 [348.1%] max: 1165.66 [351.0%] avg: 1132.65 [348.0%] std: 23.34 runs: 3
8k-0-limit/reworkoptim: min: 403.75 [126.0%] max: 409.22 [123.2%] avg: 406.16 [124.8%] std: 2.28 runs: 3
Elapsed
8k-0-limit/base: min: 475.48 max: 585.19 avg: 525.54 std: 45.30 runs: 3
8k-0-limit/rework min: 616.25 [129.6%] max: 625.90 [107.0%] avg: 620.68 [118.1%] std: 3.98 runs: 3
8k-0-limit/reworkoptim: min: 420.18 [88.4%] max: 428.28 [73.2%] avg: 423.05 [80.5%] std: 3.71 runs: 3

Apart from 8k the system time is comparable with the base kernel while
Elapsed is up to 20% better with all configurations.

* No soft limit set
System
0-no-limit/base: min: 234.76 max: 237.42 avg: 236.25 std: 1.11 runs: 3
0-no-limit/rework min: 233.09 [99.3%] max: 238.65 [100.5%] avg: 236.09 [99.9%] std: 2.29 runs: 3
0-no-limit/reworkoptim: min: 236.12 [100.6%] max: 240.53 [101.3%] avg: 237.94 [100.7%] std: 1.88 runs: 3
Elapsed
0-no-limit/base: min: 288.52 max: 295.42 avg: 291.29 std: 2.98 runs: 3
0-no-limit/rework min: 283.17 [98.1%] max: 284.33 [96.2%] avg: 283.78 [97.4%] std: 0.48 runs: 3
0-no-limit/reworkoptim: min: 288.50 [100.0%] max: 290.79 [98.4%] avg: 289.78 [99.5%] std: 0.95 runs: 3
System
0.5k-no-limit/base: min: 286.51 max: 293.23 avg: 290.21 std: 2.78 runs: 3
0.5k-no-limit/rework min: 291.69 [101.8%] max: 294.38 [100.4%] avg: 292.97 [101.0%] std: 1.10 runs: 3
0.5k-no-limit/reworkoptim: min: 277.05 [96.7%] max: 288.76 [98.5%] avg: 284.17 [97.9%] std: 5.11 runs: 3
Elapsed
0.5k-no-limit/base: min: 294.94 max: 298.92 avg: 296.47 std: 1.75 runs: 3
0.5k-no-limit/rework min: 292.55 [99.2%] max: 294.21 [98.4%] avg: 293.55 [99.0%] std: 0.72 runs: 3
0.5k-no-limit/reworkoptim: min: 294.41 [99.8%] max: 301.67 [100.9%] avg: 297.78 [100.4%] std: 2.99 runs: 3
System
2k-no-limit/base: min: 443.41 max: 466.66 avg: 457.66 std: 10.19 runs: 3
2k-no-limit/rework min: 490.11 [110.5%] max: 516.02 [110.6%] avg: 501.42 [109.6%] std: 10.83 runs: 3
2k-no-limit/reworkoptim: min: 435.25 [98.2%] max: 458.11 [98.2%] avg: 446.73 [97.6%] std: 9.33 runs: 3
Elapsed
2k-no-limit/base: min: 330.85 max: 333.75 avg: 332.52 std: 1.23 runs: 3
2k-no-limit/rework min: 343.06 [103.7%] max: 349.59 [104.7%] avg: 345.95 [104.0%] std: 2.72 runs: 3
2k-no-limit/reworkoptim: min: 330.01 [99.7%] max: 333.92 [100.1%] avg: 332.22 [99.9%] std: 1.64 runs: 3
System
8k-no-limit/base: min: 1175.64 max: 1259.38 avg: 1222.39 std: 34.88 runs: 3
8k-no-limit/rework min: 1226.31 [104.3%] max: 1241.60 [98.6%] avg: 1233.74 [100.9%] std: 6.25 runs: 3
8k-no-limit/reworkoptim: min: 1023.45 [87.1%] max: 1056.74 [83.9%] avg: 1038.92 [85.0%] std: 13.69 runs: 3
Elapsed
8k-no-limit/base: min: 613.36 max: 619.60 avg: 616.47 std: 2.55 runs: 3
8k-no-limit/rework min: 627.56 [102.3%] max: 642.33 [103.7%] avg: 633.44 [102.8%] std: 6.39 runs: 3
8k-no-limit/reworkoptim: min: 545.89 [89.0%] max: 555.36 [89.6%] avg: 552.06 [89.6%] std: 4.37 runs: 3

and these numbers look good as well. System time is around 100%
(suprisingly better for the 8k case) and Elapsed is copies that trend.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 71 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 71 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1364ca5..2a06d5a 100644
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
@@ -350,6 +351,22 @@ struct mem_cgroup {
 	atomic_t	numainfo_events;
 	atomic_t	numainfo_updating;
 #endif
+	/*
+	 * Protects soft_contributed transitions.
+	 * See mem_cgroup_update_soft_limit
+	 */
+	spinlock_t soft_lock;
+
+	/*
+	 * If true then this group has increased parents' children_in_excess
+         * when it got over the soft limit.
+	 * When a group falls bellow the soft limit, parents' children_in_excess
+	 * is decreased and soft_contributed changed to false.
+	 */
+	bool soft_contributed;
+
+	/* Number of children that are in soft limit excess */
+	atomic_t children_in_excess;
 
 	struct mem_cgroup_per_node *nodeinfo[0];
 	/* WARNING: nodeinfo must be the last member here */
@@ -880,6 +897,9 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
 		case MEM_CGROUP_TARGET_THRESH:
 			next = val + THRESHOLDS_EVENTS_TARGET;
 			break;
+		case MEM_CGROUP_TARGET_SOFTLIMIT:
+			next = val + SOFTLIMIT_EVENTS_TARGET;
+			break;
 		case MEM_CGROUP_TARGET_NUMAINFO:
 			next = val + NUMAINFO_EVENTS_TARGET;
 			break;
@@ -893,6 +913,42 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
 }
 
 /*
+ * Called from rate-limitted memcg_check_events when enough
+ * MEM_CGROUP_TARGET_SOFTLIMIT events are accumulated and it makes sure
+ * that all the parents up the hierarchy will be noticed that this group
+ * is in excess or that it is not in excess anymore. mmecg->soft_contributed
+ * makes the transition a single action whenever the state flips from one to
+ * other.
+ */
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
+/*
  * Check events in order.
  *
  */
@@ -902,8 +958,11 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
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
@@ -911,6 +970,8 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
 		preempt_enable();
 
 		mem_cgroup_threshold(memcg);
+		if (unlikely(do_softlimit))
+			mem_cgroup_update_soft_limit(memcg);
 #if MAX_NUMNODES > 1
 		if (unlikely(do_numainfo))
 			atomic_inc(&memcg->numainfo_events);
@@ -1918,6 +1979,9 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
  * hierarchy if
  * 	a) it is over its soft limit
  * 	b) any parent up the hierarchy is over its soft limit
+ *
+ * If the given group doesn't have any children over the limit then it
+ * doesn't make any sense to iterate its subtree.
  */
 enum mem_cgroup_filter_t
 mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
@@ -1939,6 +2003,8 @@ mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
 			break;
 	}
 
+	if (!atomic_read(&memcg->children_in_excess))
+		return SKIP_TREE;
 	return SKIP;
 }
 
@@ -6093,6 +6159,7 @@ mem_cgroup_css_alloc(struct cgroup *cont)
 	mutex_init(&memcg->thresholds_lock);
 	spin_lock_init(&memcg->move_lock);
 	vmpressure_init(&memcg->vmpressure);
+	spin_lock_init(&memcg->soft_lock);
 
 	return &memcg->css;
 
@@ -6182,6 +6249,10 @@ static void mem_cgroup_css_offline(struct cgroup *cont)
 
 	mem_cgroup_invalidate_reclaim_iterators(memcg);
 	mem_cgroup_reparent_charges(memcg);
+	if (memcg->soft_contributed) {
+		while ((memcg = parent_mem_cgroup(memcg)))
+			atomic_dec(&memcg->children_in_excess);
+	}
 	mem_cgroup_destroy_all_caches(memcg);
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
