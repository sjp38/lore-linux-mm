Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BA7D06B0078
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 02:21:52 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0K7LnXX012183
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 20 Jan 2010 16:21:49 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0789A2AEA8E
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 16:21:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C956245DE4E
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 16:21:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BE0EE78008
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 16:21:48 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DC89BE38003
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 16:21:47 +0900 (JST)
Date: Wed, 20 Jan 2010 16:18:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH mmotm] memcg use generic percpu allocator instead of private
 one
Message-Id: <20100120161825.15c372ac.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, kirill@shutemov.name
List-ID: <linux-mm.kvack.org>

This patch is onto mmotm Jan/15.
=
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

When per-cpu counter for memcg was implemneted, dynamic percpu allocator
was not very good. But now, we have good one and useful macros.
This patch replaces memcg's private percpu counter implementation with
generic dynamic percpu allocator and macros.

The benefits are
	- We can remove private implementation.
	- The counters will be NUMA-aware. (Current one is not...)
	- This patch reduces sizeof(struct mem_cgroup). Then,
	  struct mem_cgroup may be fit in page size on small config.

By this, size of text is reduced.
 [Before]
 [kamezawa@bluextal mmotm-2.6.33-Jan15]$ size mm/memcontrol.o
   text    data     bss     dec     hex filename
  24373    2528    4132   31033    7939 mm/memcontrol.o
 [After]
 [kamezawa@bluextal mmotm-2.6.33-Jan15]$ size mm/memcontrol.o
   text    data     bss     dec     hex filename
  23913    2528    4132   30573    776d mm/memcontrol.o

This includes no functional changes.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  184 +++++++++++++++++++-------------------------------------
 1 file changed, 63 insertions(+), 121 deletions(-)

Index: mmotm-2.6.33-Jan15/mm/memcontrol.c
===================================================================
--- mmotm-2.6.33-Jan15.orig/mm/memcontrol.c
+++ mmotm-2.6.33-Jan15/mm/memcontrol.c
@@ -89,54 +89,8 @@ enum mem_cgroup_stat_index {
 
 struct mem_cgroup_stat_cpu {
 	s64 count[MEM_CGROUP_STAT_NSTATS];
-} ____cacheline_aligned_in_smp;
-
-struct mem_cgroup_stat {
-	struct mem_cgroup_stat_cpu cpustat[0];
 };
 
-static inline void
-__mem_cgroup_stat_set_safe(struct mem_cgroup_stat_cpu *stat,
-				enum mem_cgroup_stat_index idx, s64 val)
-{
-	stat->count[idx] = val;
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
-	ret = mem_cgroup_read_stat(stat, MEM_CGROUP_STAT_CACHE);
-	ret += mem_cgroup_read_stat(stat, MEM_CGROUP_STAT_RSS);
-	return ret;
-}
-
 /*
  * per-zone information in memory controller.
  */
@@ -270,9 +224,9 @@ struct mem_cgroup {
 	unsigned long 	move_charge_at_immigrate;
 
 	/*
-	 * statistics. This must be placed at the end of memcg.
+	 * percpu counter.
 	 */
-	struct mem_cgroup_stat stat;
+	struct mem_cgroup_stat_cpu *stat;
 };
 
 /* Stuffs for move charges at task migration. */
@@ -441,19 +395,14 @@ mem_cgroup_remove_exceeded(struct mem_cg
 static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
 {
 	bool ret = false;
-	int cpu;
 	s64 val;
-	struct mem_cgroup_stat_cpu *cpustat;
 
-	cpu = get_cpu();
-	cpustat = &mem->stat.cpustat[cpu];
-	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_SOFTLIMIT);
+	val = this_cpu_read(mem->stat->count[MEM_CGROUP_STAT_SOFTLIMIT]);
 	if (unlikely(val < 0)) {
-		__mem_cgroup_stat_set_safe(cpustat, MEM_CGROUP_STAT_SOFTLIMIT,
+		this_cpu_write(mem->stat->count[MEM_CGROUP_STAT_SOFTLIMIT],
 				SOFTLIMIT_EVENTS_THRESH);
 		ret = true;
 	}
-	put_cpu();
 	return ret;
 }
 
@@ -549,17 +498,31 @@ mem_cgroup_largest_soft_limit_node(struc
 	return mz;
 }
 
+static s64 mem_cgroup_read_stat(struct mem_cgroup *mem,
+		enum mem_cgroup_stat_index idx)
+{
+	int cpu;
+	s64 val = 0;
+
+	for_each_possible_cpu(cpu)
+		val += per_cpu(mem->stat->count[idx], cpu);
+	return val;
+}
+
+static s64 mem_cgroup_local_usage(struct mem_cgroup *mem)
+{
+	s64 ret;
+
+	ret = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_RSS);
+	ret += mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_CACHE);
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
-
-	cpustat = &stat->cpustat[cpu];
-	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_SWAPOUT, val);
-	put_cpu();
+	this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_SWAPOUT], val);
 }
 
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
@@ -567,26 +530,22 @@ static void mem_cgroup_charge_statistics
 					 bool charge)
 {
 	int val = (charge) ? 1 : -1;
-	struct mem_cgroup_stat *stat = &mem->stat;
-	struct mem_cgroup_stat_cpu *cpustat;
-	int cpu = get_cpu();
 
-	cpustat = &stat->cpustat[cpu];
+	preempt_disable();
+
 	if (PageCgroupCache(pc))
-		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_CACHE, val);
+		__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_CACHE], val);
 	else
-		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_RSS, val);
+		__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_RSS], val);
 
 	if (charge)
-		__mem_cgroup_stat_add_safe(cpustat,
-				MEM_CGROUP_STAT_PGPGIN_COUNT, 1);
+		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGIN_COUNT]);
 	else
-		__mem_cgroup_stat_add_safe(cpustat,
-				MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
-	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_SOFTLIMIT, -1);
-	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_THRESHOLDS, -1);
+		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGOUT_COUNT]);
+	__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_SOFTLIMIT]);
+	__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_THRESHOLDS]);
 
-	put_cpu();
+	preempt_enable();
 }
 
 static unsigned long mem_cgroup_get_local_zonestat(struct mem_cgroup *mem,
@@ -1244,7 +1203,7 @@ static int mem_cgroup_hierarchical_recla
 				}
 			}
 		}
-		if (!mem_cgroup_local_usage(&victim->stat)) {
+		if (!mem_cgroup_local_usage(victim)) {
 			/* this cgroup's local usage == 0 */
 			css_put(&victim->css);
 			continue;
@@ -1310,9 +1269,6 @@ static void record_last_oom(struct mem_c
 void mem_cgroup_update_file_mapped(struct page *page, int val)
 {
 	struct mem_cgroup *mem;
-	struct mem_cgroup_stat *stat;
-	struct mem_cgroup_stat_cpu *cpustat;
-	int cpu;
 	struct page_cgroup *pc;
 
 	pc = lookup_page_cgroup(page);
@@ -1328,13 +1284,10 @@ void mem_cgroup_update_file_mapped(struc
 		goto done;
 
 	/*
-	 * Preemption is already disabled, we don't need get_cpu()
+	 * Preemption is already disabled. We can use __this_cpu_xxx
 	 */
-	cpu = smp_processor_id();
-	stat = &mem->stat;
-	cpustat = &stat->cpustat[cpu];
+	__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED], val);
 
-	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_FILE_MAPPED, val);
 done:
 	unlock_page_cgroup(pc);
 }
@@ -1761,9 +1714,6 @@ static void __mem_cgroup_move_account(st
 	struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
 {
 	struct page *page;
-	int cpu;
-	struct mem_cgroup_stat *stat;
-	struct mem_cgroup_stat_cpu *cpustat;
 
 	VM_BUG_ON(from == to);
 	VM_BUG_ON(PageLRU(pc->page));
@@ -1773,18 +1723,11 @@ static void __mem_cgroup_move_account(st
 
 	page = pc->page;
 	if (page_mapped(page) && !PageAnon(page)) {
-		cpu = smp_processor_id();
-		/* Update mapped_file data for mem_cgroup "from" */
-		stat = &from->stat;
-		cpustat = &stat->cpustat[cpu];
-		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_FILE_MAPPED,
-						-1);
-
-		/* Update mapped_file data for mem_cgroup "to" */
-		stat = &to->stat;
-		cpustat = &stat->cpustat[cpu];
-		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_FILE_MAPPED,
-						1);
+		/* Update mapped_file data for mem_cgroup */
+		preempt_disable();
+		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
+		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
+		preempt_enable();
 	}
 	mem_cgroup_charge_statistics(from, pc, false);
 	if (uncharge)
@@ -2885,7 +2828,7 @@ static int
 mem_cgroup_get_idx_stat(struct mem_cgroup *mem, void *data)
 {
 	struct mem_cgroup_idx_data *d = data;
-	d->val += mem_cgroup_read_stat(&mem->stat, d->idx);
+	d->val += mem_cgroup_read_stat(mem, d->idx);
 	return 0;
 }
 
@@ -3126,18 +3069,18 @@ static int mem_cgroup_get_local_stat(str
 	s64 val;
 
 	/* per cpu stat */
-	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_CACHE);
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_CACHE);
 	s->stat[MCS_CACHE] += val * PAGE_SIZE;
-	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_RSS);
 	s->stat[MCS_RSS] += val * PAGE_SIZE;
-	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_FILE_MAPPED);
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_MAPPED);
 	s->stat[MCS_FILE_MAPPED] += val * PAGE_SIZE;
-	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_PGPGIN_COUNT);
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_PGPGIN_COUNT);
 	s->stat[MCS_PGPGIN] += val;
-	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_PGPGOUT_COUNT);
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_PGPGOUT_COUNT);
 	s->stat[MCS_PGPGOUT] += val;
 	if (do_swap_account) {
-		val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_SWAPOUT);
+		val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
 		s->stat[MCS_SWAP] += val * PAGE_SIZE;
 	}
 
@@ -3287,19 +3230,14 @@ static int mem_cgroup_swappiness_write(s
 static bool mem_cgroup_threshold_check(struct mem_cgroup *mem)
 {
 	bool ret = false;
-	int cpu;
 	s64 val;
-	struct mem_cgroup_stat_cpu *cpustat;
 
-	cpu = get_cpu();
-	cpustat = &mem->stat.cpustat[cpu];
-	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_THRESHOLDS);
+	val = this_cpu_read(mem->stat->count[MEM_CGROUP_STAT_THRESHOLDS]);
 	if (unlikely(val < 0)) {
-		__mem_cgroup_stat_set_safe(cpustat, MEM_CGROUP_STAT_THRESHOLDS,
+		this_cpu_write(mem->stat->count[MEM_CGROUP_STAT_THRESHOLDS],
 				THRESHOLDS_EVENTS_THRESH);
 		ret = true;
 	}
-	put_cpu();
 	return ret;
 }
 
@@ -3687,17 +3625,12 @@ static void free_mem_cgroup_per_zone_inf
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
 
+	/* Can be very big if MAX_NUMNODES is very big */
 	if (size < PAGE_SIZE)
 		mem = kmalloc(size, GFP_KERNEL);
 	else
@@ -3705,6 +3638,14 @@ static struct mem_cgroup *mem_cgroup_all
 
 	if (mem)
 		memset(mem, 0, size);
+	mem->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
+	if (!mem->stat) {
+		if (size < PAGE_SIZE)
+			kfree(mem);
+		else
+			vfree(mem);
+		mem = NULL;
+	}
 	return mem;
 }
 
@@ -3729,7 +3670,8 @@ static void __mem_cgroup_free(struct mem
 	for_each_node_state(node, N_POSSIBLE)
 		free_mem_cgroup_per_zone_info(mem, node);
 
-	if (mem_cgroup_size() < PAGE_SIZE)
+	free_percpu(mem->stat);
+	if (sizeof(struct mem_cgroup) < PAGE_SIZE)
 		kfree(mem);
 	else
 		vfree(mem);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
