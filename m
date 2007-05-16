Subject: [PATCH/RFC] Fix hugetlb pool allocation with empty nodes - V4
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <29495f1d0705161259p70a1e499tb831889fd2bcebcb@mail.gmail.com>
References: <20070503022107.GA13592@kryten>
	 <1178310543.5236.43.camel@localhost>
	 <Pine.LNX.4.64.0705041425450.25764@schroedinger.engr.sgi.com>
	 <1178728661.5047.64.camel@localhost>
	 <29495f1d0705161259p70a1e499tb831889fd2bcebcb@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 16 May 2007 18:17:20 -0400
Message-Id: <1179353841.5867.53.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: Christoph Lameter <clameter@sgi.com>, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, ak@suse.de, mel@csn.ul.ie, apw@shadowen.org, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>, andyw@uk.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-16 at 12:59 -0700, Nish Aravamudan wrote:

<snip>
> 
> This completely breaks hugepage allocation on 4-node x86_64 box I have
> here. Each node has <4GB of memory, so all memory is ZONE_DMA and
> ZONE_DMA32. gfp_zone(GFP_HIGHUSER) is ZONE_NORMAL, though. So all
> nodes are not populated by the default initialization to an empty
> nodemask.
> 
> Thanks to Andy Whitcroft for helping me debug this.
> 
> I'm not sure how to fix this -- but I ran into while trying to base my
> sysfs hugepage allocation patches on top of yours.

OK.  Try this.  Tested OK on 4 node [+ 1 pseudo node] ia64 and 2 node
x86_64.  The x86_64 had 2G per node--all DMA32.

Notes:

1) applies on 2.6.22-rc1-mm1 atop my earlier patch to add the call to
check_highest_zone() to build_zonelists_in_zone_order().  I think it'll
apply [with offsets] w/o that patch.

2) non-NUMA case not tested.

3) note the redefinition of the populated map and the possible side
effects with some non-symmetric node memory configurations.

4) this is an RFC.  As a minimum, I'll need to repost with a cleaner
patch description, I think.  I.e., minus these notes...

5) I've retained Anton's original sign off.  Hope that's OK...

Lee

[PATCH 2.6.22-rc1-mm1] Fix hugetlb pool allocation with empty nodes V4

Original Patch [V1]:

Date:	Wed, 2 May 2007 21:21:07 -0500
From: Anton Blanchard <anton@samba.org>
To: linux-mm@kvack.org, clameter@SGI.com, ak@suse.de
Cc: nish.aravamudan@gmail.com, mel@csn.ul.ie, apw@shadowen.org
Subject: [PATCH] Fix hugetlb pool allocation with empty nodes

An interesting bug was pointed out to me where we failed to allocate
hugepages evenly. In the example below node 7 has no memory (it only has
CPUs). Node 0 and 1 have plenty of free memory. After doing:

# echo 16 > /proc/sys/vm/nr_hugepages

We see the imbalance:

# cat /sys/devices/system/node/node*/meminfo|grep HugePages_Total
Node 0 HugePages_Total:     6
Node 1 HugePages_Total:     10
Node 7 HugePages_Total:     0

It didn't take long to realise that alloc_fresh_huge_page is allocating
from node 7 without GFP_THISNODE set, so we fallback to its next
preferred node (ie 1). This means we end up with a 1/3 2/3 imbalance.

After fixing this it still didnt work, and after some more poking I see
why. When building our fallback zonelist in build_zonelists_node we
skip empty zones. This means zone 7 never registers node 7's empty
zonelists and instead registers node 1's. Therefore when we ask for a
page from node 7, using the GFP_THISNODE flag we end up with node 1
memory.

By removing the populated_zone() check in build_zonelists_node we fix
the problem:

# cat /sys/devices/system/node/node*/meminfo|grep HugePages_Total
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
populated zones.  This is early enough for boot time allocation of
huge pages.

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

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Anton Blanchard <anton@samba.org>

 include/linux/nodemask.h |   10 ++++++++++
 mm/hugetlb.c             |   21 +++++++++++++++------
 mm/page_alloc.c          |   33 +++++++++++++++++++++++++++++++--
 3 files changed, 56 insertions(+), 8 deletions(-)

Index: Linux/mm/hugetlb.c
===================================================================
--- Linux.orig/mm/hugetlb.c	2007-05-16 17:45:38.000000000 -0400
+++ Linux/mm/hugetlb.c	2007-05-16 17:47:54.000000000 -0400
@@ -105,13 +105,22 @@ static void free_huge_page(struct page *
 
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
+  				HUGETLB_PAGE_ORDER);
+		nid = next_node(nid, node_populated_map);
+		if (nid >= nr_node_ids)
+			nid = first_node(node_populated_map);
+	} while (!page && nid != start_nid);
 	if (page) {
 		set_compound_page_dtor(page, free_huge_page);
 		spin_lock(&hugetlb_lock);
Index: Linux/include/linux/nodemask.h
===================================================================
--- Linux.orig/include/linux/nodemask.h	2007-05-16 17:45:38.000000000 -0400
+++ Linux/include/linux/nodemask.h	2007-05-16 17:47:54.000000000 -0400
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
@@ -344,12 +348,14 @@ static inline void __nodes_remap(nodemas
 
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
 
Index: Linux/mm/page_alloc.c
===================================================================
--- Linux.orig/mm/page_alloc.c	2007-05-16 17:47:53.000000000 -0400
+++ Linux/mm/page_alloc.c	2007-05-16 17:47:54.000000000 -0400
@@ -54,6 +54,9 @@ nodemask_t node_online_map __read_mostly
 EXPORT_SYMBOL(node_online_map);
 nodemask_t node_possible_map __read_mostly = NODE_MASK_ALL;
 EXPORT_SYMBOL(node_possible_map);
+nodemask_t node_populated_map __read_mostly = NODE_MASK_NONE;
+EXPORT_SYMBOL(node_populated_map);
+
 unsigned long totalram_pages __read_mostly;
 unsigned long totalreserve_pages __read_mostly;
 long nr_swap_pages;
@@ -2203,7 +2206,7 @@ static int node_order[MAX_NUMNODES];
 static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
 {
 	enum zone_type i;
-	int pos, j, node;
+	int pos, j;
 	int zone_type;		/* needs to be signed */
 	struct zone *z;
 	struct zonelist *zonelist;
@@ -2213,7 +2216,7 @@ static void build_zonelists_in_zone_orde
 		pos = 0;
 		for (zone_type = i; zone_type >= 0; zone_type--) {
 			for (j = 0; j < nr_nodes; j++) {
-				node = node_order[j];
+				int node = node_order[j];
 				z = &NODE_DATA(node)->node_zones[zone_type];
 				if (populated_zone(z)) {
 					zonelist->zones[pos++] = z;
@@ -2286,6 +2289,22 @@ static void set_zonelist_order(void)
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
@@ -2369,6 +2388,15 @@ static void set_zonelist_order(void)
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
@@ -2423,6 +2451,7 @@ static int __build_all_zonelists(void *d
 	for_each_online_node(nid) {
 		build_zonelists(NODE_DATA(nid));
 		build_zonelist_cache(NODE_DATA(nid));
+		setup_populated_map(nid);
 	}
 	return 0;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
