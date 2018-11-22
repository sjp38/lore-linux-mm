Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AACEB6B2A87
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 03:40:00 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id b7so4200969eda.10
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 00:40:00 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z24-v6si311158ejo.213.2018.11.22.00.39.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 00:39:59 -0800 (PST)
Date: Thu, 22 Nov 2018 09:39:57 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, hotplug: protect nr_zones with pgdat_resize_lock()
Message-ID: <20181122083957.GC18011@dhcp22.suse.cz>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181120073141.GY22247@dhcp22.suse.cz>
 <3ba8d8c524d86af52e4c1fddc2d45734@suse.de>
 <20181121025231.ggk7zgq53nmqsqds@master>
 <20181121071549.GG12932@dhcp22.suse.cz>
 <20181122015239.qm5xdoxf4t5jzyld@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181122015239.qm5xdoxf4t5jzyld@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu 22-11-18 01:52:39, Wei Yang wrote:
> On Wed, Nov 21, 2018 at 08:15:49AM +0100, Michal Hocko wrote:
[...]
> >diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> >index c6c42a7425e5..c75fca900044 100644
> >--- a/mm/memory_hotplug.c
> >+++ b/mm/memory_hotplug.c
> >@@ -743,13 +743,12 @@ void __ref move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
> > 	int nid = pgdat->node_id;
> > 	unsigned long flags;
> > 
> >+	/* TODO Huh pgdat is irqsave while zone is not. It used to be like that before */
> >+	pgdat_resize_lock(pgdat, &flags);
> > 	if (zone_is_empty(zone))
> > 		init_currently_empty_zone(zone, start_pfn, nr_pages);
> > 
> > 	clear_zone_contiguous(zone);
> >-
> >-	/* TODO Huh pgdat is irqsave while zone is not. It used to be like that before */
> >-	pgdat_resize_lock(pgdat, &flags);
> > 	zone_span_writelock(zone);
> 
> Just want to make sure, Oscar suggests to move the code here to protect
> this under zone_span_lock.

Yes, both locks held is probably safer. Because there is both pgdat and
zone state updated.

Sorry to confuse you

-- 
Michal Hocko
SUSE Labs
