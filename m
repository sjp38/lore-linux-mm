Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 343786B003A
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 10:51:14 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so1258446pab.12
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 07:51:13 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id kl1si9729258pbd.89.2014.09.26.07.51.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Sep 2014 07:51:12 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 2/4] cpuset: simplify cpuset_node_allowed API
Date: Fri, 26 Sep 2014 18:50:53 +0400
Message-ID: <ad9b25d464c2050aa2b5016db8eadcc7a6859967.1411741632.git.vdavydov@parallels.com>
In-Reply-To: <cover.1411741632.git.vdavydov@parallels.com>
References: <cover.1411741632.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: David Rientjes <rientjes@google.com>, Li Zefan <lizefan@huawei.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

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
index ade2390ffe92..fcad559df369 100644
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
@@ -178,22 +165,12 @@ static inline int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
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
index 1c45774ee117..114a9f7cc07e 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -2452,7 +2452,7 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
 }
 
 /**
- * cpuset_node_allowed_softwall - Can we allocate on a memory node?
+ * cpuset_node_allowed - Can we allocate on a memory node?
  * @node: is this an allowed node?
  * @gfp_mask: memory allocation flags
  *
@@ -2464,13 +2464,6 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
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
@@ -2505,13 +2498,8 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
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
@@ -2519,7 +2507,6 @@ int __cpuset_node_allowed_softwall(int node, gfp_t gfp_mask)
 
 	if (in_interrupt() || (gfp_mask & __GFP_THISNODE))
 		return 1;
-	might_sleep_if(!(gfp_mask & __GFP_HARDWALL));
 	if (node_isset(node, current->mems_allowed))
 		return 1;
 	/*
@@ -2546,44 +2533,6 @@ int __cpuset_node_allowed_softwall(int node, gfp_t gfp_mask)
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
index eeceeeb09019..e4e911e38fb8 100644
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
index 1e11df8fa7ec..2836ec2fad6d 100644
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
index 18cee0d4c8a2..67971482d5a3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1963,7 +1963,7 @@ zonelist_scan:
 
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
-	 * See also __cpuset_node_allowed_softwall() comment in kernel/cpuset.c.
+	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
 	 */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						high_zoneidx, nodemask) {
@@ -1974,7 +1974,7 @@ zonelist_scan:
 				continue;
 		if (cpusets_enabled() &&
 			(alloc_flags & ALLOC_CPUSET) &&
-			!cpuset_zone_allowed_softwall(zone, gfp_mask))
+			!cpuset_zone_allowed(zone, gfp_mask))
 				continue;
 		/*
 		 * Distribute pages in proportion to the individual
@@ -2492,7 +2492,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 			alloc_flags |= ALLOC_HARDER;
 		/*
 		 * Ignore cpuset mems for GFP_ATOMIC rather than fail, see the
-		 * comment for __cpuset_node_allowed_softwall().
+		 * comment for __cpuset_node_allowed().
 		 */
 		alloc_flags &= ~ALLOC_CPUSET;
 	} else if (unlikely(rt_task(current)) && !in_interrupt())
diff --git a/mm/slab.c b/mm/slab.c
index a467b308c682..eb6f0cf6875c 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3051,7 +3051,7 @@ retry:
 	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		nid = zone_to_nid(zone);
 
-		if (cpuset_zone_allowed_hardwall(zone, flags) &&
+		if (cpuset_zone_allowed(zone, flags | __GFP_HARDWALL) &&
 			get_node(cache, nid) &&
 			get_node(cache, nid)->free_objects) {
 				obj = ____cache_alloc_node(cache,
diff --git a/mm/slub.c b/mm/slub.c
index 3e8afcc07a76..1bf4e59fea45 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1672,7 +1672,8 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 
 			n = get_node(s, zone_to_nid(zone));
 
-			if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
+			if (n && cpuset_zone_allowed(zone,
+						     flags | __GFP_HARDWALL) &&
 					n->nr_partial > s->min_partial) {
 				object = get_partial_node(s, n, c, flags);
 				if (object) {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2836b5373b2e..19fb4cb07b23 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2399,7 +2399,8 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 		 * to global LRU.
 		 */
 		if (global_reclaim(sc)) {
-			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
+			if (!cpuset_zone_allowed(zone,
+						 GFP_KERNEL | __GFP_HARDWALL))
 				continue;
 
 			lru_pages += zone_reclaimable_pages(zone);
@@ -3381,7 +3382,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
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
