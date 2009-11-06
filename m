Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2CA736B006A
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 03:58:26 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA68wNiY009043
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Nov 2009 17:58:23 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 48FE845DE4F
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 17:58:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1987845DE4D
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 17:58:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 01E201DB803C
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 17:58:23 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 549CE1DB803A
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 17:58:19 +0900 (JST)
Date: Fri, 6 Nov 2009 17:55:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/2] memcg : rewrite percpu countings with new interfaces
Message-Id: <20091106175545.b97ee867.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091106175242.6e13ee29.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091106175242.6e13ee29.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, alloc_percpu() alloc good dynamic allocations and
Recent updates on percpu.h gives us following kind of ops 
   - __this_cpu_add() etc...
This is designed to be a help for reduce code size in hot-path
and very useful to handle percpu area. Thanks for great works.

This patch rewrite memcg's (not-good) percpu status with new
percpu support macros. This decreases code size and instruction
size. By this, this area is now NUMA-aware and may have performance 
benefit. 

I got good result in parallel pagefault test. (my host is 8cpu/2socket)

before==
 Performance counter stats for './runpause.sh' (5 runs):

  474070.055912  task-clock-msecs         #      7.881 CPUs    ( +-   0.013% )
       35829310  page-faults              #      0.076 M/sec   ( +-   0.217% )
     3803016722  cache-references         #      8.022 M/sec   ( +-   0.215% )  (scaled from 100.00%)
     1104083123  cache-misses             #      2.329 M/sec   ( +-   0.961% )  (scaled from 100.00%)

   60.154982314  seconds time elapsed   ( +-   0.018% )

after==
 Performance counter stats for './runpause.sh' (5 runs):

  474919.429670  task-clock-msecs         #      7.896 CPUs    ( +-   0.013% )
       36520440  page-faults              #      0.077 M/sec   ( +-   1.854% )
     3109834751  cache-references         #      6.548 M/sec   ( +-   0.276% )
     1053275160  cache-misses             #      2.218 M/sec   ( +-   0.036% )

   60.146585280  seconds time elapsed   ( +-   0.019% )

This test is affected by cpu-utilization but I think more improvements
will be found in bigger system.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  168 +++++++++++++++++++-------------------------------------
 1 file changed, 58 insertions(+), 110 deletions(-)

Index: mmotm-2.6.32-Nov2/mm/memcontrol.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/mm/memcontrol.c
+++ mmotm-2.6.32-Nov2/mm/memcontrol.c
@@ -39,6 +39,7 @@
 #include <linux/mm_inline.h>
 #include <linux/page_cgroup.h>
 #include <linux/cpu.h>
+#include <linux/percpu.h>
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -78,54 +79,8 @@ enum mem_cgroup_stat_index {
 
 struct mem_cgroup_stat_cpu {
 	s64 count[MEMCG_STAT_NSTATS];
-} ____cacheline_aligned_in_smp;
-
-struct mem_cgroup_stat {
-	struct mem_cgroup_stat_cpu cpustat[0];
 };
 
-static inline void
-__mem_cgroup_stat_reset_safe(struct mem_cgroup_stat_cpu *stat,
-				enum mem_cgroup_stat_index idx)
-{
-	stat->count[idx] = 0;
-}
-
-static inline s64
-__mem_cgroup_stat_read_local(struct mem_cgroup_stat_cpu *stat,
-				enum mem_cgroup_stat_index idx)
-{
-	return stat->count[idx];
-}
-
-/*
- * For accounting under irq disable, no need for increment preempt count.
- */
-static inline void __mem_cgroup_stat_add_safe(struct mem_cgroup_stat_cpu *stat,
-		enum mem_cgroup_stat_index idx, int val)
-{
-	stat->count[idx] += val;
-}
-
-static s64 mem_cgroup_read_stat(struct mem_cgroup_stat *stat,
-		enum mem_cgroup_stat_index idx)
-{
-	int cpu;
-	s64 ret = 0;
-	for_each_possible_cpu(cpu)
-		ret += stat->cpustat[cpu].count[idx];
-	return ret;
-}
-
-static s64 mem_cgroup_local_usage(struct mem_cgroup_stat *stat)
-{
-	s64 ret;
-
-	ret = mem_cgroup_read_stat(stat, MEMCG_NR_CACHE);
-	ret += mem_cgroup_read_stat(stat, MEMCG_NR_RSS);
-	return ret;
-}
-
 /*
  * per-zone information in memory controller.
  */
@@ -226,10 +181,7 @@ struct mem_cgroup {
 	/* set when res.limit == memsw.limit */
 	bool		memsw_is_minimum;
 
-	/*
-	 * statistics. This must be placed at the end of memcg.
-	 */
-	struct mem_cgroup_stat stat;
+	struct mem_cgroup_stat_cpu *cpustat;
 };
 
 /*
@@ -370,18 +322,13 @@ mem_cgroup_remove_exceeded(struct mem_cg
 static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
 {
 	bool ret = false;
-	int cpu;
 	s64 val;
-	struct mem_cgroup_stat_cpu *cpustat;
 
-	cpu = get_cpu();
-	cpustat = &mem->stat.cpustat[cpu];
-	val = __mem_cgroup_stat_read_local(cpustat, MEMCG_EVENTS);
+	val = __this_cpu_read(mem->cpustat->count[MEMCG_EVENTS]);
 	if (unlikely(val > SOFTLIMIT_EVENTS_THRESH)) {
-		__mem_cgroup_stat_reset_safe(cpustat, MEMCG_EVENTS);
+		__this_cpu_write(mem->cpustat->count[MEMCG_EVENTS], 0);
 		ret = true;
 	}
-	put_cpu();
 	return ret;
 }
 
@@ -477,17 +424,35 @@ mem_cgroup_largest_soft_limit_node(struc
 	return mz;
 }
 
+static s64 mem_cgroup_read_stat(struct mem_cgroup *mem,
+		enum mem_cgroup_stat_index idx)
+{
+	struct mem_cgroup_stat_cpu *cstat;
+	int cpu;
+	s64 ret = 0;
+
+	for_each_possible_cpu(cpu) {
+		cstat = per_cpu_ptr(mem->cpustat, cpu);
+		ret += cstat->count[idx];
+	}
+	return ret;
+}
+
+static s64 mem_cgroup_local_usage(struct mem_cgroup *mem)
+{
+	s64 ret;
+
+	ret = mem_cgroup_read_stat(mem, MEMCG_NR_CACHE);
+	ret += mem_cgroup_read_stat(mem, MEMCG_NR_RSS);
+	return ret;
+}
+
 static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
 					 bool charge)
 {
 	int val = (charge) ? 1 : -1;
-	struct mem_cgroup_stat *stat = &mem->stat;
-	struct mem_cgroup_stat_cpu *cpustat;
-	int cpu = get_cpu();
 
-	cpustat = &stat->cpustat[cpu];
-	__mem_cgroup_stat_add_safe(cpustat, MEMCG_NR_SWAP, val);
-	put_cpu();
+	__this_cpu_add(mem->cpustat->count[MEMCG_NR_SWAP], val);
 }
 
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
@@ -495,22 +460,17 @@ static void mem_cgroup_charge_statistics
 					 bool charge)
 {
 	int val = (charge) ? 1 : -1;
-	struct mem_cgroup_stat *stat = &mem->stat;
-	struct mem_cgroup_stat_cpu *cpustat;
-	int cpu = get_cpu();
 
-	cpustat = &stat->cpustat[cpu];
 	if (PageCgroupCache(pc))
-		__mem_cgroup_stat_add_safe(cpustat, MEMCG_NR_CACHE, val);
+		__this_cpu_add(mem->cpustat->count[MEMCG_NR_CACHE], val);
 	else
-		__mem_cgroup_stat_add_safe(cpustat, MEMCG_NR_RSS, val);
+		__this_cpu_add(mem->cpustat->count[MEMCG_NR_RSS], val);
 
 	if (charge)
-		__mem_cgroup_stat_add_safe(cpustat, MEMCG_PGPGIN, 1);
+		__this_cpu_inc(mem->cpustat->count[MEMCG_PGPGIN]);
 	else
-		__mem_cgroup_stat_add_safe(cpustat, MEMCG_PGPGOUT, 1);
-	__mem_cgroup_stat_add_safe(cpustat, MEMCG_EVENTS, 1);
-	put_cpu();
+		__this_cpu_inc(mem->cpustat->count[MEMCG_PGPGOUT]);
+	__this_cpu_inc(mem->cpustat->count[MEMCG_EVENTS]);
 }
 
 static unsigned long mem_cgroup_get_local_zonestat(struct mem_cgroup *mem,
@@ -1162,7 +1122,7 @@ static int mem_cgroup_hierarchical_recla
 				}
 			}
 		}
-		if (!mem_cgroup_local_usage(&victim->stat)) {
+		if (!mem_cgroup_local_usage(victim)) {
 			/* this cgroup's local usage == 0 */
 			css_put(&victim->css);
 			continue;
@@ -1228,9 +1188,6 @@ static void record_last_oom(struct mem_c
 void mem_cgroup_update_file_mapped(struct page *page, int val)
 {
 	struct mem_cgroup *mem;
-	struct mem_cgroup_stat *stat;
-	struct mem_cgroup_stat_cpu *cpustat;
-	int cpu;
 	struct page_cgroup *pc;
 
 	pc = lookup_page_cgroup(page);
@@ -1245,14 +1202,7 @@ void mem_cgroup_update_file_mapped(struc
 	if (!PageCgroupUsed(pc))
 		goto done;
 
-	/*
-	 * Preemption is already disabled, we don't need get_cpu()
-	 */
-	cpu = smp_processor_id();
-	stat = &mem->stat;
-	cpustat = &stat->cpustat[cpu];
-
-	__mem_cgroup_stat_add_safe(cpustat, MEMCG_NR_FILE_MAPPED, val);
+	__this_cpu_add(mem->cpustat->count[MEMCG_NR_FILE_MAPPED], val);
 done:
 	unlock_page_cgroup(pc);
 }
@@ -1623,9 +1573,6 @@ static int mem_cgroup_move_account(struc
 	int nid, zid;
 	int ret = -EBUSY;
 	struct page *page;
-	int cpu;
-	struct mem_cgroup_stat *stat;
-	struct mem_cgroup_stat_cpu *cpustat;
 
 	VM_BUG_ON(from == to);
 	VM_BUG_ON(PageLRU(pc->page));
@@ -1650,16 +1597,11 @@ static int mem_cgroup_move_account(struc
 
 	page = pc->page;
 	if (page_mapped(page) && !PageAnon(page)) {
-		cpu = smp_processor_id();
 		/* Update mapped_file data for mem_cgroup "from" */
-		stat = &from->stat;
-		cpustat = &stat->cpustat[cpu];
-		__mem_cgroup_stat_add_safe(cpustat, MEMCG_NR_FILE_MAPPED, -1);
+		__this_cpu_dec(from->cpustat->count[MEMCG_NR_FILE_MAPPED]);
 
 		/* Update mapped_file data for mem_cgroup "to" */
-		stat = &to->stat;
-		cpustat = &stat->cpustat[cpu];
-		__mem_cgroup_stat_add_safe(cpustat, MEMCG_NR_FILE_MAPPED, 1);
+		__this_cpu_inc(to->cpustat->count[MEMCG_NR_FILE_MAPPED]);
 	}
 
 	if (do_swap_account && !mem_cgroup_is_root(from))
@@ -2715,7 +2657,7 @@ static int
 mem_cgroup_get_idx_stat(struct mem_cgroup *mem, void *data)
 {
 	struct mem_cgroup_idx_data *d = data;
-	d->val += mem_cgroup_read_stat(&mem->stat, d->idx);
+	d->val += mem_cgroup_read_stat(mem, d->idx);
 	return 0;
 }
 
@@ -2920,18 +2862,18 @@ static int mem_cgroup_get_local_stat(str
 	s64 val;
 
 	/* per cpu stat */
-	val = mem_cgroup_read_stat(&mem->stat, MEMCG_NR_CACHE);
+	val = mem_cgroup_read_stat(mem, MEMCG_NR_CACHE);
 	s->stat[MCS_CACHE] += val * PAGE_SIZE;
-	val = mem_cgroup_read_stat(&mem->stat, MEMCG_NR_RSS);
+	val = mem_cgroup_read_stat(mem, MEMCG_NR_RSS);
 	s->stat[MCS_RSS] += val * PAGE_SIZE;
-	val = mem_cgroup_read_stat(&mem->stat, MEMCG_NR_FILE_MAPPED);
+	val = mem_cgroup_read_stat(mem, MEMCG_NR_FILE_MAPPED);
 	s->stat[MCS_FILE_MAPPED] += val * PAGE_SIZE;
-	val = mem_cgroup_read_stat(&mem->stat, MEMCG_PGPGIN);
+	val = mem_cgroup_read_stat(mem, MEMCG_PGPGIN);
 	s->stat[MCS_PGPGIN] += val;
-	val = mem_cgroup_read_stat(&mem->stat, MEMCG_PGPGOUT);
+	val = mem_cgroup_read_stat(mem, MEMCG_PGPGOUT);
 	s->stat[MCS_PGPGOUT] += val;
 	if (do_swap_account) {
-		val = mem_cgroup_read_stat(&mem->stat, MEMCG_NR_SWAP);
+		val = mem_cgroup_read_stat(mem, MEMCG_NR_SWAP);
 		s->stat[MCS_SWAP] += val * PAGE_SIZE;
 	}
 
@@ -3190,17 +3132,12 @@ static void free_mem_cgroup_per_zone_inf
 	kfree(mem->info.nodeinfo[node]);
 }
 
-static int mem_cgroup_size(void)
-{
-	int cpustat_size = nr_cpu_ids * sizeof(struct mem_cgroup_stat_cpu);
-	return sizeof(struct mem_cgroup) + cpustat_size;
-}
-
 static struct mem_cgroup *mem_cgroup_alloc(void)
 {
 	struct mem_cgroup *mem;
-	int size = mem_cgroup_size();
+	int size = sizeof(struct mem_cgroup);
 
+	/* Can be very big if MAX_NUMNODES is big */
 	if (size < PAGE_SIZE)
 		mem = kmalloc(size, GFP_KERNEL);
 	else
@@ -3208,6 +3145,15 @@ static struct mem_cgroup *mem_cgroup_all
 
 	if (mem)
 		memset(mem, 0, size);
+	mem->cpustat = alloc_percpu(struct mem_cgroup_stat_cpu);
+	if (!mem->cpustat) {
+		if (size < PAGE_SIZE)
+			kfree(mem);
+		else
+			vfree(mem);
+		mem = NULL;
+	}
+
 	return mem;
 }
 
@@ -3232,7 +3178,9 @@ static void __mem_cgroup_free(struct mem
 	for_each_node_state(node, N_POSSIBLE)
 		free_mem_cgroup_per_zone_info(mem, node);
 
-	if (mem_cgroup_size() < PAGE_SIZE)
+	free_percpu(mem->cpustat);
+
+	if (sizeof(struct mem_cgroup) < PAGE_SIZE)
 		kfree(mem);
 	else
 		vfree(mem);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
