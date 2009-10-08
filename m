Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 45D306B0095
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 12:22:35 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 08 Oct 2009 12:25:52 -0400
Message-Id: <20091008162552.23192.94115.sendpatchset@localhost.localdomain>
In-Reply-To: <20091008162454.23192.91832.sendpatchset@localhost.localdomain>
References: <20091008162454.23192.91832.sendpatchset@localhost.localdomain>
Subject: [PATCH 9/12] hugetlb:  use only nodes with memory for huge pages
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, andi@firstfloor.org, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH 9/12] hugetlb:  use only nodes with memory

Register per node hstate sysfs attributes only for nodes with
memory.  Global replacement of 'all online nodes" with "all nodes
with memory" in mm/hugetlb.c.  Suggested by David Rientjes.

A subsequent patch will handle adding/removing of per node hstate
sysfs attributes when nodes transition to/from memoryless state
via memory hotplug.

NOTE:  this patch has not been tested with memoryless nodes.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reviewed-by: Andi Kleen <andi@firstfloor.org>

---

Against:  2.6.31-mmotm-090925-1435

V9 + fix botched merge.
     s/node_online_map/node_states[N_HIGH_MEMORY]/ in
     nr_hugepages_store_common

V10  use node_states[N_HIGH_MEMORY] for bootmem alloc of > MAX_ORDER
     pages.  another one dropped in reorg or series.

 Documentation/vm/hugetlbpage.txt |   12 ++++++------
 mm/hugetlb.c                     |   35 ++++++++++++++++++-----------------
 2 files changed, 24 insertions(+), 23 deletions(-)

Index: linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c
===================================================================
--- linux-2.6.31-mmotm-090925-1435.orig/mm/hugetlb.c	2009-10-07 12:32:01.000000000 -0400
+++ linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c	2009-10-07 12:32:03.000000000 -0400
@@ -942,14 +942,14 @@ static void return_unused_surplus_pages(
 
 	/*
 	 * We want to release as many surplus pages as possible, spread
-	 * evenly across all nodes. Iterate across all nodes until we
-	 * can no longer free unreserved surplus pages. This occurs when
-	 * the nodes with surplus pages have no free pages.
-	 * free_pool_huge_page() will balance the the frees across the
-	 * on-line nodes for us and will handle the hstate accounting.
+	 * evenly across all nodes with memory. Iterate across these nodes
+	 * until we can no longer free unreserved surplus pages. This occurs
+	 * when the nodes with surplus pages have no free pages.
+	 * free_pool_huge_page() will balance the the freed pages across the
+	 * on-line nodes with memory and will handle the hstate accounting.
 	 */
 	while (nr_pages--) {
-		if (!free_pool_huge_page(h, &node_online_map, 1))
+		if (!free_pool_huge_page(h, &node_states[N_HIGH_MEMORY], 1))
 			break;
 	}
 }
@@ -1053,14 +1053,14 @@ static struct page *alloc_huge_page(stru
 int __weak alloc_bootmem_huge_page(struct hstate *h)
 {
 	struct huge_bootmem_page *m;
-	int nr_nodes = nodes_weight(node_online_map);
+	int nr_nodes = nodes_weight(node_states[N_HIGH_MEMORY]);
 
 	while (nr_nodes) {
 		void *addr;
 
 		addr = __alloc_bootmem_node_nopanic(
 				NODE_DATA(hstate_next_node_to_alloc(h,
-							&node_online_map)),
+						&node_states[N_HIGH_MEMORY])),
 				huge_page_size(h), huge_page_size(h), 0);
 
 		if (addr) {
@@ -1115,7 +1115,8 @@ static void __init hugetlb_hstate_alloc_
 		if (h->order >= MAX_ORDER) {
 			if (!alloc_bootmem_huge_page(h))
 				break;
-		} else if (!alloc_fresh_huge_page(h, &node_online_map))
+		} else if (!alloc_fresh_huge_page(h,
+					 &node_states[N_HIGH_MEMORY]))
 			break;
 	}
 	h->max_huge_pages = i;
@@ -1388,7 +1389,7 @@ static ssize_t nr_hugepages_store_common
 
 	h->max_huge_pages = set_max_huge_pages(h, count, nodes_allowed);
 
-	if (nodes_allowed != &node_online_map)
+	if (nodes_allowed != &node_states[N_HIGH_MEMORY])
 		NODEMASK_FREE(nodes_allowed);
 
 	return len;
@@ -1610,7 +1611,7 @@ void hugetlb_unregister_node(struct node
 	struct node_hstate *nhs = &node_hstates[node->sysdev.id];
 
 	if (!nhs->hugepages_kobj)
-		return;
+		return;		/* no hstate attributes */
 
 	for_each_hstate(h)
 		if (nhs->hstate_kobjs[h - hstates]) {
@@ -1675,15 +1676,15 @@ void hugetlb_register_node(struct node *
 }
 
 /*
- * hugetlb init time:  register hstate attributes for all registered
- * node sysdevs.  All on-line nodes should have registered their
- * associated sysdev by the time the hugetlb module initializes.
+ * hugetlb init time:  register hstate attributes for all registered node
+ * sysdevs of nodes that have memory.  All on-line nodes should have
+ * registered their associated sysdev by this time.
  */
 static void hugetlb_register_all_nodes(void)
 {
 	int nid;
 
-	for (nid = 0; nid < nr_node_ids; nid++) {
+	for_each_node_state(nid, N_HIGH_MEMORY) {
 		struct node *node = &node_devices[nid];
 		if (node->sysdev.id == nid)
 			hugetlb_register_node(node);
@@ -1777,8 +1778,8 @@ void __init hugetlb_add_hstate(unsigned
 	h->free_huge_pages = 0;
 	for (i = 0; i < MAX_NUMNODES; ++i)
 		INIT_LIST_HEAD(&h->hugepage_freelists[i]);
-	h->next_nid_to_alloc = first_node(node_online_map);
-	h->next_nid_to_free = first_node(node_online_map);
+	h->next_nid_to_alloc = first_node(node_states[N_HIGH_MEMORY]);
+	h->next_nid_to_free = first_node(node_states[N_HIGH_MEMORY]);
 	snprintf(h->name, HSTATE_NAME_LEN, "hugepages-%lukB",
 					huge_page_size(h)/1024);
 
Index: linux-2.6.31-mmotm-090925-1435/Documentation/vm/hugetlbpage.txt
===================================================================
--- linux-2.6.31-mmotm-090925-1435.orig/Documentation/vm/hugetlbpage.txt	2009-10-07 12:32:02.000000000 -0400
+++ linux-2.6.31-mmotm-090925-1435/Documentation/vm/hugetlbpage.txt	2009-10-07 12:32:03.000000000 -0400
@@ -90,11 +90,11 @@ huge page pool to 20, allocating or free
 On a NUMA platform, the kernel will attempt to distribute the huge page pool
 over all the set of allowed nodes specified by the NUMA memory policy of the
 task that modifies nr_hugepages.  The default for the allowed nodes--when the
-task has default memory policy--is all on-line nodes.  Allowed nodes with
-insufficient available, contiguous memory for a huge page will be silently
-skipped when allocating persistent huge pages.  See the discussion below of
-the interaction of task memory policy, cpusets and per node attributes with
-the allocation and freeing of persistent huge pages.
+task has default memory policy--is all on-line nodes with memory.  Allowed
+nodes with insufficient available, contiguous memory for a huge page will be
+silently skipped when allocating persistent huge pages.  See the discussion
+below of the interaction of task memory policy, cpusets and per node attributes
+with the allocation and freeing of persistent huge pages.
 
 The success or failure of huge page allocation depends on the amount of
 physically contiguous memory that is present in system at the time of the
@@ -226,7 +226,7 @@ resulting effect on persistent huge page
    without first moving to a cpuset that contains all of the desired nodes.
 
 5) Boot-time huge page allocation attempts to distribute the requested number
-   of huge pages over all on-lines nodes.
+   of huge pages over all on-lines nodes with memory.
 
 Per Node Hugepages Attributes
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
