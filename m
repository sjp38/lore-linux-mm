Date: Thu, 31 Jul 2008 20:55:47 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [RFC:Patch: 001/008](memory hotplug) change parameter from pointer of zonelist to node id
In-Reply-To: <20080731203549.2A3F.E1E9C6FF@jp.fujitsu.com>
References: <20080731203549.2A3F.E1E9C6FF@jp.fujitsu.com>
Message-Id: <20080731205426.2A41.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This is preparation patch for the later patch.
Current code passes the pointer of zonelist to __alloc_pages() to
specify which zonelist should be used.
However, its parameter also means which node(pgdat)'s zonelist
should be used for parsing.

This patch change interface from zonelist pointer to node id (zonelist_nid)
which has target zonelist.
Because node id is easy to check node online/offline.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---
 include/linux/gfp.h       |   12 +++++------
 include/linux/mempolicy.h |    2 -
 mm/hugetlb.c              |    4 ++-
 mm/mempolicy.c            |   50 +++++++++++++++++++++++-----------------------
 mm/page_alloc.c           |   21 ++++++++++++-------
 5 files changed, 49 insertions(+), 40 deletions(-)

Index: current/include/linux/gfp.h
===================================================================
--- current.orig/include/linux/gfp.h	2008-07-31 18:54:09.000000000 +0900
+++ current/include/linux/gfp.h	2008-07-31 18:54:18.000000000 +0900
@@ -175,20 +175,20 @@ static inline void arch_alloc_page(struc
 
 struct page *
 __alloc_pages_internal(gfp_t gfp_mask, unsigned int order,
-		       struct zonelist *zonelist, nodemask_t *nodemask);
+		       int zonelist_nid, nodemask_t *nodemask);
 
 static inline struct page *
 __alloc_pages(gfp_t gfp_mask, unsigned int order,
-		struct zonelist *zonelist)
+		int zonelist_nid)
 {
-	return __alloc_pages_internal(gfp_mask, order, zonelist, NULL);
+	return __alloc_pages_internal(gfp_mask, order, zonelist_nid, NULL);
 }
 
 static inline struct page *
 __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
-		struct zonelist *zonelist, nodemask_t *nodemask)
+		int zonelist_nid, nodemask_t *nodemask)
 {
-	return __alloc_pages_internal(gfp_mask, order, zonelist, nodemask);
+	return __alloc_pages_internal(gfp_mask, order, zonelist_nid, nodemask);
 }
 
 
@@ -202,7 +202,7 @@ static inline struct page *alloc_pages_n
 	if (nid < 0)
 		nid = numa_node_id();
 
-	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
+	return __alloc_pages(gfp_mask, order, nid);
 }
 
 #ifdef CONFIG_NUMA
Index: current/mm/mempolicy.c
===================================================================
--- current.orig/mm/mempolicy.c	2008-07-31 18:54:09.000000000 +0900
+++ current/mm/mempolicy.c	2008-07-31 18:54:59.000000000 +0900
@@ -1329,7 +1329,7 @@ static nodemask_t *policy_nodemask(gfp_t
 }
 
 /* Return a zonelist indicated by gfp for node representing a mempolicy */
-static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy)
+static int policy_node(gfp_t gfp, struct mempolicy *policy)
 {
 	int nd = numa_node_id();
 
@@ -1354,7 +1354,7 @@ static struct zonelist *policy_zonelist(
 	default:
 		BUG();
 	}
-	return node_zonelist(nd, gfp);
+	return nd;
 }
 
 /* Do dynamic interleaving for a process */
@@ -1459,36 +1459,35 @@ static inline unsigned interleave_nid(st
 
 #ifdef CONFIG_HUGETLBFS
 /*
- * huge_zonelist(@vma, @addr, @gfp_flags, @mpol)
+ * huge_node(@vma, @addr, @gfp_flags, @mpol)
  * @vma = virtual memory area whose policy is sought
  * @addr = address in @vma for shared policy lookup and interleave policy
  * @gfp_flags = for requested zone
  * @mpol = pointer to mempolicy pointer for reference counted mempolicy
  * @nodemask = pointer to nodemask pointer for MPOL_BIND nodemask
  *
- * Returns a zonelist suitable for a huge page allocation and a pointer
+ * Returns node id suitable for a huge page allocation and a pointer
  * to the struct mempolicy for conditional unref after allocation.
  * If the effective policy is 'BIND, returns a pointer to the mempolicy's
  * @nodemask for filtering the zonelist.
  */
-struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
-				gfp_t gfp_flags, struct mempolicy **mpol,
-				nodemask_t **nodemask)
+int huge_node(struct vm_area_struct *vma, unsigned long addr, gfp_t gfp_flags,
+	      struct mempolicy **mpol, nodemask_t **nodemask)
 {
-	struct zonelist *zl;
+	int nid;
 
 	*mpol = get_vma_policy(current, vma, addr);
 	*nodemask = NULL;	/* assume !MPOL_BIND */
 
-	if (unlikely((*mpol)->mode == MPOL_INTERLEAVE)) {
-		zl = node_zonelist(interleave_nid(*mpol, vma, addr,
-				huge_page_shift(hstate_vma(vma))), gfp_flags);
-	} else {
-		zl = policy_zonelist(gfp_flags, *mpol);
+	if (unlikely((*mpol)->mode == MPOL_INTERLEAVE))
+		nid = interleave_nid(*mpol, vma, addr,
+				     huge_page_shift(hstate_vma(vma)));
+	else {
+		nid = policy_node(gfp_flags, *mpol);
 		if ((*mpol)->mode == MPOL_BIND)
 			*nodemask = &(*mpol)->v.nodes;
 	}
-	return zl;
+	return nid;
 }
 #endif
 
@@ -1497,13 +1496,15 @@ struct zonelist *huge_zonelist(struct vm
 static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
 					unsigned nid)
 {
-	struct zonelist *zl;
 	struct page *page;
 
-	zl = node_zonelist(nid, gfp);
-	page = __alloc_pages(gfp, order, zl);
-	if (page && page_zone(page) == zonelist_zone(&zl->_zonerefs[0]))
-		inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
+	page = __alloc_pages(gfp, order, nid);
+	if (page) {
+		struct zonelist *zl;
+		zl = node_zonelist(nid, gfp);
+		if (page_zone(page) == zonelist_zone(&zl->_zonerefs[0]))
+			inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
+	}
 	return page;
 }
 
@@ -1533,31 +1534,30 @@ struct page *
 alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
 {
 	struct mempolicy *pol = get_vma_policy(current, vma, addr);
-	struct zonelist *zl;
+	int nid;
 
 	cpuset_update_task_memory_state();
 
 	if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
-		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
 		mpol_cond_put(pol);
 		return alloc_page_interleave(gfp, 0, nid);
 	}
-	zl = policy_zonelist(gfp, pol);
+	nid = policy_node(gfp, pol);
 	if (unlikely(mpol_needs_cond_ref(pol))) {
 		/*
 		 * slow path: ref counted shared policy
 		 */
 		struct page *page =  __alloc_pages_nodemask(gfp, 0,
-						zl, policy_nodemask(gfp, pol));
+						nid, policy_nodemask(gfp, pol));
 		__mpol_put(pol);
 		return page;
 	}
 	/*
 	 * fast path:  default or task policy
 	 */
-	return __alloc_pages_nodemask(gfp, 0, zl, policy_nodemask(gfp, pol));
+	return __alloc_pages_nodemask(gfp, 0, nid, policy_nodemask(gfp, pol));
 }
 
 /**
@@ -1595,7 +1595,7 @@ struct page *alloc_pages_current(gfp_t g
 	if (pol->mode == MPOL_INTERLEAVE)
 		return alloc_page_interleave(gfp, order, interleave_nodes(pol));
 	return __alloc_pages_nodemask(gfp, order,
-			policy_zonelist(gfp, pol), policy_nodemask(gfp, pol));
+			policy_node(gfp, pol), policy_nodemask(gfp, pol));
 }
 EXPORT_SYMBOL(alloc_pages_current);
 
Index: current/mm/page_alloc.c
===================================================================
--- current.orig/mm/page_alloc.c	2008-07-31 18:54:09.000000000 +0900
+++ current/mm/page_alloc.c	2008-07-31 19:01:46.000000000 +0900
@@ -1383,7 +1383,8 @@ static void zlc_mark_zone_full(struct zo
  */
 static struct page *
 get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
-		struct zonelist *zonelist, int high_zoneidx, int alloc_flags)
+	       struct zonelist *zonelist, int high_zoneidx, int alloc_flags,
+	       int zonelist_nid)
 {
 	struct zoneref *z;
 	struct page *page = NULL;
@@ -1514,7 +1515,7 @@ static void set_page_owner(struct page *
  */
 struct page *
 __alloc_pages_internal(gfp_t gfp_mask, unsigned int order,
-			struct zonelist *zonelist, nodemask_t *nodemask)
+		       int zonelist_nid, nodemask_t *nodemask)
 {
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
@@ -1527,6 +1528,7 @@ __alloc_pages_internal(gfp_t gfp_mask, u
 	int alloc_flags;
 	unsigned long did_some_progress;
 	unsigned long pages_reclaimed = 0;
+	struct zonelist *zonelist;
 
 	might_sleep_if(wait);
 
@@ -1534,6 +1536,7 @@ __alloc_pages_internal(gfp_t gfp_mask, u
 		return NULL;
 
 restart:
+	zonelist = node_zonelist(zonelist_nid, gfp_mask);;
 	z = zonelist->_zonerefs;  /* the list of zones suitable for gfp_mask */
 
 	if (unlikely(!z->zone)) {
@@ -1545,7 +1548,9 @@ restart:
 	}
 
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
-			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET);
+		zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET,
+		zonelist_nid);
+
 	if (page)
 		goto got_pg;
 
@@ -1590,7 +1595,7 @@ restart:
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
 	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
-						high_zoneidx, alloc_flags);
+				      high_zoneidx, alloc_flags, zonelist_nid);
 	if (page)
 		goto got_pg;
 
@@ -1603,7 +1608,8 @@ rebalance:
 nofail_alloc:
 			/* go through the zonelist yet again, ignoring mins */
 			page = get_page_from_freelist(gfp_mask, nodemask, order,
-				zonelist, high_zoneidx, ALLOC_NO_WATERMARKS);
+				zonelist, high_zoneidx, ALLOC_NO_WATERMARKS,
+				zonelist_nid);
 			if (page)
 				goto got_pg;
 			if (gfp_mask & __GFP_NOFAIL) {
@@ -1638,7 +1644,8 @@ nofail_alloc:
 
 	if (likely(did_some_progress)) {
 		page = get_page_from_freelist(gfp_mask, nodemask, order,
-					zonelist, high_zoneidx, alloc_flags);
+				zonelist, high_zoneidx, alloc_flags,
+				zonelist_nid);
 		if (page)
 			goto got_pg;
 	} else if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
@@ -1655,7 +1662,7 @@ nofail_alloc:
 		 */
 		page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
 			order, zonelist, high_zoneidx,
-			ALLOC_WMARK_HIGH|ALLOC_CPUSET);
+			ALLOC_WMARK_HIGH|ALLOC_CPUSET, zonelist_nid);
 		if (page) {
 			clear_zonelist_oom(zonelist, gfp_mask);
 			goto got_pg;
Index: current/mm/hugetlb.c
===================================================================
--- current.orig/mm/hugetlb.c	2008-07-31 18:54:09.000000000 +0900
+++ current/mm/hugetlb.c	2008-07-31 18:54:18.000000000 +0900
@@ -411,8 +411,9 @@ static struct page *dequeue_huge_page_vm
 	struct page *page = NULL;
 	struct mempolicy *mpol;
 	nodemask_t *nodemask;
-	struct zonelist *zonelist = huge_zonelist(vma, address,
+	int zonelist_nid = huge_node(vma, address,
 					htlb_alloc_mask, &mpol, &nodemask);
+	struct zonelist *zonelist;
 	struct zone *zone;
 	struct zoneref *z;
 
@@ -429,6 +430,7 @@ static struct page *dequeue_huge_page_vm
 	if (avoid_reserve && h->free_huge_pages - h->resv_huge_pages == 0)
 		return NULL;
 
+	zonelist = node_zonelist(zonelist_nid, htlb_alloc_mask);
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						MAX_NR_ZONES - 1, nodemask) {
 		nid = zone_to_nid(zone);
Index: current/include/linux/mempolicy.h
===================================================================
--- current.orig/include/linux/mempolicy.h	2008-07-31 18:54:09.000000000 +0900
+++ current/include/linux/mempolicy.h	2008-07-31 18:54:18.000000000 +0900
@@ -197,7 +197,7 @@ extern void mpol_rebind_task(struct task
 extern void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new);
 extern void mpol_fix_fork_child_flag(struct task_struct *p);
 
-extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
+extern int huge_node(struct vm_area_struct *vma,
 				unsigned long addr, gfp_t gfp_flags,
 				struct mempolicy **mpol, nodemask_t **nodemask);
 extern unsigned slab_node(struct mempolicy *policy);

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
