Date: Fri, 21 Apr 2006 13:15:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] split zonelist and use nodemask for page allocation [3/4]
 hugemem policy
Message-Id: <20060421131524.7b7547b3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Changes in memploicy affects hugepage allocation.
(this ver. is a bit ugly...)

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu,com>

Index: linux-2.6.17-rc1-mm2/include/linux/mempolicy.h
===================================================================
--- linux-2.6.17-rc1-mm2.orig/include/linux/mempolicy.h	2006-04-21 11:52:05.000000000 +0900
+++ linux-2.6.17-rc1-mm2/include/linux/mempolicy.h	2006-04-21 11:56:37.000000000 +0900
@@ -157,8 +157,8 @@
 #endif
 
 extern struct mempolicy default_policy;
-extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
-		unsigned long addr);
+extern nodemask_t *huge_nodemask(struct vm_area_struct *vma,
+				 unsigned long addr, int *nid);
 extern unsigned slab_node(struct mempolicy *policy);
 
 extern int policy_zone;
Index: linux-2.6.17-rc1-mm2/mm/hugetlb.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/mm/hugetlb.c	2006-04-21 11:51:26.000000000 +0900
+++ linux-2.6.17-rc1-mm2/mm/hugetlb.c	2006-04-21 12:07:09.000000000 +0900
@@ -66,24 +66,32 @@
 static struct page *dequeue_huge_page(struct vm_area_struct *vma,
 				unsigned long address)
 {
-	int nid = numa_node_id();
 	struct page *page = NULL;
-	struct zonelist *zonelist = huge_zonelist(vma, address);
-	struct zone **z;
-
-	for (z = zonelist->zones; *z; z++) {
-		nid = (*z)->zone_pgdat->node_id;
-		if (cpuset_zone_allowed(*z, GFP_HIGHUSER) &&
-		    !list_empty(&hugepage_freelists[nid]))
-			break;
+	int zid;
+	int nid, orig_node, index = 0;
+	nodemask_t *mask = huge_nodemask(vma, address, &nid);
+	struct zone *z = NULL;
+	orig_node = nid;
+retry:
+	if (node_isset(nid, *mask)) {
+		for (zid = ZONE_HIGHMEM; zid >= 0; --zid) {
+			z = NODE_DATA(nid)->node_zones + zid;
+			if (cpuset_zone_allowed(z, GFP_HIGHUSER) &&
+		    		!list_empty(&hugepage_freelists[nid]))
+				break;
+		}
 	}
 
-	if (*z) {
+	if (z) {
 		page = list_entry(hugepage_freelists[nid].next,
 				  struct page, lru);
 		list_del(&page->lru);
 		free_huge_pages--;
 		free_huge_pages_node[nid]--;
+	} else {
+		nid = NODE_DATA(orig_node)->nodes_list[++index];
+		if (nid != -1)
+			goto retry;
 	}
 	return page;
 }
Index: linux-2.6.17-rc1-mm2/mm/mempolicy.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/mm/mempolicy.c	2006-04-21 11:52:05.000000000 +0900
+++ linux-2.6.17-rc1-mm2/mm/mempolicy.c	2006-04-21 12:05:27.000000000 +0900
@@ -1096,8 +1096,9 @@
 }
 
 #ifdef CONFIG_HUGETLBFS
-/* Return a zonelist suitable for a huge page allocation. */
-struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr)
+/* Return a nodemask suitable for a huge page allocation. */
+struct nodemask_t *
+huge_nodemask(struct vm_area_struct *vma, unsigned long addr, int *nid)
 {
 	struct mempolicy *pol = get_vma_policy(current, vma, addr);
 
@@ -1105,9 +1106,12 @@
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
-		return NODE_DATA(nid)->node_zonelists + gfp_zone(GFP_HIGHUSER);
+		return &pol->v.nodes;
 	}
-	return zonelist_policy(GFP_HIGHUSER, pol);
+	*nid = numa_node_id();
+	if (pol->policy == MPOL_MBIND)
+		return &pol->v.nodes;
+	return &node_online_map;
 }
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
