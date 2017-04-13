Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id BF32F6B03BB
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 15:43:40 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id v145so17368580qka.7
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 12:43:40 -0700 (PDT)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id c33si23613511qtd.246.2017.04.13.12.43.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 12:43:39 -0700 (PDT)
Received: by mail-qk0-x241.google.com with SMTP id k139so9678295qke.2
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 12:43:39 -0700 (PDT)
Subject: Re: [PATCH 1/9] mm: remove return value from
 init_currently_empty_zone
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410110351.12215-2-mhocko@kernel.org>
From: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Message-ID: <4207028e-e91b-6294-d5b7-ae3e65f5e286@gmail.com>
Date: Thu, 13 Apr 2017 15:43:36 -0400
MIME-Version: 1.0
In-Reply-To: <20170410110351.12215-2-mhocko@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>



On 04/10/2017 07:03 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> init_currently_empty_zone doesn't have any error to return yet it is
> still an int and callers try to be defensive and try to handle potential
> error. Remove this nonsense and simplify all callers.
> 
> This patch shouldn't have any visible effect
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

>  include/linux/mmzone.h |  2 +-
>  mm/memory_hotplug.c    | 23 +++++------------------
>  mm/page_alloc.c        |  8 ++------
>  3 files changed, 8 insertions(+), 25 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index ebaccd4e7d8c..0fc121bbf4ff 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -771,7 +771,7 @@ enum memmap_context {
>  	MEMMAP_EARLY,
>  	MEMMAP_HOTPLUG,
>  };
> -extern int init_currently_empty_zone(struct zone *zone, unsigned long start_pfn,
> +extern void init_currently_empty_zone(struct zone *zone, unsigned long start_pfn,
>  				     unsigned long size);
>  
>  extern void lruvec_init(struct lruvec *lruvec);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 257166ebdff0..9ed251811ec3 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -347,27 +347,20 @@ static void fix_zone_id(struct zone *zone, unsigned long start_pfn,
>  		set_page_links(pfn_to_page(pfn), zid, nid, pfn);
>  }
>  
> -/* Can fail with -ENOMEM from allocating a wait table with vmalloc() or
> - * alloc_bootmem_node_nopanic()/memblock_virt_alloc_node_nopanic() */
> -static int __ref ensure_zone_is_initialized(struct zone *zone,
> +static void __ref ensure_zone_is_initialized(struct zone *zone,
>  			unsigned long start_pfn, unsigned long num_pages)
>  {
>  	if (!zone_is_initialized(zone))
> -		return init_currently_empty_zone(zone, start_pfn, num_pages);
> -
> -	return 0;
> +		init_currently_empty_zone(zone, start_pfn, num_pages);
>  }
>  
>  static int __meminit move_pfn_range_left(struct zone *z1, struct zone *z2,
>  		unsigned long start_pfn, unsigned long end_pfn)
>  {
> -	int ret;
>  	unsigned long flags;
>  	unsigned long z1_start_pfn;
>  
> -	ret = ensure_zone_is_initialized(z1, start_pfn, end_pfn - start_pfn);
> -	if (ret)
> -		return ret;
> +	ensure_zone_is_initialized(z1, start_pfn, end_pfn - start_pfn);
>  
>  	pgdat_resize_lock(z1->zone_pgdat, &flags);
>  
> @@ -403,13 +396,10 @@ static int __meminit move_pfn_range_left(struct zone *z1, struct zone *z2,
>  static int __meminit move_pfn_range_right(struct zone *z1, struct zone *z2,
>  		unsigned long start_pfn, unsigned long end_pfn)
>  {
> -	int ret;
>  	unsigned long flags;
>  	unsigned long z2_end_pfn;
>  
> -	ret = ensure_zone_is_initialized(z2, start_pfn, end_pfn - start_pfn);
> -	if (ret)
> -		return ret;
> +	ensure_zone_is_initialized(z2, start_pfn, end_pfn - start_pfn);
>  
>  	pgdat_resize_lock(z1->zone_pgdat, &flags);
>  
> @@ -480,12 +470,9 @@ static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
>  	int nid = pgdat->node_id;
>  	int zone_type;
>  	unsigned long flags, pfn;
> -	int ret;
>  
>  	zone_type = zone - pgdat->node_zones;
> -	ret = ensure_zone_is_initialized(zone, phys_start_pfn, nr_pages);
> -	if (ret)
> -		return ret;
> +	ensure_zone_is_initialized(zone, phys_start_pfn, nr_pages);
>  
>  	pgdat_resize_lock(zone->zone_pgdat, &flags);
>  	grow_zone_span(zone, phys_start_pfn, phys_start_pfn + nr_pages);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9c587000d408..0cacba69ab04 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5517,7 +5517,7 @@ static __meminit void zone_pcp_init(struct zone *zone)
>  					 zone_batchsize(zone));
>  }
>  
> -int __meminit init_currently_empty_zone(struct zone *zone,
> +void __meminit init_currently_empty_zone(struct zone *zone,
>  					unsigned long zone_start_pfn,
>  					unsigned long size)
>  {
> @@ -5535,8 +5535,6 @@ int __meminit init_currently_empty_zone(struct zone *zone,
>  
>  	zone_init_free_lists(zone);
>  	zone->initialized = 1;
> -
> -	return 0;
>  }
>  
>  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> @@ -5999,7 +5997,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  {
>  	enum zone_type j;
>  	int nid = pgdat->node_id;
> -	int ret;
>  
>  	pgdat_resize_init(pgdat);
>  #ifdef CONFIG_NUMA_BALANCING
> @@ -6081,8 +6078,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  
>  		set_pageblock_order();
>  		setup_usemap(pgdat, zone, zone_start_pfn, size);
> -		ret = init_currently_empty_zone(zone, zone_start_pfn, size);
> -		BUG_ON(ret);
> +		init_currently_empty_zone(zone, zone_start_pfn, size);
>  		memmap_init(size, nid, j, zone_start_pfn);
>  	}
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
