Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 98DA36B0038
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 19:02:12 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id hn18so6237583igb.3
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 16:02:12 -0700 (PDT)
Received: from mail-ie0-x22c.google.com (mail-ie0-x22c.google.com [2607:f8b0:4001:c03::22c])
        by mx.google.com with ESMTPS id h1si1499452icz.77.2014.07.29.16.02.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Jul 2014 16:02:11 -0700 (PDT)
Received: by mail-ie0-f172.google.com with SMTP id lx4so404042iec.17
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 16:02:11 -0700 (PDT)
Date: Tue, 29 Jul 2014 16:02:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 05/14] mm, compaction: move pageblock checks up from
 isolate_migratepages_range()
In-Reply-To: <53D7690D.5070307@suse.cz>
Message-ID: <alpine.DEB.2.02.1407291559130.20991@chino.kir.corp.google.com>
References: <1406553101-29326-1-git-send-email-vbabka@suse.cz> <1406553101-29326-6-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1407281709050.8998@chino.kir.corp.google.com> <53D7690D.5070307@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Tue, 29 Jul 2014, Vlastimil Babka wrote:

> > > @@ -601,8 +554,11 @@ isolate_migratepages_range(struct zone *zone, struct
> > > compact_control *cc,
> > >   		 */
> > >   		if (PageTransHuge(page)) {
> > >   			if (!locked)
> > > -				goto next_pageblock;
> > > -			low_pfn += (1 << compound_order(page)) - 1;
> > > +				low_pfn = ALIGN(low_pfn + 1,
> > > +						pageblock_nr_pages) - 1;
> > > +			else
> > > +				low_pfn += (1 << compound_order(page)) - 1;
> > > +
> > 
> > Hmm, any reason not to always advance and align low_pfn to
> > pageblock_nr_pages?  I don't see how pageblock_order > HPAGE_PMD_ORDER
> > would make sense if encountering thp.
> 
> I think PageTransHuge() might be true even for non-THP compound pages which
> might be actually of lower order and we wouldn't want to skip the whole
> pageblock.
> 

Hmm, I'm confused at how that could be true, could you explain what 
memory other than thp can return true for PageTransHuge()?  Are you simply 
referring to possible checks on tail pages where we would need to look at 
PageHead() instead?  If so, I'm not sure how we could possibly encounter 
such a condition within this iteration.

> > > @@ -680,15 +630,61 @@ next_pageblock:
> > >   	return low_pfn;
> > >   }
> > > 
> > > +/**
> > > + * isolate_migratepages_range() - isolate migrate-able pages in a PFN
> > > range
> > > + * @start_pfn: The first PFN to start isolating.
> > > + * @end_pfn:   The one-past-last PFN.
> > 
> > Need to specify @cc?
> 
> OK.
> 
> > > 
> > >   /*
> > > - * Isolate all pages that can be migrated from the block pointed to by
> > > - * the migrate scanner within compact_control.
> > > + * Isolate all pages that can be migrated from the first suitable block,
> > > + * starting at the block pointed to by the migrate scanner pfn within
> > > + * compact_control.
> > >    */
> > >   static isolate_migrate_t isolate_migratepages(struct zone *zone,
> > >   					struct compact_control *cc)
> > >   {
> > >   	unsigned long low_pfn, end_pfn;
> > > +	struct page *page;
> > > +	const isolate_mode_t isolate_mode =
> > > +		(cc->mode == MIGRATE_ASYNC ? ISOLATE_ASYNC_MIGRATE : 0);
> > > 
> > > -	/* Do not scan outside zone boundaries */
> > > -	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
> > > +	/*
> > > +	 * Start at where we last stopped, or beginning of the zone as
> > > +	 * initialized by compact_zone()
> > > +	 */
> > > +	low_pfn = cc->migrate_pfn;
> > > 
> > >   	/* Only scan within a pageblock boundary */
> > >   	end_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages);
> > > 
> > > -	/* Do not cross the free scanner or scan within a memory hole */
> > > -	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
> > > -		cc->migrate_pfn = end_pfn;
> > > -		return ISOLATE_NONE;
> > > -	}
> > > +	/*
> > > +	 * Iterate over whole pageblocks until we find the first suitable.
> > > +	 * Do not cross the free scanner.
> > > +	 */
> > > +	for (; end_pfn <= cc->free_pfn;
> > > +			low_pfn = end_pfn, end_pfn += pageblock_nr_pages) {
> > > +
> > > +		/*
> > > +		 * This can potentially iterate a massively long zone with
> > > +		 * many pageblocks unsuitable, so periodically check if we
> > > +		 * need to schedule, or even abort async compaction.
> > > +		 */
> > > +		if (!(low_pfn % (SWAP_CLUSTER_MAX * pageblock_nr_pages))
> > > +						&& compact_should_abort(cc))
> > > +			break;
> > > +
> > > +		/* Skip whole pageblock in case of a memory hole */
> > > +		if (!pfn_valid(low_pfn))
> > > +			continue;
> > > +
> > > +		page = pfn_to_page(low_pfn);
> > > +
> > > +		/* If isolation recently failed, do not retry */
> > > +		if (!isolation_suitable(cc, page))
> > > +			continue;
> > > +
> > > +		/*
> > > +		 * For async compaction, also only scan in MOVABLE blocks.
> > > +		 * Async compaction is optimistic to see if the minimum amount
> > > +		 * of work satisfies the allocation.
> > > +		 */
> > > +		if (cc->mode == MIGRATE_ASYNC &&
> > > +		    !migrate_async_suitable(get_pageblock_migratetype(page)))
> > > +			continue;
> > > +
> > > +		/* Perform the isolation */
> > > +		low_pfn = isolate_migratepages_block(cc, low_pfn, end_pfn,
> > > +								isolate_mode);
> > 
> > Hmm, why would we want to unconditionally set pageblock_skip if no pages
> > could be isolated from a pageblock when
> > isolate_mode == ISOLATE_ASYNC_MIGRATE?  It seems like it erroneously skip
> > pageblocks for cases when isolate_mode == 0.
> 
> Well pageblock_skip is a single bit and you don't know if the next attempt
> will be async or sync. So now you would maybe skip needlessly if the next
> attempt would be sync. If we changed that, you wouldn't skip if the next
> attempt would be async again. Could be that one way is better than other but
> I'm not sure, and would consider it separately.
> The former patch 15 (quick skip pageblock that won't be fully migrated) could
> perhaps change the balance here.
> 

That's why we have two separate per-zone cached start pfns, though, right?  
The next call to async compaction should start from where the previous 
caller left off so there would be no need to set pageblock skip in that 
case until we have checked all memory.  Or are you considering the case of 
concurrent async compaction?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
