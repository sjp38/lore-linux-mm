Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7A70C6B0098
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 04:26:29 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8P8QamB016172
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 25 Sep 2009 17:26:36 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 139F145DE50
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:26:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E04E045DE4F
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:26:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B9D3DE38002
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:26:35 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 52508E08003
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:26:35 +0900 (JST)
Date: Fri, 25 Sep 2009 17:24:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 5/10] memcg: clean up percpu statistics access
Message-Id: <20090925172428.8403aac1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Cleanup.
There are several places which updates percpu counter of memcg.

In old age, there were only mem_cgroup_charge_statistics() and
we used a bare access as
   get_cpu()
   cpustat == mem_cgroup->stat.cpustat[cpu];
   update cpu stat
   put_cpu()

But we added several callers of above codes...it seems not clean. This patch
adds
  mem_cgroup_stat_read_pcpu()
  mem_cgroup_stat_add_pcpu()
and renames
  mem_cgroup_local_usage() to be mem_cgroup_usage()
because "local" here is ambiguous.
(I used "local" for meaning "no hierarchy consideration" but..)

and this changes mem_cgroup_read_stat()'s argument from
struct mem_cgroup_stat * to struct mem_cgroup *

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  126 ++++++++++++++++++++++++++++++--------------------------
 1 file changed, 68 insertions(+), 58 deletions(-)

Index: temp-mmotm/mm/memcontrol.c
===================================================================
--- temp-mmotm.orig/mm/memcontrol.c
+++ temp-mmotm/mm/memcontrol.c
@@ -314,22 +314,41 @@ static struct mem_cgroup *mem_cgroup_loo
 
 /*
  * Handlers for memcg's private percpu counters.
+ * percpu conter is used for memcg's local (means ignoring hierarchy) statitics.
+ * And an event counter is also maintained. Updates to all field should be
+ * under preemption disabled.
  */
 
-static inline void
-__mem_cgroup_stat_reset_safe(struct mem_cgroup_stat_cpu *stat,
+static inline void mem_cgroup_stat_reset_pcpu(struct mem_cgroup *mem,
 				enum mem_cgroup_stat_index idx)
 {
-	stat->count[idx] = 0;
+	struct mem_cgroup_stat_cpu *cstat;
+	int cpu = get_cpu();
+
+	cstat = &mem->stat.cpustat[cpu];
+	cstat->count[idx] = 0;
+	put_cpu();
 }
 
-static inline s64
-__mem_cgroup_stat_read_local(struct mem_cgroup_stat_cpu *stat,
+static inline s64 __mem_cgroup_stat_read_safe(struct mem_cgroup_stat_cpu *stat,
 				enum mem_cgroup_stat_index idx)
 {
 	return stat->count[idx];
 }
 
+static inline s64 mem_cgroup_stat_read_pcpu(struct mem_cgroup *mem,
+				enum mem_cgroup_stat_index idx)
+{
+	struct mem_cgroup_stat_cpu *cstat;
+	int cpu = get_cpu();
+	s64 ret;
+
+	cstat = &mem->stat.cpustat[cpu];
+	ret = __mem_cgroup_stat_read_safe(cstat, idx);
+	put_cpu();
+	return ret;
+}
+
 /*
  * For accounting under irq disable, no need for increment preempt count.
  */
@@ -339,13 +358,24 @@ static inline void __mem_cgroup_stat_add
 	stat->count[idx] += val;
 }
 
-static s64 mem_cgroup_read_stat(struct mem_cgroup_stat *stat,
+static inline void mem_cgroup_stat_add_pcpu(struct mem_cgroup *mem,
+		enum mem_cgroup_stat_index idx, int val)
+{
+	struct mem_cgroup_stat_cpu *cstat;
+	int cpu = get_cpu();
+
+	cstat = &mem->stat.cpustat[cpu];
+	__mem_cgroup_stat_add_safe(cstat, idx, val);
+	put_cpu();
+}
+
+static s64 mem_cgroup_read_stat(struct mem_cgroup *mem,
 		enum mem_cgroup_stat_index idx)
 {
 	int cpu;
 	s64 ret = 0;
 	for_each_possible_cpu(cpu)
-		ret += stat->cpustat[cpu].count[idx];
+		ret += mem->stat.cpustat[cpu].count[idx];
 	return ret;
 }
 
@@ -353,25 +383,22 @@ static void mem_cgroup_swap_statistics(s
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
+	mem_cgroup_stat_add_pcpu(mem, MEM_CGROUP_STAT_SWAPOUT, val);
 }
 
+/*
+ * We updates several coutners at once. Do all under a get_cpu/put_cpu
+ * calls.
+ */
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
 					 struct page_cgroup *pc,
 					 bool charge)
 {
 	int val = (charge) ? 1 : -1;
-	struct mem_cgroup_stat *stat = &mem->stat;
 	struct mem_cgroup_stat_cpu *cpustat;
 	int cpu = get_cpu();
 
-	cpustat = &stat->cpustat[cpu];
+	cpustat = &mem->stat.cpustat[cpu];
 	if (PageCgroupCache(pc))
 		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_CACHE, val);
 	else
@@ -387,12 +414,17 @@ static void mem_cgroup_charge_statistics
 	put_cpu();
 }
 
-static s64 mem_cgroup_local_usage(struct mem_cgroup_stat *stat)
+/*
+ * When mem_cgroup is used with hierarchy inheritance enabled, cgroup local
+ * memory usage is just shown by sum of percpu statitics. This function returns
+ * cgroup local memory usage even if it's under hierarchy.
+ */
+static s64 mem_cgroup_usage(struct mem_cgroup *mem)
 {
 	s64 ret;
 
-	ret = mem_cgroup_read_stat(stat, MEM_CGROUP_STAT_CACHE);
-	ret += mem_cgroup_read_stat(stat, MEM_CGROUP_STAT_RSS);
+	ret = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_CACHE);
+	ret += mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_RSS);
 	return ret;
 }
 
@@ -403,9 +435,6 @@ static s64 mem_cgroup_local_usage(struct
 void mem_cgroup_update_mapped_file_stat(struct page *page, int val)
 {
 	struct mem_cgroup *mem;
-	struct mem_cgroup_stat *stat;
-	struct mem_cgroup_stat_cpu *cpustat;
-	int cpu;
 	struct page_cgroup *pc;
 
 	if (!page_is_file_cache(page))
@@ -423,14 +452,7 @@ void mem_cgroup_update_mapped_file_stat(
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
+	mem_cgroup_stat_add_pcpu(mem, MEM_CGROUP_STAT_MAPPED_FILE, val);
 done:
 	unlock_page_cgroup(pc);
 }
@@ -557,18 +579,13 @@ mem_cgroup_remove_exceeded(struct mem_cg
 static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
 {
 	bool ret = false;
-	int cpu;
 	s64 val;
-	struct mem_cgroup_stat_cpu *cpustat;
 
-	cpu = get_cpu();
-	cpustat = &mem->stat.cpustat[cpu];
-	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_EVENTS);
+	val = mem_cgroup_stat_read_pcpu(mem, MEM_CGROUP_STAT_EVENTS);
 	if (unlikely(val > SOFTLIMIT_EVENTS_THRESH)) {
-		__mem_cgroup_stat_reset_safe(cpustat, MEM_CGROUP_STAT_EVENTS);
+		mem_cgroup_stat_reset_pcpu(mem, MEM_CGROUP_STAT_EVENTS);
 		ret = true;
 	}
-	put_cpu();
 	return ret;
 }
 
@@ -1265,7 +1282,11 @@ static int mem_cgroup_hierarchical_recla
 				}
 			}
 		}
-		if (!mem_cgroup_local_usage(&victim->stat)) {
+		/*
+		 * mem->res can includes memory usage of children. We have to
+		 * check memory usage of this victim.
+		 */
+		if (!mem_cgroup_usage(victim)) {
 			/* this cgroup's local usage == 0 */
 			css_put(&victim->css);
 			continue;
@@ -2092,9 +2113,6 @@ static int mem_cgroup_move_account(struc
 	int nid, zid;
 	int ret = -EBUSY;
 	struct page *page;
-	int cpu;
-	struct mem_cgroup_stat *stat;
-	struct mem_cgroup_stat_cpu *cpustat;
 
 	VM_BUG_ON(from == to);
 	VM_BUG_ON(PageLRU(pc->page));
@@ -2119,18 +2137,10 @@ static int mem_cgroup_move_account(struc
 
 	page = pc->page;
 	if (page_is_file_cache(page) && page_mapped(page)) {
-		cpu = smp_processor_id();
 		/* Update mapped_file data for mem_cgroup "from" */
-		stat = &from->stat;
-		cpustat = &stat->cpustat[cpu];
-		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE,
-						-1);
-
+		mem_cgroup_stat_add_pcpu(from, MEM_CGROUP_STAT_MAPPED_FILE, -1);
 		/* Update mapped_file data for mem_cgroup "to" */
-		stat = &to->stat;
-		cpustat = &stat->cpustat[cpu];
-		__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE,
-						1);
+		mem_cgroup_stat_add_pcpu(to, MEM_CGROUP_STAT_MAPPED_FILE, 1);
 	}
 
 	if (do_swap_account && !mem_cgroup_is_root(from))
@@ -2557,7 +2567,7 @@ static int
 mem_cgroup_get_idx_stat(struct mem_cgroup *mem, void *data)
 {
 	struct mem_cgroup_idx_data *d = data;
-	d->val += mem_cgroup_read_stat(&mem->stat, d->idx);
+	d->val += mem_cgroup_read_stat(mem, d->idx);
 	return 0;
 }
 
@@ -2763,18 +2773,18 @@ static int mem_cgroup_get_local_stat(str
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
