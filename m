Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 42CBE90010B
	for <linux-mm@kvack.org>; Thu, 12 May 2011 14:47:53 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [RFC PATCH 2/4] Organize memcgs over soft limit in round-robin.
Date: Thu, 12 May 2011 11:47:10 -0700
Message-Id: <1305226032-21448-3-git-send-email-yinghan@google.com>
In-Reply-To: <1305226032-21448-1-git-send-email-yinghan@google.com>
References: <1305226032-21448-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

Based on the discussion from LSF, we came up with the design where all the
memcgs are stored in link-list and reclaims happen in a round-robin fashion.

We build per-zone memcg list which links mem_cgroup_per_zone for all memcgs
exceeded their soft_limit and have memory allocated on the zone.

1. new memcg is examed and inserted once per 1024 increments of
mem_cgroup_commit_charge().

2. under global memory pressure, we iterate the list and try to reclaim a
target number of pages from each memcg.

3. move the memcg to the tail after finishing the reclaim.

4. remove the memcg from the list if the usage dropped below the soft_limit.

Signed-off-by: Ying Han <yinghan@google.com>
---
 mm/memcontrol.c |  159 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 159 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9da3ecf..1360de6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -136,6 +136,9 @@ struct mem_cgroup_per_zone {
 	unsigned long		count[NR_LRU_LISTS];
 
 	struct zone_reclaim_stat reclaim_stat;
+	struct list_head	soft_limit_list;
+	unsigned long long	usage_in_excess;
+	bool			on_list;
 	struct mem_cgroup	*mem;		/* Back pointer, we cannot */
 						/* use container_of	   */
 };
@@ -150,6 +153,25 @@ struct mem_cgroup_lru_info {
 	struct mem_cgroup_per_node *nodeinfo[MAX_NUMNODES];
 };
 
+/*
+ * Cgroups above their limits are maintained in a link-list, independent of
+ * their hierarchy representation
+ */
+struct mem_cgroup_list_per_zone {
+	struct list_head list;
+	spinlock_t lock;
+};
+
+struct mem_cgroup_list_per_node {
+	struct mem_cgroup_list_per_zone list_per_zone[MAX_NR_ZONES];
+};
+
+struct mem_cgroup_list {
+	struct mem_cgroup_list_per_node *list_per_node[MAX_NUMNODES];
+};
+
+static struct mem_cgroup_list soft_limit_list __read_mostly;
+
 struct mem_cgroup_threshold {
 	struct eventfd_ctx *eventfd;
 	u64 threshold;
@@ -359,6 +381,112 @@ page_cgroup_zoneinfo(struct mem_cgroup *mem, struct page *page)
 	return mem_cgroup_zoneinfo(mem, nid, zid);
 }
 
+static struct mem_cgroup_list_per_zone *
+soft_limit_list_node_zone(int nid, int zid)
+{
+	return &soft_limit_list.list_per_node[nid]->list_per_zone[zid];
+}
+
+static struct mem_cgroup_list_per_zone *
+soft_limit_list_from_page(struct page *page)
+{
+	int nid = page_to_nid(page);
+	int zid = page_zonenum(page);
+
+	return &soft_limit_list.list_per_node[nid]->list_per_zone[zid];
+}
+
+static void
+__mem_cgroup_insert_exceeded(struct mem_cgroup *mem,
+				struct mem_cgroup_per_zone *mz,
+				struct mem_cgroup_list_per_zone *mclz,
+				unsigned long long new_usage_in_excess)
+{
+	if (mz->on_list)
+		return;
+
+	mz->usage_in_excess = new_usage_in_excess;
+	if (!mz->usage_in_excess)
+		return;
+
+	list_add(&mz->soft_limit_list, &mclz->list);
+	mz->on_list = true;
+}
+
+static void
+mem_cgroup_insert_exceeded(struct mem_cgroup *mem,
+				struct mem_cgroup_per_zone *mz,
+				struct mem_cgroup_list_per_zone *mclz,
+				unsigned long long new_usage_in_excess)
+{
+	spin_lock(&mclz->lock);
+	__mem_cgroup_insert_exceeded(mem, mz, mclz, new_usage_in_excess);
+	spin_unlock(&mclz->lock);
+}
+
+static void
+__mem_cgroup_remove_exceeded(struct mem_cgroup *mem,
+				struct mem_cgroup_per_zone *mz,
+				struct mem_cgroup_list_per_zone *mclz)
+{
+	if (!mz->on_list)
+		return;
+
+	if (list_empty(&mclz->list))
+		return;
+
+	list_del(&mz->soft_limit_list);
+	mz->on_list = false;
+}
+
+static void
+mem_cgroup_remove_exceeded(struct mem_cgroup *mem,
+				struct mem_cgroup_per_zone *mz,
+				struct mem_cgroup_list_per_zone *mclz)
+{
+
+	spin_lock(&mclz->lock);
+	__mem_cgroup_remove_exceeded(mem, mz, mclz);
+	spin_unlock(&mclz->lock);
+}
+
+static void
+mem_cgroup_update_list(struct mem_cgroup *mem, struct page *page)
+{
+	unsigned long long excess;
+	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup_list_per_zone *mclz;
+	int nid = page_to_nid(page);
+	int zid = page_zonenum(page);
+	mclz = soft_limit_list_from_page(page);
+
+	for (; mem; mem = parent_mem_cgroup(mem)) {
+		mz = mem_cgroup_zoneinfo(mem, nid, zid);
+		excess = res_counter_soft_limit_excess(&mem->res);
+
+		if (excess)
+			mem_cgroup_insert_exceeded(mem, mz, mclz, excess);
+		else
+			mem_cgroup_remove_exceeded(mem, mz, mclz);
+	}
+}
+
+static void
+mem_cgroup_remove_from_lists(struct mem_cgroup *mem)
+{
+	int node, zone;
+	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup_list_per_zone *mclz;
+
+	for_each_node_state(node, N_POSSIBLE) {
+		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
+			mz = mem_cgroup_zoneinfo(mem, node, zone);
+			mclz = soft_limit_list_node_zone(node, zone);
+			mem_cgroup_remove_exceeded(mem, mz, mclz);
+		}
+	}
+}
+
 /*
  * Implementation Note: reading percpu statistics for memcg.
  *
@@ -544,6 +672,7 @@ static void memcg_check_events(struct mem_cgroup *mem, struct page *page)
 		__mem_cgroup_target_update(mem, MEM_CGROUP_TARGET_THRESH);
 		if (unlikely(__memcg_event_check(mem,
 			MEM_CGROUP_TARGET_SOFTLIMIT))){
+			mem_cgroup_update_list(mem, page);
 			__mem_cgroup_target_update(mem,
 				MEM_CGROUP_TARGET_SOFTLIMIT);
 		}
@@ -4253,6 +4382,8 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
 		mz = &pn->zoneinfo[zone];
 		for_each_lru(l)
 			INIT_LIST_HEAD(&mz->lists[l]);
+		mz->usage_in_excess = 0;
+		mz->on_list = false;
 		mz->mem = mem;
 	}
 	return 0;
@@ -4306,6 +4437,7 @@ static void __mem_cgroup_free(struct mem_cgroup *mem)
 {
 	int node;
 
+	mem_cgroup_remove_from_lists(mem);
 	free_css_id(&mem_cgroup_subsys, &mem->css);
 
 	for_each_node_state(node, N_POSSIBLE)
@@ -4360,6 +4492,31 @@ static void __init enable_swap_cgroup(void)
 }
 #endif
 
+static int mem_cgroup_soft_limit_list_init(void)
+{
+	struct mem_cgroup_list_per_node *rlpn;
+	struct mem_cgroup_list_per_zone *rlpz;
+	int tmp, node, zone;
+
+	for_each_node_state(node, N_POSSIBLE) {
+		tmp = node;
+		if (!node_state(node, N_NORMAL_MEMORY))
+			tmp = -1;
+		rlpn = kzalloc_node(sizeof(*rlpn), GFP_KERNEL, tmp);
+		if (!rlpn)
+			return 1;
+
+		soft_limit_list.list_per_node[node] = rlpn;
+
+		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
+			rlpz = &rlpn->list_per_zone[zone];
+			INIT_LIST_HEAD(&rlpz->list);
+			spin_lock_init(&rlpz->lock);
+		}
+	}
+	return 0;
+}
+
 static struct cgroup_subsys_state * __ref
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
@@ -4381,6 +4538,8 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 		enable_swap_cgroup();
 		parent = NULL;
 		root_mem_cgroup = mem;
+		if (mem_cgroup_soft_limit_list_init())
+			goto free_out;
 		for_each_possible_cpu(cpu) {
 			struct memcg_stock_pcp *stock =
 						&per_cpu(memcg_stock, cpu);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
