Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 37BD66B0037
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 07:59:24 -0500 (EST)
Received: by mail-ee0-f45.google.com with SMTP id d49so461314eek.4
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 04:59:23 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6si4240350eel.91.2013.12.19.04.59.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 04:59:22 -0800 (PST)
Date: Thu, 19 Dec 2013 13:59:21 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH 0/6] Configurable fair allocation zone policy v3
Message-ID: <20131219125921.GF10855@dhcp22.suse.cz>
References: <1387298904-8824-1-git-send-email-mgorman@suse.de>
 <20131217200210.GG21724@cmpxchg.org>
 <20131218145111.GA27510@dhcp22.suse.cz>
 <20131218151846.GM21724@cmpxchg.org>
 <20131218162050.GB27510@dhcp22.suse.cz>
 <20131218192015.GA20038@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131218192015.GA20038@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 18-12-13 14:20:15, Johannes Weiner wrote:
> On Wed, Dec 18, 2013 at 05:20:50PM +0100, Michal Hocko wrote:
[...]
> > Currently we have a per-process (cpuset in fact) flag but this will
> > change it to all or nothing. Is this really a good step?
> > Btw. I do not mind having PF_SPREAD_PAGE enabled by default.
> 
> I don't want to muck around with cpusets too much, tbh...  but I agree
> that the behavior of PF_SPREAD_PAGE should be the default.  Except it
> should honor zone_reclaim_mode and round-robin nodes that are within
> RECLAIM_DISTANCE of the local one.

Agreed.

> I will have spotty access to internet starting tomorrow night until
> New Year's.  Is there a chance we can maybe revert the NUMA aspects of
> the original patch for now and leave it as a node-local zone fairness
> thing?

Yes, that sounds perfectly reasonable to me.

> The NUMA behavior was so broken on 3.12 that I doubt that
> people have come to rely on the cache fairness on such machines in
> that one release.  So we should be able to release 3.12-stable and
> 3.13 with node-local zone fairness without regressing anybody, and
> then give the NUMA aspect of it another try in 3.14.
> 
> Something like the following should restore NUMA behavior while still
> fixing the kswapd vs. page allocator interaction bug of thrashing on
> the highest zone. 

Yes, it looks good to me. I guess zone_local could have stayed as it
was because it shouldn't be a big deal to fall-back to a different node
if the distance is LOCAL, but taking a conservative approach is not
harmfull.

> PS: zone_local() is in a CONFIG_NUMA block, which
> is why accessing zone->node is safe :-)
> 
> ---
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index dd886fac451a..317ea747d2cd 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1822,7 +1822,7 @@ static void zlc_clear_zones_full(struct zonelist *zonelist)
>  
>  static bool zone_local(struct zone *local_zone, struct zone *zone)
>  {
> -	return node_distance(local_zone->node, zone->node) == LOCAL_DISTANCE;
> +	return local_zone->node == zone->node;
>  }
>  
>  static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
> @@ -1919,18 +1919,17 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
>  		 * page was allocated in should have no effect on the
>  		 * time the page has in memory before being reclaimed.
>  		 *
> -		 * When zone_reclaim_mode is enabled, try to stay in
> -		 * local zones in the fastpath.  If that fails, the
> -		 * slowpath is entered, which will do another pass
> -		 * starting with the local zones, but ultimately fall
> -		 * back to remote zones that do not partake in the
> -		 * fairness round-robin cycle of this zonelist.
> +		 * Try to stay in local zones in the fastpath.  If
> +		 * that fails, the slowpath is entered, which will do
> +		 * another pass starting with the local zones, but
> +		 * ultimately fall back to remote zones that do not
> +		 * partake in the fairness round-robin cycle of this
> +		 * zonelist.
>  		 */
>  		if (alloc_flags & ALLOC_WMARK_LOW) {
>  			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
>  				continue;
> -			if (zone_reclaim_mode &&
> -			    !zone_local(preferred_zone, zone))
> +			if (!zone_local(preferred_zone, zone))
>  				continue;
>  		}
>  		/*
> @@ -2396,7 +2395,7 @@ static void prepare_slowpath(gfp_t gfp_mask, unsigned int order,
>  		 * thrash fairness information for zones that are not
>  		 * actually part of this zonelist's round-robin cycle.
>  		 */
> -		if (zone_reclaim_mode && !zone_local(preferred_zone, zone))
> +		if (!zone_local(preferred_zone, zone))
>  			continue;
>  		mod_zone_page_state(zone, NR_ALLOC_BATCH,
>  				    high_wmark_pages(zone) -
> 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
