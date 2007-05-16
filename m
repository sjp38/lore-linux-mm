Message-ID: <464AF589.2000000@yahoo.com.au>
Date: Wed, 16 May 2007 22:14:01 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] Only check absolute watermarks for ALLOC_HIGH and
 ALLOC_HARDER allocations
References: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie> <20070514173259.6787.58533.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070514173259.6787.58533.sendpatchset@skynet.skynet.ie>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: nicolas.mailhot@laposte.net, clameter@sgi.com, apw@shadowen.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> zone_watermark_ok() checks if there are enough free pages including a reserve.
> High-order allocations additionally check if there are enough free high-order
> pages in relation to the watermark adjusted based on the requested size. If
> there are not enough free high-order pages available, 0 is returned so that
> the caller enters direct reclaim.
> 
> ALLOC_HIGH and ALLOC_HARDER allocations are allowed to dip further into
> the reserves but also take into account if the number of free high-order
> pages meet the adjusted watermarks. As these allocations cannot sleep,

Why can't ALLOC_HIGH or ALLOC_HARDER sleep? This patch seems wrong to
me.

> they cannot enter direct reclaim so the allocation can fail even though
> the pages are available and the number of free pages is well above the
> watermark for order-0.
> 
> This patch alters the behaviour of zone_watermark_ok() slightly. Watermarks
> are still obeyed but when an allocator is flagged ALLOC_HIGH or ALLOC_HARDER,
> we only check that there is sufficient memory over the reserve to satisfy
> the allocation, allocation size is ignored.  This patch also documents
> better what zone_watermark_ok() is doing.

This is wrong because now you lose the buffering of higher order pages
for more urgent allocation classes against less urgent ones.

Think of how the order-0 allocation buffering works with the watermarks
and consider that we're trying to do the same exact thing for higher order
allocations here.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
