Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EEFD96B007D
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 00:40:12 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o145eAME031615
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 4 Feb 2010 14:40:10 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 48B3745DE52
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 14:40:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DFB345DE4F
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 14:40:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DEDC21DB8046
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 14:40:09 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 66BAF1DB8049
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 14:40:09 +0900 (JST)
Date: Thu, 4 Feb 2010 14:36:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: use for each online for making sum of percpu counter
Message-Id: <20100204143645.87b5fc28.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Tested on mmotm-2010-02-03.

Balbir-san, how about this patch ? It seems not so difficult as expected.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

memcg-use-for-each-online-cpus-for-making-sum-of-percpu-counter

Now, memcg's percpu coutner uses for_each_possible_cpus() for
handling cpu hotplug. But it adds some overhead on a server
which has an additonal cpu hotplug slot which is not used.

This patch adds cpu hotplug callback for memcg's percpu counter
and make use of for_each_online_cpu().

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   35 ++++++++++++++++++++++++++++++++---
 1 file changed, 32 insertions(+), 3 deletions(-)

Index: mmotm-2.6.33-Feb3/mm/memcontrol.c
===================================================================
--- mmotm-2.6.33-Feb3.orig/mm/memcontrol.c
+++ mmotm-2.6.33-Feb3/mm/memcontrol.c
@@ -223,6 +223,8 @@ struct mem_cgroup {
 	 */
 	unsigned long 	move_charge_at_immigrate;
 
+	/* list of all memcgs. currently used for cpu hotplug+percpu counter */
+	struct list_head list;
 	/*
 	 * percpu counter.
 	 */
@@ -504,7 +506,7 @@ static s64 mem_cgroup_read_stat(struct m
 	int cpu;
 	s64 val = 0;
 
-	for_each_possible_cpu(cpu)
+	for_each_online_cpu(cpu)
 		val += per_cpu(mem->stat->count[idx], cpu);
 	return val;
 }
@@ -1405,17 +1407,37 @@ static void drain_all_stock_sync(void)
 	atomic_dec(&memcg_drain_count);
 }
 
-static int __cpuinit memcg_stock_cpu_callback(struct notifier_block *nb,
+DEFINE_MUTEX(memcg_hotcpu_lock);
+LIST_HEAD(memcg_hotcpu_list);
+
+static int __cpuinit memcg_cpu_unplug_callback(struct notifier_block *nb,
 					unsigned long action,
 					void *hcpu)
 {
 	int cpu = (unsigned long)hcpu;
+	struct mem_cgroup *memcg;
 	struct memcg_stock_pcp *stock;
+	int idx;
+	s64 val;
 
 	if (action != CPU_DEAD)
 		return NOTIFY_OK;
 	stock = &per_cpu(memcg_stock, cpu);
 	drain_stock(stock);
+
+	/* Move dead percpu counter's value to online cpu */
+	mutex_lock(&memcg_hotcpu_lock);
+	list_for_each_entry(memcg, &memcg_hotcpu_list, list) {
+		for (idx = MEM_CGROUP_STAT_CACHE;
+		     idx <= MEM_CGROUP_STAT_SWAPOUT;
+		     idx++) {
+			val = per_cpu(memcg->stat->count[idx], cpu);
+			per_cpu(memcg->stat->count[idx], cpu) = 0;
+			this_cpu_add(memcg->stat->count[idx], val);
+		}
+	}
+	mutex_unlock(&memcg_hotcpu_lock);
+
 	return NOTIFY_OK;
 }
 
@@ -3626,6 +3648,10 @@ static struct mem_cgroup *mem_cgroup_all
 		else
 			vfree(mem);
 		mem = NULL;
+	} else {
+		mutex_lock(&memcg_hotcpu_lock);
+		list_add(&mem->list, &memcg_hotcpu_list);
+		mutex_unlock(&memcg_hotcpu_lock);
 	}
 	return mem;
 }
@@ -3651,6 +3677,9 @@ static void __mem_cgroup_free(struct mem
 	for_each_node_state(node, N_POSSIBLE)
 		free_mem_cgroup_per_zone_info(mem, node);
 
+	mutex_lock(&memcg_hotcpu_lock);
+	list_del(&mem->list);
+	mutex_unlock(&memcg_hotcpu_lock);
 	free_percpu(mem->stat);
 	if (sizeof(struct mem_cgroup) < PAGE_SIZE)
 		kfree(mem);
@@ -3753,7 +3782,7 @@ mem_cgroup_create(struct cgroup_subsys *
 						&per_cpu(memcg_stock, cpu);
 			INIT_WORK(&stock->work, drain_local_stock);
 		}
-		hotcpu_notifier(memcg_stock_cpu_callback, 0);
+		hotcpu_notifier(memcg_cpu_unplug_callback, 0);
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
 		mem->use_hierarchy = parent->use_hierarchy;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
