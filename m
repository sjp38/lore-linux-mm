Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5E04D6B02F5
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 17:11:24 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y77so11236023pfd.2
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 14:11:24 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d63sor5593189pld.1.2017.09.11.14.11.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Sep 2017 14:11:23 -0700 (PDT)
Date: Mon, 11 Sep 2017 14:11:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/2] mm, compaction: persistently skip hugetlbfs
 pageblocks
In-Reply-To: <41aa727a-7f34-3363-dc5b-a33c161c8933@suse.cz>
Message-ID: <alpine.DEB.2.10.1709111406380.108216@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1708151638550.106658@chino.kir.corp.google.com> <alpine.DEB.2.10.1708151639130.106658@chino.kir.corp.google.com> <fa162335-a36d-153a-7b5d-1d9c2d57aebc@suse.cz> <alpine.DEB.2.10.1709101807380.85650@chino.kir.corp.google.com>
 <41aa727a-7f34-3363-dc5b-a33c161c8933@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 11 Sep 2017, Vlastimil Babka wrote:

> > Yes, any page where compound_order(page) == pageblock_order would probably 
> > benefit from the same treatment.  I haven't encountered such an issue, 
> > however, so I thought it was best to restrict it only to hugetlb: hugetlb 
> > memory usually sits in the hugetlb free pool and seldom gets freed under 
> > normal conditions even when unmapped whereas thp is much more likely to be 
> > unmapped and split.  I wasn't sure that it was worth the pageblock skip.
> 
> Well, my thinking is that once we start checking page properties when
> resetting the skip bits, we might as well try to get the most of it, as
> there's no additional cost.
> 

There's no additional cost, but I have doubts of how persistent the 
conditions you're checking really are.  I know that hugetlb memory 
normally sits in a hugetlb free pool when unmapped by a user process, very 
different from thp memory that can always be unmapped and split.  I would 
consider PageHuge() to be inferred as a more persistent condition than thp 
memory.

> >>> @@ -241,6 +255,8 @@ static void __reset_isolation_suitable(struct zone *zone)
> >>>  			continue;
> >>>  		if (zone != page_zone(page))
> >>>  			continue;
> >>> +		if (pageblock_skip_persistent(page, compound_order(page)))
> >>> +			continue;
> >>
> >> I like the idea of how persistency is achieved by rechecking in the reset.
> >>
> >>>  
> >>>  		clear_pageblock_skip(page);
> >>>  	}
> >>> @@ -448,13 +464,15 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
> >>>  		 * and the only danger is skipping too much.
> >>>  		 */
> >>>  		if (PageCompound(page)) {
> >>> -			unsigned int comp_order = compound_order(page);
> >>> -
> >>> -			if (likely(comp_order < MAX_ORDER)) {
> >>> -				blockpfn += (1UL << comp_order) - 1;
> >>> -				cursor += (1UL << comp_order) - 1;
> >>> +			const unsigned int order = compound_order(page);
> >>> +
> >>> +			if (pageblock_skip_persistent(page, order)) {
> >>> +				set_pageblock_skip(page);
> >>> +				blockpfn = end_pfn;
> >>> +			} else if (likely(order < MAX_ORDER)) {
> >>> +				blockpfn += (1UL << order) - 1;
> >>> +				cursor += (1UL << order) - 1;
> >>>  			}
> >>
> >> Is this new code (and below) really necessary? The existing code should
> >> already lead to skip bit being set via update_pageblock_skip()?
> >>
> > 
> > I wanted to set the persistent pageblock skip regardless of 
> > cc->ignore_skip_hint without a local change to update_pageblock_skip().
> 
> After the first patch, there are no ignore_skip_hint users where it
> would make that much difference overriding the flag for some pageblocks
> (which this effectively does) at the cost of more complicated code.
> 

No objection to a patch that sets the skip only as part of 
update_pageblock_skip(), but that is not combined with changing the
pageblock_skip_persistent() logic, which is a separate issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
