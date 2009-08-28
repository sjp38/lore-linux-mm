Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2C7206B005C
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 00:25:12 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7S4PI9m014477
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 28 Aug 2009 13:25:18 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E47A45DE4E
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 13:25:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EFC3345DE4D
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 13:25:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D5C051DB803C
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 13:25:17 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6211BE08007
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 13:25:14 +0900 (JST)
Date: Fri, 28 Aug 2009 13:23:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 1/5] memcg: change for softlimit.
Message-Id: <20090828132321.e4a497bb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch tries to modify softlimit handling in memcg/res_counter.
There are 2 reasons in general.

 1. soft_limit can use only against sub-hierarchy root.
    Because softlimit tree is sorted by usage, putting prural groups
    under hierarchy (which shares usage) will just adds noise and unnecessary
    mess. This patch limits softlimit feature only to hierarchy root.
    This will make softlimit-tree maintainance better. 

 2. In these days, it's reported that res_counter can be bottleneck in
    massively parallel enviroment. We need to reduce jobs under spinlock.
    The reason we check softlimit at res_counter_charge() is that any member
    in hierarchy can have softlimit.
    But by chages in "1", only hierarchy root has soft_limit. We can omit
    hierarchical check in res_counter.

After this patch, soft limit is avaliable only for root of sub-hierarchy.
(Anyway, softlimit for hierarchy children just makes users confused, hard-to-use)

This modifes
  - drop unneccesary checks from res_coutner_charge().uncharge()
  - mem->sub_hierarchy_root is added.
  - only hierarchy root memcg can be on softlimit tree.


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 Documentation/cgroups/memory.txt |    2 
 include/linux/res_counter.h      |    6 --
 kernel/res_counter.c             |   14 ----
 mm/memcontrol.c                  |  113 +++++++++++++++++++++++----------------
 4 files changed, 74 insertions(+), 61 deletions(-)

Index: mmotm-2.6.31-Aug27/include/linux/res_counter.h
===================================================================
--- mmotm-2.6.31-Aug27.orig/include/linux/res_counter.h
+++ mmotm-2.6.31-Aug27/include/linux/res_counter.h
@@ -114,8 +114,7 @@ void res_counter_init(struct res_counter
 int __must_check res_counter_charge_locked(struct res_counter *counter,
 		unsigned long val);
 int __must_check res_counter_charge(struct res_counter *counter,
-		unsigned long val, struct res_counter **limit_fail_at,
-		struct res_counter **soft_limit_at);
+			unsigned long val, struct res_counter **limit_fail_at);
 
 /*
  * uncharge - tell that some portion of the resource is released
@@ -128,8 +127,7 @@ int __must_check res_counter_charge(stru
  */
 
 void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val);
-void res_counter_uncharge(struct res_counter *counter, unsigned long val,
-				bool *was_soft_limit_excess);
+void res_counter_uncharge(struct res_counter *counter, unsigned long val);
 
 static inline bool res_counter_limit_check_locked(struct res_counter *cnt)
 {
Index: mmotm-2.6.31-Aug27/kernel/res_counter.c
===================================================================
--- mmotm-2.6.31-Aug27.orig/kernel/res_counter.c
+++ mmotm-2.6.31-Aug27/kernel/res_counter.c
@@ -37,16 +37,13 @@ int res_counter_charge_locked(struct res
 }
 
 int res_counter_charge(struct res_counter *counter, unsigned long val,
-			struct res_counter **limit_fail_at,
-			struct res_counter **soft_limit_fail_at)
+		struct res_counter **limit_fail_at)
 {
 	int ret;
 	unsigned long flags;
 	struct res_counter *c, *u;
 
 	*limit_fail_at = NULL;
-	if (soft_limit_fail_at)
-		*soft_limit_fail_at = NULL;
 	local_irq_save(flags);
 	for (c = counter; c != NULL; c = c->parent) {
 		spin_lock(&c->lock);
@@ -55,9 +52,6 @@ int res_counter_charge(struct res_counte
 		 * With soft limits, we return the highest ancestor
 		 * that exceeds its soft limit
 		 */
-		if (soft_limit_fail_at &&
-			!res_counter_soft_limit_check_locked(c))
-			*soft_limit_fail_at = c;
 		spin_unlock(&c->lock);
 		if (ret < 0) {
 			*limit_fail_at = c;
@@ -85,8 +79,7 @@ void res_counter_uncharge_locked(struct 
 	counter->usage -= val;
 }
 
-void res_counter_uncharge(struct res_counter *counter, unsigned long val,
-				bool *was_soft_limit_excess)
+void res_counter_uncharge(struct res_counter *counter, unsigned long val)
 {
 	unsigned long flags;
 	struct res_counter *c;
@@ -94,9 +87,6 @@ void res_counter_uncharge(struct res_cou
 	local_irq_save(flags);
 	for (c = counter; c != NULL; c = c->parent) {
 		spin_lock(&c->lock);
-		if (was_soft_limit_excess)
-			*was_soft_limit_excess =
-				!res_counter_soft_limit_check_locked(c);
 		res_counter_uncharge_locked(c, val);
 		spin_unlock(&c->lock);
 	}
Index: mmotm-2.6.31-Aug27/mm/memcontrol.c
===================================================================
--- mmotm-2.6.31-Aug27.orig/mm/memcontrol.c
+++ mmotm-2.6.31-Aug27/mm/memcontrol.c
@@ -221,6 +221,8 @@ struct mem_cgroup {
 	atomic_t	refcnt;
 
 	unsigned int	swappiness;
+	/* sub hierarchy root cgroup */
+	struct mem_cgroup *sub_hierarchy_root;
 
 	/* set when res.limit == memsw.limit */
 	bool		memsw_is_minimum;
@@ -372,22 +374,28 @@ mem_cgroup_remove_exceeded(struct mem_cg
 	spin_unlock(&mctz->lock);
 }
 
-static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
+/*
+ * Check subhierarchy root's event counter. If event counter is over threshold,
+ * retrun root. (and the caller will trigger status-check event)
+ */
+static struct mem_cgroup * mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
 {
-	bool ret = false;
 	int cpu;
 	s64 val;
+	struct mem_cgroup *softlimit_root = mem->sub_hierarchy_root;
 	struct mem_cgroup_stat_cpu *cpustat;
 
+	if (!softlimit_root)
+		return NULL;
 	cpu = get_cpu();
-	cpustat = &mem->stat.cpustat[cpu];
+	cpustat = &softlimit_root->stat.cpustat[cpu];
 	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_EVENTS);
-	if (unlikely(val > SOFTLIMIT_EVENTS_THRESH)) {
+	if (unlikely(val > SOFTLIMIT_EVENTS_THRESH))
 		__mem_cgroup_stat_reset_safe(cpustat, MEM_CGROUP_STAT_EVENTS);
-		ret = true;
-	}
+	else
+		softlimit_root = NULL;
 	put_cpu();
-	return ret;
+	return softlimit_root;
 }
 
 static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page *page)
@@ -1268,7 +1276,7 @@ static int __mem_cgroup_try_charge(struc
 {
 	struct mem_cgroup *mem, *mem_over_limit, *mem_over_soft_limit;
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
-	struct res_counter *fail_res, *soft_fail_res = NULL;
+	struct res_counter *fail_res;
 
 	if (unlikely(test_thread_flag(TIF_MEMDIE))) {
 		/* Don't account this! */
@@ -1300,17 +1308,17 @@ static int __mem_cgroup_try_charge(struc
 
 		if (mem_cgroup_is_root(mem))
 			goto done;
-		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res,
-						&soft_fail_res);
+		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res);
+
 		if (likely(!ret)) {
 			if (!do_swap_account)
 				break;
 			ret = res_counter_charge(&mem->memsw, PAGE_SIZE,
-							&fail_res, NULL);
+						&fail_res);
 			if (likely(!ret))
 				break;
 			/* mem+swap counter fails */
-			res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
+			res_counter_uncharge(&mem->res, PAGE_SIZE);
 			flags |= MEM_CGROUP_RECLAIM_NOSWAP;
 			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
 									memsw);
@@ -1348,17 +1356,14 @@ static int __mem_cgroup_try_charge(struc
 			goto nomem;
 		}
 	}
+
 	/*
-	 * Insert just the ancestor, we should trickle down to the correct
-	 * cgroup for reclaim, since the other nodes will be below their
-	 * soft limit
-	 */
-	if (soft_fail_res) {
-		mem_over_soft_limit =
-			mem_cgroup_from_res_counter(soft_fail_res, res);
-		if (mem_cgroup_soft_limit_check(mem_over_soft_limit))
-			mem_cgroup_update_tree(mem_over_soft_limit, page);
-	}
+	 * check hierarchy root's event counter and modify softlimit-tree
+	 * if necessary.
+	 */
+	mem_over_soft_limit = mem_cgroup_soft_limit_check(mem);
+	if (mem_over_soft_limit)
+		mem_cgroup_update_tree(mem_over_soft_limit, page);
 done:
 	return 0;
 nomem:
@@ -1433,10 +1438,9 @@ static void __mem_cgroup_commit_charge(s
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
 		if (!mem_cgroup_is_root(mem)) {
-			res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
+			res_counter_uncharge(&mem->res, PAGE_SIZE);
 			if (do_swap_account)
-				res_counter_uncharge(&mem->memsw, PAGE_SIZE,
-							NULL);
+				res_counter_uncharge(&mem->memsw, PAGE_SIZE);
 		}
 		css_put(&mem->css);
 		return;
@@ -1515,7 +1519,7 @@ static int mem_cgroup_move_account(struc
 		goto out;
 
 	if (!mem_cgroup_is_root(from))
-		res_counter_uncharge(&from->res, PAGE_SIZE, NULL);
+		res_counter_uncharge(&from->res, PAGE_SIZE);
 	mem_cgroup_charge_statistics(from, pc, false);
 
 	page = pc->page;
@@ -1535,7 +1539,7 @@ static int mem_cgroup_move_account(struc
 	}
 
 	if (do_swap_account && !mem_cgroup_is_root(from))
-		res_counter_uncharge(&from->memsw, PAGE_SIZE, NULL);
+		res_counter_uncharge(&from->memsw, PAGE_SIZE);
 	css_put(&from->css);
 
 	css_get(&to->css);
@@ -1606,9 +1610,9 @@ uncharge:
 	css_put(&parent->css);
 	/* uncharge if move fails */
 	if (!mem_cgroup_is_root(parent)) {
-		res_counter_uncharge(&parent->res, PAGE_SIZE, NULL);
+		res_counter_uncharge(&parent->res, PAGE_SIZE);
 		if (do_swap_account)
-			res_counter_uncharge(&parent->memsw, PAGE_SIZE, NULL);
+			res_counter_uncharge(&parent->memsw, PAGE_SIZE);
 	}
 	return ret;
 }
@@ -1799,8 +1803,7 @@ __mem_cgroup_commit_charge_swapin(struct
 			 * calling css_tryget
 			 */
 			if (!mem_cgroup_is_root(memcg))
-				res_counter_uncharge(&memcg->memsw, PAGE_SIZE,
-							NULL);
+				res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
 			mem_cgroup_swap_statistics(memcg, false);
 			mem_cgroup_put(memcg);
 		}
@@ -1827,9 +1830,9 @@ void mem_cgroup_cancel_charge_swapin(str
 	if (!mem)
 		return;
 	if (!mem_cgroup_is_root(mem)) {
-		res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
+		res_counter_uncharge(&mem->res, PAGE_SIZE);
 		if (do_swap_account)
-			res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
+			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
 	}
 	css_put(&mem->css);
 }
@@ -1844,7 +1847,7 @@ __mem_cgroup_uncharge_common(struct page
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
 	struct mem_cgroup_per_zone *mz;
-	bool soft_limit_excess = false;
+	struct mem_cgroup *soft_limit_excess;
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -1884,10 +1887,10 @@ __mem_cgroup_uncharge_common(struct page
 	}
 
 	if (!mem_cgroup_is_root(mem)) {
-		res_counter_uncharge(&mem->res, PAGE_SIZE, &soft_limit_excess);
+		res_counter_uncharge(&mem->res, PAGE_SIZE);
 		if (do_swap_account &&
 				(ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
-			res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
+			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
 	}
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
 		mem_cgroup_swap_statistics(mem, true);
@@ -1904,8 +1907,9 @@ __mem_cgroup_uncharge_common(struct page
 	mz = page_cgroup_zoneinfo(pc);
 	unlock_page_cgroup(pc);
 
-	if (soft_limit_excess && mem_cgroup_soft_limit_check(mem))
-		mem_cgroup_update_tree(mem, page);
+	soft_limit_excess = mem_cgroup_soft_limit_check(mem);
+	if (soft_limit_excess)
+		mem_cgroup_update_tree(soft_limit_excess, page);
 	/* at swapout, this memcg will be accessed to record to swap */
 	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
 		css_put(&mem->css);
@@ -1982,7 +1986,7 @@ void mem_cgroup_uncharge_swap(swp_entry_
 		 * This memcg can be obsolete one. We avoid calling css_tryget
 		 */
 		if (!mem_cgroup_is_root(memcg))
-			res_counter_uncharge(&memcg->memsw, PAGE_SIZE, NULL);
+			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
 		mem_cgroup_swap_statistics(memcg, false);
 		mem_cgroup_put(memcg);
 	}
@@ -2475,9 +2479,13 @@ static int mem_cgroup_hierarchy_write(st
 	 */
 	if ((!parent_mem || !parent_mem->use_hierarchy) &&
 				(val == 1 || val == 0)) {
-		if (list_empty(&cont->children))
+		if (list_empty(&cont->children)) {
 			mem->use_hierarchy = val;
-		else
+			if (val)
+				mem->sub_hierarchy_root = mem;
+			else
+				mem->sub_hierarchy_root = NULL;
+		} else
 			retval = -EBUSY;
 	} else
 		retval = -EINVAL;
@@ -2587,12 +2595,21 @@ static int mem_cgroup_write(struct cgrou
 		/*
 		 * For memsw, soft limits are hard to implement in terms
 		 * of semantics, for now, we support soft limits for
-		 * control without swap
+		 * control without swap. And, softlimit is hard to handle
+		 * under hierarchy. (softliimit-excess tree handling will
+		 * be corrupted.) We limit soflimit feature only for
+		 * hierarchy root.
 		 */
-		if (type == _MEM)
-			ret = res_counter_set_soft_limit(&memcg->res, val);
-		else
+		if (!memcg->sub_hierarchy_root ||
+			memcg->sub_hierarchy_root != memcg)
 			ret = -EINVAL;
+		else {
+			if (type == _MEM)
+				ret = res_counter_set_soft_limit(&memcg->res,
+								val);
+			else
+				ret = -EINVAL;
+		}
 		break;
 	default:
 		ret = -EINVAL; /* should be BUG() ? */
@@ -3118,9 +3135,15 @@ mem_cgroup_create(struct cgroup_subsys *
 		 * mem_cgroup(see mem_cgroup_put).
 		 */
 		mem_cgroup_get(parent);
+		/*
+		 * we don't necessary to grab refcnt of hierarchy root.
+		 *  because it's my ancestor and parent is alive.
+		 */
+		mem->sub_hierarchy_root = parent->sub_hierarchy_root;
 	} else {
 		res_counter_init(&mem->res, NULL);
 		res_counter_init(&mem->memsw, NULL);
+		mem->sub_hierarchy_root = NULL;
 	}
 	mem->last_scanned_child = 0;
 	spin_lock_init(&mem->reclaim_param_lock);
Index: mmotm-2.6.31-Aug27/Documentation/cgroups/memory.txt
===================================================================
--- mmotm-2.6.31-Aug27.orig/Documentation/cgroups/memory.txt
+++ mmotm-2.6.31-Aug27/Documentation/cgroups/memory.txt
@@ -398,6 +398,8 @@ heavily contended for, memory is allocat
 hints/setup. Currently soft limit based reclaim is setup such that
 it gets invoked from balance_pgdat (kswapd).
 
+Soft limit can be set against root of subtree.
+
 7.1 Interface
 
 Soft limits can be setup by using the following commands (in this example we

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
