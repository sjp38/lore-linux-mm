Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 880986B0092
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 11:48:21 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [V5 PATCH 08/26] memcontrol: use N_MEMORY instead N_HIGH_MEMORY
Date: Mon, 29 Oct 2012 23:20:58 +0800
Message-Id: <1351524078-20363-7-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1351523301-20048-1-git-send-email-laijs@cn.fujitsu.com>
References: <1351523301-20048-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, x86 maintainers <x86@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, Rusty Russell <rusty@rustcorp.com.au>, Yinghai Lu <yinghai@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

N_HIGH_MEMORY stands for the nodes that has normal or high memory.
N_MEMORY stands for the nodes that has any memory.

The code here need to handle with the nodes which have memory, we should
use N_MEMORY instead.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 mm/memcontrol.c  |   18 +++++++++---------
 mm/page_cgroup.c |    2 +-
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7acf43b..1b69665 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -800,7 +800,7 @@ static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg,
 	int nid;
 	u64 total = 0;
 
-	for_each_node_state(nid, N_HIGH_MEMORY)
+	for_each_node_state(nid, N_MEMORY)
 		total += mem_cgroup_node_nr_lru_pages(memcg, nid, lru_mask);
 	return total;
 }
@@ -1611,9 +1611,9 @@ static void mem_cgroup_may_update_nodemask(struct mem_cgroup *memcg)
 		return;
 
 	/* make a nodemask where this memcg uses memory from */
-	memcg->scan_nodes = node_states[N_HIGH_MEMORY];
+	memcg->scan_nodes = node_states[N_MEMORY];
 
-	for_each_node_mask(nid, node_states[N_HIGH_MEMORY]) {
+	for_each_node_mask(nid, node_states[N_MEMORY]) {
 
 		if (!test_mem_cgroup_node_reclaimable(memcg, nid, false))
 			node_clear(nid, memcg->scan_nodes);
@@ -1684,7 +1684,7 @@ static bool mem_cgroup_reclaimable(struct mem_cgroup *memcg, bool noswap)
 	/*
 	 * Check rest of nodes.
 	 */
-	for_each_node_state(nid, N_HIGH_MEMORY) {
+	for_each_node_state(nid, N_MEMORY) {
 		if (node_isset(nid, memcg->scan_nodes))
 			continue;
 		if (test_mem_cgroup_node_reclaimable(memcg, nid, noswap))
@@ -3759,7 +3759,7 @@ move_account:
 		drain_all_stock_sync(memcg);
 		ret = 0;
 		mem_cgroup_start_move(memcg);
-		for_each_node_state(node, N_HIGH_MEMORY) {
+		for_each_node_state(node, N_MEMORY) {
 			for (zid = 0; !ret && zid < MAX_NR_ZONES; zid++) {
 				enum lru_list lru;
 				for_each_lru(lru) {
@@ -4087,7 +4087,7 @@ static int memcg_numa_stat_show(struct cgroup *cont, struct cftype *cft,
 
 	total_nr = mem_cgroup_nr_lru_pages(memcg, LRU_ALL);
 	seq_printf(m, "total=%lu", total_nr);
-	for_each_node_state(nid, N_HIGH_MEMORY) {
+	for_each_node_state(nid, N_MEMORY) {
 		node_nr = mem_cgroup_node_nr_lru_pages(memcg, nid, LRU_ALL);
 		seq_printf(m, " N%d=%lu", nid, node_nr);
 	}
@@ -4095,7 +4095,7 @@ static int memcg_numa_stat_show(struct cgroup *cont, struct cftype *cft,
 
 	file_nr = mem_cgroup_nr_lru_pages(memcg, LRU_ALL_FILE);
 	seq_printf(m, "file=%lu", file_nr);
-	for_each_node_state(nid, N_HIGH_MEMORY) {
+	for_each_node_state(nid, N_MEMORY) {
 		node_nr = mem_cgroup_node_nr_lru_pages(memcg, nid,
 				LRU_ALL_FILE);
 		seq_printf(m, " N%d=%lu", nid, node_nr);
@@ -4104,7 +4104,7 @@ static int memcg_numa_stat_show(struct cgroup *cont, struct cftype *cft,
 
 	anon_nr = mem_cgroup_nr_lru_pages(memcg, LRU_ALL_ANON);
 	seq_printf(m, "anon=%lu", anon_nr);
-	for_each_node_state(nid, N_HIGH_MEMORY) {
+	for_each_node_state(nid, N_MEMORY) {
 		node_nr = mem_cgroup_node_nr_lru_pages(memcg, nid,
 				LRU_ALL_ANON);
 		seq_printf(m, " N%d=%lu", nid, node_nr);
@@ -4113,7 +4113,7 @@ static int memcg_numa_stat_show(struct cgroup *cont, struct cftype *cft,
 
 	unevictable_nr = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_UNEVICTABLE));
 	seq_printf(m, "unevictable=%lu", unevictable_nr);
-	for_each_node_state(nid, N_HIGH_MEMORY) {
+	for_each_node_state(nid, N_MEMORY) {
 		node_nr = mem_cgroup_node_nr_lru_pages(memcg, nid,
 				BIT(LRU_UNEVICTABLE));
 		seq_printf(m, " N%d=%lu", nid, node_nr);
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 5ddad0c..c1054ad 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -271,7 +271,7 @@ void __init page_cgroup_init(void)
 	if (mem_cgroup_disabled())
 		return;
 
-	for_each_node_state(nid, N_HIGH_MEMORY) {
+	for_each_node_state(nid, N_MEMORY) {
 		unsigned long start_pfn, end_pfn;
 
 		start_pfn = node_start_pfn(nid);
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
