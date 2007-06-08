Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l58J6NTr003440
	for <linux-mm@kvack.org>; Fri, 8 Jun 2007 15:06:23 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l58J6Mv1496594
	for <linux-mm@kvack.org>; Fri, 8 Jun 2007 15:06:22 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l58J6LjN030293
	for <linux-mm@kvack.org>; Fri, 8 Jun 2007 15:06:22 -0400
Date: Fri, 8 Jun 2007 12:06:20 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH v5][1/3] Fix hugetlb pool allocation with empty nodes
Message-ID: <20070608190620.GB8017@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linuxfoundation.org, lee.schermerhorn@hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Original Patch [V1]:

Date:	Wed, 2 May 2007 21:21:07 -0500
From: Anton Blanchard <anton@samba.org>
To: linux-mm@kvack.org, clameter@SGI.com, ak@suse.de
Cc: nish.aravamudan@gmail.com, mel@csn.ul.ie, apw@shadowen.org
Subject: [PATCH] Fix hugetlb pool allocation with empty nodes

An interesting bug was pointed out to me where we failed to allocate
hugepages evenly. In the example below node 7 has no memory (it only has
CPUs). Node 0 and 1 have plenty of free memory. After doing:

We see the imbalance:

Node 0 HugePages_Total:     6
Node 1 HugePages_Total:     10
Node 7 HugePages_Total:     0

It didn't take long to realise that alloc_fresh_huge_page is allocating
from node 7 without GFP_THISNODE set, so we fallback to its next
preferred node (ie 1). This means we end up with a 1/3 2/3 imbalance.

After fixing this it still didnt work, and after some more poking I see
why. When building our fallback zonelist in build_zonelists_node we skip
empty zones. This means zone 7 never registers node 7's empty zonelists
and instead registers node 1's. Therefore when we ask for a page from
node 7, using the GFP_THISNODE flag we end up with node 1 memory.

By removing the populated_zone() check in build_zonelists_node we fix
the problem:

Node 0 HugePages_Total:     8
Node 1 HugePages_Total:     8
Node 7 HugePages_Total:     0

Im guessing registering empty remote zones might make the SGI guys a bit
unhappy, maybe we should just force the registration of empty local
zones? Does anyone care?

Rework [should have been V3]

Create node_populated_map and access functions [nodemask.h] to describe
nodes with populated gfp_zone(GFP_HIGHUSER).  Note that on x86, this
excludes nodes with only DMA* or NORMAL memory--i.e., no hugepages below
4G.

Populate the map while building zonelists, where we already check for
populated zones.  This is early enough for boot time allocation of huge
pages.

Attempt to allocate "fresh" huge pages only from nodes in the populated
map.

Tested on ia64 numa platform with both boot time and run time allocation
of huge pages.

Rework "V4":

+ rebase to 22-rc1-mm1 with "change zonelist order" series:

+ redefine node_populated_map to contain nodes whose first zone in the
'policy_zone' zonelist is "on node".  This will be used to filter nodes
for hugepage allocation.  Note:  if some node has only DMA32, but
policy_zone is > DMA32 [some other node/s has/have memory in higher
zones] AND we're building the zonelists in zone order, we won't mark
this zone as populated.  No hugepages will be allocated from such a
node.

+ fix typos in comments per Nish Aravamudan.

+ rework allocate_fresh_huge_page() to just scan the populated map,
again Nish's suggestion.

Rework "V5":

+ rebase to 22-rc4-mm2
+ tested on non-NUMA x86, non-NUMA ppc64, 2-node ia64, 4-node x86_64,
and 4-node ppc64 with 2 unpopulated nodes.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Anton Blanchard <anton@samba.org>
Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
Tested-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff a/include/linux/nodemask.h b/include/linux/nodemask.h
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -64,12 +64,16 @@
  *
  * int node_online(node)		Is some node online?
  * int node_possible(node)		Is some node possible?
+ * int node_populated(node)		Is some node populated [at policy_zone]
  *
  * int any_online_node(mask)		First online node in mask
  *
  * node_set_online(node)		set bit 'node' in node_online_map
  * node_set_offline(node)		clear bit 'node' in node_online_map
  *
+ * node_set_populated(node)		set bit 'node' in node_populated_map
+ * node_not_populated(node)		clear bit 'node' in node_populated_map
+ *
  * for_each_node(node)			for-loop node over node_possible_map
  * for_each_online_node(node)		for-loop node over node_online_map
  *
@@ -344,12 +348,14 @@ static inline void __nodes_remap(nodemask_t *dstp, const nodemask_t *srcp,
 
 extern nodemask_t node_online_map;
 extern nodemask_t node_possible_map;
+extern nodemask_t node_populated_map;
 
 #if MAX_NUMNODES > 1
 #define num_online_nodes()	nodes_weight(node_online_map)
 #define num_possible_nodes()	nodes_weight(node_possible_map)
 #define node_online(node)	node_isset((node), node_online_map)
 #define node_possible(node)	node_isset((node), node_possible_map)
+#define node_populated(node)	node_isset((node), node_populated_map)
 #define first_online_node	first_node(node_online_map)
 #define next_online_node(nid)	next_node((nid), node_online_map)
 extern int nr_node_ids;
@@ -358,6 +364,7 @@ extern int nr_node_ids;
 #define num_possible_nodes()	1
 #define node_online(node)	((node) == 0)
 #define node_possible(node)	((node) == 0)
+#define node_populated(node)	((node) == 0)
 #define first_online_node	0
 #define next_online_node(nid)	(MAX_NUMNODES)
 #define nr_node_ids		1
@@ -375,6 +382,9 @@ extern int nr_node_ids;
 #define node_set_online(node)	   set_bit((node), node_online_map.bits)
 #define node_set_offline(node)	   clear_bit((node), node_online_map.bits)
 
+#define node_set_populated(node)   set_bit((node), node_populated_map.bits)
+#define node_not_populated(node)   clear_bit((node), node_populated_map.bits)
+
 #define for_each_node(node)	   for_each_node_mask((node), node_possible_map)
 #define for_each_online_node(node) for_each_node_mask((node), node_online_map)
 
diff a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -105,13 +105,22 @@ static void free_huge_page(struct page *page)
 
 static int alloc_fresh_huge_page(void)
 {
-	static int nid = 0;
+	static int nid = -1;
 	struct page *page;
-	page = alloc_pages_node(nid, htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
-					HUGETLB_PAGE_ORDER);
-	nid = next_node(nid, node_online_map);
-	if (nid == MAX_NUMNODES)
-		nid = first_node(node_online_map);
+	int start_nid;
+
+	if (nid < 0)
+		nid = first_node(node_populated_map);
+	start_nid = nid;
+
+	do {
+		page = alloc_pages_node(nid,
+				GFP_HIGHUSER|__GFP_COMP|GFP_THISNODE,
+				HUGETLB_PAGE_ORDER);
+		nid = next_node(nid, node_populated_map);
+		if (nid >= nr_node_ids)
+			nid = first_node(node_populated_map);
+	} while (!page && nid != start_nid);
 	if (page) {
 		set_compound_page_dtor(page, free_huge_page);
 		spin_lock(&hugetlb_lock);
diff a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -54,6 +54,9 @@ nodemask_t node_online_map __read_mostly = { { [0] = 1UL } };
 EXPORT_SYMBOL(node_online_map);
 nodemask_t node_possible_map __read_mostly = NODE_MASK_ALL;
 EXPORT_SYMBOL(node_possible_map);
+nodemask_t node_populated_map __read_mostly = NODE_MASK_NONE;
+EXPORT_SYMBOL(node_populated_map);
+
 unsigned long totalram_pages __read_mostly;
 unsigned long totalreserve_pages __read_mostly;
 long nr_swap_pages;
@@ -2161,7 +2164,7 @@ static int node_order[MAX_NUMNODES];
 static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
 {
 	enum zone_type i;
-	int pos, j, node;
+	int pos, j;
 	int zone_type;		/* needs to be signed */
 	struct zone *z;
 	struct zonelist *zonelist;
@@ -2171,7 +2174,7 @@ static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
 		pos = 0;
 		for (zone_type = i; zone_type >= 0; zone_type--) {
 			for (j = 0; j < nr_nodes; j++) {
-				node = node_order[j];
+				int node = node_order[j];
 				z = &NODE_DATA(node)->node_zones[zone_type];
 				if (populated_zone(z)) {
 					zonelist->zones[pos++] = z;
@@ -2244,6 +2247,22 @@ static void set_zonelist_order(void)
 		current_zonelist_order = user_zonelist_order;
 }
 
+/*
+ * setup_populate_map() - record nodes whose "policy_zone" is "on-node".
+ */
+static void setup_populated_map(int nid)
+{
+	pg_data_t *pgdat = NODE_DATA(nid);
+	struct zonelist *zl = pgdat->node_zonelists + policy_zone;
+	struct zone *z = zl->zones[0];
+
+	VM_BUG_ON(!z);
+	if (z->zone_pgdat == pgdat)
+		node_set_populated(nid);
+	else
+		node_not_populated(nid);
+}
+
 static void build_zonelists(pg_data_t *pgdat)
 {
 	int j, node, load;
@@ -2327,6 +2346,15 @@ static void set_zonelist_order(void)
 	current_zonelist_order = ZONELIST_ORDER_ZONE;
 }
 
+/*
+ * setup_populated_map - non-NUMA case
+ * Only node 0 should be on-line, and it MUST be populated!
+ */
+static void setup_populated_map(int nid)
+{
+	node_set_populated(nid);
+}
+
 static void build_zonelists(pg_data_t *pgdat)
 {
 	int node, local_node;
@@ -2381,6 +2409,7 @@ static int __build_all_zonelists(void *dummy)
 	for_each_online_node(nid) {
 		build_zonelists(NODE_DATA(nid));
 		build_zonelist_cache(NODE_DATA(nid));
+		setup_populated_map(nid);
 	}
 	return 0;
 }

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
