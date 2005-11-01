Message-ID: <4366D469.2010202@yahoo.com.au>
Date: Tue, 01 Nov 2005 13:35:21 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
References: <20051030183354.22266.42795.sendpatchset@skynet.csn.ul.ie><20051031055725.GA3820@w-mikek2.ibm.com><4365BBC4.2090906@yahoo.com.au> <20051030235440.6938a0e9.akpm@osdl.org> <27700000.1130769270@[10.10.2.4]> <4366A8D1.7020507@yahoo.com.au> <Pine.LNX.4.58.0510312333240.29390@skynet> <4366C559.5090504@yahoo.com.au> <Pine.LNX.4.58.0511010137020.29390@skynet>
In-Reply-To: <Pine.LNX.4.58.0511010137020.29390@skynet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

OK I'm starting to repeat myself a bit so after this I'll be
quiet for a bit and let others speak :)

Mel Gorman wrote:
> On Tue, 1 Nov 2005, Nick Piggin wrote:

> I accept that. We should not be encouraging subsystems to use high order
> allocations but keeping the system in a fragmented state to force the
> issue is hardly the correct thing to do either.
> 

But you don't seem to actually "fix" anything. It is slightly improved,
but for cases where higher order GFP_ATOMIC and GFP_KERNEL allocations
fail (ie. anything other than memory hotplug or hugepages) you still
seem to have all the same failure cases.

Transient higher order allocations mean we don't fragment much, you say?
Well that is true, but it is true for how the system currently works.
My desktop has been up for a day or two, and it has 4444K free, and it
has 295 order-3 pages available - it can run a GigE and all its trasient
allocations no problem.

In the cases were we *do* actually get those failures from eg. networking,
I'd say your patch probably will end up having problems too. The way to
fix it is to not use higher order allocations.

>>But complexity. More bugs, code harder to understand and maintain, more
>>cache and memory footprint, more branches and instructions.
>>
> 
> 
> The patches have gone through a large number of revisions, have been
> heavily tested and reviewed by a few people. The memory footprint of this
> approach is smaller than introducing new zones. If the cache footprint,
> increased branches and instructions were a problem, I would expect them to
> show up in the aim9 benchmark or the benchmark that ran ghostscript
> multiple times on a large file.
> 

I appreciate that a lot of work has gone into them. You must appreciate
that they add a reasonable amount of complexity and a non-zero perormance
cost to the page allocator.

However I think something must be broken if the footprint of adding a new
zone is higher?

>>The easy-to-reclaim stuff doesn't need higher order allocations anyway, so
>>there is no point in being happy about large contiguous regions for these
>>guys.
>>
> 
> 
> The will need high order allocations if we want to provide HugeTLB pages
> to userspace on-demand rather than reserving at boot-time. This is a
> future problem, but it's one that is not worth tackling until the
> fragmentation problem is fixed first.
> 

Sure. In what form, we haven't agreed. I vote zones! :)

> 
>>The only thing that seems to need it is memory hot unplug, which should rather
>>use another zone.
>>
> 
> 
> Work from 2004 in memory hotplug was trying to use additional zones. I am
> hoping that someone more involved with memory hotplug will tell us what
> problems they ran into. If they ran into no problems, they might explain
> why it was never included in the mainline.
> 

That would be good.

>>OK, for hot unplug you may want that, or for hugepages. However, in those
>>cases it should be done with zones AFAIKS.
>>
> 
> 
> And then we are back to what size to make the zones. This set of patches
> will largely manage themselves without requiring a sysadmin to intervene.
> 

Either you need to guarantee some hugepage allocation / hot unplug
capability or you don't. Placing a bit of burden on admins of these
huge servers or mainframes sounds like a fine idea to me.

Seriously nobody else will want this, no embedded, no desktops, no
small servers.

> 
>>>>IMO in order to make Linux bulletproof, just have fallbacks for anything
>>>>greater than about order 2 allocations.
>>>>
>>>
>>>
>>>What sort of fallbacks? Private pools of pages of the larger order for
>>>subsystems that need large pages is hardly desirable.
>>>
>>
>>Mechanisms to continue to run without contiguous memory would be best.
>>Small private pools aren't particularly undesirable - we do that everywhere
>>anyway. Your fragmentation patches essentially do that.
>>
> 
> 
> The main difference been that when a subsystem has small private pools, it
> is possible for anyone else to use them and shrinking mechanisms are
> required. My fragmentation patches has subpools, but they are always
> available.
> 

True, but we're talking about the need to guarantee an allocation. In
that case, mempools are required anyway and neither the current nor your
modified page allocator will help.

In the case were there is no need for a guarantee, there is presumably
some other fallback.

> 
>>>>From what I have seen, by far our biggest problems in the mm are due to
>>>>page reclaim, and these patches will make our reclaim behaviour more
>>>>complex I think.
>>>>
>>>
>>>
>>>This patchset does not touch reclaim at all. The lists that this patch
>>>really affects is the zone freelists, not the LRU lists that page reclaim
>>>are dealing with. It is only later when we want to try and guarantee
>>>large-order allocations that we will have to change page reclaim.
>>>
>>
>>But it affects things in the allocation path which in turn affects the
>>reclaim path.
> 
> 
> Maybe it's because it's late, but I don't see how these patches currently
> hit the reclaim path. The reclaim path deals with LRU lists, this set of
> patches deals with the freelists.
> 

You don't "hit" the reclaim path, but by making the allocation path
more complex makes reclaim behaviour harder to analyse.

> 
>>You're doing various balancing and fallbacks and it is
>>simply complicated behaviour in terms of trying to analyse a working
>>system.
>>
> 
> 
> Someone performing such an analysis of the system will only hit problems
> with these patches if they are performing a deep analysis of the page
> allocator. Other analysis such as the page reclaim should not even notice
> that the page allocator has changed.
> 

Let me think what a nasty one we had was? Oh yeah, the reclaim
priority would "wind up" because concurrent allocations were keeping
free pages below watermarks.

I don't know, that's just an example but there are others. The two
are fundamentally tied together.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
