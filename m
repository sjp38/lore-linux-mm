Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8DDC16B004D
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 11:26:09 -0400 (EDT)
Date: Fri, 7 Aug 2009 16:26:16 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/6] tracing, page-allocator: Add trace events for
	anti-fragmentation falling back to other migratetypes
Message-ID: <20090807152616.GD24148@csn.ul.ie>
References: <1249574827-18745-1-git-send-email-mel@csn.ul.ie> <1249574827-18745-3-git-send-email-mel@csn.ul.ie> <20090807080249.GA21821@elte.hu> <20090807105732.GB18134@csn.ul.ie> <20090807110203.GC24916@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090807110203.GC24916@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 07, 2009 at 01:02:03PM +0200, Ingo Molnar wrote:
> 
> * Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > On Fri, Aug 07, 2009 at 10:02:49AM +0200, Ingo Molnar wrote:
> > > 
> > > * Mel Gorman <mel@csn.ul.ie> wrote:
> > > 
> > > > +++ b/mm/page_alloc.c
> > > > @@ -839,6 +839,12 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
> > > >  							start_migratetype);
> > > >  
> > > >  			expand(zone, page, order, current_order, area, migratetype);
> > > > +
> > > > +			trace_mm_page_alloc_extfrag(page, order, current_order,
> > > > +				start_migratetype, migratetype,
> > > > +				current_order < pageblock_order,
> > > > +				migratetype == start_migratetype);
> > > 
> > > This tracepoint too should be optimized some more:
> > > 
> > >  - pageblock_order can be passed down verbatim instead of the 
> > >    'current_order < pageblock_order': it means one comparison less 
> > >    in the fast-path, plus it gives more trace information as well.
> > > 
> > >  - migratetype == start_migratetype check is superfluous as both 
> > >    values are already traced. This property can be added to the 
> > >    TP_printk() post-processing stage instead, if the pretty-printing 
> > >    is desired.
> > > 
> > 
> > I think what you're saying that it's better to handle additional 
> > information like this in TP_printk always. That's what I've 
> > changed both of these into at least. I didn't even need to pass 
> > down pageblock_order because it should be available in the 
> > post-processing context from a header.
> 
> yeah. I formulated my suggestions in a trace-output-invariant way. 
> If some information can be omitted altogether from the trace, the 
> better.
> 

Yeah, it's an obvious point once thought about for more than a second. When
I wrote it this way, it was because I wanted to work out the higher-level
workings near the code in case it's assumptions went out of date and the
tracepoint was forgotten about, just as comments going out of date. However,
it's not much protection, tracepoints are just something that will need to
have to be remembered when changing existing assumptions.

> > The additional parameters are not being passed down any more and 
> > the TP_printk looks like
> > 
> >         TP_printk("page=%p pfn=%lu alloc_order=%d fallback_order=%d pageblock_order=%d alloc_migratetype=%d fallback_migratetype=%d fragmenting=%d change_ownership=%d",
> >                 __entry->page,
> >                 page_to_pfn(__entry->page),
> >                 __entry->alloc_order,
> >                 __entry->fallback_order,
> >                 pageblock_order,
> >                 __entry->alloc_migratetype,
> >                 __entry->fallback_migratetype,
> >                 __entry->fallback_order < pageblock_order,
> >                 __entry->alloc_migratetype == __entry->fallback_migratetype)
> > 
> > Is that what you meant?
> 
> yeah, this looks more compact.
> 
> A detail: we might still want to pass in pageblock_order somehow - 
> for example 'perf' will get access to the raw binary record but wont 
> run the above printk line.
> 

It's invariant for the lifetime of the system so it shouldn't be part of the
record. Often it can be reliably guessed because it's based on the default
hugepage size that can be allocated from the buddy lists.

x86-without-PAE:	pageblock == 10
x86-with-PAE:		pageblock == 9
x86-64:			pageblock == 9  (even if 1GB pages are available)
ppc64:			pageblock == 12 (4K base page) or 8 (64K base page)
ia64:			depends on boot parameters
other cases:		pageblock == MAX_ORDER-1

So perf can make a reasonably guess that can be specified from command-line
if absolutly necessary.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
