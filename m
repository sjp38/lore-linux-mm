Date: Wed, 8 Aug 2007 22:44:20 +0100
Subject: Re: [PATCH 0/3] Use one zonelist per node instead of multiple zonelists v2
Message-ID: <20070808214420.GD2441@skynet.ie>
References: <20070808161504.32320.79576.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0708081025330.12652@schroedinger.engr.sgi.com> <1186597819.5055.37.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1186597819.5055.37.camel@localhost>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, pj@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (08/08/07 14:30), Lee Schermerhorn didst pronounce:
> On Wed, 2007-08-08 at 10:36 -0700, Christoph Lameter wrote:
> > On Wed, 8 Aug 2007, Mel Gorman wrote:
> > 
> > > These are the range of performance losses/gains I found when running against
> > > 2.6.23-rc1-mm2. The set and these machines are a mix of i386, x86_64 and
> > > ppc64 both NUMA and non-NUMA.
> > > 
> > > Total CPU time on Kernbench: -0.20% to  3.70%
> > > Elapsed   time on Kernbench: -0.32% to  3.62%
> > > page_test from aim9:         -2.17% to 12.42%
> > > brk_test  from aim9:         -6.03% to 11.49%
> > > fork_test from aim9:         -2.30% to  5.42%
> > > exec_test from aim9:         -0.68% to  3.39%
> > > Size reduction of pg_dat_t:   0     to  7808 bytes (depends on alignment)
> > 
> > Looks good.
> > 
> > > o Remove bind_zonelist() (Patch in progress, very messy right now)
> > 
> > Will this also allow us to avoid always hitting the first node of an 
> > MPOL_BIND first?
> 
> An idea:
> 
> Apologies if someone already suggested this and I missed it.  Too much
> traffic...
> 
> instead of passing a zonelist for BIND policy, how about passing [to
> __alloc_pages(), I think] a starting node, a nodemask, and gfp flags for
> zone and modifiers. 

Yes, this has come up before although it wasn't my initial suggestion. I
thought maybe it was yours but I'm not sure anymore. I'm working through
it at the moment. With the patch currently, a a nodemask is passed in for
filtering which should be enough as the zonelist being used should be enough
information to indicate the starting node.

The signature of __alloc_pages() becomes

static page * fastcall
__alloc_pages_nodemask(gfp_t gfp_mask, nodemask_t *nodemask,
               unsigned int order, struct zonelist *zonelist)

>  For various policies, the arguments would look like this:
> Policy		start node	nodemask
> 
> default		local node	cpuset_current_mems_allowed
> 
> preferred	preferred_node	cpuset_current_mems_allowed
> 
> interleave	computed node	cpuset_current_mems_allowed
> 
> bind		local node	policy nodemask [replaces bind
> 				zonelist in mempolicy]
> 

The last one is the most interesting. Much of the patch in development
involves deleting the custom node stuff. I've included the patch below if
you're curious. I wanted to get one-zonelist out first to see if we could
agree on that before going further with it.

> Then, just walk the zonelist for the starting node--already ordered by
> distance--filtering by gfp_zone() and nodemask.  Done "right", this
> should always return memory from the closest allowed node [based on the
> nodemask argument] to the starting node.  And, it would eliminate the
> custom zonelists for bind policy.  Can also eliminate cpuset checks in
> the allocation loop because that constraint would already be applied to
> the nodemask argument.
> 

This is what I'm hoping. I haven't looked closely enough to be sure this will
work but currently I see no reason why it couldn't and it might eliminate
some of the NUMA-specific paths in the allocator.

> The fast path--when we hit in the target zone on the starting
> node--might be faster.  Once we have to start falling back to other
> nodes/zones, we've pretty much fallen off the fast path anyway, I think.
> 

Well, if you haven't hit it in the allocator, you are going to slow up
soon anyway.

> Bind policy would suffer a hit when the nodemask does not include the
> local node from which the allocation occurs.  I.e., this would always be
> a fallback case.
> 
> Too backed up to investigate further right now.  
> 
> I will add Mel's patches to my test tree, tho'.
> 

This is what the patch currently looks like for altering how MPOL_BIND
builds a zonelist. It hasn't been compile-tested, built-tested or even
had much though yet so should not be run anywhere. Expecting to apply
cleanly is probably optimistic :)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc2-015_treat_movable_highest/fs/buffer.c linux-2.6.23-rc2-020_filter_nodemask/fs/buffer.c
--- linux-2.6.23-rc2-015_treat_movable_highest/fs/buffer.c	2007-08-08 17:51:13.000000000 +0100
+++ linux-2.6.23-rc2-020_filter_nodemask/fs/buffer.c	2007-08-08 22:35:30.000000000 +0100
@@ -355,7 +355,7 @@ static void free_more_memory(void)
 
 	for_each_online_pgdat(pgdat) {
 		zones = first_zones_zonelist(&pgdat->node_zonelist,
-			gfp_zone(GFP_NOFS));
+			NULL, gfp_zone(GFP_NOFS));
 		if (*zones)
 			try_to_free_pages(&pgdat->node_zonelist, 0, GFP_NOFS);
 	}
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc2-015_treat_movable_highest/include/linux/cpuset.h linux-2.6.23-rc2-020_filter_nodemask/include/linux/cpuset.h
--- linux-2.6.23-rc2-015_treat_movable_highest/include/linux/cpuset.h	2007-08-04 03:49:55.000000000 +0100
+++ linux-2.6.23-rc2-020_filter_nodemask/include/linux/cpuset.h	2007-08-08 22:18:09.000000000 +0100
@@ -28,7 +28,7 @@ void cpuset_init_current_mems_allowed(vo
 void cpuset_update_task_memory_state(void);
 #define cpuset_nodes_subset_current_mems_allowed(nodes) \
 		nodes_subset((nodes), current->mems_allowed)
-int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl);
+int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask);
 
 extern int __cpuset_zone_allowed_softwall(struct zone *z, gfp_t gfp_mask);
 extern int __cpuset_zone_allowed_hardwall(struct zone *z, gfp_t gfp_mask);
@@ -98,7 +98,7 @@ static inline void cpuset_init_current_m
 static inline void cpuset_update_task_memory_state(void) {}
 #define cpuset_nodes_subset_current_mems_allowed(nodes) (1)
 
-static inline int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl)
+static inline int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
 {
 	return 1;
 }
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc2-015_treat_movable_highest/include/linux/gfp.h linux-2.6.23-rc2-020_filter_nodemask/include/linux/gfp.h
--- linux-2.6.23-rc2-015_treat_movable_highest/include/linux/gfp.h	2007-08-08 17:51:13.000000000 +0100
+++ linux-2.6.23-rc2-020_filter_nodemask/include/linux/gfp.h	2007-08-08 22:18:09.000000000 +0100
@@ -141,6 +141,9 @@ static inline void arch_alloc_page(struc
 extern struct page *
 FASTCALL(__alloc_pages(gfp_t, unsigned int, struct zonelist *));
 
+extern struct page *
+FASTCALL(__alloc_pages_nodemask(gfp_t, nodemask_t *, unsigned int, struct zonelist *));
+
 static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 						unsigned int order)
 {
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc2-015_treat_movable_highest/include/linux/mempolicy.h linux-2.6.23-rc2-020_filter_nodemask/include/linux/mempolicy.h
--- linux-2.6.23-rc2-015_treat_movable_highest/include/linux/mempolicy.h	2007-08-08 17:51:21.000000000 +0100
+++ linux-2.6.23-rc2-020_filter_nodemask/include/linux/mempolicy.h	2007-08-08 22:18:09.000000000 +0100
@@ -63,9 +63,8 @@ struct mempolicy {
 	atomic_t refcnt;
 	short policy; 	/* See MPOL_* above */
 	union {
-		struct zonelist  *zonelist;	/* bind */
 		short 		 preferred_node; /* preferred */
-		nodemask_t	 nodes;		/* interleave */
+		nodemask_t	 nodes;		/* interleave/bind */
 		/* undefined for default */
 	} v;
 	nodemask_t cpuset_mems_allowed;	/* mempolicy relative to these nodes */
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc2-015_treat_movable_highest/include/linux/mmzone.h linux-2.6.23-rc2-020_filter_nodemask/include/linux/mmzone.h
--- linux-2.6.23-rc2-015_treat_movable_highest/include/linux/mmzone.h	2007-08-08 17:51:13.000000000 +0100
+++ linux-2.6.23-rc2-020_filter_nodemask/include/linux/mmzone.h	2007-08-08 22:28:43.000000000 +0100
@@ -637,20 +637,39 @@ extern struct zone *next_zone(struct zon
 	     zone;					\
 	     zone = next_zone(zone))
 
+static inline int zone_allowed_by_nodemask(struct zone *zone, nodemask_t *nodes)
+{
+#ifdef NUMA
+	if (likely(nodes == NULL))
+		return 1;
+
+	/* zone_to_nid not available in this context */
+	return node_isset(zone->node, *nodes);
+#else
+	return 1;
+#endif /* CONFIG_NUMA */
+}
+
 /* Returns the first zone at or below highest_zoneidx in a zonelist */
 static inline struct zone **first_zones_zonelist(struct zonelist *zonelist,
+					nodemask_t *nodes,
 					enum zone_type highest_zoneidx)
 {
 	struct zone **z;
-	for (z = zonelist->zones; *z && zone_idx(*z) > highest_zoneidx; z++);
+	for (z = zonelist->zones;
+		*z && zone_idx(*z) > highest_zoneidx && !zone_allowed_by_nodemask(*z, nodes);
+		z++);
 	return z;
 }
 
 /* Returns the next zone at or below highest_zoneidx in a zonelist */
 static inline struct zone **next_zones_zonelist(struct zone **z,
+					nodemask_t *nodes,
 					enum zone_type highest_zoneidx)
 {
-	for (++z; *z && zone_idx(*z) > highest_zoneidx; z++);
+	for (++z;
+		*z && zone_idx(*z) > highest_zoneidx && !zone_allowed_by_nodemask(*z, nodes);
+		z++);
 	return z;
 }
 
@@ -664,9 +683,25 @@ static inline struct zone **next_zones_z
  * This iterator iterates though all zones at or below a given zone index.
  */
 #define for_each_zone_zonelist(zone, z, zlist, highidx) \
-	for (z = first_zones_zonelist(zlist, highidx), zone = *z;	\
+	for (z = first_zones_zonelist(zlist, NULL, highidx), zone = *z;	\
+		zone;							\
+		z = next_zones_zonelist(z, NULL, highidx), zone = *z)
+
+/**
+ * for_each_zone_zonelist_nodemask - helper macro to iterate over valid zones in a zonelist at or below a given zone index and within a nodemask
+ * @zone - The current zone in the iterator
+ * @z - The current pointer within zonelist->zones being iterated
+ * @zlist - The zonelist being iterated
+ * @highidx - The zone index of the highest zone to return
+ * @nodemask - Nodemask allowed by the allocator
+ *
+ * This iterator iterates though all zones at or below a given zone index and
+ * within a given nodemask
+ */
+#define for_each_zone_zonelist_nodemask(zone, z, zlist, highidx, nodemask) \
+	for (z = first_zones_zonelist(zlist, nodemask, highidx), zone = *z;	\
 		zone;							\
-		z = next_zones_zonelist(z, highidx), zone = *z)
+		z = next_zones_zonelist(z, nodemask, highidx), zone = *z)
 
 #ifdef CONFIG_SPARSEMEM
 #include <asm/sparsemem.h>
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc2-015_treat_movable_highest/kernel/cpuset.c linux-2.6.23-rc2-020_filter_nodemask/kernel/cpuset.c
--- linux-2.6.23-rc2-015_treat_movable_highest/kernel/cpuset.c	2007-08-04 03:49:55.000000000 +0100
+++ linux-2.6.23-rc2-020_filter_nodemask/kernel/cpuset.c	2007-08-08 22:18:09.000000000 +0100
@@ -2327,21 +2327,19 @@ nodemask_t cpuset_mems_allowed(struct ta
 }
 
 /**
- * cpuset_zonelist_valid_mems_allowed - check zonelist vs. curremt mems_allowed
+ * cpuset_nodemask_valid_mems_allowed - check zonelist vs. curremt mems_allowed
  * @zl: the zonelist to be checked
  *
  * Are any of the nodes on zonelist zl allowed in current->mems_allowed?
  */
-int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl)
+int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
 {
-	int i;
-
-	for (i = 0; zl->zones[i]; i++) {
-		int nid = zone_to_nid(zl->zones[i]);
+	int nid;
 
+	for_each_node_mask(nid, *nodemask)
 		if (node_isset(nid, current->mems_allowed))
 			return 1;
-	}
+
 	return 0;
 }
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc2-015_treat_movable_highest/mm/mempolicy.c linux-2.6.23-rc2-020_filter_nodemask/mm/mempolicy.c
--- linux-2.6.23-rc2-015_treat_movable_highest/mm/mempolicy.c	2007-08-08 17:51:21.000000000 +0100
+++ linux-2.6.23-rc2-020_filter_nodemask/mm/mempolicy.c	2007-08-08 22:31:00.000000000 +0100
@@ -131,41 +131,20 @@ static int mpol_check_policy(int mode, n
 	return nodes_subset(*nodes, node_online_map) ? 0 : -EINVAL;
 }
 
-/* Generate a custom zonelist for the BIND policy. */
-static struct zonelist *bind_zonelist(nodemask_t *nodes)
+/* Check that the nodemask contains at least one populated zone */
+static int is_valid_nodemask(nodemask_t *nodemask)
 {
-	struct zonelist *zl;
-	int num, max, nd;
-	enum zone_type k;
+	int nd, k;
 
-	max = 1 + MAX_NR_ZONES * nodes_weight(*nodes);
-	max++;			/* space for zlcache_ptr (see mmzone.h) */
-	zl = kmalloc(sizeof(struct zone *) * max, GFP_KERNEL);
-	if (!zl)
-		return ERR_PTR(-ENOMEM);
-	zl->zlcache_ptr = NULL;
-	num = 0;
-	/* First put in the highest zones from all nodes, then all the next 
-	   lower zones etc. Avoid empty zones because the memory allocator
-	   doesn't like them. If you implement node hot removal you
-	   have to fix that. */
-	k = MAX_NR_ZONES - 1;
-	while (1) {
-		for_each_node_mask(nd, *nodes) { 
-			struct zone *z = &NODE_DATA(nd)->node_zones[k];
-			if (z->present_pages > 0) 
-				zl->zones[num++] = z;
-		}
-		if (k == 0)
-			break;
-		k--;
-	}
-	if (num == 0) {
-		kfree(zl);
-		return ERR_PTR(-EINVAL);
+	/* Check that there is something useful in this mask */
+	k = policy_zone;
+	for_each_node_mask(nd, *nodemask) {
+		struct zone *z = &NODE_DATA(nd)->node_zones[k];
+		if (z->present_pages > 0)
+			return 1;
 	}
-	zl->zones[num] = NULL;
-	return zl;
+
+	return 0;
 }
 
 /* Create a new policy */
@@ -196,12 +175,11 @@ static struct mempolicy *mpol_new(int mo
 			policy->v.preferred_node = -1;
 		break;
 	case MPOL_BIND:
-		policy->v.zonelist = bind_zonelist(nodes);
-		if (IS_ERR(policy->v.zonelist)) {
-			void *error_code = policy->v.zonelist;
+		if (!is_valid_nodemask(nodes)) {
 			kmem_cache_free(policy_cache, policy);
-			return error_code;
+			return ERR_PTR(-EINVAL);
 		}
+		policy->v.nodes = *nodes;
 		break;
 	}
 	policy->policy = mode;
@@ -479,14 +457,10 @@ long do_set_mempolicy(int mode, nodemask
 /* Fill a zone bitmap for a policy */
 static void get_zonemask(struct mempolicy *p, nodemask_t *nodes)
 {
-	int i;
-
 	nodes_clear(*nodes);
 	switch (p->policy) {
 	case MPOL_BIND:
-		for (i = 0; p->v.zonelist->zones[i]; i++)
-			node_set(zone_to_nid(p->v.zonelist->zones[i]),
-				*nodes);
+		*nodes = p->v.nodes;
 		break;
 	case MPOL_DEFAULT:
 		break;
@@ -1090,6 +1064,17 @@ static struct mempolicy * get_vma_policy
 	return pol;
 }
 
+/* Return a nodemask represnting a mempolicy */
+static nodemask_t *nodemask_policy(gfp_t gfp, struct mempolicy *policy)
+{
+	/* Lower zones don't get a nodemask applied  for MPOL_BIND */
+	if (policy->policy == MPOL_BIND &&
+			gfp_zone(gfp) >= policy_zone &&
+			cpuset_nodemask_valid_mems_allowed(&policy->v.nodes))
+		return &policy->v.nodes;
+
+	return NULL;
+}
 /* Return a zonelist representing a mempolicy */
 static struct zonelist *zonelist_policy(gfp_t gfp, struct mempolicy *policy)
 {
@@ -1102,11 +1087,6 @@ static struct zonelist *zonelist_policy(
 			nd = numa_node_id();
 		break;
 	case MPOL_BIND:
-		/* Lower zones don't get a policy applied */
-		/* Careful: current->mems_allowed might have moved */
-		if (gfp_zone(gfp) >= policy_zone)
-			if (cpuset_zonelist_valid_mems_allowed(policy->v.zonelist))
-				return policy->v.zonelist;
 		/*FALL THROUGH*/
 	case MPOL_INTERLEAVE: /* should not happen */
 	case MPOL_DEFAULT:
@@ -1145,12 +1125,17 @@ unsigned slab_node(struct mempolicy *pol
 	case MPOL_INTERLEAVE:
 		return interleave_nodes(policy);
 
-	case MPOL_BIND:
+	case MPOL_BIND: {
 		/*
 		 * Follow bind policy behavior and start allocation at the
 		 * first node.
 		 */
-		return zone_to_nid(policy->v.zonelist->zones[0]);
+		struct zonelist *zonelist;
+		struct zone **z;
+		zonelist = &NODE_DATA(numa_node_id())->node_zonelist;
+		z = first_zones_zonelist(zonelist, &policy->v.nodes, gfp_zone(GFP_KERNEL));
+		return zone_to_nid(*z);
+	}
 
 	case MPOL_PREFERRED:
 		if (policy->v.preferred_node >= 0)
@@ -1268,7 +1253,8 @@ alloc_page_vma(gfp_t gfp, struct vm_area
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
 		return alloc_page_interleave(gfp, 0, nid);
 	}
-	return __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
+	return __alloc_pages_nodemask(gfp, nodemask_policy(gfp, pol), 0,
+						zonelist_policy(gfp, pol));
 }
 
 /**
@@ -1326,14 +1312,6 @@ struct mempolicy *__mpol_copy(struct mem
 	}
 	*new = *old;
 	atomic_set(&new->refcnt, 1);
-	if (new->policy == MPOL_BIND) {
-		int sz = ksize(old->v.zonelist);
-		new->v.zonelist = kmemdup(old->v.zonelist, sz, GFP_KERNEL);
-		if (!new->v.zonelist) {
-			kmem_cache_free(policy_cache, new);
-			return ERR_PTR(-ENOMEM);
-		}
-	}
 	return new;
 }
 
@@ -1347,17 +1325,12 @@ int __mpol_equal(struct mempolicy *a, st
 	switch (a->policy) {
 	case MPOL_DEFAULT:
 		return 1;
+	case MPOL_BIND:
+		/* Fallthrough */
 	case MPOL_INTERLEAVE:
 		return nodes_equal(a->v.nodes, b->v.nodes);
 	case MPOL_PREFERRED:
 		return a->v.preferred_node == b->v.preferred_node;
-	case MPOL_BIND: {
-		int i;
-		for (i = 0; a->v.zonelist->zones[i]; i++)
-			if (a->v.zonelist->zones[i] != b->v.zonelist->zones[i])
-				return 0;
-		return b->v.zonelist->zones[i] == NULL;
-	}
 	default:
 		BUG();
 		return 0;
@@ -1369,8 +1342,6 @@ void __mpol_free(struct mempolicy *p)
 {
 	if (!atomic_dec_and_test(&p->refcnt))
 		return;
-	if (p->policy == MPOL_BIND)
-		kfree(p->v.zonelist);
 	p->policy = MPOL_DEFAULT;
 	kmem_cache_free(policy_cache, p);
 }
@@ -1660,6 +1631,8 @@ void mpol_rebind_policy(struct mempolicy
 	switch (pol->policy) {
 	case MPOL_DEFAULT:
 		break;
+	case MPOL_BIND:
+		/* Fall through */
 	case MPOL_INTERLEAVE:
 		nodes_remap(tmp, pol->v.nodes, *mpolmask, *newmask);
 		pol->v.nodes = tmp;
@@ -1672,32 +1645,6 @@ void mpol_rebind_policy(struct mempolicy
 						*mpolmask, *newmask);
 		*mpolmask = *newmask;
 		break;
-	case MPOL_BIND: {
-		nodemask_t nodes;
-		struct zone **z;
-		struct zonelist *zonelist;
-
-		nodes_clear(nodes);
-		for (z = pol->v.zonelist->zones; *z; z++)
-			node_set(zone_to_nid(*z), nodes);
-		nodes_remap(tmp, nodes, *mpolmask, *newmask);
-		nodes = tmp;
-
-		zonelist = bind_zonelist(&nodes);
-
-		/* If no mem, then zonelist is NULL and we keep old zonelist.
-		 * If that old zonelist has no remaining mems_allowed nodes,
-		 * then zonelist_policy() will "FALL THROUGH" to MPOL_DEFAULT.
-		 */
-
-		if (!IS_ERR(zonelist)) {
-			/* Good - got mem - substitute new zonelist */
-			kfree(pol->v.zonelist);
-			pol->v.zonelist = zonelist;
-		}
-		*mpolmask = *newmask;
-		break;
-	}
 	default:
 		BUG();
 		break;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc2-015_treat_movable_highest/mm/mmzone.c linux-2.6.23-rc2-020_filter_nodemask/mm/mmzone.c
--- linux-2.6.23-rc2-015_treat_movable_highest/mm/mmzone.c	2007-08-04 03:49:55.000000000 +0100
+++ linux-2.6.23-rc2-020_filter_nodemask/mm/mmzone.c	2007-08-08 22:18:09.000000000 +0100
@@ -8,6 +8,7 @@
 #include <linux/stddef.h>
 #include <linux/mmzone.h>
 #include <linux/module.h>
+#include <linux/mm.h>
 
 struct pglist_data *first_online_pgdat(void)
 {
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc2-015_treat_movable_highest/mm/page_alloc.c linux-2.6.23-rc2-020_filter_nodemask/mm/page_alloc.c
--- linux-2.6.23-rc2-015_treat_movable_highest/mm/page_alloc.c	2007-08-08 17:51:13.000000000 +0100
+++ linux-2.6.23-rc2-020_filter_nodemask/mm/page_alloc.c	2007-08-08 22:29:10.000000000 +0100
@@ -1147,7 +1147,7 @@ static void zlc_mark_zone_full(struct zo
  * a page.
  */
 static struct page *
-get_page_from_freelist(gfp_t gfp_mask, unsigned int order,
+get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 		struct zonelist *zonelist, int alloc_flags)
 {
 	struct zone **z;
@@ -1164,7 +1164,8 @@ zonelist_scan:
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
-	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
+	for_each_zone_zonelist_nodemask(zone, z, zonelist,
+						high_zoneidx, nodemask) {
 		if (NUMA_BUILD && zlc_active &&
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
@@ -1218,8 +1219,8 @@ try_next_zone:
  * This is the 'heart' of the zoned buddy allocator.
  */
 struct page * fastcall
-__alloc_pages(gfp_t gfp_mask, unsigned int order,
-		struct zonelist *zonelist)
+__alloc_pages_nodemask(gfp_t gfp_mask, nodemask_t *nodemask,
+		unsigned int order, struct zonelist *zonelist)
 {
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
 	struct zone **z;
@@ -1243,7 +1244,7 @@ restart:
 		return NULL;
 	}
 
-	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
+	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
 				zonelist, ALLOC_WMARK_LOW|ALLOC_CPUSET);
 	if (page)
 		goto got_pg;
@@ -1288,7 +1289,8 @@ restart:
 	 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
-	page = get_page_from_freelist(gfp_mask, order, zonelist, alloc_flags);
+	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
+									alloc_flags);
 	if (page)
 		goto got_pg;
 
@@ -1300,8 +1302,8 @@ rebalance:
 		if (!(gfp_mask & __GFP_NOMEMALLOC)) {
 nofail_alloc:
 			/* go through the zonelist yet again, ignoring mins */
-			page = get_page_from_freelist(gfp_mask, order,
-				zonelist, ALLOC_NO_WATERMARKS);
+			page = get_page_from_freelist(gfp_mask, nodemask,
+				order, zonelist, ALLOC_NO_WATERMARKS);
 			if (page)
 				goto got_pg;
 			if (gfp_mask & __GFP_NOFAIL) {
@@ -1332,7 +1334,7 @@ nofail_alloc:
 	cond_resched();
 
 	if (likely(did_some_progress)) {
-		page = get_page_from_freelist(gfp_mask, order,
+		page = get_page_from_freelist(gfp_mask, nodemask, order,
 						zonelist, alloc_flags);
 		if (page)
 			goto got_pg;
@@ -1343,8 +1345,8 @@ nofail_alloc:
 		 * a parallel oom killing, we must fail if we're still
 		 * under heavy pressure.
 		 */
-		page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
-				zonelist, ALLOC_WMARK_HIGH|ALLOC_CPUSET);
+		page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
+				order, zonelist, ALLOC_WMARK_HIGH|ALLOC_CPUSET);
 		if (page)
 			goto got_pg;
 
@@ -1388,6 +1390,14 @@ got_pg:
 	return page;
 }
 
+struct page * fastcall
+__alloc_pages(gfp_t gfp_mask, unsigned int order,
+		struct zonelist *zonelist)
+{
+	return __alloc_pages_nodemask(gfp_mask, NULL, order, zonelist);
+}
+
+
 EXPORT_SYMBOL(__alloc_pages);
 
 /*
@@ -1980,7 +1990,6 @@ static void build_zonelists(pg_data_t *p
 /* Construct the zonelist performance cache - see further mmzone.h */
 static void build_zonelist_cache(pg_data_t *pgdat)
 {
-	int i;
 	struct zonelist *zonelist;
 	struct zonelist_cache *zlc;
 	struct zone **z;
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
