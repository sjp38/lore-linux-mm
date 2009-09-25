Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 864F76B00A4
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 04:33:30 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8P8XT3p026201
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 25 Sep 2009 17:33:29 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F22392AEA92
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:33:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F2D131EF085
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:32:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 837F9EF800A
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:32:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B79EC1DB8051
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:32:25 +0900 (JST)
Date: Fri, 25 Sep 2009 17:30:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 10/10] memcg: add commentary
Message-Id: <20090925173018.2435084f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>


From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Adds commenatry to memcontrol.c

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |  105 +++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 86 insertions(+), 19 deletions(-)

Index: temp-mmotm/mm/memcontrol.c
===================================================================
--- temp-mmotm.orig/mm/memcontrol.c
+++ temp-mmotm/mm/memcontrol.c
@@ -47,7 +47,10 @@ struct cgroup_subsys mem_cgroup_subsys _
 struct mem_cgroup *root_mem_cgroup __read_mostly;
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
-/* Turned on only when memory cgroup is enabled && really_do_swap_account = 1 */
+/*
+ * If this is true, we do mem+swap accounting. (see mem->memsw handling)
+ * Turned on only when memory cgroup is enabled && really_do_swap_account = 1
+ */
 int do_swap_account __read_mostly;
 static int really_do_swap_account __initdata = 1; /* for remember boot option*/
 #else
@@ -88,12 +91,13 @@ struct mem_cgroup_stat {
  */
 struct mem_cgroup_per_zone {
 	/*
-	 * spin_lock to protect the per cgroup LRU
+	 * zone->lru_lock protects the per cgroup LRU
 	 */
 	struct list_head	lists[NR_LRU_LISTS];
 	unsigned long		count[NR_LRU_LISTS];
-
+	/* reclaim_stat is used by vmscan.c. struct zone has this, too */
 	struct zone_reclaim_stat reclaim_stat;
+	/* For Softlimit handling */
 	struct rb_node		tree_node;	/* RB tree node */
 	unsigned long long	usage_in_excess;/* Set to the value by which */
 						/* the soft limit is exceeded*/
@@ -165,20 +169,32 @@ struct mem_cgroup {
 	spinlock_t reclaim_param_lock;
 
 	int	prev_priority;	/* for recording reclaim priority */
+	unsigned int	swappiness; /* form memory reclaim calculation */
 
 	/*
+	 * Should the accounting and control be hierarchical, per subtree?
+	 */
+	bool use_hierarchy;
+	/*
 	 * While reclaiming in a hiearchy, we cache the last child we
 	 * reclaimed from.
 	 */
 	int last_scanned_child;
 	/*
-	 * Should the accounting and control be hierarchical, per subtree?
+	 * Because what we handle is permanent objects, we may have references
+	 * even after all tasks are gone. Even in such case, rmdir() cgroup
+	 * should be allowed to some extent. We have private refcnt
+	 * (from swap_cgroup etc..) other than css_get/put for such cases.
 	 */
-	bool use_hierarchy;
-	unsigned long	last_oom_jiffies;
 	atomic_t	refcnt;
+	/*
+	 * When oom_kill is invoked from page fault path,
+	 * oom_kill.c::pagefault_out_of_memory() is called...but, in memcg,
+	 * we already calls oom_killer by ourselves. This jiffies is used
+	 * for avoiding calling OOM-kill twice. (see oom_kill.c also)
+	 */
+	unsigned long	last_oom_jiffies;
 
-	unsigned int	swappiness;
 
 	/* set when res.limit == memsw.limit */
 	bool		memsw_is_minimum;
@@ -204,7 +220,10 @@ enum charge_type {
 	NR_CHARGE_TYPE,
 };
 
-/* for encoding cft->private value on file */
+/*
+ * Because we have 2 types of similar controls, memory and memory.memsw, we
+ * use some encoding macro for cft->private value to share codes between them.
+ */
 #define _MEM			(0)
 #define _MEMSWAP		(1)
 #define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
@@ -1038,7 +1057,16 @@ unsigned long mem_cgroup_isolate_pages(u
 	return nr_taken;
 }
 
-
+/**
+ * task_in_mem_cgroup: check a task is under a mem_cgroup's control
+ * @task: task struct to be checked.
+ * @mem: mem_cgroup to be checked
+ *
+ * Retunrs non-zero if a task is under control of a memcgroup.
+ *
+ * This function is for checking a task is under a mem_cgroup. Because we do
+ * hierarchical accounting, we have to check all ancestors.
+ */
 
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
 {
@@ -1060,12 +1088,6 @@ int task_in_mem_cgroup(struct task_struc
 	return ret;
 }
 
-static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
-{
-	int *val = data;
-	(*val)++;
-	return 0;
-}
 
 /**
  * mem_cgroup_print_mem_info: Called from OOM with tasklist_lock held in read mode.
@@ -1134,6 +1156,12 @@ done:
 		res_counter_read_u64(&memcg->memsw, RES_FAILCNT));
 }
 
+static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
+{
+	int *val = data;
+	(*val)++;
+	return 0;
+}
 /*
  * This function returns the number of memcg under hierarchy tree. Returns
  * 1(self count) if no children.
@@ -1144,6 +1172,13 @@ static int mem_cgroup_count_children(str
  	mem_cgroup_walk_tree(mem, &num, mem_cgroup_count_children_cb);
 	return num;
 }
+
+/**
+ * mem_cgroup_oon_called - check oom-kill is called recentlry under memcg
+ * @mem: mem_cgroup to be checked.
+ *
+ * Returns true if oom-kill was invoked in this memcg recently.
+ */
 bool mem_cgroup_oom_called(struct task_struct *task)
 {
 	bool ret = false;
@@ -1314,6 +1349,16 @@ static int mem_cgroup_hierarchical_recla
 	return total;
 }
 
+/*
+ * This function is called by kswapd before entering per-zone memory reclaim.
+ * This selects a victim mem_cgroup from soft-limit tree and memory will be
+ * reclaimed from that.
+ *
+ * Soft-limit tree is sorted by the extent how many mem_cgroup's memoyr usage
+ * excess the soft limit and a memory cgroup which has the largest excess
+ * s selected as a victim. This Soft-limit tree is maintained perzone and
+ * we never select a memcg which has no memory usage on this zone.
+ */
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask, int nid,
 						int zid)
@@ -1407,7 +1452,11 @@ unsigned long mem_cgroup_soft_limit_recl
 
 /*
  * Unlike exported interface, "oom" parameter is added. if oom==true,
- * oom-killer can be invoked.
+ * oom-killer can be invoked. The callser should set oom=false if it's ok
+ * to return -ENOMEM. For example, at resizing limit of memcg.
+ *
+ * In usual case, *memcg = NULL because we charges against current task.
+ * If we charge against other, *memcg should be filled.
  */
 static int __mem_cgroup_try_charge(struct mm_struct *mm,
 			gfp_t gfp_mask, struct mem_cgroup **memcg,
@@ -1418,7 +1467,7 @@ static int __mem_cgroup_try_charge(struc
 	struct res_counter *fail_res;
 
 	if (unlikely(test_thread_flag(TIF_MEMDIE))) {
-		/* Don't account this! */
+		/* This is killed by OOM-Kill. Don't account this! */
 		*memcg = NULL;
 		return 0;
 	}
@@ -1447,8 +1496,10 @@ static int __mem_cgroup_try_charge(struc
 
 		if (mem_cgroup_is_root(mem))
 			goto done;
+		/* Check memory usage hits limit */
 		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res);
 		if (likely(!ret)) {
+			/* Memory is ok. Then Mem+Swap is ? */
 			if (!do_swap_account)
 				break;
 			ret = res_counter_charge(&mem->memsw, PAGE_SIZE,
@@ -1486,9 +1537,12 @@ static int __mem_cgroup_try_charge(struc
 
 		if (!nr_retries--) {
 			if (oom) {
+				/* Call OOM-Killer */
 				mutex_lock(&memcg_tasklist);
-				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
+				mem_cgroup_out_of_memory(mem_over_limit,
+							gfp_mask);
 				mutex_unlock(&memcg_tasklist);
+				/* Record we called OOM-Killer */
 				record_last_oom(mem_over_limit);
 			}
 			goto nomem;
@@ -1534,14 +1588,21 @@ static struct mem_cgroup *try_get_mem_cg
 
 	if (!PageSwapCache(page))
 		return NULL;
-
+	/*
+	 * At charging SwapCache, there are 2 cases in usual.
+	 * (1) a newly swapped-in page is mapped.
+	 * (2) an exisiting swap cache is mapped again.
+	 * In case (2), we need to check PageCgroupUsed().
+	 */
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
+		/* Already accounted SwapCache is mapped */
 		mem = pc->mem_cgroup;
 		if (mem && !css_tryget(&mem->css))
 			mem = NULL;
 	} else {
+		/* Maybe a new page swapped-in */
 		ent.val = page_private(page);
 		id = lookup_swap_cgroup(ent);
 		rcu_read_lock();
@@ -1569,6 +1630,7 @@ static void __mem_cgroup_commit_charge(s
 
 	lock_page_cgroup(pc);
 	if (unlikely(PageCgroupUsed(pc))) {
+		/* This means we charged this page twice. cancel ours */
 		unlock_page_cgroup(pc);
 		mem_cgroup_cancel_charge(mem);
 		return;
@@ -1757,6 +1819,11 @@ __mem_cgroup_commit_charge_swapin(struct
 		return;
 	cgroup_exclude_rmdir(&ptr->css);
 	pc = lookup_page_cgroup(page);
+	/*
+ 	 * We may overwrite pc->memcgoup in commit_charge(). But SwapCache
+ 	 * can be on LRU before we reach here. Remove it from LRU for avoiding
+ 	 * confliction.
+ 	 */
 	mem_cgroup_lru_del_before_commit_swapcache(page);
 	__mem_cgroup_commit_charge(ptr, pc, ctype);
 	mem_cgroup_lru_add_after_commit_swapcache(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
