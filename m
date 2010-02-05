Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CFCF86B0078
	for <linux-mm@kvack.org>; Fri,  5 Feb 2010 16:07:06 -0500 (EST)
Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id o15L710G001169
	for <linux-mm@kvack.org>; Fri, 5 Feb 2010 21:07:02 GMT
Received: from pzk16 (pzk16.prod.google.com [10.243.19.144])
	by spaceape13.eur.corp.google.com with ESMTP id o15L6Ow5003327
	for <linux-mm@kvack.org>; Fri, 5 Feb 2010 13:07:00 -0800
Received: by pzk16 with SMTP id 16so4259478pzk.14
        for <linux-mm@kvack.org>; Fri, 05 Feb 2010 13:06:59 -0800 (PST)
Date: Fri, 5 Feb 2010 13:06:56 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] [1/4] SLAB: Handle node-not-up case in
 fallback_alloc()
In-Reply-To: <20100203213912.D3081B1620@basil.firstfloor.org>
Message-ID: <alpine.DEB.2.00.1002051251390.2376@chino.kir.corp.google.com>
References: <201002031039.710275915@firstfloor.org> <20100203213912.D3081B1620@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: submit@firstfloor.org, linux-kernel@vger.kernel.org, haicheng.li@intel.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Feb 2010, Andi Kleen wrote:

> When fallback_alloc() runs the node of the CPU might not be initialized yet.
> Handle this case by allocating in another node.
> 

That other node must be allowed by current's cpuset, otherwise 
kmem_getpages() will fail when get_page_from_freelist() iterates only over 
unallowed nodes.

> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> ---
>  mm/slab.c |   19 ++++++++++++++++++-
>  1 file changed, 18 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.33-rc3-ak/mm/slab.c
> ===================================================================
> --- linux-2.6.33-rc3-ak.orig/mm/slab.c
> +++ linux-2.6.33-rc3-ak/mm/slab.c
> @@ -3210,7 +3210,24 @@ retry:
>  		if (local_flags & __GFP_WAIT)
>  			local_irq_enable();
>  		kmem_flagcheck(cache, flags);
> -		obj = kmem_getpages(cache, local_flags, numa_node_id());
> +
> +		/*
> +		 * Node not set up yet? Try one that the cache has been set up
> +		 * for.
> +		 */
> +		nid = numa_node_id();
> +		if (cache->nodelists[nid] == NULL) {
> +			for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
> +				nid = zone_to_nid(zone);
> +				if (cache->nodelists[nid])
> +					break;

If you set a bit in a nodemask_t everytime ____cache_alloc_node() fails in 
the previous for_each_zone_zonelist() iteration, you could just iterate 
that nodemask here without duplicating the zone_to_nid() and 
cache->nodelists[nid] != NULL check.

	nid = numa_node_id();
	if (!cache->nodelists[nid])
		for_each_node_mask(nid, allowed_nodes) {
			obj = kmem_getpages(cache, local_flags, nid);
			if (obj)
				break;
		}
	else
		obj = kmem_getpages(cache, local_flags, nid);

This way you can try all allowed nodes for memory instead of just one when 
cache->nodelists[numa_node_id()] == NULL.

> +			}
> +			if (!cache->nodelists[nid])
> +				return NULL;
> +		}
> +
> +
> +		obj = kmem_getpages(cache, local_flags, nid);
>  		if (local_flags & __GFP_WAIT)
>  			local_irq_disable();
>  		if (obj) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
