Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4C34D6B0038
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 13:11:25 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id rp16so4242029pbb.3
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 10:11:24 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id bm8si2560763pad.254.2014.04.10.10.11.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 10:11:24 -0700 (PDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so4117617pdi.16
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 10:11:23 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH] mm/memcontrol.c: make mem_cgroup_read_stat() read all interested stat item in one go
Date: Fri, 11 Apr 2014 01:11:08 +0800
Message-Id: <1397149868-30401-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, nasa4836@gmail.com

Currently, mem_cgroup_read_stat() is used for user interface. The
user accounts memory usage by memory cgroup and he _always_ requires
exact value because he accounts memory. So we don't use quick-and-fuzzy
-read-and-do-periodic-synchronization way. Thus, we iterate all cpus
for one read.

And we mem_cgroup_usage() and mem_cgroup_recursive_stat() both finally
call into mem_cgroup_read_stat().

However, these *stat snapshot* operations are implemented in a quite
coarse way: it takes M*N iteration for each stat item(M=nr_memcgs,
N=nr_possible_cpus). There are two deficiencies:

1. for every stat item, we have to iterate over all percpu value, which
   is not so cache friendly.
2. for every stat item, we call mem_cgroup_read_stat() once, which
   increase the probablity of contending on pcp_counter_lock.

So, this patch improve this a bit. Concretely, for all interested stat
items, mark them in a bitmap, and then make mem_cgroup_read_stat() read
them all in one go.

This is more efficient, and to some degree make it more like *stat snapshot*.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/memcontrol.c | 91 +++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 62 insertions(+), 29 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 29501f0..009357e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -347,7 +347,7 @@ struct mem_cgroup {
 	struct mem_cgroup_stat_cpu __percpu *stat;
 	/*
 	 * used when a cpu is offlined or other synchronizations
-	 * See mem_cgroup_read_stat().
+	 * See mem_cgroup_read_stat_vec().
 	 */
 	struct mem_cgroup_stat_cpu nocpu_base;
 	spinlock_t pcp_counter_lock;
@@ -855,7 +855,13 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
 	return mz;
 }
 
-/*
+/**
+ * @memcg: the mem_cgroup to account for.
+ * @stat_bitmask: a bitmap record which stat items to read,
+ *		each mem_cgroup_stat_index has its corresponding bit.
+ * @stat_vec: a stat vector to hold the stat value for returing, caller
+ *		shall take care of initializing it.
+ *
  * Implementation Note: reading percpu statistics for memcg.
  *
  * Both of vmstat[] and percpu_counter has threshold and do periodic
@@ -874,22 +880,25 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
  * common workload, threashold and synchonization as vmstat[] should be
  * implemented.
  */
-static long mem_cgroup_read_stat(struct mem_cgroup *memcg,
-				 enum mem_cgroup_stat_index idx)
+static void mem_cgroup_read_stat_vec(struct mem_cgroup *memcg,
+				 unsigned long *stat_bitmask,
+				 long long *stat_vec)
 {
-	long val = 0;
 	int cpu;
+	int i;
 
 	get_online_cpus();
 	for_each_online_cpu(cpu)
-		val += per_cpu(memcg->stat->count[idx], cpu);
+		for_each_set_bit(i, stat_bitmask, MEM_CGROUP_STAT_NSTATS)
+			stat_vec[i] += per_cpu(memcg->stat->count[i], cpu);
+
 #ifdef CONFIG_HOTPLUG_CPU
 	spin_lock(&memcg->pcp_counter_lock);
-	val += memcg->nocpu_base.count[idx];
+	for_each_set_bit(i, stat_bitmask, MEM_CGROUP_STAT_NSTATS)
+		stat_vec[i] += memcg->nocpu_base.count[i];
 	spin_unlock(&memcg->pcp_counter_lock);
 #endif
 	put_online_cpus();
-	return val;
 }
 
 static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
@@ -1674,6 +1683,7 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 	static DEFINE_MUTEX(oom_info_lock);
 	struct mem_cgroup *iter;
 	unsigned int i;
+	DECLARE_BITMAP(stat_bitmask, MEM_CGROUP_STAT_NSTATS);
 
 	if (!p)
 		return;
@@ -1702,16 +1712,22 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 		res_counter_read_u64(&memcg->kmem, RES_LIMIT) >> 10,
 		res_counter_read_u64(&memcg->kmem, RES_FAILCNT));
 
+	bitmap_fill(stat_bitmask, MEM_CGROUP_STAT_NSTATS);
+	if (!do_swap_account)
+		clear_bit(MEM_CGROUP_STAT_SWAP, stat_bitmask);
 	for_each_mem_cgroup_tree(iter, memcg) {
+		long long stat_vec[MEM_CGROUP_STAT_NSTATS] = {0};
+
 		pr_info("Memory cgroup stats for ");
 		pr_cont_cgroup_path(iter->css.cgroup);
 		pr_cont(":");
 
+		mem_cgroup_read_stat_vec(iter, stat_bitmask, stat_vec);
 		for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
 			if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
 				continue;
-			pr_cont(" %s:%ldKB", mem_cgroup_stat_names[i],
-				K(mem_cgroup_read_stat(iter, i)));
+			pr_cont(" %s:%lldKB", mem_cgroup_stat_names[i],
+				K(stat_vec[i]));
 		}
 
 		for (i = 0; i < NR_LRU_LISTS; i++)
@@ -4940,25 +4956,28 @@ out:
 	return retval;
 }
 
-
-static unsigned long mem_cgroup_recursive_stat(struct mem_cgroup *memcg,
-					       enum mem_cgroup_stat_index idx)
+/* Callers should take care of initialize stat_vec array */
+static void mem_cgroup_recursive_stat(struct mem_cgroup *memcg,
+					unsigned long *stat_bitmask,
+					long long *stat_vec)
 {
 	struct mem_cgroup *iter;
-	long val = 0;
+	int idx;
 
 	/* Per-cpu values can be negative, use a signed accumulator */
 	for_each_mem_cgroup_tree(iter, memcg)
-		val += mem_cgroup_read_stat(iter, idx);
+		mem_cgroup_read_stat_vec(iter, stat_bitmask, stat_vec);
 
-	if (val < 0) /* race ? */
-		val = 0;
-	return val;
+	for_each_set_bit(idx, stat_bitmask, MEM_CGROUP_STAT_NSTATS)
+		if (stat_vec[idx] < 0) /* race ? */
+			stat_vec[idx] = 0;
 }
 
 static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 {
 	u64 val;
+	DECLARE_BITMAP(stat_bitmask, MEM_CGROUP_STAT_NSTATS);
+	long long stat_vec[MEM_CGROUP_STAT_NSTATS] = {0};
 
 	if (!mem_cgroup_is_root(memcg)) {
 		if (!swap)
@@ -4967,15 +4986,21 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 			return res_counter_read_u64(&memcg->memsw, RES_USAGE);
 	}
 
+
 	/*
 	 * Transparent hugepages are still accounted for in MEM_CGROUP_STAT_RSS
 	 * as well as in MEM_CGROUP_STAT_RSS_HUGE.
 	 */
-	val = mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_CACHE);
-	val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_RSS);
-
+	bitmap_zero(stat_bitmask, MEM_CGROUP_STAT_NSTATS);
+	set_bit(MEM_CGROUP_STAT_CACHE, stat_bitmask);
+	set_bit(MEM_CGROUP_STAT_RSS, stat_bitmask);
 	if (swap)
-		val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_SWAP);
+		set_bit(MEM_CGROUP_STAT_SWAP, stat_bitmask);
+
+	mem_cgroup_recursive_stat(memcg, stat_bitmask, stat_vec);
+
+	val = stat_vec[MEM_CGROUP_STAT_CACHE] + stat_vec[MEM_CGROUP_STAT_RSS] +
+	      (swap ? stat_vec[MEM_CGROUP_STAT_SWAP] : 0);
 
 	return val << PAGE_SHIFT;
 }
@@ -5349,12 +5374,19 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
 	struct mem_cgroup *mi;
 	unsigned int i;
+	DECLARE_BITMAP(stat_bitmask, MEM_CGROUP_STAT_NSTATS);
+	long long stat_vec[MEM_CGROUP_STAT_NSTATS] = {0};
+
+	bitmap_fill(stat_bitmask, MEM_CGROUP_STAT_NSTATS);
+	if (!do_swap_account)
+		clear_bit(MEM_CGROUP_STAT_SWAP, stat_bitmask);
+	mem_cgroup_read_stat_vec(memcg, stat_bitmask, stat_vec);
 
 	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
 		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
 			continue;
-		seq_printf(m, "%s %ld\n", mem_cgroup_stat_names[i],
-			   mem_cgroup_read_stat(memcg, i) * PAGE_SIZE);
+		seq_printf(m, "%s %lld\n", mem_cgroup_stat_names[i],
+			   stat_vec[i] * PAGE_SIZE);
 	}
 
 	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++)
@@ -5375,14 +5407,15 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 				   memsw_limit);
 	}
 
+	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++)
+		stat_vec[i] = 0;
+	mem_cgroup_recursive_stat(memcg, stat_bitmask, stat_vec);
 	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
-		long long val = 0;
-
 		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
 			continue;
-		for_each_mem_cgroup_tree(mi, memcg)
-			val += mem_cgroup_read_stat(mi, i) * PAGE_SIZE;
-		seq_printf(m, "total_%s %lld\n", mem_cgroup_stat_names[i], val);
+
+		seq_printf(m, "total_%s %lld\n", mem_cgroup_stat_names[i],
+				stat_vec[i] * PAGE_SIZE);
 	}
 
 	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++) {
-- 
1.9.0.GIT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
