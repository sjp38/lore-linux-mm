Date: Wed, 8 Aug 2007 10:46:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/3] Use one zonelist that is filtered instead of multiple
 zonelists
In-Reply-To: <20070808161545.32320.41940.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0708081041240.12652@schroedinger.engr.sgi.com>
References: <20070808161504.32320.79576.sendpatchset@skynet.skynet.ie>
 <20070808161545.32320.41940.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee.Schermerhorn@hp.com, pj@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Aug 2007, Mel Gorman wrote:

>  		for (i = 0; i < npmem_ranges; i++) {
> +			zl = &NODE_DATA(i)->node_zonelist;

The above shows up again and again. Maybe add a new inline function?

struct zonelist *zonelist_node(int node)


>  {
> -	return NODE_DATA(0)->node_zonelists + gfp_zone(gfp_flags);
> +	return &NODE_DATA(0)->node_zonelist;

How many callers of gfp_zone are left? Do we still need the function?

Note that the memoryless_node patchset modifies gfp_zone and adds some 
more zonelists (sigh).

> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-005_freepages_zonelist/mm/oom_kill.c linux-2.6.23-rc1-mm2-010_use_zonelist/mm/oom_kill.c
> --- linux-2.6.23-rc1-mm2-005_freepages_zonelist/mm/oom_kill.c	2007-08-07 14:45:11.000000000 +0100
> +++ linux-2.6.23-rc1-mm2-010_use_zonelist/mm/oom_kill.c	2007-08-08 11:35:09.000000000 +0100
> @@ -177,8 +177,10 @@ static inline int constrained_alloc(stru
>  {
>  #ifdef CONFIG_NUMA
>  	struct zone **z;
> +	struct zone *zone;
>  	nodemask_t nodes;
>  	int node;
> +	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
>  
>  	nodes_clear(nodes);
>  	/* node has memory ? */
> @@ -186,9 +188,9 @@ static inline int constrained_alloc(stru
>  		if (NODE_DATA(node)->node_present_pages)
>  			node_set(node, nodes);
>  
> -	for (z = zonelist->zones; *z; z++)
> -		if (cpuset_zone_allowed_softwall(*z, gfp_mask))
> -			node_clear(zone_to_nid(*z), nodes);
> +	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
> +		if (cpuset_zone_allowed_softwall(zone, gfp_mask))
> +			node_clear(zone_to_nid(zone), nodes);
>  		else
>  			return CONSTRAINT_CPUSET;
>  

The above portion has already been changed to no longer use a zonelist by 
the memoryless_node patchset in mm.

> +	zonelist = &NODE_DATA(slab_node(current->mempolicy))->node_zonelist;
> +	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
>  		struct kmem_cache_node *n;
>  
> -		n = get_node(s, zone_to_nid(*z));
> +		n = get_node(s, zone_to_nid(zone));

Encoding the node in the zonelist pointer would help these loops but they 
are fallback lists and not on the critical path.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
