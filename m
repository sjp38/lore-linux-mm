Date: Tue, 13 Jun 2000 16:32:14 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
In-Reply-To: <Pine.LNX.4.21.0006132026040.6694-100000@inspiron.random>
Message-ID: <Pine.LNX.4.21.0006131621000.30443-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jun 2000, Andrea Arcangeli wrote:

> Then you do some more I/O and allocate some cache, then kswapd
> triggers to try to free some memory because all zones are under
> the watermark. OK?

Ahhh, but kswapd will *only* trigger the number of pages we
need to reach zone->pages_low (in the latest -ac patches).

> Then netscape exits and release 10mbyte from the DMA zone _but_
> kswapd continues to shrink the normal zone, why??? -> because
> the MM doesn't have enough information in order to do the right
> thing, that's all.

In this case kswapd will only shrink the normal zone *once*.
After the normal zone has reached zone->pages_low, we will:
1) stop freeing pages in zone_normal
2) allocate all new allocations from zone_dma, until that
   zone hits the low watermark as well

I think you're overlooking the fact that kswapd's freeing of
pages is something that occurs only *once*...

> (it may even run slower in the common case but I really don't
> mind about performance, I mind about correctness first).

Ermm, wasn't your motivation for the classzone idea
_performance_??  (at least, that's what I read from
the rest of your email)

> Assume the DMA zone is filled by cache. Assume the normal zone
> is allocate in anonymous and kernel memory (so not in lru).
> 
> Then when you release some memory from the DMA zone you _have_
> to understand that you did progress also for the normal zone
> because you _did_ progress!!!

That's why the new balancing code leaves the area between
zone->pages_low and zone->pages_high as "slack", used to
balance between zones. And when all zones go _just_ below
zone->pages_low, we'll free something from the zones.

If one zone contains more easily freeable memory, we'll free
more pages from that zone before we get the other zone(s)
above zone->pages_low ... and we have the balancing between
zones.

> At this moment I won't buy the current design and I'll stick
> with classzone until somebody will offer me a design solution
> that handles all the cases right as classzone does

I think you may want to read the discussion between Matt Dillon
and me about FreeBSD VM. The main point is that we keep some
pages around which are clean, unmapped and unused. We can reclaim
them at any time.

Since "producing" such pages doesn't mean we have to "throw away"
useful data, we'll have the ability to have one really inactive
zone grow megabytes of these pages without too much overhead, so
we can achieve faster balancing between zones with the benefits of
both classzone and the normal zoned system.

Also, since all inactive pages are equally old and equal candidates
for being evicted from memory, we can chose to delay IO on dirty
pages or spread out IO in a better way. There are all sorts of big
and small optimisations we can make here...

(eg. don't grow the number of scavenge pages in a zone if we don't
need to and it would require IO to do so)

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
