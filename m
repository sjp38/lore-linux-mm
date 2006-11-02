Date: Thu, 2 Nov 2006 22:37:06 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <Pine.LNX.4.64.0611021345140.9877@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0611022153491.27544@skynet.skynet.ie>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
 <20061027190452.6ff86cae.akpm@osdl.org> <Pine.LNX.4.64.0610271907400.10615@schroedinger.engr.sgi.com>
 <20061027192429.42bb4be4.akpm@osdl.org> <Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com>
 <20061027214324.4f80e992.akpm@osdl.org> <Pine.LNX.4.64.0610281743260.14058@schroedinger.engr.sgi.com>
 <20061028180402.7c3e6ad8.akpm@osdl.org> <Pine.LNX.4.64.0610281805280.14100@schroedinger.engr.sgi.com>
 <4544914F.3000502@yahoo.com.au> <20061101182605.GC27386@skynet.ie>
 <20061101123451.3fd6cfa4.akpm@osdl.org> <Pine.LNX.4.64.0611012155340.29614@skynet.skynet.ie>
 <454A2CE5.6080003@shadowen.org> <Pine.LNX.4.64.0611021004270.8098@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611022053490.27544@skynet.skynet.ie>
 <Pine.LNX.4.64.0611021345140.9877@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Thu, 2 Nov 2006, Christoph Lameter wrote:

> On Thu, 2 Nov 2006, Mel Gorman wrote:
>
>> Ok... list-based anti-frag identified three types of pages. From the leading
>> mail;
>>
>> EasyReclaimable - These are userspace pages that are easily reclaimable. This
>>         flag is set when it is known that the pages will be trivially
>> reclaimed
>>         by writing the page out to swap or syncing with backing storage
>>
>> KernelReclaimable - These are allocations for some kernel caches that are
>>         reclaimable or allocations that are known to be very short-lived.
>>
>> KernelNonReclaimable - These are pages that are allocated by the kernel that
>>         are not trivially reclaimed. For example, the memory allocated for a
>>         loaded module would be in this category. By default, allocations are
>>         considered to be of this type
>>
>> The EasyReclaimable and KernelReclaimable allocations are marked with __GFP
>> flags.
>>
>> Now, you want to separate pages according to movable and unmovable. Broadly
>> speaking, EasyReclaimable == Movable and
>> KernelReclaimable+KernelNonReclaimable == Non-Movable. However, while
>> KernelReclaimable are Non-Movable, they can be reclaimed by purging caches.
>> So, if we redefined the three terms to be Movable, Reclaimable and
>> Non-Movable, you get the separation you are looking for at least within a
>> MAX_ORDER_NR_PAGES.
>
> I think talking about reclaim here is not what you want. defragmentation
> is fundamentally about moving memor not reclaim.

Sure. That is why I called the mechanism anti-fragmentation, not 
defragmentation. However, If reclaimable pages are clustered together, you 
know they are moveable as well. Once the pages are clustered together in 
an intelligent manner, a hypothetical defragmenter would have less work to 
do. Additionally, once the defragmenter starts working, you know it's less 
likely to hit unmovable pages.

> Reclaim is a way of
> evicting pages from memory to avoid the move. This may be useful if memory
> is filled up because defragging can then do what swapping would have to
> do. However, evicting pages means that they have to be reread. Page
> migration can migrate pages at 1GB/sec which is certainly much higher
> than having to reread the page.
>

The reason why anti-frag currently reclaims is because reclaiming was easy 
and happens under memory pressure not because I thought pageout was free. 
As a proof-of-concept, I needed to show that pages clustered on 
reclaimability would free contiguous blocks of pages later. There was no 
point starting with defragmentation when I knew that unmovable pages would 
be with movable pages in the same MAX_ORDER_NR_PAGES block.

> Also I think the reclaim idea breaks down in the following cases:
>
> 1. An mlocked page. This is a page that is movable but not reclaimable.
> How does defrag handle that case right now? It should really move the
> page if necessary.
>

Defrag doesn't exist right now. If anti-frag got some traction, working on 
using page migration to handle movable-but-not-reclaimable pages would be 
the next step. Pages that are mlocked() will have been allocated with 
__GFP_EASYRCLM so will be clustered together with other movable pages.

> 2. There are a number of unreclaimable page types that are easily movable.
> F.e. page table pages are movable if you take a write-lock on mmap_sem
> and handle the tree carefully. These pages again are not reclaimable but
> they are movable.
>

Page tables are currently not allocated with __GFP_EASYRCLM because I knew 
I couldn't reclaim them without killing processes. However, if page 
migration within ranges was implemented, we'd start clustering based on 
movability instead of reclaimability.

> Various caching objects in the slab (cpucache align cache etc) are also
> easily movable. If we put them into a separate slab cache then we could
> make them movable.
>

As subsystems will have pointers to objects within the slab, I doubt they 
are easily movable but I'll take your word on it for the moment.

> Certain Device drivers may be able to shut down intermittendly releasing
> their memory and reallocating it later. This also may be used to move
> memory. Memory allocated by such a device driver is movable.
>

If such a driver existed in the future, their allocations could be marked 
and clustered together with other movable allocations.

> I would suggest to not categorize pages according to their reclaimability
> but according to their movability.

ok, I see your point. However, reclaimability seems a reasonable starting 
point. If I know pages of similar reclaimability are clustered together, I 
can work on using page migration to move pages out of the blocks of known 
reclaimability instead of paging them out. When that works, the __GFP_ 
flags identifying reclaimability can be renamed to marking movability and 
flag page table pages as well. This is a logical progression.

> The decision to evict a page (reclaim)
> is something that may be useful to avoid swap but it may be better to keep
> pages in memory.
>

Agreed, but swapping them out was an easier starting point.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
