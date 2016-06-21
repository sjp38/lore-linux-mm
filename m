Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id B361B828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 16:43:57 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id b13so51554198pat.3
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 13:43:57 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id b66si42044824pfg.52.2016.06.21.13.43.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 13:43:56 -0700 (PDT)
Received: by mail-pa0-x232.google.com with SMTP id b13so9540094pat.0
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 13:43:56 -0700 (PDT)
Date: Tue, 21 Jun 2016 13:43:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, compaction: abort free scanner if split fails
In-Reply-To: <5783072b-0341-dccb-8f07-c92230964d83@suse.cz>
Message-ID: <alpine.DEB.2.10.1606211330020.30237@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1606151530590.37360@chino.kir.corp.google.com> <4f5ba93e-8bf0-151e-57eb-cad1a4823b9e@suse.cz> <alpine.DEB.2.10.1606201443350.33055@chino.kir.corp.google.com> <5783072b-0341-dccb-8f07-c92230964d83@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

On Tue, 21 Jun 2016, Vlastimil Babka wrote:

> > diff --git a/mm/compaction.c b/mm/compaction.c
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -494,24 +494,22 @@ static unsigned long isolate_freepages_block(struct
> > compact_control *cc,
> > 
> >  		/* Found a free page, will break it into order-0 pages */
> >  		order = page_order(page);
> > -		isolated = __isolate_free_page(page, page_order(page));
> > +		isolated = __isolate_free_page(page, order);
> > +		if (!isolated)
> > +			break;
> 
> This seems to fix as a side-effect a bug in Joonsoo's mmotm patch
> mm-compaction-split-freepages-without-holding-the-zone-lock.patch, that
> Minchan found: http://marc.info/?l=linux-mm&m=146607176528495&w=2
> 
> So it should be noted somewhere so they are merged together. Or Joonsoo posts
> an isolated fix and this patch has to rebase.
> 

Indeed, I hadn't noticed the differences between Linus's tree and -mm.  
Thanks very much for pointing it out.

My interest is to eventually backport this to a much older kernel where we 
suffer from the same issue: it seems that we have always not terminated 
the freeing scanner when splitting the free page fails and we feel it 
because some of our systems have 128GB zones and migrate_pages() can call 
compaction_alloc() several times if it keeps getting -EAGAIN.  It's very 
expensive.

I'm not sure we should label it as a -fix for
mm-compaction-split-freepages-without-holding-the-zone-lock.patch since 
the problem this patch is addressing has seemingly existed for years.  
Perhaps it would be better to have two patches, one as a -fix and then the 
abort on page split failure on top.  I'll send out a two patch series in 
this form.

> >  		set_page_private(page, order);
> >  		total_isolated += isolated;
> >  		list_add_tail(&page->lru, freelist);
> > 
> > -		/* If a page was split, advance to the end of it */
> > -		if (isolated) {
> > -			cc->nr_freepages += isolated;
> > -			if (!strict &&
> > -				cc->nr_migratepages <= cc->nr_freepages) {
> > -				blockpfn += isolated;
> > -				break;
> > -			}
> > -
> > -			blockpfn += isolated - 1;
> > -			cursor += isolated - 1;
> > -			continue;
> > +		/* Advance to the end of split page */
> > +		cc->nr_freepages += isolated;
> > +		if (!strict && cc->nr_migratepages <= cc->nr_freepages) {
> > +			blockpfn += isolated;
> > +			break;
> >  		}
> > +		blockpfn += isolated - 1;
> > +		cursor += isolated - 1;
> > +		continue;
> > 
> >  isolate_fail:
> >  		if (strict)
> > @@ -521,6 +519,9 @@ isolate_fail:
> > 
> >  	}
> > 
> > +	if (locked)
> > +		spin_unlock_irqrestore(&cc->zone->lock, flags);
> > +
> >  	/*
> >  	 * There is a tiny chance that we have read bogus compound_order(),
> >  	 * so be careful to not go outside of the pageblock.
> > @@ -542,9 +543,6 @@ isolate_fail:
> >  	if (strict && blockpfn < end_pfn)
> >  		total_isolated = 0;
> > 
> > -	if (locked)
> > -		spin_unlock_irqrestore(&cc->zone->lock, flags);
> > -
> >  	/* Update the pageblock-skip if the whole pageblock was scanned */
> >  	if (blockpfn == end_pfn)
> >  		update_pageblock_skip(cc, valid_page, total_isolated, false);
> > @@ -622,7 +620,7 @@ isolate_freepages_range(struct compact_control *cc,
> >  		 */
> >  	}
> > 
> > -	/* split_free_page does not map the pages */
> > +	/* __isolate_free_page() does not map the pages */
> >  	map_pages(&freelist);
> > 
> >  	if (pfn < end_pfn) {
> > @@ -1071,6 +1069,7 @@ static void isolate_freepages(struct compact_control
> > *cc)
> >  				block_end_pfn = block_start_pfn,
> >  				block_start_pfn -= pageblock_nr_pages,
> >  				isolate_start_pfn = block_start_pfn) {
> > +		unsigned long isolated;
> > 
> >  		/*
> >  		 * This can iterate a massively long zone without finding any
> > @@ -1095,8 +1094,12 @@ static void isolate_freepages(struct compact_control
> > *cc)
> >  			continue;
> > 
> >  		/* Found a block suitable for isolating free pages from. */
> > -		isolate_freepages_block(cc, &isolate_start_pfn,
> > -					block_end_pfn, freelist, false);
> > +		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
> > +						block_end_pfn, freelist,
> > false);
> > +		/* If free page split failed, do not continue needlessly */
> 
> More accurately, free page isolation failed?
> 

Eek, maybe.  The condition should only work if we terminated early because 

 - need_resched() or zone->lock contention for MIGRATE_ASYNC, or

 - __isolate_free_page() fails.

And the latter can only fail because of this (somewhat arbitrary) split 
watermark check.  I'll rename it because it includes both, but I thought 
the next immediate condition check for cc->contended and its comment was 
explanatory enough.

> > +		if (!isolated && isolate_start_pfn < block_end_pfn &&
> > +		    cc->nr_freepages <= cc->nr_migratepages)
> > +			break;
> > 
> >  		/*
> >  		 * If we isolated enough freepages, or aborted due to async
> > @@ -1124,7 +1127,7 @@ static void isolate_freepages(struct compact_control
> > *cc)
> >  		}
> >  	}
> > 
> > -	/* split_free_page does not map the pages */
> > +	/* __isolate_free_page() does not map the pages */
> >  	map_pages(freelist);
> > 
> >  	/*
> > @@ -1703,6 +1706,12 @@ enum compact_result try_to_compact_pages(gfp_t
> > gfp_mask, unsigned int order,
> >  			continue;
> >  		}
> > 
> > +		/* Don't attempt compaction if splitting free page will fail
> > */
> > +		if (!zone_watermark_ok(zone, 0,
> > +				       low_wmark_pages(zone) + (1 << order),
> > +				       0, 0))
> > +			continue;
> > +
> 
> Please don't add this, compact_zone already checks this via
> compaction_suitable() (and the usual 2 << order gap), so this is adding yet
> another watermark check with a different kind of gap.
> 

Good point, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
