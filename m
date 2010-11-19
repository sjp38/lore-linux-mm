Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 645EB6B0089
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 06:08:25 -0500 (EST)
Date: Fri, 19 Nov 2010 11:08:08 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 7/8] mm: compaction: Use the LRU to get a hint on where
	compaction should start
Message-ID: <20101119110808.GD28613@csn.ul.ie>
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie> <1290010969-26721-8-git-send-email-mel@csn.ul.ie> <20101118184659.GD30376@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101118184659.GD30376@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 07:46:59PM +0100, Andrea Arcangeli wrote:
> On Wed, Nov 17, 2010 at 04:22:48PM +0000, Mel Gorman wrote:
> > +	if (!cc->migrate_pfn)
> > +		cc->migrate_pfn = zone->zone_start_pfn;
> 
> wouldn't it remove a branch if the caller always set migrate_pfn?
> 

If try_to_compact_pages() used it, it would migrate old pages and then
later enter direct reclaim where it reclaimed the pages it just
migrated. It was double work. That said, I neglected to check if
migration affects the age of pages. Offhand, I think it does so the
problem wouldn't apply so it was flawed reasoning.

> > +	if (!cc->free_pfn) {
> > +		cc->free_pfn = zone->zone_start_pfn + zone->spanned_pages;
> > +		cc->free_pfn &= ~(pageblock_nr_pages-1);
> > +	}
> 
> Who sets free_pfn to zero? Previously this was always initialized.
> 

Initialised on stack.

> > @@ -523,7 +539,23 @@ unsigned long reclaimcompact_zone_order(struct zone *zone,
> >  	INIT_LIST_HEAD(&cc.freepages);
> >  	INIT_LIST_HEAD(&cc.migratepages);
> >  
> > -	return compact_zone(zone, &cc);
> > +	/* Get a hint on where to start compacting from the LRU */
> > +	anon_page = lru_to_page(&zone->lru[LRU_BASE + LRU_INACTIVE_ANON].list);
> > +	file_page = lru_to_page(&zone->lru[LRU_BASE + LRU_INACTIVE_FILE].list);
> > +	cc.migrate_pfn = min(page_to_pfn(anon_page), page_to_pfn(file_page));
> > +	cc.migrate_pfn = ALIGN(cc.migrate_pfn, pageblock_nr_pages);
> > +	start_migrate_pfn = cc.migrate_pfn;
> > +
> > +	ret = compact_zone(zone, &cc);
> > +
> > +	/* Restart migration from the start of zone if the hint did not work */
> > +	if (!zone_watermark_ok(zone, cc.order, low_wmark_pages(zone), 0, 0)) {
> > +		cc.migrate_pfn = 0;
> > +		cc.abort_migrate_pfn = start_migrate_pfn;
> > +		ret = compact_zone(zone, &cc);
> > +	}
> > +
> 
> I doubt it works ok if the list is empty... Maybe it's safer to
> validate the migrate_pfn against the zone pfn start/end before
> setting it in the migrate_pfn.
> 

You're right, this could be unsafe.

> Interesting this heuristic slowed down the benchmark, it should lead
> to the exact opposite thanks to saving some cpu. So I guess maybe it's
> not worth it. I see it increases the ratio of compaction of a tiny
> bit, but if a tiny bit of better compaction comes at the expenses of
> an increased runtime I don't like it and I'd drop it... It's not
> making enough difference, further we could extend it to check the
> "second" page in the list and so on... so we can just go blind. All it
> matters is that we use a clock algorithm and I guess this screwes it
> and this is why it leads to increased time.
> 

The variation was within the noise but yes, maybe this is not such a great
idea and the figures are not very compelling. I'm going to drop it from the
series.

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
