Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id CF60D6B0037
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 17:38:24 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id l18so6109151wgh.1
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 14:38:24 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ua20si5035192wib.104.2014.08.08.14.38.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 08 Aug 2014 14:38:23 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/4] mm: memcontrol: use generic direct reclaim code to meet the allocation
Date: Fri,  8 Aug 2014 17:38:11 -0400
Message-Id: <1407533894-25845-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1407533894-25845-1-git-send-email-hannes@cmpxchg.org>
References: <1407533894-25845-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Memcg loops around calling direct reclaim for SWAP_CLUSTER_MAX pages
and checking the status after every invocation, but the direct reclaim
code is already required/optimized to meet higher targets efficiently.

Pass the proper target to direct reclaim and remove a lot of looping
and reclaim cruft from historic memcg glory.  All the callsites still
loop in case reclaim efforts get stolen by concurrent allocations, or
when reclaim has a hard time making progress, but at least it doesn't
have to loop to meet the basic reclaim goal anymore.

This also prepares the memcg reclaim API for use with the planned high
limit, to target any limit excess with a single reclaim invocation.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/swap.h |  6 ++--
 mm/memcontrol.c      | 86 +++++++++++-----------------------------------------
 mm/vmscan.c          |  7 +++--
 3 files changed, 25 insertions(+), 74 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 1b72060f093a..f94614a2668a 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -327,8 +327,10 @@ extern void lru_cache_add_active_or_unevictable(struct page *page,
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
 extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
-extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
-						  gfp_t gfp_mask, bool noswap);
+extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
+						  unsigned long nr_pages,
+						  gfp_t gfp_mask,
+						  bool may_swap);
 extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
 						struct zone *zone,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ec4dcf1b9562..4146c0f47ba2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -315,9 +315,6 @@ struct mem_cgroup {
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
 
-	/* set when res.limit == memsw.limit */
-	bool		memsw_is_minimum;
-
 	/* protect arrays of thresholds */
 	struct mutex thresholds_lock;
 
@@ -481,14 +478,6 @@ enum res_type {
 #define OOM_CONTROL		(0)
 
 /*
- * Reclaim flags for mem_cgroup_hierarchical_reclaim
- */
-#define MEM_CGROUP_RECLAIM_NOSWAP_BIT	0x0
-#define MEM_CGROUP_RECLAIM_NOSWAP	(1 << MEM_CGROUP_RECLAIM_NOSWAP_BIT)
-#define MEM_CGROUP_RECLAIM_SHRINK_BIT	0x1
-#define MEM_CGROUP_RECLAIM_SHRINK	(1 << MEM_CGROUP_RECLAIM_SHRINK_BIT)
-
-/*
  * The memcg_create_mutex will be held whenever a new cgroup is created.
  * As a consequence, any change that needs to protect against new child cgroups
  * appearing has to hold it as well.
@@ -1792,42 +1781,6 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 			 NULL, "Memory cgroup out of memory");
 }
 
-static unsigned long mem_cgroup_reclaim(struct mem_cgroup *memcg,
-					gfp_t gfp_mask,
-					unsigned long flags)
-{
-	unsigned long total = 0;
-	bool noswap = false;
-	int loop;
-
-	if (flags & MEM_CGROUP_RECLAIM_NOSWAP)
-		noswap = true;
-	if (!(flags & MEM_CGROUP_RECLAIM_SHRINK) && memcg->memsw_is_minimum)
-		noswap = true;
-
-	for (loop = 0; loop < MEM_CGROUP_MAX_RECLAIM_LOOPS; loop++) {
-		if (loop)
-			drain_all_stock_async(memcg);
-		total += try_to_free_mem_cgroup_pages(memcg, gfp_mask, noswap);
-		/*
-		 * Allow limit shrinkers, which are triggered directly
-		 * by userspace, to catch signals and stop reclaim
-		 * after minimal progress, regardless of the margin.
-		 */
-		if (total && (flags & MEM_CGROUP_RECLAIM_SHRINK))
-			break;
-		if (mem_cgroup_margin(memcg))
-			break;
-		/*
-		 * If nothing was reclaimed after two attempts, there
-		 * may be no reclaimable pages in this hierarchy.
-		 */
-		if (loop && !total)
-			break;
-	}
-	return total;
-}
-
 /**
  * test_mem_cgroup_node_reclaimable
  * @memcg: the target memcg
@@ -2530,8 +2483,9 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	struct mem_cgroup *mem_over_limit;
 	struct res_counter *fail_res;
 	unsigned long nr_reclaimed;
-	unsigned long flags = 0;
 	unsigned long long size;
+	bool may_swap = true;
+	bool drained = false;
 	int ret = 0;
 
 retry:
@@ -2546,7 +2500,7 @@ retry:
 			goto done_restock;
 		res_counter_uncharge(&memcg->res, size);
 		mem_over_limit = mem_cgroup_from_res_counter(fail_res, memsw);
-		flags |= MEM_CGROUP_RECLAIM_NOSWAP;
+		may_swap = false;
 	} else
 		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
 
@@ -2572,11 +2526,18 @@ retry:
 	if (!(gfp_mask & __GFP_WAIT))
 		goto nomem;
 
-	nr_reclaimed = mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);
+	nr_reclaimed = try_to_free_mem_cgroup_pages(mem_over_limit, nr_pages,
+						    gfp_mask, may_swap);
 
 	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
 		goto retry;
 
+	if (!drained) {
+		drain_all_stock_async(memcg);
+		drained = true;
+		goto retry;
+	}
+
 	if (gfp_mask & __GFP_NORETRY)
 		goto nomem;
 	/*
@@ -3707,19 +3668,13 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 			enlarge = 1;
 
 		ret = res_counter_set_limit(&memcg->res, val);
-		if (!ret) {
-			if (memswlimit == val)
-				memcg->memsw_is_minimum = true;
-			else
-				memcg->memsw_is_minimum = false;
-		}
 		mutex_unlock(&set_limit_mutex);
 
 		if (!ret)
 			break;
 
-		mem_cgroup_reclaim(memcg, GFP_KERNEL,
-				   MEM_CGROUP_RECLAIM_SHRINK);
+		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, true);
+
 		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
 		/* Usage is reduced ? */
 		if (curusage >= oldusage)
@@ -3766,20 +3721,13 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 		if (memswlimit < val)
 			enlarge = 1;
 		ret = res_counter_set_limit(&memcg->memsw, val);
-		if (!ret) {
-			if (memlimit == val)
-				memcg->memsw_is_minimum = true;
-			else
-				memcg->memsw_is_minimum = false;
-		}
 		mutex_unlock(&set_limit_mutex);
 
 		if (!ret)
 			break;
 
-		mem_cgroup_reclaim(memcg, GFP_KERNEL,
-				   MEM_CGROUP_RECLAIM_NOSWAP |
-				   MEM_CGROUP_RECLAIM_SHRINK);
+		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, false);
+
 		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
 		/* Usage is reduced ? */
 		if (curusage >= oldusage)
@@ -4028,8 +3976,8 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
 		if (signal_pending(current))
 			return -EINTR;
 
-		progress = try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL,
-						false);
+		progress = try_to_free_mem_cgroup_pages(memcg, 1,
+							GFP_KERNEL, true);
 		if (!progress) {
 			nr_retries--;
 			/* maybe some writeback is necessary */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2836b5373b2e..f1609423821b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2753,21 +2753,22 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 }
 
 unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
+					   unsigned long nr_pages,
 					   gfp_t gfp_mask,
-					   bool noswap)
+					   bool may_swap)
 {
 	struct zonelist *zonelist;
 	unsigned long nr_reclaimed;
 	int nid;
 	struct scan_control sc = {
-		.nr_to_reclaim = SWAP_CLUSTER_MAX,
+		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
 		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 				(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
 		.target_mem_cgroup = memcg,
 		.priority = DEF_PRIORITY,
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
-		.may_swap = !noswap,
+		.may_swap = may_swap,
 	};
 
 	/*
-- 
2.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
