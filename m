Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 366446B5731
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 03:17:59 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id z10so2463387edz.15
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 00:17:59 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v27si804580edm.111.2018.11.30.00.17.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 00:17:57 -0800 (PST)
Date: Fri, 30 Nov 2018 09:17:55 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2] mm, show_mem: drop pgdat_resize_lock in show_mem()
Message-ID: <20181130081646.GB6923@dhcp22.suse.cz>
References: <20181128210815.2134-1-richard.weiyang@gmail.com>
 <20181129235532.9328-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181129235532.9328-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, jweiner@fb.com, linux-mm@kvack.org

On Fri 30-11-18 07:55:32, Wei Yang wrote:
> Function show_mem() is used to print system memory status when user
> requires or fail to allocate memory. Generally, this is a best effort
> information so any races with memory hotplug (or very theoretically an
> early initialization) should be tolerable and the worst that could
> happen is to print an imprecise node state.
> 
> Drop the resize lock because this is the only place which might hold the
> lock from the interrupt context and so all other callers might use a
> simple spinlock. Even though this doesn't solve any real issue it makes
> the code easier to follow and tiny more effective.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> 
> ---
> v2:
>    * adjust the changelog to show the reason of this change
>    * remove unused variable flags
> ---
>  lib/show_mem.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/lib/show_mem.c b/lib/show_mem.c
> index 0beaa1d899aa..f4e029e1ddec 100644
> --- a/lib/show_mem.c
> +++ b/lib/show_mem.c
> @@ -18,10 +18,8 @@ void show_mem(unsigned int filter, nodemask_t *nodemask)
>  	show_free_areas(filter, nodemask);
>  
>  	for_each_online_pgdat(pgdat) {
> -		unsigned long flags;
>  		int zoneid;
>  
> -		pgdat_resize_lock(pgdat, &flags);
>  		for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
>  			struct zone *zone = &pgdat->node_zones[zoneid];
>  			if (!populated_zone(zone))
> @@ -33,7 +31,6 @@ void show_mem(unsigned int filter, nodemask_t *nodemask)
>  			if (is_highmem_idx(zoneid))
>  				highmem += zone->present_pages;
>  		}
> -		pgdat_resize_unlock(pgdat, &flags);
>  	}
>  
>  	printk("%lu pages RAM\n", total);
> -- 
> 2.15.1
> 

-- 
Michal Hocko
SUSE Labs
