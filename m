Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EB1DE6B0088
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 13:50:21 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o98HgOdS020441
	for <linux-mm@kvack.org>; Fri, 8 Oct 2010 11:42:24 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o98Ho1ac058484
	for <linux-mm@kvack.org>; Fri, 8 Oct 2010 11:50:02 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o98Ho16c032472
	for <linux-mm@kvack.org>; Fri, 8 Oct 2010 11:50:01 -0600
Date: Fri, 8 Oct 2010 23:19:58 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: [BUGFIX] memcg CPU hotplug lockdep warning fix
Message-ID: <20101008174958.GI5327@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


memcg has lockdep warnings (sleep inside rcu lock)

From: Balbir Singh <balbir@linux.vnet.ibm.com>

Recent move to get_online_cpus() ends up calling get_online_cpus() from
mem_cgroup_read_stat(). However mem_cgroup_read_stat() is called under rcu
lock. get_online_cpus() can sleep. The dirty limit patches expose
this BUG more readily due to their usage of mem_cgroup_page_stat()

This patch address this issue as identified by lockdep and moves the
hotplug protection to a higher layer. This might increase the time
required to hotplug, but not by much.

Warning messages

BUG: sleeping function called from invalid context at kernel/cpu.c:62
in_atomic(): 0, irqs_disabled(): 0, pid: 6325, name: pagetest
2 locks held by pagetest/6325:
#0:  (&mm->mmap_sem){......}, at: [<ffffffff815e9503>]
do_page_fault+0x27d/0x4a0
#1:  (rcu_read_lock){......}, at: [<ffffffff811124a1>]
mem_cgroup_page_stat+0x0/0x23f
Pid: 6325, comm: pagetest Not tainted 2.6.36-rc5-mm1+ #201
Call Trace:
[<ffffffff81041224>] __might_sleep+0x12d/0x131
[<ffffffff8104f4af>] get_online_cpus+0x1c/0x51
[<ffffffff8110eedb>] mem_cgroup_read_stat+0x27/0xa3
[<ffffffff811125d2>] mem_cgroup_page_stat+0x131/0x23f
[<ffffffff811124a1>] ? mem_cgroup_page_stat+0x0/0x23f
[<ffffffff810d57c3>] global_dirty_limits+0x42/0xf8
[<ffffffff810d58b3>] throttle_vm_writeout+0x3a/0xb4
[<ffffffff810dc2f8>] shrink_zone+0x3e6/0x3f8  
[<ffffffff81074a35>] ? ktime_get_ts+0xb2/0xbf 
[<ffffffff810dd1aa>] do_try_to_free_pages+0x106/0x478
[<ffffffff810dd601>] try_to_free_mem_cgroup_pages+0xe5/0x14c
[<ffffffff8110f947>] mem_cgroup_hierarchical_reclaim+0x314/0x3a2
[<ffffffff81111b31>] __mem_cgroup_try_charge+0x29b/0x593
[<ffffffff8111194a>] ? __mem_cgroup_try_charge+0xb4/0x593
[<ffffffff81071258>] ? local_clock+0x40/0x59  
[<ffffffff81009015>] ? sched_clock+0x9/0xd
[<ffffffff810710d5>] ? sched_clock_local+0x1c/0x82
[<ffffffff8111398a>] mem_cgroup_charge_common+0x4b/0x76
[<ffffffff81141469>] ? bio_add_page+0x36/0x38 
[<ffffffff81113ba9>] mem_cgroup_cache_charge+0x1f4/0x214
[<ffffffff810cd195>] add_to_page_cache_locked+0x4a/0x148
....


Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/memcontrol.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 116fecd..f4c5665 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -578,7 +578,6 @@ static s64 mem_cgroup_read_stat(struct mem_cgroup *mem,
 	int cpu;
 	s64 val = 0;
 
-	get_online_cpus();
 	for_each_online_cpu(cpu)
 		val += per_cpu(mem->stat->count[idx], cpu);
 #ifdef CONFIG_HOTPLUG_CPU
@@ -586,7 +585,6 @@ static s64 mem_cgroup_read_stat(struct mem_cgroup *mem,
 	val += mem->nocpu_base.count[idx];
 	spin_unlock(&mem->pcp_counter_lock);
 #endif
-	put_online_cpus();
 	return val;
 }
 
@@ -1284,6 +1282,7 @@ s64 mem_cgroup_page_stat(enum mem_cgroup_read_page_stat_item item)
 	struct mem_cgroup *iter;
 	s64 value;
 
+	get_online_cpus();
 	rcu_read_lock();
 	mem = mem_cgroup_from_task(current);
 	if (mem && !mem_cgroup_is_root(mem)) {
@@ -1305,6 +1304,7 @@ s64 mem_cgroup_page_stat(enum mem_cgroup_read_page_stat_item item)
 	} else
 		value = -EINVAL;
 	rcu_read_unlock();
+	put_online_cpus();
 
 	return value;
 }

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
