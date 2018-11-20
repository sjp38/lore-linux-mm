Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 874F46B1ECF
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 02:31:45 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id w2so291499edc.13
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 23:31:45 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f27-v6si7195239ejh.100.2018.11.19.23.31.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 23:31:43 -0800 (PST)
Date: Tue, 20 Nov 2018 08:31:41 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, hotplug: protect nr_zones with pgdat_resize_lock()
Message-ID: <20181120073141.GY22247@dhcp22.suse.cz>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181120014822.27968-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On Tue 20-11-18 09:48:22, Wei Yang wrote:
> After memory hot-added, users could online pages through sysfs, and this
> could be done in parallel.
> 
> In case two threads online pages in two different empty zones at the
> same time, there would be a contention to update the nr_zones.

No, this shouldn't be the case as I've explained in the original thread.
We use memory hotplug lock over the online phase. So there shouldn't be
any race possible.

On the other hand I would like to see the global lock to go away because
it causes scalability issues and I would like to change it to a range
lock. This would make this race possible.

That being said this is more of a preparatory work than a fix. One could
argue that pgdat resize lock is abused here but I am not convinced a
dedicated lock is much better. We do take this lock already and spanning
its scope seems reasonable. An update to the documentation is due.

> The patch use pgdat_resize_lock() to protect this critical section.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

After the changelog is updated to reflect the above, feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index e13987c2e1c4..525a5344a13b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5796,9 +5796,12 @@ void __meminit init_currently_empty_zone(struct zone *zone,
>  {
>  	struct pglist_data *pgdat = zone->zone_pgdat;
>  	int zone_idx = zone_idx(zone) + 1;
> +	unsigned long flags;
>  
> +	pgdat_resize_lock(pgdat, &flags);
>  	if (zone_idx > pgdat->nr_zones)
>  		pgdat->nr_zones = zone_idx;
> +	pgdat_resize_unlock(pgdat, &flags);
>  
>  	zone->zone_start_pfn = zone_start_pfn;
>  
> -- 
> 2.15.1

-- 
Michal Hocko
SUSE Labs
