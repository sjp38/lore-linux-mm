Date: Tue, 24 Jul 2007 11:23:32 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/1] Wait for page writeback when directly reclaiming
 contiguous areas
In-Reply-To: <46A4DC9F.9080903@shadowen.org>
Message-ID: <Pine.LNX.4.64.0707241058090.17909@skynet.skynet.ie>
References: <20070720194120.16126.56046.sendpatchset@skynet.skynet.ie>
 <20070720194140.16126.75148.sendpatchset@skynet.skynet.ie>
 <46A4DC9F.9080903@shadowen.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 23 Jul 2007, Andy Whitcroft wrote:

> Mel Gorman wrote:
>> Lumpy reclaim works by selecting a lead page from the LRU list and then
>> selecting pages for reclaim from the order-aligned area of pages. In the
>> situation were all pages in that region are inactive and not referenced by
>> any process over time, it works well.
>>
>> In the situation where there is even light load on the system, the pages may
>> not free quickly. Out of a area of 1024 pages, maybe only 950 of them are
>> freed when the allocation attempt occurs because lumpy reclaim returned early.
>> This patch alters the behaviour of direct reclaim for large contiguous blocks.
>
> Yes, lumpy is prone to starting reclaim on an area and moving on to the
> next.  Generally where there are a lot of areas, the areas are smaller
> and the number of requests larger, this is sufficient.  However for
> higher orders it will tend to suffer from the effect you indicate.  As
> you say when the system is unloaded even at very high orders we will get
> good success rates, but higher orders on a loaded machine are problematic.
>

All sounds about right. When I was testing on my desktop though, even an 
"unloaded" machine had enough background activity to cause problems. I 
imagine this will generally be the case.

> It seems logical that if we could know when all reclaim for a targeted
> area is completed that we would have a higher chance of subsequent
> success allocating.  Looking at your patch, you are using synchronising
> with the completion of all pending writeback on pages in the targeted
> area which, pretty much gives us that.
>

That was the intention. Critically, it queues up everything 
asynchronously first and then waits for it to complete instead of 
queueing and waiting on one page at a time. In pageout(), I was somewhat 
suprised I could not have

struct writeback_control wbc = {
 	.sync_mode = sync_writeback,
 	.nonblocking = 0,
 	...
}

and have sync_writeback equal to WB_SYNC_NONE or WB_SYNC_ANY depending on 
whether the caller to pageout() wanted to sync or not. This didn't work 
out though and led to this retry logic you bring up later.

> I am surprised to see a need for a retry loop here, I would have
> expected to see an async start and a sync complete pass with the
> expectation that this would be sufficient.  Otherwise the patch is
> surprisingly simple.
>

That retry loop should be gotten rid of because as you say, it should be a 
single retry. This had been left over from an earlier version of the patch 
and I should have gotten rid of it. I'll look at testing with a WARN_ON if 
the "synchronous" returns with pages still on the list to see if it 
happens.

> I will try and reproduce with your test script and also do some general
> testing to see how this might effect the direct allocation latencies,
> which I see as key.  It may well improve those for larger allocations.
>

Cool. Thanks.

>> The first attempt to call shrink_page_list() is asynchronous but if it
>> fails, the pages are submitted a second time and the calling process waits
>> for the IO to complete. It'll retry up to 5 times for the pages to be
>> fully freed. This may stall allocators waiting for contiguous memory but
>> that should be expected behaviour for high-order users. It is preferable
>> behaviour to potentially queueing unnecessary areas for IO. Note that kswapd
>> will not stall in this fashion.
>>
>> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> [...]
>
> -apw
>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
