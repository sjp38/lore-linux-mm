Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A5DD16B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 05:08:54 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v77so29712050wmv.5
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 02:08:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e9si8575723wra.100.2017.02.08.02.08.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 02:08:53 -0800 (PST)
Date: Wed, 8 Feb 2017 11:08:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: Fix nodes for reclaim in fast path
Message-ID: <20170208100850.GD5686@dhcp22.suse.cz>
References: <1486532455-29613-1-git-send-email-gwshan@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1486532455-29613-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, akpm@linux-foundation.org, anton@samba.org, mpe@ellerman.id.au, "# v3 . 16+" <stable@vger.kernel.org>

On Wed 08-02-17 16:40:55, Gavin Shan wrote:
> When @node_reclaim_node isn't 0, the page allocator tries to reclaim
> pages if the amount of free memory in the zones are below the low
> watermark. On Power platform, none of NUMA nodes are scanned for page
> reclaim because no nodes match the condition in zone_allows_reclaim().
> On Power platform, RECLAIM_DISTANCE is set to 10 which is the distance
> of Node-A to Node-A. So the preferred node even won't be scanned for
> page reclaim.

This is quite confusing. I can see 56608209d34b ("powerpc/numa: Set a
smaller value for RECLAIM_DISTANCE to enable zone reclaim") which
enforced the zone_reclaim by reducing the RECLAIM_DISTANCE, now you are
building on top of that. Having RECLAIM_DISTANCE == LOCAL_DISTANCE is
really confusing. What are distances of other nodes (in other words what
does numactl --hardware tells)? I am wondering whether we shouldn't
rather revert 56608209d34b as the node_reclaim (these days) is not
enabled by default anymore.

[...]

> Fixes: 5f7a75acdb24 ("mm: page_alloc: do not cache reclaim distances")
> Cc: <stable@vger.kernel.org> # v3.16+
> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>

anyway the patch looks OK as it brings the previous behavior back. Not
that I would be entirely happy about that behavior as it is quite nasty
- e.g. it will trigger direct reclaim from the allocator fast path way
too much and basically skip the kswapd wake up most of the time if there
is anything reclaimable... But this used to be there before as well.

Acked-by: Michal Hocko <mhocko@suse.com>

but I would really like to get rid of the ppc specific RECLAIM_DISTANCE
if possible as well.

> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f3e0c69..1a5f665 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2877,7 +2877,7 @@ bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
>  #ifdef CONFIG_NUMA
>  static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
>  {
> -	return node_distance(zone_to_nid(local_zone), zone_to_nid(zone)) <
> +	return node_distance(zone_to_nid(local_zone), zone_to_nid(zone)) <=
>  				RECLAIM_DISTANCE;
>  }
>  #else	/* CONFIG_NUMA */
> -- 
> 2.7.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
