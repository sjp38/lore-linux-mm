Date: Wed, 26 Apr 2000 16:19:19 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: 2.3.x mem balancing
In-Reply-To: <Pine.LNX.4.21.0004252240280.14340-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.21.0004261420340.624-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Apr 2000, Rik van Riel wrote:

>On Wed, 26 Apr 2000, Andrea Arcangeli wrote:
>> On Tue, 25 Apr 2000, Linus Torvalds wrote:
>> 
>> >On Tue, 25 Apr 2000, Andrea Arcangeli wrote:
>> >> 
>> >> The design I'm using is infact that each zone know about each other, each
>> >> zone have a free_pages and a classzone_free_pages. The additional
>> >> classzone_free_pages gives us the information about the free pages on the
>> >> classzone and it's also inclusve of the free_pages of all the lower zones.
>> >
>> >AND WHAT ABOUT SETUPS WHERE THERE ISNO INCLUSION?
>> 
>> They're simpler. The classzone for them matches with the zone.
>
>It doesn't. Think NUMA.

NUMA is irrelevant. If there's no inclusion the classzone matches with the
zone.

>> clazzone is composed by. That can be achieved by having the list of the
>> zones that compose the classzone in an array allocated into the zone_t. A
>> new zone->classzones[MAX_NR_ZONES+1] will do the trick. If there's no
>> inclusion zones->classzones[0] will be equal to zone and [1] will be NULL.
>> I can do that now if you think we'll _soon_ need that genericity.
>
>This sounds like the current code. The code your patch
>deletes...

What I was talking about with zone->classzones isn't the zonelist. The
zonelist is in the pgdat, the classzones[] have to be in the zone_t
instead.

>> ZONE_NORMAL that spawns between 0 and 2g, but we have to split
>> the GFP_KERNEL allocation place in two zones that are ZONE_DMA
>> and ZONE_NORMAL.
>> 
>> But alloc_pages really have to consider the 0-2g a single zone
>> because alloc_pages gets the semantic of the zone by the user
>> that consider the 0-2g range a single zone.
>
>It does. If you read mm/page_alloc.c::__alloc_pages()
>carefully, you'll see this code fragment which does
>exactly that.
>
>        for (;;) {
>                zone_t *z = *(zone++);
>
>                /* Are we supposed to free memory? Don't make it worse.. */
>                if (!z->zone_wake_kswapd && z->free_pages > z->pages_low) {
>                        struct page *page = rmqueue(z, order);
>                        if (page)
>                                return page;
>                }
>        }

Please read what you quoted above. If the current zone is under the low
watermark we fallback in the following zone. That is obviously wrong. We
must fallback on the following zone _only_ if the current zone is empty.

>> If the current zone based design is not broken, then we can
>> split any zone in as _many_ zones as we _want_ without hurting
>> anything (except some more CPU and memory resources wasted in
>> the zone arrays since there would be more zones).
>
>We can do this just fine. Splitting a box into a dozen more
>zones than what we have currently should work just fine,
>except for (as you say) higher cpu use by kwapd.

For induction split the ZONE_NORMAL in ZONE_NORMAL->size>>PAGE_SHIFT
zones. Each zone have 1 page. The watermark have can be 0 or 1. You have
to set it to 1 _on_all_zones_ to keep the system stable. Now your VM will
try to keep all pages in the ZONE_NORMAL free all the time despite of the
settings of the other one-pages-sized zones that compose the original
ZONE_NORMAL. This behaviour is broken in the same way the 2.3.99-pre6-5 VM
is broken, the difference is _only_ that with lots of zones the broken
behaviour is more biased, and with mere two zones that 98% of machines out
there are using, the broken behavour of the current code may remain well
hided, but that doesn't change the design is fully broken and it have to
be fixed if we want something of stable and that is possible to use on all
possible hardware scenarios.

Right way to fix it is to give relation to the overlapped zones and that's
exactly what I did.

>If I get my balancing patch right, most of that disadvantage
>should be gone as well. Maybe we *do* want to do this on
>bigger SMP boxes so each processor can start out with a
>separate zone and check the other zone later to avoid lock
>contention?

See, if the current design wouldn't be broken we could get per-page
scalability in the allocation by creating all one-page-sized-zones.

>> This is obviously wrong and this also proof the current design
>> is broken.
>
>What's wrong with being able to split memory in arbitrary
>zones without running into any kind of performance trouble?

The point is that you'll run into troubles, kswapd and the VM will run
completly out of control.

>> >I tell you - you are doing the wrong thing. The earlier you realize that,
>> >the better.
>> 
>> Linus, you can convinced me immediatly if you show me how I can
>> make sure that all the ZONE_NORMAL is empty before going to
>> allocate in the ZONE_DMA with the current design.
>
>[snip]
>
>> As second using 5% and 1% of critical watermarks won't give you a 6%
>> watermark for the ZONE_NORMAL _class_zone but it will give you a 1%
>> watermark instead and you probably wanted a 6% watermark to provide
>> rasonable space for atomic allocations and for having more chances of
>> doing high order allocations.
>
>So the 1% watermark for ZONE_NORMAL is too low ... fix that.

Why do you think Linus suggested to lower the watermark of the higher
zones? Answer: because we should not left any page free in the ZONE_NORMAL
before falling back into the ZONE_DMA (assuming the ZONE_DMA is completly
free of course). We are the only ones that are able to use the ZONE_NORMAL
memory, and we should use it _now_ to be friendly with the ZONE_DMA users.

This is the same obviously right principle that is been introduced some
month ago into 2.2.1x. Right now we can do it right with 2.2.1x with a
10liner patch and we fail to do this fully right in 2.3.99-pre6-5.

>> If pages_high would been the 6% and referred to the classzone
>> the VM would have immediatly and correctly shrunk an additional
>> 5% from the freeable ZONE_NORMAL. See?
>
>I see the situation and I don't see any problem with it.
>Could you please explain to us what the problem with this
>situation is?

The VM should shrink the 5% from the ZONE_NORMAL and it doesn't do that
but it keeps trying to free the unfreeable ZONE_DMA without any
success. The VM does the wrong thing in such scenario because is not
aware of the relation between the zones.

>> >I did no tuning at all of the watermarks when I changed the zone
>> >behaviour. My bad. But that does NOT mean that the whole mm behaviour
>> >should then be reverted to the old and broken setup. It only means that
>> >the zone behaviour should be tuned.
>> 
>> If you'll try to be friendly with ZONE_DMA (by allocating from
>> the ZONE_NORMAL when possible) you'll make the allocation from
>> the higher zones less reliable and you could end doing a
>> differently kind of wrong thing as explained a few lines above.
>
>What's wrong with this?  We obviously need to set the limits
>for ZONE_NORMAL to such a number that it's possible to do
>higher-order allocations. That is no change from your proposal

Then we'll end having ZONE_DMA->pages_high+ZONE_NORMAL->pages_high free
almost all the time while we would only need pages_high memory free in the
ZONE_NORMAL _class_zone. That's memory wasted that we should be able to
use for production instead.

>and just means that your 1% example value is probably not
>feasible. Then again, that's just an example value and has
>absolutely nothing to do with the design principles of the
>current code.
>
>> >Now, the way =I= propose that this [NUMA] be handled is:
>> >
>> > - each cluster has its own zone list: cluster 0 has the list 0, 1, 2, 3,
>> >   while cluster 1 has the list 1, 2, 3, 0 etc. In short, each of them
>> >   preferentially allocate from their _own_ cluster. Together with
>> >   cluster-affinity for the processes, this way we can naturally (and with
>> >   no artificial code) try to keep cross-cluster memory accesses to
>> >   a minimum.
>> 
>> That have to be done in alloc_pages_node that later will fallback into the
>> alloc_pages. This problematic is not relevant for alloc_pages IMVHO.
>> 
>> In your scenario you'll have only 1 zone per node and there's never been
>> any problem with only one zone per node since classzone design is
>> completly equal to zone design in such case.
>> 
>> All zones in a single node by design have to be all near or far in the
>> same way to all the cpus since they all belong to the same node.
>
>You may want to do a s/cluster/node/ in Linus' paragraph and

thanks, good hint, I didn't understood well this last night, sorry.

>try again, if that makes things more obvious. What you are
>saying makes absolutely no sense at all to anybody who knows
>how NUMA works. You may want to get a book on computer architecture

Now I understood, (sorry for having missed that previously). What Linus
proposed was:

	node0->zone_zonelist[2] == node1->zone_zonelist[1] == node2->zone_zonelist[0]

That's dirty design IMVHO since it cause zones outside the node to be
referenced by the node itself.

What's wrong in putting the code that does the falling back between nodes
before starting page-freeing on them into the alloc_pages_node API? This
way a pgdat only includes stuff inside the node and gets not mixed with
the stuff from the other nodes.

>(or more sleep, if that was the problem here .. I guess we all have
>that every once in a while).
>
>> >And note - the above works _now_ with the current code. And it will never
>> >ever work with your approach. Because zone 0 is not a subset of zone 1,
>> >they are both equal. It's just that there is a preferential order for
>> >allocation depending on who does the allocation.
>> 
>> IMVHO you put the NUMA stuff in the wrong domain by abusing the zones
>> instead of using the proper nodes.
>
>I'm sorry to say this, but you don't seem to understand how NUMA
>works... We're talking about preferential memory allocation here

The way Linus proposed to do NUMA is not how NUMA works(tm), but it's one
interesting possible implementation (and yes, you are right last night I
didn't understood what Linus proposed, thanks for the clarification).

My only point is an implementation issue and is that the falling back
between nodes should be done in the higher layer (the layer where we also
ask to the interface which node we prefer to allocate from).

>and IMHO the ONLY place to do memory allocation is in the memory
>allocator.
>
>> >The fact that you think that this is true obviously means that you haven't
>> >thought AT ALL about the ways to just make the watermarks work that way.
>> 
>> I don't see how playing with the watermarks can help.
>> 
>> Playing with the watermarks is been my first idea but I
>> discarded it immediatly when I seen what would be happened by
>> lowering the higher zones watermarks. And also the watermark
>> strict per zone doesn't make any sense in first place. You can't
>> say how much you should free from ZONE_NORMAL if you don't know
>> the state of the lower ZONE_DMA zone.
>
>If there is a lot of free memory in ZONE_DMA, the memory
>allocator will do the next allocations there, relieving the

And who will stop kswapd from continuing to free the other zones? How can
you know how much a page is critical for allocations only looking
page->zone->pages_high and page->zone->free_pages? You _can't_, and any
heuristic that will consider a page critical if "page->zone->pages_high"
is major than "page->zone->free_pages" will be flawed by design and it
will end doing the wrong thing eventually.

>other zones from memory pressure and not freeing pages there
>at all. This seems to be _exactly_ what is needed and what
>your classzones achieve at a much higher complexity and lower
>flexibility...

The additional complexity is necessary to keep the overlapped zones in
relation. The flexibility point can be achieved instead. Since _none_
memory allocation in 2.3.99-pre6-5 needed further flexibility I avoided to
add such stuff in my patch ;).

>> >Give it five seconds, and you'll see that the above is _exactly_ what the
>> >watermarks control, and _exactly_ by making all the flags per-zone
>> >(instead of global or per-class). And by just using the watermark
>> 
>> IMVO we used the wrong term since the first place. Kanoj wrote a function
>> called classzone at 2.3.[345]? time, and so I inherit his 'classzone' name
>> in my emails. But what I did is not really a classzone design, but I only
>> reconstructed the real _zone_ where GFP_KERNEL wants to allocate from. In
>> 2.3.99-pre6-5 the monolithic zone where GFP_KERNEL wants to allocate from,
>> it's been broken in two unrelated, disconnected pieces. I only re-joined
>> it in once piece since it's a _single_ zone.
>
>Which doesn't make any sense at all since the allocator will do the

What does not make sense to you? Don't you believe the join between
ZONE_DMA and ZONE_NORMAL is really a single zone?

Ask yourself what do_anonymous_pages wants to allocate in a write fault.
do_anonymous_pages want to allocate a page that cames from the zone that
corresponds to the whole memory available. The zone is "0-end_of_memory".
It's 1 zone. It's 1 zone even if such zone is overlapped with lower zones.

On and on some machine it's also not overlapped and a single zone_t have
included all the memory there.

Think, think, on a machine where there's no braindamage with overlapped
zones and so where you have 1 zone from 0 to end_of_memory like here:

Apr 26 15:55:40 alpha kernel: NonDMA: 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB)
Apr 26 15:55:40 alpha kernel: DMA: 1*8kB 1*16kB 10*32kB 3*64kB 3*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 102*4096kB = 421272kB)
Apr 26 15:55:40 alpha kernel: BIGMEM: 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB)

the VM would scale worse than on x86 with the 2.3.99-pre6-5 design due the
zone->lock (there's only one zone, so there's only one lock instead of
two/three locks).

So with the current design the more you have overlapped zones the better
you scale. This doesn't make any sense, and you _have_ to pay having
subtle and unexpected drawbacks elsewhere.

And that drawbacks are exactly the scenarios I'm describing and that I'm
trying to put at the light of your eyes in my last 3/4 emails.

And yes, if you were right the current design is not broken, then I would
also be stupid to not split my 512mbyte wide ZONE_DMA in nr_cpus zones and
to let each CPU to prefer to allocate from a different zones before
falling back on the other zones.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
