Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 75CFB6B0031
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 02:41:27 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id md12so19586187pbc.21
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 23:41:27 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id l8si57520098pao.7.2014.01.06.23.41.24
        for <linux-mm@kvack.org>;
        Mon, 06 Jan 2014 23:41:26 -0800 (PST)
Date: Tue, 7 Jan 2014 16:41:36 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <20140107074136.GA4011@lge.com>
References: <20140107132100.5b5ad198@kryten>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140107132100.5b5ad198@kryten>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: benh@kernel.crashing.org, paulus@samba.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, nacc@linux.vnet.ibm.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Tue, Jan 07, 2014 at 01:21:00PM +1100, Anton Blanchard wrote:
> 
> We noticed a huge amount of slab memory consumed on a large ppc64 box:
> 
> Slab:            2094336 kB
> 
> Almost 2GB. This box is not balanced and some nodes do not have local
> memory, causing slub to be very inefficient in its slab usage.
> 
> Each time we call kmem_cache_alloc_node slub checks the per cpu slab,
> sees it isn't node local, deactivates it and tries to allocate a new
> slab. On empty nodes we will allocate a new remote slab and use the
> first slot, but as explained above when we get called a second time
> we will just deactivate that slab and retry.
> 
> As such we end up only using 1 entry in each slab:
> 
> slab                    mem  objects
>                        used   active
> ------------------------------------
> kmalloc-16384       1404 MB    4.90%
> task_struct          668 MB    2.90%
> kmalloc-128          193 MB    3.61%
> kmalloc-192          152 MB    5.23%
> kmalloc-8192          72 MB   23.40%
> kmalloc-16            64 MB    7.43%
> kmalloc-512           33 MB   22.41%
> 
> The patch below checks that a node is not empty before deactivating a
> slab and trying to allocate it again. With this patch applied we now
> use about 352MB:
> 
> Slab:             360192 kB
> 
> And our efficiency is much better:
> 
> slab                    mem  objects
>                        used   active
> ------------------------------------
> kmalloc-16384         92 MB   74.27%
> task_struct           23 MB   83.46%
> idr_layer_cache       18 MB  100.00%
> pgtable-2^12          17 MB  100.00%
> kmalloc-65536         15 MB  100.00%
> inode_cache           14 MB  100.00%
> kmalloc-256           14 MB   97.81%
> kmalloc-8192          14 MB   85.71%
> 
> Signed-off-by: Anton Blanchard <anton@samba.org>
> ---
> 
> Thoughts? It seems like we could hit a similar situation if a machine
> is balanced but we run out of memory on a single node.
> 
> Index: b/mm/slub.c
> ===================================================================
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2278,10 +2278,17 @@ redo:
>  
>  	if (unlikely(!node_match(page, node))) {
>  		stat(s, ALLOC_NODE_MISMATCH);
> -		deactivate_slab(s, page, c->freelist);
> -		c->page = NULL;
> -		c->freelist = NULL;
> -		goto new_slab;
> +
> +		/*
> +		 * If the node contains no memory there is no point in trying
> +		 * to allocate a new node local slab
> +		 */
> +		if (node_spanned_pages(node)) {
> +			deactivate_slab(s, page, c->freelist);
> +			c->page = NULL;
> +			c->freelist = NULL;
> +			goto new_slab;
> +		}
>  	}
>  
>  	/*

Hello,

I think that we need more efforts to solve unbalanced node problem.

With this patch, even if node of current cpu slab is not favorable to
unbalanced node, allocation would proceed and we would get the unintended memory.

And there is one more problem. Even if we have some partial slabs on
compatible node, we would allocate new slab, because get_partial() cannot handle
this unbalance node case.

To fix this correctly, how about following patch?

Thanks.

------------->8--------------------
diff --git a/mm/slub.c b/mm/slub.c
index c3eb3d3..a1f6dfa 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1672,7 +1672,19 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
 {
        void *object;
        int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
+       struct zonelist *zonelist;
+       struct zoneref *z;
+       struct zone *zone;
+       enum zone_type high_zoneidx = gfp_zone(flags);
 
+       if (!node_present_pages(searchnode)) {
+               zonelist = node_zonelist(searchnode, flags);
+               for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
+                       searchnode = zone_to_nid(zone);
+                       if (node_present_pages(searchnode))
+                               break;
+               }
+       }
        object = get_partial_node(s, get_node(s, searchnode), c, flags);
        if (object || node != NUMA_NO_NODE)
                return object;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
