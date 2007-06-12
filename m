Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5CJp2jo022207
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 15:51:02 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5CJnuV9259028
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 15:49:56 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5CJnuVY003903
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 15:49:56 -0400
Date: Tue, 12 Jun 2007 12:49:51 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH v2] Add populated_map to account for memoryless nodes
Message-ID: <20070612194951.GC3798@us.ibm.com>
References: <20070611202728.GD9920@us.ibm.com> <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com> <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <1181657940.5592.19.camel@localhost> <Pine.LNX.4.64.0706121143530.30754@schroedinger.engr.sgi.com> <1181675840.5592.123.camel@localhost> <Pine.LNX.4.64.0706121220580.3240@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706121220580.3240@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 12.06.2007 [12:22:37 -0700], Christoph Lameter wrote:
> On Tue, 12 Jun 2007, Lee Schermerhorn wrote:
> 
> > On Tue, 2007-06-12 at 11:45 -0700, Christoph Lameter wrote:
> > Now, Nish is proposing to use the populated map to filter policy-based
> > interleaved allocations.  My definition of populated map won't work for
> > that.  So, YOU are the one changing the definition.  I'm OK with that if
> > it solves a more generic problem.  My patch hadn't gone in anyway.
> 
> Ok. So how about renaming the populated_map to
> 
> node_memory_map
> 
> so that its clear that this is a map of node with memory?
> 
> GFP_THISNODE needs this map to fail on memoryless nodes.
> 
> > Yes, but I didn't want to stick #ifdefs in the functions if I didn't
> > have to.  But, it's a moot point.  After looking at it more, I've
> > decided there may be no definition of populated map that works reliably
> > for huge page allocation on all of the platform configurations.
> > However, if GFP_THISNODE guarantees no off-node allocations, that may do
> > the trick.
> 
> It can do that if the populated map works the right way.... circle is 
> closing ... I can sent out a patchset in a few minutes that fixes the 
> GFP_THISNODE issue and introduces node_memory_map.

Something like the following (need to s/populated/memory/ as
approparitely, still... so not s-o-b...

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 49dcc2f..453cc32 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -175,6 +175,9 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 	if (nid < 0)
 		nid = numa_node_id();
 
+	if ((gfp_mask & __GFP_THISNODE) && !node_is_populated(nid))
+		return NULL;
+
 	return __alloc_pages(gfp_mask, order,
 		NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));
 }
diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index 52c54a5..4fb054a 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -70,6 +70,10 @@
  * node_set_online(node)		set bit 'node' in node_online_map
  * node_set_offline(node)		clear bit 'node' in node_online_map
  *
+ * node_set_populated(node)		set bit 'node' in node_populated_map
+ * node_set_unpopulated(node)		clear bit 'node' in node_populated_map
+ * int node_is_populated(node)		Does some node have pages_present != 0?
+ *
  * for_each_node(node)			for-loop node over node_possible_map
  * for_each_online_node(node)		for-loop node over node_online_map
  *
@@ -353,6 +357,10 @@ extern nodemask_t node_possible_map;
 #define first_online_node	first_node(node_online_map)
 #define next_online_node(nid)	next_node((nid), node_online_map)
 extern int nr_node_ids;
+extern nodemask_t node_populated_map;
+#define node_set_populated(node)	set_bit((node), node_populated_map.bits)
+#define node_set_unpopulated(node)	clear_bit((node), node_populated_map.bits)
+#define node_is_populated(node)		node_isset((node), node_populated_map)
 #else
 #define num_online_nodes()	1
 #define num_possible_nodes()	1
@@ -361,6 +369,9 @@ extern int nr_node_ids;
 #define first_online_node	0
 #define next_online_node(nid)	(MAX_NUMNODES)
 #define nr_node_ids		1
+#define node_set_populated(node)	do { } while (0)
+#define node_set_unpopulated(node)	do { } while (0)
+#define node_is_populated(nid)	((node) == 0)
 #endif
 
 #define any_online_node(mask)			\
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 07cd5ae..fab163d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -54,6 +54,8 @@ nodemask_t node_online_map __read_mostly = { { [0] = 1UL } };
 EXPORT_SYMBOL(node_online_map);
 nodemask_t node_possible_map __read_mostly = NODE_MASK_ALL;
 EXPORT_SYMBOL(node_possible_map);
+nodemask_t node_populated_map __read_mostly = { { [0] = 1UL } };
+EXPORT_SYMBOL(node_populated_map);
 unsigned long totalram_pages __read_mostly;
 unsigned long totalreserve_pages __read_mostly;
 long nr_swap_pages;
@@ -2299,6 +2301,13 @@ static void build_zonelists(pg_data_t *pgdat)
 		/* calculate node order -- i.e., DMA last! */
 		build_zonelists_in_zone_order(pgdat, j);
 	}
+
+	/*
+	 * Node and Memory Hot-Unplug will need to invoke
+	 * node_set_unpopulated if a node is made to be memory-less
+	 */
+	if (pgdat->node_present_pages)
+		node_set_populated(local_node);
 }
 
 /* Construct the zonelist performance cache - see further mmzone.h */

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
