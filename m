Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D76CC6B5AFB
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 19:27:12 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id i55so3644800ede.14
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 16:27:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e44sor4181419ede.13.2018.11.30.16.27.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Nov 2018 16:27:11 -0800 (PST)
Date: Sat, 1 Dec 2018 00:27:09 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v3] mm, hotplug: move init_currently_empty_zone() under
 zone_span_lock protection
Message-ID: <20181201002709.ggybtqza6c7hyqrn@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181122101241.7965-1-richard.weiyang@gmail.com>
 <20181130065847.13714-1-richard.weiyang@gmail.com>
 <dd8f1834-769e-d341-58dc-50a81fe0c0ec@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dd8f1834-769e-d341-58dc-50a81fe0c0ec@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On Fri, Nov 30, 2018 at 10:30:22AM +0100, David Hildenbrand wrote:
>On 30.11.18 07:58, Wei Yang wrote:
>> During online_pages phase, pgdat->nr_zones will be updated in case this
>> zone is empty.
>> 
>> Currently the online_pages phase is protected by the global lock
>> mem_hotplug_begin(), which ensures there is no contention during the
>> update of nr_zones. But this global lock introduces scalability issues.
>> 
>> The patch moves init_currently_empty_zone under both zone_span_writelock
>> and pgdat_resize_lock because both the pgdat state is changed (nr_zones)
>> and the zone's start_pfn. Also this patch changes the documentation
>> of node_size_lock to include the protectioin of nr_zones.
>
>s/protectioin/protection/
>
>> 
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> Acked-by: Michal Hocko <mhocko@suse.com>
>> Reviewed-by: Oscar Salvador <osalvador@suse.de>
>> CC: David Hildenbrand <david@redhat.com>
>> 
>> ---
>> David, I may not catch you exact comment on the code or changelog. If I
>> missed, just let me know.
>
>I guess I would have rewritten it to something like the following
>
>"
>Currently the online_pages phase is protected by two global locks
>(device_device_hotplug_lock and mem_hotplug_lock). Especial the latter
>can result in scalability issues, as it will slow down code relying on
>get_online_mems(). Let's prepare code for not having to rely on
>get_online_mems() but instead some more fine grained locks.

I am not sure why we specify get_online_mems() here. mem_hotplug_lock is
grabed in many places besides this one. In my mind, each place introduce
scalability issue, not only this one.

Or you want to say, the mem_hotplug_lock will introduce scalability
issue in two place:

  * hotplug process itself
  * slab allocation process

The second one is more critical. And this is what we try to address?

>
>During online_pages phase, pgdat->nr_zones will be updated in case the
>zone is empty. Right now mem_hotplug_lock ensures that there is no
>contention during the update of nr_zones.
>
>The patch moves init_currently_empty_zone under both zone_span_writelock
>and pgdat_resize_lock because both the pgdat state is changed (nr_zones)
>and the zone's start_pfn. Also this patch changes the documentation
>of node_size_lock to include the protection of nr_zones.
>"
>
>Does that make sense?
>
>> 
>> ---
>> v3:
>>   * slightly modify the last paragraph of changelog based on Michal's
>>     comment
>> v2:
>>   * commit log changes
>>   * modify the code in move_pfn_range_to_zone() instead of in
>>     init_currently_empty_zone()
>>   * pgdat_resize_lock documentation change
>> ---
>>  include/linux/mmzone.h | 7 ++++---
>>  mm/memory_hotplug.c    | 5 ++---
>>  2 files changed, 6 insertions(+), 6 deletions(-)
>> 
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 3d0c472438d2..37d9c5c3faa6 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -635,9 +635,10 @@ typedef struct pglist_data {
>>  #endif
>>  #if defined(CONFIG_MEMORY_HOTPLUG) || defined(CONFIG_DEFERRED_STRUCT_PAGE_INIT)
>>  	/*
>> -	 * Must be held any time you expect node_start_pfn, node_present_pages
>> -	 * or node_spanned_pages stay constant.  Holding this will also
>> -	 * guarantee that any pfn_valid() stays that way.
>> +	 * Must be held any time you expect node_start_pfn,
>> +	 * node_present_pages, node_spanned_pages or nr_zones stay constant.
>> +	 * Holding this will also guarantee that any pfn_valid() stays that
>> +	 * way.
>>  	 *
>>  	 * pgdat_resize_lock() and pgdat_resize_unlock() are provided to
>>  	 * manipulate node_size_lock without checking for CONFIG_MEMORY_HOTPLUG
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 61972da38d93..f626e7e5f57b 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -742,14 +742,13 @@ void __ref move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
>>  	int nid = pgdat->node_id;
>>  	unsigned long flags;
>>  
>> -	if (zone_is_empty(zone))
>> -		init_currently_empty_zone(zone, start_pfn, nr_pages);
>> -
>>  	clear_zone_contiguous(zone);
>>  
>>  	/* TODO Huh pgdat is irqsave while zone is not. It used to be like that before */
>>  	pgdat_resize_lock(pgdat, &flags);
>>  	zone_span_writelock(zone);
>> +	if (zone_is_empty(zone))
>> +		init_currently_empty_zone(zone, start_pfn, nr_pages);
>>  	resize_zone_range(zone, start_pfn, nr_pages);
>>  	zone_span_writeunlock(zone);
>>  	resize_pgdat_range(pgdat, start_pfn, nr_pages);
>> 
>
>
>-- 
>
>Thanks,
>
>David / dhildenb

-- 
Wei Yang
Help you, Help me
