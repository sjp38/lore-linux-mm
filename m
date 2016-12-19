Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7F52F6B026F
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 02:32:22 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 26so35409715pgy.6
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 23:32:22 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id 63si17419496pgi.211.2016.12.18.23.32.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Dec 2016 23:32:21 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id w68so1586260pgw.3
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 23:32:21 -0800 (PST)
Date: Mon, 19 Dec 2016 16:32:28 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm: simplify node/zone name printing
Message-ID: <20161219073228.GA1339@jagdpanzerIV.localdomain>
References: <20161216123232.26307-1-mhocko@kernel.org>
 <2094d241-f40b-2f21-b90b-059374bcd2c2@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2094d241-f40b-2f21-b90b-059374bcd2c2@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Petr Mladek <pmladek@suse.cz>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

On (12/19/16 08:00), Vlastimil Babka wrote:
[..]
> > @@ -4421,7 +4421,6 @@ void show_free_areas(unsigned int filter)
> >  		printk("lowmem_reserve[]:");
> >  		for (i = 0; i < MAX_NR_ZONES; i++)
> >  			printk(KERN_CONT " %ld", zone->lowmem_reserve[i]);
> > -		printk(KERN_CONT "\n");
> 
> So there's really no functional difference between terminating line
> explicitly with "\n", and doing a followup printk() without KERN_CONT?
> I agree that a KERN_CONT line just to print "\n" is ugly, just want to
> be sure we are really safe without it, considering how KERN_CONT has
> been recently changed etc.

depending on what will follow. if another KERN_CONT printk then
without this explicit '\n' printk may assume that we are still
in cont printing; if something else -- printk should flush.

kernel/printk/printk.c

	/*
	 * If an earlier line was buffered, and we're a continuation
	 * write from the same process, try to add it to the buffer.
	 */
	if (cont.len) {
		if (cont.owner == current && (lflags & LOG_CONT)) {
			if (cont_add(facility, level, lflags, text, text_len))
				return text_len;
		}
		/* Otherwise, make sure it's flushed */
		cont_flush();
	}


as far as I can tell, now for_each_populated_zone() iterations are
split by non-CONT printk() from show_zone_node(), which previously
has been   printk(KERN_CONT "%s: ", zone->name), so pr_cont(\n)
between iterations was important, but now that non-CONT printk()
should do the trick. it's _a bit_ hacky, though.

	-ss

> >  	}
> >  
> >  	for_each_populated_zone(zone) {
> > @@ -4431,8 +4430,7 @@ void show_free_areas(unsigned int filter)
> >  
> >  		if (skip_free_areas_node(filter, zone_to_nid(zone)))
> >  			continue;
> > -		show_node(zone);
> > -		printk(KERN_CONT "%s: ", zone->name);
> > +		show_zone_node(zone);
> >  
> >  		spin_lock_irqsave(&zone->lock, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
