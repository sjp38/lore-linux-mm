Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 5C2916B004F
	for <linux-mm@kvack.org>; Sat, 14 Jan 2012 19:10:50 -0500 (EST)
Received: by iafj26 with SMTP id j26so8432731iaf.14
        for <linux-mm@kvack.org>; Sat, 14 Jan 2012 16:10:49 -0800 (PST)
Date: Sat, 14 Jan 2012 16:10:42 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 2/5] memcg: replace mem and mem_cont stragglers
In-Reply-To: <alpine.LSU.2.00.1201141550170.1261@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1201141609370.1261@eggly.anvils>
References: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils> <20120109130259.GD3588@cmpxchg.org> <alpine.LSU.2.00.1201141550170.1261@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org

Replace mem and mem_cont stragglers in memcontrol.c by memcg.

Signed-off-by: Hugh Dickins <hughd@google.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Kirill A. Shutemov <kirill@shutemov.name>
Acked-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   84 +++++++++++++++++++++++-----------------------
 1 file changed, 42 insertions(+), 42 deletions(-)

--- mmotm.orig/mm/memcontrol.c	2011-12-30 21:21:34.895338593 -0800
+++ mmotm/mm/memcontrol.c	2011-12-30 21:22:05.679339324 -0800
@@ -144,7 +144,7 @@ struct mem_cgroup_per_zone {
 	unsigned long long	usage_in_excess;/* Set to the value by which */
 						/* the soft limit is exceeded*/
 	bool			on_tree;
-	struct mem_cgroup	*mem;		/* Back pointer, we cannot */
+	struct mem_cgroup	*memcg;		/* Back pointer, we cannot */
 						/* use container_of	   */
 };
 /* Macro for accessing counter */
@@ -597,9 +597,9 @@ retry:
 	 * we will to add it back at the end of reclaim to its correct
 	 * position in the tree.
 	 */
-	__mem_cgroup_remove_exceeded(mz->mem, mz, mctz);
-	if (!res_counter_soft_limit_excess(&mz->mem->res) ||
-		!css_tryget(&mz->mem->css))
+	__mem_cgroup_remove_exceeded(mz->memcg, mz, mctz);
+	if (!res_counter_soft_limit_excess(&mz->memcg->res) ||
+		!css_tryget(&mz->memcg->css))
 		goto retry;
 done:
 	return mz;
@@ -1743,22 +1743,22 @@ static DEFINE_SPINLOCK(memcg_oom_lock);
 static DECLARE_WAIT_QUEUE_HEAD(memcg_oom_waitq);
 
 struct oom_wait_info {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *memcg;
 	wait_queue_t	wait;
 };
 
 static int memcg_oom_wake_function(wait_queue_t *wait,
 	unsigned mode, int sync, void *arg)
 {
-	struct mem_cgroup *wake_memcg = (struct mem_cgroup *)arg,
-			  *oom_wait_memcg;
+	struct mem_cgroup *wake_memcg = (struct mem_cgroup *)arg;
+	struct mem_cgroup *oom_wait_memcg;
 	struct oom_wait_info *oom_wait_info;
 
 	oom_wait_info = container_of(wait, struct oom_wait_info, wait);
-	oom_wait_memcg = oom_wait_info->mem;
+	oom_wait_memcg = oom_wait_info->memcg;
 
 	/*
-	 * Both of oom_wait_info->mem and wake_mem are stable under us.
+	 * Both of oom_wait_info->memcg and wake_memcg are stable under us.
 	 * Then we can use css_is_ancestor without taking care of RCU.
 	 */
 	if (!mem_cgroup_same_or_subtree(oom_wait_memcg, wake_memcg)
@@ -1787,7 +1787,7 @@ bool mem_cgroup_handle_oom(struct mem_cg
 	struct oom_wait_info owait;
 	bool locked, need_to_kill;
 
-	owait.mem = memcg;
+	owait.memcg = memcg;
 	owait.wait.flags = 0;
 	owait.wait.func = memcg_oom_wake_function;
 	owait.wait.private = current;
@@ -3535,7 +3535,7 @@ unsigned long mem_cgroup_soft_limit_recl
 			break;
 
 		nr_scanned = 0;
-		reclaimed = mem_cgroup_soft_reclaim(mz->mem, zone,
+		reclaimed = mem_cgroup_soft_reclaim(mz->memcg, zone,
 						    gfp_mask, &nr_scanned);
 		nr_reclaimed += reclaimed;
 		*total_scanned += nr_scanned;
@@ -3562,13 +3562,13 @@ unsigned long mem_cgroup_soft_limit_recl
 				next_mz =
 				__mem_cgroup_largest_soft_limit_node(mctz);
 				if (next_mz == mz)
-					css_put(&next_mz->mem->css);
+					css_put(&next_mz->memcg->css);
 				else /* next_mz == NULL or other memcg */
 					break;
 			} while (1);
 		}
-		__mem_cgroup_remove_exceeded(mz->mem, mz, mctz);
-		excess = res_counter_soft_limit_excess(&mz->mem->res);
+		__mem_cgroup_remove_exceeded(mz->memcg, mz, mctz);
+		excess = res_counter_soft_limit_excess(&mz->memcg->res);
 		/*
 		 * One school of thought says that we should not add
 		 * back the node to the tree if reclaim returns 0.
@@ -3578,9 +3578,9 @@ unsigned long mem_cgroup_soft_limit_recl
 		 * term TODO.
 		 */
 		/* If excess == 0, no tree ops */
-		__mem_cgroup_insert_exceeded(mz->mem, mz, mctz, excess);
+		__mem_cgroup_insert_exceeded(mz->memcg, mz, mctz, excess);
 		spin_unlock(&mctz->lock);
-		css_put(&mz->mem->css);
+		css_put(&mz->memcg->css);
 		loop++;
 		/*
 		 * Could not reclaim anything and there are no more
@@ -3593,7 +3593,7 @@ unsigned long mem_cgroup_soft_limit_recl
 			break;
 	} while (!nr_reclaimed);
 	if (next_mz)
-		css_put(&next_mz->mem->css);
+		css_put(&next_mz->memcg->css);
 	return nr_reclaimed;
 }
 
@@ -4096,38 +4096,38 @@ static int mem_control_numa_stat_show(st
 	unsigned long total_nr, file_nr, anon_nr, unevictable_nr;
 	unsigned long node_nr;
 	struct cgroup *cont = m->private;
-	struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 
-	total_nr = mem_cgroup_nr_lru_pages(mem_cont, LRU_ALL);
+	total_nr = mem_cgroup_nr_lru_pages(memcg, LRU_ALL);
 	seq_printf(m, "total=%lu", total_nr);
 	for_each_node_state(nid, N_HIGH_MEMORY) {
-		node_nr = mem_cgroup_node_nr_lru_pages(mem_cont, nid, LRU_ALL);
+		node_nr = mem_cgroup_node_nr_lru_pages(memcg, nid, LRU_ALL);
 		seq_printf(m, " N%d=%lu", nid, node_nr);
 	}
 	seq_putc(m, '\n');
 
-	file_nr = mem_cgroup_nr_lru_pages(mem_cont, LRU_ALL_FILE);
+	file_nr = mem_cgroup_nr_lru_pages(memcg, LRU_ALL_FILE);
 	seq_printf(m, "file=%lu", file_nr);
 	for_each_node_state(nid, N_HIGH_MEMORY) {
-		node_nr = mem_cgroup_node_nr_lru_pages(mem_cont, nid,
+		node_nr = mem_cgroup_node_nr_lru_pages(memcg, nid,
 				LRU_ALL_FILE);
 		seq_printf(m, " N%d=%lu", nid, node_nr);
 	}
 	seq_putc(m, '\n');
 
-	anon_nr = mem_cgroup_nr_lru_pages(mem_cont, LRU_ALL_ANON);
+	anon_nr = mem_cgroup_nr_lru_pages(memcg, LRU_ALL_ANON);
 	seq_printf(m, "anon=%lu", anon_nr);
 	for_each_node_state(nid, N_HIGH_MEMORY) {
-		node_nr = mem_cgroup_node_nr_lru_pages(mem_cont, nid,
+		node_nr = mem_cgroup_node_nr_lru_pages(memcg, nid,
 				LRU_ALL_ANON);
 		seq_printf(m, " N%d=%lu", nid, node_nr);
 	}
 	seq_putc(m, '\n');
 
-	unevictable_nr = mem_cgroup_nr_lru_pages(mem_cont, BIT(LRU_UNEVICTABLE));
+	unevictable_nr = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_UNEVICTABLE));
 	seq_printf(m, "unevictable=%lu", unevictable_nr);
 	for_each_node_state(nid, N_HIGH_MEMORY) {
-		node_nr = mem_cgroup_node_nr_lru_pages(mem_cont, nid,
+		node_nr = mem_cgroup_node_nr_lru_pages(memcg, nid,
 				BIT(LRU_UNEVICTABLE));
 		seq_printf(m, " N%d=%lu", nid, node_nr);
 	}
@@ -4139,12 +4139,12 @@ static int mem_control_numa_stat_show(st
 static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 				 struct cgroup_map_cb *cb)
 {
-	struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 	struct mcs_total_stat mystat;
 	int i;
 
 	memset(&mystat, 0, sizeof(mystat));
-	mem_cgroup_get_local_stat(mem_cont, &mystat);
+	mem_cgroup_get_local_stat(memcg, &mystat);
 
 
 	for (i = 0; i < NR_MCS_STAT; i++) {
@@ -4156,14 +4156,14 @@ static int mem_control_stat_show(struct
 	/* Hierarchical information */
 	{
 		unsigned long long limit, memsw_limit;
-		memcg_get_hierarchical_limit(mem_cont, &limit, &memsw_limit);
+		memcg_get_hierarchical_limit(memcg, &limit, &memsw_limit);
 		cb->fill(cb, "hierarchical_memory_limit", limit);
 		if (do_swap_account)
 			cb->fill(cb, "hierarchical_memsw_limit", memsw_limit);
 	}
 
 	memset(&mystat, 0, sizeof(mystat));
-	mem_cgroup_get_total_stat(mem_cont, &mystat);
+	mem_cgroup_get_total_stat(memcg, &mystat);
 	for (i = 0; i < NR_MCS_STAT; i++) {
 		if (i == MCS_SWAP && !do_swap_account)
 			continue;
@@ -4179,7 +4179,7 @@ static int mem_control_stat_show(struct
 
 		for_each_online_node(nid)
 			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
-				mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
+				mz = mem_cgroup_zoneinfo(memcg, nid, zid);
 
 				recent_rotated[0] +=
 					mz->reclaim_stat.recent_rotated[0];
@@ -4808,7 +4808,7 @@ static int alloc_mem_cgroup_per_zone_inf
 			INIT_LIST_HEAD(&mz->lruvec.lists[l]);
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
-		mz->mem = memcg;
+		mz->memcg = memcg;
 	}
 	memcg->info.nodeinfo[node] = pn;
 	return 0;
@@ -4821,29 +4821,29 @@ static void free_mem_cgroup_per_zone_inf
 
 static struct mem_cgroup *mem_cgroup_alloc(void)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *memcg;
 	int size = sizeof(struct mem_cgroup);
 
 	/* Can be very big if MAX_NUMNODES is very big */
 	if (size < PAGE_SIZE)
-		mem = kzalloc(size, GFP_KERNEL);
+		memcg = kzalloc(size, GFP_KERNEL);
 	else
-		mem = vzalloc(size);
+		memcg = vzalloc(size);
 
-	if (!mem)
+	if (!memcg)
 		return NULL;
 
-	mem->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
-	if (!mem->stat)
+	memcg->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
+	if (!memcg->stat)
 		goto out_free;
-	spin_lock_init(&mem->pcp_counter_lock);
-	return mem;
+	spin_lock_init(&memcg->pcp_counter_lock);
+	return memcg;
 
 out_free:
 	if (size < PAGE_SIZE)
-		kfree(mem);
+		kfree(memcg);
 	else
-		vfree(mem);
+		vfree(memcg);
 	return NULL;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
