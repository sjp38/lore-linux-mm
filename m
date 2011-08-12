Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1C1D9900137
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 03:06:46 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp01.in.ibm.com (8.14.4/8.13.1) with ESMTP id p7C76QAd014237
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 12:36:26 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7C76ODq2969788
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 12:36:25 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7C76NLB003553
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 17:06:24 +1000
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Date: Fri, 12 Aug 2011 12:36:23 +0530
Message-Id: <20110812070623.28939.4733.sendpatchset@oc5400248562.ibm.com>
Subject: [PATCH V2 1/1][cleanup] memcg: renaming of mem variable to memcg
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arend van Spriel <arend@broadcom.com>, Greg Kroah-Hartman <gregkh@suse.de>, "David S. Miller" <davem@davemloft.net>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, "John W. Linville" <linville@tuxdriver.com>, Mauro Carvalho Chehab <mchehab@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>

 The memcg code sometimes uses "struct mem_cgroup *mem" and sometimes uses
 "struct mem_cgroup *memcg". This patch renames all mem variables to memcg in
 source file.

Testing : Compile tested with following configurations.
1) make defconfig ARCH=i386 + CONFIG_CGROUP_MEM_RES_CTLR=y 
CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED=y

Binary size Before patch
========================
   text	   data	    bss	    dec	    hex	filename
8911169	 520464	1884160	11315793	 acaa51	vmlinux

Binary Size After patch
=======================
   text	   data	    bss	    dec	    hex	filename
8911169	 520464	1884160	11315793	 acaa51	vmlinux

2) make defconfig ARCH=i386 + CONFIG_CGROUP_MEM_RES_CTLR=y
CONFIG_CGROUP_MEM_RES_CTLR_SWAP=n CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED=n

3) make defconfig ARCH=i386  CONFIG_CGROUP_MEM_RES_CTLR=n
CONFIG_CGROUP_MEM_RES_CTLR_SWAP=n CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED=n

Other sanity check:
Bootable configuration on x86 (T60p)  with  CONFIG_CGROUP_MEM_RES_CTLR=y 
CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED=y
is tesed with basic mounting of memcgroup, creation of child and parallel fault.
mkdir -p /cgroup
mount -t cgroup none /cgroup -o memory
mkdir /cgroup/0
echo $$ > /cgroup/0/tasks
time ./parallel_fault 2 100000 32

real	0m0.025s
user	0m0.001s
sys	0m0.033s

From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
Reference to previous posting :
https://lkml.org/lkml/2011/8/10/363

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5633f51..fb1ed1c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -88,8 +88,8 @@ extern void mem_cgroup_uncharge_end(void);
 extern void mem_cgroup_uncharge_page(struct page *page);
 extern void mem_cgroup_uncharge_cache_page(struct page *page);
 
-extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
-int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
+extern void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask);
+int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg);
 
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
@@ -98,19 +98,19 @@ extern struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm);
 static inline
 int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *memcg;
 	rcu_read_lock();
-	mem = mem_cgroup_from_task(rcu_dereference((mm)->owner));
+	memcg = mem_cgroup_from_task(rcu_dereference((mm)->owner));
 	rcu_read_unlock();
-	return cgroup == mem;
+	return cgroup == memcg;
 }
 
-extern struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem);
+extern struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg);
 
 extern int
 mem_cgroup_prepare_migration(struct page *page,
 	struct page *newpage, struct mem_cgroup **ptr, gfp_t gfp_mask);
-extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
+extern void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 	struct page *oldpage, struct page *newpage, bool migration_ok);
 
 /*
@@ -167,7 +167,7 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask,
 						unsigned long *total_scanned);
-u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
+u64 mem_cgroup_get_limit(struct mem_cgroup *memcg);
 
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -263,18 +263,20 @@ static inline struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm
 	return NULL;
 }
 
-static inline int mm_match_cgroup(struct mm_struct *mm, struct mem_cgroup *mem)
+static inline int mm_match_cgroup(struct mm_struct *mm,
+		struct mem_cgroup *memcg)
 {
 	return 1;
 }
 
 static inline int task_in_mem_cgroup(struct task_struct *task,
-				     const struct mem_cgroup *mem)
+				     const struct mem_cgroup *memcg)
 {
 	return 1;
 }
 
-static inline struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem)
+static inline struct cgroup_subsys_state
+		*mem_cgroup_css(struct mem_cgroup *memcg)
 {
 	return NULL;
 }
@@ -286,22 +288,22 @@ mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
 	return 0;
 }
 
-static inline void mem_cgroup_end_migration(struct mem_cgroup *mem,
+static inline void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 		struct page *oldpage, struct page *newpage, bool migration_ok)
 {
 }
 
-static inline int mem_cgroup_get_reclaim_priority(struct mem_cgroup *mem)
+static inline int mem_cgroup_get_reclaim_priority(struct mem_cgroup *memcg)
 {
 	return 0;
 }
 
-static inline void mem_cgroup_note_reclaim_priority(struct mem_cgroup *mem,
+static inline void mem_cgroup_note_reclaim_priority(struct mem_cgroup *memcg,
 						int priority)
 {
 }
 
-static inline void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem,
+static inline void mem_cgroup_record_reclaim_priority(struct mem_cgroup *memcg,
 						int priority)
 {
 }
@@ -367,7 +369,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 }
 
 static inline
-u64 mem_cgroup_get_limit(struct mem_cgroup *mem)
+u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
 {
 	return 0;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1a93393..fda53b4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -202,8 +202,8 @@ struct mem_cgroup_eventfd_list {
 	struct eventfd_ctx *eventfd;
 };
 
-static void mem_cgroup_threshold(struct mem_cgroup *mem);
-static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
+static void mem_cgroup_threshold(struct mem_cgroup *memcg);
+static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
 
 enum {
 	SCAN_BY_LIMIT,
@@ -408,29 +408,29 @@ enum charge_type {
 #define MEM_CGROUP_RECLAIM_SOFT_BIT	0x2
 #define MEM_CGROUP_RECLAIM_SOFT		(1 << MEM_CGROUP_RECLAIM_SOFT_BIT)
 
-static void mem_cgroup_get(struct mem_cgroup *mem);
-static void mem_cgroup_put(struct mem_cgroup *mem);
-static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
-static void drain_all_stock_async(struct mem_cgroup *mem);
+static void mem_cgroup_get(struct mem_cgroup *memcg);
+static void mem_cgroup_put(struct mem_cgroup *memcg);
+static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg);
+static void drain_all_stock_async(struct mem_cgroup *memcg);
 
 static struct mem_cgroup_per_zone *
-mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
+mem_cgroup_zoneinfo(struct mem_cgroup *memcg, int nid, int zid)
 {
-	return &mem->info.nodeinfo[nid]->zoneinfo[zid];
+	return &memcg->info.nodeinfo[nid]->zoneinfo[zid];
 }
 
-struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem)
+struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg)
 {
-	return &mem->css;
+	return &memcg->css;
 }
 
 static struct mem_cgroup_per_zone *
-page_cgroup_zoneinfo(struct mem_cgroup *mem, struct page *page)
+page_cgroup_zoneinfo(struct mem_cgroup *memcg, struct page *page)
 {
 	int nid = page_to_nid(page);
 	int zid = page_zonenum(page);
 
-	return mem_cgroup_zoneinfo(mem, nid, zid);
+	return mem_cgroup_zoneinfo(memcg, nid, zid);
 }
 
 static struct mem_cgroup_tree_per_zone *
@@ -449,7 +449,7 @@ soft_limit_tree_from_page(struct page *page)
 }
 
 static void
-__mem_cgroup_insert_exceeded(struct mem_cgroup *mem,
+__mem_cgroup_insert_exceeded(struct mem_cgroup *memcg,
 				struct mem_cgroup_per_zone *mz,
 				struct mem_cgroup_tree_per_zone *mctz,
 				unsigned long long new_usage_in_excess)
@@ -483,7 +483,7 @@ __mem_cgroup_insert_exceeded(struct mem_cgroup *mem,
 }
 
 static void
-__mem_cgroup_remove_exceeded(struct mem_cgroup *mem,
+__mem_cgroup_remove_exceeded(struct mem_cgroup *memcg,
 				struct mem_cgroup_per_zone *mz,
 				struct mem_cgroup_tree_per_zone *mctz)
 {
@@ -494,17 +494,17 @@ __mem_cgroup_remove_exceeded(struct mem_cgroup *mem,
 }
 
 static void
-mem_cgroup_remove_exceeded(struct mem_cgroup *mem,
+mem_cgroup_remove_exceeded(struct mem_cgroup *memcg,
 				struct mem_cgroup_per_zone *mz,
 				struct mem_cgroup_tree_per_zone *mctz)
 {
 	spin_lock(&mctz->lock);
-	__mem_cgroup_remove_exceeded(mem, mz, mctz);
+	__mem_cgroup_remove_exceeded(memcg, mz, mctz);
 	spin_unlock(&mctz->lock);
 }
 
 
-static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page *page)
+static void mem_cgroup_update_tree(struct mem_cgroup *memcg, struct page *page)
 {
 	unsigned long long excess;
 	struct mem_cgroup_per_zone *mz;
@@ -517,9 +517,9 @@ static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page *page)
 	 * Necessary to update all ancestors when hierarchy is used.
 	 * because their event counter is not touched.
 	 */
-	for (; mem; mem = parent_mem_cgroup(mem)) {
-		mz = mem_cgroup_zoneinfo(mem, nid, zid);
-		excess = res_counter_soft_limit_excess(&mem->res);
+	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
+		mz = mem_cgroup_zoneinfo(memcg, nid, zid);
+		excess = res_counter_soft_limit_excess(&memcg->res);
 		/*
 		 * We have to update the tree if mz is on RB-tree or
 		 * mem is over its softlimit.
@@ -528,18 +528,18 @@ static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page *page)
 			spin_lock(&mctz->lock);
 			/* if on-tree, remove it */
 			if (mz->on_tree)
-				__mem_cgroup_remove_exceeded(mem, mz, mctz);
+				__mem_cgroup_remove_exceeded(memcg, mz, mctz);
 			/*
 			 * Insert again. mz->usage_in_excess will be updated.
 			 * If excess is 0, no tree ops.
 			 */
-			__mem_cgroup_insert_exceeded(mem, mz, mctz, excess);
+			__mem_cgroup_insert_exceeded(memcg, mz, mctz, excess);
 			spin_unlock(&mctz->lock);
 		}
 	}
 }
 
-static void mem_cgroup_remove_from_trees(struct mem_cgroup *mem)
+static void mem_cgroup_remove_from_trees(struct mem_cgroup *memcg)
 {
 	int node, zone;
 	struct mem_cgroup_per_zone *mz;
@@ -547,9 +547,9 @@ static void mem_cgroup_remove_from_trees(struct mem_cgroup *mem)
 
 	for_each_node_state(node, N_POSSIBLE) {
 		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
-			mz = mem_cgroup_zoneinfo(mem, node, zone);
+			mz = mem_cgroup_zoneinfo(memcg, node, zone);
 			mctz = soft_limit_tree_node_zone(node, zone);
-			mem_cgroup_remove_exceeded(mem, mz, mctz);
+			mem_cgroup_remove_exceeded(memcg, mz, mctz);
 		}
 	}
 }
@@ -610,7 +610,7 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
  * common workload, threashold and synchonization as vmstat[] should be
  * implemented.
  */
-static long mem_cgroup_read_stat(struct mem_cgroup *mem,
+static long mem_cgroup_read_stat(struct mem_cgroup *memcg,
 				 enum mem_cgroup_stat_index idx)
 {
 	long val = 0;
@@ -618,81 +618,83 @@ static long mem_cgroup_read_stat(struct mem_cgroup *mem,
 
 	get_online_cpus();
 	for_each_online_cpu(cpu)
-		val += per_cpu(mem->stat->count[idx], cpu);
+		val += per_cpu(memcg->stat->count[idx], cpu);
 #ifdef CONFIG_HOTPLUG_CPU
-	spin_lock(&mem->pcp_counter_lock);
-	val += mem->nocpu_base.count[idx];
-	spin_unlock(&mem->pcp_counter_lock);
+	spin_lock(&memcg->pcp_counter_lock);
+	val += memcg->nocpu_base.count[idx];
+	spin_unlock(&memcg->pcp_counter_lock);
 #endif
 	put_online_cpus();
 	return val;
 }
 
-static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
+static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
 					 bool charge)
 {
 	int val = (charge) ? 1 : -1;
-	this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_SWAPOUT], val);
+	this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SWAPOUT], val);
 }
 
-void mem_cgroup_pgfault(struct mem_cgroup *mem, int val)
+void mem_cgroup_pgfault(struct mem_cgroup *memcg, int val)
 {
-	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_PGFAULT], val);
+	this_cpu_add(memcg->stat->events[MEM_CGROUP_EVENTS_PGFAULT], val);
 }
 
-void mem_cgroup_pgmajfault(struct mem_cgroup *mem, int val)
+void mem_cgroup_pgmajfault(struct mem_cgroup *memcg, int val)
 {
-	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_PGMAJFAULT], val);
+	this_cpu_add(memcg->stat->events[MEM_CGROUP_EVENTS_PGMAJFAULT], val);
 }
 
-static unsigned long mem_cgroup_read_events(struct mem_cgroup *mem,
+static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
 					    enum mem_cgroup_events_index idx)
 {
 	unsigned long val = 0;
 	int cpu;
 
 	for_each_online_cpu(cpu)
-		val += per_cpu(mem->stat->events[idx], cpu);
+		val += per_cpu(memcg->stat->events[idx], cpu);
 #ifdef CONFIG_HOTPLUG_CPU
-	spin_lock(&mem->pcp_counter_lock);
-	val += mem->nocpu_base.events[idx];
-	spin_unlock(&mem->pcp_counter_lock);
+	spin_lock(&memcg->pcp_counter_lock);
+	val += memcg->nocpu_base.events[idx];
+	spin_unlock(&memcg->pcp_counter_lock);
 #endif
 	return val;
 }
 
-static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
+static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 					 bool file, int nr_pages)
 {
 	preempt_disable();
 
 	if (file)
-		__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_CACHE], nr_pages);
+		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_CACHE],
+				nr_pages);
 	else
-		__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_RSS], nr_pages);
+		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_RSS],
+				nr_pages);
 
 	/* pagein of a big page is an event. So, ignore page size */
 	if (nr_pages > 0)
-		__this_cpu_inc(mem->stat->events[MEM_CGROUP_EVENTS_PGPGIN]);
+		__this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGIN]);
 	else {
-		__this_cpu_inc(mem->stat->events[MEM_CGROUP_EVENTS_PGPGOUT]);
+		__this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGOUT]);
 		nr_pages = -nr_pages; /* for event */
 	}
 
-	__this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_COUNT], nr_pages);
+	__this_cpu_add(memcg->stat->events[MEM_CGROUP_EVENTS_COUNT], nr_pages);
 
 	preempt_enable();
 }
 
 unsigned long
-mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *mem, int nid, int zid,
+mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg, int nid, int zid,
 			unsigned int lru_mask)
 {
 	struct mem_cgroup_per_zone *mz;
 	enum lru_list l;
 	unsigned long ret = 0;
 
-	mz = mem_cgroup_zoneinfo(mem, nid, zid);
+	mz = mem_cgroup_zoneinfo(memcg, nid, zid);
 
 	for_each_lru(l) {
 		if (BIT(l) & lru_mask)
@@ -702,44 +704,45 @@ mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *mem, int nid, int zid,
 }
 
 static unsigned long
-mem_cgroup_node_nr_lru_pages(struct mem_cgroup *mem,
+mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 			int nid, unsigned int lru_mask)
 {
 	u64 total = 0;
 	int zid;
 
 	for (zid = 0; zid < MAX_NR_ZONES; zid++)
-		total += mem_cgroup_zone_nr_lru_pages(mem, nid, zid, lru_mask);
+		total += mem_cgroup_zone_nr_lru_pages(memcg,
+						nid, zid, lru_mask);
 
 	return total;
 }
 
-static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *mem,
+static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg,
 			unsigned int lru_mask)
 {
 	int nid;
 	u64 total = 0;
 
 	for_each_node_state(nid, N_HIGH_MEMORY)
-		total += mem_cgroup_node_nr_lru_pages(mem, nid, lru_mask);
+		total += mem_cgroup_node_nr_lru_pages(memcg, nid, lru_mask);
 	return total;
 }
 
-static bool __memcg_event_check(struct mem_cgroup *mem, int target)
+static bool __memcg_event_check(struct mem_cgroup *memcg, int target)
 {
 	unsigned long val, next;
 
-	val = this_cpu_read(mem->stat->events[MEM_CGROUP_EVENTS_COUNT]);
-	next = this_cpu_read(mem->stat->targets[target]);
+	val = this_cpu_read(memcg->stat->events[MEM_CGROUP_EVENTS_COUNT]);
+	next = this_cpu_read(memcg->stat->targets[target]);
 	/* from time_after() in jiffies.h */
 	return ((long)next - (long)val < 0);
 }
 
-static void __mem_cgroup_target_update(struct mem_cgroup *mem, int target)
+static void __mem_cgroup_target_update(struct mem_cgroup *memcg, int target)
 {
 	unsigned long val, next;
 
-	val = this_cpu_read(mem->stat->events[MEM_CGROUP_EVENTS_COUNT]);
+	val = this_cpu_read(memcg->stat->events[MEM_CGROUP_EVENTS_COUNT]);
 
 	switch (target) {
 	case MEM_CGROUP_TARGET_THRESH:
@@ -755,30 +758,30 @@ static void __mem_cgroup_target_update(struct mem_cgroup *mem, int target)
 		return;
 	}
 
-	this_cpu_write(mem->stat->targets[target], next);
+	this_cpu_write(memcg->stat->targets[target], next);
 }
 
 /*
  * Check events in order.
  *
  */
-static void memcg_check_events(struct mem_cgroup *mem, struct page *page)
+static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
 {
 	/* threshold event is triggered in finer grain than soft limit */
-	if (unlikely(__memcg_event_check(mem, MEM_CGROUP_TARGET_THRESH))) {
-		mem_cgroup_threshold(mem);
-		__mem_cgroup_target_update(mem, MEM_CGROUP_TARGET_THRESH);
-		if (unlikely(__memcg_event_check(mem,
+	if (unlikely(__memcg_event_check(memcg, MEM_CGROUP_TARGET_THRESH))) {
+		mem_cgroup_threshold(memcg);
+		__mem_cgroup_target_update(memcg, MEM_CGROUP_TARGET_THRESH);
+		if (unlikely(__memcg_event_check(memcg,
 			     MEM_CGROUP_TARGET_SOFTLIMIT))) {
-			mem_cgroup_update_tree(mem, page);
-			__mem_cgroup_target_update(mem,
+			mem_cgroup_update_tree(memcg, page);
+			__mem_cgroup_target_update(memcg,
 						   MEM_CGROUP_TARGET_SOFTLIMIT);
 		}
 #if MAX_NUMNODES > 1
-		if (unlikely(__memcg_event_check(mem,
+		if (unlikely(__memcg_event_check(memcg,
 			MEM_CGROUP_TARGET_NUMAINFO))) {
-			atomic_inc(&mem->numainfo_events);
-			__mem_cgroup_target_update(mem,
+			atomic_inc(&memcg->numainfo_events);
+			__mem_cgroup_target_update(memcg,
 				MEM_CGROUP_TARGET_NUMAINFO);
 		}
 #endif
@@ -808,7 +811,7 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 
 struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 {
-	struct mem_cgroup *mem = NULL;
+	struct mem_cgroup *memcg = NULL;
 
 	if (!mm)
 		return NULL;
@@ -819,25 +822,25 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 	 */
 	rcu_read_lock();
 	do {
-		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
-		if (unlikely(!mem))
+		memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
+		if (unlikely(!memcg))
 			break;
-	} while (!css_tryget(&mem->css));
+	} while (!css_tryget(&memcg->css));
 	rcu_read_unlock();
-	return mem;
+	return memcg;
 }
 
 /* The caller has to guarantee "mem" exists before calling this */
-static struct mem_cgroup *mem_cgroup_start_loop(struct mem_cgroup *mem)
+static struct mem_cgroup *mem_cgroup_start_loop(struct mem_cgroup *memcg)
 {
 	struct cgroup_subsys_state *css;
 	int found;
 
-	if (!mem) /* ROOT cgroup has the smallest ID */
+	if (!memcg) /* ROOT cgroup has the smallest ID */
 		return root_mem_cgroup; /*css_put/get against root is ignored*/
-	if (!mem->use_hierarchy) {
-		if (css_tryget(&mem->css))
-			return mem;
+	if (!memcg->use_hierarchy) {
+		if (css_tryget(&memcg->css))
+			return memcg;
 		return NULL;
 	}
 	rcu_read_lock();
@@ -845,13 +848,13 @@ static struct mem_cgroup *mem_cgroup_start_loop(struct mem_cgroup *mem)
 	 * searching a memory cgroup which has the smallest ID under given
 	 * ROOT cgroup. (ID >= 1)
 	 */
-	css = css_get_next(&mem_cgroup_subsys, 1, &mem->css, &found);
+	css = css_get_next(&mem_cgroup_subsys, 1, &memcg->css, &found);
 	if (css && css_tryget(css))
-		mem = container_of(css, struct mem_cgroup, css);
+		memcg = container_of(css, struct mem_cgroup, css);
 	else
-		mem = NULL;
+		memcg = NULL;
 	rcu_read_unlock();
-	return mem;
+	return memcg;
 }
 
 static struct mem_cgroup *mem_cgroup_get_next(struct mem_cgroup *iter,
@@ -905,29 +908,29 @@ static struct mem_cgroup *mem_cgroup_get_next(struct mem_cgroup *iter,
 	for_each_mem_cgroup_tree_cond(iter, NULL, true)
 
 
-static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
+static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
 {
-	return (mem == root_mem_cgroup);
+	return (memcg == root_mem_cgroup);
 }
 
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *memcg;
 
 	if (!mm)
 		return;
 
 	rcu_read_lock();
-	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
-	if (unlikely(!mem))
+	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
+	if (unlikely(!memcg))
 		goto out;
 
 	switch (idx) {
 	case PGMAJFAULT:
-		mem_cgroup_pgmajfault(mem, 1);
+		mem_cgroup_pgmajfault(memcg, 1);
 		break;
 	case PGFAULT:
-		mem_cgroup_pgfault(mem, 1);
+		mem_cgroup_pgfault(memcg, 1);
 		break;
 	default:
 		BUG();
@@ -1112,18 +1115,18 @@ void mem_cgroup_move_lists(struct page *page,
  * Checks whether given mem is same or in the root_mem's
  * hierarchy subtree
  */
-static bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_mem,
-		struct mem_cgroup *mem)
+static bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
+		struct mem_cgroup *memcg)
 {
-	if (root_mem != mem) {
-		return (root_mem->use_hierarchy &&
-			css_is_ancestor(&mem->css, &root_mem->css));
+	if (root_memcg != memcg) {
+		return (root_memcg->use_hierarchy &&
+			css_is_ancestor(&memcg->css, &root_memcg->css));
 	}
 
 	return true;
 }
 
-int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
+int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg)
 {
 	int ret;
 	struct mem_cgroup *curr = NULL;
@@ -1137,12 +1140,12 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
 	if (!curr)
 		return 0;
 	/*
-	 * We should check use_hierarchy of "mem" not "curr". Because checking
+	 * We should check use_hierarchy of "memcg" not "curr". Because checking
 	 * use_hierarchy of "curr" here make this function true if hierarchy is
-	 * enabled in "curr" and "curr" is a child of "mem" in *cgroup*
-	 * hierarchy(even if use_hierarchy is disabled in "mem").
+	 * enabled in "curr" and "curr" is a child of "memcg" in *cgroup*
+	 * hierarchy(even if use_hierarchy is disabled in "memcg").
 	 */
-	ret = mem_cgroup_same_or_subtree(mem, curr);
+	ret = mem_cgroup_same_or_subtree(memcg, curr);
 	css_put(&curr->css);
 	return ret;
 }
@@ -1300,13 +1303,13 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
  * Returns the maximum amount of memory @mem can be charged with, in
  * pages.
  */
-static unsigned long mem_cgroup_margin(struct mem_cgroup *mem)
+static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
 {
 	unsigned long long margin;
 
-	margin = res_counter_margin(&mem->res);
+	margin = res_counter_margin(&memcg->res);
 	if (do_swap_account)
-		margin = min(margin, res_counter_margin(&mem->memsw));
+		margin = min(margin, res_counter_margin(&memcg->memsw));
 	return margin >> PAGE_SHIFT;
 }
 
@@ -1321,33 +1324,33 @@ int mem_cgroup_swappiness(struct mem_cgroup *memcg)
 	return memcg->swappiness;
 }
 
-static void mem_cgroup_start_move(struct mem_cgroup *mem)
+static void mem_cgroup_start_move(struct mem_cgroup *memcg)
 {
 	int cpu;
 
 	get_online_cpus();
-	spin_lock(&mem->pcp_counter_lock);
+	spin_lock(&memcg->pcp_counter_lock);
 	for_each_online_cpu(cpu)
-		per_cpu(mem->stat->count[MEM_CGROUP_ON_MOVE], cpu) += 1;
-	mem->nocpu_base.count[MEM_CGROUP_ON_MOVE] += 1;
-	spin_unlock(&mem->pcp_counter_lock);
+		per_cpu(memcg->stat->count[MEM_CGROUP_ON_MOVE], cpu) += 1;
+	memcg->nocpu_base.count[MEM_CGROUP_ON_MOVE] += 1;
+	spin_unlock(&memcg->pcp_counter_lock);
 	put_online_cpus();
 
 	synchronize_rcu();
 }
 
-static void mem_cgroup_end_move(struct mem_cgroup *mem)
+static void mem_cgroup_end_move(struct mem_cgroup *memcg)
 {
 	int cpu;
 
-	if (!mem)
+	if (!memcg)
 		return;
 	get_online_cpus();
-	spin_lock(&mem->pcp_counter_lock);
+	spin_lock(&memcg->pcp_counter_lock);
 	for_each_online_cpu(cpu)
-		per_cpu(mem->stat->count[MEM_CGROUP_ON_MOVE], cpu) -= 1;
-	mem->nocpu_base.count[MEM_CGROUP_ON_MOVE] -= 1;
-	spin_unlock(&mem->pcp_counter_lock);
+		per_cpu(memcg->stat->count[MEM_CGROUP_ON_MOVE], cpu) -= 1;
+	memcg->nocpu_base.count[MEM_CGROUP_ON_MOVE] -= 1;
+	spin_unlock(&memcg->pcp_counter_lock);
 	put_online_cpus();
 }
 /*
@@ -1362,13 +1365,13 @@ static void mem_cgroup_end_move(struct mem_cgroup *mem)
  *			  waiting at hith-memory prressure caused by "move".
  */
 
-static bool mem_cgroup_stealed(struct mem_cgroup *mem)
+static bool mem_cgroup_stealed(struct mem_cgroup *memcg)
 {
 	VM_BUG_ON(!rcu_read_lock_held());
-	return this_cpu_read(mem->stat->count[MEM_CGROUP_ON_MOVE]) > 0;
+	return this_cpu_read(memcg->stat->count[MEM_CGROUP_ON_MOVE]) > 0;
 }
 
-static bool mem_cgroup_under_move(struct mem_cgroup *mem)
+static bool mem_cgroup_under_move(struct mem_cgroup *memcg)
 {
 	struct mem_cgroup *from;
 	struct mem_cgroup *to;
@@ -1383,17 +1386,17 @@ static bool mem_cgroup_under_move(struct mem_cgroup *mem)
 	if (!from)
 		goto unlock;
 
-	ret = mem_cgroup_same_or_subtree(mem, from)
-		|| mem_cgroup_same_or_subtree(mem, to);
+	ret = mem_cgroup_same_or_subtree(memcg, from)
+		|| mem_cgroup_same_or_subtree(memcg, to);
 unlock:
 	spin_unlock(&mc.lock);
 	return ret;
 }
 
-static bool mem_cgroup_wait_acct_move(struct mem_cgroup *mem)
+static bool mem_cgroup_wait_acct_move(struct mem_cgroup *memcg)
 {
 	if (mc.moving_task && current != mc.moving_task) {
-		if (mem_cgroup_under_move(mem)) {
+		if (mem_cgroup_under_move(memcg)) {
 			DEFINE_WAIT(wait);
 			prepare_to_wait(&mc.waitq, &wait, TASK_INTERRUPTIBLE);
 			/* moving charge context might have finished. */
@@ -1477,12 +1480,12 @@ done:
  * This function returns the number of memcg under hierarchy tree. Returns
  * 1(self count) if no children.
  */
-static int mem_cgroup_count_children(struct mem_cgroup *mem)
+static int mem_cgroup_count_children(struct mem_cgroup *memcg)
 {
 	int num = 0;
 	struct mem_cgroup *iter;
 
-	for_each_mem_cgroup_tree(iter, mem)
+	for_each_mem_cgroup_tree(iter, memcg)
 		num++;
 	return num;
 }
@@ -1512,21 +1515,21 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
  * that to reclaim free pages from.
  */
 static struct mem_cgroup *
-mem_cgroup_select_victim(struct mem_cgroup *root_mem)
+mem_cgroup_select_victim(struct mem_cgroup *root_memcg)
 {
 	struct mem_cgroup *ret = NULL;
 	struct cgroup_subsys_state *css;
 	int nextid, found;
 
-	if (!root_mem->use_hierarchy) {
-		css_get(&root_mem->css);
-		ret = root_mem;
+	if (!root_memcg->use_hierarchy) {
+		css_get(&root_memcg->css);
+		ret = root_memcg;
 	}
 
 	while (!ret) {
 		rcu_read_lock();
-		nextid = root_mem->last_scanned_child + 1;
-		css = css_get_next(&mem_cgroup_subsys, nextid, &root_mem->css,
+		nextid = root_memcg->last_scanned_child + 1;
+		css = css_get_next(&mem_cgroup_subsys, nextid, &root_memcg->css,
 				   &found);
 		if (css && css_tryget(css))
 			ret = container_of(css, struct mem_cgroup, css);
@@ -1535,9 +1538,9 @@ mem_cgroup_select_victim(struct mem_cgroup *root_mem)
 		/* Updates scanning parameter */
 		if (!css) {
 			/* this means start scan from ID:1 */
-			root_mem->last_scanned_child = 0;
+			root_memcg->last_scanned_child = 0;
 		} else
-			root_mem->last_scanned_child = found;
+			root_memcg->last_scanned_child = found;
 	}
 
 	return ret;
@@ -1553,14 +1556,14 @@ mem_cgroup_select_victim(struct mem_cgroup *root_mem)
  * reclaimable pages on a node. Returns true if there are any reclaimable
  * pages in the node.
  */
-static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *mem,
+static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *memcg,
 		int nid, bool noswap)
 {
-	if (mem_cgroup_node_nr_lru_pages(mem, nid, LRU_ALL_FILE))
+	if (mem_cgroup_node_nr_lru_pages(memcg, nid, LRU_ALL_FILE))
 		return true;
 	if (noswap || !total_swap_pages)
 		return false;
-	if (mem_cgroup_node_nr_lru_pages(mem, nid, LRU_ALL_ANON))
+	if (mem_cgroup_node_nr_lru_pages(memcg, nid, LRU_ALL_ANON))
 		return true;
 	return false;
 
@@ -1573,29 +1576,29 @@ static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *mem,
  * nodes based on the zonelist. So update the list loosely once per 10 secs.
  *
  */
-static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem)
+static void mem_cgroup_may_update_nodemask(struct mem_cgroup *memcg)
 {
 	int nid;
 	/*
 	 * numainfo_events > 0 means there was at least NUMAINFO_EVENTS_TARGET
 	 * pagein/pageout changes since the last update.
 	 */
-	if (!atomic_read(&mem->numainfo_events))
+	if (!atomic_read(&memcg->numainfo_events))
 		return;
-	if (atomic_inc_return(&mem->numainfo_updating) > 1)
+	if (atomic_inc_return(&memcg->numainfo_updating) > 1)
 		return;
 
 	/* make a nodemask where this memcg uses memory from */
-	mem->scan_nodes = node_states[N_HIGH_MEMORY];
+	memcg->scan_nodes = node_states[N_HIGH_MEMORY];
 
 	for_each_node_mask(nid, node_states[N_HIGH_MEMORY]) {
 
-		if (!test_mem_cgroup_node_reclaimable(mem, nid, false))
-			node_clear(nid, mem->scan_nodes);
+		if (!test_mem_cgroup_node_reclaimable(memcg, nid, false))
+			node_clear(nid, memcg->scan_nodes);
 	}
 
-	atomic_set(&mem->numainfo_events, 0);
-	atomic_set(&mem->numainfo_updating, 0);
+	atomic_set(&memcg->numainfo_events, 0);
+	atomic_set(&memcg->numainfo_updating, 0);
 }
 
 /*
@@ -1610,16 +1613,16 @@ static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem)
  *
  * Now, we use round-robin. Better algorithm is welcomed.
  */
-int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
+int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
 {
 	int node;
 
-	mem_cgroup_may_update_nodemask(mem);
-	node = mem->last_scanned_node;
+	mem_cgroup_may_update_nodemask(memcg);
+	node = memcg->last_scanned_node;
 
-	node = next_node(node, mem->scan_nodes);
+	node = next_node(node, memcg->scan_nodes);
 	if (node == MAX_NUMNODES)
-		node = first_node(mem->scan_nodes);
+		node = first_node(memcg->scan_nodes);
 	/*
 	 * We call this when we hit limit, not when pages are added to LRU.
 	 * No LRU may hold pages because all pages are UNEVICTABLE or
@@ -1629,7 +1632,7 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
 	if (unlikely(node == MAX_NUMNODES))
 		node = numa_node_id();
 
-	mem->last_scanned_node = node;
+	memcg->last_scanned_node = node;
 	return node;
 }
 
@@ -1639,7 +1642,7 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
  * unused nodes. But scan_nodes is lazily updated and may not cotain
  * enough new information. We need to do double check.
  */
-bool mem_cgroup_reclaimable(struct mem_cgroup *mem, bool noswap)
+bool mem_cgroup_reclaimable(struct mem_cgroup *memcg, bool noswap)
 {
 	int nid;
 
@@ -1647,12 +1650,12 @@ bool mem_cgroup_reclaimable(struct mem_cgroup *mem, bool noswap)
 	 * quick check...making use of scan_node.
 	 * We can skip unused nodes.
 	 */
-	if (!nodes_empty(mem->scan_nodes)) {
-		for (nid = first_node(mem->scan_nodes);
+	if (!nodes_empty(memcg->scan_nodes)) {
+		for (nid = first_node(memcg->scan_nodes);
 		     nid < MAX_NUMNODES;
-		     nid = next_node(nid, mem->scan_nodes)) {
+		     nid = next_node(nid, memcg->scan_nodes)) {
 
-			if (test_mem_cgroup_node_reclaimable(mem, nid, noswap))
+			if (test_mem_cgroup_node_reclaimable(memcg, nid, noswap))
 				return true;
 		}
 	}
@@ -1660,23 +1663,23 @@ bool mem_cgroup_reclaimable(struct mem_cgroup *mem, bool noswap)
 	 * Check rest of nodes.
 	 */
 	for_each_node_state(nid, N_HIGH_MEMORY) {
-		if (node_isset(nid, mem->scan_nodes))
+		if (node_isset(nid, memcg->scan_nodes))
 			continue;
-		if (test_mem_cgroup_node_reclaimable(mem, nid, noswap))
+		if (test_mem_cgroup_node_reclaimable(memcg, nid, noswap))
 			return true;
 	}
 	return false;
 }
 
 #else
-int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
+int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
 {
 	return 0;
 }
 
-bool mem_cgroup_reclaimable(struct mem_cgroup *mem, bool noswap)
+bool mem_cgroup_reclaimable(struct mem_cgroup *memcg, bool noswap)
 {
-	return test_mem_cgroup_node_reclaimable(mem, 0, noswap);
+	return test_mem_cgroup_node_reclaimable(memcg, 0, noswap);
 }
 #endif
 
@@ -1701,21 +1704,21 @@ static void __mem_cgroup_record_scanstat(unsigned long *stats,
 
 static void mem_cgroup_record_scanstat(struct memcg_scanrecord *rec)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *memcg;
 	int context = rec->context;
 
 	if (context >= NR_SCAN_CONTEXT)
 		return;
 
-	mem = rec->mem;
-	spin_lock(&mem->scanstat.lock);
-	__mem_cgroup_record_scanstat(mem->scanstat.stats[context], rec);
-	spin_unlock(&mem->scanstat.lock);
+	memcg = rec->mem;
+	spin_lock(&memcg->scanstat.lock);
+	__mem_cgroup_record_scanstat(memcg->scanstat.stats[context], rec);
+	spin_unlock(&memcg->scanstat.lock);
 
-	mem = rec->root;
-	spin_lock(&mem->scanstat.lock);
-	__mem_cgroup_record_scanstat(mem->scanstat.rootstats[context], rec);
-	spin_unlock(&mem->scanstat.lock);
+	memcg = rec->root;
+	spin_lock(&memcg->scanstat.lock);
+	__mem_cgroup_record_scanstat(memcg->scanstat.rootstats[context], rec);
+	spin_unlock(&memcg->scanstat.lock);
 }
 
 /*
@@ -1723,14 +1726,14 @@ static void mem_cgroup_record_scanstat(struct memcg_scanrecord *rec)
  * we reclaimed from, so that we don't end up penalizing one child extensively
  * based on its position in the children list.
  *
- * root_mem is the original ancestor that we've been reclaim from.
+ * root_memcg is the original ancestor that we've been reclaim from.
  *
- * We give up and return to the caller when we visit root_mem twice.
+ * We give up and return to the caller when we visit root_memcg twice.
  * (other groups can be removed while we're walking....)
  *
  * If shrink==true, for avoiding to free too much, this returns immedieately.
  */
-static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
+static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
 						struct zone *zone,
 						gfp_t gfp_mask,
 						unsigned long reclaim_options,
@@ -1746,10 +1749,10 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 	unsigned long excess;
 	unsigned long scanned;
 
-	excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
+	excess = res_counter_soft_limit_excess(&root_memcg->res) >> PAGE_SHIFT;
 
 	/* If memsw_is_minimum==1, swap-out is of-no-use. */
-	if (!check_soft && !shrink && root_mem->memsw_is_minimum)
+	if (!check_soft && !shrink && root_memcg->memsw_is_minimum)
 		noswap = true;
 
 	if (shrink)
@@ -1759,11 +1762,11 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 	else
 		rec.context = SCAN_BY_LIMIT;
 
-	rec.root = root_mem;
+	rec.root = root_memcg;
 
 	while (1) {
-		victim = mem_cgroup_select_victim(root_mem);
-		if (victim == root_mem) {
+		victim = mem_cgroup_select_victim(root_memcg);
+		if (victim == root_memcg) {
 			loop++;
 			/*
 			 * We are not draining per cpu cached charges during
@@ -1772,7 +1775,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 			 * charges will not give any.
 			 */
 			if (!check_soft && loop >= 1)
-				drain_all_stock_async(root_mem);
+				drain_all_stock_async(root_memcg);
 			if (loop >= 2) {
 				/*
 				 * If we have not been able to reclaim
@@ -1828,9 +1831,9 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 			return ret;
 		total += ret;
 		if (check_soft) {
-			if (!res_counter_soft_limit_excess(&root_mem->res))
+			if (!res_counter_soft_limit_excess(&root_memcg->res))
 				return total;
-		} else if (mem_cgroup_margin(root_mem))
+		} else if (mem_cgroup_margin(root_memcg))
 			return total;
 	}
 	return total;
@@ -1841,13 +1844,13 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
  * If someone is running, return false.
  * Has to be called with memcg_oom_lock
  */
-static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
+static bool mem_cgroup_oom_lock(struct mem_cgroup *memcg)
 {
 	int lock_count = -1;
 	struct mem_cgroup *iter, *failed = NULL;
 	bool cond = true;
 
-	for_each_mem_cgroup_tree_cond(iter, mem, cond) {
+	for_each_mem_cgroup_tree_cond(iter, memcg, cond) {
 		bool locked = iter->oom_lock;
 
 		iter->oom_lock = true;
@@ -1872,7 +1875,7 @@ static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
 	 * what we set up to the failing subtree
 	 */
 	cond = true;
-	for_each_mem_cgroup_tree_cond(iter, mem, cond) {
+	for_each_mem_cgroup_tree_cond(iter, memcg, cond) {
 		if (iter == failed) {
 			cond = false;
 			continue;
@@ -1886,24 +1889,24 @@ done:
 /*
  * Has to be called with memcg_oom_lock
  */
-static int mem_cgroup_oom_unlock(struct mem_cgroup *mem)
+static int mem_cgroup_oom_unlock(struct mem_cgroup *memcg)
 {
 	struct mem_cgroup *iter;
 
-	for_each_mem_cgroup_tree(iter, mem)
+	for_each_mem_cgroup_tree(iter, memcg)
 		iter->oom_lock = false;
 	return 0;
 }
 
-static void mem_cgroup_mark_under_oom(struct mem_cgroup *mem)
+static void mem_cgroup_mark_under_oom(struct mem_cgroup *memcg)
 {
 	struct mem_cgroup *iter;
 
-	for_each_mem_cgroup_tree(iter, mem)
+	for_each_mem_cgroup_tree(iter, memcg)
 		atomic_inc(&iter->under_oom);
 }
 
-static void mem_cgroup_unmark_under_oom(struct mem_cgroup *mem)
+static void mem_cgroup_unmark_under_oom(struct mem_cgroup *memcg)
 {
 	struct mem_cgroup *iter;
 
@@ -1912,7 +1915,7 @@ static void mem_cgroup_unmark_under_oom(struct mem_cgroup *mem)
 	 * mem_cgroup_oom_lock() may not be called. We have to use
 	 * atomic_add_unless() here.
 	 */
-	for_each_mem_cgroup_tree(iter, mem)
+	for_each_mem_cgroup_tree(iter, memcg)
 		atomic_add_unless(&iter->under_oom, -1, 0);
 }
 
@@ -1927,80 +1930,80 @@ struct oom_wait_info {
 static int memcg_oom_wake_function(wait_queue_t *wait,
 	unsigned mode, int sync, void *arg)
 {
-	struct mem_cgroup *wake_mem = (struct mem_cgroup *)arg,
-			  *oom_wait_mem;
+	struct mem_cgroup *wake_memcg = (struct mem_cgroup *)arg,
+			  *oom_wait_memcg;
 	struct oom_wait_info *oom_wait_info;
 
 	oom_wait_info = container_of(wait, struct oom_wait_info, wait);
-	oom_wait_mem = oom_wait_info->mem;
+	oom_wait_memcg = oom_wait_info->mem;
 
 	/*
 	 * Both of oom_wait_info->mem and wake_mem are stable under us.
 	 * Then we can use css_is_ancestor without taking care of RCU.
 	 */
-	if (!mem_cgroup_same_or_subtree(oom_wait_mem, wake_mem)
-			&& !mem_cgroup_same_or_subtree(wake_mem, oom_wait_mem))
+	if (!mem_cgroup_same_or_subtree(oom_wait_memcg, wake_memcg)
+		&& !mem_cgroup_same_or_subtree(wake_memcg, oom_wait_memcg))
 		return 0;
 	return autoremove_wake_function(wait, mode, sync, arg);
 }
 
-static void memcg_wakeup_oom(struct mem_cgroup *mem)
+static void memcg_wakeup_oom(struct mem_cgroup *memcg)
 {
-	/* for filtering, pass "mem" as argument. */
-	__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, mem);
+	/* for filtering, pass "memcg" as argument. */
+	__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, memcg);
 }
 
-static void memcg_oom_recover(struct mem_cgroup *mem)
+static void memcg_oom_recover(struct mem_cgroup *memcg)
 {
-	if (mem && atomic_read(&mem->under_oom))
-		memcg_wakeup_oom(mem);
+	if (memcg && atomic_read(&memcg->under_oom))
+		memcg_wakeup_oom(memcg);
 }
 
 /*
  * try to call OOM killer. returns false if we should exit memory-reclaim loop.
  */
-bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
+bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
 {
 	struct oom_wait_info owait;
 	bool locked, need_to_kill;
 
-	owait.mem = mem;
+	owait.mem = memcg;
 	owait.wait.flags = 0;
 	owait.wait.func = memcg_oom_wake_function;
 	owait.wait.private = current;
 	INIT_LIST_HEAD(&owait.wait.task_list);
 	need_to_kill = true;
-	mem_cgroup_mark_under_oom(mem);
+	mem_cgroup_mark_under_oom(memcg);
 
-	/* At first, try to OOM lock hierarchy under mem.*/
+	/* At first, try to OOM lock hierarchy under memcg.*/
 	spin_lock(&memcg_oom_lock);
-	locked = mem_cgroup_oom_lock(mem);
+	locked = mem_cgroup_oom_lock(memcg);
 	/*
 	 * Even if signal_pending(), we can't quit charge() loop without
 	 * accounting. So, UNINTERRUPTIBLE is appropriate. But SIGKILL
 	 * under OOM is always welcomed, use TASK_KILLABLE here.
 	 */
 	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
-	if (!locked || mem->oom_kill_disable)
+	if (!locked || memcg->oom_kill_disable)
 		need_to_kill = false;
 	if (locked)
-		mem_cgroup_oom_notify(mem);
+		mem_cgroup_oom_notify(memcg);
 	spin_unlock(&memcg_oom_lock);
 
 	if (need_to_kill) {
 		finish_wait(&memcg_oom_waitq, &owait.wait);
-		mem_cgroup_out_of_memory(mem, mask);
+		mem_cgroup_out_of_memory(memcg, mask);
 	} else {
 		schedule();
 		finish_wait(&memcg_oom_waitq, &owait.wait);
 	}
 	spin_lock(&memcg_oom_lock);
 	if (locked)
-		mem_cgroup_oom_unlock(mem);
-	memcg_wakeup_oom(mem);
+		mem_cgroup_oom_unlock(memcg);
+	memcg_wakeup_oom(memcg);
 	spin_unlock(&memcg_oom_lock);
 
-	mem_cgroup_unmark_under_oom(mem);
+	mem_cgroup_unmark_under_oom(memcg);
 
 	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
 		return false;
@@ -2036,7 +2039,7 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
 void mem_cgroup_update_page_stat(struct page *page,
 				 enum mem_cgroup_page_stat_item idx, int val)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *memcg;
 	struct page_cgroup *pc = lookup_page_cgroup(page);
 	bool need_unlock = false;
 	unsigned long uninitialized_var(flags);
@@ -2045,16 +2048,16 @@ void mem_cgroup_update_page_stat(struct page *page,
 		return;
 
 	rcu_read_lock();
-	mem = pc->mem_cgroup;
-	if (unlikely(!mem || !PageCgroupUsed(pc)))
+	memcg = pc->mem_cgroup;
+	if (unlikely(!memcg || !PageCgroupUsed(pc)))
 		goto out;
 	/* pc->mem_cgroup is unstable ? */
-	if (unlikely(mem_cgroup_stealed(mem)) || PageTransHuge(page)) {
+	if (unlikely(mem_cgroup_stealed(memcg)) || PageTransHuge(page)) {
 		/* take a lock against to access pc->mem_cgroup */
 		move_lock_page_cgroup(pc, &flags);
 		need_unlock = true;
-		mem = pc->mem_cgroup;
-		if (!mem || !PageCgroupUsed(pc))
+		memcg = pc->mem_cgroup;
+		if (!memcg || !PageCgroupUsed(pc))
 			goto out;
 	}
 
@@ -2070,7 +2073,7 @@ void mem_cgroup_update_page_stat(struct page *page,
 		BUG();
 	}
 
-	this_cpu_add(mem->stat->count[idx], val);
+	this_cpu_add(memcg->stat->count[idx], val);
 
 out:
 	if (unlikely(need_unlock))
@@ -2100,13 +2103,13 @@ static DEFINE_PER_CPU(struct memcg_stock_pcp, memcg_stock);
  * cgroup which is not current target, returns false. This stock will be
  * refilled.
  */
-static bool consume_stock(struct mem_cgroup *mem)
+static bool consume_stock(struct mem_cgroup *memcg)
 {
 	struct memcg_stock_pcp *stock;
 	bool ret = true;
 
 	stock = &get_cpu_var(memcg_stock);
-	if (mem == stock->cached && stock->nr_pages)
+	if (memcg == stock->cached && stock->nr_pages)
 		stock->nr_pages--;
 	else /* need to call res_counter_charge */
 		ret = false;
@@ -2147,24 +2150,24 @@ static void drain_local_stock(struct work_struct *dummy)
  * Cache charges(val) which is from res_counter, to local per_cpu area.
  * This will be consumed by consume_stock() function, later.
  */
-static void refill_stock(struct mem_cgroup *mem, unsigned int nr_pages)
+static void refill_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
 	struct memcg_stock_pcp *stock = &get_cpu_var(memcg_stock);
 
-	if (stock->cached != mem) { /* reset if necessary */
+	if (stock->cached != memcg) { /* reset if necessary */
 		drain_stock(stock);
-		stock->cached = mem;
+		stock->cached = memcg;
 	}
 	stock->nr_pages += nr_pages;
 	put_cpu_var(memcg_stock);
 }
 
 /*
- * Drains all per-CPU charge caches for given root_mem resp. subtree
+ * Drains all per-CPU charge caches for given root_memcg resp. subtree
  * of the hierarchy under it. sync flag says whether we should block
  * until the work is done.
  */
-static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
+static void drain_all_stock(struct mem_cgroup *root_memcg, bool sync)
 {
 	int cpu, curcpu;
 
@@ -2179,12 +2182,12 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
 	curcpu = raw_smp_processor_id();
 	for_each_online_cpu(cpu) {
 		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
-		struct mem_cgroup *mem;
+		struct mem_cgroup *memcg;
 
-		mem = stock->cached;
-		if (!mem || !stock->nr_pages)
+		memcg = stock->cached;
+		if (!memcg || !stock->nr_pages)
 			continue;
-		if (!mem_cgroup_same_or_subtree(root_mem, mem))
+		if (!mem_cgroup_same_or_subtree(root_memcg, memcg))
 			continue;
 		if (!test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags)) {
 			if (cpu == curcpu)
@@ -2199,7 +2202,7 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
 
 	for_each_online_cpu(cpu) {
 		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
-		if (mem_cgroup_same_or_subtree(root_mem, stock->cached) &&
+		if (mem_cgroup_same_or_subtree(root_memcg, stock->cached) &&
 				test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
 			flush_work(&stock->work);
 	}
@@ -2229,35 +2232,35 @@ static void drain_all_stock_sync(struct mem_cgroup *root_mem)
  * This function drains percpu counter value from DEAD cpu and
  * move it to local cpu. Note that this function can be preempted.
  */
-static void mem_cgroup_drain_pcp_counter(struct mem_cgroup *mem, int cpu)
+static void mem_cgroup_drain_pcp_counter(struct mem_cgroup *memcg, int cpu)
 {
 	int i;
 
-	spin_lock(&mem->pcp_counter_lock);
+	spin_lock(&memcg->pcp_counter_lock);
 	for (i = 0; i < MEM_CGROUP_STAT_DATA; i++) {
-		long x = per_cpu(mem->stat->count[i], cpu);
+		long x = per_cpu(memcg->stat->count[i], cpu);
 
-		per_cpu(mem->stat->count[i], cpu) = 0;
-		mem->nocpu_base.count[i] += x;
+		per_cpu(memcg->stat->count[i], cpu) = 0;
+		memcg->nocpu_base.count[i] += x;
 	}
 	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++) {
-		unsigned long x = per_cpu(mem->stat->events[i], cpu);
+		unsigned long x = per_cpu(memcg->stat->events[i], cpu);
 
-		per_cpu(mem->stat->events[i], cpu) = 0;
-		mem->nocpu_base.events[i] += x;
+		per_cpu(memcg->stat->events[i], cpu) = 0;
+		memcg->nocpu_base.events[i] += x;
 	}
 	/* need to clear ON_MOVE value, works as a kind of lock. */
-	per_cpu(mem->stat->count[MEM_CGROUP_ON_MOVE], cpu) = 0;
-	spin_unlock(&mem->pcp_counter_lock);
+	per_cpu(memcg->stat->count[MEM_CGROUP_ON_MOVE], cpu) = 0;
+	spin_unlock(&memcg->pcp_counter_lock);
 }
 
-static void synchronize_mem_cgroup_on_move(struct mem_cgroup *mem, int cpu)
+static void synchronize_mem_cgroup_on_move(struct mem_cgroup *memcg, int cpu)
 {
 	int idx = MEM_CGROUP_ON_MOVE;
 
-	spin_lock(&mem->pcp_counter_lock);
-	per_cpu(mem->stat->count[idx], cpu) = mem->nocpu_base.count[idx];
-	spin_unlock(&mem->pcp_counter_lock);
+	spin_lock(&memcg->pcp_counter_lock);
+	per_cpu(memcg->stat->count[idx], cpu) = memcg->nocpu_base.count[idx];
+	spin_unlock(&memcg->pcp_counter_lock);
 }
 
 static int __cpuinit memcg_cpu_hotplug_callback(struct notifier_block *nb,
@@ -2295,7 +2298,7 @@ enum {
 	CHARGE_OOM_DIE,		/* the current is killed because of OOM */
 };
 
-static int mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
+static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 				unsigned int nr_pages, bool oom_check)
 {
 	unsigned long csize = nr_pages * PAGE_SIZE;
@@ -2304,16 +2307,16 @@ static int mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 	unsigned long flags = 0;
 	int ret;
 
-	ret = res_counter_charge(&mem->res, csize, &fail_res);
+	ret = res_counter_charge(&memcg->res, csize, &fail_res);
 
 	if (likely(!ret)) {
 		if (!do_swap_account)
 			return CHARGE_OK;
-		ret = res_counter_charge(&mem->memsw, csize, &fail_res);
+		ret = res_counter_charge(&memcg->memsw, csize, &fail_res);
 		if (likely(!ret))
 			return CHARGE_OK;
 
-		res_counter_uncharge(&mem->res, csize);
+		res_counter_uncharge(&memcg->res, csize);
 		mem_over_limit = mem_cgroup_from_res_counter(fail_res, memsw);
 		flags |= MEM_CGROUP_RECLAIM_NOSWAP;
 	} else
@@ -2371,12 +2374,12 @@ static int mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 static int __mem_cgroup_try_charge(struct mm_struct *mm,
 				   gfp_t gfp_mask,
 				   unsigned int nr_pages,
-				   struct mem_cgroup **memcg,
+				   struct mem_cgroup **ptr,
 				   bool oom)
 {
 	unsigned int batch = max(CHARGE_BATCH, nr_pages);
 	int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
-	struct mem_cgroup *mem = NULL;
+	struct mem_cgroup *memcg = NULL;
 	int ret;
 
 	/*
@@ -2394,17 +2397,17 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 	 * thread group leader migrates. It's possible that mm is not
 	 * set, if so charge the init_mm (happens for pagecache usage).
 	 */
-	if (!*memcg && !mm)
+	if (!*ptr && !mm)
 		goto bypass;
 again:
-	if (*memcg) { /* css should be a valid one */
-		mem = *memcg;
-		VM_BUG_ON(css_is_removed(&mem->css));
-		if (mem_cgroup_is_root(mem))
+	if (*ptr) { /* css should be a valid one */
+		memcg = *ptr;
+		VM_BUG_ON(css_is_removed(&memcg->css));
+		if (mem_cgroup_is_root(memcg))
 			goto done;
-		if (nr_pages == 1 && consume_stock(mem))
+		if (nr_pages == 1 && consume_stock(memcg))
 			goto done;
-		css_get(&mem->css);
+		css_get(&memcg->css);
 	} else {
 		struct task_struct *p;
 
@@ -2412,7 +2415,7 @@ again:
 		p = rcu_dereference(mm->owner);
 		/*
 		 * Because we don't have task_lock(), "p" can exit.
-		 * In that case, "mem" can point to root or p can be NULL with
+		 * In that case, "memcg" can point to root or p can be NULL with
 		 * race with swapoff. Then, we have small risk of mis-accouning.
 		 * But such kind of mis-account by race always happens because
 		 * we don't have cgroup_mutex(). It's overkill and we allo that
@@ -2420,12 +2423,12 @@ again:
 		 * (*) swapoff at el will charge against mm-struct not against
 		 * task-struct. So, mm->owner can be NULL.
 		 */
-		mem = mem_cgroup_from_task(p);
-		if (!mem || mem_cgroup_is_root(mem)) {
+		memcg = mem_cgroup_from_task(p);
+		if (!memcg || mem_cgroup_is_root(memcg)) {
 			rcu_read_unlock();
 			goto done;
 		}
-		if (nr_pages == 1 && consume_stock(mem)) {
+		if (nr_pages == 1 && consume_stock(memcg)) {
 			/*
 			 * It seems dagerous to access memcg without css_get().
 			 * But considering how consume_stok works, it's not
@@ -2438,7 +2441,7 @@ again:
 			goto done;
 		}
 		/* after here, we may be blocked. we need to get refcnt */
-		if (!css_tryget(&mem->css)) {
+		if (!css_tryget(&memcg->css)) {
 			rcu_read_unlock();
 			goto again;
 		}
@@ -2450,7 +2453,7 @@ again:
 
 		/* If killed, bypass charge */
 		if (fatal_signal_pending(current)) {
-			css_put(&mem->css);
+			css_put(&memcg->css);
 			goto bypass;
 		}
 
@@ -2460,43 +2463,43 @@ again:
 			nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
 		}
 
-		ret = mem_cgroup_do_charge(mem, gfp_mask, batch, oom_check);
+		ret = mem_cgroup_do_charge(memcg, gfp_mask, batch, oom_check);
 		switch (ret) {
 		case CHARGE_OK:
 			break;
 		case CHARGE_RETRY: /* not in OOM situation but retry */
 			batch = nr_pages;
-			css_put(&mem->css);
-			mem = NULL;
+			css_put(&memcg->css);
+			memcg = NULL;
 			goto again;
 		case CHARGE_WOULDBLOCK: /* !__GFP_WAIT */
-			css_put(&mem->css);
+			css_put(&memcg->css);
 			goto nomem;
 		case CHARGE_NOMEM: /* OOM routine works */
 			if (!oom) {
-				css_put(&mem->css);
+				css_put(&memcg->css);
 				goto nomem;
 			}
 			/* If oom, we never return -ENOMEM */
 			nr_oom_retries--;
 			break;
 		case CHARGE_OOM_DIE: /* Killed by OOM Killer */
-			css_put(&mem->css);
+			css_put(&memcg->css);
 			goto bypass;
 		}
 	} while (ret != CHARGE_OK);
 
 	if (batch > nr_pages)
-		refill_stock(mem, batch - nr_pages);
-	css_put(&mem->css);
+		refill_stock(memcg, batch - nr_pages);
+	css_put(&memcg->css);
 done:
-	*memcg = mem;
+	*ptr = memcg;
 	return 0;
 nomem:
-	*memcg = NULL;
+	*ptr = NULL;
 	return -ENOMEM;
 bypass:
-	*memcg = NULL;
+	*ptr = NULL;
 	return 0;
 }
 
@@ -2505,15 +2508,15 @@ bypass:
  * This function is for that and do uncharge, put css's refcnt.
  * gotten by try_charge().
  */
-static void __mem_cgroup_cancel_charge(struct mem_cgroup *mem,
+static void __mem_cgroup_cancel_charge(struct mem_cgroup *memcg,
 				       unsigned int nr_pages)
 {
-	if (!mem_cgroup_is_root(mem)) {
+	if (!mem_cgroup_is_root(memcg)) {
 		unsigned long bytes = nr_pages * PAGE_SIZE;
 
-		res_counter_uncharge(&mem->res, bytes);
+		res_counter_uncharge(&memcg->res, bytes);
 		if (do_swap_account)
-			res_counter_uncharge(&mem->memsw, bytes);
+			res_counter_uncharge(&memcg->memsw, bytes);
 	}
 }
 
@@ -2538,7 +2541,7 @@ static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
 
 struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 {
-	struct mem_cgroup *mem = NULL;
+	struct mem_cgroup *memcg = NULL;
 	struct page_cgroup *pc;
 	unsigned short id;
 	swp_entry_t ent;
@@ -2548,23 +2551,23 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
-		mem = pc->mem_cgroup;
-		if (mem && !css_tryget(&mem->css))
-			mem = NULL;
+		memcg = pc->mem_cgroup;
+		if (memcg && !css_tryget(&memcg->css))
+			memcg = NULL;
 	} else if (PageSwapCache(page)) {
 		ent.val = page_private(page);
 		id = lookup_swap_cgroup(ent);
 		rcu_read_lock();
-		mem = mem_cgroup_lookup(id);
-		if (mem && !css_tryget(&mem->css))
-			mem = NULL;
+		memcg = mem_cgroup_lookup(id);
+		if (memcg && !css_tryget(&memcg->css))
+			memcg = NULL;
 		rcu_read_unlock();
 	}
 	unlock_page_cgroup(pc);
-	return mem;
+	return memcg;
 }
 
-static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
+static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 				       struct page *page,
 				       unsigned int nr_pages,
 				       struct page_cgroup *pc,
@@ -2573,14 +2576,14 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
 	lock_page_cgroup(pc);
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
-		__mem_cgroup_cancel_charge(mem, nr_pages);
+		__mem_cgroup_cancel_charge(memcg, nr_pages);
 		return;
 	}
 	/*
 	 * we don't need page_cgroup_lock about tail pages, becase they are not
 	 * accessed by any other context at this point.
 	 */
-	pc->mem_cgroup = mem;
+	pc->mem_cgroup = memcg;
 	/*
 	 * We access a page_cgroup asynchronously without lock_page_cgroup().
 	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
@@ -2603,14 +2606,14 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
 		break;
 	}
 
-	mem_cgroup_charge_statistics(mem, PageCgroupCache(pc), nr_pages);
+	mem_cgroup_charge_statistics(memcg, PageCgroupCache(pc), nr_pages);
 	unlock_page_cgroup(pc);
 	/*
 	 * "charge_statistics" updated event counter. Then, check it.
 	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
 	 * if they exceeds softlimit.
 	 */
-	memcg_check_events(mem, page);
+	memcg_check_events(memcg, page);
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -2797,7 +2800,7 @@ out:
 static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask, enum charge_type ctype)
 {
-	struct mem_cgroup *mem = NULL;
+	struct mem_cgroup *memcg = NULL;
 	unsigned int nr_pages = 1;
 	struct page_cgroup *pc;
 	bool oom = true;
@@ -2816,11 +2819,11 @@ static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
 	pc = lookup_page_cgroup(page);
 	BUG_ON(!pc); /* XXX: remove this and move pc lookup into commit */
 
-	ret = __mem_cgroup_try_charge(mm, gfp_mask, nr_pages, &mem, oom);
-	if (ret || !mem)
+	ret = __mem_cgroup_try_charge(mm, gfp_mask, nr_pages, &memcg, oom);
+	if (ret || !memcg)
 		return ret;
 
-	__mem_cgroup_commit_charge(mem, page, nr_pages, pc, ctype);
+	__mem_cgroup_commit_charge(memcg, page, nr_pages, pc, ctype);
 	return 0;
 }
 
@@ -2849,7 +2852,7 @@ __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
 					enum charge_type ctype);
 
 static void
-__mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *mem,
+__mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *memcg,
 					enum charge_type ctype)
 {
 	struct page_cgroup *pc = lookup_page_cgroup(page);
@@ -2859,7 +2862,7 @@ __mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *mem,
 	 * LRU. Take care of it.
 	 */
 	mem_cgroup_lru_del_before_commit(page);
-	__mem_cgroup_commit_charge(mem, page, 1, pc, ctype);
+	__mem_cgroup_commit_charge(memcg, page, 1, pc, ctype);
 	mem_cgroup_lru_add_after_commit(page);
 	return;
 }
@@ -2867,7 +2870,7 @@ __mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *mem,
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask)
 {
-	struct mem_cgroup *mem = NULL;
+	struct mem_cgroup *memcg = NULL;
 	int ret;
 
 	if (mem_cgroup_disabled())
@@ -2879,8 +2882,8 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 		mm = &init_mm;
 
 	if (page_is_file_cache(page)) {
-		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, &mem, true);
-		if (ret || !mem)
+		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, &memcg, true);
+		if (ret || !memcg)
 			return ret;
 
 		/*
@@ -2888,15 +2891,15 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 		 * put that would remove them from the LRU list, make
 		 * sure that they get relinked properly.
 		 */
-		__mem_cgroup_commit_charge_lrucare(page, mem,
+		__mem_cgroup_commit_charge_lrucare(page, memcg,
 					MEM_CGROUP_CHARGE_TYPE_CACHE);
 		return ret;
 	}
 	/* shmem */
 	if (PageSwapCache(page)) {
-		ret = mem_cgroup_try_charge_swapin(mm, page, gfp_mask, &mem);
+		ret = mem_cgroup_try_charge_swapin(mm, page, gfp_mask, &memcg);
 		if (!ret)
-			__mem_cgroup_commit_charge_swapin(page, mem,
+			__mem_cgroup_commit_charge_swapin(page, memcg,
 					MEM_CGROUP_CHARGE_TYPE_SHMEM);
 	} else
 		ret = mem_cgroup_charge_common(page, mm, gfp_mask,
@@ -2915,7 +2918,7 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 				 struct page *page,
 				 gfp_t mask, struct mem_cgroup **ptr)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *memcg;
 	int ret;
 
 	*ptr = NULL;
@@ -2933,12 +2936,12 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 	 */
 	if (!PageSwapCache(page))
 		goto charge_cur_mm;
-	mem = try_get_mem_cgroup_from_page(page);
-	if (!mem)
+	memcg = try_get_mem_cgroup_from_page(page);
+	if (!memcg)
 		goto charge_cur_mm;
-	*ptr = mem;
+	*ptr = memcg;
 	ret = __mem_cgroup_try_charge(NULL, mask, 1, ptr, true);
-	css_put(&mem->css);
+	css_put(&memcg->css);
 	return ret;
 charge_cur_mm:
 	if (unlikely(!mm))
@@ -2998,16 +3001,16 @@ void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
 					MEM_CGROUP_CHARGE_TYPE_MAPPED);
 }
 
-void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
+void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *memcg)
 {
 	if (mem_cgroup_disabled())
 		return;
-	if (!mem)
+	if (!memcg)
 		return;
-	__mem_cgroup_cancel_charge(mem, 1);
+	__mem_cgroup_cancel_charge(memcg, 1);
 }
 
-static void mem_cgroup_do_uncharge(struct mem_cgroup *mem,
+static void mem_cgroup_do_uncharge(struct mem_cgroup *memcg,
 				   unsigned int nr_pages,
 				   const enum charge_type ctype)
 {
@@ -3025,7 +3028,7 @@ static void mem_cgroup_do_uncharge(struct mem_cgroup *mem,
 	 * uncharges. Then, it's ok to ignore memcg's refcnt.
 	 */
 	if (!batch->memcg)
-		batch->memcg = mem;
+		batch->memcg = memcg;
 	/*
 	 * do_batch > 0 when unmapping pages or inode invalidate/truncate.
 	 * In those cases, all pages freed continuously can be expected to be in
@@ -3045,7 +3048,7 @@ static void mem_cgroup_do_uncharge(struct mem_cgroup *mem,
 	 * merge a series of uncharges to an uncharge of res_counter.
 	 * If not, we uncharge res_counter ony by one.
 	 */
-	if (batch->memcg != mem)
+	if (batch->memcg != memcg)
 		goto direct_uncharge;
 	/* remember freed charge and uncharge it later */
 	batch->nr_pages++;
@@ -3053,11 +3056,11 @@ static void mem_cgroup_do_uncharge(struct mem_cgroup *mem,
 		batch->memsw_nr_pages++;
 	return;
 direct_uncharge:
-	res_counter_uncharge(&mem->res, nr_pages * PAGE_SIZE);
+	res_counter_uncharge(&memcg->res, nr_pages * PAGE_SIZE);
 	if (uncharge_memsw)
-		res_counter_uncharge(&mem->memsw, nr_pages * PAGE_SIZE);
-	if (unlikely(batch->memcg != mem))
-		memcg_oom_recover(mem);
+		res_counter_uncharge(&memcg->memsw, nr_pages * PAGE_SIZE);
+	if (unlikely(batch->memcg != memcg))
+		memcg_oom_recover(memcg);
 	return;
 }
 
@@ -3067,7 +3070,7 @@ direct_uncharge:
 static struct mem_cgroup *
 __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 {
-	struct mem_cgroup *mem = NULL;
+	struct mem_cgroup *memcg = NULL;
 	unsigned int nr_pages = 1;
 	struct page_cgroup *pc;
 
@@ -3090,7 +3093,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 
 	lock_page_cgroup(pc);
 
-	mem = pc->mem_cgroup;
+	memcg = pc->mem_cgroup;
 
 	if (!PageCgroupUsed(pc))
 		goto unlock_out;
@@ -3113,7 +3116,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 		break;
 	}
 
-	mem_cgroup_charge_statistics(mem, PageCgroupCache(pc), -nr_pages);
+	mem_cgroup_charge_statistics(memcg, PageCgroupCache(pc), -nr_pages);
 
 	ClearPageCgroupUsed(pc);
 	/*
@@ -3128,15 +3131,15 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	 * even after unlock, we have mem->res.usage here and this memcg
 	 * will never be freed.
 	 */
-	memcg_check_events(mem, page);
+	memcg_check_events(memcg, page);
 	if (do_swap_account && ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT) {
-		mem_cgroup_swap_statistics(mem, true);
-		mem_cgroup_get(mem);
+		mem_cgroup_swap_statistics(memcg, true);
+		mem_cgroup_get(memcg);
 	}
-	if (!mem_cgroup_is_root(mem))
-		mem_cgroup_do_uncharge(mem, nr_pages, ctype);
+	if (!mem_cgroup_is_root(memcg))
+		mem_cgroup_do_uncharge(memcg, nr_pages, ctype);
 
-	return mem;
+	return memcg;
 
 unlock_out:
 	unlock_page_cgroup(pc);
@@ -3326,7 +3329,7 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
 int mem_cgroup_prepare_migration(struct page *page,
 	struct page *newpage, struct mem_cgroup **ptr, gfp_t gfp_mask)
 {
-	struct mem_cgroup *mem = NULL;
+	struct mem_cgroup *memcg = NULL;
 	struct page_cgroup *pc;
 	enum charge_type ctype;
 	int ret = 0;
@@ -3340,8 +3343,8 @@ int mem_cgroup_prepare_migration(struct page *page,
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
-		mem = pc->mem_cgroup;
-		css_get(&mem->css);
+		memcg = pc->mem_cgroup;
+		css_get(&memcg->css);
 		/*
 		 * At migrating an anonymous page, its mapcount goes down
 		 * to 0 and uncharge() will be called. But, even if it's fully
@@ -3379,12 +3382,12 @@ int mem_cgroup_prepare_migration(struct page *page,
 	 * If the page is not charged at this point,
 	 * we return here.
 	 */
-	if (!mem)
+	if (!memcg)
 		return 0;
 
-	*ptr = mem;
+	*ptr = memcg;
 	ret = __mem_cgroup_try_charge(NULL, gfp_mask, 1, ptr, false);
-	css_put(&mem->css);/* drop extra refcnt */
+	css_put(&memcg->css);/* drop extra refcnt */
 	if (ret || *ptr == NULL) {
 		if (PageAnon(page)) {
 			lock_page_cgroup(pc);
@@ -3410,21 +3413,21 @@ int mem_cgroup_prepare_migration(struct page *page,
 		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
 	else
 		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
-	__mem_cgroup_commit_charge(mem, page, 1, pc, ctype);
+	__mem_cgroup_commit_charge(memcg, page, 1, pc, ctype);
 	return ret;
 }
 
 /* remove redundant charge if migration failed*/
-void mem_cgroup_end_migration(struct mem_cgroup *mem,
+void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 	struct page *oldpage, struct page *newpage, bool migration_ok)
 {
 	struct page *used, *unused;
 	struct page_cgroup *pc;
 
-	if (!mem)
+	if (!memcg)
 		return;
 	/* blocks rmdir() */
-	cgroup_exclude_rmdir(&mem->css);
+	cgroup_exclude_rmdir(&memcg->css);
 	if (!migration_ok) {
 		used = oldpage;
 		unused = newpage;
@@ -3460,7 +3463,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
 	 * So, rmdir()->pre_destroy() can be called while we do this charge.
 	 * In that case, we need to call pre_destroy() again. check it here.
 	 */
-	cgroup_release_and_wakeup_rmdir(&mem->css);
+	cgroup_release_and_wakeup_rmdir(&memcg->css);
 }
 
 #ifdef CONFIG_DEBUG_VM
@@ -3539,7 +3542,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 		/*
 		 * Rather than hide all in some function, I do this in
 		 * open coded manner. You see what this really does.
-		 * We have to guarantee mem->res.limit < mem->memsw.limit.
+		 * We have to guarantee memcg->res.limit < memcg->memsw.limit.
 		 */
 		mutex_lock(&set_limit_mutex);
 		memswlimit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
@@ -3601,7 +3604,7 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 		/*
 		 * Rather than hide all in some function, I do this in
 		 * open coded manner. You see what this really does.
-		 * We have to guarantee mem->res.limit < mem->memsw.limit.
+		 * We have to guarantee memcg->res.limit < memcg->memsw.limit.
 		 */
 		mutex_lock(&set_limit_mutex);
 		memlimit = res_counter_read_u64(&memcg->res, RES_LIMIT);
@@ -3739,7 +3742,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
  * This routine traverse page_cgroup in given list and drop them all.
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
  */
-static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
+static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 				int node, int zid, enum lru_list lru)
 {
 	struct zone *zone;
@@ -3750,7 +3753,7 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 	int ret = 0;
 
 	zone = &NODE_DATA(node)->node_zones[zid];
-	mz = mem_cgroup_zoneinfo(mem, node, zid);
+	mz = mem_cgroup_zoneinfo(memcg, node, zid);
 	list = &mz->lists[lru];
 
 	loop = MEM_CGROUP_ZSTAT(mz, lru);
@@ -3777,7 +3780,7 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 
 		page = lookup_cgroup_page(pc);
 
-		ret = mem_cgroup_move_parent(page, pc, mem, GFP_KERNEL);
+		ret = mem_cgroup_move_parent(page, pc, memcg, GFP_KERNEL);
 		if (ret == -ENOMEM)
 			break;
 
@@ -3798,14 +3801,14 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
  * make mem_cgroup's charge to be 0 if there is no task.
  * This enables deleting this mem_cgroup.
  */
-static int mem_cgroup_force_empty(struct mem_cgroup *mem, bool free_all)
+static int mem_cgroup_force_empty(struct mem_cgroup *memcg, bool free_all)
 {
 	int ret;
 	int node, zid, shrink;
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
-	struct cgroup *cgrp = mem->css.cgroup;
+	struct cgroup *cgrp = memcg->css.cgroup;
 
-	css_get(&mem->css);
+	css_get(&memcg->css);
 
 	shrink = 0;
 	/* should free all ? */
@@ -3821,14 +3824,14 @@ move_account:
 			goto out;
 		/* This is for making all *used* pages to be on LRU. */
 		lru_add_drain_all();
-		drain_all_stock_sync(mem);
+		drain_all_stock_sync(memcg);
 		ret = 0;
-		mem_cgroup_start_move(mem);
+		mem_cgroup_start_move(memcg);
 		for_each_node_state(node, N_HIGH_MEMORY) {
 			for (zid = 0; !ret && zid < MAX_NR_ZONES; zid++) {
 				enum lru_list l;
 				for_each_lru(l) {
-					ret = mem_cgroup_force_empty_list(mem,
+					ret = mem_cgroup_force_empty_list(memcg,
 							node, zid, l);
 					if (ret)
 						break;
@@ -3837,16 +3840,16 @@ move_account:
 			if (ret)
 				break;
 		}
-		mem_cgroup_end_move(mem);
-		memcg_oom_recover(mem);
+		mem_cgroup_end_move(memcg);
+		memcg_oom_recover(memcg);
 		/* it seems parent cgroup doesn't have enough mem */
 		if (ret == -ENOMEM)
 			goto try_to_free;
 		cond_resched();
 	/* "ret" should also be checked to ensure all lists are empty. */
-	} while (mem->res.usage > 0 || ret);
+	} while (memcg->res.usage > 0 || ret);
 out:
-	css_put(&mem->css);
+	css_put(&memcg->css);
 	return ret;
 
 try_to_free:
@@ -3859,7 +3862,7 @@ try_to_free:
 	lru_add_drain_all();
 	/* try to free all pages in this cgroup */
 	shrink = 1;
-	while (nr_retries && mem->res.usage > 0) {
+	while (nr_retries && memcg->res.usage > 0) {
 		struct memcg_scanrecord rec;
 		int progress;
 
@@ -3868,9 +3871,9 @@ try_to_free:
 			goto out;
 		}
 		rec.context = SCAN_BY_SHRINK;
-		rec.mem = mem;
-		rec.root = mem;
-		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
+		rec.mem = memcg;
+		rec.root = memcg;
+		progress = try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL,
 						false, &rec);
 		if (!progress) {
 			nr_retries--;
@@ -3899,12 +3902,12 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
 					u64 val)
 {
 	int retval = 0;
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 	struct cgroup *parent = cont->parent;
-	struct mem_cgroup *parent_mem = NULL;
+	struct mem_cgroup *parent_memcg = NULL;
 
 	if (parent)
-		parent_mem = mem_cgroup_from_cont(parent);
+		parent_memcg = mem_cgroup_from_cont(parent);
 
 	cgroup_lock();
 	/*
@@ -3915,10 +3918,10 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
 	 * For the root cgroup, parent_mem is NULL, we allow value to be
 	 * set if there are no children.
 	 */
-	if ((!parent_mem || !parent_mem->use_hierarchy) &&
+	if ((!parent_memcg || !parent_memcg->use_hierarchy) &&
 				(val == 1 || val == 0)) {
 		if (list_empty(&cont->children))
-			mem->use_hierarchy = val;
+			memcg->use_hierarchy = val;
 		else
 			retval = -EBUSY;
 	} else
@@ -3929,14 +3932,14 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
 }
 
 
-static unsigned long mem_cgroup_recursive_stat(struct mem_cgroup *mem,
+static unsigned long mem_cgroup_recursive_stat(struct mem_cgroup *memcg,
 					       enum mem_cgroup_stat_index idx)
 {
 	struct mem_cgroup *iter;
 	long val = 0;
 
 	/* Per-cpu values can be negative, use a signed accumulator */
-	for_each_mem_cgroup_tree(iter, mem)
+	for_each_mem_cgroup_tree(iter, memcg)
 		val += mem_cgroup_read_stat(iter, idx);
 
 	if (val < 0) /* race ? */
@@ -3944,29 +3947,29 @@ static unsigned long mem_cgroup_recursive_stat(struct mem_cgroup *mem,
 	return val;
 }
 
-static inline u64 mem_cgroup_usage(struct mem_cgroup *mem, bool swap)
+static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 {
 	u64 val;
 
-	if (!mem_cgroup_is_root(mem)) {
+	if (!mem_cgroup_is_root(memcg)) {
 		if (!swap)
-			return res_counter_read_u64(&mem->res, RES_USAGE);
+			return res_counter_read_u64(&memcg->res, RES_USAGE);
 		else
-			return res_counter_read_u64(&mem->memsw, RES_USAGE);
+			return res_counter_read_u64(&memcg->memsw, RES_USAGE);
 	}
 
-	val = mem_cgroup_recursive_stat(mem, MEM_CGROUP_STAT_CACHE);
-	val += mem_cgroup_recursive_stat(mem, MEM_CGROUP_STAT_RSS);
+	val = mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_CACHE);
+	val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_RSS);
 
 	if (swap)
-		val += mem_cgroup_recursive_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
+		val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_SWAPOUT);
 
 	return val << PAGE_SHIFT;
 }
 
 static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 {
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 	u64 val;
 	int type, name;
 
@@ -3975,15 +3978,15 @@ static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 	switch (type) {
 	case _MEM:
 		if (name == RES_USAGE)
-			val = mem_cgroup_usage(mem, false);
+			val = mem_cgroup_usage(memcg, false);
 		else
-			val = res_counter_read_u64(&mem->res, name);
+			val = res_counter_read_u64(&memcg->res, name);
 		break;
 	case _MEMSWAP:
 		if (name == RES_USAGE)
-			val = mem_cgroup_usage(mem, true);
+			val = mem_cgroup_usage(memcg, true);
 		else
-			val = res_counter_read_u64(&mem->memsw, name);
+			val = res_counter_read_u64(&memcg->memsw, name);
 		break;
 	default:
 		BUG();
@@ -4071,24 +4074,24 @@ out:
 
 static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *memcg;
 	int type, name;
 
-	mem = mem_cgroup_from_cont(cont);
+	memcg = mem_cgroup_from_cont(cont);
 	type = MEMFILE_TYPE(event);
 	name = MEMFILE_ATTR(event);
 	switch (name) {
 	case RES_MAX_USAGE:
 		if (type == _MEM)
-			res_counter_reset_max(&mem->res);
+			res_counter_reset_max(&memcg->res);
 		else
-			res_counter_reset_max(&mem->memsw);
+			res_counter_reset_max(&memcg->memsw);
 		break;
 	case RES_FAILCNT:
 		if (type == _MEM)
-			res_counter_reset_failcnt(&mem->res);
+			res_counter_reset_failcnt(&memcg->res);
 		else
-			res_counter_reset_failcnt(&mem->memsw);
+			res_counter_reset_failcnt(&memcg->memsw);
 		break;
 	}
 
@@ -4105,7 +4108,7 @@ static u64 mem_cgroup_move_charge_read(struct cgroup *cgrp,
 static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
 					struct cftype *cft, u64 val)
 {
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
 
 	if (val >= (1 << NR_MOVE_TYPE))
 		return -EINVAL;
@@ -4115,7 +4118,7 @@ static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
 	 * inconsistent.
 	 */
 	cgroup_lock();
-	mem->move_charge_at_immigrate = val;
+	memcg->move_charge_at_immigrate = val;
 	cgroup_unlock();
 
 	return 0;
@@ -4172,49 +4175,49 @@ struct {
 
 
 static void
-mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
+mem_cgroup_get_local_stat(struct mem_cgroup *memcg, struct mcs_total_stat *s)
 {
 	s64 val;
 
 	/* per cpu stat */
-	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_CACHE);
+	val = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_CACHE);
 	s->stat[MCS_CACHE] += val * PAGE_SIZE;
-	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_RSS);
+	val = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_RSS);
 	s->stat[MCS_RSS] += val * PAGE_SIZE;
-	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_MAPPED);
+	val = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
 	s->stat[MCS_FILE_MAPPED] += val * PAGE_SIZE;
-	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGPGIN);
+	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGPGIN);
 	s->stat[MCS_PGPGIN] += val;
-	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGPGOUT);
+	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGPGOUT);
 	s->stat[MCS_PGPGOUT] += val;
 	if (do_swap_account) {
-		val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
+		val = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_SWAPOUT);
 		s->stat[MCS_SWAP] += val * PAGE_SIZE;
 	}
-	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGFAULT);
+	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGFAULT);
 	s->stat[MCS_PGFAULT] += val;
-	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGMAJFAULT);
+	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGMAJFAULT);
 	s->stat[MCS_PGMAJFAULT] += val;
 
 	/* per zone stat */
-	val = mem_cgroup_nr_lru_pages(mem, BIT(LRU_INACTIVE_ANON));
+	val = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_INACTIVE_ANON));
 	s->stat[MCS_INACTIVE_ANON] += val * PAGE_SIZE;
-	val = mem_cgroup_nr_lru_pages(mem, BIT(LRU_ACTIVE_ANON));
+	val = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_ACTIVE_ANON));
 	s->stat[MCS_ACTIVE_ANON] += val * PAGE_SIZE;
-	val = mem_cgroup_nr_lru_pages(mem, BIT(LRU_INACTIVE_FILE));
+	val = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_INACTIVE_FILE));
 	s->stat[MCS_INACTIVE_FILE] += val * PAGE_SIZE;
-	val = mem_cgroup_nr_lru_pages(mem, BIT(LRU_ACTIVE_FILE));
+	val = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_ACTIVE_FILE));
 	s->stat[MCS_ACTIVE_FILE] += val * PAGE_SIZE;
-	val = mem_cgroup_nr_lru_pages(mem, BIT(LRU_UNEVICTABLE));
+	val = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_UNEVICTABLE));
 	s->stat[MCS_UNEVICTABLE] += val * PAGE_SIZE;
 }
 
 static void
-mem_cgroup_get_total_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
+mem_cgroup_get_total_stat(struct mem_cgroup *memcg, struct mcs_total_stat *s)
 {
 	struct mem_cgroup *iter;
 
-	for_each_mem_cgroup_tree(iter, mem)
+	for_each_mem_cgroup_tree(iter, memcg)
 		mem_cgroup_get_local_stat(iter, s);
 }
 
@@ -4438,20 +4441,20 @@ static int compare_thresholds(const void *a, const void *b)
 	return _a->threshold - _b->threshold;
 }
 
-static int mem_cgroup_oom_notify_cb(struct mem_cgroup *mem)
+static int mem_cgroup_oom_notify_cb(struct mem_cgroup *memcg)
 {
 	struct mem_cgroup_eventfd_list *ev;
 
-	list_for_each_entry(ev, &mem->oom_notify, list)
+	list_for_each_entry(ev, &memcg->oom_notify, list)
 		eventfd_signal(ev->eventfd, 1);
 	return 0;
 }
 
-static void mem_cgroup_oom_notify(struct mem_cgroup *mem)
+static void mem_cgroup_oom_notify(struct mem_cgroup *memcg)
 {
 	struct mem_cgroup *iter;
 
-	for_each_mem_cgroup_tree(iter, mem)
+	for_each_mem_cgroup_tree(iter, memcg)
 		mem_cgroup_oom_notify_cb(iter);
 }
 
@@ -4641,7 +4644,7 @@ static int mem_cgroup_oom_register_event(struct cgroup *cgrp,
 static void mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
 	struct cftype *cft, struct eventfd_ctx *eventfd)
 {
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
 	struct mem_cgroup_eventfd_list *ev, *tmp;
 	int type = MEMFILE_TYPE(cft->private);
 
@@ -4649,7 +4652,7 @@ static void mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
 
 	spin_lock(&memcg_oom_lock);
 
-	list_for_each_entry_safe(ev, tmp, &mem->oom_notify, list) {
+	list_for_each_entry_safe(ev, tmp, &memcg->oom_notify, list) {
 		if (ev->eventfd == eventfd) {
 			list_del(&ev->list);
 			kfree(ev);
@@ -4662,11 +4665,11 @@ static void mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
 static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
 	struct cftype *cft,  struct cgroup_map_cb *cb)
 {
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
 
-	cb->fill(cb, "oom_kill_disable", mem->oom_kill_disable);
+	cb->fill(cb, "oom_kill_disable", memcg->oom_kill_disable);
 
-	if (atomic_read(&mem->under_oom))
+	if (atomic_read(&memcg->under_oom))
 		cb->fill(cb, "under_oom", 1);
 	else
 		cb->fill(cb, "under_oom", 0);
@@ -4676,7 +4679,7 @@ static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
 static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
 	struct cftype *cft, u64 val)
 {
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
 	struct mem_cgroup *parent;
 
 	/* cannot set to root cgroup and only 0 and 1 are allowed */
@@ -4688,13 +4691,13 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
 	cgroup_lock();
 	/* oom-kill-disable is a flag for subhierarchy. */
 	if ((parent->use_hierarchy) ||
-	    (mem->use_hierarchy && !list_empty(&cgrp->children))) {
+	    (memcg->use_hierarchy && !list_empty(&cgrp->children))) {
 		cgroup_unlock();
 		return -EINVAL;
 	}
-	mem->oom_kill_disable = val;
+	memcg->oom_kill_disable = val;
 	if (!val)
-		memcg_oom_recover(mem);
+		memcg_oom_recover(memcg);
 	cgroup_unlock();
 	return 0;
 }
@@ -4719,33 +4722,35 @@ static int mem_cgroup_vmscan_stat_read(struct cgroup *cgrp,
 				struct cftype *cft,
 				struct cgroup_map_cb *cb)
 {
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
 	char string[64];
 	int i;
 
 	for (i = 0; i < NR_SCANSTATS; i++) {
 		strcpy(string, scanstat_string[i]);
 		strcat(string, SCANSTAT_WORD_LIMIT);
-		cb->fill(cb, string,  mem->scanstat.stats[SCAN_BY_LIMIT][i]);
+		cb->fill(cb, string, memcg->scanstat.stats[SCAN_BY_LIMIT][i]);
 	}
 
 	for (i = 0; i < NR_SCANSTATS; i++) {
 		strcpy(string, scanstat_string[i]);
 		strcat(string, SCANSTAT_WORD_SYSTEM);
-		cb->fill(cb, string,  mem->scanstat.stats[SCAN_BY_SYSTEM][i]);
+		cb->fill(cb, string, memcg->scanstat.stats[SCAN_BY_SYSTEM][i]);
 	}
 
 	for (i = 0; i < NR_SCANSTATS; i++) {
 		strcpy(string, scanstat_string[i]);
 		strcat(string, SCANSTAT_WORD_LIMIT);
 		strcat(string, SCANSTAT_WORD_HIERARCHY);
-		cb->fill(cb, string,  mem->scanstat.rootstats[SCAN_BY_LIMIT][i]);
+		cb->fill(cb,
+			string, memcg->scanstat.rootstats[SCAN_BY_LIMIT][i]);
 	}
 	for (i = 0; i < NR_SCANSTATS; i++) {
 		strcpy(string, scanstat_string[i]);
 		strcat(string, SCANSTAT_WORD_SYSTEM);
 		strcat(string, SCANSTAT_WORD_HIERARCHY);
-		cb->fill(cb, string,  mem->scanstat.rootstats[SCAN_BY_SYSTEM][i]);
+		cb->fill(cb,
+			string, memcg->scanstat.rootstats[SCAN_BY_SYSTEM][i]);
 	}
 	return 0;
 }
@@ -4753,12 +4758,13 @@ static int mem_cgroup_vmscan_stat_read(struct cgroup *cgrp,
 static int mem_cgroup_reset_vmscan_stat(struct cgroup *cgrp,
 				unsigned int event)
 {
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
 
-	spin_lock(&mem->scanstat.lock);
-	memset(&mem->scanstat.stats, 0, sizeof(mem->scanstat.stats));
-	memset(&mem->scanstat.rootstats, 0, sizeof(mem->scanstat.rootstats));
-	spin_unlock(&mem->scanstat.lock);
+	spin_lock(&memcg->scanstat.lock);
+	memset(&memcg->scanstat.stats, 0, sizeof(memcg->scanstat.stats));
+	memset(&memcg->scanstat.rootstats,
+		0, sizeof(memcg->scanstat.rootstats));
+	spin_unlock(&memcg->scanstat.lock);
 	return 0;
 }
 
@@ -4883,7 +4889,7 @@ static int register_memsw_files(struct cgroup *cont, struct cgroup_subsys *ss)
 }
 #endif
 
-static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
+static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 {
 	struct mem_cgroup_per_node *pn;
 	struct mem_cgroup_per_zone *mz;
@@ -4909,9 +4915,9 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
 			INIT_LIST_HEAD(&mz->lists[l]);
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
-		mz->mem = mem;
+		mz->mem = memcg;
 	}
-	mem->info.nodeinfo[node] = pn;
+	memcg->info.nodeinfo[node] = pn;
 	return 0;
 }
 
@@ -4959,51 +4965,51 @@ out_free:
  * Removal of cgroup itself succeeds regardless of refs from swap.
  */
 
-static void __mem_cgroup_free(struct mem_cgroup *mem)
+static void __mem_cgroup_free(struct mem_cgroup *memcg)
 {
 	int node;
 
-	mem_cgroup_remove_from_trees(mem);
-	free_css_id(&mem_cgroup_subsys, &mem->css);
+	mem_cgroup_remove_from_trees(memcg);
+	free_css_id(&mem_cgroup_subsys, &memcg->css);
 
 	for_each_node_state(node, N_POSSIBLE)
-		free_mem_cgroup_per_zone_info(mem, node);
+		free_mem_cgroup_per_zone_info(memcg, node);
 
-	free_percpu(mem->stat);
+	free_percpu(memcg->stat);
 	if (sizeof(struct mem_cgroup) < PAGE_SIZE)
-		kfree(mem);
+		kfree(memcg);
 	else
-		vfree(mem);
+		vfree(memcg);
 }
 
-static void mem_cgroup_get(struct mem_cgroup *mem)
+static void mem_cgroup_get(struct mem_cgroup *memcg)
 {
-	atomic_inc(&mem->refcnt);
+	atomic_inc(&memcg->refcnt);
 }
 
-static void __mem_cgroup_put(struct mem_cgroup *mem, int count)
+static void __mem_cgroup_put(struct mem_cgroup *memcg, int count)
 {
-	if (atomic_sub_and_test(count, &mem->refcnt)) {
-		struct mem_cgroup *parent = parent_mem_cgroup(mem);
-		__mem_cgroup_free(mem);
+	if (atomic_sub_and_test(count, &memcg->refcnt)) {
+		struct mem_cgroup *parent = parent_mem_cgroup(memcg);
+		__mem_cgroup_free(memcg);
 		if (parent)
 			mem_cgroup_put(parent);
 	}
 }
 
-static void mem_cgroup_put(struct mem_cgroup *mem)
+static void mem_cgroup_put(struct mem_cgroup *memcg)
 {
-	__mem_cgroup_put(mem, 1);
+	__mem_cgroup_put(memcg, 1);
 }
 
 /*
  * Returns the parent mem_cgroup in memcgroup hierarchy with hierarchy enabled.
  */
-static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem)
+static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg)
 {
-	if (!mem->res.parent)
+	if (!memcg->res.parent)
 		return NULL;
-	return mem_cgroup_from_res_counter(mem->res.parent, res);
+	return mem_cgroup_from_res_counter(memcg->res.parent, res);
 }
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
@@ -5046,16 +5052,16 @@ static int mem_cgroup_soft_limit_tree_init(void)
 static struct cgroup_subsys_state * __ref
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
-	struct mem_cgroup *mem, *parent;
+	struct mem_cgroup *memcg, *parent;
 	long error = -ENOMEM;
 	int node;
 
-	mem = mem_cgroup_alloc();
-	if (!mem)
+	memcg = mem_cgroup_alloc();
+	if (!memcg)
 		return ERR_PTR(error);
 
 	for_each_node_state(node, N_POSSIBLE)
-		if (alloc_mem_cgroup_per_zone_info(mem, node))
+		if (alloc_mem_cgroup_per_zone_info(memcg, node))
 			goto free_out;
 
 	/* root ? */
@@ -5063,7 +5069,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 		int cpu;
 		enable_swap_cgroup();
 		parent = NULL;
-		root_mem_cgroup = mem;
+		root_mem_cgroup = memcg;
 		if (mem_cgroup_soft_limit_tree_init())
 			goto free_out;
 		for_each_possible_cpu(cpu) {
@@ -5074,13 +5080,13 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 		hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
-		mem->use_hierarchy = parent->use_hierarchy;
-		mem->oom_kill_disable = parent->oom_kill_disable;
+		memcg->use_hierarchy = parent->use_hierarchy;
+		memcg->oom_kill_disable = parent->oom_kill_disable;
 	}
 
 	if (parent && parent->use_hierarchy) {
-		res_counter_init(&mem->res, &parent->res);
-		res_counter_init(&mem->memsw, &parent->memsw);
+		res_counter_init(&memcg->res, &parent->res);
+		res_counter_init(&memcg->memsw, &parent->memsw);
 		/*
 		 * We increment refcnt of the parent to ensure that we can
 		 * safely access it on res_counter_charge/uncharge.
@@ -5089,22 +5095,22 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 		 */
 		mem_cgroup_get(parent);
 	} else {
-		res_counter_init(&mem->res, NULL);
-		res_counter_init(&mem->memsw, NULL);
+		res_counter_init(&memcg->res, NULL);
+		res_counter_init(&memcg->memsw, NULL);
 	}
-	mem->last_scanned_child = 0;
-	mem->last_scanned_node = MAX_NUMNODES;
-	INIT_LIST_HEAD(&mem->oom_notify);
+	memcg->last_scanned_child = 0;
+	memcg->last_scanned_node = MAX_NUMNODES;
+	INIT_LIST_HEAD(&memcg->oom_notify);
 
 	if (parent)
-		mem->swappiness = mem_cgroup_swappiness(parent);
-	atomic_set(&mem->refcnt, 1);
-	mem->move_charge_at_immigrate = 0;
-	mutex_init(&mem->thresholds_lock);
-	spin_lock_init(&mem->scanstat.lock);
-	return &mem->css;
+		memcg->swappiness = mem_cgroup_swappiness(parent);
+	atomic_set(&memcg->refcnt, 1);
+	memcg->move_charge_at_immigrate = 0;
+	mutex_init(&memcg->thresholds_lock);
+	spin_lock_init(&memcg->scanstat.lock);
+	return &memcg->css;
 free_out:
-	__mem_cgroup_free(mem);
+	__mem_cgroup_free(memcg);
 	root_mem_cgroup = NULL;
 	return ERR_PTR(error);
 }
@@ -5112,17 +5118,17 @@ free_out:
 static int mem_cgroup_pre_destroy(struct cgroup_subsys *ss,
 					struct cgroup *cont)
 {
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 
-	return mem_cgroup_force_empty(mem, false);
+	return mem_cgroup_force_empty(memcg, false);
 }
 
 static void mem_cgroup_destroy(struct cgroup_subsys *ss,
 				struct cgroup *cont)
 {
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 
-	mem_cgroup_put(mem);
+	mem_cgroup_put(memcg);
 }
 
 static int mem_cgroup_populate(struct cgroup_subsys *ss,
@@ -5145,9 +5151,9 @@ static int mem_cgroup_do_precharge(unsigned long count)
 {
 	int ret = 0;
 	int batch_count = PRECHARGE_COUNT_AT_ONCE;
-	struct mem_cgroup *mem = mc.to;
+	struct mem_cgroup *memcg = mc.to;
 
-	if (mem_cgroup_is_root(mem)) {
+	if (mem_cgroup_is_root(memcg)) {
 		mc.precharge += count;
 		/* we don't need css_get for root */
 		return ret;
@@ -5156,16 +5162,16 @@ static int mem_cgroup_do_precharge(unsigned long count)
 	if (count > 1) {
 		struct res_counter *dummy;
 		/*
-		 * "mem" cannot be under rmdir() because we've already checked
+		 * "memcg" cannot be under rmdir() because we've already checked
 		 * by cgroup_lock_live_cgroup() that it is not removed and we
 		 * are still under the same cgroup_mutex. So we can postpone
 		 * css_get().
 		 */
-		if (res_counter_charge(&mem->res, PAGE_SIZE * count, &dummy))
+		if (res_counter_charge(&memcg->res, PAGE_SIZE * count, &dummy))
 			goto one_by_one;
-		if (do_swap_account && res_counter_charge(&mem->memsw,
+		if (do_swap_account && res_counter_charge(&memcg->memsw,
 						PAGE_SIZE * count, &dummy)) {
-			res_counter_uncharge(&mem->res, PAGE_SIZE * count);
+			res_counter_uncharge(&memcg->res, PAGE_SIZE * count);
 			goto one_by_one;
 		}
 		mc.precharge += count;
@@ -5182,8 +5188,9 @@ one_by_one:
 			batch_count = PRECHARGE_COUNT_AT_ONCE;
 			cond_resched();
 		}
-		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, 1, &mem, false);
-		if (ret || !mem)
+		ret = __mem_cgroup_try_charge(NULL,
+					GFP_KERNEL, 1, &memcg, false);
+		if (ret || !memcg)
 			/* mem_cgroup_clear_mc() will do uncharge later */
 			return -ENOMEM;
 		mc.precharge++;
@@ -5457,13 +5464,13 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 				struct task_struct *p)
 {
 	int ret = 0;
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cgroup);
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgroup);
 
-	if (mem->move_charge_at_immigrate) {
+	if (memcg->move_charge_at_immigrate) {
 		struct mm_struct *mm;
 		struct mem_cgroup *from = mem_cgroup_from_task(p);
 
-		VM_BUG_ON(from == mem);
+		VM_BUG_ON(from == memcg);
 
 		mm = get_task_mm(p);
 		if (!mm)
@@ -5478,7 +5485,7 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 			mem_cgroup_start_move(from);
 			spin_lock(&mc.lock);
 			mc.from = from;
-			mc.to = mem;
+			mc.to = memcg;
 			spin_unlock(&mc.lock);
 			/* We set mc.moving_task later */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
