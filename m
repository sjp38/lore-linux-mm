Subject: Re: [patch 2/3] Fix GFP_THISNODE behavior for memoryless nodes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070612205738.548677035@sgi.com>
References: <20070612204843.491072749@sgi.com>
	 <20070612205738.548677035@sgi.com>
Content-Type: text/plain
Date: Wed, 13 Jun 2007 17:10:32 -0400
Message-Id: <1181769033.6148.116.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-06-12 at 13:48 -0700, clameter@sgi.com wrote:
> GFP_THISNODE checks that the zone selected is within the pgdat (node) of the
> first zone of a nodelist. That only works if the node has memory. A
> memoryless node will have its first zone on another pgdat (node).
> 
> Thus GFP_THISNODE may be returning memory on other nodes.
> GFP_THISNODE should fail if there is no local memory on a node.
> 
> So we add a check to verify that the node specified has memory in
> alloc_pages_node(). If the node has no memory then return NULL.
> 
> The case of alloc_pages(GFP_THISNODE) is not changed. alloc_pages() (with
> no memory policies in effect) is understood to prefer the current node.
> If a process is running on a node with no memory then its default allocations
> come from the next neighboring node. GFP_THISNODE will then force the memory
> to come from that node.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 
> Index: linux-2.6.22-rc4-mm2/include/linux/gfp.h
> ===================================================================
> --- linux-2.6.22-rc4-mm2.orig/include/linux/gfp.h	2007-06-12 12:33:37.000000000 -0700
> +++ linux-2.6.22-rc4-mm2/include/linux/gfp.h	2007-06-12 12:38:37.000000000 -0700
> @@ -175,6 +175,13 @@ static inline struct page *alloc_pages_n
>  	if (nid < 0)
>  		nid = numa_node_id();
>  
> +	/*
> +	 * Check for the special case that GFP_THISNODE is used on a
> +	 * memoryless node
> +	 */
> +	if ((gfp_mask & __GFP_THISNODE) && !node_memory(nid))
> +		return NULL;
> +
>  	return __alloc_pages(gfp_mask, order,
>  		NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));
>  }
> 

Attached patch fixes alloc_pages_node() so that it never returns an
off-node page when GFP_THISNODE is specified by.  This requires a fix to
SLUB early allocation, included in the patch.  Works on HP ia64 platform
with small DMA only node and "zone order" zonelists.  Will test on
x86_64 real soon now...

---

PATCH  fix GFP_THISNODE for DMA only nodes and zone-order zonelists

The map of nodes with memory may include nodes with just
DMA/DMA32 memory.  Using this map/mask together with
GFP_THISNODE will not guarantee on-node allocations at higher
zones.  Modify checks in alloc_pages_node() to ensure that the
first zone in the selected zonelist is "on-node".

This change will result in alloc_pages_node() returning NULL
when GFP_THISNODE is specified and the first zone in the zonelist
selected by (nid, gfp_zone(gfp_mask) is not on node 'nid'.  This,
in turn, BUGs out in slub.c:early_kmem_cache_node_alloc() which
apparently can't handle a NULL page from new_slab().  Fix SLUB
to handle NULL page in early allocation.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/gfp.h |   11 ++++++++---
 mm/slub.c           |   22 ++++++++++++----------
 2 files changed, 20 insertions(+), 13 deletions(-)

Index: Linux/include/linux/gfp.h
===================================================================
--- Linux.orig/include/linux/gfp.h	2007-06-13 16:36:02.000000000 -0400
+++ Linux/include/linux/gfp.h	2007-06-13 16:38:41.000000000 -0400
@@ -168,6 +168,9 @@ FASTCALL(__alloc_pages(gfp_t, unsigned i
 static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 						unsigned int order)
 {
+	pg_data_t *pgdat;
+	struct zonelist *zonelist;
+
 	if (unlikely(order >= MAX_ORDER))
 		return NULL;
 
@@ -179,11 +182,13 @@ static inline struct page *alloc_pages_n
 	 * Check for the special case that GFP_THISNODE is used on a
 	 * memoryless node
 	 */
-	if ((gfp_mask & __GFP_THISNODE) && !node_memory(nid))
+	pgdat = NODE_DATA(nid);
+	zonelist = pgdat->node_zonelists + gfp_zone(gfp_mask);
+	if ((gfp_mask & __GFP_THISNODE) &&
+		pgdat != zonelist->zones[0]->zone_pgdat)
 		return NULL;
 
-	return __alloc_pages(gfp_mask, order,
-		NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));
+	return __alloc_pages(gfp_mask, order, zonelist);
 }
 
 #ifdef CONFIG_NUMA
Index: Linux/mm/slub.c
===================================================================
--- Linux.orig/mm/slub.c	2007-06-13 16:36:02.000000000 -0400
+++ Linux/mm/slub.c	2007-06-13 16:38:41.000000000 -0400
@@ -1870,16 +1870,18 @@ static struct kmem_cache_node * __init e
 	/* new_slab() disables interupts */
 	local_irq_enable();
 
-	BUG_ON(!page);
-	n = page->freelist;
-	BUG_ON(!n);
-	page->freelist = get_freepointer(kmalloc_caches, n);
-	page->inuse++;
-	kmalloc_caches->node[node] = n;
-	setup_object_debug(kmalloc_caches, page, n);
-	init_kmem_cache_node(n);
-	atomic_long_inc(&n->nr_slabs);
-	add_partial(n, page);
+	if (page) {
+		n = page->freelist;
+		BUG_ON(!n);
+		page->freelist = get_freepointer(kmalloc_caches, n);
+		page->inuse++;
+		kmalloc_caches->node[node] = n;
+		setup_object_debug(kmalloc_caches, page, n);
+		init_kmem_cache_node(n);
+		atomic_long_inc(&n->nr_slabs);
+		add_partial(n, page);
+	} else
+		kmalloc_caches->node[node] = NULL;
 	return n;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
