Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C0D06B0390
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 03:47:09 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v44so524722wrc.9
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 00:47:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o102si27972706wrb.208.2017.04.05.00.47.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Apr 2017 00:47:08 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 2/4] mm: introduce memalloc_noreclaim_{save,restore}
Date: Wed,  5 Apr 2017 09:46:58 +0200
Message-Id: <20170405074700.29871-3-vbabka@suse.cz>
In-Reply-To: <20170405074700.29871-1-vbabka@suse.cz>
References: <20170405074700.29871-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-block@vger.kernel.org, nbd-general@lists.sourceforge.net, open-iscsi@googlegroups.com, linux-scsi@vger.kernel.org, netdev@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>

The previous patch has shown that simply setting and clearing PF_MEMALLOC in
current->flags can result in wrongly clearing a pre-existing PF_MEMALLOC flag
and potentially lead to recursive reclaim. Let's introduce helpers that support
proper nesting by saving the previous stat of the flag, similar to the existing
memalloc_noio_* and memalloc_nofs_* helpers. Convert existing setting/clearing
of PF_MEMALLOC within mm to the new helpers.

There are no known issues with the converted code, but the change makes it more
robust.

Suggested-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/sched/mm.h | 12 ++++++++++++
 mm/page_alloc.c          | 11 ++++++-----
 mm/vmscan.c              | 17 +++++++++++------
 3 files changed, 29 insertions(+), 11 deletions(-)

diff --git a/include/linux/sched/mm.h b/include/linux/sched/mm.h
index 9daabe138c99..2b24a6974847 100644
--- a/include/linux/sched/mm.h
+++ b/include/linux/sched/mm.h
@@ -191,4 +191,16 @@ static inline void memalloc_nofs_restore(unsigned int flags)
 	current->flags = (current->flags & ~PF_MEMALLOC_NOFS) | flags;
 }
 
+static inline unsigned int memalloc_noreclaim_save(void)
+{
+	unsigned int flags = current->flags & PF_MEMALLOC;
+	current->flags |= PF_MEMALLOC;
+	return flags;
+}
+
+static inline void memalloc_noreclaim_restore(unsigned int flags)
+{
+	current->flags = (current->flags & ~PF_MEMALLOC) | flags;
+}
+
 #endif /* _LINUX_SCHED_MM_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b84e6ffbe756..037e32dccd7a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3288,15 +3288,15 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		enum compact_priority prio, enum compact_result *compact_result)
 {
 	struct page *page;
-	unsigned int noreclaim_flag = current->flags & PF_MEMALLOC;
+	unsigned int noreclaim_flag;
 
 	if (!order)
 		return NULL;
 
-	current->flags |= PF_MEMALLOC;
+	noreclaim_flag = memalloc_noreclaim_save();
 	*compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
 									prio);
-	current->flags = (current->flags & ~PF_MEMALLOC) | noreclaim_flag;
+	memalloc_noreclaim_restore(noreclaim_flag);
 
 	if (*compact_result <= COMPACT_INACTIVE)
 		return NULL;
@@ -3443,12 +3443,13 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 {
 	struct reclaim_state reclaim_state;
 	int progress;
+	unsigned int noreclaim_flag;
 
 	cond_resched();
 
 	/* We now go into synchronous reclaim */
 	cpuset_memory_pressure_bump();
-	current->flags |= PF_MEMALLOC;
+	noreclaim_flag = memalloc_noreclaim_save();
 	lockdep_set_current_reclaim_state(gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
 	current->reclaim_state = &reclaim_state;
@@ -3458,7 +3459,7 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 
 	current->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
-	current->flags &= ~PF_MEMALLOC;
+	memalloc_noreclaim_restore(noreclaim_flag);
 
 	cond_resched();
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 58615bb27f2f..ff63b91a0f48 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2992,6 +2992,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 	struct zonelist *zonelist;
 	unsigned long nr_reclaimed;
 	int nid;
+	unsigned int noreclaim_flag;
 	struct scan_control sc = {
 		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
 		.gfp_mask = (current_gfp_context(gfp_mask) & GFP_RECLAIM_MASK) |
@@ -3018,9 +3019,9 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 					    sc.gfp_mask,
 					    sc.reclaim_idx);
 
-	current->flags |= PF_MEMALLOC;
+	noreclaim_flag = memalloc_noreclaim_save();
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
-	current->flags &= ~PF_MEMALLOC;
+	memalloc_noreclaim_restore(noreclaim_flag);
 
 	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
 
@@ -3544,8 +3545,9 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 	struct zonelist *zonelist = node_zonelist(numa_node_id(), sc.gfp_mask);
 	struct task_struct *p = current;
 	unsigned long nr_reclaimed;
+	unsigned int noreclaim_flag;
 
-	p->flags |= PF_MEMALLOC;
+	noreclaim_flag = memalloc_noreclaim_save();
 	lockdep_set_current_reclaim_state(sc.gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
@@ -3554,7 +3556,7 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 
 	p->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
-	p->flags &= ~PF_MEMALLOC;
+	memalloc_noreclaim_restore(noreclaim_flag);
 
 	return nr_reclaimed;
 }
@@ -3719,6 +3721,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	struct task_struct *p = current;
 	struct reclaim_state reclaim_state;
 	int classzone_idx = gfp_zone(gfp_mask);
+	unsigned int noreclaim_flag;
 	struct scan_control sc = {
 		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
 		.gfp_mask = (gfp_mask = current_gfp_context(gfp_mask)),
@@ -3736,7 +3739,8 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	 * and we also need to be able to write out pages for RECLAIM_WRITE
 	 * and RECLAIM_UNMAP.
 	 */
-	p->flags |= PF_MEMALLOC | PF_SWAPWRITE;
+	noreclaim_flag = memalloc_noreclaim_save();
+	p->flags |= PF_SWAPWRITE;
 	lockdep_set_current_reclaim_state(gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
@@ -3752,7 +3756,8 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	}
 
 	p->reclaim_state = NULL;
-	current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
+	current->flags &= ~PF_SWAPWRITE;
+	memalloc_noreclaim_restore(noreclaim_flag);
 	lockdep_clear_current_reclaim_state();
 	return sc.nr_reclaimed >= nr_pages;
 }
-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
