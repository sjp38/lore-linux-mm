Subject: [PATCH] 2.6.25-rc3-mm1 - Mempolicy:  make dequeue_huge_page_vma()
	obey MPOL_BIND nodemask
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080304180145.GB9051@csn.ul.ie>
References: <20080227214708.6858.53458.sendpatchset@localhost>
	 <20080227214734.6858.9968.sendpatchset@localhost>
	 <20080228133247.6a7b626f.akpm@linux-foundation.org>
	 <20080229145030.GD6045@csn.ul.ie> <1204300094.5311.50.camel@localhost>
	 <20080304180145.GB9051@csn.ul.ie>
Content-Type: text/plain
Date: Wed, 05 Mar 2008 11:06:34 -0500
Message-Id: <1204733195.5026.20.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, agl@us.ibm.com, wli@holomorphy.com, clameter@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, rientjes@google.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH Mempolicy - make dequeue_huge_page_vma() obey MPOL_BIND nodemask

dequeue_huge_page_vma() is not obeying the MPOL_BIND nodemask
with the zonelist rework.  It needs to search only zones in 
the mempolicy nodemask for hugepages.

Use for_each_zone_zonelist_nodemask() instead of
for_each_zone_zonelist().

Note:  this will bloat mm/hugetlb.o a bit until Mel reworks the
inlining of the for_each_zone... macros and helpers.

Added mempolicy helper function mpol_bind_nodemask() to hide
the details of mempolicy from hugetlb and to avoid
#ifdef CONFIG_NUMA in dequeue_huge_page_vma().

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/mempolicy.h |   13 +++++++++++++
 mm/hugetlb.c              |    4 +++-
 2 files changed, 16 insertions(+), 1 deletion(-)

Index: linux-2.6.25-rc3-mm1/mm/hugetlb.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/hugetlb.c	2008-03-05 10:35:12.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/hugetlb.c	2008-03-05 10:37:09.000000000 -0500
@@ -99,8 +99,10 @@ static struct page *dequeue_huge_page_vm
 					htlb_alloc_mask, &mpol);
 	struct zone *zone;
 	struct zoneref *z;
+	nodemask_t *nodemask = mpol_bind_nodemask(mpol);
 
-	for_each_zone_zonelist(zone, z, zonelist, MAX_NR_ZONES - 1) {
+	for_each_zone_zonelist_nodemask(zone, z, zonelist,
+						MAX_NR_ZONES - 1, nodemask) {
 		nid = zone_to_nid(zone);
 		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask) &&
 		    !list_empty(&hugepage_freelists[nid])) {
Index: linux-2.6.25-rc3-mm1/include/linux/mempolicy.h
===================================================================
--- linux-2.6.25-rc3-mm1.orig/include/linux/mempolicy.h	2008-03-05 10:35:12.000000000 -0500
+++ linux-2.6.25-rc3-mm1/include/linux/mempolicy.h	2008-03-05 10:59:11.000000000 -0500
@@ -163,6 +163,14 @@ static inline void check_highest_zone(en
 		policy_zone = k;
 }
 
+static inline nodemask_t *mpol_bind_nodemask(struct mempolicy *mpol)
+{
+	if (mpol->policy == MPOL_BIND)
+		return &mpol->v.nodes;
+	else
+		return NULL;
+}
+
 int do_migrate_pages(struct mm_struct *mm,
 	const nodemask_t *from_nodes, const nodemask_t *to_nodes, int flags);
 
@@ -255,6 +263,11 @@ static inline int do_migrate_pages(struc
 static inline void check_highest_zone(int k)
 {
 }
+
+static inline nodemask_t *mpol_bind_nodemask(struct mempolicy *mpol)
+{
+	return NULL;
+}
 #endif /* CONFIG_NUMA */
 #endif /* __KERNEL__ */
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
