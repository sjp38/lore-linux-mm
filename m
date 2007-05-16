Date: Wed, 16 May 2007 14:24:19 +0100
Subject: Re: [PATCH 2/2] Only check absolute watermarks for ALLOC_HIGH and ALLOC_HARDER allocations
Message-ID: <20070516132419.GA18542@skynet.ie>
References: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie> <20070514173259.6787.58533.sendpatchset@skynet.skynet.ie> <464AF589.2000000@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <464AF589.2000000@yahoo.com.au>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: nicolas.mailhot@laposte.net, clameter@sgi.com, apw@shadowen.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (16/05/07 22:14), Nick Piggin didst pronounce:
> Mel Gorman wrote:
> >zone_watermark_ok() checks if there are enough free pages including a 
> >reserve.
> >High-order allocations additionally check if there are enough free 
> >high-order
> >pages in relation to the watermark adjusted based on the requested size. If
> >there are not enough free high-order pages available, 0 is returned so that
> >the caller enters direct reclaim.
> >
> >ALLOC_HIGH and ALLOC_HARDER allocations are allowed to dip further into
> >the reserves but also take into account if the number of free high-order
> >pages meet the adjusted watermarks. As these allocations cannot sleep,
> 
> Why can't ALLOC_HIGH or ALLOC_HARDER sleep? This patch seems wrong to
> me.
> 

In page_alloc.c

        if ((unlikely(rt_task(p)) && !in_interrupt()) || !wait)
                alloc_flags |= ALLOC_HARDER;

See the !wait part.

The ALLOC_HIGH applies to __GFP_HIGH allocations which are allowed to
dip into emergency pools and go below the reserve.

> >they cannot enter direct reclaim so the allocation can fail even though
> >the pages are available and the number of free pages is well above the
> >watermark for order-0.
> >
> >This patch alters the behaviour of zone_watermark_ok() slightly. Watermarks
> >are still obeyed but when an allocator is flagged ALLOC_HIGH or 
> >ALLOC_HARDER,
> >we only check that there is sufficient memory over the reserve to satisfy
> >the allocation, allocation size is ignored.  This patch also documents
> >better what zone_watermark_ok() is doing.
> 
> This is wrong because now you lose the buffering of higher order pages
> for more urgent allocation classes against less urgent ones.
> 

ALLOC_HARDER is an urgent allocation class.

> Think of how the order-0 allocation buffering works with the watermarks
> and consider that we're trying to do the same exact thing for higher order
> allocations here.
> 

What actually happens is that high-order allocations fail even though
the watermarks are met because they cannot enter direct reclaim.

> -- 
> SUSE Labs, Novell Inc.

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
