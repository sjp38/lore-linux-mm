Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 878E06B0299
	for <linux-mm@kvack.org>; Sun, 10 Sep 2017 21:12:14 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 11so14034192pge.4
        for <linux-mm@kvack.org>; Sun, 10 Sep 2017 18:12:14 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h13sor3568904plk.126.2017.09.10.18.12.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 10 Sep 2017 18:12:13 -0700 (PDT)
Date: Sun, 10 Sep 2017 18:12:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/2] mm, compaction: persistently skip hugetlbfs
 pageblocks
In-Reply-To: <fa162335-a36d-153a-7b5d-1d9c2d57aebc@suse.cz>
Message-ID: <alpine.DEB.2.10.1709101807380.85650@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1708151638550.106658@chino.kir.corp.google.com> <alpine.DEB.2.10.1708151639130.106658@chino.kir.corp.google.com> <fa162335-a36d-153a-7b5d-1d9c2d57aebc@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 23 Aug 2017, Vlastimil Babka wrote:

> > diff --git a/mm/compaction.c b/mm/compaction.c
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -217,6 +217,20 @@ static void reset_cached_positions(struct zone *zone)
> >  				pageblock_start_pfn(zone_end_pfn(zone) - 1);
> >  }
> >  
> > +/*
> > + * Hugetlbfs pages should consistenly be skipped until updated by the hugetlb
> > + * subsystem.  It is always pointless to compact pages of pageblock_order and
> > + * the free scanner can reconsider when no longer huge.
> > + */
> > +static bool pageblock_skip_persistent(struct page *page, unsigned int order)
> > +{
> > +	if (!PageHuge(page))
> > +		return false;
> > +	if (order != pageblock_order)
> > +		return false;
> > +	return true;
> 
> Why just HugeTLBfs? There's also no point in migrating/finding free
> pages in THPs. Actually, any compound page of pageblock order?
> 

Yes, any page where compound_order(page) == pageblock_order would probably 
benefit from the same treatment.  I haven't encountered such an issue, 
however, so I thought it was best to restrict it only to hugetlb: hugetlb 
memory usually sits in the hugetlb free pool and seldom gets freed under 
normal conditions even when unmapped whereas thp is much more likely to be 
unmapped and split.  I wasn't sure that it was worth the pageblock skip.

> > +}
> > +
> >  /*
> >   * This function is called to clear all cached information on pageblocks that
> >   * should be skipped for page isolation when the migrate and free page scanner
> > @@ -241,6 +255,8 @@ static void __reset_isolation_suitable(struct zone *zone)
> >  			continue;
> >  		if (zone != page_zone(page))
> >  			continue;
> > +		if (pageblock_skip_persistent(page, compound_order(page)))
> > +			continue;
> 
> I like the idea of how persistency is achieved by rechecking in the reset.
> 
> >  
> >  		clear_pageblock_skip(page);
> >  	}
> > @@ -448,13 +464,15 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
> >  		 * and the only danger is skipping too much.
> >  		 */
> >  		if (PageCompound(page)) {
> > -			unsigned int comp_order = compound_order(page);
> > -
> > -			if (likely(comp_order < MAX_ORDER)) {
> > -				blockpfn += (1UL << comp_order) - 1;
> > -				cursor += (1UL << comp_order) - 1;
> > +			const unsigned int order = compound_order(page);
> > +
> > +			if (pageblock_skip_persistent(page, order)) {
> > +				set_pageblock_skip(page);
> > +				blockpfn = end_pfn;
> > +			} else if (likely(order < MAX_ORDER)) {
> > +				blockpfn += (1UL << order) - 1;
> > +				cursor += (1UL << order) - 1;
> >  			}
> 
> Is this new code (and below) really necessary? The existing code should
> already lead to skip bit being set via update_pageblock_skip()?
> 

I wanted to set the persistent pageblock skip regardless of 
cc->ignore_skip_hint without a local change to update_pageblock_skip().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
