Message-ID: <46410DFB.2080507@yahoo.com.au>
Date: Wed, 09 May 2007 09:55:39 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: SLUB: Reduce antifrag max order (fwd)
References: <Pine.LNX.4.64.0705081416140.20563@skynet.skynet.ie> <46407DD4.7080101@shadowen.org>
In-Reply-To: <46407DD4.7080101@shadowen.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Mel Gorman <mel@csn.ul.ie>, clameter@sgi.com, akpm@linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:
> Mel Gorman wrote:
> 
>>Sorry for resend, I didn't add Andy to the cc as intended.
>>
>>On Sat, 5 May 2007, Christoph Lameter wrote:
>>
>>
>>>My test systems fails to obtain order 4 allocs after prolonged use.
>>>So the Antifragmentation patches are unable to guarantee order 4
>>>blocks after a while (straight compile, edit load).
>>>
>>
>>Anti-frag still depends on reclaim to take place and I imagine you have
>>not altered min_free_kbytes to keep pages free. Also, I don't think
>>kswapd is currently making any effort to keep blocks free at a known
>>desired order although I'm cc'ing Andy Whitcroft to confirm. As the
>>kernel gives up easily when order > PAGE_ALLOC_COSTLY_ORDER, prehaps you
>>should be using PAGE_ALLOC_COSTLY_ORDER instead of
>>DEFAULT_ANTIFRAG_MAX_ORDER for SLUB.
> 
> 
> kswapd only reactively uses orders above 0.  If allocations are pushing
> below the high water marks those will trigger kswapd to reclaim at their
> highest order.  No attempt overall is made to keep "some" higher order
> pages free.

It does try, if you have a look at zone_watermark_ok. But it doesn't
check for pages of a higher order than are being allocated (ie. so
an order-0 alloc could split the last free order-3 page).

This is intentional, because if your workload isn't doing any higher
order allocations, it should not be trying to keep any free.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
