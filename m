Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D978F6B24CF
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 02:15:51 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id d17-v6so2580215edv.4
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 23:15:51 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g5si2052993edn.354.2018.11.20.23.15.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 23:15:50 -0800 (PST)
Date: Wed, 21 Nov 2018 08:15:49 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, hotplug: protect nr_zones with pgdat_resize_lock()
Message-ID: <20181121071549.GG12932@dhcp22.suse.cz>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181120073141.GY22247@dhcp22.suse.cz>
 <3ba8d8c524d86af52e4c1fddc2d45734@suse.de>
 <20181121025231.ggk7zgq53nmqsqds@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181121025231.ggk7zgq53nmqsqds@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On Wed 21-11-18 02:52:31, Wei Yang wrote:
> On Tue, Nov 20, 2018 at 08:58:11AM +0100, osalvador@suse.de wrote:
> >> On the other hand I would like to see the global lock to go away because
> >> it causes scalability issues and I would like to change it to a range
> >> lock. This would make this race possible.
> >> 
> >> That being said this is more of a preparatory work than a fix. One could
> >> argue that pgdat resize lock is abused here but I am not convinced a
> >> dedicated lock is much better. We do take this lock already and spanning
> >> its scope seems reasonable. An update to the documentation is due.
> >
> >Would not make more sense to move it within the pgdat lock
> >in move_pfn_range_to_zone?
> >The call from free_area_init_core is safe as we are single-thread there.
> >
> 
> Agree. This would be better.
> 
> >And if we want to move towards a range locking, I even think it would be more
> >consistent if we move it within the zone's span lock (which is already
> >wrapped with a pgdat lock).
> >
> 
> I lost a little here, just want to confirm with you.
> 
> Instead of call pgdat_resize_lock() around init_currently_empty_zone()
> in move_pfn_range_to_zone(), we move init_currently_empty_zone() before
> resize_zone_range()?
> 
> This sounds reasonable.

Btw. resolving the existing TODO would be nice as well, now that you are
looking that direction...

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c6c42a7425e5..c75fca900044 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -743,13 +743,12 @@ void __ref move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 	int nid = pgdat->node_id;
 	unsigned long flags;
 
+	/* TODO Huh pgdat is irqsave while zone is not. It used to be like that before */
+	pgdat_resize_lock(pgdat, &flags);
 	if (zone_is_empty(zone))
 		init_currently_empty_zone(zone, start_pfn, nr_pages);
 
 	clear_zone_contiguous(zone);
-
-	/* TODO Huh pgdat is irqsave while zone is not. It used to be like that before */
-	pgdat_resize_lock(pgdat, &flags);
 	zone_span_writelock(zone);
 	resize_zone_range(zone, start_pfn, nr_pages);
 	zone_span_writeunlock(zone);
-- 
Michal Hocko
SUSE Labs
