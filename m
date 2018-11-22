Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7CF036B2BC3
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 10:26:44 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id w185so9556035qka.9
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 07:26:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b82si8566186qkb.56.2018.11.22.07.26.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 07:26:43 -0800 (PST)
Subject: Re: [PATCH v2] mm, hotplug: move init_currently_empty_zone() under
 zone_span_lock protection
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181122101241.7965-1-richard.weiyang@gmail.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <18088694-22c8-b09b-f500-4932b6199004@redhat.com>
Date: Thu, 22 Nov 2018 16:26:40 +0100
MIME-Version: 1.0
In-Reply-To: <20181122101241.7965-1-richard.weiyang@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, osalvador@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org

On 22.11.18 11:12, Wei Yang wrote:
> During online_pages phase, pgdat->nr_zones will be updated in case this
> zone is empty.
> 
> Currently the online_pages phase is protected by the global lock
> mem_hotplug_begin(), which ensures there is no contention during the
> update of nr_zones. But this global lock introduces scalability issues.
> 
> This patch is a preparation for removing the global lock during
> online_pages phase. Also this patch changes the documentation of
> node_size_lock to include the protectioin of nr_zones.

I looked into locking recently, and there is more to it.

Please read:

commit dee6da22efac451d361f5224a60be2796d847b51
Author: David Hildenbrand <david@redhat.com>
Date:   Tue Oct 30 15:10:44 2018 -0700

    memory-hotplug.rst: add some details about locking internals
    
    Let's document the magic a bit, especially why device_hotplug_lock is
    required when adding/removing memory and how it all play together with
    requests to online/offline memory from user space.

Short summary: Onlining/offlining of memory requires the device_hotplug_lock
as of now.

mem_hotplug_begin() is just an internal optimization. (we don't want
 everybody to take the device lock)



> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
> v2:
>   * commit log changes
>   * modify the code in move_pfn_range_to_zone() instead of in
>     init_currently_empty_zone()
>   * documentation change
> 
> ---
>  include/linux/mmzone.h | 7 ++++---
>  mm/memory_hotplug.c    | 5 ++---
>  2 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 68d7b558924b..1bb749bee284 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -636,9 +636,10 @@ typedef struct pglist_data {
>  #endif
>  #if defined(CONFIG_MEMORY_HOTPLUG) || defined(CONFIG_DEFERRED_STRUCT_PAGE_INIT)
>  	/*
> -	 * Must be held any time you expect node_start_pfn, node_present_pages
> -	 * or node_spanned_pages stay constant.  Holding this will also
> -	 * guarantee that any pfn_valid() stays that way.
> +	 * Must be held any time you expect node_start_pfn,
> +	 * node_present_pages, node_spanned_pages or nr_zones stay constant.
> +	 * Holding this will also guarantee that any pfn_valid() stays that
> +	 * way.
>  	 *
>  	 * pgdat_resize_lock() and pgdat_resize_unlock() are provided to
>  	 * manipulate node_size_lock without checking for CONFIG_MEMORY_HOTPLUG
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 61972da38d93..f626e7e5f57b 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -742,14 +742,13 @@ void __ref move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
>  	int nid = pgdat->node_id;
>  	unsigned long flags;
>  
> -	if (zone_is_empty(zone))
> -		init_currently_empty_zone(zone, start_pfn, nr_pages);
> -
>  	clear_zone_contiguous(zone);
>  
>  	/* TODO Huh pgdat is irqsave while zone is not. It used to be like that before */
>  	pgdat_resize_lock(pgdat, &flags);
>  	zone_span_writelock(zone);
> +	if (zone_is_empty(zone))
> +		init_currently_empty_zone(zone, start_pfn, nr_pages);
>  	resize_zone_range(zone, start_pfn, nr_pages);
>  	zone_span_writeunlock(zone);
>  	resize_pgdat_range(pgdat, start_pfn, nr_pages);
> 


-- 

Thanks,

David / dhildenb
