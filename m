Date: Tue, 25 Apr 2000 09:57:13 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 2.3.x mem balancing
In-Reply-To: <Pine.LNX.4.21.0004250401520.4898-100000@alpha.random>
Message-ID: <Pine.LNX.4.10.10004250932570.750-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 25 Apr 2000, Andrea Arcangeli wrote:
> 
> The design I'm using is infact that each zone know about each other, each
> zone have a free_pages and a classzone_free_pages. The additional
> classzone_free_pages gives us the information about the free pages on the
> classzone and it's also inclusve of the free_pages of all the lower zones.

AND WHAT ABOUT SETUPS WHERE THERE ISNO INCLUSION?

Andrea, face it, the design is WRONG!

You've made both free_pages() and alloc_pages() more complex and costly,
and the per-zone spinlock cannot exist any more. WHICH IS BAD BAD BAD.

Thing of the case of a NUMA architecture - you sure as hell want to have
all "local" zones share the same spinlock, because then you'll have to
grab a global spinlock for each allocation, even if you only allocate from
a local zone closeto the node you're actually running on.

I tell you - you are doing the wrong thing. The earlier you realize that,
the better.

> >> Now assume rest of memory zone (ZONE_NORMAL) is getting under the
> >> zone_normal->page_low watermark. We must definitely not start kswapd if
> >> there are still 16mbyte of free memory in the classzone.
> >
> >No.
> >
> >We should just not allocate from that zone. Look at what
> >__get_free_pages() does: it tries to first find _any_ zone that it can
> >allocate from, and if it cannot find such a zone only _then_ does it
> >decide to start kswapd.
> 
> Woops I did wrong example to explain the suprious kswapd run and I also
> didn't explained the real problem in that scenario.
> 
> The real problem in that scenario is that you don't empty the ZONE_NORMAL
> but you stop at the low watermark, while you should empty the ZONE_NORMAL
> complelty for allocation that supports ZONE_NORMAL memory (so for non
> ISA_DMA memory) before falling back into the ZONE_DMA zone.

Oh?

And what is wrong with just changing the water-marks, instead of your
global (and in my opinion stupid and wrong) change?

Why didn't you just do a small little initialization routine that made the
watermark for the DMA zone go up, and the watermark for the bigger zones
go down?

Let's face it, with the current Linux per-zone memory allocation, doing
things like that is _trivial_. There are no magic couplings between
different zones, so if you want to make sure that it's primarily only the
DMA zone that is kept free, then you can do _exactly_ that by saying
simply that the "critical watermark for the DMA zone should be 5%, while
the critical watermark for the regular zone should be just 1%".

I did no tuning at all of the watermarks when I changed the zone
behaviour. My bad. But that does NOT mean that the whole mm behaviour
should then be reverted to the old and broken setup. It only means that
the zone behaviour should be tuned.

> You can't
> optimize the zone usage without knowledge on the whole classzone. That's
> the first basic thing where the strict zone based design will be always
> inferior compared to a classzone based design.

You are wrong. And you are so FUNDAMENTALLY wrong that I'm at a loss to
even explain why.

What's the matter with just realizing that the whole issue of DMA vs
non-DMA, and local zone vs remote zone is just a very generic case of
trying to balance memory usage. It has nothing at all to do with
"inclusion", and I personally think that the whole notion of "inclusion"
is fundamentally flawed. It adds a rule that shouldn't be there, and has
no meaning.

Andrea, how do you ever propose to handle the case of four different
memory zones, all "equal", but all separate in that while all of memory
isaccessible from each CPU, each zone is "closer" to certain CPU's? Let's
say that CPU's 0-3 have direct access to zone 0, CPU's 4-7 have direct
access to zone 1, etc etc.. Whenever a CPU touches memory on a non-local
zone, it takes longer for the cache miss, but it still works.

Now, the way =I= propose that this be handled is:

 - each cluster has its own zone list: cluster 0 has the list 0, 1, 2, 3,
   while cluster 1 has the list 1, 2, 3, 0 etc. In short, each of them
   preferentially allocate from their _own_ cluster. Together with
   cluster-affinity for the processes, this way we can naturally (and with
   no artificial code) try to keep cross-cluster memory accesses to
   a minimum.

And note - the above works _now_ with the current code. And it will never
ever work with your approach. Because zone 0 is not a subset of zone 1,
they are both equal. It's just that there is a preferential order for
allocation depending on who does the allocation.

> About kswapd suppose we were low on memory on both the two zones and so we
> started kswapd on both zones and we keep allocating waiting to reach the
> min watermark. Then while kswapd it's running a process exits and release
> all the first 16mbyte of RAM. kswapd correctly stops freeing the ISADMA
> zone (because free_pages set zone_wake_kswapd back to zero) but kswapd
> will keep freeing the normal zone for no good reason. You have no way to
> stop the wrong kswapd in such scenario without a classzone design. If you
> keep looking only at zone->free_pages and zone->pages_high then kswapd
> will keep running for no good reason.

The fact that you think that this is true obviously means that you haven't
thought AT ALL about the ways to just make the watermarks work that way.

Give it five seconds, and you'll see that the above is _exactly_ what the
watermarks control, and _exactly_ by making all the flags per-zone
(instead of global or per-class). And by just using the watermark
heuristics to determine which zone to use for new allocations too, you get
into a situation where you can always say "this zone is currently the best
for new allocations, and these other zones are being free'd up because
they are getting low on memory".

In short, you've only convinced me _not_ to touch your patches, by showing
that you haven't even though about what the current setup really means.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
