Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9B86C6B004A
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 08:51:13 -0400 (EDT)
Message-Id: <2f17df54db6661c39a05669d08a9e6257435b898.1311338634.git.mhocko@suse.cz>
In-Reply-To: <cover.1311338634.git.mhocko@suse.cz>
References: <cover.1311338634.git.mhocko@suse.cz>
From: Michal Hocko <mhocko@suse.cz>
Date: Thu, 21 Jul 2011 09:38:00 +0200
Subject: [PATCH 1/4] memcg: do not try to drain per-cpu caches without pages
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

drain_all_stock_async tries to optimize a work to be done on the work
queue by excluding any work for the current CPU because it assumes that
the context we are called from already tried to charge from that cache
and it's failed so it must be empty already.
While the assumption is correct we can optimize it even more by checking
the current number of pages in the cache. This will also reduce a work
on other CPUs with an empty stock.
For the current CPU we can simply call drain_local_stock rather than
deferring it to the work queue.

[KAMEZAWA Hiroyuki - use drain_local_stock for current CPU optimization]
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f11f198..c012ffe 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2159,11 +2159,8 @@ static void drain_all_stock_async(struct mem_cgroup *root_mem)
 		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
 		struct mem_cgroup *mem;
 
-		if (cpu == curcpu)
-			continue;
-
 		mem = stock->cached;
-		if (!mem)
+		if (!mem || !stock->nr_pages)
 			continue;
 		if (mem != root_mem) {
 			if (!root_mem->use_hierarchy)
@@ -2172,8 +2169,12 @@ static void drain_all_stock_async(struct mem_cgroup *root_mem)
 			if (!css_is_ancestor(&mem->css, &root_mem->css))
 				continue;
 		}
-		if (!test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
-			schedule_work_on(cpu, &stock->work);
+		if (!test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags)) {
+			if (cpu == curcpu)
+				drain_local_stock(&stock->work);
+			else
+				schedule_work_on(cpu, &stock->work);
+		}
 	}
  	put_online_cpus();
 	mutex_unlock(&percpu_charge_mutex);
-- 
1.7.5.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
