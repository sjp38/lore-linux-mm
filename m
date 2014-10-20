Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0E5476B006E
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 07:50:51 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id y10so4791381pdj.23
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 04:50:51 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id w8si7695144pde.28.2014.10.20.04.50.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 04:50:51 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RESEND 2/4] cpuset: simplify cpuset_node_allowed API
Date: Mon, 20 Oct 2014 15:50:30 +0400
Message-ID: <c52e3c30a61d29da40b69b602c41c2d91868c3ae.1413804554.git.vdavydov@parallels.com>
In-Reply-To: <cover.1413804554.git.vdavydov@parallels.com>
References: <cover.1413804554.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Zefan Li <lizefan@huawei.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Current cpuset API for checking if a zone/node is allowed to allocate
from looks rather awkward. We have hardwall and softwall versions of
cpuset_node_allowed with the softwall version doing literally the same
as the hardwall version if __GFP_HARDWALL is passed to it in gfp flags.
If it isn't, the softwall version may check the given node against the
enclosing hardwall cpuset, which it needs to take the callback lock to
do.

Such a distinction was introduced by commit 02a0e53d8227 ("cpuset:
rework cpuset_zone_allowed api"). Before, we had the only version with
the __GFP_HARDWALL flag determining its behavior. The purpose of the
commit was to avoid sleep-in-atomic bugs when someone would mistakenly
call the function without the __GFP_HARDWALL flag for an atomic
allocation. The suffixes introduced were intended to make the callers
think before using the function.

However, since the callback lock was converted from mutex to spinlock by
the previous patch, the softwall check function cannot sleep, and these
precautions are no longer necessary.

So let's simplify the API back to the single check.

Suggested-by: David Rientjes <rientjes@google.com>
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: Zefan Li <lizefan@huawei.com>
---
 include/linux/cpuset.h |   37 ++++++--------------------------
 kernel/cpuset.c        |   55 ++----------------------------------------------
 mm/hugetlb.c           |    2 +-
 mm/oom_kill.c          |    2 +-
 mm/page_alloc.c        |    6 +++---
 mm/slab.c              |    2 +-
 mm/slub.c              |    3 ++-
 mm/vmscan.c            |    5 +++--
 8 files changed, 20 insertions(+), 92 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index 2f073db7392e..1b357997cac5 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -48,29 +48,16 @@ extern nodemask_t cpuset_mems_allowed(struct task_struct *p);
 void cpuset_init_current_mems_allowed(void);
 int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask);
 
-extern int __cpuset_node_allowed_softwall(int node, gfp_t gfp_mask);
-extern int __cpuset_node_allowed_hardwall(int node, gfp_t gfp_mask);
+extern int __cpuset_node_allowed(int node, gfp_t gfp_mask);
 
-static inline int cpuset_node_allowed_softwall(int node, gfp_t gfp_mask)
+static inline int cpuset_node_allowed(int node, gfp_t gfp_mask)
 {
-	return nr_cpusets() <= 1 ||
-		__cpuset_node_allowed_softwall(node, gfp_mask);
+	return nr_cpusets() <= 1 || __cpuset_node_allowed(node, gfp_mask);
 }
 
-static inline int cpuset_node_allowed_hardwall(int node, gfp_t gfp_mask)
+static inline int cpuset_zone_allowed(struct zone *z, gfp_t gfp_mask)
 {
-	return nr_cpusets() <= 1 ||
-		__cpuset_node_allowed_hardwall(node, gfp_mask);
-}
-
-static inline int cpuset_zone_allowed_softwall(struct zone *z, gfp_t gfp_mask)
-{
-	return cpuset_node_allowed_softwall(zone_to_nid(z), gfp_mask);
-}
-
-static inline int cpuset_zone_allowed_hardwall(struct zone *z, gfp_t gfp_mask)
-{
-	return cpuset_node_allowed_hardwall(zone_to_nid(z), gfp_mask);
+	return cpuset_node_allowed(zone_to_nid(z), gfp_mask);
 }
 
 extern int cpuset_mems_allowed_intersects(const struct task_struct *tsk1,
@@ -179,22 +166,12 @@ static inline int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
 	return 1;
 }
 
-static inline int cpuset_node_allowed_softwall(int node, gfp_t gfp_mask)
-{
-	return 1;
-}
-
-static inline int cpuset_node_allowed_hardwall(int node, gfp_t gfp_mask)
-{
-	return 1;
-}
-
-static inline int cpuset_zone_allowed_softwall(struct zone *z, gfp_t gfp_mask)
+static inline int cpuset_node_allowed(int node, gfp_t gfp_mask)
 {
 	return 1;
 }
 
-static inline int cpuset_zone_allowed_hardwall(struct zone *z, gfp_t gfp_mask)
+static inline int cpuset_zone_allowed(struct zone *z, gfp_t gfp_mask)
 {
 	return 1;
 }
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index f21ba868f0d1..38f7433c1cd2 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -2453,7 +2453,7 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
 }
 
 /**
- * cpuset_node_allowed_softwall - Can we allocate on a memory node?
+ * cpuset_node_allowed - Can we allocate on a memory node?
  * @node: is this an allowed node?
  * @gfp_mask: memory allocation flags
  *
@@ -2465,13 +2465,6 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
  * flag, yes.
  * Otherwise, no.
  *
- * If __GFP_HARDWALL is set, cpuset_node_allowed_softwall() reduces to
- * cpuset_node_allowed_hardwall().  Otherwise, cpuset_node_allowed_softwall()
- * might sleep, and might allow a node from an enclosing cpuset.
- *
- * cpuset_node_allowed_hardwall() only handles the simpler case of hardwall
- * cpusets, and never sleeps.
- *
  * The __GFP_THISNODE placement logic is really handled elsewhere,
  * by forcibly using a zonelist starting at a specified node, and by
  * (in get_page_from_freelist()) refusing to consider the zones for
@@ -2506,13 +2499,8 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
  *	TIF_MEMDIE   - any node ok
  *	GFP_KERNEL   - any node in enclosing hardwalled cpuset ok
  *	GFP_USER     - only nodes in current tasks mems allowed ok.
- *
- * Rule:
- *    Don't call cpuset_node_allowed_softwall if you can't sleep, unless you
- *    pass in the __GFP_HARDWALL flag set in gfp_flag, which disables
- *    the code that might scan up ancestor cpusets and sleep.
  */
-int __cpuset_node_allowed_softwall(int node, gfp_t gfp_mask)
+int __cpuset_node_allowed(int node, gfp_t gfp_mask)
 {
 	struct cpuset *cs;		/* current cpuset ancestors */
 	int allowed;			/* is allocation in zone z allowed? */
@@ -2520,7 +2508,6 @@ int __cpuset_node_allowed_softwall(int node, gfp_t gfp_mask)
 
 	if (in_interrupt() || (gfp_mask & __GFP_THISNODE))
 		return 1;
-	might_sleep_if(!(gfp_mask & __GFP_HARDWALL));
 	if (node_isset(node, current->mems_allowed))
 		return 1;
 	/*
@@ -2547,44 +2534,6 @@ int __cpuset_node_allowed_softwall(int node, gfp_t gfp_mask)
 	return allowed;
 }
 
-/*
- * cpuset_node_allowed_hardwall - Can we allocate on a memory node?
- * @node: is this an allowed node?
- * @gfp_mask: memory allocation flags
- *
- * If we're in interrupt, yes, we can always allocate.  If __GFP_THISNODE is
- * set, yes, we can always allocate.  If node is in our task's mems_allowed,
- * yes.  If the task has been OOM killed and has access to memory reserves as
- * specified by the TIF_MEMDIE flag, yes.
- * Otherwise, no.
- *
- * The __GFP_THISNODE placement logic is really handled elsewhere,
- * by forcibly using a zonelist starting at a specified node, and by
- * (in get_page_from_freelist()) refusing to consider the zones for
- * any node on the zonelist except the first.  By the time any such
- * calls get to this routine, we should just shut up and say 'yes'.
- *
- * Unlike the cpuset_node_allowed_softwall() variant, above,
- * this variant requires that the node be in the current task's
- * mems_allowed or that we're in interrupt.  It does not scan up the
- * cpuset hierarchy for the nearest enclosing mem_exclusive cpuset.
- * It never sleeps.
- */
-int __cpuset_node_allowed_hardwall(int node, gfp_t gfp_mask)
-{
-	if (in_interrupt() || (gfp_mask & __GFP_THISNODE))
-		return 1;
-	if (node_isset(node, current->mems_allowed))
-		return 1;
-	/*
-	 * Allow tasks that have access to memory reserves because they have
-	 * been OOM killed to get memory anywhere.
-	 */
-	if (unlikely(test_thread_flag(TIF_MEMDIE)))
-		return 1;
-	return 0;
-}
-
 /**
  * cpuset_mem_spread_node() - On which node to begin search for a file page
  * cpuset_slab_spread_node() - On which node to begin search for a slab page
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9fd722769927..82da930fa3f8 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -582,7 +582,7 @@ retry_cpuset:
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						MAX_NR_ZONES - 1, nodemask) {
-		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask(h))) {
+		if (cpuset_zone_allowed(zone, htlb_alloc_mask(h))) {
 			page = dequeue_huge_page_node(h, zone_to_nid(zone));
 			if (page) {
 				if (avoid_reserve)
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index bbf405a3a18f..4af376f67198 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -233,7 +233,7 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
 	/* Check this allocation failure is caused by cpuset's wall function */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 			high_zoneidx, nodemask)
-		if (!cpuset_zone_allowed_softwall(zone, gfp_mask))
+		if (!cpuset_zone_allowed(zone, gfp_mask))
 			cpuset_limited = true;
 
 	if (cpuset_limited) {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 736d8e1b6381..76deeb10317c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1962,7 +1962,7 @@ zonelist_scan:
 
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
-	 * See also __cpuset_node_allowed_softwall() comment in kernel/cpuset.c.
+	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
 	 */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						high_zoneidx, nodemask) {
@@ -1973,7 +1973,7 @@ zonelist_scan:
 				continue;
 		if (cpusets_enabled() &&
 			(alloc_flags & ALLOC_CPUSET) &&
-			!cpuset_zone_allowed_softwall(zone, gfp_mask))
+			!cpuset_zone_allowed(zone, gfp_mask))
 				continue;
 		/*
 		 * Distribute pages in proportion to the individual
@@ -2506,7 +2506,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 			alloc_flags |= ALLOC_HARDER;
 		/*
 		 * Ignore cpuset mems for GFP_ATOMIC rather than fail, see the
-		 * comment for __cpuset_node_allowed_softwall().
+		 * comment for __cpuset_node_allowed().
 		 */
 		alloc_flags &= ~ALLOC_CPUSET;
 	} else if (unlikely(rt_task(current)) && !in_interrupt())
diff --git a/mm/slab.c b/mm/slab.c
index eb2b2ea30130..063a91bc8826 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3012,7 +3012,7 @@ retry:
 	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		nid = zone_to_nid(zone);
 
-		if (cpuset_zone_allowed_hardwall(zone, flags) &&
+		if (cpuset_zone_allowed(zone, flags | __GFP_HARDWALL) &&
 			get_node(cache, nid) &&
 			get_node(cache, nid)->free_objects) {
 				obj = ____cache_alloc_node(cache,
diff --git a/mm/slub.c b/mm/slub.c
index ae7b9f1ad394..7d12f51d9bac 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1662,7 +1662,8 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 
 			n = get_node(s, zone_to_nid(zone));
 
-			if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
+			if (n && cpuset_zone_allowed(zone,
+						     flags | __GFP_HARDWALL) &&
 					n->nr_partial > s->min_partial) {
 				object = get_partial_node(s, n, c, flags);
 				if (object) {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index dcb47074ae03..38878b2ab1d0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2405,7 +2405,8 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 		 * to global LRU.
 		 */
 		if (global_reclaim(sc)) {
-			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
+			if (!cpuset_zone_allowed(zone,
+						 GFP_KERNEL | __GFP_HARDWALL))
 				continue;
 
 			lru_pages += zone_reclaimable_pages(zone);
@@ -3388,7 +3389,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	if (!populated_zone(zone))
 		return;
 
-	if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
+	if (!cpuset_zone_allowed(zone, GFP_KERNEL | __GFP_HARDWALL))
 		return;
 	pgdat = zone->zone_pgdat;
 	if (pgdat->kswapd_max_order < order) {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
