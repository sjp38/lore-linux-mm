Date: Wed, 26 Apr 2000 03:07:04 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: 2.3.x mem balancing
In-Reply-To: <Pine.LNX.4.10.10004250932570.750-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0004251903560.13102-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Apr 2000, Linus Torvalds wrote:

>On Tue, 25 Apr 2000, Andrea Arcangeli wrote:
>> 
>> The design I'm using is infact that each zone know about each other, each
>> zone have a free_pages and a classzone_free_pages. The additional
>> classzone_free_pages gives us the information about the free pages on the
>> classzone and it's also inclusve of the free_pages of all the lower zones.
>
>AND WHAT ABOUT SETUPS WHERE THERE ISNO INCLUSION?

They're simpler. The classzone for them matches with the zone. Actually I
told the kernel that a classzone is always composed by the zone itself
joined with all the lower zones (since I tought we're not going to have a
non lower-zone-inclusive setup any time soon and so I made the code faster
harcoding such assumption), but if that won't be true any longer we only
need to tell the code that updates classzone_free_pages what zones the
clazzone is composed by. That can be achieved by having the list of the
zones that compose the classzone in an array allocated into the zone_t. A
new zone->classzones[MAX_NR_ZONES+1] will do the trick. If there's no
inclusion zones->classzones[0] will be equal to zone and [1] will be NULL.
I can do that now if you think we'll _soon_ need that genericity.

Please consider this. When we do a GFP_KERNEL allocation, we want to
allocate from 1 zone. Not from two zones. When we do:

	alloc_page(GFP_KERNEL);

we want to allocate from 1 zone that is between 0 and 2giga.

	0						2g
	-------------------------------------------------
	| ZONE_DMA	| ZONE_NORMAL			|
	-------------------------------------------------
	|            GFP_KERNEL				|
	-------------------------------------------------

Incidentally we also have somebody (GFP_DMA) that wants to allocate from
the ZONE_DMA and so to be able to provide GFP_DMA allocations in O(1) we
can't create a single indpendent ZONE_NORMAL that spawns between 0 and 2g,
but we have to split the GFP_KERNEL allocation place in two zones that are
ZONE_DMA and ZONE_NORMAL.

But alloc_pages really have to consider the 0-2g a single zone because
alloc_pages gets the semantic of the zone by the user that consider the
0-2g range a single zone.

If it's true as you say that we can make to work alloc_pages on the 0-2g
zone using two completly separated and not-related-in-any-way zones, then
we could also split the ZONE_DMA is ZONE_DMA0 and ZONE_DMA1 and be able to
keep the ZONE_DMA1 classzone balanced as if it would be still ZONE_DMA.
We could in the same way split ZONE_NORMAL in several zones and still keep
ZONE_NORMAL in perfect balance.

If the current zone based design is not broken, then we can split any zone
in as _many_ zones as we _want_ without hurting anything (except some
more CPU and memory resources wasted in the zone arrays since there would
be more zones).

This is obviously wrong and this also proof the current design is
broken.

>Andrea, face it, the design is WRONG!
>
>You've made both free_pages() and alloc_pages() more complex and costly,
>and the per-zone spinlock cannot exist any more. WHICH IS BAD BAD BAD.

rmqueue and __free_pages_ok are now doing at once the work that
nr_free_buffer_pages was doing all the time. I don't know how much these
changes are sensitive in performance.

For the spinlock I fully agree, previous code was very nicer. However I
couldn't find a way to avoid parallel alloc_pages() to fool the memory
balancing by using a per-zone lock (I could acquire more than one spinlock
in zone-decreasing-order but that was going to hurt too much) and so IMHO
the previous code was risky indipendent of the zone problems.

>Thing of the case of a NUMA architecture - you sure as hell want to have
>all "local" zones share the same spinlock, because then you'll have to
>grab a global spinlock for each allocation, even if you only allocate from
>a local zone closeto the node you're actually running on.

I'm sorry but I'm not sure to understand what you mean. NUMA scaling is
not more penalized than non NUMA scaling as far I can tell. The spinlock
is now in the node so you are still allowed to allocate from two
_different_ nodes at the same time as before.

node0->node_zones[0] != node1->node_zones[0] && node0->freelist_lock != node1->freelist_lock

>I tell you - you are doing the wrong thing. The earlier you realize that,
>the better.

I apologise but I still think I'm doing the right thing and that the
current strict zone based design is not correct and that it will end doing
the wrong thing sometime with non obvious drawbacks.

Linus, you can convinced me immediatly if you show me how I can make sure
that all the ZONE_NORMAL is empty before going to allocate in the ZONE_DMA
with the current design. I also like to know how can I stop kswapd that is
trying to raise the ZONE_NORMAL->free_pages over ZONE_NORMAL->pages_high
after kswapd succesfully put the ZONE_DMA over the ZONE_DMA->pages_high
limit in the previous pass (assuming ZONE_DMA->pages_high >=
ZONE_NORMAL->pages_high, that's perfectly allowed value). Also from
swap_out how can I know how much a page is critical by only looking at how
many free pages are in its zone (think if the lower zones are completly
free).

>> >> Now assume rest of memory zone (ZONE_NORMAL) is getting under the
>> >> zone_normal->page_low watermark. We must definitely not start kswapd if
>> >> there are still 16mbyte of free memory in the classzone.
>> >
>> >No.
>> >
>> >We should just not allocate from that zone. Look at what
>> >__get_free_pages() does: it tries to first find _any_ zone that it can
>> >allocate from, and if it cannot find such a zone only _then_ does it
>> >decide to start kswapd.
>> 
>> Woops I did wrong example to explain the suprious kswapd run and I also
>> didn't explained the real problem in that scenario.
>> 
>> The real problem in that scenario is that you don't empty the ZONE_NORMAL
>> but you stop at the low watermark, while you should empty the ZONE_NORMAL
>> complelty for allocation that supports ZONE_NORMAL memory (so for non
>> ISA_DMA memory) before falling back into the ZONE_DMA zone.
>
>Oh?
>
>And what is wrong with just changing the water-marks, instead of your
>global (and in my opinion stupid and wrong) change?
>
>Why didn't you just do a small little initialization routine that made the
>watermark for the DMA zone go up, and the watermark for the bigger zones
>go down?
>
>Let's face it, with the current Linux per-zone memory allocation, doing
>things like that is _trivial_. There are no magic couplings between
>different zones, so if you want to make sure that it's primarily only the
>DMA zone that is kept free, then you can do _exactly_ that by saying
>simply that the "critical watermark for the DMA zone should be 5%, while
>the critical watermark for the regular zone should be just 1%".

As first this mean you'll left an 1% of the ZONE_NORMAL free, while you
should have allocated also such remaining 1% before falling back in the
ZONE_DMA and so your solution doesn't solve the problem but only hides it
better. There's no one single good reason for which you should left such
1% free, while there are obvious good reason for which you should allocate
also such 1% before falling back on the lower zone.

As second using 5% and 1% of critical watermarks won't give you a 6%
watermark for the ZONE_NORMAL _class_zone but it will give you a 1%
watermark instead and you probably wanted a 6% watermark to provide
rasonable space for atomic allocations and for having more chances of
doing high order allocations.

(note the numbers 1%/5% and global 6% are just random values for me now,
I'm not even thinking if they are a good default or not, just assume they
are a good default for the following example)

Assume you want a 6% watermark on the zone-normal classzone, ok?

Now suppose 95% of the ZONE_DMA is mlocked and a ISA-DMA network card
allocates from irqs the latest 5%. Suppose the ZONE_NORMAL is all
_freeable_ in not mapped page cache but that 99% of the ZONE_NORMAL is
allocated in page cache and only the 1% is free. Then the VM with the
current design will take only 1% free in the ZONE_NORMAL _classzone_
because it have no knowledge about the classzone.

If pages_high would been the 6% and referred to the classzone the VM would
have immediatly and correctly shrunk an additional 5% from the freeable
ZONE_NORMAL. See?

You can't fix that problem without changing design.

>I did no tuning at all of the watermarks when I changed the zone
>behaviour. My bad. But that does NOT mean that the whole mm behaviour
>should then be reverted to the old and broken setup. It only means that
>the zone behaviour should be tuned.

If you'll try to be friendly with ZONE_DMA (by allocating from the
ZONE_NORMAL when possible) you'll make the allocation from the higher
zones less reliable and you could end doing a differently kind of wrong
thing as explained a few lines above.

>> You can't
>> optimize the zone usage without knowledge on the whole classzone. That's
>> the first basic thing where the strict zone based design will be always
>> inferior compared to a classzone based design.
>
>You are wrong. And you are so FUNDAMENTALLY wrong that I'm at a loss to
>even explain why.
>
>What's the matter with just realizing that the whole issue of DMA vs
>non-DMA, and local zone vs remote zone is just a very generic case of
>trying to balance memory usage. It has nothing at all to do with
>"inclusion", and I personally think that the whole notion of "inclusion"
>is fundamentally flawed. It adds a rule that shouldn't be there, and has
>no meaning.
>
>Andrea, how do you ever propose to handle the case of four different
>memory zones, all "equal", but all separate in that while all of memory
>isaccessible from each CPU, each zone is "closer" to certain CPU's? Let's
>say that CPU's 0-3 have direct access to zone 0, CPU's 4-7 have direct
>access to zone 1, etc etc.. Whenever a CPU touches memory on a non-local
>zone, it takes longer for the cache miss, but it still works.

Note that what you call zones are really nodes. Your zone 0 is not a
zone_t but a pg_data_t instead.

>Now, the way =I= propose that this be handled is:
>
> - each cluster has its own zone list: cluster 0 has the list 0, 1, 2, 3,
>   while cluster 1 has the list 1, 2, 3, 0 etc. In short, each of them
>   preferentially allocate from their _own_ cluster. Together with
>   cluster-affinity for the processes, this way we can naturally (and with
>   no artificial code) try to keep cross-cluster memory accesses to
>   a minimum.

That have to be done in alloc_pages_node that later will fallback into the
alloc_pages. This problematic is not relevant for alloc_pages IMVHO.

In your scenario you'll have only 1 zone per node and there's never been
any problem with only one zone per node since classzone design is
completly equal to zone design in such case.

All zones in a single node by design have to be all near or far in the
same way to all the cpus since they all belong to the same node.

>And note - the above works _now_ with the current code. And it will never
>ever work with your approach. Because zone 0 is not a subset of zone 1,
>they are both equal. It's just that there is a preferential order for
>allocation depending on who does the allocation.

IMVHO you put the NUMA stuff in the wrong domain by abusing the zones
instead of using the proper nodes.

>> About kswapd suppose we were low on memory on both the two zones and so we
>> started kswapd on both zones and we keep allocating waiting to reach the
>> min watermark. Then while kswapd it's running a process exits and release
>> all the first 16mbyte of RAM. kswapd correctly stops freeing the ISADMA
>> zone (because free_pages set zone_wake_kswapd back to zero) but kswapd
>> will keep freeing the normal zone for no good reason. You have no way to
>> stop the wrong kswapd in such scenario without a classzone design. If you
>> keep looking only at zone->free_pages and zone->pages_high then kswapd
>> will keep running for no good reason.
>
>The fact that you think that this is true obviously means that you haven't
>thought AT ALL about the ways to just make the watermarks work that way.

I don't see how playing with the watermarks can help.

Playing with the watermarks is been my first idea but I discarded it
immediatly when I seen what would be happened by lowering the higher zones
watermarks. And also the watermark strict per zone doesn't make any sense
in first place. You can't say how much you should free from ZONE_NORMAL if
you don't know the state of the lower ZONE_DMA zone. All such
pages_{high,low,min} watermarks can make sense only if referred to the
classzone.

>Give it five seconds, and you'll see that the above is _exactly_ what the
>watermarks control, and _exactly_ by making all the flags per-zone
>(instead of global or per-class). And by just using the watermark

IMVO we used the wrong term since the first place. Kanoj wrote a function
called classzone at 2.3.[345]? time, and so I inherit his 'classzone' name
in my emails. But what I did is not really a classzone design, but I only
reconstructed the real _zone_ where GFP_KERNEL wants to allocate from. In
2.3.99-pre6-5 the monolithic zone where GFP_KERNEL wants to allocate from,
it's been broken in two unrelated, disconnected pieces. I only re-joined
it in once piece since it's a _single_ zone. It's a more problematic zone
since it's overlapped with the lower zones and so we have to update it
also when we change the lower zones, but it's really a _single_ zone that
shares the same equal properties of the other zones.

>In short, you've only convinced me _not_ to touch your patches, by showing
>that you haven't even though about what the current setup really means.

Note that I have started saying "let's try to give the current code better
balance since it seems we're calling swap_out two more times than
necessary". And the first time I read the new alloc_pages code I thought
"cute idea to implement alloc_pages that way, we avoid the cost of having
to calculate the number of free pages in the classzone".

_Then_ when I tried to give to the smarter code the expected right
behaviour I noticed I couldn't in lots of cases and that's the only reason
that caused me to change the design of the zones.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
