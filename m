Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BMAfrC029211
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 18:10:41 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BMAfwP549408
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 18:10:41 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BMAeDY006232
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 18:10:41 -0400
Date: Mon, 11 Jun 2007 15:10:36 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH v2] Add populated_map to account for memoryless nodes
Message-ID: <20070611221036.GA14458@us.ibm.com>
References: <20070611202728.GD9920@us.ibm.com> <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [14:25:38 -0700], Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> > @@ -2161,7 +2164,7 @@ static int node_order[MAX_NUMNODES];
> >  static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
> >  {
> >  	enum zone_type i;
> > -	int pos, j, node;
> > +	int pos, j;
> >  	int zone_type;		/* needs to be signed */
> >  	struct zone *z;
> >  	struct zonelist *zonelist;
> > @@ -2171,7 +2174,7 @@ static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
> >  		pos = 0;
> >  		for (zone_type = i; zone_type >= 0; zone_type--) {
> >  			for (j = 0; j < nr_nodes; j++) {
> > -				node = node_order[j];
> > +				int node = node_order[j];
> >  				z = &NODE_DATA(node)->node_zones[zone_type];
> >  				if (populated_zone(z)) {
> >  					zonelist->zones[pos++] = z;
> 
> Unrelated modifications.

Agreed -- sorry, I have just been refreshing/testing Lee and Anton's
original fixes.

> > @@ -2244,6 +2247,22 @@ static void set_zonelist_order(void)
> >  		current_zonelist_order = user_zonelist_order;
> >  }
> >  
> > +/*
> > + * setup_populate_map() - record nodes whose "policy_zone" is "on-node".
> > + */
> > +static void setup_populated_map(int nid)
> > +{
> > +	pg_data_t *pgdat = NODE_DATA(nid);
> > +	struct zonelist *zl = pgdat->node_zonelists + policy_zone;
> > +	struct zone *z = zl->zones[0];
> > +
> > +	VM_BUG_ON(!z);
> > +	if (z->zone_pgdat == pgdat)
> > +		node_set_populated(nid);
> > +	else
> > +		node_not_populated(nid);
> > +}
> 
> 
> A node is only populated if it has memory in the policy zone? I would
> say a node is populated if it has any memory in any zone.
> 
> The above check may fail on x86_64 where only some nodes may have 
> ZONE_NORMAL. Others only have ZONE_DMA32. Policy zone will be set to 
> ZONE_NORMAL.

I agree here as well, updated below.

> >  static void build_zonelists(pg_data_t *pgdat)
> >  {
> >  	int j, node, load;
> > @@ -2327,6 +2346,15 @@ static void set_zonelist_order(void)
> >  	current_zonelist_order = ZONELIST_ORDER_ZONE;
> >  }
> >  
> > +/*
> > + * setup_populated_map - non-NUMA case
> > + * Only node 0 should be on-line, and it MUST be populated!
> > + */
> > +static void setup_populated_map(int nid)
> > +{
> > +	node_set_populated(nid);
> > +}
> 
> I'd say provide fallback functions so that node_populated() always
> returns true for !NUMA. That way it can be optimized out at compile
> time.

Already done in the original patch (node_populated() returns (node == 0)
if MAX_NUMODES <= 1), I think.

> >  static void build_zonelists(pg_data_t *pgdat)
> >  {
> >  	int node, local_node;
> > @@ -2381,6 +2409,7 @@ static int __build_all_zonelists(void *dummy)
> >  	for_each_online_node(nid) {
> >  		build_zonelists(NODE_DATA(nid));
> >  		build_zonelist_cache(NODE_DATA(nid));
> > +		setup_populated_map(nid);
> >  	}
> 
> Is it possible to move the set_populated_node into build_zonelists 
> somehow?
> 
> F.e. In build_zonelists_node you can check if nr_zones > 0 and then
> set it up?

I've tried to do this as well, please see below.

Split up Lee and Anton's original patch
(http://marc.info/?l=linux-mm&m=118133042025995&w=2), to allow for the
populated_map changes to go in on their own.

Add a populated_map nodemask to indicate a node has memory or not.  We
have run into a number of issues (in practice and in code) with
assumptions about every node having memory. Having this nodemask allows
us to fix these issues; in particular, THISNODE allocations will come
from the node specified, only, and the INTERLEAVE policy will be able to
do the right thing with memoryless nodes.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index 52c54a5..751d3d7 100644
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
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 07cd5ae..1d20f8f 100644
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
@@ -2251,6 +2254,7 @@ static void build_zonelists(pg_data_t *pgdat)
 	nodemask_t used_mask;
 	int local_node, prev_node;
 	struct zonelist *zonelist;
+	struct zone *z;
 	int order = current_zonelist_order;
 
 	/* initialize zonelists */
@@ -2299,6 +2303,18 @@ static void build_zonelists(pg_data_t *pgdat)
 		/* calculate node order -- i.e., DMA last! */
 		build_zonelists_in_zone_order(pgdat, j);
 	}
+
+	/*
+	 * record nodes whose first fallback zone is "on-node" as
+	 * populated
+	 */
+	z = pgdat->node_zonelists->zones[0];
+
+	VM_BUG_ON(!z);
+	if (z->zone_pgdat == pgdat)
+		node_set_populated(local_node);
+	else
+		node_not_populated(local_node);
 }
 
 /* Construct the zonelist performance cache - see further mmzone.h */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
