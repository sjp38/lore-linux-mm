Date: Tue, 13 Jun 2000 20:34:30 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
In-Reply-To: <Pine.LNX.4.21.0006132355560.7792-100000@inspiron.random>
Message-ID: <Pine.LNX.4.21.0006132022480.2500-100000@duckman.distro.conectiva>
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
> >> Then netscape exits and release 10mbyte from the DMA zone _but_
> >> kswapd continues to shrink the normal zone, why??? -> because
> >> the MM doesn't have enough information in order to do the right
> >> thing, that's all.
> >
> >In this case kswapd will only shrink the normal zone *once*.
> 
> How can you be sure of that? So I'll make you an obvious case where
> it will shrink not twice, not three times but _forever_.

The infinite loop case is orthagonal to classzone. Please don't
try to confuse the issues.

> Assume the pages_min of the normal zone watermark triggers when the normal
> zone is allocated at 95% and assume that all such 95% of the normal zone
> is been allocated all in mlocked memory and kernel mem_map_t array. Can't
> somebody (for example an oracle database) allocate 95% of the normal zone
> in mlocked shm memory? Do you agree? Or you are telling me it can't or
> that if it does so it should then expect the linux kernel to explode
> (actually it would cause kswapd to loop forever trying to free the normal
> zone even if there's still 15mbyte of ZONE_DMA memory free).

No. Kswapd will never get woken up until *all* zones get below
zone->pages_low. I fixed this buglet in the -ac patches.

> memory. You still have 15mbyte free for the cache in the ZONE_DMA, OK?
> Then you allocate the 95% of such 15mbyte in the cache and then kswapd
> triggers and it will never stop because it will try to free the
> zone_normal forever, even if it just recycled enough memory from the
> ZONE_DMA (so even if __alloc_pages wouldn't start memory balancing
> anymore!). See????

No I don't see this. Kswapd will only be woken up when all zones get
below pages_low. I agree that this corner case can happen and that
we should fix it in kswapd, but I don't see how this has anything to
do with classzone vs. the zoned approach.

> >I think you're overlooking the fact that kswapd's freeing of
> >pages is something that occurs only *once*...
> 
> Since the normal zone will never return over pages_low it will
> run more than once.

You're right that the current kswapd loop won't terminate and
that this is a bug, but it doesn't have anything at all to do
with the classzone idea.

> I believe the very classzone part (the design change in the
> page_alloc.c) isn't going to make visible performance changes in
> the common case but it simply allow to get the corner case
> right.

Except when the zones are not inclusive. You may want to check
out the docs on the new POWER4 beasts from IBM. They have 4
dual-cpu dies in one package, with fast interconnects between
the dies, but one memory but and one IO bus directly attached
to each die.

This way you'll end up with something halfway between NUMA and
SMP (nUMA?), and the zone lists are still complementory, but no
longer inclusive ...

Classzone may be a nice abstraction for the current generation
of PCs, but it's simply not general enough to cover all corner
cases. Also, the gain of classzone over a correctly implemented
zoned VM should be absolutely negligable (if it exists at all).

> I don't mind about the other part of the email at this moment, I
> only mind about the global design of the allocator at this
> moment.

Then please look at the allocator code in -ac18 and not at the
one in Linus his kernel...

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
