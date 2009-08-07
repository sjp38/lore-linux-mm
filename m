Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7660D6B004D
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 06:57:25 -0400 (EDT)
Date: Fri, 7 Aug 2009 11:57:33 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/6] tracing, page-allocator: Add trace events for
	anti-fragmentation falling back to other migratetypes
Message-ID: <20090807105732.GB18134@csn.ul.ie>
References: <1249574827-18745-1-git-send-email-mel@csn.ul.ie> <1249574827-18745-3-git-send-email-mel@csn.ul.ie> <20090807080249.GA21821@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090807080249.GA21821@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 07, 2009 at 10:02:49AM +0200, Ingo Molnar wrote:
> 
> * Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > +++ b/mm/page_alloc.c
> > @@ -839,6 +839,12 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
> >  							start_migratetype);
> >  
> >  			expand(zone, page, order, current_order, area, migratetype);
> > +
> > +			trace_mm_page_alloc_extfrag(page, order, current_order,
> > +				start_migratetype, migratetype,
> > +				current_order < pageblock_order,
> > +				migratetype == start_migratetype);
> 
> This tracepoint too should be optimized some more:
> 
>  - pageblock_order can be passed down verbatim instead of the 
>    'current_order < pageblock_order': it means one comparison less 
>    in the fast-path, plus it gives more trace information as well.
> 
>  - migratetype == start_migratetype check is superfluous as both 
>    values are already traced. This property can be added to the 
>    TP_printk() post-processing stage instead, if the pretty-printing 
>    is desired.
> 

I think what you're saying that it's better to handle additional information
like this in TP_printk always. That's what I've changed both of these into
at least. I didn't even need to pass down pageblock_order because it should
be available in the post-processing context from a header.

The additional parameters are not being passed down any more and the
TP_printk looks like

        TP_printk("page=%p pfn=%lu alloc_order=%d fallback_order=%d pageblock_order=%d alloc_migratetype=%d fallback_migratetype=%d fragmenting=%d change_ownership=%d",
                __entry->page,
                page_to_pfn(__entry->page),
                __entry->alloc_order,
                __entry->fallback_order,
                pageblock_order,
                __entry->alloc_migratetype,
                __entry->fallback_migratetype,
                __entry->fallback_order < pageblock_order,
                __entry->alloc_migratetype == __entry->fallback_migratetype)

Is that what you meant?


-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
