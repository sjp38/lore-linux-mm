Date: Fri, 29 Feb 2008 16:49:19 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/6] Have zonelist contains structs with both a zone pointer and zone_idx
In-Reply-To: <20080227214740.6858.3677.sendpatchset@localhost>
References: <20080227214708.6858.53458.sendpatchset@localhost> <20080227214740.6858.3677.sendpatchset@localhost>
Message-Id: <20080229163522.66F3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>, Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, ak@suse.de, clameter@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, rientjes@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Hi

this is nitpick.


> +static inline struct zone *zonelist_zone(struct zoneref *zoneref)
> +{
> +	return zoneref->zone;
> +}

this is zoneref operated function, not zonelist operation.
I like zoneref_zone() :)

> +static inline int zonelist_zone_idx(struct zoneref *zoneref)
> +{
> +	return zoneref->zone_idx;
> +}

ditto


> +static inline int zonelist_node_idx(struct zoneref *zoneref)
> +{
> +#ifdef CONFIG_NUMA
> +	/* zone_to_nid not available in this context */
> +	return zoneref->zone->node;
> +#else
> +	return 0;
> +#endif /* CONFIG_NUMA */
> +}

tritto


> -int try_set_zone_oom(struct zonelist *zonelist)
> +int try_set_zone_oom(struct zonelist *zonelist, gfp_t gfp_mask)
>  {
(snip)
> +	for_each_zone_zonelist(zone, z, zonelist, gfp_zone(gfp_mask)) {

this function is no relation memory allocation and free.
and gfp_mask argument is only used for calculate highest zone.

I think following argument is more descriptive, may be.

	int try_set_zone_oom(struct zonelist *zonelist, 
	                     enum zone_type highest_zone_idx)


> @@ -491,16 +491,15 @@ out:
>   * allocation attempts with zonelists containing them may now recall the OOM
>   * killer, if necessary.
>   */
> -void clear_zonelist_oom(struct zonelist *zonelist)
> +void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_mask)

ditto


Thanks.

- kosaki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
