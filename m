Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 24E326B00B8
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 04:59:33 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8I8xUF0004176
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 18 Sep 2009 17:59:31 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id AA21B45DE51
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 17:59:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F78D45DE4F
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 17:59:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 29C8B1DB803A
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 17:59:30 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 91B3A1DB803F
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 17:59:29 +0900 (JST)
Date: Fri, 18 Sep 2009 17:57:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 6/11] memcg: cleaun up percpu statistics
Message-Id: <20090918175724.e40c421a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090918174757.672f1e8e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090909173903.afc86d85.kamezawa.hiroyu@jp.fujitsu.com>
	<20090918174757.672f1e8e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

mem_cgroup has per cpu statistics counter. When implemented,
the users are limited and very low level interface was enough.

But in these days, there are more users. This patch is for cleaning up them.
And adds more precise commentary.

Diff seems big but this patch includes big code moving....
This moves percpu stat access function after definition of mem_cgroup.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  224 +++++++++++++++++++++++++++++++-------------------------
 1 file changed, 125 insertions(+), 99 deletions(-)

Index: mmotm-2.6.31-Sep17/mm/memcontrol.c
===================================================================
--- mmotm-2.6.31-Sep17.orig/mm/memcontrol.c
+++ mmotm-2.6.31-Sep17/mm/memcontrol.c
@@ -59,7 +59,7 @@ static DEFINE_MUTEX(memcg_tasklist);	/* 
 #define SOFTLIMIT_EVENTS_THRESH (1000)
 
 /*
- * Statistics for memory cgroup.
+ * Statistics for memory cgroup. accounted per cpu.
  */
 enum mem_cgroup_stat_index {
 	/*
@@ -84,48 +84,6 @@ struct mem_cgroup_stat {
 	struct mem_cgroup_stat_cpu cpustat[0];
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
-	ret = mem_cgroup_read_stat(stat, MEM_CGROUP_STAT_CACHE);
-	ret += mem_cgroup_read_stat(stat, MEM_CGROUP_STAT_RSS);
-	return ret;
-}
-
 /*
  * per-zone information in memory controller.
  */
@@ -278,6 +236,101 @@ static void mem_cgroup_put(struct mem_cg
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
 static void drain_all_stock_async(void);
 
+/*
+ * Functions for acceccing cpu local statistics. modification should be
+ * done under preempt disabled. __mem_cgroup_xxx functions are for low level.
+ */
+static inline void
+__mem_cgroup_stat_reset_local(struct mem_cgroup_stat_cpu *stat,
+				enum mem_cgroup_stat_index idx)
+{
+	stat->count[idx] = 0;
+}
+
+static inline void
+mem_cgroup_stat_reset_local(struct mem_cgroup *mem,
+			enum mem_cgroup_stat_index idx)
+{
+	struct mem_cgroup_stat *stat = &mem->stat;
+	struct mem_cgroup_stat_cpu *cstat;
+	int cpu = get_cpu();
+
+	cstat = &stat->cpustat[cpu];
+	__mem_cgroup_stat_reset_local(cstat, idx);
+	put_cpu();
+}
+
+static inline s64
+__mem_cgroup_stat_read_local(struct mem_cgroup_stat_cpu *stat,
+				enum mem_cgroup_stat_index idx)
+{
+	return stat->count[idx];
+}
+
+static inline s64
+mem_cgroup_stat_read_local(struct mem_cgroup *mem,
+			enum mem_cgroup_stat_index idx)
+{
+	struct mem_cgroup_stat *stat = &mem->stat;
+	struct mem_cgroup_stat_cpu *cstat;
+	int cpu = get_cpu();
+	s64 val;
+
+	cstat = &stat->cpustat[cpu];
+	val = __mem_cgroup_stat_read_local(cstat, idx);
+	put_cpu();
+	return val;
+}
+
+static inline void __mem_cgroup_stat_add_local(struct mem_cgroup_stat_cpu *stat,
+		enum mem_cgroup_stat_index idx, int val)
+{
+	stat->count[idx] += val;
+}
+
+static inline void
+mem_cgroup_stat_add_local(struct mem_cgroup *mem,
+		enum mem_cgroup_stat_index idx, int val)
+{
+	struct mem_cgroup_stat *stat = &mem->stat;
+	struct mem_cgroup_stat_cpu *cstat;
+	int cpu = get_cpu();
+
+	cstat = &stat->cpustat[cpu];
+	__mem_cgroup_stat_add_local(cstat, idx, val);
+	put_cpu();
+}
+
+/*
+ * A function for reading sum of all percpu statistics.
+ * Will be slow on big machines.
+ */
+static s64 mem_cgroup_read_stat(struct mem_cgroup *mem,
+		enum mem_cgroup_stat_index idx)
+{
+	int cpu;
+	s64 ret = 0;
+	struct mem_cgroup_stat *stat = &mem->stat;
+
+	for_each_possible_cpu(cpu)
+		ret += stat->cpustat[cpu].count[idx];
+	return ret;
+}
+/*
+ * When mem_cgroup is used with hierarchy inheritance enabled, cgroup local
+ * memory usage is just shown by sum of percpu statitics. This function returns
+ * cgroup local memory usage even if it's under hierarchy.
+ */
+static s64 mem_cgroup_local_usage(struct mem_cgroup *mem)
+{
+	s64 ret;
+
+	ret = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_CACHE);
+	ret += mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_RSS);
+	return ret;
+}
+
+
 static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
 {
@@ -370,18 +423,13 @@ mem_cgroup_remove_exceeded(struct mem_cg
 static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
 {
 	bool ret = false;
-	int cpu;
 	s64 val;
-	struct mem_cgroup_stat_cpu *cpustat;
 
-	cpu = get_cpu();
-	cpustat = &mem->stat.cpustat[cpu];
-	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_EVENTS);
+	val = mem_cgroup_stat_read_local(mem, MEM_CGROUP_STAT_EVENTS);
 	if (unlikely(val > SOFTLIMIT_EVENTS_THRESH)) {
-		__mem_cgroup_stat_reset_safe(cpustat, MEM_CGROUP_STAT_EVENTS);
+		mem_cgroup_stat_reset_local(mem, MEM_CGROUP_STAT_EVENTS);
 		ret = true;
 	}
-	put_cpu();
 	return ret;
 }
 
@@ -480,13 +528,7 @@ static void mem_cgroup_swap_statistics(s
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
+	mem_cgroup_stat_add_local(mem, MEM_CGROUP_STAT_SWAPOUT, val);
 }
 
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
@@ -495,22 +537,22 @@ static void mem_cgroup_charge_statistics
 {
 	int val = (charge) ? 1 : -1;
 	struct mem_cgroup_stat *stat = &mem->stat;
-	struct mem_cgroup_stat_cpu *cpustat;
+	struct mem_cgroup_stat_cpu *cstat;
 	int cpu = get_cpu();
-
-	cpustat = &stat->cpustat[cpu];
+	/* for fast access, we use open-coded manner */
+	cstat = &stat->cpustat[cpu];
 	if (PageCgroupCache(pc))
-		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_CACHE, val);
+		__mem_cgroup_stat_add_local(cstat, MEM_CGROUP_STAT_CACHE, val);
 	else
-		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_RSS, val);
+		__mem_cgroup_stat_add_local(cstat, MEM_CGROUP_STAT_RSS, val);
 
 	if (charge)
-		__mem_cgroup_stat_add_safe(cpustat,
+		__mem_cgroup_stat_add_local(cstat,
 				MEM_CGROUP_STAT_PGPGIN_COUNT, 1);
 	else
-		__mem_cgroup_stat_add_safe(cpustat,
+		__mem_cgroup_stat_add_local(cstat,
 				MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
-	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_EVENTS, 1);
+	__mem_cgroup_stat_add_local(cstat, MEM_CGROUP_STAT_EVENTS, 1);
 	put_cpu();
 }
 
@@ -1163,7 +1205,11 @@ static int mem_cgroup_hierarchical_recla
 				}
 			}
 		}
-		if (!mem_cgroup_local_usage(&victim->stat)) {
+		/*
+		 * mem->res can includes children cgroup's memory usage.What
+		 * we need to check here is local usage.
+		 */
+		if (!mem_cgroup_local_usage(victim)) {
 			/* this cgroup's local usage == 0 */
 			css_put(&victim->css);
 			continue;
@@ -1229,9 +1275,6 @@ static void record_last_oom(struct mem_c
 void mem_cgroup_update_mapped_file_stat(struct page *page, int val)
 {
 	struct mem_cgroup *mem;
-	struct mem_cgroup_stat *stat;
-	struct mem_cgroup_stat_cpu *cpustat;
-	int cpu;
 	struct page_cgroup *pc;
 
 	if (!page_is_file_cache(page))
@@ -1249,14 +1292,7 @@ void mem_cgroup_update_mapped_file_stat(
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
+	mem_cgroup_stat_add_local(mem, MEM_CGROUP_STAT_MAPPED_FILE, val);
 done:
 	unlock_page_cgroup(pc);
 }
@@ -1607,9 +1643,6 @@ static int mem_cgroup_move_account(struc
 	int nid, zid;
 	int ret = -EBUSY;
 	struct page *page;
-	int cpu;
-	struct mem_cgroup_stat *stat;
-	struct mem_cgroup_stat_cpu *cpustat;
 
 	VM_BUG_ON(from == to);
 	VM_BUG_ON(PageLRU(pc->page));
@@ -1634,18 +1667,11 @@ static int mem_cgroup_move_account(struc
 
 	page = pc->page;
 	if (page_is_file_cache(page) && page_mapped(page)) {
-		cpu = smp_processor_id();
-		/* Update mapped_file data for mem_cgroup "from" */
-		stat = &from->stat;
-		cpustat = &stat->cpustat[cpu];
-		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE,
-						-1);
-
-		/* Update mapped_file data for mem_cgroup "to" */
-		stat = &to->stat;
-		cpustat = &stat->cpustat[cpu];
-		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE,
-						1);
+		/* decrement mapped_file data for mem_cgroup "from" */
+		mem_cgroup_stat_add_local(from,
+				MEM_CGROUP_STAT_MAPPED_FILE, -1);
+		/* increment mapped_file data for mem_cgroup "to" */
+		mem_cgroup_stat_add_local(to, MEM_CGROUP_STAT_MAPPED_FILE, 1);
 	}
 
 	if (do_swap_account && !mem_cgroup_is_root(from))
@@ -2685,7 +2711,7 @@ static int
 mem_cgroup_get_idx_stat(struct mem_cgroup *mem, void *data)
 {
 	struct mem_cgroup_idx_data *d = data;
-	d->val += mem_cgroup_read_stat(&mem->stat, d->idx);
+	d->val += mem_cgroup_read_stat(mem, d->idx);
 	return 0;
 }
 
@@ -2890,18 +2916,18 @@ static int mem_cgroup_get_local_stat(str
 	s64 val;
 
 	/* per cpu stat */
-	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_CACHE);
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_CACHE);
 	s->stat[MCS_CACHE] += val * PAGE_SIZE;
-	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_RSS);
 	s->stat[MCS_RSS] += val * PAGE_SIZE;
-	val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_MAPPED_FILE);
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_MAPPED_FILE);
 	s->stat[MCS_MAPPED_FILE] += val * PAGE_SIZE;
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
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
