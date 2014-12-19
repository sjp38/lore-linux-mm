Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E40406B0038
	for <linux-mm@kvack.org>; Thu, 18 Dec 2014 21:00:01 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so146196pad.29
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 18:00:01 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id kl5si12159129pbc.256.2014.12.18.17.59.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Dec 2014 18:00:00 -0800 (PST)
Received: by mail-pa0-f42.google.com with SMTP id et14so146147pad.29
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 17:59:59 -0800 (PST)
Date: Fri, 19 Dec 2014 02:01:30 +0000
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch 1/6] mm: page_isolation: check pfn validity before access
Message-ID: <20141219020130.GA22412@gmail.com>
References: <548f68b2.K9HkeqWVHZ6daibm%akpm@linux-foundation.org>
 <alpine.DEB.2.10.1412171548150.16260@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1412171548150.16260@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, weijie.yang@samsung.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, mhocko@suse.cz, mina86@mina86.com, stable@vger.kernel.org

On Wed, Dec 17, 2014 at 03:56:08PM -0800, David Rientjes wrote:
> On Mon, 15 Dec 2014, akpm@linux-foundation.org wrote:
> 
> > From: Weijie Yang <weijie.yang@samsung.com>
> > Subject: mm: page_isolation: check pfn validity before access
> > 
> > In the undo path of start_isolate_page_range(), we need to check the pfn
> > validity before accessing its page, or it will trigger an addressing
> > exception if there is hole in the zone.
> > 
> > This issue is found by code-review not a test-trigger.  In
> > "CONFIG_HOLES_IN_ZONE" environment, there is a certain chance that it
> > would casue an addressing exception when start_isolate_page_range()
> > fails, this could affect CMA, hugepage and memory-hotplug function.
> > 
> > Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> > Acked-by: Michal Nazarewicz <mina86@mina86.com>
> > Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: Mel Gorman <mel@csn.ul.ie>
> > Cc: Michal Hocko <mhocko@suse.cz>
> > Cc: <stable@vger.kernel.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> > 
> >  mm/page_isolation.c |    7 +++++--
> >  1 file changed, 5 insertions(+), 2 deletions(-)
> > 
> > diff -puN mm/page_isolation.c~mm-page_isolation-check-pfn-validity-before-access mm/page_isolation.c
> > --- a/mm/page_isolation.c~mm-page_isolation-check-pfn-validity-before-access
> > +++ a/mm/page_isolation.c
> > @@ -176,8 +176,11 @@ int start_isolate_page_range(unsigned lo
> >  undo:
> >  	for (pfn = start_pfn;
> >  	     pfn < undo_pfn;
> > -	     pfn += pageblock_nr_pages)
> > -		unset_migratetype_isolate(pfn_to_page(pfn), migratetype);
> > +	     pfn += pageblock_nr_pages) {
> > +		page = __first_valid_page(pfn, pageblock_nr_pages);
> > +		if (page)
> > +			unset_migratetype_isolate(page, migratetype);
> > +	}
> >  
> >  	return -EBUSY;
> >  }
> 
> This is such an interesting patch because of who acked it and the two 
> callers of the function that seem to want different behavior.
> 
> The behavior of start_isolate_page_range() is currently to either set the 
> migratetype of the pageblocks to MIGRATE_ISOLATE or allow the pageblocks 
> to have no valid pages due to a memory hole.
> 
> The memory hotplug usecase makes perfect sense since it's entirely 
> legitimate to offline memory holes and we would not want to return -EBUSY, 
> but that doesn't seem to be what the implementation of 
> start_isolate_page_range() is this undo behavior expects pfn_to_page(pfn) 
> to be valid up to undo_pfn.
> 
> I'm not a CMA expert, but I'm surprised that we want to return success 
> here if some pageblocks are actually memory holes.  Don't we want to 
> return -EBUSY for such a range?  That seems to be more in line with the 
> comment for start_isolate_page_range() which specifies it returns "-EBUSY 
> if any part of range cannot be isolated", which would seem to imply memory 
> holes as well, but that doesn't match its implementation.

Can CMA have memory hole?
CMA user should allocate CMA area with cma_declare_contiguous which uses
memblock. I'm not familiar with memblock but I don't think it's possible.

> 
> So there's two radically different expectations for this function with 
> regard to invalid pfns.  Which one do we want?
> 
> If we want it to simply disregard memory holes (memory hotplug), then ack 
> the patch with a follow-up to fix the comment.  If we want it to undo on 
> memory holes (CMA), then nack the patch since its current implementation 
> is correct and we need to fix memory hotplug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
