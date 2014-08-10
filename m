Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DA15D6B0036
	for <linux-mm@kvack.org>; Sun, 10 Aug 2014 18:43:24 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so10108913pab.33
        for <linux-mm@kvack.org>; Sun, 10 Aug 2014 15:43:24 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id gr3si3201776pbb.170.2014.08.10.15.43.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 10 Aug 2014 15:43:23 -0700 (PDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so9597172pde.23
        for <linux-mm@kvack.org>; Sun, 10 Aug 2014 15:43:23 -0700 (PDT)
Date: Sun, 10 Aug 2014 15:43:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mm] slab: fix cpuset check in fallback_alloc
In-Reply-To: <1407692891-24312-1-git-send-email-vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.02.1408101512500.706@chino.kir.corp.google.com>
References: <1407692891-24312-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>, Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Sun, 10 Aug 2014, Vladimir Davydov wrote:

> fallback_alloc is called on kmalloc if the preferred node doesn't have
> free or partial slabs and there's no pages on the node's free list
> (GFP_THISNODE allocations fail). Before invoking the reclaimer it tries
> to locate a free or partial slab on other allowed nodes' lists. While
> iterating over the preferred node's zonelist it skips those zones which
> cpuset_zone_allowed_hardwall returns false for. That means that for a
> task bound to a specific node using cpusets fallback_alloc will always
> ignore free slabs on other nodes and go directly to the reclaimer,
> which, however, may allocate from other nodes if cpuset.mem_hardwall is
> unset (default). As a result, we may get lists of free slabs grow
> without bounds on other nodes, which is bad, because inactive slabs are
> only evicted by cache_reap at a very slow rate and cannot be dropped
> forcefully.
> 
> To reproduce the issue, run a process that will walk over a directory
> tree with lots of files inside a cpuset bound to a node that constantly
> experiences memory pressure. Look at num_slabs vs active_slabs growth as
> reported by /proc/slabinfo.
> 
> We should use cpuset_zone_allowed_softwall in fallback_alloc. Since it
> can sleep, we only call it on __GFP_WAIT allocations. For atomic
> allocations we simply ignore cpusets, which is in agreement with the
> cpuset documenation (see the comment to __cpuset_node_allowed_softwall).
> 

If that rule were ever changed, nobody would think to modify the 
fallback_alloc() behavior in the slab allocator.  Why can't 
cpuset_zone_allowed_hardwall() just return 1 for !__GFP_WAIT?

I don't think this issue is restricted only to slab, it's for all callers 
of cpuset_zone_allowed_softwall() that could possibly be atomic.  I think 
it would be better to determine if cpuset_zone_allowed() should be 
hardwall or softwall depending on the gfp flags.

Let's add Li, the cpuset maintainer.  Any reason we can't do this?
---
diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -48,29 +48,16 @@ extern nodemask_t cpuset_mems_allowed(struct task_struct *p);
 void cpuset_init_current_mems_allowed(void);
 int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask);
 
-extern int __cpuset_node_allowed_softwall(int node, gfp_t gfp_mask);
-extern int __cpuset_node_allowed_hardwall(int node, gfp_t gfp_mask);
+extern int __cpuset_node_allowed(int node, const gfp_t gfp_mask);
 
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
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -2449,7 +2449,7 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
 }
 
 /**
- * cpuset_node_allowed_softwall - Can we allocate on a memory node?
+ * __cpuset_node_allowed - Can we allocate on a memory node?
  * @node: is this an allowed node?
  * @gfp_mask: memory allocation flags
  *
@@ -2461,12 +2461,8 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
  * flag, yes.
  * Otherwise, no.
  *
- * If __GFP_HARDWALL is set, cpuset_node_allowed_softwall() reduces to
- * cpuset_node_allowed_hardwall().  Otherwise, cpuset_node_allowed_softwall()
- * might sleep, and might allow a node from an enclosing cpuset.
- *
- * cpuset_node_allowed_hardwall() only handles the simpler case of hardwall
- * cpusets, and never sleeps.
+ * If __GFP_HARDWALL is not set, this might sleep and might allow a node from an
+ * enclosing cpuset.
  *
  * The __GFP_THISNODE placement logic is really handled elsewhere,
  * by forcibly using a zonelist starting at a specified node, and by
@@ -2495,7 +2491,7 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
  *
  * The second pass through get_page_from_freelist() doesn't even call
  * here for GFP_ATOMIC calls.  For those calls, the __alloc_pages()
- * variable 'wait' is not set, and the bit ALLOC_CPUSET is not set
+ * variable 'atomic' is set, and the bit ALLOC_CPUSET is not set
  * in alloc_flags.  That logic and the checks below have the combined
  * affect that:
  *	in_interrupt - any node ok (current task context irrelevant)
@@ -2505,18 +2501,22 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
  *	GFP_USER     - only nodes in current tasks mems allowed ok.
  *
  * Rule:
- *    Don't call cpuset_node_allowed_softwall if you can't sleep, unless you
+ *    Don't call __cpuset_node_allowed if you can't sleep, unless you
  *    pass in the __GFP_HARDWALL flag set in gfp_flag, which disables
  *    the code that might scan up ancestor cpusets and sleep.
  */
-int __cpuset_node_allowed_softwall(int node, gfp_t gfp_mask)
+int __cpuset_node_allowed(int node, const gfp_t gfp_mask)
 {
 	struct cpuset *cs;		/* current cpuset ancestors */
 	int allowed;			/* is allocation in zone z allowed? */
 
-	if (in_interrupt() || (gfp_mask & __GFP_THISNODE))
+	if (in_interrupt())
 		return 1;
 	might_sleep_if(!(gfp_mask & __GFP_HARDWALL));
+	if (gfp_mask & __GFP_THISNODE)
+		return 1;
+	if (!(gfp_mask & __GFP_WAIT))
+		return 1;
 	if (node_isset(node, current->mems_allowed))
 		return 1;
 	/*
@@ -2543,44 +2543,6 @@ int __cpuset_node_allowed_softwall(int node, gfp_t gfp_mask)
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
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -231,7 +231,7 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
 	/* Check this allocation failure is caused by cpuset's wall function */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 			high_zoneidx, nodemask)
-		if (!cpuset_zone_allowed_softwall(zone, gfp_mask))
+		if (!cpuset_zone_allowed(zone, gfp_mask))
 			cpuset_limited = true;
 
 	if (cpuset_limited) {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1963,7 +1963,7 @@ zonelist_scan:
 
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
-	 * See also __cpuset_node_allowed_softwall() comment in kernel/cpuset.c.
+	 * See __cpuset_node_allowed() comment in kernel/cpuset.c.
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
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3047,16 +3047,19 @@ retry:
 	 * from existing per node queues.
 	 */
 	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
-		nid = zone_to_nid(zone);
+		struct kmem_cache_node *n;
 
-		if (cpuset_zone_allowed_hardwall(zone, flags) &&
-			get_node(cache, nid) &&
-			get_node(cache, nid)->free_objects) {
-				obj = ____cache_alloc_node(cache,
-					flags | GFP_THISNODE, nid);
-				if (obj)
-					break;
-		}
+		nid = zone_to_nid(zone);
+		if (!cpuset_zone_allowed(zone, flags | __GFP_HARDWALL))
+			continue;
+		n = get_node(cache, nid);
+		if (!n)
+			continue;
+		if (!n->free_objects)
+			continue;
+		obj = ____cache_alloc_node(cache, flags | GFP_THISNODE, nid);
+		if (obj)
+			break;
 	}
 
 	if (!obj) {
diff --git a/mm/slub.c b/mm/slub.c
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1671,20 +1671,22 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 			struct kmem_cache_node *n;
 
 			n = get_node(s, zone_to_nid(zone));
+			if (!n)
+				continue;
+			if (!cpuset_zone_allowed(zone, flags | __GFP_HARDWALL))
+				continue;
+			if (n->nr_parial <= s->min_partial)
+				continue;
 
-			if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
-					n->nr_partial > s->min_partial) {
-				object = get_partial_node(s, n, c, flags);
-				if (object) {
-					/*
-					 * Don't check read_mems_allowed_retry()
-					 * here - if mems_allowed was updated in
-					 * parallel, that was a harmless race
-					 * between allocation and the cpuset
-					 * update
-					 */
-					return object;
-				}
+			object = get_partial_node(s, n, c, flags);
+			if (object) {
+				/*
+				 * Don't check read_mems_allowed_retry() here -
+				 * if mems_allowed was updated in parallel,
+				 * that was a harmless race between allocation
+				 * and the cpuset update.
+				 */
+				return object;
 			}
 		}
 	} while (read_mems_allowed_retry(cpuset_mems_cookie));
diff --git a/mm/vmscan.c b/mm/vmscan.c
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
