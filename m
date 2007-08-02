Date: Thu, 2 Aug 2007 13:45:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Apply memory policies to top two highest zones when
 highest zone is ZONE_MOVABLE
In-Reply-To: <20070802172118.GD23133@skynet.ie>
Message-ID: <Pine.LNX.4.64.0708021343420.10244@schroedinger.engr.sgi.com>
References: <20070802172118.GD23133@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: akpm@linux-foundation.org, pj@sgi.com, Lee.Schermerhorn@hp.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2 Aug 2007, Mel Gorman wrote:

> +#ifdef CONFIG_NUMA
> +/*
> + * Only custom zonelists like MPOL_BIND need to be filtered as part of
> + * policies. As described in the comment for struct zonelist_cache, these
> + * zonelists will not have a zlcache so zlcache_ptr will not be set. Use
> + * that to determine if the zonelists needs to be filtered or not.
> + */
> +static inline int alloc_should_filter_zonelist(struct zonelist *zonelist)
> +{
> +	return !zonelist->zlcache_ptr;
> +}

I guess Paul needs to have a look at this one.

Otherwise

Acked-by: Christoph Lameter <clameter@sgi.com>

> @@ -1166,6 +1167,18 @@ zonelist_scan:
>  	z = zonelist->zones;
>  
>  	do {
> +		/*
> +		 * In NUMA, this could be a policy zonelist which contains
> +		 * zones that may not be allowed by the current gfp_mask.
> +		 * Check the zone is allowed by the current flags
> +		 */
> +		if (unlikely(alloc_should_filter_zonelist(zonelist))) {
> +			if (highest_zoneidx == -1)
> +				highest_zoneidx = gfp_zone(gfp_mask);
> +			if (zone_idx(*z) > highest_zoneidx)
> +				continue;
> +		}
> +
>  		if (NUMA_BUILD && zlc_active &&

Hotpath. Sigh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
