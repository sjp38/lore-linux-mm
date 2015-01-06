Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 695CC6B00D1
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 10:09:23 -0500 (EST)
Received: by mail-lb0-f177.google.com with SMTP id b6so19011068lbj.22
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 07:09:22 -0800 (PST)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id fa10si121527742wjd.91.2015.01.06.07.09.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 07:09:22 -0800 (PST)
Received: by mail-wi0-f178.google.com with SMTP id em10so5501997wid.17
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 07:09:22 -0800 (PST)
Date: Tue, 6 Jan 2015 16:09:20 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V4 4/4] mm: microoptimize zonelist operations
Message-ID: <20150106150920.GE20860@dhcp22.suse.cz>
References: <1420478263-25207-1-git-send-email-vbabka@suse.cz>
 <1420478263-25207-5-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420478263-25207-5-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon 05-01-15 18:17:43, Vlastimil Babka wrote:
> The function next_zones_zonelist() returns zoneref pointer, as well as zone
> pointer via extra parameter. Since the latter can be trivially obtained by
> dereferencing the former, the overhead of the extra parameter is unjustified.
> 
> This patch thus removes the zone parameter from next_zones_zonelist(). Both
> callers happen to be in the same header file, so it's simple to add the
> zoneref dereference inline. We save some bytes of code size.

Dunno. It makes first_zones_zonelist and next_zones_zonelist look
different which might be a bit confusing. It's not a big deal but
I am not sure it is worth it.

> add/remove: 0/0 grow/shrink: 0/3 up/down: 0/-96 (-96)
> function                                     old     new   delta
> __alloc_pages_nodemask                      2182    2176      -6
> nr_free_zone_pages                           129     115     -14
> get_page_from_freelist                      2652    2576     -76
> 
> add/remove: 0/0 grow/shrink: 1/0 up/down: 10/0 (10)
> function                                     old     new   delta
> try_to_compact_pages                         569     579     +10
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> ---
>  include/linux/mmzone.h | 13 +++++++------
>  mm/mmzone.c            |  4 +---
>  2 files changed, 8 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 2f0856d..a2884ef 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -970,7 +970,6 @@ static inline int zonelist_node_idx(struct zoneref *zoneref)
>   * @z - The cursor used as a starting point for the search
>   * @highest_zoneidx - The zone index of the highest zone to return
>   * @nodes - An optional nodemask to filter the zonelist with
> - * @zone - The first suitable zone found is returned via this parameter
>   *
>   * This function returns the next zone at or below a given zone index that is
>   * within the allowed nodemask using a cursor as the starting point for the
> @@ -980,8 +979,7 @@ static inline int zonelist_node_idx(struct zoneref *zoneref)
>   */
>  struct zoneref *next_zones_zonelist(struct zoneref *z,
>  					enum zone_type highest_zoneidx,
> -					nodemask_t *nodes,
> -					struct zone **zone);
> +					nodemask_t *nodes);
>  
>  /**
>   * first_zones_zonelist - Returns the first zone at or below highest_zoneidx within the allowed nodemask in a zonelist
> @@ -1000,8 +998,10 @@ static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
>  					nodemask_t *nodes,
>  					struct zone **zone)
>  {
> -	return next_zones_zonelist(zonelist->_zonerefs, highest_zoneidx, nodes,
> -								zone);
> +	struct zoneref *z = next_zones_zonelist(zonelist->_zonerefs,
> +							highest_zoneidx, nodes);
> +	*zone = zonelist_zone(z);
> +	return z;
>  }
>  
>  /**
> @@ -1018,7 +1018,8 @@ static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
>  #define for_each_zone_zonelist_nodemask(zone, z, zlist, highidx, nodemask) \
>  	for (z = first_zones_zonelist(zlist, highidx, nodemask, &zone);	\
>  		zone;							\
> -		z = next_zones_zonelist(++z, highidx, nodemask, &zone))	\
> +		z = next_zones_zonelist(++z, highidx, nodemask),	\
> +			zone = zonelist_zone(z))			\
>  
>  /**
>   * for_each_zone_zonelist - helper macro to iterate over valid zones in a zonelist at or below a given zone index
> diff --git a/mm/mmzone.c b/mm/mmzone.c
> index bf34fb8..7d87ebb 100644
> --- a/mm/mmzone.c
> +++ b/mm/mmzone.c
> @@ -54,8 +54,7 @@ static inline int zref_in_nodemask(struct zoneref *zref, nodemask_t *nodes)
>  /* Returns the next zone at or below highest_zoneidx in a zonelist */
>  struct zoneref *next_zones_zonelist(struct zoneref *z,
>  					enum zone_type highest_zoneidx,
> -					nodemask_t *nodes,
> -					struct zone **zone)
> +					nodemask_t *nodes)
>  {
>  	/*
>  	 * Find the next suitable zone to use for the allocation.
> @@ -69,7 +68,6 @@ struct zoneref *next_zones_zonelist(struct zoneref *z,
>  				(z->zone && !zref_in_nodemask(z, nodes)))
>  			z++;
>  
> -	*zone = zonelist_zone(z);
>  	return z;
>  }
>  
> -- 
> 2.1.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
