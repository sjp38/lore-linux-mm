Date: Tue, 8 Aug 2006 09:51:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC] Unify memory policy layer functions for huge pages and slab.
Message-ID: <Pine.LNX.4.64.0608080949290.27620@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ak@suse.de
List-ID: <linux-mm.kvack.org>

We currently have multiple functions that determine policies for
certain specialized situations.

Generalize this into one single function that can cover all.

I am not sure if its worth doing since the generalized functions must have
a superset of the existing policy related functions. F.e. it has a 
page_shift parameter. sigh.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc3-mm2/mm/mempolicy.c
===================================================================
--- linux-2.6.18-rc3-mm2.orig/mm/mempolicy.c	2006-08-08 09:20:41.729850533 -0700
+++ linux-2.6.18-rc3-mm2/mm/mempolicy.c	2006-08-08 09:45:56.470228035 -0700
@@ -1126,33 +1126,6 @@ static unsigned interleave_nodes(struct 
 	return nid;
 }
 
-/*
- * Depending on the memory policy provide a node from which to allocate the
- * next slab entry.
- */
-unsigned slab_node(struct mempolicy *policy)
-{
-	switch (policy->policy) {
-	case MPOL_INTERLEAVE:
-		return interleave_nodes(policy);
-
-	case MPOL_BIND:
-		/*
-		 * Follow bind policy behavior and start allocation at the
-		 * first node.
-		 */
-		return policy->v.zonelist->zones[0]->zone_pgdat->node_id;
-
-	case MPOL_PREFERRED:
-		if (policy->v.preferred_node >= 0)
-			return policy->v.preferred_node;
-		/* Fall through */
-
-	default:
-		return numa_node_id();
-	}
-}
-
 /* Do static interleaving for a VMA with known offset. */
 static unsigned offset_il_node(struct mempolicy *pol,
 		struct vm_area_struct *vma, unsigned long off)
@@ -1184,21 +1157,23 @@ static inline unsigned interleave_nid(st
 		return interleave_nodes(pol);
 }
 
-#ifdef CONFIG_HUGETLBFS
-/* Return a zonelist suitable for a huge page allocation. */
-struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr)
+/* Return a zonelist proper for the vma, addresss and gfp mask. */
+struct zonelist *mpol_zonelist(gfp_t flags, int page_shift,
+			struct vm_area_struct *vma, unsigned long addr)
 {
 	struct mempolicy *pol = get_vma_policy(current, vma, addr);
 
+	if ((flags & __GFP_THISNODE) || in_interrupt())
+		pol = &default_policy;
+
 	if (pol->policy == MPOL_INTERLEAVE) {
 		unsigned nid;
 
-		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
-		return NODE_DATA(nid)->node_zonelists + gfp_zone(GFP_HIGHUSER);
+		nid = interleave_nid(pol, vma, addr, page_shift);
+		return NODE_DATA(nid)->node_zonelists + gfp_zone(flags);
 	}
-	return zonelist_policy(GFP_HIGHUSER, pol);
+	return zonelist_policy(flags, pol);
 }
-#endif
 
 /* Allocate a page in interleaved policy.
    Own path because it needs to do special accounting. */
Index: linux-2.6.18-rc3-mm2/mm/slab.c
===================================================================
--- linux-2.6.18-rc3-mm2.orig/mm/slab.c	2006-08-07 20:21:28.389342343 -0700
+++ linux-2.6.18-rc3-mm2/mm/slab.c	2006-08-08 09:45:56.472181039 -0700
@@ -3072,8 +3072,11 @@ static void *alternate_node_alloc(struct
 	nid_alloc = nid_here = numa_node_id();
 	if (cpuset_do_slab_mem_spread() && (cachep->flags & SLAB_MEM_SPREAD))
 		nid_alloc = cpuset_mem_spread_node();
-	else if (current->mempolicy)
-		nid_alloc = slab_node(current->mempolicy);
+	else if (current->mempolicy) {
+		struct zonelist *zonelist = mpol_zonelist(flags, 0, NULL, 0);
+
+		nid_alloc = zonelist->zones[0]->zone_pgdat->node_id;
+	}
 	if (nid_alloc != nid_here)
 		return __cache_alloc_node(cachep, flags, nid_alloc);
 	return NULL;
Index: linux-2.6.18-rc3-mm2/include/linux/mempolicy.h
===================================================================
--- linux-2.6.18-rc3-mm2.orig/include/linux/mempolicy.h	2006-08-07 20:21:01.767943956 -0700
+++ linux-2.6.18-rc3-mm2/include/linux/mempolicy.h	2006-08-08 09:45:56.473157542 -0700
@@ -158,9 +158,8 @@ extern void mpol_fix_fork_child_flag(str
 #endif
 
 extern struct mempolicy default_policy;
-extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
-		unsigned long addr);
-extern unsigned slab_node(struct mempolicy *policy);
+extern struct zonelist *mpol_zonelist(gfp_t flags, int page_shift,
+		struct vm_area_struct *vma, unsigned long addr);
 
 extern enum zone_type policy_zone;
 
Index: linux-2.6.18-rc3-mm2/mm/hugetlb.c
===================================================================
--- linux-2.6.18-rc3-mm2.orig/mm/hugetlb.c	2006-07-29 23:15:36.000000000 -0700
+++ linux-2.6.18-rc3-mm2/mm/hugetlb.c	2006-08-08 09:45:56.474134044 -0700
@@ -68,7 +68,8 @@ static struct page *dequeue_huge_page(st
 {
 	int nid = numa_node_id();
 	struct page *page = NULL;
-	struct zonelist *zonelist = huge_zonelist(vma, address);
+	struct zonelist *zonelist =
+		mpol_zonelist(GFP_HIGHUSER, HPAGE_SHIFT, vma, address);
 	struct zone **z;
 
 	for (z = zonelist->zones; *z; z++) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
