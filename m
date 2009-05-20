Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C73A36B0085
	for <linux-mm@kvack.org>; Wed, 20 May 2009 04:08:51 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4K88vKN008342
	for <linux-mm@kvack.org> (envelope-from y-goto@jp.fujitsu.com);
	Wed, 20 May 2009 17:08:57 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DE68945DE65
	for <linux-mm@kvack.org>; Wed, 20 May 2009 17:08:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B2C7545DE5D
	for <linux-mm@kvack.org>; Wed, 20 May 2009 17:08:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 76684E18008
	for <linux-mm@kvack.org>; Wed, 20 May 2009 17:08:56 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 24EC2E38005
	for <linux-mm@kvack.org>; Wed, 20 May 2009 17:08:56 +0900 (JST)
Date: Wed, 20 May 2009 17:08:51 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] reset wmark_min and inactive ratio of zone when hotplug happens
In-Reply-To: <20090520162616.744C.A69D9226@jp.fujitsu.com>
References: <20090520162001.3f3bbe5c.minchan.kim@barrios-desktop> <20090520162616.744C.A69D9226@jp.fujitsu.com>
Message-Id: <20090520170712.6CEE.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > This patch solve two problems.
> > 
> > Whenever memory hotplug sucessfully happens, zone->present_pages
> > have to be changed.
> > 
> > 1) Now, memory hotplug calls setup_per_zone_wmark_min only when
> > online_pages called, not offline_pages.
> > 
> > It breaks balance.
> > 
> > 2) If zone->present_pages is changed, we also have to change
> > zone->inactive_ratio. That's because inactive_ratio depends
> > on zone->present_pages.
> 
> Good catch!
> looks good to me. but I'm not familiar this area. CC to Goto-san.
> 

Thanks. Looks good!

Acked-by: Yasunori Goto <y-goto@jp.fujitsu.com>



> 
> 
> 
> 
> > CC: Mel Gorman <mel@csn.ul.ie>
> > CC: Rik van Riel <riel@redhat.com>
> > CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > CC: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > ---
> >  mm/memory_hotplug.c |    4 ++++
> >  1 files changed, 4 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index 40bf385..1611010 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -423,6 +423,7 @@ int online_pages(unsigned long pfn, unsigned long nr_pages)
> >  	zone->zone_pgdat->node_present_pages += onlined_pages;
> >  
> >  	setup_per_zone_wmark_min();
> > +	calculate_per_zone_inactive_ratio(zone);
> >  	if (onlined_pages) {
> >  		kswapd_run(zone_to_nid(zone));
> >  		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
> > @@ -832,6 +833,9 @@ repeat:
> >  	totalram_pages -= offlined_pages;
> >  	num_physpages -= offlined_pages;
> >  
> > +	setup_per_zone_wmark_min();
> > +	calculate_per_zone_inactive_ratio(zone);
> > +
> >  	vm_total_pages = nr_free_pagecache_pages();
> >  	writeback_set_ratelimit();
> >  
> > -- 
> > 1.5.4.3
> > 
> > 
> > 
> > -- 
> > Kinds Regards
> > Minchan Kim
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
