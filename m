Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D93BC6B026E
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 04:05:32 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id n21-v6so742001plp.9
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 01:05:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a1-v6si721546pld.63.2018.07.26.01.05.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 01:05:31 -0700 (PDT)
Date: Thu, 26 Jul 2018 10:05:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 2/5] mm: access zone->node via zone_to_nid() and
 zone_set_nid()
Message-ID: <20180726080500.GX28386@dhcp22.suse.cz>
References: <20180725220144.11531-1-osalvador@techadventures.net>
 <20180725220144.11531-3-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180725220144.11531-3-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: akpm@linux-foundation.org, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, Oscar Salvador <osalvador@suse.de>

On Thu 26-07-18 00:01:41, osalvador@techadventures.net wrote:
> From: Pavel Tatashin <pasha.tatashin@oracle.com>
> 
> zone->node is configured only when CONFIG_NUMA=y, so it is a good idea to
> have inline functions to access this field in order to avoid ifdef's in
> c files.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Reviewed-by: Oscar Salvador <osalvador@suse.de>

My previous [1] question is not addressed in the changelog but I will
not insist. If there is any reason to resubmit this then please
consider.

Acked-by: Michal Hocko <mhocko@suse.com>

[1] http://lkml.kernel.org/r/20180719134018.GB7193@dhcp22.suse.cz

> ---
>  include/linux/mm.h     |  9 ---------
>  include/linux/mmzone.h | 26 ++++++++++++++++++++------
>  mm/mempolicy.c         |  4 ++--
>  mm/mm_init.c           |  9 ++-------
>  mm/page_alloc.c        | 10 ++++------
>  5 files changed, 28 insertions(+), 30 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 726e71475144..6954ad183159 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -940,15 +940,6 @@ static inline int page_zone_id(struct page *page)
>  	return (page->flags >> ZONEID_PGSHIFT) & ZONEID_MASK;
>  }
>  
> -static inline int zone_to_nid(struct zone *zone)
> -{
> -#ifdef CONFIG_NUMA
> -	return zone->node;
> -#else
> -	return 0;
> -#endif
> -}
> -
>  #ifdef NODE_NOT_IN_PAGE_FLAGS
>  extern int page_to_nid(const struct page *page);
>  #else
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index ae1a034c3e2c..17fdff3bfb41 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -842,6 +842,25 @@ static inline bool populated_zone(struct zone *zone)
>  	return zone->present_pages;
>  }
>  
> +#ifdef CONFIG_NUMA
> +static inline int zone_to_nid(struct zone *zone)
> +{
> +	return zone->node;
> +}
> +
> +static inline void zone_set_nid(struct zone *zone, int nid)
> +{
> +	zone->node = nid;
> +}
> +#else
> +static inline int zone_to_nid(struct zone *zone)
> +{
> +	return 0;
> +}
> +
> +static inline void zone_set_nid(struct zone *zone, int nid) {}
> +#endif
> +
>  extern int movable_zone;
>  
>  #ifdef CONFIG_HIGHMEM
> @@ -957,12 +976,7 @@ static inline int zonelist_zone_idx(struct zoneref *zoneref)
>  
>  static inline int zonelist_node_idx(struct zoneref *zoneref)
>  {
> -#ifdef CONFIG_NUMA
> -	/* zone_to_nid not available in this context */
> -	return zoneref->zone->node;
> -#else
> -	return 0;
> -#endif /* CONFIG_NUMA */
> +	return zone_to_nid(zoneref->zone);
>  }
>  
>  struct zoneref *__next_zones_zonelist(struct zoneref *z,
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index f0fcf70bcec7..8c1c09b3852a 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1784,7 +1784,7 @@ unsigned int mempolicy_slab_node(void)
>  		zonelist = &NODE_DATA(node)->node_zonelists[ZONELIST_FALLBACK];
>  		z = first_zones_zonelist(zonelist, highest_zoneidx,
>  							&policy->v.nodes);
> -		return z->zone ? z->zone->node : node;
> +		return z->zone ? zone_to_nid(z->zone) : node;
>  	}
>  
>  	default:
> @@ -2326,7 +2326,7 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
>  				node_zonelist(numa_node_id(), GFP_HIGHUSER),
>  				gfp_zone(GFP_HIGHUSER),
>  				&pol->v.nodes);
> -		polnid = z->zone->node;
> +		polnid = zone_to_nid(z->zone);
>  		break;
>  
>  	default:
> diff --git a/mm/mm_init.c b/mm/mm_init.c
> index 5b72266b4b03..6838a530789b 100644
> --- a/mm/mm_init.c
> +++ b/mm/mm_init.c
> @@ -53,13 +53,8 @@ void __init mminit_verify_zonelist(void)
>  				zone->name);
>  
>  			/* Iterate the zonelist */
> -			for_each_zone_zonelist(zone, z, zonelist, zoneid) {
> -#ifdef CONFIG_NUMA
> -				pr_cont("%d:%s ", zone->node, zone->name);
> -#else
> -				pr_cont("0:%s ", zone->name);
> -#endif /* CONFIG_NUMA */
> -			}
> +			for_each_zone_zonelist(zone, z, zonelist, zoneid)
> +				pr_cont("%d:%s ", zone_to_nid(zone), zone->name);
>  			pr_cont("\n");
>  		}
>  	}
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8a73305f7c55..10b754fba5fa 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2909,10 +2909,10 @@ static inline void zone_statistics(struct zone *preferred_zone, struct zone *z)
>  	if (!static_branch_likely(&vm_numa_stat_key))
>  		return;
>  
> -	if (z->node != numa_node_id())
> +	if (zone_to_nid(z) != numa_node_id())
>  		local_stat = NUMA_OTHER;
>  
> -	if (z->node == preferred_zone->node)
> +	if (zone_to_nid(z) == zone_to_nid(preferred_zone))
>  		__inc_numa_state(z, NUMA_HIT);
>  	else {
>  		__inc_numa_state(z, NUMA_MISS);
> @@ -5287,7 +5287,7 @@ int local_memory_node(int node)
>  	z = first_zones_zonelist(node_zonelist(node, GFP_KERNEL),
>  				   gfp_zone(GFP_KERNEL),
>  				   NULL);
> -	return z->zone->node;
> +	return zone_to_nid(z->zone);
>  }
>  #endif
>  
> @@ -6311,9 +6311,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  		 * And all highmem pages will be managed by the buddy system.
>  		 */
>  		zone->managed_pages = freesize;
> -#ifdef CONFIG_NUMA
> -		zone->node = nid;
> -#endif
> +		zone_set_nid(zone, nid);
>  		zone->name = zone_names[j];
>  		zone->zone_pgdat = pgdat;
>  		spin_lock_init(&zone->lock);
> -- 
> 2.13.6
> 

-- 
Michal Hocko
SUSE Labs
