Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 729CE6B004A
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 05:46:39 -0400 (EDT)
Message-Id: <113c4affc2f0938b7b22d43c88d2b0a623de9a6b.1311241300.git.mhocko@suse.cz>
In-Reply-To: <cover.1311241300.git.mhocko@suse.cz>
References: <cover.1311241300.git.mhocko@suse.cz>
From: Michal Hocko <mhocko@suse.cz>
Date: Thu, 21 Jul 2011 09:38:00 +0200
Subject: [PATCH 1/4] memcg: do not try to drain per-cpu caches without pages
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

drain_all_stock_async tries to optimize a work to be done on the work
queue by excluding any work for the current CPU because it assumes that
the context we are called from already tried to charge from that cache
and it's failed so it must be empty already.
While the assumption is correct we can do it by checking the current
number of pages in the cache. This will also reduce a work on other CPUs
with an empty stock.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   14 ++------------
 1 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f11f198..786bffb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2140,7 +2140,7 @@ static void refill_stock(struct mem_cgroup *mem, unsigned int nr_pages)
  */
 static void drain_all_stock_async(struct mem_cgroup *root_mem)
 {
-	int cpu, curcpu;
+	int cpu;
 	/*
 	 * If someone calls draining, avoid adding more kworker runs.
 	 */
@@ -2148,22 +2148,12 @@ static void drain_all_stock_async(struct mem_cgroup *root_mem)
 		return;
 	/* Notify other cpus that system-wide "drain" is running */
 	get_online_cpus();
-	/*
-	 * Get a hint for avoiding draining charges on the current cpu,
-	 * which must be exhausted by our charging.  It is not required that
-	 * this be a precise check, so we use raw_smp_processor_id() instead of
-	 * getcpu()/putcpu().
-	 */
-	curcpu = raw_smp_processor_id();
 	for_each_online_cpu(cpu) {
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
-- 
1.7.5.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
