Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 014C66B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 19:50:53 -0500 (EST)
Received: by vcge1 with SMTP id e1so2341793vcg.14
        for <linux-mm@kvack.org>; Thu, 12 Jan 2012 16:50:53 -0800 (PST)
Date: Fri, 13 Jan 2012 09:50:42 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm/compaction : do optimazition when the migration
 scanner gets no page
Message-ID: <20120113005026.GA2614@barrios-desktop.redhat.com>
References: <1326347222-9980-1-git-send-email-b32955@freescale.com>
 <20120112080311.GA30634@barrios-desktop.redhat.com>
 <20120112114835.GI4118@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120112114835.GI4118@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Huang Shijie <b32955@freescale.com>, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu, Jan 12, 2012 at 11:48:35AM +0000, Mel Gorman wrote:
> On Thu, Jan 12, 2012 at 05:03:11PM +0900, Minchan Kim wrote:
> > On Thu, Jan 12, 2012 at 01:47:02PM +0800, Huang Shijie wrote:
> > > In the real tests, there are maybe many times the cc->nr_migratepages is zero,
> > > but isolate_migratepages() returns ISOLATE_SUCCESS.
> > > 
> > > Memory in our mx6q board:
> > > 	2G memory, 8192 pages per page block
> > > 
> > > We use the following command to test in two types system loads:
> > > 	#echo 1 > /proc/sys/vm/compact_memory
> > > 
> > > Test Result:
> > > 	[1] little load(login in the ubuntu):
> > > 		all the scanned pageblocks	: 79
> > > 		pageblocks which get no pages	: 46
> > > 
> > > 		The ratio of `get no pages` pageblock is 58.2%.
> > > 
> > > 	[2] heavy load(start thunderbird, firefox, ..etc):
> > > 		all the scanned pageblocks	: 89
> > > 		pageblocks which get no pages	: 36
> > > 
> > > 		The ratio of `get no pages` pageblock is 40.4%.
> > > 
> > > In order to get better performance, we should check the number of the
> > > really isolated pages. And do the optimazition for this case.
> > > 
> > > Also fix the confused comments(from Mel Gorman).
> > > 
> > > Tested this patch in MX6Q board.
> > > 
> > > Signed-off-by: Huang Shijie <b32955@freescale.com>
> > > Acked-by: Mel Gorman <mgorman@suse.de>
> > > ---
> > >  mm/compaction.c |   28 ++++++++++++++++------------
> > >  1 files changed, 16 insertions(+), 12 deletions(-)
> > > 
> > > diff --git a/mm/compaction.c b/mm/compaction.c
> > > index f4f514d..41d1b72a 100644
> > > --- a/mm/compaction.c
> > > +++ b/mm/compaction.c
> > > @@ -246,8 +246,8 @@ static bool too_many_isolated(struct zone *zone)
> > >  /* possible outcome of isolate_migratepages */
> > >  typedef enum {
> > >  	ISOLATE_ABORT,		/* Abort compaction now */
> > > -	ISOLATE_NONE,		/* No pages isolated, continue scanning */
> > > -	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
> > > +	ISOLATE_NONE,		/* No pages scanned, consider next pageblock*/
> > > +	ISOLATE_SUCCESS,	/* Pages scanned and maybe isolated, migrate */
> > >  } isolate_migrate_t;
> > >  
> > 
> > Hmm, I don't like this change.
> > ISOLATE_NONE mean "we don't isolate any page at all"
> > ISOLATE_SUCCESS mean "We isolaetssome pages"
> > It's very clear but you are changing semantic slighly.
> > 
> 
> That is somewhat the point of his patch - isolate_migratepages()
> can return ISOLATE_SUCCESS even though no pages were isolated. Note that

That's what I don't like part.
Why should we return ISOLATE_SUCESS although we didn't isolate any page?
Of course, comment can say that but I want to clear code itself than comment.

> he does not change when ISOLATE_NONE or ISOLATE_SUCCESS gets returned,
> he updates the comment to match what the code is actually doing. This

I think he code is doing needs fix.

> should be visible from the tracepoint. My machine has been up for days
> and loaded when I started a process that mapped a large anonymous
> region. THP would kick in and I see from the tracepoints excerpts like
> this
> 
>           malloc-13964 [007] 221636.457022: mm_compaction_isolate_migratepages: nr_scanned=1 nr_taken=0
>           malloc-13964 [007] 221636.457022: mm_compaction_isolate_migratepages: nr_scanned=1 nr_taken=0
>           malloc-13964 [007] 221636.457023: mm_compaction_isolate_migratepages: nr_scanned=1 nr_taken=0
>           malloc-13964 [007] 221636.457023: mm_compaction_isolate_migratepages: nr_scanned=1 nr_taken=0
>           malloc-13964 [007] 221636.457024: mm_compaction_isolate_migratepages: nr_scanned=1 nr_taken=0
>           malloc-13964 [007] 221636.457025: mm_compaction_isolate_migratepages: nr_scanned=1 nr_taken=0
>           malloc-13964 [007] 221636.457025: mm_compaction_isolate_migratepages: nr_scanned=1 nr_taken=0
>           malloc-13964 [007] 221636.457049: mm_compaction_isolate_migratepages: nr_scanned=512 nr_taken=16
>           malloc-13964 [007] 221636.457102: mm_compaction_isolate_migratepages: nr_scanned=512 nr_taken=16
>           malloc-13964 [007] 221636.457143: mm_compaction_isolate_migratepages: nr_scanned=512 nr_taken=17
>           malloc-13964 [007] 221636.457189: mm_compaction_isolate_migratepages: nr_scanned=433 nr_taken=32
>           malloc-13964 [007] 221636.457253: mm_compaction_isolate_migratepages: nr_scanned=205 nr_taken=32
>           malloc-13964 [007] 221636.457319: mm_compaction_isolate_migratepages: nr_scanned=389 nr_taken=7
> 
> These "nr_scanned=1 nr_taken=0" are during async compaction where the
> scanner is skipping over pageblocks that are not MIGRATE_MOVABLE. As the
> function only deals in pageblocks, it means the function returns after
> only scanning 1 page expecting that compact_zone() will move to the next
> block.
> 
> > How about this?
> > 
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -376,7 +376,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
> >  
> >         trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
> >  
> > -       return ISOLATE_SUCCESS;
> > +       return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
> >  }
> >  
> >  /*
> > @@ -542,6 +542,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
> >                 unsigned long nr_migrate, nr_remaining;
> >                 int err;
> >  
> > +               count_vm_event(COMPACTBLOCKS);
> > +
> >                 switch (isolate_migratepages(zone, cc)) {
> >                 case ISOLATE_ABORT:
> >                         ret = COMPACT_PARTIAL;
> > @@ -559,7 +561,6 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
> >                 update_nr_listpages(cc);
> >                 nr_remaining = cc->nr_migratepages;
> >  
> > -               count_vm_event(COMPACTBLOCKS);
> >                 count_vm_events(COMPACTPAGES, nr_migrate - nr_remaining);
> >                 if (nr_remaining)
> >                         count_vm_events(COMPACTPAGEFAILED, nr_remaining);
> > 
> > This patch's side effect is that it accounts COMPACTBLOCK although isolation is cancel by signal
> > but I think it's very rare and doesn't give big effect for statistics of compaciton.
> > 
> 
> This came up during discussion the last time. My opinion was that
> COMPACTBLOCK not being updated was a problem. In the existing code
> ISOLATE_NONE returning also means the scan did not take place and
> this does not need to be accounted for. However, if we scan the block
> and isolate no pages, we still want to account for that. A rapidly
> increasing COMPACTBLOCKS while COMPACTPAGES changes very little could
> indicate that compaction is doing a lot of busy work without making
> any useful progress for example.

Agree.

> 
> It could easily be argued that if we skip over !MIGRATE_MOVABLE
> pageblocks then we should not account for that in COMPACTBLOCKS either
> because the scanning was minimal. In that case we would change this
> 
>                 /*
>                  * For async migration, also only scan in MOVABLE blocks. Async
>                  * migration is optimistic to see if the minimum amount of work
>                  * satisfies the allocation
>                  */
>                 pageblock_nr = low_pfn >> pageblock_order;
>                 if (!cc->sync && last_pageblock_nr != pageblock_nr &&
>                                 get_pageblock_migratetype(page) != MIGRATE_MOVABLE) {
>                         low_pfn += pageblock_nr_pages;
>                         low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
>                         last_pageblock_nr = pageblock_nr;
>                         continue;
>                 }
> 
> to return ISOLATE_NONE there instead of continue. I would be ok making
> that part of this patch to clarify the difference between ISOLATE_NONE
> and ISOLATE_SUCCESS and what it means for accounting.

I think simple patch is returning "return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;"
It's very clear and readable, I think.
In this patch, what's the problem you think?

> 
> > 
> > >  /*
> > > @@ -542,7 +542,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
> > >  
> > >  	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
> > >  		unsigned long nr_migrate, nr_remaining;
> > > -		int err;
> > > +		int err = 0;
> > >  
> > >  		switch (isolate_migratepages(zone, cc)) {
> > >  		case ISOLATE_ABORT:
> > > @@ -554,17 +554,21 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
> > >  			;
> > >  		}
> > >  
> > > -		nr_migrate = cc->nr_migratepages;
> > > -		err = migrate_pages(&cc->migratepages, compaction_alloc,
> > > -				(unsigned long)cc, false,
> > > -				cc->sync);
> > > -		update_nr_listpages(cc);
> > > -		nr_remaining = cc->nr_migratepages;
> > > +		nr_migrate = nr_remaining = cc->nr_migratepages;
> > > +		if (nr_migrate) {
> > > +			err = migrate_pages(&cc->migratepages, compaction_alloc,
> > > +					(unsigned long)cc, false,
> > > +					cc->sync);
> > > +			update_nr_listpages(cc);
> > > +			nr_remaining = cc->nr_migratepages;
> > > +			count_vm_events(COMPACTPAGES,
> > > +					nr_migrate - nr_remaining);
> > > +			if (nr_remaining)
> > > +				count_vm_events(COMPACTPAGEFAILED,
> > > +						nr_remaining);
> > > +		}
> > >  
> > >  		count_vm_event(COMPACTBLOCKS);
> > > -		count_vm_events(COMPACTPAGES, nr_migrate - nr_remaining);
> > > -		if (nr_remaining)
> > > -			count_vm_events(COMPACTPAGEFAILED, nr_remaining);
> > >  		trace_mm_compaction_migratepages(nr_migrate - nr_remaining,
> > >  						nr_remaining);
> > >  
> 
> -- 
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
