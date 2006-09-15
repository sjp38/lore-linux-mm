Date: Thu, 14 Sep 2006 22:00:11 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060914220011.2be9100a.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Sep 2006 16:50:41 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> This patch insures that the slab node lists in the NUMA case only contain
> slabs that belong to that specific node. All slab allocations use
> GFP_THISNODE when calling into the page allocator. If an allocation fails
> then we fall back in the slab allocator according to the zonelists
> appropriate for a certain context.
> 
> This allows a replication of the behavior of alloc_pages and alloc_pages
> node in the slab layer.
> 
> Currently allocations requested from the page allocator may be redirected
> via cpusets to other nodes. This results in remote pages on nodelists and
> that in turn results in interrupt latency issues during cache draining.
> Plus the slab is handing out memory as local when it is really remote.
> 
> Fallback for slab memory allocations will occur within the slab
> allocator and not in the page allocator. This is necessary in order
> to be able to use the existing pools of objects on the nodes that
> we fall back to before adding more pages to a slab.
> 
> The fallback function insures that the nodes we fall back to obey
> cpuset restrictions of the current context. We do not allocate
> objects from outside of the current cpuset context like before.
> 
> Note that the implementation of locality constraints within the slab
> allocator requires importing logic from the page allocator. This is a
> mischmash that is not that great. Other allocators (uncached allocator,
> vmalloc, huge pages) face similar problems and have similar minimal
> reimplementations of the basic fallback logic of the page allocator.
> There is another way of implementing a slab by avoiding per node lists
> (see modular slab) but this wont work within the existing slab.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.18-rc6-mm2/mm/slab.c
> ===================================================================
> --- linux-2.6.18-rc6-mm2.orig/mm/slab.c	2006-09-13 18:04:57.000000000 -0500
> +++ linux-2.6.18-rc6-mm2/mm/slab.c	2006-09-13 18:20:41.356901622 -0500
> @@ -1566,6 +1566,14 @@ static void *kmem_getpages(struct kmem_c
>  	 */
>  	flags |= __GFP_COMP;
>  #endif
> +#ifdef CONFIG_NUMA
> +	/*
> +	 * Under NUMA we want memory on the indicated node. We will handle
> +	 * the needed fallback ourselves since we want to serve from our
> +	 * per node object lists first for other nodes.
> +	 */
> +	flags |= GFP_THISNODE;
> +#endif

hm.  GFP_THISNODE is dangerous.  For example, its use in
kernel/profile.c:create_hash_tables() has gone and caused non-NUMA machines
to use __GFP_NOWARN | __GFP_NORETRY in this situation.

OK, that's relatively harmless here, but why on earth did non-NUMA
machines want to make this change?

Would it not be saner to do away with the dangerous GFP_THISNODE and then
open-code __GFP_THIS_NODE in those places which want that behaviour?

And to then make non-NUMA __GFP_THISNODE equal literal zero, so we can
remove the above ifdefs?

>  	flags |= cachep->gfpflags;
>  
>  	page = alloc_pages_node(nodeid, flags, cachep->gfporder);
> @@ -3085,6 +3093,15 @@ static __always_inline void *__cache_all
>  
>  	objp = ____cache_alloc(cachep, flags);
>  out:
> +
> +#ifdef CONFIG_NUMA
> +	/*
> +	 * We may just have run out of memory on the local know.
> +	 * __cache_alloc_node knows how to locate memory on other nodes
> +	 */
> + 	if (!objp)
> + 		objp = __cache_alloc_node(cachep, flags, numa_node_id());
> +#endif

What happened to my `#define NUMA_BUILD 0 or 1' proposal?  If we had that,
the above could be

	if (NUMA_BUILD && !objp)
		objp = ...


>  /*
> + * Fallback function if there was no memory available and no objects on a
> + * certain node and we are allowed to fall back. We mimick the behavior of
> + * the page allocator. We fall back according to a zonelist determined by
> + * the policy layer while obeying cpuset constraints.
> + */
> +void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
> +{
> +	struct zonelist *zonelist = &NODE_DATA(slab_node(current->mempolicy))
> +					->node_zonelists[gfp_zone(flags)];
> +	struct zone **z;
> +	void *obj = NULL;
> +
> +	for (z = zonelist->zones; *z && !obj; z++)
> +		if (zone_idx(*z) <= ZONE_NORMAL &&
> +				cpuset_zone_allowed(*z, flags))
> +			obj = __cache_alloc_node(cache,
> +					flags | __GFP_THISNODE,
> +					zone_to_nid(*z));
> +	return obj;
> +}

hm, there's cpuset_zone_allowed() again.

I have a feeling that we need to nuke that thing: take a 128-node machine,
create a cpuset which has 64 memnodes, consume all the memory in 60 of
them, do some heavy page allocation, then stick a thermometer into
get_page_from_freelist()?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
