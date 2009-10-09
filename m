Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3CED46B004D
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 04:03:39 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9983aT4006956
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 9 Oct 2009 17:03:36 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E3D9445DE4F
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 17:03:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BF33045DE51
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 17:03:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 116151DB8038
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 17:03:31 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D07C1DB803C
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 17:03:30 +0900 (JST)
Date: Fri, 9 Oct 2009 17:01:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/2] memcg: coalescing charge by percpu (Oct/9)
Message-Id: <20091009170105.170e025f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091009165826.59c6f6e3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091009165826.59c6f6e3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, h-shimamoto@ct.jp.nec.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This is a patch for coalescing access to res_counter at charging by
percpu caching. At charge, memcg charges 64pages and remember it in
percpu cache. Because it's cache, drain/flush if necessary.

This version uses public percpu area.
 2 benefits for using public percpu area.
 1. Sum of stocked charge in the system is limited to # of cpus
    not to the number of memcg. This shows better synchonization.
 2. drain code for flush/cpuhotplug is very easy (and quick)

The most important point of this patch is that we never touch res_counter
in fast path. The res_counter is system-wide shared counter which is modified
very frequently. We shouldn't touch it as far as we can for avoiding
false sharing.

On x86-64 8cpu server, I tested overheads of memcg at page fault by
running a program which does map/fault/unmap in a loop. Running
a task per a cpu by taskset and see sum of the number of page faults
in 60secs.

[without memcg config]
  40156968  page-faults              #      0.085 M/sec   ( +-   0.046% )
  27.67 cache-miss/faults

[root cgroup]
  36659599  page-faults              #      0.077 M/sec   ( +-   0.247% )
  31.58 cache miss/faults

[in a child cgroup]
  18444157  page-faults              #      0.039 M/sec   ( +-   0.133% )
  69.96 cache miss/faults

[ + coalescing uncharge patch]
  27133719  page-faults              #      0.057 M/sec   ( +-   0.155% )
  47.16 cache miss/faults

[ + coalescing uncharge patch + this patch ]
  34224709  page-faults              #      0.072 M/sec   ( +-   0.173% )
  34.69 cache miss/faults

Changelog (since Oct/2):
  - updated comments
  - replaced get_cpu_var() with __get_cpu_var() if possible.
  - removed mutex for system-wide drain. adds a counter instead of it.
  - removed CONFIG_HOTPLUG_CPU

Changelog (old):
  - rebased onto the latest mmotm
  - moved charge size check before __GFP_WAIT check for avoiding unnecesary
  - added asynchronous flush routine.
  - fixed bugs pointed out by Nishimura-san.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  162 +++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 156 insertions(+), 6 deletions(-)

Index: mmotm-2.6.31-Sep28/mm/memcontrol.c
===================================================================
--- mmotm-2.6.31-Sep28.orig/mm/memcontrol.c
+++ mmotm-2.6.31-Sep28/mm/memcontrol.c
@@ -38,6 +38,7 @@
 #include <linux/vmalloc.h>
 #include <linux/mm_inline.h>
 #include <linux/page_cgroup.h>
+#include <linux/cpu.h>
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -275,6 +276,7 @@ enum charge_type {
 static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
+static void drain_all_stock_async(void);
 
 static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
@@ -1137,6 +1139,8 @@ static int mem_cgroup_hierarchical_recla
 		victim = mem_cgroup_select_victim(root_mem);
 		if (victim == root_mem) {
 			loop++;
+			if (loop >= 1)
+				drain_all_stock_async();
 			if (loop >= 2) {
 				/*
 				 * If we have not been able to reclaim
@@ -1259,6 +1263,139 @@ done:
 }
 
 /*
+ * size of first charge trial. "32" comes from vmscan.c's magic value.
+ * TODO: maybe necessary to use big numbers in big irons.
+ */
+#define CHARGE_SIZE	(32 * PAGE_SIZE)
+struct memcg_stock_pcp {
+	struct mem_cgroup *cached; /* this never be root cgroup */
+	int charge;
+	struct work_struct work;
+};
+static DEFINE_PER_CPU(struct memcg_stock_pcp, memcg_stock);
+static atomic_t memcg_drain_count;
+
+/*
+ * Try to consume stocked charge on this cpu. If success, PAGE_SIZE is consumed
+ * from local stock and true is returned. If the stock is 0 or charges from a
+ * cgroup which is not current target, returns false. This stock will be
+ * refilled.
+ */
+static bool consume_stock(struct mem_cgroup *mem)
+{
+	struct memcg_stock_pcp *stock;
+	bool ret = true;
+
+	stock = &get_cpu_var(memcg_stock);
+	if (mem == stock->cached && stock->charge)
+		stock->charge -= PAGE_SIZE;
+	else /* need to call res_counter_charge */
+		ret = false;
+	put_cpu_var(memcg_stock);
+	return ret;
+}
+
+/*
+ * Retruens stocks cached in percpu to res_counter and reset
+ * cached information.
+ */
+static void drain_stock(struct memcg_stock_pcp *stock)
+{
+	struct mem_cgroup *old = stock->cached;
+
+	if (stock->charge) {
+		res_counter_uncharge(&old->res, stock->charge);
+		if (do_swap_account)
+			res_counter_uncharge(&old->memsw, stock->charge);
+	}
+	stock->cached = NULL;
+	stock->charge = 0;
+}
+
+/*
+ * This must be called under preempt disabled or must be called by
+ * a thread which is pinned to local cpu.
+ */
+static void drain_local_stock(struct work_struct *dummy)
+{
+	struct memcg_stock_pcp *stock = &__get_cpu_var(memcg_stock);
+	drain_stock(stock);
+}
+
+/*
+ * Cache charges(val) which is from res_counter, to local per_cpu area.
+ * This will be consumed by consumt_stock() function, later.
+ */
+
+static void refill_stock(struct mem_cgroup *mem, int val)
+{
+	struct memcg_stock_pcp *stock = &get_cpu_var(memcg_stock);
+
+	if (stock->cached != mem) { /* reset if necessary */
+		drain_stock(stock);
+		stock->cached = mem;
+	}
+	stock->charge += val;
+	put_cpu_var(memcg_stock);
+}
+
+/*
+ * Tries to drain stocked charges in other cpus. This function is asynchronous
+ * and just put a work per cpu for draining localy on each cpu. Caller can
+ * expects some charges will be back to res_counter later but cannot wait for
+ * it.
+ */
+
+static void drain_all_stock_async(void)
+{
+	int cpu;
+	/* This function is for scheduling "drain" in asynchronous way.
+	 * The result of "drain" is not directly handled by callers. Then,
+	 * if someone is calling drain, we don't have to call drain more.
+	 * Anyway, work_pending() will catch if there is a race. We just do
+	 * loose check here.
+	 */
+	if (atomic_read(&memcg_drain_count))
+		return;
+	/* Notify other cpus that system-wide "drain" is running */
+	atomic_inc(&memcg_drain_count);
+	get_online_cpus();
+	for_each_online_cpu(cpu) {
+		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
+		if (work_pending(&stock->work))
+			continue;
+		INIT_WORK(&stock->work, drain_local_stock);
+		schedule_work_on(cpu, &stock->work);
+	}
+ 	put_online_cpus();
+	atomic_dec(&memcg_drain_count);
+	/* We don't wait for flush_work */
+}
+
+/* This is a synchronous drain interface. */
+static void drain_all_stock_sync(void)
+{
+	/* called when force_empty is called */
+	atomic_inc(&memcg_drain_count);
+	schedule_on_each_cpu(drain_local_stock);
+	atomic_dec(&memcg_drain_count);
+}
+
+static int __cpuinit memcg_stock_cpu_callback(struct notifier_block *nb,
+					unsigned long action,
+					void *hcpu)
+{
+	int cpu = (unsigned long)hcpu;
+	struct memcg_stock_pcp *stock;
+
+	if (action != CPU_DEAD)
+		return NOTIFY_OK;
+	stock = &per_cpu(memcg_stock, cpu);
+	drain_stock(stock);
+	return NOTIFY_OK;
+}
+
+/*
  * Unlike exported interface, "oom" parameter is added. if oom==true,
  * oom-killer can be invoked.
  */
@@ -1269,6 +1406,7 @@ static int __mem_cgroup_try_charge(struc
 	struct mem_cgroup *mem, *mem_over_limit;
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct res_counter *fail_res;
+	int csize = CHARGE_SIZE;
 
 	if (unlikely(test_thread_flag(TIF_MEMDIE))) {
 		/* Don't account this! */
@@ -1293,23 +1431,25 @@ static int __mem_cgroup_try_charge(struc
 		return 0;
 
 	VM_BUG_ON(css_is_removed(&mem->css));
+	if (mem_cgroup_is_root(mem))
+		goto done;
 
 	while (1) {
 		int ret = 0;
 		unsigned long flags = 0;
 
-		if (mem_cgroup_is_root(mem))
-			goto done;
-		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res);
+		if (consume_stock(mem))
+			goto charged;
+
+		ret = res_counter_charge(&mem->res, csize, &fail_res);
 		if (likely(!ret)) {
 			if (!do_swap_account)
 				break;
-			ret = res_counter_charge(&mem->memsw, PAGE_SIZE,
-							&fail_res);
+			ret = res_counter_charge(&mem->memsw, csize, &fail_res);
 			if (likely(!ret))
 				break;
 			/* mem+swap counter fails */
-			res_counter_uncharge(&mem->res, PAGE_SIZE);
+			res_counter_uncharge(&mem->res, csize);
 			flags |= MEM_CGROUP_RECLAIM_NOSWAP;
 			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
 									memsw);
@@ -1318,6 +1458,11 @@ static int __mem_cgroup_try_charge(struc
 			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
 									res);
 
+		/* reduce request size and retry */
+		if (csize > PAGE_SIZE) {
+			csize = PAGE_SIZE;
+			continue;
+		}
 		if (!(gfp_mask & __GFP_WAIT))
 			goto nomem;
 
@@ -1347,6 +1492,9 @@ static int __mem_cgroup_try_charge(struc
 			goto nomem;
 		}
 	}
+	if (csize > PAGE_SIZE)
+		refill_stock(mem, csize - PAGE_SIZE);
+charged:
 	/*
 	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
 	 * if they exceeds softlimit.
@@ -2468,6 +2616,7 @@ move_account:
 			goto out;
 		/* This is for making all *used* pages to be on LRU. */
 		lru_add_drain_all();
+		drain_all_stock_sync();
 		ret = 0;
 		for_each_node_state(node, N_HIGH_MEMORY) {
 			for (zid = 0; !ret && zid < MAX_NR_ZONES; zid++) {
@@ -3186,6 +3335,7 @@ mem_cgroup_create(struct cgroup_subsys *
 		root_mem_cgroup = mem;
 		if (mem_cgroup_soft_limit_tree_init())
 			goto free_out;
+		hotcpu_notifier(memcg_stock_cpu_callback, 0);
 
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
