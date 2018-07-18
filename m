Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0289C6B0270
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 09:37:20 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g11-v6so1873029edi.8
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 06:37:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t11-v6si3641028edt.159.2018.07.18.06.37.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 06:37:18 -0700 (PDT)
Date: Wed, 18 Jul 2018 15:37:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm/page_alloc: Move ifdefery out of
 free_area_init_core
Message-ID: <20180718133717.GE7193@dhcp22.suse.cz>
References: <20180718124722.9872-1-osalvador@techadventures.net>
 <20180718124722.9872-2-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180718124722.9872-2-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, aaron.lu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Wed 18-07-18 14:47:20, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> Moving the #ifdefs out of the function makes it easier to follow.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>

OK, this makes some sense.
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 50 +++++++++++++++++++++++++++++++++++++-------------
>  1 file changed, 37 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index e357189cd24a..8a73305f7c55 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6206,6 +6206,37 @@ static unsigned long __paginginit calc_memmap_size(unsigned long spanned_pages,
>  	return PAGE_ALIGN(pages * sizeof(struct page)) >> PAGE_SHIFT;
>  }
>  
> +#ifdef CONFIG_NUMA_BALANCING
> +static void pgdat_init_numabalancing(struct pglist_data *pgdat)
> +{
> +	spin_lock_init(&pgdat->numabalancing_migrate_lock);
> +	pgdat->numabalancing_migrate_nr_pages = 0;
> +	pgdat->numabalancing_migrate_next_window = jiffies;
> +}
> +#else
> +static void pgdat_init_numabalancing(struct pglist_data *pgdat) {}
> +#endif
> +
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static void pgdat_init_split_queue(struct pglist_data *pgdat)
> +{
> +	spin_lock_init(&pgdat->split_queue_lock);
> +	INIT_LIST_HEAD(&pgdat->split_queue);
> +	pgdat->split_queue_len = 0;
> +}
> +#else
> +static void pgdat_init_split_queue(struct pglist_data *pgdat) {}
> +#endif
> +
> +#ifdef CONFIG_COMPACTION
> +static void pgdat_init_kcompactd(struct pglist_data *pgdat)
> +{
> +	init_waitqueue_head(&pgdat->kcompactd_wait);
> +}
> +#else
> +static void pgdat_init_kcompactd(struct pglist_data *pgdat) {}
> +#endif
> +
>  /*
>   * Set up the zone data structures:
>   *   - mark all pages reserved
> @@ -6220,21 +6251,14 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  	int nid = pgdat->node_id;
>  
>  	pgdat_resize_init(pgdat);
> -#ifdef CONFIG_NUMA_BALANCING
> -	spin_lock_init(&pgdat->numabalancing_migrate_lock);
> -	pgdat->numabalancing_migrate_nr_pages = 0;
> -	pgdat->numabalancing_migrate_next_window = jiffies;
> -#endif
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -	spin_lock_init(&pgdat->split_queue_lock);
> -	INIT_LIST_HEAD(&pgdat->split_queue);
> -	pgdat->split_queue_len = 0;
> -#endif
> +
> +	pgdat_init_numabalancing(pgdat);
> +	pgdat_init_split_queue(pgdat);
> +	pgdat_init_kcompactd(pgdat);
> +
>  	init_waitqueue_head(&pgdat->kswapd_wait);
>  	init_waitqueue_head(&pgdat->pfmemalloc_wait);
> -#ifdef CONFIG_COMPACTION
> -	init_waitqueue_head(&pgdat->kcompactd_wait);
> -#endif
> +
>  	pgdat_page_ext_init(pgdat);
>  	spin_lock_init(&pgdat->lru_lock);
>  	lruvec_init(node_lruvec(pgdat));
> -- 
> 2.13.6
> 

-- 
Michal Hocko
SUSE Labs
