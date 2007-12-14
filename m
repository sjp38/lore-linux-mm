Date: Fri, 14 Dec 2007 11:50:39 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: QUEUE_FLAG_CLUSTER: not working in 2.6.24 ?
Message-ID: <20071214115038.GB11046@csn.ul.ie>
References: <476190BE.9010405@rtr.ca> <20071213200958.GK10104@kernel.dk> <20071213140207.111f94e2.akpm@linux-foundation.org> <1197584106.3154.55.camel@localhost.localdomain> <20071213142935.47ff19d9.akpm@linux-foundation.org> <4761B32A.3070201@rtr.ca> <4761BCB4.1060601@rtr.ca> <4761C8E4.2010900@rtr.ca> <4761CE88.9070406@rtr.ca> <20071213163726.3bb601fa.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20071213163726.3bb601fa.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Lord <liml@rtr.ca>, James.Bottomley@HansenPartnership.com, jens.axboe@oracle.com, lkml@rtr.ca, matthew@wil.cx, linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (13/12/07 16:37), Andrew Morton didst pronounce:
> On Thu, 13 Dec 2007 19:30:00 -0500
> Mark Lord <liml@rtr.ca> wrote:
> 
> > Here's the commit that causes the regression:
> > 
> > ...
> >
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -760,7 +760,8 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
> >  		struct page *page = __rmqueue(zone, order, migratetype);
> >  		if (unlikely(page == NULL))
> >  			break;
> > -		list_add_tail(&page->lru, list);
> > +		list_add(&page->lru, list);
> 
> well that looks fishy.
> 

The reasoning behind the change was the first page encountered on the list
by the caller would have a matching migratetype. I failed to take into
account the physical ordering of pages returned. I'm setting up to run some
performance benchmarks of the candidate fix merged into the -mm tree to see
if the search shows up or not. I'm testing against 2.6.25-rc5 but it'll
take a few hours to complete.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
