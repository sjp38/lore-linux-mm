Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 807E66B0293
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 08:20:40 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id m203so19562899wma.2
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 05:20:40 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id c2si18475128wjm.95.2016.12.19.05.20.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 05:20:39 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id u144so18593950wmu.0
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 05:20:39 -0800 (PST)
Date: Mon, 19 Dec 2016 14:20:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: simplify node/zone name printing
Message-ID: <20161219132036.GB5164@dhcp22.suse.cz>
References: <20161216123232.26307-1-mhocko@kernel.org>
 <2094d241-f40b-2f21-b90b-059374bcd2c2@suse.cz>
 <20161219100549.GL393@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161219100549.GL393@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Mon 19-12-16 11:05:49, Petr Mladek wrote:
> On Mon 2016-12-19 08:00:47, Vlastimil Babka wrote:
> > On 12/16/2016 01:32 PM, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > show_node currently only prints Node id while it is always followed by
> > > printing zone->name. As the node information is conditional to
> > > CONFIG_NUMA we have to be careful to always terminate the previous
> > > continuation line before printing the zone name. This is quite ugly
> > > and easy to mess up. Let's rename show_node to show_zone_node and
> > > make sure that it will always start at a new line. We can drop the ugly
> > > printk(KERN_CONT "\n") from show_free_areas.
> > > 
> > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > 
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 3f2c9e535f7f..5324efa8b9d0 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -4120,10 +4120,12 @@ unsigned long nr_free_pagecache_pages(void)
> > >  	return nr_free_zone_pages(gfp_zone(GFP_HIGHUSER_MOVABLE));
> > >  }
> > >  
> > > -static inline void show_node(struct zone *zone)
> > > +static inline void show_zone_node(struct zone *zone)
> > >  {
> > >  	if (IS_ENABLED(CONFIG_NUMA))
> > > -		printk("Node %d ", zone_to_nid(zone));
> > > +		printk("Node %d %s", zone_to_nid(zone), zone->name);
> > > +	else
> > > +		printk("%s: ", zone->name);
> > >  }
> > >  
> > >  long si_mem_available(void)
> > > @@ -4371,9 +4373,8 @@ void show_free_areas(unsigned int filter)
> > >  		for_each_online_cpu(cpu)
> > >  			free_pcp += per_cpu_ptr(zone->pageset, cpu)->pcp.count;
> > >  
> > > -		show_node(zone);
> > > +		show_zone_node(zone);
> > >  		printk(KERN_CONT
> > > -			"%s"
> 
> The new code will printk "%s: " when called with disabled CONFIG_NUMA.
> Is the added ": " OK?

no, that was not intentional. Will drop it.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
