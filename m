Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E6C0B5F0047
	for <linux-mm@kvack.org>; Fri, 15 Oct 2010 17:17:33 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v2 08/11] memcg: CPU hotplug lockdep warning fix
Date: Fri, 15 Oct 2010 14:14:36 -0700
Message-Id: <1287177279-30876-9-git-send-email-gthelen@google.com>
In-Reply-To: <1287177279-30876-1-git-send-email-gthelen@google.com>
References: <1287177279-30876-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

From: Balbir Singh <balbir@linux.vnet.ibm.com>

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
do_page_fault+0x27d/0x4a0
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

Acked-by: Greg Thelen <gthelen@google.com>
Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---
 mm/memcontrol.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index eef25fe..1e4c9d2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -588,7 +588,6 @@ static s64 mem_cgroup_read_stat(struct mem_cgroup *mem,
 	int cpu;
 	s64 val = 0;
 
-	get_online_cpus();
 	for_each_online_cpu(cpu)
 		val += per_cpu(mem->stat->count[idx], cpu);
 #ifdef CONFIG_HOTPLUG_CPU
@@ -596,7 +595,6 @@ static s64 mem_cgroup_read_stat(struct mem_cgroup *mem,
 	val += mem->nocpu_base.count[idx];
 	spin_unlock(&mem->pcp_counter_lock);
 #endif
-	put_online_cpus();
 	return val;
 }
 
@@ -1300,6 +1298,7 @@ s64 mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item item)
 	struct mem_cgroup *iter;
 	s64 value;
 
+	get_online_cpus();
 	rcu_read_lock();
 	mem = mem_cgroup_from_task(current);
 	if (mem && !mem_cgroup_is_root(mem)) {
@@ -1321,6 +1320,7 @@ s64 mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item item)
 	} else
 		value = -EINVAL;
 	rcu_read_unlock();
+	put_online_cpus();
 
 	return value;
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
