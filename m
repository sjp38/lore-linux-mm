Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 64FA26B026D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 02:00:50 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id he10so45696044wjc.6
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 23:00:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l203si13664892wmf.46.2016.12.18.23.00.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 18 Dec 2016 23:00:48 -0800 (PST)
Subject: Re: [PATCH] mm: simplify node/zone name printing
References: <20161216123232.26307-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2094d241-f40b-2f21-b90b-059374bcd2c2@suse.cz>
Date: Mon, 19 Dec 2016 08:00:47 +0100
MIME-Version: 1.0
In-Reply-To: <20161216123232.26307-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Petr Mladek <pmladek@suse.cz>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On 12/16/2016 01:32 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> show_node currently only prints Node id while it is always followed by
> printing zone->name. As the node information is conditional to
> CONFIG_NUMA we have to be careful to always terminate the previous
> continuation line before printing the zone name. This is quite ugly
> and easy to mess up. Let's rename show_node to show_zone_node and
> make sure that it will always start at a new line. We can drop the ugly
> printk(KERN_CONT "\n") from show_free_areas.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Just a question below... (CC printk experts)

> ---
> Hi,
> this has been sitting in my tree since oct and I completely forgot about
> it. Does this look like a reasonable clean up to you?

Yeah, even besides the removed line, which my question is about....

>  mm/page_alloc.c | 14 ++++++--------
>  1 file changed, 6 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3f2c9e535f7f..5324efa8b9d0 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4120,10 +4120,12 @@ unsigned long nr_free_pagecache_pages(void)
>  	return nr_free_zone_pages(gfp_zone(GFP_HIGHUSER_MOVABLE));
>  }
>  
> -static inline void show_node(struct zone *zone)
> +static inline void show_zone_node(struct zone *zone)
>  {
>  	if (IS_ENABLED(CONFIG_NUMA))
> -		printk("Node %d ", zone_to_nid(zone));
> +		printk("Node %d %s", zone_to_nid(zone), zone->name);
> +	else
> +		printk("%s: ", zone->name);
>  }
>  
>  long si_mem_available(void)
> @@ -4371,9 +4373,8 @@ void show_free_areas(unsigned int filter)
>  		for_each_online_cpu(cpu)
>  			free_pcp += per_cpu_ptr(zone->pageset, cpu)->pcp.count;
>  
> -		show_node(zone);
> +		show_zone_node(zone);
>  		printk(KERN_CONT
> -			"%s"
>  			" free:%lukB"
>  			" min:%lukB"
>  			" low:%lukB"
> @@ -4396,7 +4397,6 @@ void show_free_areas(unsigned int filter)
>  			" local_pcp:%ukB"
>  			" free_cma:%lukB"
>  			"\n",
> -			zone->name,
>  			K(zone_page_state(zone, NR_FREE_PAGES)),
>  			K(min_wmark_pages(zone)),
>  			K(low_wmark_pages(zone)),
> @@ -4421,7 +4421,6 @@ void show_free_areas(unsigned int filter)
>  		printk("lowmem_reserve[]:");
>  		for (i = 0; i < MAX_NR_ZONES; i++)
>  			printk(KERN_CONT " %ld", zone->lowmem_reserve[i]);
> -		printk(KERN_CONT "\n");

So there's really no functional difference between terminating line
explicitly with "\n", and doing a followup printk() without KERN_CONT?
I agree that a KERN_CONT line just to print "\n" is ugly, just want to
be sure we are really safe without it, considering how KERN_CONT has
been recently changed etc.

>  	}
>  
>  	for_each_populated_zone(zone) {
> @@ -4431,8 +4430,7 @@ void show_free_areas(unsigned int filter)
>  
>  		if (skip_free_areas_node(filter, zone_to_nid(zone)))
>  			continue;
> -		show_node(zone);
> -		printk(KERN_CONT "%s: ", zone->name);
> +		show_zone_node(zone);
>  
>  		spin_lock_irqsave(&zone->lock, flags);
>  		for (order = 0; order < MAX_ORDER; order++) {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
