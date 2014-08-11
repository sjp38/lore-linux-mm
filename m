Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id E59796B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 08:17:51 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id w10so10710131pde.32
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 05:17:51 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id fm8si13327097pab.78.2014.08.11.05.17.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Aug 2014 05:17:51 -0700 (PDT)
Date: Mon, 11 Aug 2014 16:17:39 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm] slab: fix cpuset check in fallback_alloc
Message-ID: <20140811121739.GB18709@esperanza>
References: <1407692891-24312-1-git-send-email-vdavydov@parallels.com>
 <alpine.DEB.2.02.1408101512500.706@chino.kir.corp.google.com>
 <20140811071315.GA18709@esperanza>
 <alpine.DEB.2.02.1408110433140.15519@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1408110433140.15519@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, Aug 11, 2014 at 04:37:15AM -0700, David Rientjes wrote:
> On Mon, 11 Aug 2014, Vladimir Davydov wrote:
> 
> > > diff --git a/mm/slab.c b/mm/slab.c
> > > --- a/mm/slab.c
> > > +++ b/mm/slab.c
> > > @@ -3047,16 +3047,19 @@ retry:
> > >  	 * from existing per node queues.
> > >  	 */
> > >  	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
> > > -		nid = zone_to_nid(zone);
> > > +		struct kmem_cache_node *n;
> > >  
> > > -		if (cpuset_zone_allowed_hardwall(zone, flags) &&
> > > -			get_node(cache, nid) &&
> > > -			get_node(cache, nid)->free_objects) {
> > > -				obj = ____cache_alloc_node(cache,
> > > -					flags | GFP_THISNODE, nid);
> > > -				if (obj)
> > > -					break;
> > > -		}
> > > +		nid = zone_to_nid(zone);
> > > +		if (!cpuset_zone_allowed(zone, flags | __GFP_HARDWALL))
> > 
> > We must use softwall check here, otherwise we will proceed to
> > alloc_pages even if there are lots of free slabs on other nodes.
> > alloc_pages, in turn, may allocate from other nodes in case
> > cpuset.mem_hardwall=0, because it uses softwall check, so it may add yet
> > another free slab to another node's list even if it isn't empty. As a
> > result, we may get free list bloating on other nodes. I've seen a
> > machine with one of its nodes almost completely filled with inactive
> > slabs for buffer_heads (dozens of GBs) w/o any chance to drop them. So,
> > this is a bug that must be fixed.
> > 
> 
> Right, I understand, and my patch makes no attempt to fix that issue, it's 
> simply collapsing the code down into a single cpuset_zone_allowed() 
> function and the context for the allocation is controlled by the gfp 
> flags (and hardwall is controlled by setting __GFP_HARDWALL) as it should 
> be.  I understand the issue you face, but I can't combine a cleanup with a 
> fix and I would prefer to have your patch keep your commit description.  

Sorry, I misunderstood you.

> The diffstat for my proposal removes many more lines than it adds and I 
> think it will avoid this type of issue in the future for new callers.  
> Your patch could then be based on the single cpuset_zone_allowed() 
> function where you would simply have to remove the __GFP_HARDWALL above.  
> Or, your patch could be merged first and then my cleanup on top, but it 
> seems like your one-liner would be more clear if it is based on mine.

Having one function instead of two doing similar thing is usually better
IMO, but AFAIU your patch isn't a mere cleanup - it also slightly
changes the logic behind !__GFP_WAIT vs cpusets interaction:

> @@ -2505,18 +2501,22 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
>   *	GFP_USER     - only nodes in current tasks mems allowed ok.
>   *
>   * Rule:
> - *    Don't call cpuset_node_allowed_softwall if you can't sleep, unless you
> + *    Don't call __cpuset_node_allowed if you can't sleep, unless you
>   *    pass in the __GFP_HARDWALL flag set in gfp_flag, which disables
>   *    the code that might scan up ancestor cpusets and sleep.
>   */
> -int __cpuset_node_allowed_softwall(int node, gfp_t gfp_mask)
> +int __cpuset_node_allowed(int node, const gfp_t gfp_mask)
>  {
>  	struct cpuset *cs;		/* current cpuset ancestors */
>  	int allowed;			/* is allocation in zone z allowed? */
>  
> -	if (in_interrupt() || (gfp_mask & __GFP_THISNODE))
> +	if (in_interrupt())
>  		return 1;
>  	might_sleep_if(!(gfp_mask & __GFP_HARDWALL));
> +	if (gfp_mask & __GFP_THISNODE)
> +		return 1;
> +	if (!(gfp_mask & __GFP_WAIT))
> +		return 1;

This means cpuset_zone_allowed will now always return true for
!__GFP_WAIT allocations.

>  	if (node_isset(node, current->mems_allowed))
>  		return 1;
>  	/*
[...]
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1963,7 +1963,7 @@ zonelist_scan:
>  
>  	/*
>  	 * Scan zonelist, looking for a zone with enough free.
> -	 * See also __cpuset_node_allowed_softwall() comment in kernel/cpuset.c.
> +	 * See __cpuset_node_allowed() comment in kernel/cpuset.c.
>  	 */
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
>  						high_zoneidx, nodemask) {
> @@ -1974,7 +1974,7 @@ zonelist_scan:
>  				continue;
>  		if (cpusets_enabled() &&
>  			(alloc_flags & ALLOC_CPUSET) &&
> -			!cpuset_zone_allowed_softwall(zone, gfp_mask))
> +			!cpuset_zone_allowed(zone, gfp_mask))
>  				continue;

So, this is get_page_from_freelist. It's called from
__alloc_pages_nodemask with alloc_flags always having ALLOC_CPUSET bit
set and from __alloc_pages_slowpath with alloc_flags having ALLOC_CPUSET
bit set only for __GFP_WAIT allocations. That said, w/o your patch we
try to respect cpusets for all allocations, including atomic, and only
ignore cpusets if tight on memory (freelist's empty) for !__GFP_WAIT
allocations, while with your patch we always ignore cpusets for
!__GFP_WAIT allocations. Not sure if it really matters though, because
usually one uses cpuset.mems in conjunction with cpuset.cpus and it
won't make any difference then. It also doesn't conflict with any cpuset
documentation.

>  		/*
>  		 * Distribute pages in proportion to the individual

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
