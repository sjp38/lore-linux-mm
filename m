Date: Tue, 13 Jun 2000 21:58:39 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
In-Reply-To: <Pine.LNX.4.21.0006140157280.9129-100000@inspiron.random>
Message-ID: <Pine.LNX.4.21.0006132146370.2954-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jun 2000, Andrea Arcangeli wrote:
> On Tue, 13 Jun 2000, Rik van Riel wrote:
> 
> >The infinite loop case is orthagonal to classzone. Please don't
> >try to confuse the issues.
> 
> It isn't! classzone will loop forever only if you are really out
> of memory,

Which is a bug, just the same as this can happen to the zoned design
when we run out of memory in one zone. As I said, orthagonal.

> >No. Kswapd will never get woken up until *all* zones get below
> >zone->pages_low. I fixed this buglet in the -ac patches.
> 
> All zones gone under pages_low. The zone normal gone under the
> watermark due oracle mlocked shm, the other other zone (dma)
> gone down the watermark due the cache that is been allocated
> during I/O.

The zone approach doesn't really use the watermarks in the 2.2
sense. If all zones dive below pages_low, kswapd will free some
memory until all zones get just above pages_low.

We achieve something like the watermarks because we'll free the
pages that are at the end of the LRU list, so if one zone has a
lot of unused pages, we'll have freed up to pages_high memory in
that zone before we get the other zone above pages_low...

> >we should fix it in kswapd, but I don't see how this has anything to
> >do with classzone vs. the zoned approach.
> 
> You can't fix this from kswapd with yet another hack.

Above you wrote that classzone has the exact same problem. If one
(class)zone gets out of memory and contains no freeable memory,
kswapd will enter an infinite loop. In this case there's no
difference between freeing memory from a classzone or a normal zone.

In fact, the bugfix would be the exact *same* for both classzone and
the normal zoned VM.

> >You're right that the current kswapd loop won't terminate and
> >that this is a bug, but it doesn't have anything at all to do
> >with the classzone idea.
> 
> It have to do with the classzone idea, because you shouldn't
> even try to repeat the loop because you should notice that the
> ZONE_NORMAL _classzone_ is not under the watermark because you
> succeeded freeing the cache from the ZONE_DMA.

You're playing with words here. If the cache was allocated before
the mlock()ed memory, classzone would loop forever on trying to
free memory from the DMA zone. There is no fundamental difference
in the manifestation of the bug on either classzone or the normal
VM.

> >Classzone may be a nice abstraction for the current generation
> >of PCs, but it's simply not general enough to cover all corner
> >cases. [..]
> 
> Sorry but your argument is silly. You say that you are not
> covering the corner cases at runtime in a PC used by 90% of
> userbase because you want to support another very alien
> architecture without having to change one bit of code in
> page_alloc.c?

No. I'm saying that the classzone abstraction is not general enough
and we can support all corner cases of usage well without it. In
fact, as I demonstrated above, even your own contorted example will
hang classzone if I only switch the order in which the allocations
happen...

> All the architecture that I know fits in the classzone design,
> but don't worry about that, if there is some future that won't
> fit I will extend the classzone design to support also non
> inclusive zones. I simply avoid to overdesign at this time.

I don't think I can add anything to this. Adding features to
an already complex design to avoid overengineering??

cheers,

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
