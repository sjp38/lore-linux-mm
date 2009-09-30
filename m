Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C858B6B005A
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 06:06:58 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8UAEMwS032173
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 30 Sep 2009 19:14:22 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 28DD145DE4C
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 19:14:22 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id F285145DE4E
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 19:14:21 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D6F3E1DB8041
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 19:14:21 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 824701DB803E
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 19:14:21 +0900 (JST)
Date: Wed, 30 Sep 2009 19:12:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/2] memcg: use generic percpu array_counter
Message-Id: <20090930191209.e7f14414.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090930190417.8823fa44.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090930190417.8823fa44.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Replace memcg's private percpu counter with array_counter().
And I made counter's array index's name shorter for easy reading.
By this patch, one of memcg's dirty part will go away.

Side-effect:
This makes event-coutner as global counter, not per-cpu counter.
Maybe good side-effect for softlimit updates.


Signged-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  216 +++++++++++++++++++-------------------------------------
 1 file changed, 75 insertions(+), 141 deletions(-)

Index: mmotm-2.6.31-Sep28/mm/memcontrol.c
===================================================================
--- mmotm-2.6.31-Sep28.orig/mm/memcontrol.c
+++ mmotm-2.6.31-Sep28/mm/memcontrol.c
@@ -39,6 +39,7 @@
 #include <linux/mm_inline.h>
 #include <linux/page_cgroup.h>
 #include <linux/cpu.h>
+#include <linux/percpu_counter.h>
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -56,7 +57,6 @@ static int really_do_swap_account __init
 #endif
 
 static DEFINE_MUTEX(memcg_tasklist);	/* can be hold under cgroup_mutex */
-#define SOFTLIMIT_EVENTS_THRESH (1000)
 
 /*
  * Statistics for memory cgroup.
@@ -65,67 +65,17 @@ enum mem_cgroup_stat_index {
 	/*
 	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
 	 */
-	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
-	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
-	MEM_CGROUP_STAT_MAPPED_FILE,  /* # of pages charged as file rss */
-	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
-	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
-	MEM_CGROUP_STAT_EVENTS,	/* sum of pagein + pageout for internal use */
-	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
+	MEMCG_STAT_CACHE, 	   /* # of pages charged as cache */
+	MEMCG_STAT_RSS,	   /* # of pages charged as anon rss */
+	MEMCG_STAT_MAPPED_FILE,  /* # of pages charged as file rss */
+	MEMCG_STAT_PGPGIN,	/* # of pages paged in */
+	MEMCG_STAT_PGPGOUT,	/* # of pages paged out */
+	MEMCG_STAT_EVENTS,	/* sum of pagein + pageout for internal use */
+	MEMCG_STAT_SWAPOUT, /* # of pages, swapped out */
 
-	MEM_CGROUP_STAT_NSTATS,
+	MEMCG_STAT_NSTATS,
 };
 
-struct mem_cgroup_stat_cpu {
-	s64 count[MEM_CGROUP_STAT_NSTATS];
-} ____cacheline_aligned_in_smp;
-
-struct mem_cgroup_stat {
-	struct mem_cgroup_stat_cpu cpustat[0];
-};
-
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
-	ret = mem_cgroup_read_stat(stat, MEM_CGROUP_STAT_CACHE);
-	ret += mem_cgroup_read_stat(stat, MEM_CGROUP_STAT_RSS);
-	return ret;
-}
-
 /*
  * per-zone information in memory controller.
  */
@@ -223,13 +173,13 @@ struct mem_cgroup {
 
 	unsigned int	swappiness;
 
+	unsigned long		softlimit_prev_event;
+#define SOFTLIMIT_EVENTS_THRESH (4000)
 	/* set when res.limit == memsw.limit */
 	bool		memsw_is_minimum;
 
-	/*
-	 * statistics. This must be placed at the end of memcg.
-	 */
-	struct mem_cgroup_stat stat;
+	/* statistics. using percpu array counter */
+	DEFINE_ARRAY_COUNTER(stat, MEMCG_STAT_NSTATS);
 };
 
 /*
@@ -369,20 +319,17 @@ mem_cgroup_remove_exceeded(struct mem_cg
 
 static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
 {
-	bool ret = false;
-	int cpu;
-	s64 val;
-	struct mem_cgroup_stat_cpu *cpustat;
-
-	cpu = get_cpu();
-	cpustat = &mem->stat.cpustat[cpu];
-	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_EVENTS);
-	if (unlikely(val > SOFTLIMIT_EVENTS_THRESH)) {
-		__mem_cgroup_stat_reset_safe(cpustat, MEM_CGROUP_STAT_EVENTS);
-		ret = true;
+	unsigned long val;
+	val = (unsigned long)
+		array_counter_read(GET_ARC(&mem->stat), MEMCG_STAT_EVENTS);
+
+	if (unlikely(time_after(val, mem->softlimit_prev_event +
+					SOFTLIMIT_EVENTS_THRESH))) {
+		/* there can be race..but not necessary to correct. */
+		mem->softlimit_prev_event = val;
+		return true;
 	}
-	put_cpu();
-	return ret;
+	return false;
 }
 
 static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page *page)
@@ -480,14 +427,10 @@ mem_cgroup_largest_soft_limit_node(struc
 static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
 					 bool charge)
 {
-	int val = (charge) ? 1 : -1;
-	struct mem_cgroup_stat *stat = &mem->stat;
-	struct mem_cgroup_stat_cpu *cpustat;
-	int cpu = get_cpu();
-
-	cpustat = &stat->cpustat[cpu];
-	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_SWAPOUT, val);
-	put_cpu();
+	if (charge)
+		array_counter_inc(GET_ARC(&mem->stat), MEMCG_STAT_SWAPOUT);
+	else
+		array_counter_dec(GET_ARC(&mem->stat), MEMCG_STAT_SWAPOUT);
 }
 
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
@@ -495,24 +438,28 @@ static void mem_cgroup_charge_statistics
 					 bool charge)
 {
 	int val = (charge) ? 1 : -1;
-	struct mem_cgroup_stat *stat = &mem->stat;
-	struct mem_cgroup_stat_cpu *cpustat;
-	int cpu = get_cpu();
+	struct array_counter *ac = GET_ARC(&mem->stat);
 
-	cpustat = &stat->cpustat[cpu];
 	if (PageCgroupCache(pc))
-		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_CACHE, val);
+		array_counter_add(ac, MEMCG_STAT_CACHE, val);
 	else
-		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_RSS, val);
+		array_counter_add(ac, MEMCG_STAT_RSS, val);
 
 	if (charge)
-		__mem_cgroup_stat_add_safe(cpustat,
-				MEM_CGROUP_STAT_PGPGIN_COUNT, 1);
+		array_counter_inc(ac,MEMCG_STAT_PGPGIN);
 	else
-		__mem_cgroup_stat_add_safe(cpustat,
-				MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
-	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_EVENTS, 1);
-	put_cpu();
+		array_counter_inc(ac, MEMCG_STAT_PGPGOUT);
+	array_counter_inc(ac, MEMCG_STAT_EVENTS);
+}
+
+/* This function ignores hierarchy */
+static unsigned long mem_cgroup_my_usage(struct mem_cgroup *mem)
+{
+	unsigned long ret;
+
+	ret = array_counter_read(GET_ARC(&mem->stat), MEMCG_STAT_RSS);
+	ret += array_counter_read(GET_ARC(&mem->stat), MEMCG_STAT_CACHE);
+	return ret;
 }
 
 static unsigned long mem_cgroup_get_local_zonestat(struct mem_cgroup *mem,
@@ -1164,7 +1111,7 @@ static int mem_cgroup_hierarchical_recla
 				}
 			}
 		}
-		if (!mem_cgroup_local_usage(&victim->stat)) {
+		if (!mem_cgroup_my_usage(victim)) {
 			/* this cgroup's local usage == 0 */
 			css_put(&victim->css);
 			continue;
@@ -1230,9 +1177,6 @@ static void record_last_oom(struct mem_c
 void mem_cgroup_update_mapped_file_stat(struct page *page, int val)
 {
 	struct mem_cgroup *mem;
-	struct mem_cgroup_stat *stat;
-	struct mem_cgroup_stat_cpu *cpustat;
-	int cpu;
 	struct page_cgroup *pc;
 
 	if (!page_is_file_cache(page))
@@ -1250,14 +1194,7 @@ void mem_cgroup_update_mapped_file_stat(
 	if (!PageCgroupUsed(pc))
 		goto done;
 
-	/*
-	 * Preemption is already disabled, we don't need get_cpu()
-	 */
-	cpu = smp_processor_id();
-	stat = &mem->stat;
-	cpustat = &stat->cpustat[cpu];
-
-	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE, val);
+	array_counter_add(GET_ARC(&mem->stat), MEMCG_STAT_MAPPED_FILE, val);
 done:
 	unlock_page_cgroup(pc);
 }
@@ -1598,9 +1535,6 @@ static int mem_cgroup_move_account(struc
 	int nid, zid;
 	int ret = -EBUSY;
 	struct page *page;
-	int cpu;
-	struct mem_cgroup_stat *stat;
-	struct mem_cgroup_stat_cpu *cpustat;
 
 	VM_BUG_ON(from == to);
 	VM_BUG_ON(PageLRU(pc->page));
@@ -1625,18 +1559,10 @@ static int mem_cgroup_move_account(struc
 
 	page = pc->page;
 	if (page_is_file_cache(page) && page_mapped(page)) {
-		cpu = smp_processor_id();
 		/* Update mapped_file data for mem_cgroup "from" */
-		stat = &from->stat;
-		cpustat = &stat->cpustat[cpu];
-		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE,
-						-1);
-
+		array_counter_dec(GET_ARC(&from->stat), MEMCG_STAT_MAPPED_FILE);
 		/* Update mapped_file data for mem_cgroup "to" */
-		stat = &to->stat;
-		cpustat = &stat->cpustat[cpu];
-		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE,
-						1);
+		array_counter_inc(GET_ARC(&to->stat), MEMCG_STAT_MAPPED_FILE);
 	}
 
 	if (do_swap_account && !mem_cgroup_is_root(from))
@@ -2687,7 +2613,7 @@ static int
 mem_cgroup_get_idx_stat(struct mem_cgroup *mem, void *data)
 {
 	struct mem_cgroup_idx_data *d = data;
-	d->val += mem_cgroup_read_stat(&mem->stat, d->idx);
+	d->val += array_counter_read(GET_ARC(&mem->stat), d->idx);
 	return 0;
 }
 
@@ -2714,10 +2640,10 @@ static u64 mem_cgroup_read(struct cgroup
 	case _MEM:
 		if (name == RES_USAGE && mem_cgroup_is_root(mem)) {
 			mem_cgroup_get_recursive_idx_stat(mem,
-				MEM_CGROUP_STAT_CACHE, &idx_val);
+				MEMCG_STAT_CACHE, &idx_val);
 			val = idx_val;
 			mem_cgroup_get_recursive_idx_stat(mem,
-				MEM_CGROUP_STAT_RSS, &idx_val);
+				MEMCG_STAT_RSS, &idx_val);
 			val += idx_val;
 			val <<= PAGE_SHIFT;
 		} else
@@ -2726,13 +2652,13 @@ static u64 mem_cgroup_read(struct cgroup
 	case _MEMSWAP:
 		if (name == RES_USAGE && mem_cgroup_is_root(mem)) {
 			mem_cgroup_get_recursive_idx_stat(mem,
-				MEM_CGROUP_STAT_CACHE, &idx_val);
+				MEMCG_STAT_CACHE, &idx_val);
 			val = idx_val;
 			mem_cgroup_get_recursive_idx_stat(mem,
-				MEM_CGROUP_STAT_RSS, &idx_val);
+				MEMCG_STAT_RSS, &idx_val);
 			val += idx_val;
 			mem_cgroup_get_recursive_idx_stat(mem,
-				MEM_CGROUP_STAT_SWAPOUT, &idx_val);
+				MEMCG_STAT_SWAPOUT, &idx_val);
 			val <<= PAGE_SHIFT;
 		} else
 			val = res_counter_read_u64(&mem->memsw, name);
@@ -2892,18 +2818,19 @@ static int mem_cgroup_get_local_stat(str
 	s64 val;
 
 	/* per cpu stat */
-	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_CACHE);
+	val = array_counter_read(GET_ARC(&mem->stat), MEMCG_STAT_CACHE);
 	s->stat[MCS_CACHE] += val * PAGE_SIZE;
-	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
+	val = array_counter_read(GET_ARC(&mem->stat), MEMCG_STAT_RSS);
 	s->stat[MCS_RSS] += val * PAGE_SIZE;
-	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_MAPPED_FILE);
+	val = array_counter_read(GET_ARC(&mem->stat), MEMCG_STAT_MAPPED_FILE);
 	s->stat[MCS_MAPPED_FILE] += val * PAGE_SIZE;
-	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_PGPGIN_COUNT);
+	val = array_counter_read(GET_ARC(&mem->stat), MEMCG_STAT_PGPGIN);
 	s->stat[MCS_PGPGIN] += val;
-	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_PGPGOUT_COUNT);
+	val = array_counter_read(GET_ARC(&mem->stat), MEMCG_STAT_PGPGOUT);
 	s->stat[MCS_PGPGOUT] += val;
 	if (do_swap_account) {
-		val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_SWAPOUT);
+		val = array_counter_read(GET_ARC(&mem->stat),
+			MEMCG_STAT_SWAPOUT);
 		s->stat[MCS_SWAP] += val * PAGE_SIZE;
 	}
 
@@ -3162,16 +3089,10 @@ static void free_mem_cgroup_per_zone_inf
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
 
 	if (size < PAGE_SIZE)
 		mem = kmalloc(size, GFP_KERNEL);
@@ -3180,6 +3101,17 @@ static struct mem_cgroup *mem_cgroup_all
 
 	if (mem)
 		memset(mem, 0, size);
+	if (!mem)
+		return NULL;
+
+	if (array_counter_init(GET_ARC(&mem->stat), MEMCG_STAT_NSTATS)) {
+		/* can't allocate percpu counter */
+		if (size < PAGE_SIZE)
+			kfree(mem);
+		else
+			vfree(mem);
+		mem = NULL;
+	}
 	return mem;
 }
 
@@ -3204,7 +3136,9 @@ static void __mem_cgroup_free(struct mem
 	for_each_node_state(node, N_POSSIBLE)
 		free_mem_cgroup_per_zone_info(mem, node);
 
-	if (mem_cgroup_size() < PAGE_SIZE)
+	array_counter_destroy(GET_ARC(&mem->stat));
+
+	if (sizeof(*mem) < PAGE_SIZE)
 		kfree(mem);
 	else
 		vfree(mem);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
