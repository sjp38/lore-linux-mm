Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9DB6B007E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 13:48:12 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 143so20822281pfx.0
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 10:48:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id jh2si12622224pac.149.2016.06.10.10.48.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jun 2016 10:48:11 -0700 (PDT)
Date: Fri, 10 Jun 2016 19:48:00 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 02/27] mm, vmscan: Move lru_lock to the node
Message-ID: <20160610174800.GU30909@twins.programming.kicks-ass.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-3-git-send-email-mgorman@techsingularity.net>
 <575AED3E.3090705@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <575AED3E.3090705@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 10, 2016 at 06:39:26PM +0200, Vlastimil Babka wrote:
> On 06/09/2016 08:04 PM, Mel Gorman wrote:
> > Node-based reclaim requires node-based LRUs and locking. This is a
> > preparation patch that just moves the lru_lock to the node so later patches
> > are easier to review. It is a mechanical change but note this patch makes
> > contention worse because the LRU lock is hotter and direct reclaim and kswapd
> > can contend on the same lock even when reclaiming from different zones.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> One thing...
> 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 9d71af25acf9..1e0ad06c33bd 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -5944,10 +5944,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
> >  		zone->min_slab_pages = (freesize * sysctl_min_slab_ratio) / 100;
> >  #endif
> >  		zone->name = zone_names[j];
> > +		zone->zone_pgdat = pgdat;
> >  		spin_lock_init(&zone->lock);
> > -		spin_lock_init(&zone->lru_lock);
> > +		spin_lock_init(zone_lru_lock(zone));
> 
> This means the same lock will be inited MAX_NR_ZONES times. Peterz told
> me it's valid but weird. Probably better to do it just once, in case
> lockdep/lock debugging gains some checks for that?

Ah, I thought you meant using spin_lock_init() after the lock has
already been used. This is fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
