Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 06D006B0006
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 08:10:56 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 1/5] memcg: make nocpu_base available for non hotplug
Date: Tue,  5 Mar 2013 17:10:54 +0400
Message-Id: <1362489058-3455-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1362489058-3455-1-git-send-email-glommer@parallels.com>
References: <1362489058-3455-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, handai.szj@gmail.com, anton.vorontsov@linaro.org, Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>

We are using nocpu_base to accumulate charges on the main counters
during cpu hotplug. I have a similar need, which is transferring charges
to the root cgroup when lazily enabling memcg. Because system wide
information is not kept per-cpu, it is hard to distribute it. This field
works well for this. So we need to make it available for all usages, not
only hotplug cases.

Signed-off-by: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>
---
 mm/memcontrol.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 669d16a..b8b363f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -921,11 +921,11 @@ static long mem_cgroup_read_stat(struct mem_cgroup *memcg,
 	get_online_cpus();
 	for_each_online_cpu(cpu)
 		val += per_cpu(memcg->stat->count[idx], cpu);
-#ifdef CONFIG_HOTPLUG_CPU
+
 	spin_lock(&memcg->pcp_counter_lock);
 	val += memcg->nocpu_base.count[idx];
 	spin_unlock(&memcg->pcp_counter_lock);
-#endif
+
 	put_online_cpus();
 	return val;
 }
@@ -945,11 +945,11 @@ static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
 
 	for_each_online_cpu(cpu)
 		val += per_cpu(memcg->stat->events[idx], cpu);
-#ifdef CONFIG_HOTPLUG_CPU
+
 	spin_lock(&memcg->pcp_counter_lock);
 	val += memcg->nocpu_base.events[idx];
 	spin_unlock(&memcg->pcp_counter_lock);
-#endif
+
 	return val;
 }
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
