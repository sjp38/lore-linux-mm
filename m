Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 284696B02F4
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 03:38:59 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z81so32746198wrc.2
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 00:38:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y128si3409085wmg.15.2017.06.28.00.38.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 00:38:57 -0700 (PDT)
Date: Wed, 28 Jun 2017 09:38:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memory_hotplug: adjust zone/node size during
 __offline_pages()
Message-ID: <20170628073854.GA5225@dhcp22.suse.cz>
References: <20170628034531.70940-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170628034531.70940-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 28-06-17 11:45:31, Wei Yang wrote:
> After onlining a memory_block and then offline it, the valid_zones will not
> come back to the original state.
> 
> For example:
> 
>     $cat memory4?/valid_zones
>     Movable Normal
>     Movable Normal
>     Movable Normal
> 
>     $echo online > memory40/state
>     $cat memory4?/valid_zones
>     Movable
>     Movable
>     Movable
> 
>     $echo offline > memory40/state
>     $cat memory4?/valid_zones
>     Movable
>     Movable
>     Movable
> 
> While the expected behavior is back to the original valid_zones.

Yes this is a known restriction currently. Nobody complained so far. I
guess that is because nobody really cares.

> The reason is during __offline_pages(), zone/node related fields are not
> adjusted.
> 
> This patch adjusts zone/node related fields in __offline_pages().

My plan for the next release cycle is to remove the zone restriction
altogether and allow onlining movable inside kernel zones. This would
make this change completely irrelevant. So I would rather not do this
now unless you have a strong usecase for it or an existing usecase broke
 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  mm/memory_hotplug.c | 42 ++++++++++++++++++++++++++++++++++++------
>  1 file changed, 36 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 9b94ca67ab00..823939d57f9b 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -879,8 +879,8 @@ bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_pages,
>  	return online_type == MMOP_ONLINE_KEEP;
>  }
>  
> -static void __meminit resize_zone_range(struct zone *zone, unsigned long start_pfn,
> -		unsigned long nr_pages)
> +static void __meminit upsize_zone_range(struct zone *zone,
> +		unsigned long start_pfn, unsigned long nr_pages)
>  {
>  	unsigned long old_end_pfn = zone_end_pfn(zone);
>  
> @@ -890,8 +890,21 @@ static void __meminit resize_zone_range(struct zone *zone, unsigned long start_p
>  	zone->spanned_pages = max(start_pfn + nr_pages, old_end_pfn) - zone->zone_start_pfn;
>  }
>  
> -static void __meminit resize_pgdat_range(struct pglist_data *pgdat, unsigned long start_pfn,
> -                                     unsigned long nr_pages)
> +static void __meminit downsize_zone_range(struct zone *zone,
> +		unsigned long start_pfn, unsigned long nr_pages)
> +{
> +	unsigned long old_end_pfn = zone_end_pfn(zone);
> +
> +	if (start_pfn == zone->zone_start_pfn
> +		|| old_end_pfn == (start_pfn + nr_pages))
> +		zone->spanned_pages -= nr_pages;
> +
> +	if (start_pfn == zone->zone_start_pfn)
> +		zone->zone_start_pfn += nr_pages;
> +}
> +
> +static void __meminit upsize_pgdat_range(struct pglist_data *pgdat,
> +		unsigned long start_pfn, unsigned long nr_pages)
>  {
>  	unsigned long old_end_pfn = pgdat_end_pfn(pgdat);
>  
> @@ -901,6 +914,19 @@ static void __meminit resize_pgdat_range(struct pglist_data *pgdat, unsigned lon
>  	pgdat->node_spanned_pages = max(start_pfn + nr_pages, old_end_pfn) - pgdat->node_start_pfn;
>  }
>  
> +static void __meminit downsize_pgdat_range(struct pglist_data *pgdat,
> +		unsigned long start_pfn, unsigned long nr_pages)
> +{
> +	unsigned long old_end_pfn = pgdat_end_pfn(pgdat);
> +
> +	if (pgdat->node_start_pfn == start_pfn)
> +		pgdat->node_start_pfn = start_pfn;
> +
> +	if (pgdat->node_start_pfn == start_pfn
> +		|| old_end_pfn == (start_pfn + nr_pages))
> +		pgdat->node_spanned_pages -= nr_pages;
> +}
> +
>  void __ref move_pfn_range_to_zone(struct zone *zone,
>  		unsigned long start_pfn, unsigned long nr_pages)
>  {
> @@ -916,9 +942,9 @@ void __ref move_pfn_range_to_zone(struct zone *zone,
>  	/* TODO Huh pgdat is irqsave while zone is not. It used to be like that before */
>  	pgdat_resize_lock(pgdat, &flags);
>  	zone_span_writelock(zone);
> -	resize_zone_range(zone, start_pfn, nr_pages);
> +	upsize_zone_range(zone, start_pfn, nr_pages);
>  	zone_span_writeunlock(zone);
> -	resize_pgdat_range(pgdat, start_pfn, nr_pages);
> +	upsize_pgdat_range(pgdat, start_pfn, nr_pages);
>  	pgdat_resize_unlock(pgdat, &flags);
>  
>  	/*
> @@ -1809,7 +1835,11 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	zone->present_pages -= offlined_pages;
>  
>  	pgdat_resize_lock(zone->zone_pgdat, &flags);
> +	zone_span_writelock(zone);
> +	downsize_zone_range(zone, start_pfn, nr_pages);
> +	zone_span_writeunlock(zone);
>  	zone->zone_pgdat->node_present_pages -= offlined_pages;
> +	downsize_pgdat_range(zone->zone_pgdat, start_pfn, nr_pages);
>  	pgdat_resize_unlock(zone->zone_pgdat, &flags);
>  
>  	init_per_zone_wmark_min();
> -- 
> 2.11.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
