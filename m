Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 80BC76B026B
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 10:01:04 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f13-v6so7548947pgs.15
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 07:01:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t7-v6si2980660pgp.18.2018.07.30.07.01.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 07:01:03 -0700 (PDT)
Date: Mon, 30 Jul 2018 16:00:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Remove zone_id() and make use of zone_idx() in
 is_dev_zone()
Message-ID: <20180730140059.GU24267@dhcp22.suse.cz>
References: <20180730133718.28683-1-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180730133718.28683-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: akpm@linux-foundation.org, vbabka@suse.cz, sfr@canb.auug.org.au, rientjes@google.com, pasha.tatashin@oracle.com, kemi.wang@intel.com, jia.he@hxt-semitech.com, ptesarik@suse.com, aryabinin@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, Oscar Salvador <osalvador@suse.de>

On Mon 30-07-18 15:37:18, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> is_dev_zone() is using zone_id() to check if the zone is ZONE_DEVICE.
> zone_id() looks pretty much the same as zone_idx(), and while the use of
> zone_idx() is quite spread in the kernel, zone_id() is only being
> used by is_dev_zone().
> 
> This patch removes zone_id() and makes is_dev_zone() use zone_idx()
> to check the zone, so we do not have two things with the same
> functionality around.

Yes this looks like a pointless code duplication. I guess Dan just
wasn't aware of zone_idx() macro.

> Signed-off-by: Oscar Salvador <osalvador@suse.de>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mmzone.h | 31 ++++++++++++-------------------
>  1 file changed, 12 insertions(+), 19 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 83b1d11e90eb..dbe7635c33dd 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -755,25 +755,6 @@ static inline bool pgdat_is_empty(pg_data_t *pgdat)
>  	return !pgdat->node_start_pfn && !pgdat->node_spanned_pages;
>  }
>  
> -static inline int zone_id(const struct zone *zone)
> -{
> -	struct pglist_data *pgdat = zone->zone_pgdat;
> -
> -	return zone - pgdat->node_zones;
> -}
> -
> -#ifdef CONFIG_ZONE_DEVICE
> -static inline bool is_dev_zone(const struct zone *zone)
> -{
> -	return zone_id(zone) == ZONE_DEVICE;
> -}
> -#else
> -static inline bool is_dev_zone(const struct zone *zone)
> -{
> -	return false;
> -}
> -#endif
> -
>  #include <linux/memory_hotplug.h>
>  
>  void build_all_zonelists(pg_data_t *pgdat);
> @@ -824,6 +805,18 @@ static inline int local_memory_node(int node_id) { return node_id; };
>   */
>  #define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
>  
> +#ifdef CONFIG_ZONE_DEVICE
> +static inline bool is_dev_zone(const struct zone *zone)
> +{
> +	return zone_idx(zone) == ZONE_DEVICE;
> +}
> +#else
> +static inline bool is_dev_zone(const struct zone *zone)
> +{
> +	return false;
> +}
> +#endif
> +
>  /*
>   * Returns true if a zone has pages managed by the buddy allocator.
>   * All the reclaim decisions have to use this function rather than
> -- 
> 2.13.6
> 

-- 
Michal Hocko
SUSE Labs
