Date: Fri, 21 Apr 2006 13:13:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] split zonelist and use nodemask for page allocation [2/4]
 mempolicy
Message-Id: <20060421131324.0959d501.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Now mempolicy uses zonelist, which covers all (required) nodes.
This patch removes it because __alloc_pages_nodemask() is avaiable.

This will fix MPOL_MBIND behavior.

BTW, I think preferred_node + nodemask can be used at the same time if the
interface allows it.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: linux-2.6.17-rc1-mm2/include/linux/mempolicy.h
===================================================================
--- linux-2.6.17-rc1-mm2.orig/include/linux/mempolicy.h	2006-04-21 12:07:19.000000000 +0900
+++ linux-2.6.17-rc1-mm2/include/linux/mempolicy.h	2006-04-21 12:10:21.000000000 +0900
@@ -63,7 +63,6 @@
 	atomic_t refcnt;
 	short policy; 	/* See MPOL_* above */
 	union {
-		struct zonelist  *zonelist;	/* bind */
 		short 		 preferred_node; /* preferred */
 		nodemask_t	 nodes;		/* interleave */
 		/* undefined for default */
Index: linux-2.6.17-rc1-mm2/mm/mempolicy.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/mm/mempolicy.c	2006-04-21 12:07:19.000000000 +0900
+++ linux-2.6.17-rc1-mm2/mm/mempolicy.c	2006-04-21 12:10:21.000000000 +0900
@@ -21,9 +21,6 @@
  *
  * bind           Only allocate memory on a specific set of nodes,
  *                no fallback.
- *                FIXME: memory is allocated starting with the first node
- *                to the last. It would be better if bind would truly restrict
- *                the allocation to memory nodes instead
  *
  * preferred       Try a specific node first before normal fallback.
  *                As a special case node -1 here means do the allocation
@@ -131,32 +128,6 @@
 	return nodes_subset(*nodes, node_online_map) ? 0 : -EINVAL;
 }
 
-/* Generate a custom zonelist for the BIND policy. */
-static struct zonelist *bind_zonelist(nodemask_t *nodes)
-{
-	struct zonelist *zl;
-	int num, max, nd, k;
-
-	max = 1 + MAX_NR_ZONES * nodes_weight(*nodes);
-	zl = kmalloc(sizeof(struct zone *) * max, GFP_KERNEL);
-	if (!zl)
-		return NULL;
-	num = 0;
-	/* First put in the highest zones from all nodes, then all the next 
-	   lower zones etc. Avoid empty zones because the memory allocator
-	   doesn't like them. If you implement node hot removal you
-	   have to fix that. */
-	for (k = policy_zone; k >= 0; k--) { 
-		for_each_node_mask(nd, *nodes) { 
-			struct zone *z = &NODE_DATA(nd)->node_zones[k];
-			if (z->present_pages > 0) 
-				zl->zones[num++] = z;
-		}
-	}
-	zl->zones[num] = NULL;
-	return zl;
-}
-
 /* Create a new policy */
 static struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
 {
@@ -183,11 +154,7 @@
 			policy->v.preferred_node = -1;
 		break;
 	case MPOL_BIND:
-		policy->v.zonelist = bind_zonelist(nodes);
-		if (policy->v.zonelist == NULL) {
-			kmem_cache_free(policy_cache, policy);
-			return ERR_PTR(-ENOMEM);
-		}
+		policy->v.nodes = *nodes;
 		break;
 	}
 	policy->policy = mode;
@@ -474,14 +441,10 @@
 /* Fill a zone bitmap for a policy */
 static void get_zonemask(struct mempolicy *p, nodemask_t *nodes)
 {
-	int i;
-
 	nodes_clear(*nodes);
 	switch (p->policy) {
 	case MPOL_BIND:
-		for (i = 0; p->v.zonelist->zones[i]; i++)
-			node_set(p->v.zonelist->zones[i]->zone_pgdat->node_id,
-				*nodes);
+		*nodes = p->v.nodes;
 		break;
 	case MPOL_DEFAULT:
 		break;
@@ -1060,35 +1023,6 @@
 	return pol;
 }
 
-/* Return a zonelist representing a mempolicy */
-static struct zonelist *zonelist_policy(gfp_t gfp, struct mempolicy *policy)
-{
-	int nd;
-
-	switch (policy->policy) {
-	case MPOL_PREFERRED:
-		nd = policy->v.preferred_node;
-		if (nd < 0)
-			nd = numa_node_id();
-		break;
-	case MPOL_BIND:
-		/* Lower zones don't get a policy applied */
-		/* Careful: current->mems_allowed might have moved */
-		if (gfp_zone(gfp) >= policy_zone)
-			if (cpuset_zonelist_valid_mems_allowed(policy->v.zonelist))
-				return policy->v.zonelist;
-		/*FALL THROUGH*/
-	case MPOL_INTERLEAVE: /* should not happen */
-	case MPOL_DEFAULT:
-		nd = numa_node_id();
-		break;
-	default:
-		nd = 0;
-		BUG();
-	}
-	return NODE_DATA(nd)->node_zonelists + gfp_zone(gfp);
-}
-
 /* Do dynamic interleaving for a process */
 static unsigned interleave_nodes(struct mempolicy *policy)
 {
@@ -1118,7 +1052,7 @@
 		 * Follow bind policy behavior and start allocation at the
 		 * first node.
 		 */
-		return policy->v.zonelist->zones[0]->zone_pgdat->node_id;
+		return first_node(policy->v.nodes);
 
 	case MPOL_PREFERRED:
 		if (policy->v.preferred_node >= 0)
@@ -1180,20 +1114,43 @@
 /* Allocate a page in interleaved policy.
    Own path because it needs to do special accounting. */
 static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
-					unsigned nid)
+					  unsigned nid, nodemask_t *mask)
 {
-	struct zonelist *zl;
 	struct page *page;
-
-	zl = NODE_DATA(nid)->node_zonelists + gfp_zone(gfp);
-	page = __alloc_pages(gfp, order, zl);
-	if (page && page_zone(page) == zl->zones[0]) {
-		zone_pcp(zl->zones[0],get_cpu())->interleave_hit++;
+	page = __alloc_pages_nodemask(gfp, order, nid, mask);
+	if (page && page_to_nid(page) == nid) {
+		zone_pcp(page_zone(page),get_cpu())->interleave_hit++;
 		put_cpu();
 	}
 	return page;
 }
 
+/*
+ * Allocate suitable pages for given policy.
+ */
+
+struct page *
+alloc_pages_policy(gfp_t gfp, int order, struct mempolicy *pol)
+{
+	unsigned int nid = numa_node_id();
+
+	cpuset_update_task_memory_state();
+
+	switch (pol->policy) {
+		case MPOL_BIND:
+			return __alloc_pages_nodemask(gfp, 0, nid, &pol->v.nodes);
+		case MPOL_PREFERRED:
+			return __alloc_pages_nodemask(gfp, 0, pol->v.preferred_node, NULL);
+		case MPOL_INTERLEAVE:
+			/* never comes here */
+		default:
+			break;
+	}
+	return __alloc_pages_nodemask(gfp, order, nid, NULL);
+}
+
+
+
 /**
  * 	alloc_page_vma	- Allocate a page for a VMA.
  *
@@ -1216,20 +1173,15 @@
  *
  *	Should be called with the mm_sem of the vma hold.
  */
-struct page *
-alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
+struct page *alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
 {
 	struct mempolicy *pol = get_vma_policy(current, vma, addr);
-
-	cpuset_update_task_memory_state();
-
-	if (unlikely(pol->policy == MPOL_INTERLEAVE)) {
-		unsigned nid;
-
+	if (pol->policy == MPOL_INTERLEAVE) {
+		int nid;
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
-		return alloc_page_interleave(gfp, 0, nid);
+		return alloc_page_interleave(gfp, 0, nid, &pol->v.nodes);
 	}
-	return __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
+	return alloc_pages_policy(gfp, 0, pol);
 }
 
 /**
@@ -1260,8 +1212,9 @@
 	if (!pol || in_interrupt())
 		pol = &default_policy;
 	if (pol->policy == MPOL_INTERLEAVE)
-		return alloc_page_interleave(gfp, order, interleave_nodes(pol));
-	return __alloc_pages(gfp, order, zonelist_policy(gfp, pol));
+		return alloc_page_interleave(gfp, order, interleave_nodes(pol),
+					     &pol->v.nodes);
+	return alloc_pages_policy(gfp, order,pol);
 }
 EXPORT_SYMBOL(alloc_pages_current);
 
@@ -1287,15 +1240,6 @@
 	}
 	*new = *old;
 	atomic_set(&new->refcnt, 1);
-	if (new->policy == MPOL_BIND) {
-		int sz = ksize(old->v.zonelist);
-		new->v.zonelist = kmalloc(sz, SLAB_KERNEL);
-		if (!new->v.zonelist) {
-			kmem_cache_free(policy_cache, new);
-			return ERR_PTR(-ENOMEM);
-		}
-		memcpy(new->v.zonelist, old->v.zonelist, sz);
-	}
 	return new;
 }
 
@@ -1313,13 +1257,8 @@
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
+	case MPOL_BIND:
+		return nodes_equal(a->v.nodes, b->v.nodes);
 	default:
 		BUG();
 		return 0;
@@ -1331,8 +1270,6 @@
 {
 	if (!atomic_dec_and_test(&p->refcnt))
 		return;
-	if (p->policy == MPOL_BIND)
-		kfree(p->v.zonelist);
 	p->policy = MPOL_DEFAULT;
 	kmem_cache_free(policy_cache, p);
 }
@@ -1597,6 +1534,7 @@
 	switch (pol->policy) {
 	case MPOL_DEFAULT:
 		break;
+        case MPOL_BIND:
 	case MPOL_INTERLEAVE:
 		nodes_remap(tmp, pol->v.nodes, *mpolmask, *newmask);
 		pol->v.nodes = tmp;
@@ -1609,32 +1547,6 @@
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
-			node_set((*z)->zone_pgdat->node_id, nodes);
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
-		if (zonelist) {
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
