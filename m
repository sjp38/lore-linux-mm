Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 52C416B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 18:16:38 -0400 (EDT)
Received: by pacbt3 with SMTP id bt3so2619861pac.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 15:16:38 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id w7si5615212pbs.85.2015.09.22.15.16.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 15:16:37 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so21180156pac.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 15:16:37 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH] memcg: make mem_cgroup_read_stat() unsigned
Date: Tue, 22 Sep 2015 15:16:32 -0700
Message-Id: <1442960192-83405-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>

mem_cgroup_read_stat() returns a page count by summing per cpu page
counters.  The summing is racy wrt. updates, so a transient negative sum
is possible.  Callers don't want negative values:
- mem_cgroup_wb_stats() doesn't want negative nr_dirty or nr_writeback.
- oom reports and memory.stat shouldn't show confusing negative usage.
- tree_usage() already avoids negatives.

Avoid returning negative page counts from mem_cgroup_read_stat() and
convert it to unsigned.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/memcontrol.c | 30 ++++++++++++++++++------------
 1 file changed, 18 insertions(+), 12 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6ddaeba34e09..2633e9be4a99 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -644,12 +644,14 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
 }
 
 /*
+ * Return page count for single (non recursive) @memcg.
+ *
  * Implementation Note: reading percpu statistics for memcg.
  *
  * Both of vmstat[] and percpu_counter has threshold and do periodic
  * synchronization to implement "quick" read. There are trade-off between
  * reading cost and precision of value. Then, we may have a chance to implement
- * a periodic synchronizion of counter in memcg's counter.
+ * a periodic synchronization of counter in memcg's counter.
  *
  * But this _read() function is used for user interface now. The user accounts
  * memory usage by memory cgroup and he _always_ requires exact value because
@@ -659,17 +661,24 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
  *
  * If there are kernel internal actions which can make use of some not-exact
  * value, and reading all cpu value can be performance bottleneck in some
- * common workload, threashold and synchonization as vmstat[] should be
+ * common workload, threashold and synchronization as vmstat[] should be
  * implemented.
  */
-static long mem_cgroup_read_stat(struct mem_cgroup *memcg,
-				 enum mem_cgroup_stat_index idx)
+static unsigned long
+mem_cgroup_read_stat(struct mem_cgroup *memcg, enum mem_cgroup_stat_index idx)
 {
 	long val = 0;
 	int cpu;
 
+	/* Per-cpu values can be negative, use a signed accumulator */
 	for_each_possible_cpu(cpu)
 		val += per_cpu(memcg->stat->count[idx], cpu);
+	/*
+	 * Summing races with updates, so val may be negative.  Avoid exposing
+	 * transient negative values.
+	 */
+	if (val < 0)
+		val = 0;
 	return val;
 }
 
@@ -1254,7 +1263,7 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 		for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
 			if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
 				continue;
-			pr_cont(" %s:%ldKB", mem_cgroup_stat_names[i],
+			pr_cont(" %s:%luKB", mem_cgroup_stat_names[i],
 				K(mem_cgroup_read_stat(iter, i)));
 		}
 
@@ -2819,14 +2828,11 @@ static unsigned long tree_stat(struct mem_cgroup *memcg,
 			       enum mem_cgroup_stat_index idx)
 {
 	struct mem_cgroup *iter;
-	long val = 0;
+	unsigned long val = 0;
 
-	/* Per-cpu values can be negative, use a signed accumulator */
 	for_each_mem_cgroup_tree(iter, memcg)
 		val += mem_cgroup_read_stat(iter, idx);
 
-	if (val < 0) /* race ? */
-		val = 0;
 	return val;
 }
 
@@ -3169,7 +3175,7 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
 		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
 			continue;
-		seq_printf(m, "%s %ld\n", mem_cgroup_stat_names[i],
+		seq_printf(m, "%s %lu\n", mem_cgroup_stat_names[i],
 			   mem_cgroup_read_stat(memcg, i) * PAGE_SIZE);
 	}
 
@@ -3194,13 +3200,13 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 			   (u64)memsw * PAGE_SIZE);
 
 	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
-		long long val = 0;
+		unsigned long long val = 0;
 
 		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
 			continue;
 		for_each_mem_cgroup_tree(mi, memcg)
 			val += mem_cgroup_read_stat(mi, i) * PAGE_SIZE;
-		seq_printf(m, "total_%s %lld\n", mem_cgroup_stat_names[i], val);
+		seq_printf(m, "total_%s %llu\n", mem_cgroup_stat_names[i], val);
 	}
 
 	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++) {
-- 
2.6.0.rc0.131.gf624c3d

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
