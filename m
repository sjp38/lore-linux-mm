Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 913E26B00AB
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 11:42:23 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id lx4so3331244iec.12
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 08:42:23 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id i7si2403098pat.139.2014.09.11.08.42.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Sep 2014 08:42:22 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 1/2] memcg: use percpu_counter for statistics
Date: Thu, 11 Sep 2014 19:41:49 +0400
Message-ID: <395271ceb801fdb6b97160bbdd38fa2214b29983.1410447097.git.vdavydov@parallels.com>
In-Reply-To: <cover.1410447097.git.vdavydov@parallels.com>
References: <cover.1410447097.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@parallels.com>, Konstantin Khorenko <khorenko@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

In the next patch I need a quick way to get a value of
MEM_CGROUP_STAT_RSS. The current procedure (mem_cgroup_read_stat) is
slow (iterates over all cpus) and may sleep (uses get/put_online_cpus),
so it's a no-go.

This patch converts memory cgroup statistics to use percpu_counter so
that percpu_counter_read will do the trick.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |  217 ++++++++++++++++++-------------------------------------
 1 file changed, 69 insertions(+), 148 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 085dc6d2f876..7e8d65e0608a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -136,9 +136,7 @@ enum mem_cgroup_events_target {
 #define SOFTLIMIT_EVENTS_TARGET 1024
 #define NUMAINFO_EVENTS_TARGET	1024
 
-struct mem_cgroup_stat_cpu {
-	long count[MEM_CGROUP_STAT_NSTATS];
-	unsigned long events[MEM_CGROUP_EVENTS_NSTATS];
+struct mem_cgroup_ratelimit_state {
 	unsigned long nr_page_events;
 	unsigned long targets[MEM_CGROUP_NTARGETS];
 };
@@ -341,16 +339,10 @@ struct mem_cgroup {
 	atomic_t	moving_account;
 	/* taken only while moving_account > 0 */
 	spinlock_t	move_lock;
-	/*
-	 * percpu counter.
-	 */
-	struct mem_cgroup_stat_cpu __percpu *stat;
-	/*
-	 * used when a cpu is offlined or other synchronizations
-	 * See mem_cgroup_read_stat().
-	 */
-	struct mem_cgroup_stat_cpu nocpu_base;
-	spinlock_t pcp_counter_lock;
+
+	struct percpu_counter stat[MEM_CGROUP_STAT_NSTATS];
+	struct percpu_counter events[MEM_CGROUP_EVENTS_NSTATS];
+	struct mem_cgroup_ratelimit_state __percpu *ratelimit;
 
 	atomic_t	dead_count;
 #if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
@@ -849,59 +841,16 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
 	return mz;
 }
 
-/*
- * Implementation Note: reading percpu statistics for memcg.
- *
- * Both of vmstat[] and percpu_counter has threshold and do periodic
- * synchronization to implement "quick" read. There are trade-off between
- * reading cost and precision of value. Then, we may have a chance to implement
- * a periodic synchronizion of counter in memcg's counter.
- *
- * But this _read() function is used for user interface now. The user accounts
- * memory usage by memory cgroup and he _always_ requires exact value because
- * he accounts memory. Even if we provide quick-and-fuzzy read, we always
- * have to visit all online cpus and make sum. So, for now, unnecessary
- * synchronization is not implemented. (just implemented for cpu hotplug)
- *
- * If there are kernel internal actions which can make use of some not-exact
- * value, and reading all cpu value can be performance bottleneck in some
- * common workload, threashold and synchonization as vmstat[] should be
- * implemented.
- */
 static long mem_cgroup_read_stat(struct mem_cgroup *memcg,
 				 enum mem_cgroup_stat_index idx)
 {
-	long val = 0;
-	int cpu;
-
-	get_online_cpus();
-	for_each_online_cpu(cpu)
-		val += per_cpu(memcg->stat->count[idx], cpu);
-#ifdef CONFIG_HOTPLUG_CPU
-	spin_lock(&memcg->pcp_counter_lock);
-	val += memcg->nocpu_base.count[idx];
-	spin_unlock(&memcg->pcp_counter_lock);
-#endif
-	put_online_cpus();
-	return val;
+	return percpu_counter_read(&memcg->stat[idx]);
 }
 
 static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
 					    enum mem_cgroup_events_index idx)
 {
-	unsigned long val = 0;
-	int cpu;
-
-	get_online_cpus();
-	for_each_online_cpu(cpu)
-		val += per_cpu(memcg->stat->events[idx], cpu);
-#ifdef CONFIG_HOTPLUG_CPU
-	spin_lock(&memcg->pcp_counter_lock);
-	val += memcg->nocpu_base.events[idx];
-	spin_unlock(&memcg->pcp_counter_lock);
-#endif
-	put_online_cpus();
-	return val;
+	return percpu_counter_read(&memcg->events[idx]);
 }
 
 static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
@@ -913,25 +862,21 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 	 * counted as CACHE even if it's on ANON LRU.
 	 */
 	if (PageAnon(page))
-		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_RSS],
+		percpu_counter_add(&memcg->stat[MEM_CGROUP_STAT_RSS],
 				nr_pages);
 	else
-		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_CACHE],
+		percpu_counter_add(&memcg->stat[MEM_CGROUP_STAT_CACHE],
 				nr_pages);
 
 	if (PageTransHuge(page))
-		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_RSS_HUGE],
+		percpu_counter_add(&memcg->stat[MEM_CGROUP_STAT_RSS_HUGE],
 				nr_pages);
 
 	/* pagein of a big page is an event. So, ignore page size */
 	if (nr_pages > 0)
-		__this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGIN]);
-	else {
-		__this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGOUT]);
-		nr_pages = -nr_pages; /* for event */
-	}
-
-	__this_cpu_add(memcg->stat->nr_page_events, nr_pages);
+		percpu_counter_inc(&memcg->events[MEM_CGROUP_EVENTS_PGPGIN]);
+	else
+		percpu_counter_inc(&memcg->events[MEM_CGROUP_EVENTS_PGPGOUT]);
 }
 
 unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
@@ -981,8 +926,8 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
 {
 	unsigned long val, next;
 
-	val = __this_cpu_read(memcg->stat->nr_page_events);
-	next = __this_cpu_read(memcg->stat->targets[target]);
+	val = __this_cpu_read(memcg->ratelimit->nr_page_events);
+	next = __this_cpu_read(memcg->ratelimit->targets[target]);
 	/* from time_after() in jiffies.h */
 	if ((long)next - (long)val < 0) {
 		switch (target) {
@@ -998,7 +943,7 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
 		default:
 			break;
 		}
-		__this_cpu_write(memcg->stat->targets[target], next);
+		__this_cpu_write(memcg->ratelimit->targets[target], next);
 		return true;
 	}
 	return false;
@@ -1006,10 +951,15 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
 
 /*
  * Check events in order.
- *
  */
-static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
+static void memcg_check_events(struct mem_cgroup *memcg, struct page *page,
+			       unsigned long nr_pages)
 {
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__this_cpu_add(memcg->ratelimit->nr_page_events, nr_pages);
+
 	/* threshold event is triggered in finer grain than soft limit */
 	if (unlikely(mem_cgroup_event_ratelimit(memcg,
 						MEM_CGROUP_TARGET_THRESH))) {
@@ -1030,6 +980,7 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
 			atomic_inc(&memcg->numainfo_events);
 #endif
 	}
+	local_irq_restore(flags);
 }
 
 struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
@@ -1294,10 +1245,10 @@ void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 
 	switch (idx) {
 	case PGFAULT:
-		this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGFAULT]);
+		percpu_counter_inc(&memcg->events[MEM_CGROUP_EVENTS_PGFAULT]);
 		break;
 	case PGMAJFAULT:
-		this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGMAJFAULT]);
+		percpu_counter_inc(&memcg->events[MEM_CGROUP_EVENTS_PGMAJFAULT]);
 		break;
 	default:
 		BUG();
@@ -2306,7 +2257,7 @@ void mem_cgroup_update_page_stat(struct page *page,
 	if (unlikely(!memcg || !PageCgroupUsed(pc)))
 		return;
 
-	this_cpu_add(memcg->stat->count[idx], val);
+	percpu_counter_add(&memcg->stat[idx], val);
 }
 
 /*
@@ -2476,37 +2427,12 @@ static void drain_all_stock_sync(struct mem_cgroup *root_memcg)
 	mutex_unlock(&percpu_charge_mutex);
 }
 
-/*
- * This function drains percpu counter value from DEAD cpu and
- * move it to local cpu. Note that this function can be preempted.
- */
-static void mem_cgroup_drain_pcp_counter(struct mem_cgroup *memcg, int cpu)
-{
-	int i;
-
-	spin_lock(&memcg->pcp_counter_lock);
-	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
-		long x = per_cpu(memcg->stat->count[i], cpu);
-
-		per_cpu(memcg->stat->count[i], cpu) = 0;
-		memcg->nocpu_base.count[i] += x;
-	}
-	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++) {
-		unsigned long x = per_cpu(memcg->stat->events[i], cpu);
-
-		per_cpu(memcg->stat->events[i], cpu) = 0;
-		memcg->nocpu_base.events[i] += x;
-	}
-	spin_unlock(&memcg->pcp_counter_lock);
-}
-
 static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
 					unsigned long action,
 					void *hcpu)
 {
 	int cpu = (unsigned long)hcpu;
 	struct memcg_stock_pcp *stock;
-	struct mem_cgroup *iter;
 
 	if (action == CPU_ONLINE)
 		return NOTIFY_OK;
@@ -2514,9 +2440,6 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
 	if (action != CPU_DEAD && action != CPU_DEAD_FROZEN)
 		return NOTIFY_OK;
 
-	for_each_mem_cgroup(iter)
-		mem_cgroup_drain_pcp_counter(iter, cpu);
-
 	stock = &per_cpu(memcg_stock, cpu);
 	drain_stock(stock);
 	return NOTIFY_OK;
@@ -3419,8 +3342,8 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 		pc->mem_cgroup = memcg;
 		pc->flags = head_pc->flags;
 	}
-	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS_HUGE],
-		       HPAGE_PMD_NR);
+	percpu_counter_sub(&memcg->stat[MEM_CGROUP_STAT_RSS_HUGE],
+			   HPAGE_PMD_NR);
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
@@ -3475,17 +3398,17 @@ static int mem_cgroup_move_account(struct page *page,
 	move_lock_mem_cgroup(from, &flags);
 
 	if (!PageAnon(page) && page_mapped(page)) {
-		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
-			       nr_pages);
-		__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
-			       nr_pages);
+		percpu_counter_sub(&from->stat[MEM_CGROUP_STAT_FILE_MAPPED],
+				   nr_pages);
+		percpu_counter_add(&to->stat[MEM_CGROUP_STAT_FILE_MAPPED],
+				   nr_pages);
 	}
 
 	if (PageWriteback(page)) {
-		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_WRITEBACK],
-			       nr_pages);
-		__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_WRITEBACK],
-			       nr_pages);
+		percpu_counter_sub(&from->stat[MEM_CGROUP_STAT_WRITEBACK],
+				   nr_pages);
+		percpu_counter_add(&to->stat[MEM_CGROUP_STAT_WRITEBACK],
+				   nr_pages);
 	}
 
 	/*
@@ -3499,12 +3422,10 @@ static int mem_cgroup_move_account(struct page *page,
 	move_unlock_mem_cgroup(from, &flags);
 	ret = 0;
 
-	local_irq_disable();
 	mem_cgroup_charge_statistics(to, page, nr_pages);
-	memcg_check_events(to, page);
+	memcg_check_events(to, page, nr_pages);
 	mem_cgroup_charge_statistics(from, page, -nr_pages);
-	memcg_check_events(from, page);
-	local_irq_enable();
+	memcg_check_events(from, page, nr_pages);
 out_unlock:
 	unlock_page(page);
 out:
@@ -3582,7 +3503,7 @@ static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
 					 bool charge)
 {
 	int val = (charge) ? 1 : -1;
-	this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SWAP], val);
+	percpu_counter_add(&memcg->stat[MEM_CGROUP_STAT_SWAP], val);
 }
 
 /**
@@ -5413,25 +5334,11 @@ static void free_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 
 static struct mem_cgroup *mem_cgroup_alloc(void)
 {
-	struct mem_cgroup *memcg;
 	size_t size;
 
 	size = sizeof(struct mem_cgroup);
 	size += nr_node_ids * sizeof(struct mem_cgroup_per_node *);
-
-	memcg = kzalloc(size, GFP_KERNEL);
-	if (!memcg)
-		return NULL;
-
-	memcg->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
-	if (!memcg->stat)
-		goto out_free;
-	spin_lock_init(&memcg->pcp_counter_lock);
-	return memcg;
-
-out_free:
-	kfree(memcg);
-	return NULL;
+	return kzalloc(size, GFP_KERNEL);
 }
 
 /*
@@ -5448,13 +5355,20 @@ out_free:
 static void __mem_cgroup_free(struct mem_cgroup *memcg)
 {
 	int node;
+	int i;
 
 	mem_cgroup_remove_from_trees(memcg);
 
 	for_each_node(node)
 		free_mem_cgroup_per_zone_info(memcg, node);
 
-	free_percpu(memcg->stat);
+	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++)
+		percpu_counter_destroy(&memcg->stat[i]);
+
+	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++)
+		percpu_counter_destroy(&memcg->events[i]);
+
+	free_percpu(memcg->ratelimit);
 
 	/*
 	 * We need to make sure that (at least for now), the jump label
@@ -5511,11 +5425,24 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	struct mem_cgroup *memcg;
 	long error = -ENOMEM;
 	int node;
+	int i;
 
 	memcg = mem_cgroup_alloc();
 	if (!memcg)
 		return ERR_PTR(error);
 
+	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++)
+		if (percpu_counter_init(&memcg->stat[i], 0, GFP_KERNEL))
+			goto free_out;
+
+	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++)
+		if (percpu_counter_init(&memcg->events[i], 0, GFP_KERNEL))
+			goto free_out;
+
+	memcg->ratelimit = alloc_percpu(struct mem_cgroup_ratelimit_state);
+	if (!memcg->ratelimit)
+		goto free_out;
+
 	for_each_node(node)
 		if (alloc_mem_cgroup_per_zone_info(memcg, node))
 			goto free_out;
@@ -6507,10 +6434,8 @@ void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 	}
 
-	local_irq_disable();
 	mem_cgroup_charge_statistics(memcg, page, nr_pages);
-	memcg_check_events(memcg, page);
-	local_irq_enable();
+	memcg_check_events(memcg, page, nr_pages);
 
 	if (do_swap_account && PageSwapCache(page)) {
 		swp_entry_t entry = { .val = page_private(page) };
@@ -6557,8 +6482,6 @@ static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
 			   unsigned long nr_anon, unsigned long nr_file,
 			   unsigned long nr_huge, struct page *dummy_page)
 {
-	unsigned long flags;
-
 	if (!mem_cgroup_is_root(memcg)) {
 		if (nr_mem)
 			res_counter_uncharge(&memcg->res,
@@ -6569,14 +6492,12 @@ static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
 		memcg_oom_recover(memcg);
 	}
 
-	local_irq_save(flags);
-	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS], nr_anon);
-	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_CACHE], nr_file);
-	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS_HUGE], nr_huge);
-	__this_cpu_add(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGOUT], pgpgout);
-	__this_cpu_add(memcg->stat->nr_page_events, nr_anon + nr_file);
-	memcg_check_events(memcg, dummy_page);
-	local_irq_restore(flags);
+	percpu_counter_sub(&memcg->stat[MEM_CGROUP_STAT_RSS], nr_anon);
+	percpu_counter_sub(&memcg->stat[MEM_CGROUP_STAT_CACHE], nr_file);
+	percpu_counter_sub(&memcg->stat[MEM_CGROUP_STAT_RSS_HUGE], nr_huge);
+	percpu_counter_add(&memcg->events[MEM_CGROUP_EVENTS_PGPGOUT], pgpgout);
+
+	memcg_check_events(memcg, dummy_page, nr_anon + nr_file);
 }
 
 static void uncharge_list(struct list_head *page_list)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
