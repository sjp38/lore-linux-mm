Date: Tue, 20 Jun 2000 19:59:34 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: shrink_mmap() change in ac-21
In-Reply-To: <200006202027.NAA01142@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0006201921510.1314-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Tue, 20 Jun 2000, Linus Torvalds wrote:
> In article <Pine.LNX.4.21.0006201258190.12944-100000@duckman.distro.conectiva>,
> Rik van Riel  <riel@conectiva.com.br> wrote:
> >
> >I didn't know for sure either until I tested -ac21 on my
> >192MB workstation. The bursts kswapd went through when
> >it was freeing DMA memory (and 8MB of other memory) have
> >convinced me that this is not a good idea.
> 
> Note that this is exactly what the zone "goodness" test is
> supposed to avoid.

Indeed, and reinserting the zone goodness test makes the system
perform wonderfully again. It was removed shortly in -ac21 for
unknown reasons.  Removing that test was done by a few people on
IRC when we tried to identify if that was the cause of high
kswapd cpu use on low-memory machines (do_try_to_free_pages would
call shrink_mmap until count reaches 0) and it was never intended
to go into the kernel...

> I suspect that the problem is that the goodness test is wrong.

No, the current zone goodness test is very much ok.

> 	if (page->zone->zone_wake_kswapd)
> 		/* uninteresting page */
> 
> rather than the current test
> 
> 	if (page->zone->free_pages > page->zone->pages_high)
> 		/* uninteresting page */
> 
> Note that once the zone has actually been low on memory, the two
> tests are equivalent:

This is exactly what we need to avoid. If one zone is slightly
loaded and another zone contains a ton of old pages, we want to
free the old pages from the other zone regardless, until we reach
pages_high.

Suppose, as an example, that the normal zone contains a ton of
old pages (but it has not yet reached the low watermark) and we
do a DMA allocation. The DMA allocation wakes up kswapd and the
system tries to free some pages.

In this case we *really* want to free some of the (stone age old)
pages from the normal zone so we'll allocate more pages from that
zone (and, relatively, less pages from the dma zone) until we
wake up kswapd again.

In fact, the high and low watermark (kswapd woken up and going
to sleep) are pretty much the same, modulo time difference. The
hysteresis in the latest kernel is achieved by two effects. One
of them is the kswapd_pause logic in __alloc_pages and the other
is the fact that often the oldest pages in one zone have a
different age (and thus position) than the pages from the other
zone(s). This makes us free "extra" pages from the less loaded
zone and will balance the load between the zones faster (I hope).

> The zone test is _definitely_ needed, because without that test
> we'll deplete zones that have tons of memory and really should
> not be depleted..

*nod*

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
