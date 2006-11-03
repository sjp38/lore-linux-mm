Subject: Re: Page allocator: Single Zone optimizations
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0611021345140.9877@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
	 <20061027190452.6ff86cae.akpm@osdl.org>
	 <Pine.LNX.4.64.0610271907400.10615@schroedinger.engr.sgi.com>
	 <20061027192429.42bb4be4.akpm@osdl.org>
	 <Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com>
	 <20061027214324.4f80e992.akpm@osdl.org>
	 <Pine.LNX.4.64.0610281743260.14058@schroedinger.engr.sgi.com>
	 <20061028180402.7c3e6ad8.akpm@osdl.org>
	 <Pine.LNX.4.64.0610281805280.14100@schroedinger.engr.sgi.com>
	 <4544914F.3000502@yahoo.com.au> <20061101182605.GC27386@skynet.ie>
	 <20061101123451.3fd6cfa4.akpm@osdl.org>
	 <Pine.LNX.4.64.0611012155340.29614@skynet.skynet.ie>
	 <454A2CE5.6080003@shadowen.org>
	 <Pine.LNX.4.64.0611021004270.8098@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0611022053490.27544@skynet.skynet.ie>
	 <Pine.LNX.4.64.0611021345140.9877@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 03 Nov 2006 13:48:05 +0100
Message-Id: <1162558085.26989.17.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-11-02 at 13:52 -0800, Christoph Lameter wrote:
> On Thu, 2 Nov 2006, Mel Gorman wrote:
> 
> > Ok... list-based anti-frag identified three types of pages. From the leading
> > mail;
> > 
> > EasyReclaimable - These are userspace pages that are easily reclaimable. This
> >         flag is set when it is known that the pages will be trivially
> > reclaimed
> >         by writing the page out to swap or syncing with backing storage
> > 
> > KernelReclaimable - These are allocations for some kernel caches that are
> >         reclaimable or allocations that are known to be very short-lived.
> > 
> > KernelNonReclaimable - These are pages that are allocated by the kernel that
> >         are not trivially reclaimed. For example, the memory allocated for a
> >         loaded module would be in this category. By default, allocations are
> >         considered to be of this type
> > 
> > The EasyReclaimable and KernelReclaimable allocations are marked with __GFP
> > flags.
> > 
> > Now, you want to separate pages according to movable and unmovable. Broadly
> > speaking, EasyReclaimable == Movable and
> > KernelReclaimable+KernelNonReclaimable == Non-Movable. However, while
> > KernelReclaimable are Non-Movable, they can be reclaimed by purging caches.
> > So, if we redefined the three terms to be Movable, Reclaimable and
> > Non-Movable, you get the separation you are looking for at least within a
> > MAX_ORDER_NR_PAGES.
> 
> I think talking about reclaim here is not what you want. 

I think it is; all of this only matters at the moment you want to
allocate a large page, at that time you need to reclaim memory to
satisfy the request. (There is some hysteresis between alloc and
reclaim; but lets ignore that for a moment.)

So, the basic operation is reclaim, make it succeed in freeing up the
requested order page (with the least possible disturbance to the rest).

Anti-fragmentation as mel now has it increases the success rate; lumpy
reclaim decreases the collateral damage.

Defrag could contribute to this by moving otherwise un-reclaimable pages
to an lower order free page, so that reclaim of a higher order page can
succeed.

> defragmentation 
> is fundamentally about moving memor not reclaim. Reclaim is a way of 
> evicting pages from memory to avoid the move. This may be useful if memory 
> is filled up because defragging can then do what swapping would have to 
> do. However, evicting pages means that they have to be reread. Page 
> migration can migrate pages at 1GB/sec which is certainly much higher 
> than having to reread the page.

Moving memory about is not the point; although it might come in handy;
its freeing linear chunks of memory without disturbing too much.

> Also I think the reclaim idea breaks down in the following cases:
> 
> 1. An mlocked page. This is a page that is movable but not reclaimable. 
> How does defrag 

NOTE: its anti-fragmentation; not de-fragmentation; the emphasis is on
avoiding fragments; not coalescing them.

> handle that case right now? It should really move the 
> page if necessary.

Sure, defrag or rather move_pages() could be rather useful.

> 2. There are a number of unreclaimable page types that are easily movable.
> F.e. page table pages are movable if you take a write-lock on mmap_sem 
> and handle the tree carefully. These pages again are not reclaimable but 
> they are movable.
> 
> Various caching objects in the slab (cpucache align cache etc) are also 
> easily movable. If we put them into a separate slab cache then we could 
> make them movable.
> 
> Certain Device drivers may be able to shut down intermittendly releasing 
> their memory and reallocating it later. This also may be used to move 
> memory. Memory allocated by such a device driver is movable.

The ability to move pages about that are otherwise unreclaimable does
indeed open up a new class of pages. But moving pages about is not the
main purpose; attaining linear free pages with the least amount of
collateral damage is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
