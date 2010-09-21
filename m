Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 67EF36B004A
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 05:40:41 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8L9edZ9004882
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Sep 2010 18:40:39 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 03FD845DE51
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 18:40:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AFF7F45DE55
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 18:40:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 81C4A1DB8047
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 18:40:38 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 015341DB8041
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 18:40:35 +0900 (JST)
Date: Tue, 21 Sep 2010 18:35:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v2 2/3][-mm] memcg: cpu hotplug aware percpu count updates
Message-Id: <20100921183527.16d55570.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100921183127.1c4c2bc1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100921183127.1c4c2bc1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, memcgroup's per cpu coutner uses for_each_possible_cpu() to
get the value. It's better to use for_each_online_cpu() and
a cpu hotplug handler.

This patch only handles statistics counter. MEM_CGROUP_ON_MOVE
will be handled in another patch.

Changelog: 2010/09/21
 - add and use for_each_mem_cgroup_all()
 - added "core" value and spin_lock.
 - added Implementation Note for future updates.
 - divided out "MEM_CGROUP_ON_MOVE" handling.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   80 +++++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 74 insertions(+), 6 deletions(-)

Index: mmotm-0915/mm/memcontrol.c
===================================================================
--- mmotm-0915.orig/mm/memcontrol.c
+++ mmotm-0915/mm/memcontrol.c
@@ -89,7 +89,9 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
 	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
 	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
-	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
+	MEM_CGROUP_STAT_DATA, /* end of data requires synchronization */
+	/* incremented at every  pagein/pageout */
+	MEM_CGROUP_EVENTS = MEM_CGROUP_STAT_DATA,
 	MEM_CGROUP_ON_MOVE,	/* someone is moving account between groups */
 
 	MEM_CGROUP_STAT_NSTATS,
@@ -255,6 +257,12 @@ struct mem_cgroup {
 	 * percpu counter.
 	 */
 	struct mem_cgroup_stat_cpu *stat;
+	/*
+	 * used when a cpu is offlined or other synchronizations
+	 * See mem_cgroup_read_stat().
+	 */
+	struct mem_cgroup_stat_cpu nocpu_base;
+	spinlock_t pcp_counter_lock;
 };
 
 /* Stuffs for move charges at task migration. */
@@ -531,14 +539,40 @@ mem_cgroup_largest_soft_limit_node(struc
 	return mz;
 }
 
+/*
+ * Implementation Note: reading percpu statistics for memcg.
+ *
+ * Both of vmstat[] and percpu_counter has threshold and do periodic
+ * synchronization to implement "quick" read. There are trade-off between
+ * reading cost and precision of value. Then, we may have a chance to implement
+ * a periodic synchronizion of counter in memcg's counter.
+ *
+ * But this _read() function is used for user interface now. The user accounts
+ * memory usage by memory cgroup and he _always_ requires exact value because
+ * he accounts memory. Even if we provide quick-and-fuzzy read, we always
+ * have to visit all online cpus and make sum. So, for now, unnecessary
+ * synchronization is not implemented. (just implemented for cpu hotplug)
+ *
+ * If there are kernel internal actions which can make use of some not-exact
+ * value, and reading all cpu value can be performance bottleneck in some
+ * common workload, threashold and synchonization as vmstat[] should be
+ * implemented.
+ */
 static s64 mem_cgroup_read_stat(struct mem_cgroup *mem,
 		enum mem_cgroup_stat_index idx)
 {
 	int cpu;
 	s64 val = 0;
 
-	for_each_possible_cpu(cpu)
+	get_online_cpus();
+	for_each_online_cpu(cpu)
 		val += per_cpu(mem->stat->count[idx], cpu);
+#ifdef CONFIG_HOTPLUG_CPU
+	spin_lock(&mem->pcp_counter_lock);
+	val += mem->nocpu_base.count[idx];
+	spin_unlock(&mem->pcp_counter_lock);
+#endif
+	put_online_cpus();
 	return val;
 }
 
@@ -665,6 +699,9 @@ static struct mem_cgroup *mem_cgroup_sta
 {
 	if (mem && css_tryget(&mem->css))
 		return mem;
+	if (!mem)
+		return root_mem_cgroup; /*css_put/get against root is ignored*/
+
 	return NULL;
 }
 
@@ -680,9 +717,13 @@ static struct mem_cgroup *mem_cgroup_get
 	hierarchy_used = iter->use_hierarchy;
 
 	css_put(&iter->css);
-	if (!cond || !hierarchy_used)
+	/* If no ROOT, walk all, ignore hierarchy */
+	if (!cond || (root && !hierarchy_used))
 		return NULL;
 
+	if (!root)
+		root = root_mem_cgroup;
+
 	do {
 		iter = NULL;
 		rcu_read_lock();
@@ -711,6 +752,9 @@ static struct mem_cgroup *mem_cgroup_get
 #define for_each_mem_cgroup_tree(iter, root) \
 	for_each_mem_cgroup_tree_cond(iter, root, true)
 
+#define for_each_mem_cgroup_all(iter) \
+	for_each_mem_cgroup_tree_cond(iter, NULL, true)
+
 
 static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
 {
@@ -1676,15 +1720,38 @@ static void drain_all_stock_sync(void)
 	atomic_dec(&memcg_drain_count);
 }
 
-static int __cpuinit memcg_stock_cpu_callback(struct notifier_block *nb,
+/*
+ * This function drains percpu counter value from DEAD cpu and
+ * move it to local cpu. Note that this function can be preempted.
+ */
+static void mem_cgroup_drain_pcp_counter(struct mem_cgroup *mem, int cpu)
+{
+	int i;
+
+	spin_lock(&mem->pcp_counter_lock);
+	for (i = 0; i < MEM_CGROUP_STAT_DATA; i++) {
+		s64 x = per_cpu(mem->stat->count[i], cpu);
+
+		per_cpu(mem->stat->count[i], cpu) = 0;
+		mem->nocpu_base.count[i] += x;
+	}
+	spin_unlock(&mem->pcp_counter_lock);
+}
+
+static int __cpuinit memcg_cpu_hotplug_callback(struct notifier_block *nb,
 					unsigned long action,
 					void *hcpu)
 {
 	int cpu = (unsigned long)hcpu;
 	struct memcg_stock_pcp *stock;
+	struct mem_cgroup *iter;
 
-	if (action != CPU_DEAD)
+	if ((action != CPU_DEAD) || action != CPU_DEAD_FROZEN)
 		return NOTIFY_OK;
+
+	for_each_mem_cgroup_all(iter)
+		mem_cgroup_drain_pcp_counter(iter, cpu);
+
 	stock = &per_cpu(memcg_stock, cpu);
 	drain_stock(stock);
 	return NOTIFY_OK;
@@ -4094,6 +4161,7 @@ static struct mem_cgroup *mem_cgroup_all
 			vfree(mem);
 		mem = NULL;
 	}
+	spin_lock_init(&mem->pcp_counter_lock);
 	return mem;
 }
 
@@ -4220,7 +4288,7 @@ mem_cgroup_create(struct cgroup_subsys *
 						&per_cpu(memcg_stock, cpu);
 			INIT_WORK(&stock->work, drain_local_stock);
 		}
-		hotcpu_notifier(memcg_stock_cpu_callback, 0);
+		hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
 		mem->use_hierarchy = parent->use_hierarchy;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
