Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id D2CD46B0279
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 08:33:43 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o8so107346883qtc.1
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 05:33:43 -0700 (PDT)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id 91si4471732qta.132.2017.07.04.05.33.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jul 2017 05:33:42 -0700 (PDT)
Received: by mail-qk0-x241.google.com with SMTP id v143so14635591qkb.3
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 05:33:42 -0700 (PDT)
From: josef@toxicpanda.com
Subject: [PATCH 1/4] vmscan: push reclaim_state down to shrink_node()
Date: Tue,  4 Jul 2017 08:33:37 -0400
Message-Id: <1499171620-6746-1-git-send-email-jbacik@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, akpm@linux-foundation.org, kernel-team@fb.com, linux-mm@kvack.org, hannes@cmpxchg.org, riel@redhat.com
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

We care about this for slab reclaim, and only some of the paths set this
and way higher up than we care about.  Fix this by pushing it into
shrink_node() so we always have the slab reclaim information, regardless
of how we are doing the reclaim.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 mm/page_alloc.c |  4 ----
 mm/vmscan.c     | 26 +++++++-------------------
 2 files changed, 7 insertions(+), 23 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b896897..2d5b79c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3484,7 +3484,6 @@ static int
 __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 					const struct alloc_context *ac)
 {
-	struct reclaim_state reclaim_state;
 	int progress;
 	unsigned int noreclaim_flag;
 
@@ -3494,13 +3493,10 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 	cpuset_memory_pressure_bump();
 	noreclaim_flag = memalloc_noreclaim_save();
 	lockdep_set_current_reclaim_state(gfp_mask);
-	reclaim_state.reclaimed_slab = 0;
-	current->reclaim_state = &reclaim_state;
 
 	progress = try_to_free_pages(ac->zonelist, order, gfp_mask,
 								ac->nodemask);
 
-	current->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
 	memalloc_noreclaim_restore(noreclaim_flag);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f84cdd3..cf23de9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2560,10 +2560,13 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 
 static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 {
-	struct reclaim_state *reclaim_state = current->reclaim_state;
+	struct reclaim_state reclaim_state = {
+		.reclaimed_slab = 0,
+	};
 	unsigned long nr_reclaimed, nr_scanned;
 	bool reclaimable = false;
 
+	current->reclaim_state = &reclaim_state;
 	do {
 		struct mem_cgroup *root = sc->target_mem_cgroup;
 		struct mem_cgroup_reclaim_cookie reclaim = {
@@ -2644,10 +2647,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			   sc->nr_scanned - nr_scanned,
 			   sc->nr_reclaimed - nr_reclaimed);
 
-		if (reclaim_state) {
-			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
-			reclaim_state->reclaimed_slab = 0;
-		}
+		sc->nr_reclaimed += reclaim_state.reclaimed_slab;
+		reclaim_state.reclaimed_slab = 0;
 
 		if (sc->nr_reclaimed - nr_reclaimed)
 			reclaimable = true;
@@ -2664,6 +2665,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 	if (reclaimable)
 		pgdat->kswapd_failures = 0;
 
+	current->reclaim_state = NULL;
 	return reclaimable;
 }
 
@@ -3527,16 +3529,12 @@ static int kswapd(void *p)
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
 
-	struct reclaim_state reclaim_state = {
-		.reclaimed_slab = 0,
-	};
 	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
 
 	lockdep_set_current_reclaim_state(GFP_KERNEL);
 
 	if (!cpumask_empty(cpumask))
 		set_cpus_allowed_ptr(tsk, cpumask);
-	current->reclaim_state = &reclaim_state;
 
 	/*
 	 * Tell the memory management that we're a "memory allocator",
@@ -3598,7 +3596,6 @@ static int kswapd(void *p)
 	}
 
 	tsk->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD);
-	current->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
 
 	return 0;
@@ -3645,7 +3642,6 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
  */
 unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 {
-	struct reclaim_state reclaim_state;
 	struct scan_control sc = {
 		.nr_to_reclaim = nr_to_reclaim,
 		.gfp_mask = GFP_HIGHUSER_MOVABLE,
@@ -3657,18 +3653,14 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 		.hibernation_mode = 1,
 	};
 	struct zonelist *zonelist = node_zonelist(numa_node_id(), sc.gfp_mask);
-	struct task_struct *p = current;
 	unsigned long nr_reclaimed;
 	unsigned int noreclaim_flag;
 
 	noreclaim_flag = memalloc_noreclaim_save();
 	lockdep_set_current_reclaim_state(sc.gfp_mask);
-	reclaim_state.reclaimed_slab = 0;
-	p->reclaim_state = &reclaim_state;
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
-	p->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
 	memalloc_noreclaim_restore(noreclaim_flag);
 
@@ -3833,7 +3825,6 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	/* Minimum pages needed in order to stay on node */
 	const unsigned long nr_pages = 1 << order;
 	struct task_struct *p = current;
-	struct reclaim_state reclaim_state;
 	unsigned int noreclaim_flag;
 	struct scan_control sc = {
 		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
@@ -3855,8 +3846,6 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	noreclaim_flag = memalloc_noreclaim_save();
 	p->flags |= PF_SWAPWRITE;
 	lockdep_set_current_reclaim_state(sc.gfp_mask);
-	reclaim_state.reclaimed_slab = 0;
-	p->reclaim_state = &reclaim_state;
 
 	if (node_pagecache_reclaimable(pgdat) > pgdat->min_unmapped_pages) {
 		/*
@@ -3868,7 +3857,6 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
 	}
 
-	p->reclaim_state = NULL;
 	current->flags &= ~PF_SWAPWRITE;
 	memalloc_noreclaim_restore(noreclaim_flag);
 	lockdep_clear_current_reclaim_state();
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
