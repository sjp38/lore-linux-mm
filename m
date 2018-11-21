Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 81AB76B2354
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 21:44:39 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e12so2303520edd.16
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 18:44:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s23-v6sor10513107eju.43.2018.11.20.18.44.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 18:44:37 -0800 (PST)
Date: Wed, 21 Nov 2018 02:44:35 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, hotplug: protect nr_zones with pgdat_resize_lock()
Message-ID: <20181121024435.zbd76wqplc2obpxb@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181120073141.GY22247@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181120073141.GY22247@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On Tue, Nov 20, 2018 at 08:31:41AM +0100, Michal Hocko wrote:
>On Tue 20-11-18 09:48:22, Wei Yang wrote:
>> After memory hot-added, users could online pages through sysfs, and this
>> could be done in parallel.
>> 
>> In case two threads online pages in two different empty zones at the
>> same time, there would be a contention to update the nr_zones.
>
>No, this shouldn't be the case as I've explained in the original thread.
>We use memory hotplug lock over the online phase. So there shouldn't be
>any race possible.

Sorry for misunderstanding your point.

>
>On the other hand I would like to see the global lock to go away because
>it causes scalability issues and I would like to change it to a range
>lock. This would make this race possible.

The global lock you want to remove is mem_hotplug_begin() ?

Hmm... my understanding may not correct. While mem_hotplug_begin() use
percpu lock, which means if there are two threads running on two
different cpus to online pages at the same time, they could get their
own lock?

If this is the case, will we face the race condition here?

>
>That being said this is more of a preparatory work than a fix. One could
>argue that pgdat resize lock is abused here but I am not convinced a
>dedicated lock is much better. We do take this lock already and spanning
>its scope seems reasonable. An update to the documentation is due.

Agree, I will try to update the documentation in next verstion. 

>
>> The patch use pgdat_resize_lock() to protect this critical section.
>> 
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>
>After the changelog is updated to reflect the above, feel free to add
>Acked-by: Michal Hocko <mhocko@suse.com>
>
>> ---
>>  mm/page_alloc.c | 3 +++
>>  1 file changed, 3 insertions(+)
>> 
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index e13987c2e1c4..525a5344a13b 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5796,9 +5796,12 @@ void __meminit init_currently_empty_zone(struct zone *zone,
>>  {
>>  	struct pglist_data *pgdat = zone->zone_pgdat;
>>  	int zone_idx = zone_idx(zone) + 1;
>> +	unsigned long flags;
>>  
>> +	pgdat_resize_lock(pgdat, &flags);
>>  	if (zone_idx > pgdat->nr_zones)
>>  		pgdat->nr_zones = zone_idx;
>> +	pgdat_resize_unlock(pgdat, &flags);
>>  
>>  	zone->zone_start_pfn = zone_start_pfn;
>>  
>> -- 
>> 2.15.1
>
>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
