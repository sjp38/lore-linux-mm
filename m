Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id B38A96B1918
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 01:38:58 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id w129-v6so16427475oib.18
        for <linux-mm@kvack.org>; Sun, 18 Nov 2018 22:38:58 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d134si9318847oib.261.2018.11.18.22.38.57
        for <linux-mm@kvack.org>;
        Sun, 18 Nov 2018 22:38:57 -0800 (PST)
Subject: Re: [PATCH] mm, page_alloc: fix calculation of pgdat->nr_zones
References: <20181117022022.9956-1-richard.weiyang@gmail.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <fc661a9c-3cde-8e43-a05d-f26817ba6e8e@arm.com>
Date: Mon, 19 Nov 2018 12:08:54 +0530
MIME-Version: 1.0
In-Reply-To: <20181117022022.9956-1-richard.weiyang@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, dave.hansen@intel.com
Cc: linux-mm@kvack.org



On 11/17/2018 07:50 AM, Wei Yang wrote:
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

So pgdat->nr_zones over counts the number of zones than what node has
really got ? Does it affect all online options (online/online_kernel
/online_movable) if there are other higher index zones present on the
node. 

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

Which prevents an over count I guess. Just wondering if you noticed this
causing any real problem or some other side effects.

> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
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

This seems to be correct if we try to init a zone (due to memory hotplug)
in between index 0 and pgdat->nr_zones on an already populated node.
