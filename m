Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id B1DBC6B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 05:34:34 -0500 (EST)
Date: Fri, 13 Jan 2012 10:34:27 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2] mm/compaction : do optimazition when the migration
 scanner gets no page
Message-ID: <20120113103427.GP4118@suse.de>
References: <1326347222-9980-1-git-send-email-b32955@freescale.com>
 <20120112080311.GA30634@barrios-desktop.redhat.com>
 <20120112114835.GI4118@suse.de>
 <20120113005026.GA2614@barrios-desktop.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120113005026.GA2614@barrios-desktop.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Huang Shijie <b32955@freescale.com>, akpm@linux-foundation.org, linux-mm@kvack.org

On Fri, Jan 13, 2012 at 09:50:42AM +0900, Minchan Kim wrote:
> > > Hmm, I don't like this change.
> > > ISOLATE_NONE mean "we don't isolate any page at all"
> > > ISOLATE_SUCCESS mean "We isolaetssome pages"
> > > It's very clear but you are changing semantic slighly.
> > > 
> > 
> > That is somewhat the point of his patch - isolate_migratepages()
> > can return ISOLATE_SUCCESS even though no pages were isolated. Note that
> 
> That's what I don't like part.
> Why should we return ISOLATE_SUCESS although we didn't isolate any page?

Because the scan took place. ISOLATE_NONE is returned when no scanning
took place. ISOLATE_SUCCESS is returned when some scanning took place.
BEcause of async compaction, the scan might only be 1 page but
it's still a scan. It's easy to distinguish using the tracepoint
if necessary.

> Of course, comment can say that but I want to clear code itself than comment.
> 

Yes.

> > <SNIP>
> > 
> > It could easily be argued that if we skip over !MIGRATE_MOVABLE
> > pageblocks then we should not account for that in COMPACTBLOCKS either
> > because the scanning was minimal. In that case we would change this
> > 
> >                 /*
> >                  * For async migration, also only scan in MOVABLE blocks. Async
> >                  * migration is optimistic to see if the minimum amount of work
> >                  * satisfies the allocation
> >                  */
> >                 pageblock_nr = low_pfn >> pageblock_order;
> >                 if (!cc->sync && last_pageblock_nr != pageblock_nr &&
> >                                 get_pageblock_migratetype(page) != MIGRATE_MOVABLE) {
> >                         low_pfn += pageblock_nr_pages;
> >                         low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
> >                         last_pageblock_nr = pageblock_nr;
> >                         continue;
> >                 }
> > 
> > to return ISOLATE_NONE there instead of continue. I would be ok making
> > that part of this patch to clarify the difference between ISOLATE_NONE
> > and ISOLATE_SUCCESS and what it means for accounting.
> 
> I think simple patch is returning "return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;"
> It's very clear and readable, I think.
> In this patch, what's the problem you think?
> 

The trace point and accounting is missed and that information is useful. 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
