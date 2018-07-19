Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D60626B0006
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:40:21 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l1-v6so3283272edi.11
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:40:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p41-v6si1124646edc.24.2018.07.19.06.40.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 06:40:20 -0700 (PDT)
Date: Thu, 19 Jul 2018 15:40:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 2/5] mm: access zone->node via zone_to_nid() and
 zone_set_nid()
Message-ID: <20180719134018.GB7193@dhcp22.suse.cz>
References: <20180719132740.32743-1-osalvador@techadventures.net>
 <20180719132740.32743-3-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719132740.32743-3-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, vbabka@suse.cz, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Thu 19-07-18 15:27:37, osalvador@techadventures.net wrote:
> From: Pavel Tatashin <pasha.tatashin@oracle.com>
> 
> zone->node is configured only when CONFIG_NUMA=y, so it is a good idea to
> have inline functions to access this field in order to avoid ifdef's in
> c files.

Is this a manual find & replace or did you use some scripts?

The change makes sense, but I haven't checked that all the places are
replaced properly. If not we can replace them later.

> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Reviewed-by: Oscar Salvador <osalvador@suse.de>

Acked-by: Michal Hocko <mhocko@suse.com>

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
