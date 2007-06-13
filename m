Date: Wed, 13 Jun 2007 15:46:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/3] Fix GFP_THISNODE behavior for memoryless nodes
In-Reply-To: <1181769033.6148.116.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706131535200.32399@schroedinger.engr.sgi.com>
References: <20070612204843.491072749@sgi.com>  <20070612205738.548677035@sgi.com>
 <1181769033.6148.116.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jun 2007, Lee Schermerhorn wrote:

> SLUB early allocation, included in the patch.  Works on HP ia64 platform
> with small DMA only node and "zone order" zonelists.  Will test on
> x86_64 real soon now...

I do not see the difference?? How does this work? node_memory(x) fails 
there?

> The map of nodes with memory may include nodes with just
> DMA/DMA32 memory.  Using this map/mask together with
> GFP_THISNODE will not guarantee on-node allocations at higher
> zones.  Modify checks in alloc_pages_node() to ensure that the
> first zone in the selected zonelist is "on-node".

That check is already done by __alloc_pages.

> This change will result in alloc_pages_node() returning NULL
> when GFP_THISNODE is specified and the first zone in the zonelist
> selected by (nid, gfp_zone(gfp_mask) is not on node 'nid'.  This,
> in turn, BUGs out in slub.c:early_kmem_cache_node_alloc() which
> apparently can't handle a NULL page from new_slab().  Fix SLUB
> to handle NULL page in early allocation.

Ummm... Slub would need to consult node_memory_map instead I guess.

> Index: Linux/mm/slub.c
> ===================================================================
> --- Linux.orig/mm/slub.c	2007-06-13 16:36:02.000000000 -0400
> +++ Linux/mm/slub.c	2007-06-13 16:38:41.000000000 -0400
> @@ -1870,16 +1870,18 @@ static struct kmem_cache_node * __init e
>  	/* new_slab() disables interupts */
>  	local_irq_enable();
>  
> -	BUG_ON(!page);
> -	n = page->freelist;
> -	BUG_ON(!n);
> -	page->freelist = get_freepointer(kmalloc_caches, n);
> -	page->inuse++;
> -	kmalloc_caches->node[node] = n;
> -	setup_object_debug(kmalloc_caches, page, n);
> -	init_kmem_cache_node(n);
> -	atomic_long_inc(&n->nr_slabs);
> -	add_partial(n, page);
> +	if (page) {
> +		n = page->freelist;
> +		BUG_ON(!n);
> +		page->freelist = get_freepointer(kmalloc_caches, n);
> +		page->inuse++;
> +		kmalloc_caches->node[node] = n;
> +		setup_object_debug(kmalloc_caches, page, n);
> +		init_kmem_cache_node(n);
> +		atomic_long_inc(&n->nr_slabs);
> +		add_partial(n, page);
> +	} else
> +		kmalloc_caches->node[node] = NULL;
>  	return n;
>  }

It would be easier to modify SLUB to loop over node_memory_map instead of 
node_online_map? Potentially we have to change all loops over online node 
in the slab allocators.

---
 include/linux/nodemask.h |    1 +
 mm/slub.c                |    2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/nodemask.h
===================================================================
--- linux-2.6.orig/include/linux/nodemask.h	2007-06-13 15:40:27.000000000 -0700
+++ linux-2.6/include/linux/nodemask.h	2007-06-13 15:40:48.000000000 -0700
@@ -377,5 +377,6 @@ extern int nr_node_ids;
 
 #define for_each_node(node)	   for_each_node_mask((node), node_possible_map)
 #define for_each_online_node(node) for_each_node_mask((node), node_online_map)
+#define for_each_memory_node(node) for_each_node_mask((node), node_memory_map)
 
 #endif /* __LINUX_NODEMASK_H */
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-06-13 15:39:16.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-06-13 15:40:23.000000000 -0700
@@ -1836,7 +1836,7 @@ static int init_kmem_cache_nodes(struct 
 	else
 		local_node = 0;
 
-	for_each_online_node(node) {
+	for_each_memory_node(node) {
 		struct kmem_cache_node *n;
 
 		if (local_node == node)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
