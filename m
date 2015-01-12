Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C176B6B006E
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 04:30:55 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so31090221pab.2
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 01:30:55 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id fe8si22491779pad.225.2015.01.12.01.30.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 01:30:54 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 2/2] mm: vmscan: init reclaim_state in do_try_to_free_pages
Date: Mon, 12 Jan 2015 12:30:38 +0300
Message-ID: <20a8ae66cc2b9412b1bf81c0a46f4e8c737aa537.1421054931.git.vdavydov@parallels.com>
In-Reply-To: <880700a513472a8b86fd3100aef674322c66c68e.1421054931.git.vdavydov@parallels.com>
References: <880700a513472a8b86fd3100aef674322c66c68e.1421054931.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

All users of do_try_to_free_pages() want to have current->reclaim_state
set in order to account reclaimed slab pages. So instead of duplicating
the reclaim_state initialization code in each call site, let's do it
directly in do_try_to_free_pages().

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/page_alloc.c |    6 ------
 mm/vmscan.c     |   24 +++++++++---------------
 2 files changed, 9 insertions(+), 21 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e1963ea0684a..bdd43815c99a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2448,7 +2448,6 @@ static int
 __perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
 		  nodemask_t *nodemask)
 {
-	struct reclaim_state reclaim_state;
 	int progress;
 
 	cond_resched();
@@ -2456,14 +2455,9 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
 	/* We now go into synchronous reclaim */
 	cpuset_memory_pressure_bump();
 	current->flags |= PF_MEMALLOC;
-	lockdep_set_current_reclaim_state(gfp_mask);
-	reclaim_state.reclaimed_slab = 0;
-	current->reclaim_state = &reclaim_state;
 
 	progress = try_to_free_pages(zonelist, order, gfp_mask, nodemask);
 
-	current->reclaim_state = NULL;
-	lockdep_clear_current_reclaim_state();
 	current->flags &= ~PF_MEMALLOC;
 
 	cond_resched();
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b2c041139a51..0a9ddeb3b747 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2592,6 +2592,12 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	unsigned long total_scanned = 0;
 	unsigned long writeback_threshold;
 	bool zones_reclaimable;
+	struct reclaim_state reclaim_state = {
+		.reclaimed_slab = 0,
+	};
+
+	lockdep_set_current_reclaim_state(sc->gfp_mask);
+	current->reclaim_state = &reclaim_state;
 
 	delayacct_freepages_start();
 
@@ -2635,6 +2641,9 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 
 	delayacct_freepages_end();
 
+	current->reclaim_state = NULL;
+	lockdep_clear_current_reclaim_state();
+
 	if (sc->nr_reclaimed)
 		return sc->nr_reclaimed;
 
@@ -2867,9 +2876,6 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 		.may_unmap = 1,
 		.may_swap = may_swap,
 	};
-	struct reclaim_state reclaim_state = {
-		.reclaimed_slab = 0,
-	};
 
 	/*
 	 * Unlike direct reclaim via alloc_pages(), memcg's reclaim doesn't
@@ -2880,9 +2886,6 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 
 	zonelist = NODE_DATA(nid)->node_zonelists;
 
-	lockdep_set_current_reclaim_state(gfp_mask);
-	current->reclaim_state = &reclaim_state;
-
 	trace_mm_vmscan_memcg_reclaim_begin(0,
 					    sc.may_writepage,
 					    sc.gfp_mask);
@@ -2891,9 +2894,6 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 
 	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
 
-	current->reclaim_state = NULL;
-	lockdep_clear_current_reclaim_state();
-
 	return nr_reclaimed;
 }
 #endif
@@ -3503,7 +3503,6 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
  */
 unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 {
-	struct reclaim_state reclaim_state;
 	struct scan_control sc = {
 		.nr_to_reclaim = nr_to_reclaim,
 		.gfp_mask = GFP_HIGHUSER_MOVABLE,
@@ -3518,14 +3517,9 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 	unsigned long nr_reclaimed;
 
 	p->flags |= PF_MEMALLOC;
-	lockdep_set_current_reclaim_state(sc.gfp_mask);
-	reclaim_state.reclaimed_slab = 0;
-	p->reclaim_state = &reclaim_state;
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
-	p->reclaim_state = NULL;
-	lockdep_clear_current_reclaim_state();
 	p->flags &= ~PF_MEMALLOC;
 
 	return nr_reclaimed;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
