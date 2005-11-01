Message-ID: <4366C559.5090504@yahoo.com.au>
Date: Tue, 01 Nov 2005 12:31:05 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
References: <20051030183354.22266.42795.sendpatchset@skynet.csn.ul.ie><20051031055725.GA3820@w-mikek2.ibm.com><4365BBC4.2090906@yahoo.com.au> <20051030235440.6938a0e9.akpm@osdl.org> <27700000.1130769270@[10.10.2.4]> <4366A8D1.7020507@yahoo.com.au> <Pine.LNX.4.58.0510312333240.29390@skynet>
In-Reply-To: <Pine.LNX.4.58.0510312333240.29390@skynet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On Tue, 1 Nov 2005, Nick Piggin wrote:

>>But it doesn't seem to be a great problem right now, apart from hotplug
>>and hugepages. Some jumbo GigE drivers use higher order allocations, but
>>I think there are moves to get away from that (e1000, for example).
>>
> 
> 
> GigE drivers and any other subsystem will not use higher order allocations
> if they know the underlying allocator is not going to satisfy the
> request. These patches are the starting point for properly supporting
> large allocations. I will admit that this set of patches is not going to
> solve the whole problem, but it is a start that can be built upon.
> 

I really don't think we *want* to say we support higher order allocations
absolutely robustly, nor do we want people using them if possible. Because
we don't. Even with your patches.

Ingo also brought up this point at Ottawa.

>>But this doesn't exactly make Linux bulletproof, AFAIKS it doesn't work
>>well on small memory systems, and it can still get fragmented and not work.
> 
> 
> Small memory systems are unlikely to care about satisfying large
> allocations. These patches should not be adversely affecting small memory
> systems but it is likely that a smaller value of MAX_ORDER would have to
> be used to help with fragmentation.
> 

But complexity. More bugs, code harder to understand and maintain, more
cache and memory footprint, more branches and instructions.

> You are right that we can still get fragmented. To prevent all
> fragmentation would require more work but these patches would still be the
> starting point. It makes sense to start with this patchset now and move on
> the the more complex stuff later. If these patches are in, we could later
> do stuff like;
> 
> o Configurable option that controls how strict fallback is. In a situation
>   where we absolutely do not want to fragment, do not allow kernel
>   allocations to fallback to EasyRclm zones. Instead, teach kswapd to
>   reclaim pages from the Fallback and KernNoRclm areas.
> 

In which case someone like GigE is not going to be able to access unfragmented
memory anyway. This is my point. The patch still has the same long term failure
cases that we appear to only be able to sanely solve by avoiding higher order
allocations.

The easy-to-reclaim stuff doesn't need higher order allocations anyway, so
there is no point in being happy about large contiguous regions for these
guys.

The only thing that seems to need it is memory hot unplug, which should rather
use another zone.


> All these ideas need a mechanism like this set of patches to group related
> pages together. This set of patches still help fragmentation now, although
> not in a 100% reliable fashion. My desktop which is running a kernel
> patched with these patches has been running for 33 hours and managed to
> allocate 80 order-10 blocks from ZONE_NORMAL which is about 42% of the
> zone while xmms, X, konqueror and a pile of terminals were running. That
> is pretty decent, even if it's not perfect.
> 

But nobody does that. Why should we care? And in the case you *really* need
to do that, your system likely to fail at some point anyway.

OK, for hot unplug you may want that, or for hugepages. However, in those
cases it should be done with zones AFAIKS.

>>IMO in order to make Linux bulletproof, just have fallbacks for anything
>>greater than about order 2 allocations.
>>
> 
> 
> What sort of fallbacks? Private pools of pages of the larger order for
> subsystems that need large pages is hardly desirable.
> 

Mechanisms to continue to run without contiguous memory would be best.
Small private pools aren't particularly undesirable - we do that everywhere
anyway. Your fragmentation patches essentially do that.

> 
>>From what I have seen, by far our biggest problems in the mm are due to
>>page reclaim, and these patches will make our reclaim behaviour more
>>complex I think.
>>
> 
> 
> This patchset does not touch reclaim at all. The lists that this patch
> really affects is the zone freelists, not the LRU lists that page reclaim
> are dealing with. It is only later when we want to try and guarantee
> large-order allocations that we will have to change page reclaim.
> 

But it affects things in the allocation path which in turn affects the
reclaim path. You're doing various balancing and fallbacks and it is
simply complicated behaviour in terms of trying to analyse a working
system.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
