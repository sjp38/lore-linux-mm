Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 106546B004A
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 05:41:55 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8L9frQd010252
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Sep 2010 18:41:53 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B26345DE56
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 18:41:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CE13F45DE4F
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 18:41:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AEE98E08002
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 18:41:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 582AAE18001
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 18:41:52 +0900 (JST)
Date: Tue, 21 Sep 2010 18:36:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v2 3/3][-mm] memcg: cpu hotplug aware quick acount_move
 detection
Message-Id: <20100921183647.9c3f538f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100921183127.1c4c2bc1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100921183127.1c4c2bc1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

An event counter MEM_CGROUP_ON_MOVE is used for quick check whether
file stat update can be done in async manner or not. Now, it use
percpu counter and for_each_possible_cpu to update.

This patch replaces for_each_possible_cpu to for_each_online_cpu
and adds necessary synchronization logic at CPU HOTPLUG.

Changelog:
 - make use of cpu independent "core" value to synchronize.
 - replaces mc.lock with pcp_coutner_lock.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   37 ++++++++++++++++++++++++++++++-------
 1 file changed, 30 insertions(+), 7 deletions(-)

Index: mmotm-0915/mm/memcontrol.c
===================================================================
--- mmotm-0915.orig/mm/memcontrol.c
+++ mmotm-0915/mm/memcontrol.c
@@ -1116,11 +1116,14 @@ static unsigned int get_swappiness(struc
 static void mem_cgroup_start_move(struct mem_cgroup *mem)
 {
 	int cpu;
-	/* Because this is for moving account, reuse mc.lock */
-	spin_lock(&mc.lock);
-	for_each_possible_cpu(cpu)
+
+	get_online_cpus();
+	spin_lock(&mem->pcp_counter_lock);
+	for_each_online_cpu(cpu)
 		per_cpu(mem->stat->count[MEM_CGROUP_ON_MOVE], cpu) += 1;
-	spin_unlock(&mc.lock);
+	mem->nocpu_base.count[MEM_CGROUP_ON_MOVE] += 1;
+	spin_unlock(&mem->pcp_counter_lock);
+	put_online_cpus();
 
 	synchronize_rcu();
 }
@@ -1131,10 +1134,13 @@ static void mem_cgroup_end_move(struct m
 
 	if (!mem)
 		return;
-	spin_lock(&mc.lock);
-	for_each_possible_cpu(cpu)
+	get_online_cpus();
+	spin_lock(&mem->pcp_counter_lock);
+	for_each_online_cpu(cpu)
 		per_cpu(mem->stat->count[MEM_CGROUP_ON_MOVE], cpu) -= 1;
-	spin_unlock(&mc.lock);
+	mem->nocpu_base.count[MEM_CGROUP_ON_MOVE] -= 1;
+	spin_unlock(&mem->pcp_counter_lock);
+	put_online_cpus();
 }
 /*
  * 2 routines for checking "mem" is under move_account() or not.
@@ -1735,6 +1741,17 @@ static void mem_cgroup_drain_pcp_counter
 		per_cpu(mem->stat->count[i], cpu) = 0;
 		mem->nocpu_base.count[i] += x;
 	}
+	/* need to clear ON_MOVE value, works as a kind of lock. */
+	per_cpu(mem->stat->count[MEM_CGROUP_ON_MOVE],cpu) = 0;
+	spin_unlock(&mem->pcp_counter_lock);
+}
+
+static void synchronize_mem_cgroup_on_move(struct mem_cgroup *mem, int cpu)
+{
+	int idx = MEM_CGROUP_ON_MOVE;
+
+	spin_lock(&mem->pcp_counter_lock);
+	per_cpu(mem->stat->count[idx],cpu) = mem->nocpu_base.count[idx];
 	spin_unlock(&mem->pcp_counter_lock);
 }
 
@@ -1746,6 +1763,12 @@ static int __cpuinit memcg_cpu_hotplug_c
 	struct memcg_stock_pcp *stock;
 	struct mem_cgroup *iter;
 
+	if ((action == CPU_ONLINE)) {
+		for_each_mem_cgroup_all(iter)
+			synchronize_mem_cgroup_on_move(iter, cpu);
+		return NOTIFY_OK;
+	}
+
 	if ((action != CPU_DEAD) || action != CPU_DEAD_FROZEN)
 		return NOTIFY_OK;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
