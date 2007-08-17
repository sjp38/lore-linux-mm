From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070817201828.14792.57905.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070817201647.14792.2690.sendpatchset@skynet.skynet.ie>
References: <20070817201647.14792.2690.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 5/6] Filter based on a nodemask as well as a gfp_mask
Date: Fri, 17 Aug 2007 21:18:28 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee.Schermerhorn@hp.com, ak@suse.de, clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The MPOL_BIND policy creates a zonelist that is used for allocations belonging
to that thread that can use the policy_zone. As the zonelist is already being
filtered based on a zone id, this patch adds a version of __alloc_pages()
that takes a nodemask for further filtering. This eliminates the need for
MPOL_BIND to create a custom zonelist. The practical upside of this is that
allocations using MPOL_BIND should now use nodes closer to the running CPU
first instead of using nodes in numeric order.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 fs/buffer.c               |    2 
 include/linux/cpuset.h    |    4 -
 include/linux/gfp.h       |    4 +
 include/linux/mempolicy.h |    3 
 include/linux/mmzone.h    |   59 +++++++++++++---
 kernel/cpuset.c           |   16 +---
 mm/mempolicy.c            |  145 +++++++++++------------------------------
 mm/page_alloc.c           |   34 ++++++---
 8 files changed, 128 insertions(+), 139 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-020_gfpskip/fs/buffer.c linux-2.6.23-rc3-030_filter_nodemask/fs/buffer.c
--- linux-2.6.23-rc3-020_gfpskip/fs/buffer.c	2007-08-17 16:36:04.000000000 +0100
+++ linux-2.6.23-rc3-030_filter_nodemask/fs/buffer.c	2007-08-17 16:56:36.000000000 +0100
@@ -355,7 +355,7 @@ static void free_more_memory(void)
 
 	for_each_online_node(nid) {
 		zones = first_zones_zonelist(node_zonelist(nid),
-			gfp_zone(GFP_NOFS));
+			NULL, gfp_zone(GFP_NOFS));
 		if (*zones)
 			try_to_free_pages(node_zonelist(nid), 0, GFP_NOFS);
 	}
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-020_gfpskip/include/linux/cpuset.h linux-2.6.23-rc3-030_filter_nodemask/include/linux/cpuset.h
--- linux-2.6.23-rc3-020_gfpskip/include/linux/cpuset.h	2007-08-13 05:25:24.000000000 +0100
+++ linux-2.6.23-rc3-030_filter_nodemask/include/linux/cpuset.h	2007-08-17 16:56:36.000000000 +0100
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
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-020_gfpskip/include/linux/gfp.h linux-2.6.23-rc3-030_filter_nodemask/include/linux/gfp.h
--- linux-2.6.23-rc3-020_gfpskip/include/linux/gfp.h	2007-08-17 16:35:55.000000000 +0100
+++ linux-2.6.23-rc3-030_filter_nodemask/include/linux/gfp.h	2007-08-17 16:56:36.000000000 +0100
@@ -141,6 +141,10 @@ static inline void arch_alloc_page(struc
 extern struct page *
 FASTCALL(__alloc_pages(gfp_t, unsigned int, struct zonelist *));
 
+extern struct page *
+FASTCALL(__alloc_pages_nodemask(gfp_t, unsigned int,
+				struct zonelist *, nodemask_t *nodemask));
+
 static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 						unsigned int order)
 {
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-020_gfpskip/include/linux/mempolicy.h linux-2.6.23-rc3-030_filter_nodemask/include/linux/mempolicy.h
--- linux-2.6.23-rc3-020_gfpskip/include/linux/mempolicy.h	2007-08-17 16:35:55.000000000 +0100
+++ linux-2.6.23-rc3-030_filter_nodemask/include/linux/mempolicy.h	2007-08-17 16:56:36.000000000 +0100
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
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-020_gfpskip/include/linux/mmzone.h linux-2.6.23-rc3-030_filter_nodemask/include/linux/mmzone.h
--- linux-2.6.23-rc3-020_gfpskip/include/linux/mmzone.h	2007-08-17 16:56:20.000000000 +0100
+++ linux-2.6.23-rc3-030_filter_nodemask/include/linux/mmzone.h	2007-08-17 17:31:05.000000000 +0100
@@ -696,6 +696,16 @@ static inline struct zonelist *node_zone
 	return &NODE_DATA(nid)->node_zonelist;
 }
 
+static inline int zone_in_nodemask(unsigned long zone_addr,
+				nodemask_t *nodes)
+{
+#ifdef CONFIG_NUMA
+	return node_isset(zonelist_zone(zone_addr)->node, *nodes);
+#else
+	return 1;
+#endif /* CONFIG_NUMA */
+}
+
 static inline unsigned long *zonelist_gfp_skip(struct zonelist *zonelist,
 					enum zone_type highest_zoneidx)
 {
@@ -704,26 +714,57 @@ static inline unsigned long *zonelist_gf
 
 /* Returns the first zone at or below highest_zoneidx in a zonelist */
 static inline unsigned long *first_zones_zonelist(struct zonelist *zonelist,
+					nodemask_t *nodes,
 					enum zone_type highest_zoneidx)
 {
-	unsigned long *z;
-	for (z = zonelist_gfp_skip(zonelist, highest_zoneidx);
-		zonelist_zone_idx(*z) > highest_zoneidx;
-		z++);
+	unsigned long *z = zonelist_gfp_skip(zonelist, highest_zoneidx);
+
+	/* Only filter based on the nodemask if it's set */
+	if (likely(nodes == NULL))
+		for (;zonelist_zone_idx(*z) > highest_zoneidx;
+			z++);
+	else
+		for (;zonelist_zone_idx(*z) > highest_zoneidx ||
+				!zone_in_nodemask(*z, nodes);
+			z++);
 	return z;
 }
 
 /* Returns the next zone at or below highest_zoneidx in a zonelist */
 static inline unsigned long *next_zones_zonelist(unsigned long *z,
+					nodemask_t *nodes,
 					enum zone_type highest_zoneidx)
 {
-	for (++z;
-		zonelist_zone_idx(*z) > highest_zoneidx;
-		z++);
+	z++;
+
+	/* Only filter based on the nodemask if it's set */
+	if (likely(nodes == NULL))
+		for (;zonelist_zone_idx(*z) > highest_zoneidx;
+			z++);
+	else
+		for (;zonelist_zone_idx(*z) > highest_zoneidx ||
+				!zone_in_nodemask(*z, nodes);
+			z++);
 	return z;
 }
 
 /**
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
+	for (z = first_zones_zonelist(zlist, nodemask, highidx), zone = zonelist_zone(*z); \
+		zone;							\
+		z = next_zones_zonelist(z, nodemask, highidx), zone = zonelist_zone(*z))
+
+/**
  * for_each_zone_zonelist - helper macro to iterate over valid zones in a zonelist at or below a given zone index
  * @zone - The current zone in the iterator
  * @z - The current pointer within zonelist->zones being iterated
@@ -733,9 +774,7 @@ static inline unsigned long *next_zones_
  * This iterator iterates though all zones at or below a given zone index.
  */
 #define for_each_zone_zonelist(zone, z, zlist, highidx) \
-	for (z = first_zones_zonelist(zlist, highidx), zone = zonelist_zone(*z); \
-		zone; \
-		z = next_zones_zonelist(z, highidx), zone = zonelist_zone(*z))
+	for_each_zone_zonelist_nodemask(zone, z, zlist, highidx, NULL)
 
 #ifdef CONFIG_SPARSEMEM
 #include <asm/sparsemem.h>
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-020_gfpskip/kernel/cpuset.c linux-2.6.23-rc3-030_filter_nodemask/kernel/cpuset.c
--- linux-2.6.23-rc3-020_gfpskip/kernel/cpuset.c	2007-08-17 16:36:04.000000000 +0100
+++ linux-2.6.23-rc3-030_filter_nodemask/kernel/cpuset.c	2007-08-17 16:56:36.000000000 +0100
@@ -2327,21 +2327,19 @@ nodemask_t cpuset_mems_allowed(struct ta
 }
 
 /**
- * cpuset_zonelist_valid_mems_allowed - check zonelist vs. curremt mems_allowed
- * @zl: the zonelist to be checked
+ * cpuset_nodemask_valid_mems_allowed - check nodemask vs. curremt mems_allowed
+ * @nodemask: the nodemask to be checked
  *
- * Are any of the nodes on zonelist zl allowed in current->mems_allowed?
+ * Are any of the nodes in the nodemask allowed in current->mems_allowed?
  */
-int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl)
+int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
 {
-	int i;
-
-	for (i = 0; zl->_zones[i]; i++) {
-		int nid = zone_to_nid(zonelist_zone(zl->_zones[i]));
+	int nid;
 
+	for_each_node_mask(nid, *nodemask)
 		if (node_isset(nid, current->mems_allowed))
 			return 1;
-	}
+
 	return 0;
 }
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-020_gfpskip/mm/mempolicy.c linux-2.6.23-rc3-030_filter_nodemask/mm/mempolicy.c
--- linux-2.6.23-rc3-020_gfpskip/mm/mempolicy.c	2007-08-17 16:55:31.000000000 +0100
+++ linux-2.6.23-rc3-030_filter_nodemask/mm/mempolicy.c	2007-08-17 17:00:07.000000000 +0100
@@ -131,43 +131,20 @@ static int mpol_check_policy(int mode, n
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
-	max += sizeof(unsigned short) * MAX_NR_ZONES;	/* gfp_skip */
-	zl = kmalloc(sizeof(struct zone *) * max, GFP_KERNEL);
-	if (!zl)
-		return ERR_PTR(-ENOMEM);
-	zl->zlcache_ptr = NULL;
-	memset(zl->gfp_skip, 0, sizeof(zl->gfp_skip));
-	num = 0;
-	/* First put in the highest zones from all nodes, then all the next 
-	   lower zones etc. Avoid empty zones because the memory allocator
-	   doesn't like them. If you implement node hot removal you
-	   have to fix that. */
+	/* Check that there is something useful in this mask */
 	k = policy_zone;
-	while (1) {
-		for_each_node_mask(nd, *nodes) { 
-			struct zone *z = &NODE_DATA(nd)->node_zones[k];
-			if (z->present_pages > 0) 
-				zl->_zones[num++] = encode_zone_idx(z);
-		}
-		if (k == 0)
-			break;
-		k--;
-	}
-	if (num == 0) {
-		kfree(zl);
-		return ERR_PTR(-EINVAL);
+	for_each_node_mask(nd, *nodemask) {
+		struct zone *z = &NODE_DATA(nd)->node_zones[k];
+		if (z->present_pages > 0)
+			return 1;
 	}
-	zl->_zones[num] = 0;
-	return zl;
+
+	return 0;
 }
 
 /* Create a new policy */
@@ -198,12 +175,11 @@ static struct mempolicy *mpol_new(int mo
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
@@ -481,19 +457,13 @@ long do_set_mempolicy(int mode, nodemask
 /* Fill a zone bitmap for a policy */
 static void get_zonemask(struct mempolicy *p, nodemask_t *nodes)
 {
-	int i;
 
 	nodes_clear(*nodes);
 	switch (p->policy) {
-	case MPOL_BIND:
-		for (i = 0; p->v.zonelist->_zones[i]; i++) {
-			struct zone *zone;
-			zone = zonelist_zone(p->v.zonelist->_zones[i]);
-			node_set(zone_to_nid(zone), *nodes);
-		}
-		break;
 	case MPOL_DEFAULT:
 		break;
+	case MPOL_BIND:
+		/* Fall through */
 	case MPOL_INTERLEAVE:
 		*nodes = p->v.nodes;
 		break;
@@ -1094,6 +1064,17 @@ static struct mempolicy * get_vma_policy
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
@@ -1106,11 +1087,6 @@ static struct zonelist *zonelist_policy(
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
@@ -1149,12 +1125,19 @@ unsigned slab_node(struct mempolicy *pol
 	case MPOL_INTERLEAVE:
 		return interleave_nodes(policy);
 
-	case MPOL_BIND:
+	case MPOL_BIND: {
 		/*
 		 * Follow bind policy behavior and start allocation at the
 		 * first node.
 		 */
-		return zone_to_nid(zonelist_zone(policy->v.zonelist->_zones[0]));
+		struct zonelist *zonelist;
+		unsigned long *z;
+		enum zone_type highest_zoneidx = gfp_zone(GFP_KERNEL);
+		zonelist = &NODE_DATA(numa_node_id())->node_zonelist;
+		z = first_zones_zonelist(zonelist, &policy->v.nodes,
+							highest_zoneidx);
+		return zone_to_nid(zonelist_zone(*z));
+	}
 
 	case MPOL_PREFERRED:
 		if (policy->v.preferred_node >= 0)
@@ -1272,7 +1255,8 @@ alloc_page_vma(gfp_t gfp, struct vm_area
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
 		return alloc_page_interleave(gfp, 0, nid);
 	}
-	return __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
+	return __alloc_pages_nodemask(gfp, 0,
+			zonelist_policy(gfp, pol), nodemask_policy(gfp, pol));
 }
 
 /**
@@ -1330,14 +1314,6 @@ struct mempolicy *__mpol_copy(struct mem
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
 
@@ -1351,21 +1327,12 @@ int __mpol_equal(struct mempolicy *a, st
 	switch (a->policy) {
 	case MPOL_DEFAULT:
 		return 1;
+	case MPOL_BIND:
+		/* Fall through */
 	case MPOL_INTERLEAVE:
 		return nodes_equal(a->v.nodes, b->v.nodes);
 	case MPOL_PREFERRED:
 		return a->v.preferred_node == b->v.preferred_node;
-	case MPOL_BIND: {
-		int i;
-		for (i = 0; a->v.zonelist->_zones[i]; i++) {
-			struct zone *za, *zb;
-			za = zonelist_zone(a->v.zonelist->_zones[i]);
-			zb = zonelist_zone(b->v.zonelist->_zones[i]);
-			if (za != zb)
-				return 0;
-		}
-		return b->v.zonelist->_zones[i] == 0;
-	}
 	default:
 		BUG();
 		return 0;
@@ -1377,8 +1344,6 @@ void __mpol_free(struct mempolicy *p)
 {
 	if (!atomic_dec_and_test(&p->refcnt))
 		return;
-	if (p->policy == MPOL_BIND)
-		kfree(p->v.zonelist);
 	p->policy = MPOL_DEFAULT;
 	kmem_cache_free(policy_cache, p);
 }
@@ -1668,6 +1633,8 @@ void mpol_rebind_policy(struct mempolicy
 	switch (pol->policy) {
 	case MPOL_DEFAULT:
 		break;
+	case MPOL_BIND:
+		/* Fall through */
 	case MPOL_INTERLEAVE:
 		nodes_remap(tmp, pol->v.nodes, *mpolmask, *newmask);
 		pol->v.nodes = tmp;
@@ -1680,32 +1647,6 @@ void mpol_rebind_policy(struct mempolicy
 						*mpolmask, *newmask);
 		*mpolmask = *newmask;
 		break;
-	case MPOL_BIND: {
-		nodemask_t nodes;
-		unsigned long *z;
-		struct zonelist *zonelist;
-
-		nodes_clear(nodes);
-		for (z = pol->v.zonelist->_zones; *z; z++)
-			node_set(zone_to_nid(zonelist_zone(*z)), nodes);
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
@@ -1768,9 +1709,7 @@ static inline int mpol_to_str(char *buff
 		break;
 
 	case MPOL_BIND:
-		get_zonemask(pol, &nodes);
-		break;
-
+		/* Fall through */
 	case MPOL_INTERLEAVE:
 		nodes = pol->v.nodes;
 		break;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-020_gfpskip/mm/page_alloc.c linux-2.6.23-rc3-030_filter_nodemask/mm/page_alloc.c
--- linux-2.6.23-rc3-020_gfpskip/mm/page_alloc.c	2007-08-17 16:55:31.000000000 +0100
+++ linux-2.6.23-rc3-030_filter_nodemask/mm/page_alloc.c	2007-08-17 17:00:27.000000000 +0100
@@ -1147,7 +1147,7 @@ static void zlc_mark_zone_full(struct zo
  * a page.
  */
 static struct page *
-get_page_from_freelist(gfp_t gfp_mask, unsigned int order,
+get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 		struct zonelist *zonelist, int high_zoneidx, int alloc_flags)
 {
 	unsigned long *z;
@@ -1159,7 +1159,7 @@ get_page_from_freelist(gfp_t gfp_mask, u
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 
-	z = first_zones_zonelist(zonelist, high_zoneidx);
+	z = first_zones_zonelist(zonelist, nodemask, high_zoneidx);
 	classzone = zonelist_zone(*z);
 	classzone_idx = zonelist_zone_idx(*z);
 
@@ -1168,7 +1168,8 @@ zonelist_scan:
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
-	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
+	for_each_zone_zonelist_nodemask(zone, z, zonelist,
+						high_zoneidx, nodemask) {
 		if (NUMA_BUILD && zlc_active &&
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
@@ -1222,8 +1223,8 @@ try_next_zone:
  * This is the 'heart' of the zoned buddy allocator.
  */
 struct page * fastcall
-__alloc_pages(gfp_t gfp_mask, unsigned int order,
-		struct zonelist *zonelist)
+__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
+			struct zonelist *zonelist, nodemask_t *nodemask)
 {
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
@@ -1248,7 +1249,7 @@ restart:
 		return NULL;
 	}
 
-	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
+	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
 			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET);
 	if (page)
 		goto got_pg;
@@ -1293,7 +1294,7 @@ restart:
 	 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
-	page = get_page_from_freelist(gfp_mask, order, zonelist,
+	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
 						high_zoneidx, alloc_flags);
 	if (page)
 		goto got_pg;
@@ -1306,7 +1307,7 @@ rebalance:
 		if (!(gfp_mask & __GFP_NOMEMALLOC)) {
 nofail_alloc:
 			/* go through the zonelist yet again, ignoring mins */
-			page = get_page_from_freelist(gfp_mask, order,
+			page = get_page_from_freelist(gfp_mask, nodemask, order,
 				zonelist, high_zoneidx, ALLOC_NO_WATERMARKS);
 			if (page)
 				goto got_pg;
@@ -1338,7 +1339,7 @@ nofail_alloc:
 	cond_resched();
 
 	if (likely(did_some_progress)) {
-		page = get_page_from_freelist(gfp_mask, order,
+		page = get_page_from_freelist(gfp_mask, nodemask, order,
 					zonelist, high_zoneidx, alloc_flags);
 		if (page)
 			goto got_pg;
@@ -1349,8 +1350,9 @@ nofail_alloc:
 		 * a parallel oom killing, we must fail if we're still
 		 * under heavy pressure.
 		 */
-		page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
-			zonelist, high_zoneidx, ALLOC_WMARK_HIGH|ALLOC_CPUSET);
+		page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
+			order, zonelist, high_zoneidx,
+			ALLOC_WMARK_HIGH|ALLOC_CPUSET);
 		if (page)
 			goto got_pg;
 
@@ -1394,6 +1396,14 @@ got_pg:
 	return page;
 }
 
+struct page * fastcall
+__alloc_pages(gfp_t gfp_mask, unsigned int order,
+		struct zonelist *zonelist)
+{
+	return __alloc_pages_nodemask(gfp_mask, order, zonelist, NULL);
+}
+
+
 EXPORT_SYMBOL(__alloc_pages);
 
 /*
@@ -2055,7 +2065,7 @@ static void build_zonelist_gfpskip(pg_da
 
 	for (target = 0; target < MAX_NR_ZONES; target++) {
 		unsigned long *z;
-		z = first_zones_zonelist(zl, target);
+		z = first_zones_zonelist(zl, NULL, target);
 		zl->gfp_skip[target] = z - zl->_zones;
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
