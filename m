Date: Wed, 14 Jun 2000 02:12:43 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
In-Reply-To: <Pine.LNX.4.21.0006132022480.2500-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0006140157280.9129-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jun 2000, Rik van Riel wrote:

>The infinite loop case is orthagonal to classzone. Please don't
>try to confuse the issues.

It isn't! classzone will loop forever only if you are really out of
memory, in the described scenario instead it won't waste any further time
in kswapd because kswapd succeed to shrink some bit from ZONE_DMA.

>> Assume the pages_min of the normal zone watermark triggers when the normal
>> zone is allocated at 95% and assume that all such 95% of the normal zone
>> is been allocated all in mlocked memory and kernel mem_map_t array. Can't
>> somebody (for example an oracle database) allocate 95% of the normal zone
>> in mlocked shm memory? Do you agree? Or you are telling me it can't or
>> that if it does so it should then expect the linux kernel to explode
>> (actually it would cause kswapd to loop forever trying to free the normal
>> zone even if there's still 15mbyte of ZONE_DMA memory free).
>
>No. Kswapd will never get woken up until *all* zones get below
>zone->pages_low. I fixed this buglet in the -ac patches.

All zones gone under pages_low. The zone normal gone under the watermark
due oracle mlocked shm, the other other zone (dma) gone down the watermark
due the cache that is been allocated during I/O.

>> memory. You still have 15mbyte free for the cache in the ZONE_DMA, OK?
>> Then you allocate the 95% of such 15mbyte in the cache and then kswapd
>> triggers and it will never stop because it will try to free the
>> zone_normal forever, even if it just recycled enough memory from the
>> ZONE_DMA (so even if __alloc_pages wouldn't start memory balancing
>> anymore!). See????
>
>No I don't see this. Kswapd will only be woken up when all zones get
>below pages_low. I agree that this corner case can happen and that

all zones gone under pages_low.

>we should fix it in kswapd, but I don't see how this has anything to
>do with classzone vs. the zoned approach.

You can't fix this from kswapd with yet another hack.

>You're right that the current kswapd loop won't terminate and
>that this is a bug, but it doesn't have anything at all to do
>with the classzone idea.

It have to do with the classzone idea, because you shouldn't even try to
repeat the loop because you should notice that the ZONE_NORMAL _classzone_
is not under the watermark because you succeeded freeing the cache from
the ZONE_DMA.

>Except when the zones are not inclusive. You may want to check
>out the docs on the new POWER4 beasts from IBM. They have 4

If it's a power4beast I also hope it won't need any zone in first place
just like on a alpha, we have more then one zone only because some
hardware is been designed in the very past.

>Classzone may be a nice abstraction for the current generation
>of PCs, but it's simply not general enough to cover all corner
>cases. [..]

Sorry but your argument is silly. You say that you are not covering the
corner cases at runtime in a PC used by 90% of userbase because you want
to support another very alien architecture without having to change one
bit of code in page_alloc.c?

All the architecture that I know fits in the classzone design, but don't
worry about that, if there is some future that won't fit I will extend the
classzone design to support also non inclusive zones. I simply avoid to
overdesign at this time.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
