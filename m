Date: Wed, 14 Jun 2000 01:07:23 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
In-Reply-To: <Pine.LNX.4.21.0006131621000.30443-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0006132355560.7792-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jun 2000, Rik van Riel wrote:

>On Tue, 13 Jun 2000, Andrea Arcangeli wrote:
>
>> Then you do some more I/O and allocate some cache, then kswapd
>> triggers to try to free some memory because all zones are under
>> the watermark. OK?
>
>Ahhh, but kswapd will *only* trigger the number of pages we
>need to reach zone->pages_low (in the latest -ac patches).

Who said otherwise? It will trigger for freeing pages_low-pages_min. Just
the gap between the two watermarks you prefer.

>> Then netscape exits and release 10mbyte from the DMA zone _but_
>> kswapd continues to shrink the normal zone, why??? -> because
>> the MM doesn't have enough information in order to do the right
>> thing, that's all.
>
>In this case kswapd will only shrink the normal zone *once*.

How can you be sure of that? So I'll make you an obvious case where
it will shrink not twice, not three times but _forever_.

Assume the pages_min of the normal zone watermark triggers when the normal
zone is allocated at 95% and assume that all such 95% of the normal zone
is been allocated all in mlocked memory and kernel mem_map_t array. Can't
somebody (for example an oracle database) allocate 95% of the normal zone
in mlocked shm memory? Do you agree? Or you are telling me it can't or
that if it does so it should then expect the linux kernel to explode
(actually it would cause kswapd to loop forever trying to free the normal
zone even if there's still 15mbyte of ZONE_DMA memory free).

So let's make the whole picture from the start starting with all the
memory free: assume oracle allocates all the normal zone in shm mlocked
memory. You still have 15mbyte free for the cache in the ZONE_DMA, OK?
Then you allocate the 95% of such 15mbyte in the cache and then kswapd
triggers and it will never stop because it will try to free the
zone_normal forever, even if it just recycled enough memory from the
ZONE_DMA (so even if __alloc_pages wouldn't start memory balancing
anymore!). See????

The classzone patch will fix the above bad behaviour completly because
kswapd in classzone will notice that there's enough memory for allocation
from both ZONE_DMA and ZONE_NORMAL because the cache in the ZONE_DMA is
been recycled successfully.

Without classzone you'll always get the above case wrong and I don't mind
if it's a corner case or not, we have to handle it right! I will hate a
kernel that works fine only as far as you only compile kernels on it.

>After the normal zone has reached zone->pages_low, we will:

The normal zone will never reach pages_low because all that is
allocated in the normal zone is mlocked userspace shm memory.

>I think you're overlooking the fact that kswapd's freeing of
>pages is something that occurs only *once*...

Since the normal zone will never return over pages_low it will run more
than once.

>> (it may even run slower in the common case but I really don't
>> mind about performance, I mind about correctness first).
>
>Ermm, wasn't your motivation for the classzone idea
>_performance_??  (at least, that's what I read from
>the rest of your email)

My argument of the classzone design is to get correctness in the corner
case: to fix the drawbacks.

Then I also included into such patch some performance stuff and that's why
it also improve performances siginficantly but I'm not interested about
such part for now. Since such part is stable as well you can get both
correctness and improvement at the same time but I can drop the
performance part if there will be an interest only on the other part.

I believe the very classzone part (the design change in the page_alloc.c)
isn't going to make visible performance changes in the common case but it
simply allow to get the corner case right.

I don't mind about the other part of the email at this moment, I only mind
about the global design of the allocator at this moment.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
