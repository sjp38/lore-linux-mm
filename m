Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 11F336B0092
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 04:23:57 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8P8O33u021718
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 25 Sep 2009 17:24:03 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id EC8D945DE4E
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:24:02 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C16845DE53
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:24:02 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B91451DB8040
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:24:01 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E38CE1DB8065
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:24:00 +0900 (JST)
Date: Fri, 25 Sep 2009 17:21:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/10] memcg: reorganize memcontrol.c
Message-Id: <20090925172153.0052cc3b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This is a patch just for reordering functions/definitions in memcontrol.c.

I think it's time to clean up memcontrol.c to be readable. Before adding
commentary or functions, it seems it's necessary to reorder functions in
memcontrol.c for better organization.

After this,  memcontol.c will be reordered in following way.

  - defintions of structs.
  - functions for accessing struct mem_cgroup.
  - functions for per-cpu statistics of mem_cgroup
  - functions for per-zone statistics of mem_cgroup
  - functions for per-zone softlimit-tree handling.
  - functions for LRU management.
  - functions for memory reclaim...called by vmscan.c
  - functions for OOM handling.
  - functions for hierarchical memory reclaim (includes softlimit)
  - functions for charge
  - functions for uncharge
  - functions for move charges.
  - functions for user interfaces
  - functions for cgroup callbacks.
  - functions for memcg creation/deletion.

This patch seems big...but just move codes.
There are no functionality/logic changes at all.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c | 1589 ++++++++++++++++++++++++++++----------------------------
 1 file changed, 812 insertions(+), 777 deletions(-)

Index: temp-mmotm/mm/memcontrol.c
===================================================================
--- temp-mmotm.orig/mm/memcontrol.c
+++ temp-mmotm/mm/memcontrol.c
@@ -55,7 +55,6 @@ static int really_do_swap_account __init
 #endif
 
 static DEFINE_MUTEX(memcg_tasklist);	/* can be hold under cgroup_mutex */
-#define SOFTLIMIT_EVENTS_THRESH (1000)
 
 /*
  * Statistics for memory cgroup.
@@ -83,47 +82,6 @@ struct mem_cgroup_stat {
 	struct mem_cgroup_stat_cpu cpustat[0];
 };
 
-static inline void
-__mem_cgroup_stat_reset_safe(struct mem_cgroup_stat_cpu *stat,
-				enum mem_cgroup_stat_index idx)
-{
-	stat->count[idx] = 0;
-}
-
-static inline s64
-__mem_cgroup_stat_read_local(struct mem_cgroup_stat_cpu *stat,
-				enum mem_cgroup_stat_index idx)
-{
-	return stat->count[idx];
-}
-
-/*
- * For accounting under irq disable, no need for increment preempt count.
- */
-static inline void __mem_cgroup_stat_add_safe(struct mem_cgroup_stat_cpu *stat,
-		enum mem_cgroup_stat_index idx, int val)
-{
-	stat->count[idx] += val;
-}
-
-static s64 mem_cgroup_read_stat(struct mem_cgroup_stat *stat,
-		enum mem_cgroup_stat_index idx)
-{
-	int cpu;
-	s64 ret = 0;
-	for_each_possible_cpu(cpu)
-		ret += stat->cpustat[cpu].count[idx];
-	return ret;
-}
-
-static s64 mem_cgroup_local_usage(struct mem_cgroup_stat *stat)
-{
-	s64 ret;
-
-	ret = mem_cgroup_read_stat(stat, MEM_CGROUP_STAT_CACHE);
-	ret += mem_cgroup_read_stat(stat, MEM_CGROUP_STAT_RSS);
-	return ret;
-}
 
 /*
  * per-zone information in memory controller.
@@ -231,12 +189,6 @@ struct mem_cgroup {
 	struct mem_cgroup_stat stat;
 };
 
-/*
- * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
- * limit reclaim to prevent infinite loops, if they ever occur.
- */
-#define	MEM_CGROUP_MAX_RECLAIM_LOOPS		(100)
-#define	MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS	(2)
 
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
@@ -263,6 +215,14 @@ enum charge_type {
 #define MEMFILE_ATTR(val)	((val) & 0xffff)
 
 /*
+ * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
+ * limit reclaim to prevent infinite loops, if they ever occur.
+ */
+#define MEM_CGROUP_MAX_RECLAIM_LOOPS		(100)
+#define MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS	(2)
+#define SOFTLIMIT_EVENTS_THRESH 		(1000)
+
+/*
  * Reclaim flags for mem_cgroup_hierarchical_reclaim
  */
 #define MEM_CGROUP_RECLAIM_NOSWAP_BIT	0x0
@@ -276,242 +236,239 @@ static void mem_cgroup_get(struct mem_cg
 static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
 
-static struct mem_cgroup_per_zone *
-mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
+/*
+ * root_cgroup is very special and we don't use res_counter in it.
+ */
+static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
 {
-	return &mem->info.nodeinfo[nid]->zoneinfo[zid];
+	return (mem == root_mem_cgroup);
 }
 
-static struct mem_cgroup_per_zone *
-page_cgroup_zoneinfo(struct page_cgroup *pc)
-{
-	struct mem_cgroup *mem = pc->mem_cgroup;
-	int nid = page_cgroup_nid(pc);
-	int zid = page_cgroup_zid(pc);
+/*
+ * Functions for getting mem_cgroup struct from misc structs.
+ */
 
-	if (!mem)
-		return NULL;
+#define mem_cgroup_from_res_counter(counter, member)	\
+	container_of(counter, struct mem_cgroup, member)
 
-	return mem_cgroup_zoneinfo(mem, nid, zid);
+static struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
+{
+	return container_of(cgroup_subsys_state(cont,
+				mem_cgroup_subsys_id), struct mem_cgroup,
+				css);
 }
 
-static struct mem_cgroup_tree_per_zone *
-soft_limit_tree_node_zone(int nid, int zid)
+struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 {
-	return &soft_limit_tree.rb_tree_per_node[nid]->rb_tree_per_zone[zid];
+	/*
+	 * mm_update_next_owner() may clear mm->owner to NULL
+	 * if it races with swapoff, page migration, etc.
+	 * So this can be called with p == NULL.
+	 */
+	if (unlikely(!p))
+		return NULL;
+
+	return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
+				struct mem_cgroup, css);
 }
 
-static struct mem_cgroup_tree_per_zone *
-soft_limit_tree_from_page(struct page *page)
+static struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 {
-	int nid = page_to_nid(page);
-	int zid = page_zonenum(page);
+	struct mem_cgroup *mem = NULL;
 
-	return &soft_limit_tree.rb_tree_per_node[nid]->rb_tree_per_zone[zid];
+	if (!mm)
+		return NULL;
+	/*
+	 * Because we have no locks, mm->owner's may be being moved to other
+	 * cgroup. We use css_tryget() here even if this looks
+	 * pessimistic (rather than adding locks here).
+	 */
+	rcu_read_lock();
+	do {
+		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
+		if (unlikely(!mem))
+			break;
+	} while (!css_tryget(&mem->css));
+	rcu_read_unlock();
+	return mem;
 }
 
-static void
-__mem_cgroup_insert_exceeded(struct mem_cgroup *mem,
-				struct mem_cgroup_per_zone *mz,
-				struct mem_cgroup_tree_per_zone *mctz,
-				unsigned long long new_usage_in_excess)
+/*
+ * A helper function to get mem_cgroup from ID. must be called under
+ * rcu_read_lock(). The caller must check css_is_removed() or some if
+ * it's concern. (dropping refcnt from swap can be called against removed
+ * memcg.)
+ */
+static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
 {
-	struct rb_node **p = &mctz->rb_root.rb_node;
-	struct rb_node *parent = NULL;
-	struct mem_cgroup_per_zone *mz_node;
+	struct cgroup_subsys_state *css;
 
-	if (mz->on_tree)
-		return;
+	/* ID 0 is unused ID */
+	if (!id)
+		return NULL;
+	css = css_lookup(&mem_cgroup_subsys, id);
+	if (!css)
+		return NULL;
+	return container_of(css, struct mem_cgroup, css);
+}
 
-	mz->usage_in_excess = new_usage_in_excess;
-	if (!mz->usage_in_excess)
-		return;
-	while (*p) {
-		parent = *p;
-		mz_node = rb_entry(parent, struct mem_cgroup_per_zone,
-					tree_node);
-		if (mz->usage_in_excess < mz_node->usage_in_excess)
-			p = &(*p)->rb_left;
-		/*
-		 * We can't avoid mem cgroups that are over their soft
-		 * limit by the same amount
-		 */
-		else if (mz->usage_in_excess >= mz_node->usage_in_excess)
-			p = &(*p)->rb_right;
-	}
-	rb_link_node(&mz->tree_node, parent, p);
-	rb_insert_color(&mz->tree_node, &mctz->rb_root);
-	mz->on_tree = true;
+/*
+ * Handlers for memcg's private percpu counters.
+ */
+
+static inline void
+__mem_cgroup_stat_reset_safe(struct mem_cgroup_stat_cpu *stat,
+				enum mem_cgroup_stat_index idx)
+{
+	stat->count[idx] = 0;
 }
 
-static void
-__mem_cgroup_remove_exceeded(struct mem_cgroup *mem,
-				struct mem_cgroup_per_zone *mz,
-				struct mem_cgroup_tree_per_zone *mctz)
+static inline s64
+__mem_cgroup_stat_read_local(struct mem_cgroup_stat_cpu *stat,
+				enum mem_cgroup_stat_index idx)
 {
-	if (!mz->on_tree)
-		return;
-	rb_erase(&mz->tree_node, &mctz->rb_root);
-	mz->on_tree = false;
+	return stat->count[idx];
 }
 
-static void
-mem_cgroup_remove_exceeded(struct mem_cgroup *mem,
-				struct mem_cgroup_per_zone *mz,
-				struct mem_cgroup_tree_per_zone *mctz)
+/*
+ * For accounting under irq disable, no need for increment preempt count.
+ */
+static inline void __mem_cgroup_stat_add_safe(struct mem_cgroup_stat_cpu *stat,
+		enum mem_cgroup_stat_index idx, int val)
 {
-	spin_lock(&mctz->lock);
-	__mem_cgroup_remove_exceeded(mem, mz, mctz);
-	spin_unlock(&mctz->lock);
+	stat->count[idx] += val;
 }
 
-static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
+static s64 mem_cgroup_read_stat(struct mem_cgroup_stat *stat,
+		enum mem_cgroup_stat_index idx)
 {
-	bool ret = false;
 	int cpu;
-	s64 val;
-	struct mem_cgroup_stat_cpu *cpustat;
-
-	cpu = get_cpu();
-	cpustat = &mem->stat.cpustat[cpu];
-	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_EVENTS);
-	if (unlikely(val > SOFTLIMIT_EVENTS_THRESH)) {
-		__mem_cgroup_stat_reset_safe(cpustat, MEM_CGROUP_STAT_EVENTS);
-		ret = true;
-	}
-	put_cpu();
+	s64 ret = 0;
+	for_each_possible_cpu(cpu)
+		ret += stat->cpustat[cpu].count[idx];
 	return ret;
 }
 
-static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page *page)
+static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
+					 bool charge)
 {
-	unsigned long long excess;
-	struct mem_cgroup_per_zone *mz;
-	struct mem_cgroup_tree_per_zone *mctz;
-	int nid = page_to_nid(page);
-	int zid = page_zonenum(page);
-	mctz = soft_limit_tree_from_page(page);
+	int val = (charge) ? 1 : -1;
+	struct mem_cgroup_stat *stat = &mem->stat;
+	struct mem_cgroup_stat_cpu *cpustat;
+	int cpu = get_cpu();
 
-	/*
-	 * Necessary to update all ancestors when hierarchy is used.
-	 * because their event counter is not touched.
-	 */
-	for (; mem; mem = parent_mem_cgroup(mem)) {
-		mz = mem_cgroup_zoneinfo(mem, nid, zid);
-		excess = res_counter_soft_limit_excess(&mem->res);
-		/*
-		 * We have to update the tree if mz is on RB-tree or
-		 * mem is over its softlimit.
-		 */
-		if (excess || mz->on_tree) {
-			spin_lock(&mctz->lock);
-			/* if on-tree, remove it */
-			if (mz->on_tree)
-				__mem_cgroup_remove_exceeded(mem, mz, mctz);
-			/*
-			 * Insert again. mz->usage_in_excess will be updated.
-			 * If excess is 0, no tree ops.
-			 */
-			__mem_cgroup_insert_exceeded(mem, mz, mctz, excess);
-			spin_unlock(&mctz->lock);
-		}
-	}
+	cpustat = &stat->cpustat[cpu];
+	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_SWAPOUT, val);
+	put_cpu();
 }
 
-static void mem_cgroup_remove_from_trees(struct mem_cgroup *mem)
+static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
+					 struct page_cgroup *pc,
+					 bool charge)
 {
-	int node, zone;
-	struct mem_cgroup_per_zone *mz;
-	struct mem_cgroup_tree_per_zone *mctz;
-
-	for_each_node_state(node, N_POSSIBLE) {
-		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
-			mz = mem_cgroup_zoneinfo(mem, node, zone);
-			mctz = soft_limit_tree_node_zone(node, zone);
-			mem_cgroup_remove_exceeded(mem, mz, mctz);
-		}
-	}
+	int val = (charge) ? 1 : -1;
+	struct mem_cgroup_stat *stat = &mem->stat;
+	struct mem_cgroup_stat_cpu *cpustat;
+	int cpu = get_cpu();
+
+	cpustat = &stat->cpustat[cpu];
+	if (PageCgroupCache(pc))
+		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_CACHE, val);
+	else
+		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_RSS, val);
+
+	if (charge)
+		__mem_cgroup_stat_add_safe(cpustat,
+				MEM_CGROUP_STAT_PGPGIN_COUNT, 1);
+	else
+		__mem_cgroup_stat_add_safe(cpustat,
+				MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
+	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_EVENTS, 1);
+	put_cpu();
 }
 
-static inline unsigned long mem_cgroup_get_excess(struct mem_cgroup *mem)
+static s64 mem_cgroup_local_usage(struct mem_cgroup_stat *stat)
 {
-	return res_counter_soft_limit_excess(&mem->res) >> PAGE_SHIFT;
+	s64 ret;
+
+	ret = mem_cgroup_read_stat(stat, MEM_CGROUP_STAT_CACHE);
+	ret += mem_cgroup_read_stat(stat, MEM_CGROUP_STAT_RSS);
+	return ret;
 }
 
-static struct mem_cgroup_per_zone *
-__mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
+/*
+ * Currently used to update mapped file statistics, but the routine can be
+ * generalized to update other statistics as well.
+ */
+void mem_cgroup_update_mapped_file_stat(struct page *page, int val)
 {
-	struct rb_node *rightmost = NULL;
-	struct mem_cgroup_per_zone *mz = NULL;
+	struct mem_cgroup *mem;
+	struct mem_cgroup_stat *stat;
+	struct mem_cgroup_stat_cpu *cpustat;
+	int cpu;
+	struct page_cgroup *pc;
 
-retry:
-	rightmost = rb_last(&mctz->rb_root);
-	if (!rightmost)
-		goto done;		/* Nothing to reclaim from */
+	if (!page_is_file_cache(page))
+		return;
+
+	pc = lookup_page_cgroup(page);
+	if (unlikely(!pc))
+		return;
+
+	lock_page_cgroup(pc);
+	mem = pc->mem_cgroup;
+	if (!mem)
+		goto done;
+
+	if (!PageCgroupUsed(pc))
+		goto done;
 
-	mz = rb_entry(rightmost, struct mem_cgroup_per_zone, tree_node);
 	/*
-	 * Remove the node now but someone else can add it back,
-	 * we will to add it back at the end of reclaim to its correct
-	 * position in the tree.
+	 * Preemption is already disabled, we don't need get_cpu()
 	 */
-	__mem_cgroup_remove_exceeded(mz->mem, mz, mctz);
-	if (!res_counter_soft_limit_excess(&mz->mem->res) ||
-		!css_tryget(&mz->mem->css))
-		goto retry;
+	cpu = smp_processor_id();
+	stat = &mem->stat;
+	cpustat = &stat->cpustat[cpu];
+
+	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE, val);
 done:
-	return mz;
+	unlock_page_cgroup(pc);
 }
 
+/*
+ * Handlers for memcg's private perzone counters.
+ */
 static struct mem_cgroup_per_zone *
-mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
+mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
 {
-	struct mem_cgroup_per_zone *mz;
-
-	spin_lock(&mctz->lock);
-	mz = __mem_cgroup_largest_soft_limit_node(mctz);
-	spin_unlock(&mctz->lock);
-	return mz;
+	return &mem->info.nodeinfo[nid]->zoneinfo[zid];
 }
 
-static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
-					 bool charge)
+static struct mem_cgroup_per_zone *
+page_cgroup_zoneinfo(struct page_cgroup *pc)
 {
-	int val = (charge) ? 1 : -1;
-	struct mem_cgroup_stat *stat = &mem->stat;
-	struct mem_cgroup_stat_cpu *cpustat;
-	int cpu = get_cpu();
+	struct mem_cgroup *mem = pc->mem_cgroup;
+	int nid = page_cgroup_nid(pc);
+	int zid = page_cgroup_zid(pc);
 
-	cpustat = &stat->cpustat[cpu];
-	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_SWAPOUT, val);
-	put_cpu();
+	if (!mem)
+		return NULL;
+
+	return mem_cgroup_zoneinfo(mem, nid, zid);
 }
 
-static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
-					 struct page_cgroup *pc,
-					 bool charge)
+unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
+				       struct zone *zone,
+				       enum lru_list lru)
 {
-	int val = (charge) ? 1 : -1;
-	struct mem_cgroup_stat *stat = &mem->stat;
-	struct mem_cgroup_stat_cpu *cpustat;
-	int cpu = get_cpu();
-
-	cpustat = &stat->cpustat[cpu];
-	if (PageCgroupCache(pc))
-		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_CACHE, val);
-	else
-		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_RSS, val);
+	int nid = zone->zone_pgdat->node_id;
+	int zid = zone_idx(zone);
+	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
 
-	if (charge)
-		__mem_cgroup_stat_add_safe(cpustat,
-				MEM_CGROUP_STAT_PGPGIN_COUNT, 1);
-	else
-		__mem_cgroup_stat_add_safe(cpustat,
-				MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
-	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_EVENTS, 1);
-	put_cpu();
+	return MEM_CGROUP_ZSTAT(mz, lru);
 }
 
+
 static unsigned long mem_cgroup_get_local_zonestat(struct mem_cgroup *mem,
 					enum lru_list idx)
 {
@@ -527,48 +484,186 @@ static unsigned long mem_cgroup_get_loca
 	return total;
 }
 
-static struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
+static struct mem_cgroup_tree_per_zone *
+soft_limit_tree_node_zone(int nid, int zid)
 {
-	return container_of(cgroup_subsys_state(cont,
-				mem_cgroup_subsys_id), struct mem_cgroup,
-				css);
+	return &soft_limit_tree.rb_tree_per_node[nid]->rb_tree_per_zone[zid];
 }
 
-struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
+static struct mem_cgroup_tree_per_zone *
+soft_limit_tree_from_page(struct page *page)
+{
+	int nid = page_to_nid(page);
+	int zid = page_zonenum(page);
+
+	return &soft_limit_tree.rb_tree_per_node[nid]->rb_tree_per_zone[zid];
+}
+
+static void
+__mem_cgroup_insert_exceeded(struct mem_cgroup *mem,
+				struct mem_cgroup_per_zone *mz,
+				struct mem_cgroup_tree_per_zone *mctz,
+				unsigned long long new_usage_in_excess)
+{
+	struct rb_node **p = &mctz->rb_root.rb_node;
+	struct rb_node *parent = NULL;
+	struct mem_cgroup_per_zone *mz_node;
+
+	if (mz->on_tree)
+		return;
+
+	mz->usage_in_excess = new_usage_in_excess;
+	if (!mz->usage_in_excess)
+		return;
+	while (*p) {
+		parent = *p;
+		mz_node = rb_entry(parent, struct mem_cgroup_per_zone,
+					tree_node);
+		if (mz->usage_in_excess < mz_node->usage_in_excess)
+			p = &(*p)->rb_left;
+		/*
+		 * We can't avoid mem cgroups that are over their soft
+		 * limit by the same amount
+		 */
+		else if (mz->usage_in_excess >= mz_node->usage_in_excess)
+			p = &(*p)->rb_right;
+	}
+	rb_link_node(&mz->tree_node, parent, p);
+	rb_insert_color(&mz->tree_node, &mctz->rb_root);
+	mz->on_tree = true;
+}
+
+static void
+__mem_cgroup_remove_exceeded(struct mem_cgroup *mem,
+				struct mem_cgroup_per_zone *mz,
+				struct mem_cgroup_tree_per_zone *mctz)
 {
+	if (!mz->on_tree)
+		return;
+	rb_erase(&mz->tree_node, &mctz->rb_root);
+	mz->on_tree = false;
+}
+
+static void
+mem_cgroup_remove_exceeded(struct mem_cgroup *mem,
+				struct mem_cgroup_per_zone *mz,
+				struct mem_cgroup_tree_per_zone *mctz)
+{
+	spin_lock(&mctz->lock);
+	__mem_cgroup_remove_exceeded(mem, mz, mctz);
+	spin_unlock(&mctz->lock);
+}
+
+static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
+{
+	bool ret = false;
+	int cpu;
+	s64 val;
+	struct mem_cgroup_stat_cpu *cpustat;
+
+	cpu = get_cpu();
+	cpustat = &mem->stat.cpustat[cpu];
+	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_EVENTS);
+	if (unlikely(val > SOFTLIMIT_EVENTS_THRESH)) {
+		__mem_cgroup_stat_reset_safe(cpustat, MEM_CGROUP_STAT_EVENTS);
+		ret = true;
+	}
+	put_cpu();
+	return ret;
+}
+
+static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page *page)
+{
+	unsigned long long excess;
+	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup_tree_per_zone *mctz;
+	int nid = page_to_nid(page);
+	int zid = page_zonenum(page);
+	mctz = soft_limit_tree_from_page(page);
+
+	/*
+	 * Necessary to update all ancestors when hierarchy is used.
+	 * because their event counter is not touched.
+	 */
+	for (; mem; mem = parent_mem_cgroup(mem)) {
+		mz = mem_cgroup_zoneinfo(mem, nid, zid);
+		excess = res_counter_soft_limit_excess(&mem->res);
+		/*
+		 * We have to update the tree if mz is on RB-tree or
+		 * mem is over its softlimit.
+		 */
+		if (excess || mz->on_tree) {
+			spin_lock(&mctz->lock);
+			/* if on-tree, remove it */
+			if (mz->on_tree)
+				__mem_cgroup_remove_exceeded(mem, mz, mctz);
+			/*
+			 * Insert again. mz->usage_in_excess will be updated.
+			 * If excess is 0, no tree ops.
+			 */
+			__mem_cgroup_insert_exceeded(mem, mz, mctz, excess);
+			spin_unlock(&mctz->lock);
+		}
+	}
+}
+
+static void mem_cgroup_remove_from_trees(struct mem_cgroup *mem)
+{
+	int node, zone;
+	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup_tree_per_zone *mctz;
+
+	for_each_node_state(node, N_POSSIBLE) {
+		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
+			mz = mem_cgroup_zoneinfo(mem, node, zone);
+			mctz = soft_limit_tree_node_zone(node, zone);
+			mem_cgroup_remove_exceeded(mem, mz, mctz);
+		}
+	}
+}
+
+static inline unsigned long mem_cgroup_get_excess(struct mem_cgroup *mem)
+{
+	return res_counter_soft_limit_excess(&mem->res) >> PAGE_SHIFT;
+}
+
+static struct mem_cgroup_per_zone *
+__mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
+{
+	struct rb_node *rightmost = NULL;
+	struct mem_cgroup_per_zone *mz = NULL;
+
+retry:
+	rightmost = rb_last(&mctz->rb_root);
+	if (!rightmost)
+		goto done;		/* Nothing to reclaim from */
+
+	mz = rb_entry(rightmost, struct mem_cgroup_per_zone, tree_node);
 	/*
-	 * mm_update_next_owner() may clear mm->owner to NULL
-	 * if it races with swapoff, page migration, etc.
-	 * So this can be called with p == NULL.
+	 * Remove the node now but someone else can add it back,
+	 * we will to add it back at the end of reclaim to its correct
+	 * position in the tree.
 	 */
-	if (unlikely(!p))
-		return NULL;
-
-	return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
-				struct mem_cgroup, css);
+	__mem_cgroup_remove_exceeded(mz->mem, mz, mctz);
+	if (!res_counter_soft_limit_excess(&mz->mem->res) ||
+		!css_tryget(&mz->mem->css))
+		goto retry;
+done:
+	return mz;
 }
 
-static struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
+static struct mem_cgroup_per_zone *
+mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
 {
-	struct mem_cgroup *mem = NULL;
+	struct mem_cgroup_per_zone *mz;
 
-	if (!mm)
-		return NULL;
-	/*
-	 * Because we have no locks, mm->owner's may be being moved to other
-	 * cgroup. We use css_tryget() here even if this looks
-	 * pessimistic (rather than adding locks here).
-	 */
-	rcu_read_lock();
-	do {
-		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
-		if (unlikely(!mem))
-			break;
-	} while (!css_tryget(&mem->css));
-	rcu_read_unlock();
-	return mem;
+	spin_lock(&mctz->lock);
+	mz = __mem_cgroup_largest_soft_limit_node(mctz);
+	spin_unlock(&mctz->lock);
+	return mz;
 }
 
+
 /*
  * Call callback function against all cgroup under hierarchy tree.
  */
@@ -604,11 +699,6 @@ static int mem_cgroup_walk_tree(struct m
 	return ret;
 }
 
-static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
-{
-	return (mem == root_mem_cgroup);
-}
-
 /*
  * Following LRU functions are allowed to be used without PCG_LOCK.
  * Operations are called by routine of global LRU independently from memcg.
@@ -699,6 +789,15 @@ void mem_cgroup_add_lru_list(struct page
 	list_add(&pc->lru, &mz->lists[lru]);
 }
 
+void mem_cgroup_move_lists(struct page *page,
+			   enum lru_list from, enum lru_list to)
+{
+	if (mem_cgroup_disabled())
+		return;
+	mem_cgroup_del_lru_list(page, from);
+	mem_cgroup_add_lru_list(page, to);
+}
+
 /*
  * At handling SwapCache, pc->mem_cgroup may be changed while it's linked to
  * lru because the page may.be reused after it's fully uncharged (because of
@@ -736,35 +835,6 @@ static void mem_cgroup_lru_add_after_com
 }
 
 
-void mem_cgroup_move_lists(struct page *page,
-			   enum lru_list from, enum lru_list to)
-{
-	if (mem_cgroup_disabled())
-		return;
-	mem_cgroup_del_lru_list(page, from);
-	mem_cgroup_add_lru_list(page, to);
-}
-
-int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
-{
-	int ret;
-	struct mem_cgroup *curr = NULL;
-
-	task_lock(task);
-	rcu_read_lock();
-	curr = try_get_mem_cgroup_from_mm(task->mm);
-	rcu_read_unlock();
-	task_unlock(task);
-	if (!curr)
-		return 0;
-	if (curr->use_hierarchy)
-		ret = css_is_ancestor(&curr->css, &mem->css);
-	else
-		ret = (curr == mem);
-	css_put(&curr->css);
-	return ret;
-}
-
 /*
  * prev_priority control...this will be used in memory reclaim path.
  */
@@ -847,16 +917,6 @@ int mem_cgroup_inactive_file_is_low(stru
 	return (active > inactive);
 }
 
-unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
-				       struct zone *zone,
-				       enum lru_list lru)
-{
-	int nid = zone->zone_pgdat->node_id;
-	int zid = zone_idx(zone);
-	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
-
-	return MEM_CGROUP_ZSTAT(mz, lru);
-}
 
 struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 						      struct zone *zone)
@@ -868,6 +928,22 @@ struct zone_reclaim_stat *mem_cgroup_get
 	return &mz->reclaim_stat;
 }
 
+static unsigned int get_swappiness(struct mem_cgroup *memcg)
+{
+	struct cgroup *cgrp = memcg->css.cgroup;
+	unsigned int swappiness;
+
+	/* root ? */
+	if (cgrp->parent == NULL)
+		return vm_swappiness;
+
+	spin_lock(&memcg->reclaim_param_lock);
+	swappiness = memcg->swappiness;
+	spin_unlock(&memcg->reclaim_param_lock);
+
+	return swappiness;
+}
+
 struct zone_reclaim_stat *
 mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 {
@@ -948,35 +1024,26 @@ unsigned long mem_cgroup_isolate_pages(u
 	return nr_taken;
 }
 
-#define mem_cgroup_from_res_counter(counter, member)	\
-	container_of(counter, struct mem_cgroup, member)
 
-static bool mem_cgroup_check_under_limit(struct mem_cgroup *mem)
-{
-	if (do_swap_account) {
-		if (res_counter_check_under_limit(&mem->res) &&
-			res_counter_check_under_limit(&mem->memsw))
-			return true;
-	} else
-		if (res_counter_check_under_limit(&mem->res))
-			return true;
-	return false;
-}
 
-static unsigned int get_swappiness(struct mem_cgroup *memcg)
+int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
 {
-	struct cgroup *cgrp = memcg->css.cgroup;
-	unsigned int swappiness;
-
-	/* root ? */
-	if (cgrp->parent == NULL)
-		return vm_swappiness;
-
-	spin_lock(&memcg->reclaim_param_lock);
-	swappiness = memcg->swappiness;
-	spin_unlock(&memcg->reclaim_param_lock);
+	int ret;
+	struct mem_cgroup *curr = NULL;
 
-	return swappiness;
+	task_lock(task);
+	rcu_read_lock();
+	curr = try_get_mem_cgroup_from_mm(task->mm);
+	rcu_read_unlock();
+	task_unlock(task);
+	if (!curr)
+		return 0;
+	if (curr->use_hierarchy)
+		ret = css_is_ancestor(&curr->css, &mem->css);
+	else
+		ret = (curr == mem);
+	css_put(&curr->css);
+	return ret;
 }
 
 static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
@@ -1063,6 +1130,45 @@ static int mem_cgroup_count_children(str
  	mem_cgroup_walk_tree(mem, &num, mem_cgroup_count_children_cb);
 	return num;
 }
+bool mem_cgroup_oom_called(struct task_struct *task)
+{
+	bool ret = false;
+	struct mem_cgroup *mem;
+	struct mm_struct *mm;
+
+	rcu_read_lock();
+	mm = task->mm;
+	if (!mm)
+		mm = &init_mm;
+	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
+	if (mem && time_before(jiffies, mem->last_oom_jiffies + HZ/10))
+		ret = true;
+	rcu_read_unlock();
+	return ret;
+}
+
+static int record_last_oom_cb(struct mem_cgroup *mem, void *data)
+{
+	mem->last_oom_jiffies = jiffies;
+	return 0;
+}
+
+static void record_last_oom(struct mem_cgroup *mem)
+{
+	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
+}
+
+static bool mem_cgroup_check_under_limit(struct mem_cgroup *mem)
+{
+	if (do_swap_account) {
+		if (res_counter_check_under_limit(&mem->res) &&
+			res_counter_check_under_limit(&mem->memsw))
+			return true;
+	} else
+		if (res_counter_check_under_limit(&mem->res))
+			return true;
+	return false;
+}
 
 /*
  * Visit the first child (need not be the first child as per the ordering
@@ -1190,71 +1296,95 @@ static int mem_cgroup_hierarchical_recla
 	return total;
 }
 
-bool mem_cgroup_oom_called(struct task_struct *task)
-{
-	bool ret = false;
-	struct mem_cgroup *mem;
-	struct mm_struct *mm;
-
-	rcu_read_lock();
-	mm = task->mm;
-	if (!mm)
-		mm = &init_mm;
-	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
-	if (mem && time_before(jiffies, mem->last_oom_jiffies + HZ/10))
-		ret = true;
-	rcu_read_unlock();
-	return ret;
-}
-
-static int record_last_oom_cb(struct mem_cgroup *mem, void *data)
-{
-	mem->last_oom_jiffies = jiffies;
-	return 0;
-}
-
-static void record_last_oom(struct mem_cgroup *mem)
-{
-	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
-}
-
-/*
- * Currently used to update mapped file statistics, but the routine can be
- * generalized to update other statistics as well.
- */
-void mem_cgroup_update_mapped_file_stat(struct page *page, int val)
+unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
+						gfp_t gfp_mask, int nid,
+						int zid)
 {
-	struct mem_cgroup *mem;
-	struct mem_cgroup_stat *stat;
-	struct mem_cgroup_stat_cpu *cpustat;
-	int cpu;
-	struct page_cgroup *pc;
-
-	if (!page_is_file_cache(page))
-		return;
-
-	pc = lookup_page_cgroup(page);
-	if (unlikely(!pc))
-		return;
-
-	lock_page_cgroup(pc);
-	mem = pc->mem_cgroup;
-	if (!mem)
-		goto done;
+	unsigned long nr_reclaimed = 0;
+	struct mem_cgroup_per_zone *mz, *next_mz = NULL;
+	unsigned long reclaimed;
+	int loop = 0;
+	struct mem_cgroup_tree_per_zone *mctz;
+	unsigned long long excess;
 
-	if (!PageCgroupUsed(pc))
-		goto done;
+	if (order > 0)
+		return 0;
 
+	mctz = soft_limit_tree_node_zone(nid, zid);
 	/*
-	 * Preemption is already disabled, we don't need get_cpu()
+	 * This loop can run a while, specially if mem_cgroup's continuously
+	 * keep exceeding their soft limit and putting the system under
+	 * pressure
 	 */
-	cpu = smp_processor_id();
-	stat = &mem->stat;
-	cpustat = &stat->cpustat[cpu];
+	do {
+		if (next_mz)
+			mz = next_mz;
+		else
+			mz = mem_cgroup_largest_soft_limit_node(mctz);
+		if (!mz)
+			break;
 
-	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE, val);
-done:
-	unlock_page_cgroup(pc);
+		reclaimed = mem_cgroup_hierarchical_reclaim(mz->mem, zone,
+						gfp_mask,
+						MEM_CGROUP_RECLAIM_SOFT);
+		nr_reclaimed += reclaimed;
+		spin_lock(&mctz->lock);
+
+		/*
+		 * If we failed to reclaim anything from this memory cgroup
+		 * it is time to move on to the next cgroup
+		 */
+		next_mz = NULL;
+		if (!reclaimed) {
+			do {
+				/*
+				 * Loop until we find yet another one.
+				 *
+				 * By the time we get the soft_limit lock
+				 * again, someone might have aded the
+				 * group back on the RB tree. Iterate to
+				 * make sure we get a different mem.
+				 * mem_cgroup_largest_soft_limit_node returns
+				 * NULL if no other cgroup is present on
+				 * the tree
+				 */
+				next_mz =
+				__mem_cgroup_largest_soft_limit_node(mctz);
+				if (next_mz == mz) {
+					css_put(&next_mz->mem->css);
+					next_mz = NULL;
+				} else /* next_mz == NULL or other memcg */
+					break;
+			} while (1);
+		}
+		__mem_cgroup_remove_exceeded(mz->mem, mz, mctz);
+		excess = res_counter_soft_limit_excess(&mz->mem->res);
+		/*
+		 * One school of thought says that we should not add
+		 * back the node to the tree if reclaim returns 0.
+		 * But our reclaim could return 0, simply because due
+		 * to priority we are exposing a smaller subset of
+		 * memory to reclaim from. Consider this as a longer
+		 * term TODO.
+		 */
+		/* If excess == 0, no tree ops */
+		__mem_cgroup_insert_exceeded(mz->mem, mz, mctz, excess);
+		spin_unlock(&mctz->lock);
+		css_put(&mz->mem->css);
+		loop++;
+		/*
+		 * Could not reclaim anything and there are no more
+		 * mem cgroups to try or we seem to be looping without
+		 * reclaiming anything.
+		 */
+		if (!nr_reclaimed &&
+			(next_mz == NULL ||
+			loop > MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS))
+			break;
+	} while (!nr_reclaimed);
+	if (next_mz)
+		css_put(&next_mz->mem->css);
+	return nr_reclaimed;
 }
 
 /*
@@ -1359,24 +1489,6 @@ nomem:
 	return -ENOMEM;
 }
 
-/*
- * A helper function to get mem_cgroup from ID. must be called under
- * rcu_read_lock(). The caller must check css_is_removed() or some if
- * it's concern. (dropping refcnt from swap can be called against removed
- * memcg.)
- */
-static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
-{
-	struct cgroup_subsys_state *css;
-
-	/* ID 0 is unused ID */
-	if (!id)
-		return NULL;
-	css = css_lookup(&mem_cgroup_subsys, id);
-	if (!css)
-		return NULL;
-	return container_of(css, struct mem_cgroup, css);
-}
 
 static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
 {
@@ -1420,189 +1532,46 @@ static void __mem_cgroup_commit_charge(s
 {
 	/* try_charge() can return NULL to *memcg, taking care of it. */
 	if (!mem)
-		return;
-
-	lock_page_cgroup(pc);
-	if (unlikely(PageCgroupUsed(pc))) {
-		unlock_page_cgroup(pc);
-		if (!mem_cgroup_is_root(mem)) {
-			res_counter_uncharge(&mem->res, PAGE_SIZE);
-			if (do_swap_account)
-				res_counter_uncharge(&mem->memsw, PAGE_SIZE);
-		}
-		css_put(&mem->css);
-		return;
-	}
-
-	pc->mem_cgroup = mem;
-	/*
-	 * We access a page_cgroup asynchronously without lock_page_cgroup().
-	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
-	 * is accessed after testing USED bit. To make pc->mem_cgroup visible
-	 * before USED bit, we need memory barrier here.
-	 * See mem_cgroup_add_lru_list(), etc.
- 	 */
-	smp_wmb();
-	switch (ctype) {
-	case MEM_CGROUP_CHARGE_TYPE_CACHE:
-	case MEM_CGROUP_CHARGE_TYPE_SHMEM:
-		SetPageCgroupCache(pc);
-		SetPageCgroupUsed(pc);
-		break;
-	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
-		ClearPageCgroupCache(pc);
-		SetPageCgroupUsed(pc);
-		break;
-	default:
-		break;
-	}
-
-	mem_cgroup_charge_statistics(mem, pc, true);
-
-	unlock_page_cgroup(pc);
-}
-
-/**
- * mem_cgroup_move_account - move account of the page
- * @pc:	page_cgroup of the page.
- * @from: mem_cgroup which the page is moved from.
- * @to:	mem_cgroup which the page is moved to. @from != @to.
- *
- * The caller must confirm following.
- * - page is not on LRU (isolate_page() is useful.)
- *
- * returns 0 at success,
- * returns -EBUSY when lock is busy or "pc" is unstable.
- *
- * This function does "uncharge" from old cgroup but doesn't do "charge" to
- * new cgroup. It should be done by a caller.
- */
-
-static int mem_cgroup_move_account(struct page_cgroup *pc,
-	struct mem_cgroup *from, struct mem_cgroup *to)
-{
-	struct mem_cgroup_per_zone *from_mz, *to_mz;
-	int nid, zid;
-	int ret = -EBUSY;
-	struct page *page;
-	int cpu;
-	struct mem_cgroup_stat *stat;
-	struct mem_cgroup_stat_cpu *cpustat;
-
-	VM_BUG_ON(from == to);
-	VM_BUG_ON(PageLRU(pc->page));
-
-	nid = page_cgroup_nid(pc);
-	zid = page_cgroup_zid(pc);
-	from_mz =  mem_cgroup_zoneinfo(from, nid, zid);
-	to_mz =  mem_cgroup_zoneinfo(to, nid, zid);
-
-	if (!trylock_page_cgroup(pc))
-		return ret;
-
-	if (!PageCgroupUsed(pc))
-		goto out;
-
-	if (pc->mem_cgroup != from)
-		goto out;
-
-	if (!mem_cgroup_is_root(from))
-		res_counter_uncharge(&from->res, PAGE_SIZE);
-	mem_cgroup_charge_statistics(from, pc, false);
-
-	page = pc->page;
-	if (page_is_file_cache(page) && page_mapped(page)) {
-		cpu = smp_processor_id();
-		/* Update mapped_file data for mem_cgroup "from" */
-		stat = &from->stat;
-		cpustat = &stat->cpustat[cpu];
-		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE,
-						-1);
-
-		/* Update mapped_file data for mem_cgroup "to" */
-		stat = &to->stat;
-		cpustat = &stat->cpustat[cpu];
-		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE,
-						1);
-	}
-
-	if (do_swap_account && !mem_cgroup_is_root(from))
-		res_counter_uncharge(&from->memsw, PAGE_SIZE);
-	css_put(&from->css);
-
-	css_get(&to->css);
-	pc->mem_cgroup = to;
-	mem_cgroup_charge_statistics(to, pc, true);
-	ret = 0;
-out:
-	unlock_page_cgroup(pc);
-	/*
-	 * We charges against "to" which may not have any tasks. Then, "to"
-	 * can be under rmdir(). But in current implementation, caller of
-	 * this function is just force_empty() and it's garanteed that
-	 * "to" is never removed. So, we don't check rmdir status here.
-	 */
-	return ret;
-}
-
-/*
- * move charges to its parent.
- */
-
-static int mem_cgroup_move_parent(struct page_cgroup *pc,
-				  struct mem_cgroup *child,
-				  gfp_t gfp_mask)
-{
-	struct page *page = pc->page;
-	struct cgroup *cg = child->css.cgroup;
-	struct cgroup *pcg = cg->parent;
-	struct mem_cgroup *parent;
-	int ret;
-
-	/* Is ROOT ? */
-	if (!pcg)
-		return -EINVAL;
-
-
-	parent = mem_cgroup_from_cont(pcg);
-
-
-	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false, page);
-	if (ret || !parent)
-		return ret;
-
-	if (!get_page_unless_zero(page)) {
-		ret = -EBUSY;
-		goto uncharge;
-	}
-
-	ret = isolate_lru_page(page);
-
-	if (ret)
-		goto cancel;
-
-	ret = mem_cgroup_move_account(pc, child, parent);
+		return;
 
-	putback_lru_page(page);
-	if (!ret) {
-		put_page(page);
-		/* drop extra refcnt by try_charge() */
-		css_put(&parent->css);
-		return 0;
+	lock_page_cgroup(pc);
+	if (unlikely(PageCgroupUsed(pc))) {
+		unlock_page_cgroup(pc);
+		if (!mem_cgroup_is_root(mem)) {
+			res_counter_uncharge(&mem->res, PAGE_SIZE);
+			if (do_swap_account)
+				res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+		}
+		css_put(&mem->css);
+		return;
 	}
 
-cancel:
-	put_page(page);
-uncharge:
-	/* drop extra refcnt by try_charge() */
-	css_put(&parent->css);
-	/* uncharge if move fails */
-	if (!mem_cgroup_is_root(parent)) {
-		res_counter_uncharge(&parent->res, PAGE_SIZE);
-		if (do_swap_account)
-			res_counter_uncharge(&parent->memsw, PAGE_SIZE);
+	pc->mem_cgroup = mem;
+	/*
+	 * We access a page_cgroup asynchronously without lock_page_cgroup().
+	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
+	 * is accessed after testing USED bit. To make pc->mem_cgroup visible
+	 * before USED bit, we need memory barrier here.
+	 * See mem_cgroup_add_lru_list(), etc.
+	 */
+	smp_wmb();
+	switch (ctype) {
+	case MEM_CGROUP_CHARGE_TYPE_CACHE:
+	case MEM_CGROUP_CHARGE_TYPE_SHMEM:
+		SetPageCgroupCache(pc);
+		SetPageCgroupUsed(pc);
+		break;
+	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
+		ClearPageCgroupCache(pc);
+		SetPageCgroupUsed(pc);
+		break;
+	default:
+		break;
 	}
-	return ret;
+
+	mem_cgroup_charge_statistics(mem, pc, true);
+
+	unlock_page_cgroup(pc);
 }
 
 /*
@@ -1981,6 +1950,32 @@ void mem_cgroup_uncharge_swap(swp_entry_
 #endif
 
 /*
+ * A call to try to shrink memory usage on charge failure at shmem's swapin.
+ * Calling hierarchical_reclaim is not enough because we should update
+ * last_oom_jiffies to prevent pagefault_out_of_memory from invoking global OOM.
+ * Moreover considering hierarchy, we should reclaim from the mem_over_limit,
+ * not from the memcg which this page would be charged to.
+ * try_charge_swapin does all of these works properly.
+ */
+int mem_cgroup_shmem_charge_fallback(struct page *page,
+			    struct mm_struct *mm,
+			    gfp_t gfp_mask)
+{
+	struct mem_cgroup *mem = NULL;
+	int ret;
+
+	if (mem_cgroup_disabled())
+		return 0;
+
+	ret = mem_cgroup_try_charge_swapin(mm, page, gfp_mask, &mem);
+	if (!ret)
+		mem_cgroup_cancel_charge_swapin(mem); /* it does !mem check */
+
+	return ret;
+}
+
+
+/*
  * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
  * page belongs to.
  */
@@ -2030,70 +2025,231 @@ void mem_cgroup_end_migration(struct mem
 		unused = oldpage;
 	}
 
-	if (PageAnon(target))
-		ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
-	else if (page_is_file_cache(target))
-		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
-	else
-		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
-
-	/* unused page is not on radix-tree now. */
-	if (unused)
-		__mem_cgroup_uncharge_common(unused, ctype);
+	if (PageAnon(target))
+		ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
+	else if (page_is_file_cache(target))
+		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
+	else
+		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
+
+	/* unused page is not on radix-tree now. */
+	if (unused)
+		__mem_cgroup_uncharge_common(unused, ctype);
+
+	pc = lookup_page_cgroup(target);
+	/*
+	 * __mem_cgroup_commit_charge() check PCG_USED bit of page_cgroup.
+	 * So, double-counting is effectively avoided.
+	 */
+	__mem_cgroup_commit_charge(mem, pc, ctype);
+
+	/*
+	 * Both of oldpage and newpage are still under lock_page().
+	 * Then, we don't have to care about race in radix-tree.
+	 * But we have to be careful that this page is unmapped or not.
+	 *
+	 * There is a case for !page_mapped(). At the start of
+	 * migration, oldpage was mapped. But now, it's zapped.
+	 * But we know *target* page is not freed/reused under us.
+	 * mem_cgroup_uncharge_page() does all necessary checks.
+	 */
+	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
+		mem_cgroup_uncharge_page(target);
+	/*
+	 * At migration, we may charge account against cgroup which has no tasks
+	 * So, rmdir()->pre_destroy() can be called while we do this charge.
+	 * In that case, we need to call pre_destroy() again. check it here.
+	 */
+	cgroup_release_and_wakeup_rmdir(&mem->css);
+}
+
+
+/**
+ * mem_cgroup_move_account - move account of the page
+ * @pc:	page_cgroup of the page.
+ * @from: mem_cgroup which the page is moved from.
+ * @to:	mem_cgroup which the page is moved to. @from != @to.
+ *
+ * The caller must confirm following.
+ * - page is not on LRU (isolate_page() is useful.)
+ *
+ * returns 0 at success,
+ * returns -EBUSY when lock is busy or "pc" is unstable.
+ *
+ * This function does "uncharge" from old cgroup but doesn't do "charge" to
+ * new cgroup. It should be done by a caller.
+ */
+
+static int mem_cgroup_move_account(struct page_cgroup *pc,
+	struct mem_cgroup *from, struct mem_cgroup *to)
+{
+	struct mem_cgroup_per_zone *from_mz, *to_mz;
+	int nid, zid;
+	int ret = -EBUSY;
+	struct page *page;
+	int cpu;
+	struct mem_cgroup_stat *stat;
+	struct mem_cgroup_stat_cpu *cpustat;
+
+	VM_BUG_ON(from == to);
+	VM_BUG_ON(PageLRU(pc->page));
+
+	nid = page_cgroup_nid(pc);
+	zid = page_cgroup_zid(pc);
+	from_mz =  mem_cgroup_zoneinfo(from, nid, zid);
+	to_mz =  mem_cgroup_zoneinfo(to, nid, zid);
+
+	if (!trylock_page_cgroup(pc))
+		return ret;
+
+	if (!PageCgroupUsed(pc))
+		goto out;
+
+	if (pc->mem_cgroup != from)
+		goto out;
+
+	if (!mem_cgroup_is_root(from))
+		res_counter_uncharge(&from->res, PAGE_SIZE);
+	mem_cgroup_charge_statistics(from, pc, false);
+
+	page = pc->page;
+	if (page_is_file_cache(page) && page_mapped(page)) {
+		cpu = smp_processor_id();
+		/* Update mapped_file data for mem_cgroup "from" */
+		stat = &from->stat;
+		cpustat = &stat->cpustat[cpu];
+		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE,
+						-1);
+
+		/* Update mapped_file data for mem_cgroup "to" */
+		stat = &to->stat;
+		cpustat = &stat->cpustat[cpu];
+		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE,
+						1);
+	}
+
+	if (do_swap_account && !mem_cgroup_is_root(from))
+		res_counter_uncharge(&from->memsw, PAGE_SIZE);
+	css_put(&from->css);
+
+	css_get(&to->css);
+	pc->mem_cgroup = to;
+	mem_cgroup_charge_statistics(to, pc, true);
+	ret = 0;
+out:
+	unlock_page_cgroup(pc);
+	/*
+	 * We charges against "to" which may not have any tasks. Then, "to"
+	 * can be under rmdir(). But in current implementation, caller of
+	 * this function is just force_empty() and it's garanteed that
+	 * "to" is never removed. So, we don't check rmdir status here.
+	 */
+	return ret;
+}
+
+/*
+ * move charges to its parent.
+ */
+
+static int mem_cgroup_move_parent(struct page_cgroup *pc,
+				  struct mem_cgroup *child,
+				  gfp_t gfp_mask)
+{
+	struct page *page = pc->page;
+	struct cgroup *cg = child->css.cgroup;
+	struct cgroup *pcg = cg->parent;
+	struct mem_cgroup *parent;
+	int ret;
+
+	/* Is ROOT ? */
+	if (!pcg)
+		return -EINVAL;
+
+
+	parent = mem_cgroup_from_cont(pcg);
+
+
+	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false, page);
+	if (ret || !parent)
+		return ret;
+
+	if (!get_page_unless_zero(page)) {
+		ret = -EBUSY;
+		goto uncharge;
+	}
+
+	ret = isolate_lru_page(page);
+
+	if (ret)
+		goto cancel;
+
+	ret = mem_cgroup_move_account(pc, child, parent);
+
+	putback_lru_page(page);
+	if (!ret) {
+		put_page(page);
+		/* drop extra refcnt by try_charge() */
+		css_put(&parent->css);
+		return 0;
+	}
+
+cancel:
+	put_page(page);
+uncharge:
+	/* drop extra refcnt by try_charge() */
+	css_put(&parent->css);
+	/* uncharge if move fails */
+	if (!mem_cgroup_is_root(parent)) {
+		res_counter_uncharge(&parent->res, PAGE_SIZE);
+		if (do_swap_account)
+			res_counter_uncharge(&parent->memsw, PAGE_SIZE);
+	}
+	return ret;
+}
+
+/*
+ * For User Interfaces.
+ */
+static DEFINE_MUTEX(set_limit_mutex);
 
-	pc = lookup_page_cgroup(target);
-	/*
-	 * __mem_cgroup_commit_charge() check PCG_USED bit of page_cgroup.
-	 * So, double-counting is effectively avoided.
-	 */
-	__mem_cgroup_commit_charge(mem, pc, ctype);
+static u64 mem_cgroup_swappiness_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
 
-	/*
-	 * Both of oldpage and newpage are still under lock_page().
-	 * Then, we don't have to care about race in radix-tree.
-	 * But we have to be careful that this page is unmapped or not.
-	 *
-	 * There is a case for !page_mapped(). At the start of
-	 * migration, oldpage was mapped. But now, it's zapped.
-	 * But we know *target* page is not freed/reused under us.
-	 * mem_cgroup_uncharge_page() does all necessary checks.
-	 */
-	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
-		mem_cgroup_uncharge_page(target);
-	/*
-	 * At migration, we may charge account against cgroup which has no tasks
-	 * So, rmdir()->pre_destroy() can be called while we do this charge.
-	 * In that case, we need to call pre_destroy() again. check it here.
-	 */
-	cgroup_release_and_wakeup_rmdir(&mem->css);
+	return get_swappiness(memcg);
 }
 
-/*
- * A call to try to shrink memory usage on charge failure at shmem's swapin.
- * Calling hierarchical_reclaim is not enough because we should update
- * last_oom_jiffies to prevent pagefault_out_of_memory from invoking global OOM.
- * Moreover considering hierarchy, we should reclaim from the mem_over_limit,
- * not from the memcg which this page would be charged to.
- * try_charge_swapin does all of these works properly.
- */
-int mem_cgroup_shmem_charge_fallback(struct page *page,
-			    struct mm_struct *mm,
-			    gfp_t gfp_mask)
+static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
+				       u64 val)
 {
-	struct mem_cgroup *mem = NULL;
-	int ret;
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *parent;
 
-	if (mem_cgroup_disabled())
-		return 0;
+	if (val > 100)
+		return -EINVAL;
 
-	ret = mem_cgroup_try_charge_swapin(mm, page, gfp_mask, &mem);
-	if (!ret)
-		mem_cgroup_cancel_charge_swapin(mem); /* it does !mem check */
+	if (cgrp->parent == NULL)
+		return -EINVAL;
 
-	return ret;
-}
+	parent = mem_cgroup_from_cont(cgrp->parent);
 
-static DEFINE_MUTEX(set_limit_mutex);
+	cgroup_lock();
+
+	/* If under hierarchy, only empty-root can set this value */
+	if ((parent->use_hierarchy) ||
+	    (memcg->use_hierarchy && !list_empty(&cgrp->children))) {
+		cgroup_unlock();
+		return -EINVAL;
+	}
+
+	spin_lock(&memcg->reclaim_param_lock);
+	memcg->swappiness = val;
+	spin_unlock(&memcg->reclaim_param_lock);
+
+	cgroup_unlock();
+
+	return 0;
+}
 
 static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 				unsigned long long val)
@@ -2210,96 +2366,6 @@ static int mem_cgroup_resize_memsw_limit
 	return ret;
 }
 
-unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
-						gfp_t gfp_mask, int nid,
-						int zid)
-{
-	unsigned long nr_reclaimed = 0;
-	struct mem_cgroup_per_zone *mz, *next_mz = NULL;
-	unsigned long reclaimed;
-	int loop = 0;
-	struct mem_cgroup_tree_per_zone *mctz;
-	unsigned long long excess;
-
-	if (order > 0)
-		return 0;
-
-	mctz = soft_limit_tree_node_zone(nid, zid);
-	/*
-	 * This loop can run a while, specially if mem_cgroup's continuously
-	 * keep exceeding their soft limit and putting the system under
-	 * pressure
-	 */
-	do {
-		if (next_mz)
-			mz = next_mz;
-		else
-			mz = mem_cgroup_largest_soft_limit_node(mctz);
-		if (!mz)
-			break;
-
-		reclaimed = mem_cgroup_hierarchical_reclaim(mz->mem, zone,
-						gfp_mask,
-						MEM_CGROUP_RECLAIM_SOFT);
-		nr_reclaimed += reclaimed;
-		spin_lock(&mctz->lock);
-
-		/*
-		 * If we failed to reclaim anything from this memory cgroup
-		 * it is time to move on to the next cgroup
-		 */
-		next_mz = NULL;
-		if (!reclaimed) {
-			do {
-				/*
-				 * Loop until we find yet another one.
-				 *
-				 * By the time we get the soft_limit lock
-				 * again, someone might have aded the
-				 * group back on the RB tree. Iterate to
-				 * make sure we get a different mem.
-				 * mem_cgroup_largest_soft_limit_node returns
-				 * NULL if no other cgroup is present on
-				 * the tree
-				 */
-				next_mz =
-				__mem_cgroup_largest_soft_limit_node(mctz);
-				if (next_mz == mz) {
-					css_put(&next_mz->mem->css);
-					next_mz = NULL;
-				} else /* next_mz == NULL or other memcg */
-					break;
-			} while (1);
-		}
-		__mem_cgroup_remove_exceeded(mz->mem, mz, mctz);
-		excess = res_counter_soft_limit_excess(&mz->mem->res);
-		/*
-		 * One school of thought says that we should not add
-		 * back the node to the tree if reclaim returns 0.
-		 * But our reclaim could return 0, simply because due
-		 * to priority we are exposing a smaller subset of
-		 * memory to reclaim from. Consider this as a longer
-		 * term TODO.
-		 */
-		/* If excess == 0, no tree ops */
-		__mem_cgroup_insert_exceeded(mz->mem, mz, mctz, excess);
-		spin_unlock(&mctz->lock);
-		css_put(&mz->mem->css);
-		loop++;
-		/*
-		 * Could not reclaim anything and there are no more
-		 * mem cgroups to try or we seem to be looping without
-		 * reclaiming anything.
-		 */
-		if (!nr_reclaimed &&
-			(next_mz == NULL ||
-			loop > MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS))
-			break;
-	} while (!nr_reclaimed);
-	if (next_mz)
-		css_put(&next_mz->mem->css);
-	return nr_reclaimed;
-}
 
 /*
  * This routine traverse page_cgroup in given list and drop them all.
@@ -2484,7 +2550,6 @@ static int mem_cgroup_hierarchy_write(st
 
 	return retval;
 }
-
 struct mem_cgroup_idx_data {
 	s64 val;
 	enum mem_cgroup_stat_index idx;
@@ -2655,6 +2720,7 @@ static int mem_cgroup_reset(struct cgrou
 }
 
 
+
 /* For read statistics */
 enum {
 	MCS_CACHE,
@@ -2799,44 +2865,6 @@ static int mem_control_stat_show(struct 
 	return 0;
 }
 
-static u64 mem_cgroup_swappiness_read(struct cgroup *cgrp, struct cftype *cft)
-{
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
-
-	return get_swappiness(memcg);
-}
-
-static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
-				       u64 val)
-{
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
-	struct mem_cgroup *parent;
-
-	if (val > 100)
-		return -EINVAL;
-
-	if (cgrp->parent == NULL)
-		return -EINVAL;
-
-	parent = mem_cgroup_from_cont(cgrp->parent);
-
-	cgroup_lock();
-
-	/* If under hierarchy, only empty-root can set this value */
-	if ((parent->use_hierarchy) ||
-	    (memcg->use_hierarchy && !list_empty(&cgrp->children))) {
-		cgroup_unlock();
-		return -EINVAL;
-	}
-
-	spin_lock(&memcg->reclaim_param_lock);
-	memcg->swappiness = val;
-	spin_unlock(&memcg->reclaim_param_lock);
-
-	cgroup_unlock();
-
-	return 0;
-}
 
 
 static struct cftype mem_cgroup_files[] = {
@@ -2916,6 +2944,27 @@ static struct cftype memsw_cgroup_files[
 	},
 };
 
+/*
+ * Moving tasks.
+ */
+static void mem_cgroup_move_task(struct cgroup_subsys *ss,
+				struct cgroup *cont,
+				struct cgroup *old_cont,
+				struct task_struct *p,
+				bool threadgroup)
+{
+	mutex_lock(&memcg_tasklist);
+	/*
+	 * FIXME: It's better to move charges of this process from old
+	 * memcg to new memcg. But it's just on TODO-List now.
+	 */
+	mutex_unlock(&memcg_tasklist);
+}
+
+/*
+ * memcg creation and destruction.
+ */
+
 static int register_memsw_files(struct cgroup *cont, struct cgroup_subsys *ss)
 {
 	if (!do_swap_account)
@@ -3163,20 +3212,6 @@ static int mem_cgroup_populate(struct cg
 	return ret;
 }
 
-static void mem_cgroup_move_task(struct cgroup_subsys *ss,
-				struct cgroup *cont,
-				struct cgroup *old_cont,
-				struct task_struct *p,
-				bool threadgroup)
-{
-	mutex_lock(&memcg_tasklist);
-	/*
-	 * FIXME: It's better to move charges of this process from old
-	 * memcg to new memcg. But it's just on TODO-List now.
-	 */
-	mutex_unlock(&memcg_tasklist);
-}
-
 struct cgroup_subsys mem_cgroup_subsys = {
 	.name = "memory",
 	.subsys_id = mem_cgroup_subsys_id,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
