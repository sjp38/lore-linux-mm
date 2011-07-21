Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8C26B007E
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 05:46:39 -0400 (EDT)
Message-Id: <16dca2225fc14783a16d00c43f6680b67418da65.1311241300.git.mhocko@suse.cz>
In-Reply-To: <cover.1311241300.git.mhocko@suse.cz>
References: <cover.1311241300.git.mhocko@suse.cz>
From: Michal Hocko <mhocko@suse.cz>
Date: Thu, 21 Jul 2011 09:50:00 +0200
Subject: [PATCH 2/4] memcg: unify sync and async per-cpu charge cache
 draining
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

Currently we have two ways how to drain per-CPU caches for charges.
drain_all_stock_sync will synchronously drain all caches while
drain_all_stock_async will asynchronously drain only those that refer to
a given memory cgroup or its subtree in hierarchy.
Targeted async draining has been introduced by 26fe6168 (memcg: fix
percpu cached charge draining frequency) to reduce the cpu workers
number.

sync draining is currently triggered only from mem_cgroup_force_empty
which is triggered only by userspace (mem_cgroup_force_empty_write) or
when a cgroup is removed (mem_cgroup_pre_destroy). Although these are
not usually frequent operations it still makes some sense to do targeted
draining as well, especially if the box has many CPUs.

This patch unifies both methods to use the single code (drain_all_stock)
which relies on the original async implementation and just adds
flush_work to wait on all caches that are still under work for the sync
mode.
We are using FLUSHING_CACHED_CHARGE bit check to prevent from waiting on
a work that we haven't triggered.
Please note that both sync and async functions are currently protected
by percpu_charge_mutex so we cannot race with other drainers.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   48 ++++++++++++++++++++++++++++++++++--------------
 1 files changed, 34 insertions(+), 14 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 786bffb..8180cd9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2133,19 +2133,14 @@ static void refill_stock(struct mem_cgroup *mem, unsigned int nr_pages)
 }
 
 /*
- * Tries to drain stocked charges in other cpus. This function is asynchronous
- * and just put a work per cpu for draining localy on each cpu. Caller can
- * expects some charges will be back to res_counter later but cannot wait for
- * it.
+ * Drains all per-CPU charge caches for given root_mem resp. subtree
+ * of the hierarchy under it. sync flag says whether we should block
+ * until the work is done.
  */
-static void drain_all_stock_async(struct mem_cgroup *root_mem)
+static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
 {
 	int cpu;
-	/*
-	 * If someone calls draining, avoid adding more kworker runs.
-	 */
-	if (!mutex_trylock(&percpu_charge_mutex))
-		return;
+
 	/* Notify other cpus that system-wide "drain" is running */
 	get_online_cpus();
 	for_each_online_cpu(cpu) {
@@ -2165,17 +2160,42 @@ static void drain_all_stock_async(struct mem_cgroup *root_mem)
 		if (!test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
 			schedule_work_on(cpu, &stock->work);
 	}
+
+	if (!sync)
+		goto out;
+
+	for_each_online_cpu(cpu) {
+		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
+		if (test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
+			flush_work(&stock->work);
+	}
+out:
  	put_online_cpus();
+}
+
+/*
+ * Tries to drain stocked charges in other cpus. This function is asynchronous
+ * and just put a work per cpu for draining localy on each cpu. Caller can
+ * expects some charges will be back to res_counter later but cannot wait for
+ * it.
+ */
+static void drain_all_stock_async(struct mem_cgroup *root_mem)
+{
+	/*
+	 * If someone calls draining, avoid adding more kworker runs.
+	 */
+	if (!mutex_trylock(&percpu_charge_mutex))
+		return;
+	drain_all_stock(root_mem, false);
 	mutex_unlock(&percpu_charge_mutex);
-	/* We don't wait for flush_work */
 }
 
 /* This is a synchronous drain interface. */
-static void drain_all_stock_sync(void)
+static void drain_all_stock_sync(struct mem_cgroup *root_mem)
 {
 	/* called when force_empty is called */
 	mutex_lock(&percpu_charge_mutex);
-	schedule_on_each_cpu(drain_local_stock);
+	drain_all_stock(root_mem, true);
 	mutex_unlock(&percpu_charge_mutex);
 }
 
@@ -3824,7 +3844,7 @@ move_account:
 			goto out;
 		/* This is for making all *used* pages to be on LRU. */
 		lru_add_drain_all();
-		drain_all_stock_sync();
+		drain_all_stock_sync(mem);
 		ret = 0;
 		mem_cgroup_start_move(mem);
 		for_each_node_state(node, N_HIGH_MEMORY) {
-- 
1.7.5.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
