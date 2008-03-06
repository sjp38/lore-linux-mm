Subject: [PATCH] Mempolicy:  make dequeue_huge_page_vma() obey MPOL_BIND
	nodemask rework
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080306010440.GE28746@us.ibm.com>
References: <20080227214708.6858.53458.sendpatchset@localhost>
	 <20080227214734.6858.9968.sendpatchset@localhost>
	 <20080228133247.6a7b626f.akpm@linux-foundation.org>
	 <20080229145030.GD6045@csn.ul.ie> <1204300094.5311.50.camel@localhost>
	 <20080304180145.GB9051@csn.ul.ie> <1204733195.5026.20.camel@localhost>
	 <20080305180322.GA9795@us.ibm.com> <1204743774.6244.6.camel@localhost>
	 <20080306010440.GE28746@us.ibm.com>
Content-Type: text/plain
Date: Thu, 06 Mar 2008 16:24:53 -0500
Message-Id: <1204838693.5294.102.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, agl@us.ibm.com, wli@holomorphy.com, clameter@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, rientjes@google.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Fix for earlier patch:
"mempolicy-make-dequeue_huge_page_vma-obey-bind-policy"

Against: 2.6.25-rc3-mm1 atop the above patch.

As suggested by Nish Aravamudan, remove the mpol_bind_nodemask()
helper and return a pointer to the policy node mask from
huge_zonelist for MPOL_BIND.  This hides more of the mempolicy
quirks from hugetlb.

In making this change, I noticed that the huge_zonelist() stub
for !NUMA wasn't nulling out the mpol.  Added that as well.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/mempolicy.h |   21 ++++++---------------
 mm/hugetlb.c              |    4 ++--
 mm/mempolicy.c            |   18 ++++++++++++------
 3 files changed, 20 insertions(+), 23 deletions(-)

Index: linux-2.6.25-rc3-mm1/include/linux/mempolicy.h
===================================================================
--- linux-2.6.25-rc3-mm1.orig/include/linux/mempolicy.h	2008-03-06 12:01:59.000000000 -0500
+++ linux-2.6.25-rc3-mm1/include/linux/mempolicy.h	2008-03-06 12:14:24.000000000 -0500
@@ -152,7 +152,8 @@ extern void mpol_fix_fork_child_flag(str
 
 extern struct mempolicy default_policy;
 extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
-		unsigned long addr, gfp_t gfp_flags, struct mempolicy **mpol);
+				unsigned long addr, gfp_t gfp_flags,
+				struct mempolicy **mpol, nodemask_t **nodemask);
 extern unsigned slab_node(struct mempolicy *policy);
 
 extern enum zone_type policy_zone;
@@ -163,14 +164,6 @@ static inline void check_highest_zone(en
 		policy_zone = k;
 }
 
-static inline nodemask_t *mpol_bind_nodemask(struct mempolicy *mpol)
-{
-	if (mpol->policy == MPOL_BIND)
-		return &mpol->v.nodes;
-	else
-		return NULL;
-}
-
 int do_migrate_pages(struct mm_struct *mm,
 	const nodemask_t *from_nodes, const nodemask_t *to_nodes, int flags);
 
@@ -248,8 +241,11 @@ static inline void mpol_fix_fork_child_f
 }
 
 static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
- 		unsigned long addr, gfp_t gfp_flags, struct mempolicy **mpol)
+				unsigned long addr, gfp_t gfp_flags,
+				struct mempolicy **mpol, nodemask_t **nodemask)
 {
+	*mpol = NULL;
+	*nodemask = NULL;
 	return node_zonelist(0, gfp_flags);
 }
 
@@ -263,11 +259,6 @@ static inline int do_migrate_pages(struc
 static inline void check_highest_zone(int k)
 {
 }
-
-static inline nodemask_t *mpol_bind_nodemask(struct mempolicy *mpol)
-{
-	return NULL;
-}
 #endif /* CONFIG_NUMA */
 #endif /* __KERNEL__ */
 
Index: linux-2.6.25-rc3-mm1/mm/hugetlb.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/hugetlb.c	2008-03-06 12:01:59.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/hugetlb.c	2008-03-06 12:03:06.000000000 -0500
@@ -95,11 +95,11 @@ static struct page *dequeue_huge_page_vm
 	int nid;
 	struct page *page = NULL;
 	struct mempolicy *mpol;
+	nodemask_t *nodemask;
 	struct zonelist *zonelist = huge_zonelist(vma, address,
-					htlb_alloc_mask, &mpol);
+					htlb_alloc_mask, &mpol, &nodemask);
 	struct zone *zone;
 	struct zoneref *z;
-	nodemask_t *nodemask = mpol_bind_nodemask(mpol);
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						MAX_NR_ZONES - 1, nodemask) {
Index: linux-2.6.25-rc3-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/mempolicy.c	2008-03-06 12:01:59.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/mempolicy.c	2008-03-06 12:33:58.000000000 -0500
@@ -1276,25 +1276,31 @@ static inline unsigned interleave_nid(st
  * @vma = virtual memory area whose policy is sought
  * @addr = address in @vma for shared policy lookup and interleave policy
  * @gfp_flags = for requested zone
- * @mpol = pointer to mempolicy pointer for reference counted 'BIND policy
+ * @mpol = pointer to mempolicy pointer for reference counted mempolicy
+ * @nodemask = pointer to nodemask pointer for MPOL_BIND nodemask
  *
  * Returns a zonelist suitable for a huge page allocation.
- * If the effective policy is 'BIND, returns pointer to policy's zonelist.
+ * If the effective policy is 'BIND, returns pointer to local node's zonelist,
+ * and a pointer to the mempolicy's @nodemask for filtering the zonelist.
  * If it is also a policy for which get_vma_policy() returns an extra
- * reference, we must hold that reference until after allocation.
+ * reference, we must hold that reference until after the allocation.
  * In that case, return policy via @mpol so hugetlb allocation can drop
- * the reference.  For non-'BIND referenced policies, we can/do drop the
+ * the reference. For non-'BIND referenced policies, we can/do drop the
  * reference here, so the caller doesn't need to know about the special case
  * for default and current task policy.
  */
 struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
-				gfp_t gfp_flags, struct mempolicy **mpol)
+				gfp_t gfp_flags, struct mempolicy **mpol,
+				nodemask_t **nodemask)
 {
 	struct mempolicy *pol = get_vma_policy(current, vma, addr);
 	struct zonelist *zl;
 
 	*mpol = NULL;		/* probably no unref needed */
-	if (pol->policy == MPOL_INTERLEAVE) {
+	*nodemask = NULL;	/* assume !MPOL_BIND */
+	if (pol->policy == MPOL_BIND) {
+			*nodemask = &pol->v.nodes;
+	} else if (pol->policy == MPOL_INTERLEAVE) {
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
