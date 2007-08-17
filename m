Date: Fri, 17 Aug 2007 14:29:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 5/6] Filter based on a nodemask as well as a gfp_mask
In-Reply-To: <20070817201828.14792.57905.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0708171417510.9635@schroedinger.engr.sgi.com>
References: <20070817201647.14792.2690.sendpatchset@skynet.skynet.ie>
 <20070817201828.14792.57905.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee.Schermerhorn@hp.com, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Aug 2007, Mel Gorman wrote:

> @@ -696,6 +696,16 @@ static inline struct zonelist *node_zone
>  	return &NODE_DATA(nid)->node_zonelist;
>  }
>  
> +static inline int zone_in_nodemask(unsigned long zone_addr,
> +				nodemask_t *nodes)
> +{
> +#ifdef CONFIG_NUMA
> +	return node_isset(zonelist_zone(zone_addr)->node, *nodes);
> +#else
> +	return 1;
> +#endif /* CONFIG_NUMA */
> +}
> +

This is dereferencind the zone in a filtering operation. I wonder if
we could encode the node in the zone_addr as well? x86_64 aligns zones on
page boundaries. So we have 10 bits left after taking 2 for the zone id.

> -int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl)
> +int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
>  {
> -	int i;
> -
> -	for (i = 0; zl->_zones[i]; i++) {
> -		int nid = zone_to_nid(zonelist_zone(zl->_zones[i]));
> +	int nid;
>  
> +	for_each_node_mask(nid, *nodemask)
>  		if (node_isset(nid, current->mems_allowed))
>  			return 1;
> -	}
> +
>  	return 0;

Hmmm... This is equivalent to

nodemask_t temp;

nodes_and(temp, nodemask, current->mems_allowed);
return !nodes_empty(temp);

which avoids the loop over all nodes.

> -	}
> -	if (num == 0) {
> -		kfree(zl);
> -		return ERR_PTR(-EINVAL);
> +	for_each_node_mask(nd, *nodemask) {
> +		struct zone *z = &NODE_DATA(nd)->node_zones[k];
> +		if (z->present_pages > 0)
> +			return 1;

Here you could use an and with the N_HIGH_MEMORY or N_NORMAL_MEMORY 
nodemask.

> @@ -1149,12 +1125,19 @@ unsigned slab_node(struct mempolicy *pol
>  	case MPOL_INTERLEAVE:
>  		return interleave_nodes(policy);
>  
> -	case MPOL_BIND:
> +	case MPOL_BIND: {

No { } needed.

>  		/*
>  		 * Follow bind policy behavior and start allocation at the
>  		 * first node.
>  		 */
> -		return zone_to_nid(zonelist_zone(policy->v.zonelist->_zones[0]));
> +		struct zonelist *zonelist;
> +		unsigned long *z;
> +		enum zone_type highest_zoneidx = gfp_zone(GFP_KERNEL);
> +		zonelist = &NODE_DATA(numa_node_id())->node_zonelist;
> +		z = first_zones_zonelist(zonelist, &policy->v.nodes,
> +							highest_zoneidx);
> +		return zone_to_nid(zonelist_zone(*z));
> +	}
>  
>  	case MPOL_PREFERRED:
>  		if (policy->v.preferred_node >= 0)

> @@ -1330,14 +1314,6 @@ struct mempolicy *__mpol_copy(struct mem
>  	}
>  	*new = *old;
>  	atomic_set(&new->refcnt, 1);
> -	if (new->policy == MPOL_BIND) {
> -		int sz = ksize(old->v.zonelist);
> -		new->v.zonelist = kmemdup(old->v.zonelist, sz, GFP_KERNEL);
> -		if (!new->v.zonelist) {
> -			kmem_cache_free(policy_cache, new);
> -			return ERR_PTR(-ENOMEM);
> -		}
> -	}
>  	return new;

That is a good optimization.

> @@ -1680,32 +1647,6 @@ void mpol_rebind_policy(struct mempolicy
>  						*mpolmask, *newmask);
>  		*mpolmask = *newmask;
>  		break;
> -	case MPOL_BIND: {
> -		nodemask_t nodes;
> -		unsigned long *z;
> -		struct zonelist *zonelist;
> -
> -		nodes_clear(nodes);
> -		for (z = pol->v.zonelist->_zones; *z; z++)
> -			node_set(zone_to_nid(zonelist_zone(*z)), nodes);
> -		nodes_remap(tmp, nodes, *mpolmask, *newmask);
> -		nodes = tmp;
> -
> -		zonelist = bind_zonelist(&nodes);
> -
> -		/* If no mem, then zonelist is NULL and we keep old zonelist.
> -		 * If that old zonelist has no remaining mems_allowed nodes,
> -		 * then zonelist_policy() will "FALL THROUGH" to MPOL_DEFAULT.
> -		 */
> -
> -		if (!IS_ERR(zonelist)) {
> -			/* Good - got mem - substitute new zonelist */
> -			kfree(pol->v.zonelist);
> -			pol->v.zonelist = zonelist;
> -		}
> -		*mpolmask = *newmask;
> -		break;
> -	}

Simply dropped? We still need to recalculate the node_mask depending on 
the new cpuset environment!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
