Date: Tue, 13 Jun 2000 21:09:49 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
In-Reply-To: <yttsnuh8q50.fsf@serpe.mitica>
Message-ID: <Pine.LNX.4.21.0006132026040.6694-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On 13 Jun 2000, Juan J. Quintela wrote:

>>>>>> "andrea" == Andrea Arcangeli <andrea@suse.de> writes:
>
>andrea> You have more kswapd load for sure due the strict zone approch. It maybe
>andrea> not noticeable but it's real. You boot, you allocate all the normal zone
>andrea> in cache doing some fs load, then you start netscape and you allocate the
>andrea> lower 16mbyte of RAM into it, then doing some other thing you trigger
>andrea> kswapd to run because also the lower 16mbyte are been allocated now. Then
>andrea> netscape exists and release all the lower 16m but kswapd keeps shrinking
>andrea> the normal zone (this shouldn't happen and it wouldn't happen with
>andrea> classzone design).
>
>Linus argument is that you should never get _all_ the normal zone
>allocated and nothing of the DMA zone.  You need to balance the
>allocations module the .free_pages, .low_pages etc of each zone....

Of course I was just assuming the Linus's point you raised (I was just
running in my mind plain 2.4.0-test1-ac vm) even if it's irrelevant for
this example (and that's why I didn't focused on the fact there was still
some memory free in the normal zone before going to allocate from the dma
zone). In what I described above I just assumed that _not_ all the normal
zone is been allocated, but that we stopped eating from there as soon as
we triggered the watermark (high/low/min whatever you want, I don't mind).

So far so good. Then you also allocated most of the DMA zone because you
started netscape. As you prefer to point out at this point there was still
"pages_min" pages free in the normal zone.

Then you do some more I/O and allocate some cache, then kswapd triggers to
try to free some memory because all zones are under the watermark. OK?

Then netscape exits and release 10mbyte from the DMA zone _but_ kswapd
continues to shrink the normal zone, why??? -> because the MM doesn't have
enough information in order to do the right thing, that's all.

It's broken, period and you can't fix that behaviour without changing
design and going classzone based. You can say nobody will ever notice it
with only mere three zones, I don't have numbers to say otherwise at this
moment, but it's sure my own kernel will react right to that corner case
too (it may even run slower in the common case but I really don't mind
about performance, I mind about correctness first).

I only mentioned another one of the buggy behaviour that I see. For the
other fact you don't empty the zone_normal before falling back into
zone_dma you all agree it's a feature (while IMHO it's a misefature but
not severe, but ok for now I will also assume that one was a feature to
avoid further flames).

Now I'd like to hear if you consider what I described in these two emails
a feature too. If you consider it a feature I'll just tell you the next
bad behaviour that happens in the LRU aging (and that's not exactly the
problem you are describing below but it's only a little bit more subtle).

>The problem with the actual algorithm is when we have allocated all
>the pages in one zone and all the pages in the LRU list are from a
>different zone.  We need to do some swaping and not write to disk

You don't need to do any swapping! Please read carefully the below stuff:

Assume the DMA zone is filled by cache. Assume the normal zone is allocate
in anonymous and kernel memory (so not in lru).

Then when you release some memory from the DMA zone you _have_ to
understand that you did progress also for the normal zone because you
_did_ progress!!! Now the next alloc_pages(GFP_KERNEL) will succeed
because you have memory free in the DMA zone. Do you agree that you did
some progress or not?

Classzone understands you did progress in the DMA zone and it doesn't
remains stuck trying to free cache from the normal zone. That case is
handled _perfectly_ from ages by the classzone patch and it instead breaks
with the current kernel (both 2.4.0-test1 and latest ac one).

Fixing it by swapping out stuff from the normal zone is even worse. It
just means that you'll start swapping out stuff when you still have around
16mbyte of cache freeable and potentially very old!! See? Only way to fix
this is to change the design of the memory balancing... as I just did with
the classzone patch when I noticed what was going on last month.

At this moment I won't buy the current design and I'll stick with
classzone until somebody will offer me a design solution that handles all
the cases right as classzone does (and I think there's no other way than
what I am just doing however I can't exclude there's a smarter solution so
think about it!). I believe if people would understand what's the current
allocator is doing they wouldn't agree with it either.

I'd love if Rik would do his patch where he splits each zone in NR_CPUS
zones so that the drawbacks that are now in the darkness (because there
are only 2 or 3 zones) would see more light.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
