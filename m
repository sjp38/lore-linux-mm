Subject: Re: [PATCH] Fix hugetlb pool allocation with empty nodes - V2 -> V3
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0705041425450.25764@schroedinger.engr.sgi.com>
References: <20070503022107.GA13592@kryten>
	 <1178310543.5236.43.camel@localhost>
	 <Pine.LNX.4.64.0705041425450.25764@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 09 May 2007 12:37:40 -0400
Message-Id: <1178728661.5047.64.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Anton Blanchard <anton@samba.org>
Cc: linux-mm@kvack.org, ak@suse.de, nish.aravamudan@gmail.com, mel@csn.ul.ie, apw@shadowen.org, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-05-04 at 14:27 -0700, Christoph Lameter wrote:
> On Fri, 4 May 2007, Lee Schermerhorn wrote:
> 
> > On Wed, 2007-05-02 at 21:21 -0500, Anton Blanchard wrote:
> > > An interesting bug was pointed out to me where we failed to allocate
> > > hugepages evenly. In the example below node 7 has no memory (it only has
> > > CPUs). Node 0 and 1 have plenty of free memory. After doing:
> > 
> > Here's my attempt to fix the problem [I see it on HP platforms as well],
> > without removing the population check in build_zonelists_node().  Seems
> > to work.
> 
> I think we need something like for_each_online_node for each node with
> memory otherwise we are going to replicate this all over the place for 
> memoryless nodes. Add a nodemap for populated nodes?
> 
> I.e.
> 
> for_each_mem_node?
> 
> Then you do not have to check the zone flags all the time. May avoid a lot 
> of mess?

OK, here's a rework that exports a node_populated_map and associated
access functions from page_alloc.c where we already check for populated
zones.  Maybe this should be "node_hugepages_map" ?  

Also, we might consider exporting this to user space for applications
that want to "interleave across all nodes with hugepages"--not that
hugetlbfs mappings currently obey "vma policy".  Could still be used
with the "set task policy before allocating region" method [not that I
advocate this method ;-)].

I don't think that a 'for_each_*_node()' macro is appropriate for this
usage, as allocate_fresh_huge_page() is an "incremental allocator" that
returns a page from the "next eligible node" on each call.

By the way:  does anything protect the "static int nid" in
allocate_fresh_huge_page() from racing attempts to set nr_hugepages?
Can this happen?  Do we care?

Again, I chose to rework Anton's original patch, maintaining his
rationale/discussion, rather create a separate patch.  Note the "Rework"
comments therein--especially regarding NORMAL zone.  I expect we'll need
a few more rounds of "discussion" on this issue.  And, it'll require
rework to merge with the "change zonelist order" series that hits the
same area.

Lee

[PATCH] Fix hugetlb pool allocation with empty nodes - V3

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

Rework:

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

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Anton Blanchard <anton@samba.org>
 include/linux/nodemask.h |    9 +++++++++
 mm/hugetlb.c             |   20 +++++++++++++++-----
 mm/page_alloc.c          |   13 +++++++++++--
 3 files changed, 35 insertions(+), 7 deletions(-)

Index: Linux/mm/hugetlb.c
===================================================================
--- Linux.orig/mm/hugetlb.c	2007-05-08 10:27:15.000000000 -0400
+++ Linux/mm/hugetlb.c	2007-05-09 11:17:30.000000000 -0400
@@ -107,11 +107,21 @@ static int alloc_fresh_huge_page(void)
 {
 	static int nid = 0;
 	struct page *page;
-	page = alloc_pages_node(nid, htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
-					HUGETLB_PAGE_ORDER);
-	nid = next_node(nid, node_online_map);
-	if (nid == MAX_NUMNODES)
-		nid = first_node(node_online_map);
+	int start_nid = nid;
+
+	do {
+		/*
+		 * accept only nodes with populated "HIGHUSER" zone
+		 */
+		if (node_populated(nid))
+			page = alloc_pages_node(nid,
+					GFP_HIGHUSER|__GFP_COMP|GFP_THISNODE,
+  					HUGETLB_PAGE_ORDER);
+
+		nid = next_node(nid, node_online_map);
+		if (nid == MAX_NUMNODES)
+			nid = first_node(node_online_map);
+	} while (!page && nid != start_nid);
 	if (page) {
 		set_compound_page_dtor(page, free_huge_page);
 		spin_lock(&hugetlb_lock);
Index: Linux/include/linux/nodemask.h
===================================================================
--- Linux.orig/include/linux/nodemask.h	2007-04-25 23:08:32.000000000 -0400
+++ Linux/include/linux/nodemask.h	2007-05-09 10:58:04.000000000 -0400
@@ -64,12 +64,16 @@
  *
  * int node_online(node)		Is some node online?
  * int node_possible(node)		Is some node possible?
+ * int node_populated(node)		Is some node populated [at 'HIGHUSER]
  *
  * int any_online_node(mask)		First online node in mask
  *
  * node_set_online(node)		set bit 'node' in node_online_map
  * node_set_offline(node)		clear bit 'node' in node_online_map
  *
+ * node_set_poplated(node)		set bit 'node' in node_populated_map
+ * node_not_poplated(node)		clear bit 'node' in node_populated_map
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
@@ -375,6 +381,9 @@ extern int nr_node_ids;
 #define node_set_online(node)	   set_bit((node), node_online_map.bits)
 #define node_set_offline(node)	   clear_bit((node), node_online_map.bits)
 
+#define node_set_populated(node)   set_bit((node), node_populated_map.bits)
+#define node_not_populated(node)   clear_bit((node), node_populated_map.bits)
+
 #define for_each_node(node)	   for_each_node_mask((node), node_possible_map)
 #define for_each_online_node(node) for_each_node_mask((node), node_online_map)
 
Index: Linux/mm/page_alloc.c
===================================================================
--- Linux.orig/mm/page_alloc.c	2007-05-08 11:47:45.000000000 -0400
+++ Linux/mm/page_alloc.c	2007-05-09 11:16:27.000000000 -0400
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
@@ -2021,11 +2024,14 @@ void show_free_areas(void)
  * Builds allocation fallback zone lists.
  *
  * Add all populated zones of a node to the zonelist.
+ * Record nodes with populated gfp_zone(GFP_HIGHUSER) for huge page allocation.
  */
 static int __meminit build_zonelists_node(pg_data_t *pgdat,
-			struct zonelist *zonelist, int nr_zones, enum zone_type zone_type)
+			struct zonelist *zonelist, int nr_zones,
+			enum zone_type zone_type)
 {
 	struct zone *zone;
+	enum zone_type zone_highuser = gfp_zone(GFP_HIGHUSER);
 
 	BUG_ON(zone_type >= MAX_NR_ZONES);
 	zone_type++;
@@ -2036,7 +2042,10 @@ static int __meminit build_zonelists_nod
 		if (populated_zone(zone)) {
 			zonelist->zones[nr_zones++] = zone;
 			check_highest_zone(zone_type);
-		}
+			if (zone_type == zone_highuser)
+				node_set_populated(pgdat->node_id);
+		} else if (zone_type == zone_highuser)
+			node_not_populated(pgdat->node_id);
 
 	} while (zone_type);
 	return nr_zones;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
