Message-ID: <46407DD4.7080101@shadowen.org>
Date: Tue, 08 May 2007 14:40:36 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: SLUB: Reduce antifrag max order (fwd)
References: <Pine.LNX.4.64.0705081416140.20563@skynet.skynet.ie>
In-Reply-To: <Pine.LNX.4.64.0705081416140.20563@skynet.skynet.ie>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, clameter@sgi.com
Cc: akpm@linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> Sorry for resend, I didn't add Andy to the cc as intended.
> 
> On Sat, 5 May 2007, Christoph Lameter wrote:
> 
>> My test systems fails to obtain order 4 allocs after prolonged use.
>> So the Antifragmentation patches are unable to guarantee order 4
>> blocks after a while (straight compile, edit load).
>>
> 
> Anti-frag still depends on reclaim to take place and I imagine you have
> not altered min_free_kbytes to keep pages free. Also, I don't think
> kswapd is currently making any effort to keep blocks free at a known
> desired order although I'm cc'ing Andy Whitcroft to confirm. As the
> kernel gives up easily when order > PAGE_ALLOC_COSTLY_ORDER, prehaps you
> should be using PAGE_ALLOC_COSTLY_ORDER instead of
> DEFAULT_ANTIFRAG_MAX_ORDER for SLUB.

kswapd only reactively uses orders above 0.  If allocations are pushing
below the high water marks those will trigger kswapd to reclaim at their
highest order.  No attempt overall is made to keep "some" higher order
pages free.  That is anticipated, but not yet tested.

>> Reduce the the max order if antifrag measures are detected to 3.

As Mel indicates you are probally best staying at or below
PAGE_ALLOC_COSTLY_ORDER and indeed that is probabally what the 3
represents below; the "highest easily allocatable order".  If so it very
likely should be:

#define DEFAULT_ANTIFRAG_MAX_ORDER PAGE_ALLOC_COSTLY_ORDER

<snip>

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
