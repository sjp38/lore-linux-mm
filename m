Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 45D4A6B00E8
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 08:51:15 -0400 (EDT)
Message-Id: <a9244082ba28c4c2e4a6997311d5493bdaa117e9.1311338634.git.mhocko@suse.cz>
In-Reply-To: <cover.1311338634.git.mhocko@suse.cz>
References: <cover.1311338634.git.mhocko@suse.cz>
From: Michal Hocko <mhocko@suse.cz>
Date: Fri, 22 Jul 2011 13:20:25 +0200
Subject: [PATCH 4/4] memcg: get rid of percpu_charge_mutex lock
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

percpu_charge_mutex protects from multiple simultaneous per-cpu charge
caches draining because we might end up having too many work items.
At least this was the case until 26fe6168 (memcg: fix percpu cached
charge draining frequency) when we introduced a more targeted draining
for async mode.
Now that also sync draining is targeted we can safely remove mutex
because we will not send more work than the current number of CPUs.
FLUSHING_CACHED_CHARGE protects from sending the same work multiple
times and stock->nr_pages == 0 protects from pointless sending a work
if there is obviously nothing to be done. This is of course racy but we
can live with it as the race window is really small (we would have to
see FLUSHING_CACHED_CHARGE cleared while nr_pages would be still
non-zero).
The only remaining place where we can race is synchronous mode when we
rely on FLUSHING_CACHED_CHARGE test which might have been set by other
drainer on the same group but we should wait in that case as well.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3685107..f8463a0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2071,7 +2071,6 @@ struct memcg_stock_pcp {
 #define FLUSHING_CACHED_CHARGE	(0)
 };
 static DEFINE_PER_CPU(struct memcg_stock_pcp, memcg_stock);
-static DEFINE_MUTEX(percpu_charge_mutex);
 
 /*
  * Try to consume stocked charge on this cpu. If success, one page is consumed
@@ -2178,7 +2177,8 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
 
 	for_each_online_cpu(cpu) {
 		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
-		if (test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
+		if (mem_cgroup_same_or_subtree(root_mem, stock->cached) &&
+				test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
 			flush_work(&stock->work);
 	}
 out:
@@ -2193,22 +2193,14 @@ out:
  */
 static void drain_all_stock_async(struct mem_cgroup *root_mem)
 {
-	/*
-	 * If someone calls draining, avoid adding more kworker runs.
-	 */
-	if (!mutex_trylock(&percpu_charge_mutex))
-		return;
 	drain_all_stock(root_mem, false);
-	mutex_unlock(&percpu_charge_mutex);
 }
 
 /* This is a synchronous drain interface. */
 static void drain_all_stock_sync(struct mem_cgroup *root_mem)
 {
 	/* called when force_empty is called */
-	mutex_lock(&percpu_charge_mutex);
 	drain_all_stock(root_mem, true);
-	mutex_unlock(&percpu_charge_mutex);
 }
 
 /*
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
