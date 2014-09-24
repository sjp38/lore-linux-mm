Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1DA6B0039
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 11:09:16 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id q5so7502582wiv.13
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 08:09:15 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p9si14065936wjy.126.2014.09.24.08.09.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Sep 2014 08:09:15 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/3] mm: memcontrol: fix transparent huge page allocations under pressure
Date: Wed, 24 Sep 2014 11:08:58 -0400
Message-Id: <1411571338-8178-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1411571338-8178-1-git-send-email-hannes@cmpxchg.org>
References: <1411571338-8178-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Dave Hansen <dave@sr71.net>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

In a memcg with even just moderate cache pressure, success rates for
transparent huge page allocations drop to zero, wasting a lot of
effort that the allocator puts into assembling these pages.

The reason for this is that the memcg reclaim code was never designed
for higher-order charges.  It reclaims in small batches until there is
room for at least one page.  Huge page charges only succeed when these
batches add up over a series of huge faults, which is unlikely under
any significant load involving order-0 allocations in the group.

Remove that loop on the memcg side in favor of passing the actual
reclaim goal to direct reclaim, which is already set up and optimized
to meet higher-order goals efficiently.

This brings memcg's THP policy in line with the system policy: if the
allocator painstakingly assembles a hugepage, memcg will at least make
an honest effort to charge it.  As a result, transparent hugepage
allocation rates amid cache activity are drastically improved:

                                      vanilla                 patched
pgalloc                 4717530.80 (  +0.00%)   4451376.40 (  -5.64%)
pgfault                  491370.60 (  +0.00%)    225477.40 ( -54.11%)
pgmajfault                    2.00 (  +0.00%)         1.80 (  -6.67%)
thp_fault_alloc               0.00 (  +0.00%)       531.60 (+100.00%)
thp_fault_fallback          749.00 (  +0.00%)       217.40 ( -70.88%)

[ Note: this may in turn increase memory consumption from internal
  fragmentation, which is an inherent risk of transparent hugepages.
  Some setups may have to adjust the memcg limits accordingly to
  accomodate this - or, if the machine is already packed to capacity,
  disable the transparent huge page feature. ]

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/swap.h |  6 +++--
 mm/memcontrol.c      | 69 +++++++++++++---------------------------------------
 mm/vmscan.c          |  7 +++---
 3 files changed, 25 insertions(+), 57 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index ea4f926e6b9b..37a585beef5c 100644
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
index 89c920156c2a..c2c75262a209 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -478,14 +478,6 @@ enum res_type {
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
@@ -1791,40 +1783,6 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
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
@@ -2527,8 +2485,9 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	struct mem_cgroup *mem_over_limit;
 	struct res_counter *fail_res;
 	unsigned long nr_reclaimed;
-	unsigned long flags = 0;
 	unsigned long long size;
+	bool may_swap = true;
+	bool drained = false;
 	int ret = 0;
 
 	if (mem_cgroup_is_root(memcg))
@@ -2547,7 +2506,7 @@ retry:
 		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
 	} else {
 		mem_over_limit = mem_cgroup_from_res_counter(fail_res, memsw);
-		flags |= MEM_CGROUP_RECLAIM_NOSWAP;
+		may_swap = false;
 	}
 
 	if (batch > nr_pages) {
@@ -2572,11 +2531,18 @@ retry:
 	if (!(gfp_mask & __GFP_WAIT))
 		goto nomem;
 
-	nr_reclaimed = mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);
+	nr_reclaimed = try_to_free_mem_cgroup_pages(mem_over_limit, nr_pages,
+						    gfp_mask, may_swap);
 
 	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
 		goto retry;
 
+	if (!drained) {
+		drain_all_stock_async(mem_over_limit);
+		drained = true;
+		goto retry;
+	}
+
 	if (gfp_mask & __GFP_NORETRY)
 		goto nomem;
 	/*
@@ -3652,8 +3618,8 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		mem_cgroup_reclaim(memcg, GFP_KERNEL,
-				   MEM_CGROUP_RECLAIM_SHRINK);
+		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, true);
+
 		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
 		/* Usage is reduced ? */
 		if (curusage >= oldusage)
@@ -3703,9 +3669,8 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
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
@@ -3954,8 +3919,8 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
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
index 06123f20a326..dcb47074ae03 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2759,21 +2759,22 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
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
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
