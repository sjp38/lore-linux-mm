Message-ID: <43E80F36.8020209@yahoo.com.au>
Date: Tue, 07 Feb 2006 14:08:38 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: implement swap prefetching
References: <200602071028.30721.kernel@kolivas.org>
In-Reply-To: <200602071028.30721.kernel@kolivas.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

Con Kolivas wrote:
> Andrew et al
> 
> I'm resubmitting the swap prefetching patch for inclusion in -mm and hopefully
> mainline. After you removed it from -mm there were some people that described
> the benefits it afforded their workloads. -mm being ever so slightly quieter
> at the moment please reconsider.
> 

I have a few comments.

prefetch_get_page is doing funny things with zones and nodes / zonelists
(eg. 'We don't prefetch into DMA' meaning something like 'this only works
on i386 and x86-64').

buffered_rmqueue, zone_statistics, etc really should to stay static to
page_alloc.

It is completely non NUMA or cpuset-aware so it will likely allocate memory
in the wrong node, and will cause cpuset tasks that have their memory swapped
out to get it swapped in again on other parts of the machine (ie. breaks
cpuset's memory partitioning stuff).

It introduces global cacheline bouncing in pagecache allocation and removal
and page reclaim paths, also low watermark failure is quite common in normal
operation, so that is another global cacheline write in page allocation path.

Why bother with the trylocks? On many architectures they'll RMW the cacheline
anyway, so scalability isn't going to be much improved (or do you see big
lock contention?)

Aside from those issues, I think the idea has is pretty cool... but there are
a few things that get to me:

- it is far more common to reclaim pages from other mappings (not swap).
   Shouldn't they have the same treatment? Would that be more worthwhile?

- when is a system _really_ idle? what if we want it to stay idle (eg.
   laptops)? what if some block devices or swap devices are busy, or
   memory is continually being allocated and freed and/or pagecache is
   being created and truncated but we still want to prefetch?

- for all its efforts, it will still interact with page reclaim by
   putting pages on the LRU and causing them to be cycled.

   - on bursty loads, this cycling could happen a bit. and more reads on
     the swap devices.

- in a sense it papers over page reclaim problems that shouldn't be so
   bad in the first place (midnight cron). On the other hand, I can see
   how it solves this issue nicely.


> Cheers,
> Con
> ---
> This patch implements swap prefetching when the vm is relatively idle and
> there is free ram available. The code is based on some early work by Thomas
> Schlichter.
> 

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
