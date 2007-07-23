Message-ID: <46A4DC9F.9080903@shadowen.org>
Date: Mon, 23 Jul 2007 17:51:43 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] Wait for page writeback when directly reclaiming
 contiguous areas
References: <20070720194120.16126.56046.sendpatchset@skynet.skynet.ie> <20070720194140.16126.75148.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070720194140.16126.75148.sendpatchset@skynet.skynet.ie>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> Lumpy reclaim works by selecting a lead page from the LRU list and then
> selecting pages for reclaim from the order-aligned area of pages. In the
> situation were all pages in that region are inactive and not referenced by
> any process over time, it works well.
> 
> In the situation where there is even light load on the system, the pages may
> not free quickly. Out of a area of 1024 pages, maybe only 950 of them are
> freed when the allocation attempt occurs because lumpy reclaim returned early.
> This patch alters the behaviour of direct reclaim for large contiguous blocks.

Yes, lumpy is prone to starting reclaim on an area and moving on to the
next.  Generally where there are a lot of areas, the areas are smaller
and the number of requests larger, this is sufficient.  However for
higher orders it will tend to suffer from the effect you indicate.  As
you say when the system is unloaded even at very high orders we will get
good success rates, but higher orders on a loaded machine are problematic.

It seems logical that if we could know when all reclaim for a targeted
area is completed that we would have a higher chance of subsequent
success allocating.  Looking at your patch, you are using synchronising
with the completion of all pending writeback on pages in the targeted
area which, pretty much gives us that.

I am surprised to see a need for a retry loop here, I would have
expected to see an async start and a sync complete pass with the
expectation that this would be sufficient.  Otherwise the patch is
surprisingly simple.

I will try and reproduce with your test script and also do some general
testing to see how this might effect the direct allocation latencies,
which I see as key.  It may well improve those for larger allocations.

> The first attempt to call shrink_page_list() is asynchronous but if it
> fails, the pages are submitted a second time and the calling process waits
> for the IO to complete. It'll retry up to 5 times for the pages to be
> fully freed. This may stall allocators waiting for contiguous memory but
> that should be expected behaviour for high-order users. It is preferable
> behaviour to potentially queueing unnecessary areas for IO. Note that kswapd
> will not stall in this fashion.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
[...]

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
