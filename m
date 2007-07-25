Date: Wed, 25 Jul 2007 12:31:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: NUMA policy issues with ZONE_MOVABLE
In-Reply-To: <20070725111646.GA9098@skynet.ie>
Message-ID: <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
 <20070725111646.GA9098@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 25 Jul 2007, Mel Gorman wrote:

> o check_highest_zone will be the highest populated zone that is not ZONE_MOVEABLE
> o bind_zonelist builds a zonelist of all populated zones, not policy_zone and lower
> o The page allocator checks what the highest usable zone is and ignores
>   zones in the zonelist that should not be used

Which is a performance impact that we would rather avoid since we are now 
filtering zonelists on every allocation. But we have other issues as well 
that would be fixed by this approach.

How about changing __alloc_pages to lookup the zonelist on its own based 
on a node parameter and a set of allowed nodes? That may significantly 
clean up the memory policy layer and the cpuset layer. But it will 
increase the effort to scan zonelists on each allocation. A large system 
with 1024 nodes may have more than 1024 zones on each nodelist!

> On the second point here, policy_zone and how it is used is a bit
> mad. Particularly, its behaviour on machines with multiple zones is a
> little unpredictable with cross-platform applications potentially behaving
> different on IA64 than x86_64 for example.  However, a test patch that would
> delete it looked as if it would break NUMAQ if a process was bound to nodes
> 2 and 3 but not 0 for example because slab allocations would fail. Similar,
> it would have consequences on x86_64 with NORMAL and DMA32.

Nope it would not fail. NUMAQ has policy_zone == HIGHMEM and slab 
allocations do not use highmem. Memory policies are not applied to slab 
allocs on NUMAQ. Thus slab allocations will use node 0 even 
if you restrict allocs to node 2 and 3.

> Here is the patch just to handle policies with ZONE_MOVABLE. The highest
> zone still gets treated as it does today but allocations using ZONE_MOVABLE
> will still be policied. It has been boot-tested and a basic compile job run
> on a x86_64 NUMA machine (elm3b6 on test.kernel.org). Is there a
> standard test for regression testing policies?

There is a test in the numactl package by Andi Kleen.

> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> index e147cf5..5bdd656 100644
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -166,7 +166,7 @@ extern enum zone_type policy_zone;
>  
>  static inline void check_highest_zone(enum zone_type k)
>  {
> -	if (k > policy_zone)
> +	if (k > policy_zone && k != ZONE_MOVABLE)
>  		policy_zone = k;
>  }

That actually cleans up stuff...

> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 71b84b4..e798be5 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -149,7 +144,7 @@ static struct zonelist *bind_zonelist(nodemask_t *nodes)
>  	   lower zones etc. Avoid empty zones because the memory allocator
>  	   doesn't like them. If you implement node hot removal you
>  	   have to fix that. */
> -	k = policy_zone;
> +	k = MAX_NR_ZONES - 1;

k = ZONE_MOVABLE?

>  	while (1) {
>  		for_each_node_mask(nd, *nodes) { 
>  			struct zone *z = &NODE_DATA(nd)->node_zones[k];

So bind zonelists now include two zones per node: The origin of 
ZONE_MOVABLE and ZONE_MOVABLE.

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 40954fb..22485d5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1157,6 +1157,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order,
>  	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
>  	int zlc_active = 0;		/* set if using zonelist_cache */
>  	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
> +	enum zone_type highest_zoneidx;
>  
>  zonelist_scan:
>  	/*
> @@ -1165,10 +1166,23 @@ zonelist_scan:
>  	 */
>  	z = zonelist->zones;
>  
> +	/* For memory policies, get the highest allowed zone by the flags */
> +	if (NUMA_BUILD)
> +		highest_zoneidx = gfp_zone(gfp_mask);
> +
>  	do {
>  		if (NUMA_BUILD && zlc_active &&
>  			!zlc_zone_worth_trying(zonelist, z, allowednodes))
>  				continue;
> +
> +		/*
> +		 * In NUMA, this could be a policy zonelist which contains
> +		 * zones that may not be allowed by the current gfp_mask.
> +		 * Check the zone is allowed by the current flags
> +		 */
> +		if (NUMA_BUILD && zone_idx(*z) > highest_zoneidx)
> +			continue;
> +

Skip the zones that are higher?

So for a __GFP_MOVABLE alloc we would scan all zones and for 
policy_zone just the policy zone.

Lee should probably also review this in detail since he has recent 
experience fiddling around with memory policies. Paul has also 
experience in this area.

Maybe this can actually  help to deal with some of the corner cases of 
memory policies (just hope the performance impact is not significant).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
