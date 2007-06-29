Message-ID: <46845E68.9070508@redhat.com>
Date: Thu, 28 Jun 2007 21:20:40 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01 of 16] remove nr_scan_inactive/active
References: <8e38f7656968417dfee0.1181332979@v2.random>	<466C36AE.3000101@redhat.com>	<20070610181700.GC7443@v2.random>	<46814829.8090808@redhat.com>	<20070626105541.cd82c940.akpm@linux-foundation.org>	<468439E8.4040606@redhat.com>	<20070628155715.49d051c9.akpm@linux-foundation.org>	<46843E65.3020008@redhat.com>	<20070628161350.5ce20202.akpm@linux-foundation.org>	<4684415D.1060700@redhat.com>	<20070628162936.9e78168d.akpm@linux-foundation.org>	<46844B83.20901@redhat.com>	<20070628171922.2c1bd91f.akpm@linux-foundation.org>	<46845620.6020906@redhat.com> <20070628181238.372828fa.akpm@linux-foundation.org>
In-Reply-To: <20070628181238.372828fa.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 28 Jun 2007 20:45:20 -0400
> Rik van Riel <riel@redhat.com> wrote:
> 
>>>> The only problem with this is that anonymous
>>>> pages could be easily pushed out of memory by
>>>> the page cache, because the page cache has
>>>> totally different locality of reference.
>>> I don't immediately see why we need to change the fundamental aging design
>>> at all.   The problems afacit are
>>>
>>> a) that huge burst of activity when we hit pages_high and
>>>
>>> b) the fact that this huge burst happens on lots of CPUs at the same time.
>>>
>>> And balancing the LRUs _prior_ to hitting pages_high can address both
>>> problems?
>> That may work on systems with up to a few GB of memory,
>> but customers are already rolling out systems with 256GB
>> of RAM for general purpose use, that's 64 million pages!
>>
>> Even doing a background scan on that many pages will take
>> insane amounts of CPU time.
>>
>> In a few years, they will be deploying systems with 1TB
>> of memory and throwing random workloads at them.
> 
> I don't see how the amount of memory changes anything here: if there are
> more pages, more work needs to be done regardless of when we do it.
> 
> Still confused.

If we deactivate some of the active pages regardless of
whether or not they were recently referenced, you end
up with "hey, I need to deactivate 1GB worth of pages",
instead of with "I need to scan through 1TB worth of
pages to find 1GB of not recently accessed ones".

Note that is the exact same argument used against the
used-once cleanups that have been proposed in the past:
it is more work to scan through the whole list than to
have pages end up in a "reclaimable" state by default.

> But the problem with the vfs caches is that they aren't node/zone-specific.
> We wouldn't want to get into the situation where 1023 CPUs are twiddling
> thumbs waiting for one CPU to free stuff up (or less extreme variants of
> this).

The direct reclaimers can free something else.  Chances are they
don't care about the little bit of memory coming out of these
caches.

We just need to make sure the pressure gets evened out later.

>> Maybe direct reclaim processes should not dive into this cache
>> at all, but simply increase some variable indicating that kswapd
>> might want to prune some extra pages from this cache on its next
>> run?
> 
> Tell the node's kswapd to go off and do VFS reclaim while the CPUs on that
> node wait for it?  That would help I guess, but those thousand processes
> would still need to block _somewhere_ waiting for the memory to come back.

Not for the VFS memory.  They can just recycle some page cache
memory or start IO on anonymous memory going into swap.

> So what we could do here is to back off when iprune_mutex is busy and, if
> nothing else works out, block in congestion_wait() (which is becoming
> increasingly misnamed).  Then, add some more smarts to congestion_wait():
> deliver a wakeup when "enough" memory got freed from the VFS caches.

Yeah, that sounds doable.  Not sure if they should wait in
congestion_wait() though, or if they should just return
to __alloc_pages() since they may already have reclaimed
enough pages from the anonymous list.

> But for now, the question is: is this a reasonable overall design?  Back
> off from contention points, block at the top-level, polling for allocatable
> memory to turn up?

I'm not convinced.  If we have already reclaimed some
pages from the inactive list, why wait in congestion_wait()
AT ALL?

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
