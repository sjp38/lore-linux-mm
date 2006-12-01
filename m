Date: Fri, 1 Dec 2006 12:32:05 +0000
Subject: Re: Slab: Better fallback allocation behavior
Message-ID: <20061201123205.GA3528@skynet.ie>
References: <Pine.LNX.4.64.0611291659390.18762@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0611291659390.18762@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On (29/11/06 17:01), Christoph Lameter didst pronounce:
> Currently we simply attempt to allocate from all allowed nodes using 
> GFP_THISNODE.

I thought GFP_THISNODE meant we never fallback to other nodes and no policies
are ever applied.

> However, GFP_THISNODE does not do reclaim (it wont do any at 
> all if the recent GFP_THISNODE patch is accepted). If we truly run out of 
> memory in the whole system then fallback_alloc may return NULL although 
> memory may still be available if we would perform more thorough reclaim.
> 
> This patch changes fallback_alloc() so that we first only inspect all the 
> per node queues for available slabs. If we find any then we allocate from 
> those. This avoids slab fragmentation by first getting rid of all partial 
> allocated slabs on every node before allocating new memory.
> 
> If we cannot satisfy the allocation from any per node queue then we extend 
> a slab. We now call into the page allocator without specifying 
> GFP_THISNODE. The page allocator will then implement its own fallback (in 
> the given cpuset context), perform necessary reclaim (again considering 
> not a single node but the whole set of allowed nodes) and then return 
> pages for a new slab.
> 

So, why have __GFP_THISNODE in slabs at all?

> We identify from which node the pages were allocated and then insert the 
> pages into the corresponding per node structure. In order to do so we need 
> to modify cache_grow() to take a parameter that specifies the new slab. 
> kmem_getpages() can no longer set the GFP_THISNODE flag since we need to 
> be able to use kmem_getpage to allocate from an arbitrary node. 
> GFP_THISNODE needs to be specified when calling cache_grow().
> 

ok.

> One key advantage is that the decision from which node to allocate new 
> memory is removed from slab fallback processing. The patch allows to go 
> back to use of the page allocators fallback/reclaim logic.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.19-rc6-mm2/mm/slab.c
> ===================================================================
> --- linux-2.6.19-rc6-mm2.orig/mm/slab.c	2006-11-29 18:40:15.650296908 -0600
> +++ linux-2.6.19-rc6-mm2/mm/slab.c	2006-11-29 18:40:37.767454017 -0600
> @@ -1610,12 +1610,7 @@ static void *kmem_getpages(struct kmem_c
>  	flags |= __GFP_COMP;
>  #endif
>  
> -	/*
> -	 * Under NUMA we want memory on the indicated node. We will handle
> -	 * the needed fallback ourselves since we want to serve from our
> -	 * per node object lists first for other nodes.
> -	 */
> -	flags |= cachep->gfpflags | GFP_THISNODE;
> +	flags |= cachep->gfpflags;
>  
>  	page = alloc_pages_node(nodeid, flags, cachep->gfporder);
>  	if (!page)
> @@ -2569,7 +2564,7 @@ static struct slab *alloc_slabmgmt(struc
>  	if (OFF_SLAB(cachep)) {
>  		/* Slab management obj is off-slab. */
>  		slabp = kmem_cache_alloc_node(cachep->slabp_cache,
> -					      local_flags, nodeid);
> +					      local_flags & ~GFP_THISNODE, nodeid);

This also removes the __GFP_NOWARN and __GFP_NORETRY flags. Is that intended
or did you mean ~__GFP_THISNODE?

>  		if (!slabp)
>  			return NULL;
>  	} else {
> @@ -2712,10 +2707,10 @@ static void slab_map_pages(struct kmem_c
>   * Grow (by 1) the number of slabs within a cache.  This is called by
>   * kmem_cache_alloc() when there are no active objs left in a cache.
>   */
> -static int cache_grow(struct kmem_cache *cachep, gfp_t flags, int nodeid)
> +static int cache_grow(struct kmem_cache *cachep,
> +		gfp_t flags, int nodeid, void *objp)
>  {
>  	struct slab *slabp;
> -	void *objp;
>  	size_t offset;
>  	gfp_t local_flags;
>  	unsigned long ctor_flags;
> @@ -2767,12 +2762,14 @@ static int cache_grow(struct kmem_cache 
>  	 * Get mem for the objs.  Attempt to allocate a physical page from
>  	 * 'nodeid'.
>  	 */
> -	objp = kmem_getpages(cachep, flags, nodeid);
> +	if (!objp)
> +		objp = kmem_getpages(cachep, flags, nodeid);
>  	if (!objp)
>  		goto failed;
>  
>  	/* Get slab management. */
> -	slabp = alloc_slabmgmt(cachep, objp, offset, local_flags, nodeid);
> +	slabp = alloc_slabmgmt(cachep, objp, offset,
> +			local_flags & ~GFP_THISNODE, nodeid);

Same comment about GFP_THISNODE vs __GFP_THISNODE

>  	if (!slabp)
>  		goto opps1;
>  
> @@ -3010,7 +3007,7 @@ alloc_done:
>  
>  	if (unlikely(!ac->avail)) {
>  		int x;
> -		x = cache_grow(cachep, flags, node);
> +		x = cache_grow(cachep, flags | GFP_THISNODE, node, NULL);
>  

Ok, so we first try and stick to the current node and there is no
fallback, reclaim or policy enforcement. As a side-effect (I think,
slab.c boggles the mind and I'm not as familiar with it as I should be),
callers of kmem_cache_alloc() now imply __GFP_THISNODE | __GFP_NORETRY and
__GFP_NORETRY. Again, just checking, is this intentional?

>  		/* cache_grow can reenable interrupts, then ac could change. */
>  		ac = cpu_cache_get(cachep);
> @@ -3246,9 +3243,11 @@ static void *alternate_node_alloc(struct
>  
>  /*
>   * Fallback function if there was no memory available and no objects on a
> - * certain node and we are allowed to fall back. We mimick the behavior of
> - * the page allocator. We fall back according to a zonelist determined by
> - * the policy layer while obeying cpuset constraints.
> + * certain node and fall back is permitted. First we scan all the
> + * available nodelists for available objects. If that fails then we
> + * perform an allocation without specifying a node. This allows the page
> + * allocator to do its reclaim / fallback magic. We then insert the
> + * slab into the proper nodelist and then allocate from it.
>   */
>  void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
>  {
> @@ -3256,15 +3255,51 @@ void *fallback_alloc(struct kmem_cache *
>  					->node_zonelists[gfp_zone(flags)];
>  	struct zone **z;
>  	void *obj = NULL;
> +	int nid;
>  
> +retry:
> +	/*
> +	 * Look through allowed nodes for objects available
> +	 * from existing per node queues.
> +	 */
>  	for (z = zonelist->zones; *z && !obj; z++) {
> -		int nid = zone_to_nid(*z);
> +		nid = zone_to_nid(*z);
> +
> +		if (cpuset_zone_allowed(*z, flags) &&
> +			cache->nodelists[nid] &&
> +			cache->nodelists[nid]->free_objects)
> +				obj = ____cache_alloc_node(cache,
> +					flags | GFP_THISNODE, nid);
> +	}

Would we not get similar behavior if you just didn't specify
GFP_THISNODE?

Again, GFP_THISNODE vs __GFP_THISNODE, intentional?

>  
> -		if (zone_idx(*z) <= ZONE_NORMAL &&
> -				cpuset_zone_allowed(*z, flags) &&
> -				cache->nodelists[nid])
> -			obj = ____cache_alloc_node(cache,
> -					flags | __GFP_THISNODE, nid);
> +	if (!obj) {
> +		/*
> +		 * This allocation will be performed within the constraints
> +		 * of the current cpuset / memory policy requirements.
> +		 * We may trigger various forms of reclaim on the allowed
> +		 * set and go into memory reserves if necessary.
> +		 */
> +		obj = kmem_getpages(cache, flags, -1);
> +		if (obj) {
> +			/*
> +			 * Insert into the appropriate per node queues
> +			 */
> +			nid = page_to_nid(virt_to_page(obj));
> +			if (cache_grow(cache, flags, nid, obj)) {
> +				obj = ____cache_alloc_node(cache,
> +					flags | GFP_THISNODE, nid);
> +				if (!obj)
> +					/*
> +					 * Another processor may allocate the
> +					 * objects in the slab since we are
> +					 * not holding any locks.
> +					 */
> +					goto retry;
> +			} else {
> +				kmem_freepages(cache, obj);
> +				obj = NULL;
> +			}
> +		}
>  	}
>  	return obj;
>  }
> @@ -3321,7 +3356,7 @@ retry:
>  
>  must_grow:
>  	spin_unlock(&l3->list_lock);
> -	x = cache_grow(cachep, flags, nodeid);
> +	x = cache_grow(cachep, flags | GFP_THISNODE, nodeid, NULL);
>  	if (x)

The obvious callers to ____cache_alloc_node seem to specify GFP_THISNODE
now, when is fallback_alloc called when it looks like

if (!(flags & __GFP_THISNODE))
	/* Unable to grow the cache. Fall back to other
	 * nodes. */
	return fallback_alloc(cachep,
		flags);
					 

>  		goto retry;
>  

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
