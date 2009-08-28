Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 014A76B008A
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 00:30:05 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7S4U1gs013189
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 28 Aug 2009 13:30:01 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C4BA45DE4E
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 13:30:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 071E645DE4D
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 13:30:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DE2411DB803C
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 13:30:00 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 897381DB8038
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 13:30:00 +0900 (JST)
Date: Fri, 28 Aug 2009 13:28:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 5/5] memcg: drain per cpu stock
Message-Id: <20090828132809.ad7cfebc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>


Add function for dropping per-cpu stock of charges.
This is called when
	- cpu is unplugged.
	- force_empty
	- recalim seems to be not easy.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   71 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 70 insertions(+), 1 deletion(-)

Index: mmotm-2.6.31-Aug27/mm/memcontrol.c
===================================================================
--- mmotm-2.6.31-Aug27.orig/mm/memcontrol.c
+++ mmotm-2.6.31-Aug27/mm/memcontrol.c
@@ -38,6 +38,8 @@
 #include <linux/vmalloc.h>
 #include <linux/mm_inline.h>
 #include <linux/page_cgroup.h>
+#include <linux/notifier.h>
+#include <linux/cpu.h>
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -77,6 +79,8 @@ enum mem_cgroup_stat_index {
 
 struct mem_cgroup_stat_cpu {
 	s64 count[MEM_CGROUP_STAT_NSTATS];
+	struct work_struct work;
+	struct mem_cgroup *mem;
 } ____cacheline_aligned_in_smp;
 
 struct mem_cgroup_stat {
@@ -277,6 +281,7 @@ enum charge_type {
 static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
+static void schedule_drain_stock_all(struct mem_cgroup *mem, bool sync);
 
 static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
@@ -1195,6 +1200,9 @@ static int mem_cgroup_hierarchical_recla
 				return total;
 		} else if (mem_cgroup_check_under_limit(root_mem))
 			return 1 + total;
+
+		if (loop > 0)
+			schedule_drain_stock_all(victim, false);
 	}
 	return total;
 }
@@ -1292,6 +1300,48 @@ void do_local_stock(struct mem_cgroup *m
 	put_cpu();
 }
 
+/* called by cpu hotplug and workqueue */
+int force_drain_local_stock(struct mem_cgroup *mem, void *data)
+{
+	struct mem_cgroup_stat_cpu *cstat;
+	int cpu = *(unsigned long *)data;
+	unsigned long stock;
+
+	cstat = &mem->stat.cpustat[cpu];
+	stock = cstat->count[MEM_CGROUP_STAT_STOCK];
+	cstat->count[MEM_CGROUP_STAT_STOCK] = 0;
+	res_counter_uncharge(&mem->res, stock);
+	return 0;
+}
+
+
+void drain_local_stock(struct work_struct *work)
+{
+	struct mem_cgroup_stat_cpu *cstat;
+	struct mem_cgroup *mem;
+	unsigned long cpu;
+
+	cpu = get_cpu();
+	cstat = container_of(work, struct mem_cgroup_stat_cpu, work);
+	mem = cstat->mem;
+	force_drain_local_stock(mem, &cpu);
+	put_cpu();
+}
+
+
+void schedule_drain_stock_all(struct mem_cgroup *mem, bool sync)
+{
+	struct mem_cgroup_stat_cpu *cstat;
+	int cpu;
+
+	for_each_online_cpu(cpu) {
+		cstat = &mem->stat.cpustat[cpu];
+		schedule_work_on(cpu, &cstat->work);
+		if (sync)
+			flush_work(&cstat->work);
+	}
+}
+
 /*
  * Unlike exported interface, "oom" parameter is added. if oom==true,
  * oom-killer can be invoked.
@@ -2471,6 +2521,7 @@ move_account:
 		if (signal_pending(current))
 			goto out;
 		/* This is for making all *used* pages to be on LRU. */
+		schedule_drain_stock_all(mem, true);
 		lru_add_drain_all();
 		ret = 0;
 		for_each_node_state(node, N_HIGH_MEMORY) {
@@ -3081,6 +3132,7 @@ static struct mem_cgroup *mem_cgroup_all
 {
 	struct mem_cgroup *mem;
 	int size = mem_cgroup_size();
+	int i;
 
 	if (size < PAGE_SIZE)
 		mem = kmalloc(size, GFP_KERNEL);
@@ -3089,9 +3141,26 @@ static struct mem_cgroup *mem_cgroup_all
 
 	if (mem)
 		memset(mem, 0, size);
+	for (i = 0; i < nr_cpu_ids; i++)
+		INIT_WORK(&mem->stat.cpustat[i].work, drain_local_stock);
+
 	return mem;
 }
 
+static int __cpuinit percpu_memcg_hotcpu_callback(struct notifier_block *nb,
+		unsigned long  action, void *hcpu)
+{
+#ifdef CONFIG_HOTPLUG_CPU
+	if (action != CPU_DEAD)
+		return NOTIFY_OK;
+	if (!root_mem_cgroup)
+		return NOTIFY_OK;
+	mem_cgroup_walk_tree(root_mem_cgroup, hcpu, force_drain_local_stock);
+#endif
+	return NOTIFY_OK;
+}
+
+
 /*
  * At destroying mem_cgroup, references from swap_cgroup can remain.
  * (scanning all at force_empty is too costly...)
@@ -3203,7 +3272,7 @@ mem_cgroup_create(struct cgroup_subsys *
 		root_mem_cgroup = mem;
 		if (mem_cgroup_soft_limit_tree_init())
 			goto free_out;
-
+		hotcpu_notifier(percpu_memcg_hotcpu_callback, 0);
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
 		mem->use_hierarchy = parent->use_hierarchy;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
