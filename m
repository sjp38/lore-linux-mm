Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 835A36B0277
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:45:49 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w10-v6so3284352eds.7
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:45:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j34-v6si1397534edb.167.2018.07.19.06.45.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 06:45:48 -0700 (PDT)
Date: Thu, 19 Jul 2018 15:45:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 4/5] mm/page_alloc: Inline function to handle
 CONFIG_DEFERRED_STRUCT_PAGE_INIT
Message-ID: <20180719134546.GD7193@dhcp22.suse.cz>
References: <20180719132740.32743-1-osalvador@techadventures.net>
 <20180719132740.32743-5-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719132740.32743-5-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, vbabka@suse.cz, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Thu 19-07-18 15:27:39, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> Let us move the code between CONFIG_DEFERRED_STRUCT_PAGE_INIT
> to an inline function.

... to remove an ugly ifdef in the code.

Please always mention _why_ in the changelog. I can clearly see what
you've done in the diff.

> Signed-off-by: Oscar Salvador <osalvador@suse.de>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 25 ++++++++++++++++---------
>  1 file changed, 16 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f7a6f4e13f41..d77bc2a7ec2c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6379,6 +6379,21 @@ static void __ref alloc_node_mem_map(struct pglist_data *pgdat)
>  static void __ref alloc_node_mem_map(struct pglist_data *pgdat) { }
>  #endif /* CONFIG_FLAT_NODE_MEM_MAP */
>  
> +#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> +static inline void pgdat_set_deferred_range(pg_data_t *pgdat)
> +{
> +	/*
> +	 * We start only with one section of pages, more pages are added as
> +	 * needed until the rest of deferred pages are initialized.
> +	 */
> +	pgdat->static_init_pgcnt = min_t(unsigned long, PAGES_PER_SECTION,
> +						pgdat->node_spanned_pages);
> +	pgdat->first_deferred_pfn = ULONG_MAX;
> +}
> +#else
> +static inline void pgdat_set_deferred_range(pg_data_t *pgdat) {}
> +#endif
> +
>  void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
>  		unsigned long node_start_pfn, unsigned long *zholes_size)
>  {
> @@ -6404,16 +6419,8 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
>  				  zones_size, zholes_size);
>  
>  	alloc_node_mem_map(pgdat);
> +	pgdat_set_deferred_range(pgdat);
>  
> -#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> -	/*
> -	 * We start only with one section of pages, more pages are added as
> -	 * needed until the rest of deferred pages are initialized.
> -	 */
> -	pgdat->static_init_pgcnt = min_t(unsigned long, PAGES_PER_SECTION,
> -					 pgdat->node_spanned_pages);
> -	pgdat->first_deferred_pfn = ULONG_MAX;
> -#endif
>  	free_area_init_core(pgdat);
>  }
>  
> -- 
> 2.13.6
> 

-- 
Michal Hocko
SUSE Labs
