Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5EEBC6B0289
	for <linux-mm@kvack.org>; Fri, 22 May 2015 18:23:43 -0400 (EDT)
Received: by qkgv12 with SMTP id v12so23396600qkg.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:23:43 -0700 (PDT)
Received: from mail-qk0-x234.google.com (mail-qk0-x234.google.com. [2607:f8b0:400d:c09::234])
        by mx.google.com with ESMTPS id k20si3159004qhk.66.2015.05.22.15.23.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 15:23:42 -0700 (PDT)
Received: by qkgx75 with SMTP id x75so23381023qkg.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:23:42 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 01/19] memcg: make mem_cgroup_read_{stat|event}() iterate possible cpus instead of online
Date: Fri, 22 May 2015 18:23:18 -0400
Message-Id: <1432333416-6221-2-git-send-email-tj@kernel.org>
In-Reply-To: <1432333416-6221-1-git-send-email-tj@kernel.org>
References: <1432333416-6221-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

cpu_possible_mask represents the CPUs which are actually possible
during that boot instance.  For systems which don't support CPU
hotplug, this will match cpu_online_mask exactly in most cases.  Even
for systems which support CPU hotplug, the number of possible CPU
slots is highly unlikely to diverge greatly from the number of online
CPUs.  The only cases where the difference between possible and online
caused problems were when the boot code failed to initialize the
possible mask and left it fully set at NR_CPUS - 1.

As such, most per-cpu constructs allocate for all possible CPUs and
often iterate over the possibles, which also has the benefit of
avoiding the blocking CPU hotplug synchronization.

memcg open codes per-cpu stat counting for mem_cgroup_read_stat() and
mem_cgroup_read_events(), which iterates over online CPUs and handles
CPU hotplug operations explicitly.  This complexity doesn't actually
buy anything.  Switch to iterating over the possibles and drop the
explicit CPU hotplug handling.

Eventually, we want to convert memcg to use percpu_counter instead of
its own custom implementation which also benefits from quick access
w/o summing for cases where larger error margin is acceptable.

This will allow mem_cgroup_read_stat() to be called from non-sleepable
contexts which will be used by cgroup writeback.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 51 ++-------------------------------------------------
 1 file changed, 2 insertions(+), 49 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6732c2c..d7d270a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -324,11 +324,6 @@ struct mem_cgroup {
 	 * percpu counter.
 	 */
 	struct mem_cgroup_stat_cpu __percpu *stat;
-	/*
-	 * used when a cpu is offlined or other synchronizations
-	 * See mem_cgroup_read_stat().
-	 */
-	struct mem_cgroup_stat_cpu nocpu_base;
 	spinlock_t pcp_counter_lock;
 
 #if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
@@ -815,15 +810,8 @@ static long mem_cgroup_read_stat(struct mem_cgroup *memcg,
 	long val = 0;
 	int cpu;
 
-	get_online_cpus();
-	for_each_online_cpu(cpu)
+	for_each_possible_cpu(cpu)
 		val += per_cpu(memcg->stat->count[idx], cpu);
-#ifdef CONFIG_HOTPLUG_CPU
-	spin_lock(&memcg->pcp_counter_lock);
-	val += memcg->nocpu_base.count[idx];
-	spin_unlock(&memcg->pcp_counter_lock);
-#endif
-	put_online_cpus();
 	return val;
 }
 
@@ -833,15 +821,8 @@ static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
 	unsigned long val = 0;
 	int cpu;
 
-	get_online_cpus();
-	for_each_online_cpu(cpu)
+	for_each_possible_cpu(cpu)
 		val += per_cpu(memcg->stat->events[idx], cpu);
-#ifdef CONFIG_HOTPLUG_CPU
-	spin_lock(&memcg->pcp_counter_lock);
-	val += memcg->nocpu_base.events[idx];
-	spin_unlock(&memcg->pcp_counter_lock);
-#endif
-	put_online_cpus();
 	return val;
 }
 
@@ -2191,37 +2172,12 @@ static void drain_all_stock(struct mem_cgroup *root_memcg)
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
@@ -2229,9 +2185,6 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
 	if (action != CPU_DEAD && action != CPU_DEAD_FROZEN)
 		return NOTIFY_OK;
 
-	for_each_mem_cgroup(iter)
-		mem_cgroup_drain_pcp_counter(iter, cpu);
-
 	stock = &per_cpu(memcg_stock, cpu);
 	drain_stock(stock);
 	return NOTIFY_OK;
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
