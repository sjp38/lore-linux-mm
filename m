Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E47BF6B28C0
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 20:52:42 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c53so3900613edc.9
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 17:52:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x1-v6sor1895852ejf.13.2018.11.21.17.52.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 17:52:41 -0800 (PST)
Date: Thu, 22 Nov 2018 01:52:39 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, hotplug: protect nr_zones with pgdat_resize_lock()
Message-ID: <20181122015239.qm5xdoxf4t5jzyld@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181120073141.GY22247@dhcp22.suse.cz>
 <3ba8d8c524d86af52e4c1fddc2d45734@suse.de>
 <20181121025231.ggk7zgq53nmqsqds@master>
 <20181121071549.GG12932@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181121071549.GG12932@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On Wed, Nov 21, 2018 at 08:15:49AM +0100, Michal Hocko wrote:
>On Wed 21-11-18 02:52:31, Wei Yang wrote:
>> On Tue, Nov 20, 2018 at 08:58:11AM +0100, osalvador@suse.de wrote:
>> >> On the other hand I would like to see the global lock to go away because
>> >> it causes scalability issues and I would like to change it to a range
>> >> lock. This would make this race possible.
>> >> 
>> >> That being said this is more of a preparatory work than a fix. One could
>> >> argue that pgdat resize lock is abused here but I am not convinced a
>> >> dedicated lock is much better. We do take this lock already and spanning
>> >> its scope seems reasonable. An update to the documentation is due.
>> >
>> >Would not make more sense to move it within the pgdat lock
>> >in move_pfn_range_to_zone?
>> >The call from free_area_init_core is safe as we are single-thread there.
>> >
>> 
>> Agree. This would be better.
>> 
>> >And if we want to move towards a range locking, I even think it would be more
>> >consistent if we move it within the zone's span lock (which is already
>> >wrapped with a pgdat lock).
>> >
>> 
>> I lost a little here, just want to confirm with you.
>> 
>> Instead of call pgdat_resize_lock() around init_currently_empty_zone()
>> in move_pfn_range_to_zone(), we move init_currently_empty_zone() before
>> resize_zone_range()?
>> 
>> This sounds reasonable.
>
>Btw. resolving the existing TODO would be nice as well, now that you are
>looking that direction...

I took a look at that commit, seems I need some time to understand this
TODO. :-)

>
>diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>index c6c42a7425e5..c75fca900044 100644
>--- a/mm/memory_hotplug.c
>+++ b/mm/memory_hotplug.c
>@@ -743,13 +743,12 @@ void __ref move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
> 	int nid = pgdat->node_id;
> 	unsigned long flags;
> 
>+	/* TODO Huh pgdat is irqsave while zone is not. It used to be like that before */
>+	pgdat_resize_lock(pgdat, &flags);
> 	if (zone_is_empty(zone))
> 		init_currently_empty_zone(zone, start_pfn, nr_pages);
> 
> 	clear_zone_contiguous(zone);
>-
>-	/* TODO Huh pgdat is irqsave while zone is not. It used to be like that before */
>-	pgdat_resize_lock(pgdat, &flags);
> 	zone_span_writelock(zone);

Just want to make sure, Oscar suggests to move the code here to protect
this under zone_span_lock.

If this the correct, I would spin a v2 and try to address the TODO.

> 	resize_zone_range(zone, start_pfn, nr_pages);
> 	zone_span_writeunlock(zone);
>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
