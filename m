Date: Tue, 25 Apr 2000 23:10:56 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: 2.3.x mem balancing
In-Reply-To: <Pine.LNX.4.21.0004251903560.13102-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0004252240280.14340-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Apr 2000, Andrea Arcangeli wrote:
> On Tue, 25 Apr 2000, Linus Torvalds wrote:
> 
> >On Tue, 25 Apr 2000, Andrea Arcangeli wrote:
> >> 
> >> The design I'm using is infact that each zone know about each other, each
> >> zone have a free_pages and a classzone_free_pages. The additional
> >> classzone_free_pages gives us the information about the free pages on the
> >> classzone and it's also inclusve of the free_pages of all the lower zones.
> >
> >AND WHAT ABOUT SETUPS WHERE THERE ISNO INCLUSION?
> 
> They're simpler. The classzone for them matches with the zone.

It doesn't. Think NUMA.

> clazzone is composed by. That can be achieved by having the list of the
> zones that compose the classzone in an array allocated into the zone_t. A
> new zone->classzones[MAX_NR_ZONES+1] will do the trick. If there's no
> inclusion zones->classzones[0] will be equal to zone and [1] will be NULL.
> I can do that now if you think we'll _soon_ need that genericity.

This sounds like the current code. The code your patch
deletes...

> ZONE_NORMAL that spawns between 0 and 2g, but we have to split
> the GFP_KERNEL allocation place in two zones that are ZONE_DMA
> and ZONE_NORMAL.
> 
> But alloc_pages really have to consider the 0-2g a single zone
> because alloc_pages gets the semantic of the zone by the user
> that consider the 0-2g range a single zone.

It does. If you read mm/page_alloc.c::__alloc_pages()
carefully, you'll see this code fragment which does
exactly that.

        for (;;) {
                zone_t *z = *(zone++);

                /* Are we supposed to free memory? Don't make it worse.. */
                if (!z->zone_wake_kswapd && z->free_pages > z->pages_low) {
                        struct page *page = rmqueue(z, order);
                        if (page)
                                return page;
                }
        }

Here it scans the entire zonelist for each allocation and
allocates from the first zone where we have enough free
pages. This will spead memory load across zones just fine.

> If the current zone based design is not broken, then we can
> split any zone in as _many_ zones as we _want_ without hurting
> anything (except some more CPU and memory resources wasted in
> the zone arrays since there would be more zones).

We can do this just fine. Splitting a box into a dozen more
zones than what we have currently should work just fine,
except for (as you say) higher cpu use by kwapd.

If I get my balancing patch right, most of that disadvantage
should be gone as well. Maybe we *do* want to do this on
bigger SMP boxes so each processor can start out with a
separate zone and check the other zone later to avoid lock
contention?

> This is obviously wrong and this also proof the current design
> is broken.

What's wrong with being able to split memory in arbitrary
zones without running into any kind of performance trouble?

> >I tell you - you are doing the wrong thing. The earlier you realize that,
> >the better.
> 
> Linus, you can convinced me immediatly if you show me how I can
> make sure that all the ZONE_NORMAL is empty before going to
> allocate in the ZONE_DMA with the current design.

[snip]

> As second using 5% and 1% of critical watermarks won't give you a 6%
> watermark for the ZONE_NORMAL _class_zone but it will give you a 1%
> watermark instead and you probably wanted a 6% watermark to provide
> rasonable space for atomic allocations and for having more chances of
> doing high order allocations.

So the 1% watermark for ZONE_NORMAL is too low ... fix that.

> If pages_high would been the 6% and referred to the classzone
> the VM would have immediatly and correctly shrunk an additional
> 5% from the freeable ZONE_NORMAL. See?

I see the situation and I don't see any problem with it.
Could you please explain to us what the problem with this
situation is?

> >I did no tuning at all of the watermarks when I changed the zone
> >behaviour. My bad. But that does NOT mean that the whole mm behaviour
> >should then be reverted to the old and broken setup. It only means that
> >the zone behaviour should be tuned.
> 
> If you'll try to be friendly with ZONE_DMA (by allocating from
> the ZONE_NORMAL when possible) you'll make the allocation from
> the higher zones less reliable and you could end doing a
> differently kind of wrong thing as explained a few lines above.

What's wrong with this?  We obviously need to set the limits
for ZONE_NORMAL to such a number that it's possible to do
higher-order allocations. That is no change from your proposal
and just means that your 1% example value is probably not
feasible. Then again, that's just an example value and has
absolutely nothing to do with the design principles of the
current code.

> >Now, the way =I= propose that this [NUMA] be handled is:
> >
> > - each cluster has its own zone list: cluster 0 has the list 0, 1, 2, 3,
> >   while cluster 1 has the list 1, 2, 3, 0 etc. In short, each of them
> >   preferentially allocate from their _own_ cluster. Together with
> >   cluster-affinity for the processes, this way we can naturally (and with
> >   no artificial code) try to keep cross-cluster memory accesses to
> >   a minimum.
> 
> That have to be done in alloc_pages_node that later will fallback into the
> alloc_pages. This problematic is not relevant for alloc_pages IMVHO.
> 
> In your scenario you'll have only 1 zone per node and there's never been
> any problem with only one zone per node since classzone design is
> completly equal to zone design in such case.
> 
> All zones in a single node by design have to be all near or far in the
> same way to all the cpus since they all belong to the same node.

You may want to do a s/cluster/node/ in Linus' paragraph and
try again, if that makes things more obvious. What you are
saying makes absolutely no sense at all to anybody who knows
how NUMA works. You may want to get a book on computer architecture
(or more sleep, if that was the problem here .. I guess we all have
that every once in a while).

> >And note - the above works _now_ with the current code. And it will never
> >ever work with your approach. Because zone 0 is not a subset of zone 1,
> >they are both equal. It's just that there is a preferential order for
> >allocation depending on who does the allocation.
> 
> IMVHO you put the NUMA stuff in the wrong domain by abusing the zones
> instead of using the proper nodes.

I'm sorry to say this, but you don't seem to understand how NUMA
works... We're talking about preferential memory allocation here
and IMHO the ONLY place to do memory allocation is in the memory
allocator.

> >The fact that you think that this is true obviously means that you haven't
> >thought AT ALL about the ways to just make the watermarks work that way.
> 
> I don't see how playing with the watermarks can help.
> 
> Playing with the watermarks is been my first idea but I
> discarded it immediatly when I seen what would be happened by
> lowering the higher zones watermarks. And also the watermark
> strict per zone doesn't make any sense in first place. You can't
> say how much you should free from ZONE_NORMAL if you don't know
> the state of the lower ZONE_DMA zone.

If there is a lot of free memory in ZONE_DMA, the memory
allocator will do the next allocations there, relieving the
other zones from memory pressure and not freeing pages there
at all. This seems to be _exactly_ what is needed and what
your classzones achieve at a much higher complexity and lower
flexibility...

> >Give it five seconds, and you'll see that the above is _exactly_ what the
> >watermarks control, and _exactly_ by making all the flags per-zone
> >(instead of global or per-class). And by just using the watermark
> 
> IMVO we used the wrong term since the first place. Kanoj wrote a function
> called classzone at 2.3.[345]? time, and so I inherit his 'classzone' name
> in my emails. But what I did is not really a classzone design, but I only
> reconstructed the real _zone_ where GFP_KERNEL wants to allocate from. In
> 2.3.99-pre6-5 the monolithic zone where GFP_KERNEL wants to allocate from,
> it's been broken in two unrelated, disconnected pieces. I only re-joined
> it in once piece since it's a _single_ zone.

Which doesn't make any sense at all since the allocator will do the
balancing between the zones automatically.

> >In short, you've only convinced me _not_ to touch your patches, by showing
> >that you haven't even though about what the current setup really means.
> 
> Note that I have started saying "let's try to give the current
> code better balance since it seems we're calling swap_out two
> more times than necessary"

Indeed, there's a small performance bug in the page freeing code
in the current kernels. The obvious place to fix that is (surprise)
in the page freeing code. The allocation code is fine and has been
for a long time.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
