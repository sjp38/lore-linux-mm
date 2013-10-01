Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id D30916B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 19:31:27 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so196376pab.29
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 16:31:27 -0700 (PDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so51600pdi.28
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 16:31:25 -0700 (PDT)
Date: Tue, 1 Oct 2013 16:31:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch for-3.12] mm, memcg: protect mem_cgroup_read_events for cpu
 hotplug
Message-ID: <alpine.DEB.2.02.1310011629350.27758@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

for_each_online_cpu() needs the protection of {get,put}_online_cpus() so
cpu_online_mask doesn't change during the iteration.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/memcontrol.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -866,6 +866,7 @@ static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
 	unsigned long val = 0;
 	int cpu;
 
+	get_online_cpus();
 	for_each_online_cpu(cpu)
 		val += per_cpu(memcg->stat->events[idx], cpu);
 #ifdef CONFIG_HOTPLUG_CPU
@@ -873,6 +874,7 @@ static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
 	val += memcg->nocpu_base.events[idx];
 	spin_unlock(&memcg->pcp_counter_lock);
 #endif
+	put_online_cpus();
 	return val;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
