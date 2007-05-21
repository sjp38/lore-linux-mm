Subject: Re: [PATCH/RFC] Fix hugetlb pool allocation with empty nodes - V4
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <29495f1d0705171730h552f7d80hc3f991f8dce9d4c2@mail.gmail.com>
References: <20070503022107.GA13592@kryten>
	 <1178310543.5236.43.camel@localhost>
	 <Pine.LNX.4.64.0705041425450.25764@schroedinger.engr.sgi.com>
	 <1178728661.5047.64.camel@localhost>
	 <29495f1d0705161259p70a1e499tb831889fd2bcebcb@mail.gmail.com>
	 <1179353841.5867.53.camel@localhost>
	 <29495f1d0705171730h552f7d80hc3f991f8dce9d4c2@mail.gmail.com>
Content-Type: text/plain
Date: Mon, 21 May 2007 10:57:08 -0400
Message-Id: <1179759429.5113.16.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: Christoph Lameter <clameter@sgi.com>, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, ak@suse.de, mel@csn.ul.ie, apw@shadowen.org, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>, andyw@uk.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-05-17 at 17:30 -0700, Nish Aravamudan wrote:
> On 5/16/07, Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> > On Wed, 2007-05-16 at 12:59 -0700, Nish Aravamudan wrote:
> >
> > <snip>
> > >
> > > This completely breaks hugepage allocation on 4-node x86_64 box I have
> > > here. Each node has <4GB of memory, so all memory is ZONE_DMA and
> > > ZONE_DMA32. gfp_zone(GFP_HIGHUSER) is ZONE_NORMAL, though. So all
> > > nodes are not populated by the default initialization to an empty
> > > nodemask.
> > >
> > > Thanks to Andy Whitcroft for helping me debug this.
> > >
> > > I'm not sure how to fix this -- but I ran into while trying to base my
> > > sysfs hugepage allocation patches on top of yours.
> >
> > OK.  Try this.  Tested OK on 4 node [+ 1 pseudo node] ia64 and 2 node
> > x86_64.  The x86_64 had 2G per node--all DMA32.
> >
> > Notes:
> >
> > 1) applies on 2.6.22-rc1-mm1 atop my earlier patch to add the call to
> > check_highest_zone() to build_zonelists_in_zone_order().  I think it'll
> > apply [with offsets] w/o that patch.
> 
> Could you give both patches (or just this one) against 2.6.22-rc1 or
> current -linus? -mm1 has build issues on ppc64 and i386 (as reported
> by Andy and Mel in other threads).

Nish:

Here's the hugepage fix against 2.6.22-rc2 for your testing.  I think
the patch still needs to cook in -mm if you think it's OK.

Lee

[PATCH 2.6.22-rc2] Fix hugetlb pool allocation with empty nodes V4a

Temporary patch against 2.6.22-rc2 for Nish's testing.  

description and signoffs intentionally omitted


 include/linux/nodemask.h |   10 ++++++++++
 mm/hugetlb.c             |   21 +++++++++++++++------
 mm/page_alloc.c          |   29 +++++++++++++++++++++++++++++
 3 files changed, 54 insertions(+), 6 deletions(-)

Index: Linux/mm/hugetlb.c
===================================================================
--- Linux.orig/mm/hugetlb.c	2007-05-21 09:22:53.000000000 -0400
+++ Linux/mm/hugetlb.c	2007-05-21 10:00:45.000000000 -0400
@@ -101,13 +101,22 @@ static void free_huge_page(struct page *
 
 static int alloc_fresh_huge_page(void)
 {
-	static int nid = 0;
+	static int nid = -1;
 	struct page *page;
-	page = alloc_pages_node(nid, GFP_HIGHUSER|__GFP_COMP|__GFP_NOWARN,
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
--- Linux.orig/include/linux/nodemask.h	2007-04-25 23:08:32.000000000 -0400
+++ Linux/include/linux/nodemask.h	2007-05-21 09:59:16.000000000 -0400
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
--- Linux.orig/mm/page_alloc.c	2007-05-21 09:22:53.000000000 -0400
+++ Linux/mm/page_alloc.c	2007-05-21 10:03:17.000000000 -0400
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
@@ -1719,6 +1722,22 @@ static int __meminit find_next_best_node
 	return best_node;
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
 static void __meminit build_zonelists(pg_data_t *pgdat)
 {
 	int j, node, local_node;
@@ -1788,6 +1807,15 @@ static void __meminit build_zonelist_cac
 
 #else	/* CONFIG_NUMA */
 
+/*
+ * setup_populated_map - non-NUMA case
+ * Only node 0 should be on-line, and it MUST be populated!
+ */
+static void setup_populated_map(int nid)
+{
+	node_set_populated(nid);
+}
+
 static void __meminit build_zonelists(pg_data_t *pgdat)
 {
 	int node, local_node;
@@ -1842,6 +1870,7 @@ static int __meminit __build_all_zonelis
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
