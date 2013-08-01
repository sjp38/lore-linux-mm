Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 457176B0032
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 07:55:52 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so1996265pbb.19
        for <linux-mm@kvack.org>; Thu, 01 Aug 2013 04:55:51 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V5 6/8] memcg: make nocpu_base available for non-hotplug
Date: Thu,  1 Aug 2013 19:55:15 +0800
Message-Id: <1375358115-10369-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1375357402-9811-1-git-send-email-handai.szj@taobao.com>
References: <1375357402-9811-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, glommer@gmail.com, gthelen@google.com, fengguang.wu@intel.com, akpm@linux-foundation.org, Sha Zhengju <handai.szj@taobao.com>, Glauber Costa <glommer@parallels.com>

From: Glauber Costa <glommer@parallels.com>

This is inspired by Glauber Costa, his 1st version:
http://www.spinics.net/lists/cgroups/msg06233.html.

We are using nocpu_base to accumulate numbers on the main counters
during cpu hotplug. In later patch we need to transfer page stats to
the root cgroup when lazily enabling memcg. Since system wide counter
is not kept per-cpu, it is hard to distribute it. So make this field
available for all usages, not only hotplug cases.

Sha Zhengju: rename nocpu_base to stats_base

Signed-off-by: Glauber Costa <glommer@parallels.com>
Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
Acked-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6c18a6d..54da686 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -303,10 +303,10 @@ struct mem_cgroup {
 	 */
 	struct mem_cgroup_stat_cpu __percpu *stat;
 	/*
-	 * used when a cpu is offlined or other synchronizations
+	 * used when first non-memcg is created or a cpu is offlined.
 	 * See mem_cgroup_read_stat().
 	 */
-	struct mem_cgroup_stat_cpu nocpu_base;
+	struct mem_cgroup_stat_cpu stats_base;
 	spinlock_t pcp_counter_lock;
 
 	atomic_t	dead_count;
@@ -845,11 +845,11 @@ static long mem_cgroup_read_stat(struct mem_cgroup *memcg,
 	get_online_cpus();
 	for_each_online_cpu(cpu)
 		val += per_cpu(memcg->stat->count[idx], cpu);
-#ifdef CONFIG_HOTPLUG_CPU
+
 	spin_lock(&memcg->pcp_counter_lock);
-	val += memcg->nocpu_base.count[idx];
+	val += memcg->stats_base.count[idx];
 	spin_unlock(&memcg->pcp_counter_lock);
-#endif
+
 	put_online_cpus();
 	return val;
 }
@@ -869,11 +869,11 @@ static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
 
 	for_each_online_cpu(cpu)
 		val += per_cpu(memcg->stat->events[idx], cpu);
-#ifdef CONFIG_HOTPLUG_CPU
+
 	spin_lock(&memcg->pcp_counter_lock);
-	val += memcg->nocpu_base.events[idx];
+	val += memcg->stats_base.events[idx];
 	spin_unlock(&memcg->pcp_counter_lock);
-#endif
+
 	return val;
 }
 
@@ -2491,13 +2491,13 @@ static void mem_cgroup_drain_pcp_counter(struct mem_cgroup *memcg, int cpu)
 		long x = per_cpu(memcg->stat->count[i], cpu);
 
 		per_cpu(memcg->stat->count[i], cpu) = 0;
-		memcg->nocpu_base.count[i] += x;
+		memcg->stats_base.count[i] += x;
 	}
 	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++) {
 		unsigned long x = per_cpu(memcg->stat->events[i], cpu);
 
 		per_cpu(memcg->stat->events[i], cpu) = 0;
-		memcg->nocpu_base.events[i] += x;
+		memcg->stats_base.events[i] += x;
 	}
 	spin_unlock(&memcg->pcp_counter_lock);
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
