Date: Tue, 13 Jun 2000 23:49:19 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
In-Reply-To: <Pine.LNX.4.21.0006131611350.30443-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0006132319560.7792-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jun 2000, Rik van Riel wrote:

>On Tue, 13 Jun 2000, Andrea Arcangeli wrote:
>> On Mon, 12 Jun 2000, Stephen C. Tweedie wrote:
>> 
>> >Nice --- it might also explain some of the excessive kswap CPU 
>> >utilisation we've seen reported now and again.
>> 
>> You have more kswapd load for sure due the strict zone approch.
>> It maybe not noticeable but it's real.
>
>Theoretically it's real, but having a certain number of free pages
>around in the normal zone so we can do eg. process struct allocations
>and slab allocations from there is well worth it. You may want to
>closely re-read Linus' response to your classzone proposal some
>weeks ago.

I read all Linus's reply and I'm not missing anything.

>> I think Linus's argument about the above scenario is simply that
>> the above isn't going to happen very often, but how can I ignore
>> this broken behaviour? I hate code that works in the common case
>> but that have drawbacks in the corner case.
>
>Let me summarise the drawbacks of classzone and the strict zone
>approach:
>
>Strict zone approach:
>- use slightly more memory, on the order of maybe 1 or 2%
>- use slightly more kswapd cpu time since the free page goals
>  are stricter
>
>Classzone:
>- can easily run out of 2- and 4-page contiguous areas of
>  free memory in the normal zone, leading to the need to
>  do allocation of task_structs and most slab caches from
>  the dma zone

This is a very very red herring. Take 2.4.0-test1-aclatest and assume you
do some I/O and you fill all the normal zone (except the latest pages_min
of course) in the cache. Then you fork a task and you fallback in the DMA
zone that is completly free and the memory for the task_struct got
allocated from the DMA zone also with your design!

Also the memory you take free from the normal zone for this purpose is at
max pages_high-pages_min that is very low margin that you can trivially
throw away if you are doing some I/O and you happen to allocate it from
the cache. Then you won't have any margin anymore and you'll allocate all
the persistent stuff from the zone DMA.

>- this in turn will lead to the dma zone being less reliable
>  when we need to allocate dma pages, [..]

Previous point was wrong and that can happen also with current kernel. The
fact is that the kernel memory currently can't be relocated and thus you
can't do anything to solve this problem except to avoid to allocate there
anything that can't be relocated and then you could fail kernel
allocations even if you still have 16mbyte of free ram.

>  [..] or to a fork() failing
>  with out of memory once we have a lot of processes on very
>  big systems

What the fork have to do with this issue? classzone patch will take enough
memory free in the classzone so that it's likely there are two contigous
pages thus this point is completly irrelevant with regard to
zone/classzone design.

>Here you'll see that both systems have their advantages and
>disadvantages. The zoned approach has a few (minimal) performance

As far I can tell the only disavantage of classzone is that the spinlock
have to be per-node and you have to keep collected the information about
the classzone while allocating and freeing the pages.

>disadvantages while classzone has a few stability disadvantages.

IMHO it's the opposite. Classzone provides the correct behaviour but at a
potentially major fixed cost during allocations/deallocations and the lock
is not per-zone anymore. However this additional information that we
collect we'll avoid us to waste CPU and memory so it's not obvious that
classzone will decrease performance.

>Personally I'd chose stability over performance any day, but that's
>just me.

I fully agree and that's why I developed classzone in first place.

>The big gains in classzone are most likely from the _other_ changes
>that are somewhere inside the classzone patch. If we focus on

Indeed.

>merging some of those (and maybe even improving some of the others
>before merging), we can have a 2.4 which performs as good as or
>better than the current classzone code but without the drawbacks.

IMHO it's the current kernel that have the drawbacks. Classzone is the
_fixes_ for the drawbacks.

For the other improvments I agree they are completly orthogonal and I
agree to split them and to discuss separately. I have not mentioned in
these emails infact. I'm only concerned about the zone design at this
moment.

>Oh, btw, the classzone patch is vulnerable to the infinite-loop
>in shrink_mmap too. Imagine a page shortage in the dma zone but
>having only zone_normal pages on the lru queue ...
>(and since the zone_normal classzone already has enough free pages,
>shrink_mmap will find itself looping forever searching for freeable
>zone_dma pages which aren't there)

You're obviously wrong that can't happen with classzone! I intentionally
always put the pages outside the memclass into a dispose list so I simply
can't lockup there and the code there in classzone is rock solid. Here the
code from 2.4.0-test1-ac7-classzone-31:filemap.c:shrink_mmap():

	while (count > 0 && (page_lru = lru_head->prev) != lru_head) {
		page = list_entry(page_lru, struct page, lru);
		list_del(page_lru);

		dispose = &old;
		^^^^^^^^^^^^^^
		/* don't account passes over not DMA pages */
		if (!memclass(page->zone, zone))
			goto dispose_continue;

		count--;

It doesn't matter at all if I do count-- after going to the
dispose_continue and that's not a bug it's intentional and the count--
have to stay after the check for the memclass to provide shrink_mmap
enough power for shrinking the interesting classzones.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
