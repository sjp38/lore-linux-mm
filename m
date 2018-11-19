Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9A6AB6B1A04
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 04:48:36 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c53so6664210edc.9
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 01:48:36 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d6-v6si2429627edo.400.2018.11.19.01.48.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 01:48:35 -0800 (PST)
Date: Mon, 19 Nov 2018 10:48:32 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_alloc: fix calculation of pgdat->nr_zones
Message-ID: <20181119094832.GC22247@dhcp22.suse.cz>
References: <20181117022022.9956-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181117022022.9956-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, dave.hansen@intel.com, linux-mm@kvack.org

On Sat 17-11-18 10:20:22, Wei Yang wrote:
> Function init_currently_empty_zone() will adjust pgdat->nr_zones and set
> it to 'zone_idx(zone) + 1' unconditionally. This is correct in the
> normal case, while not exact in hot-plug situation.
>
> This function is used in two places:
> 
>   * free_area_init_core()
>   * move_pfn_range_to_zone()
> 
> In the first case, we are sure zone index increase monotonically. While
> in the second one, this is under users control.
> 
> One way to reproduce this is:
> ----------------------------
> 
> 1. create a virtual machine with empty node1
> 
>    -m 4G,slots=32,maxmem=32G \
>    -smp 4,maxcpus=8          \
>    -numa node,nodeid=0,mem=4G,cpus=0-3 \
>    -numa node,nodeid=1,mem=0G,cpus=4-7
> 
> 2. hot-add cpu 3-7
> 
>    cpu-add [3-7]
> 
> 2. hot-add memory to nod1
> 
>    object_add memory-backend-ram,id=ram0,size=1G
>    device_add pc-dimm,id=dimm0,memdev=ram0,node=1
> 
> 3. online memory with following order
> 
>    echo online_movable > memory47/state
>    echo online > memory40/state
> 
> After this, node1 will have its nr_zones equals to (ZONE_NORMAL + 1)
> instead of (ZONE_MOVABLE + 1).

Maybe it is just me but the above was quite hard to grasp. So just to
clarify. The underlying problem is that initialization of any existing
empty zone will override the previous node wide setting
(pgdat->nr_zones). The fix is to only update nr_zones when a higher zone
is added.

Fixes: f1dd2cd13c4b ("mm, memory_hotplug: do not associate hotadded memory to zones until online")

I haven't checked the code prior to this rework but I suspect it was
really the above one to change the picture.

> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/page_alloc.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5b7cd20dbaef..2d3c54201255 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5823,8 +5823,10 @@ void __meminit init_currently_empty_zone(struct zone *zone,
>  					unsigned long size)
>  {
>  	struct pglist_data *pgdat = zone->zone_pgdat;
> +	int zone_idx = zone_idx(zone) + 1;
>  
> -	pgdat->nr_zones = zone_idx(zone) + 1;
> +	if (zone_idx > pgdat->nr_zones)
> +		pgdat->nr_zones = zone_idx;
>  
>  	zone->zone_start_pfn = zone_start_pfn;
>  
> -- 
> 2.15.1
> 

-- 
Michal Hocko
SUSE Labs
