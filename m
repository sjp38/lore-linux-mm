Message-ID: <454B4185.3040302@shadowen.org>
Date: Fri, 03 Nov 2006 13:17:57 +0000
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: Page allocator: Single Zone optimizations
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0610271907400.10615@schroedinger.engr.sgi.com> <20061027192429.42bb4be4.akpm@osdl.org> <Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com> <20061027214324.4f80e992.akpm@osdl.org> <Pine.LNX.4.64.0610281743260.14058@schroedinger.engr.sgi.com> <20061028180402.7c3e6ad8.akpm@osdl.org> <Pine.LNX.4.64.0610281805280.14100@schroedinger.engr.sgi.com> <4544914F.3000502@yahoo.com.au> <20061101182605.GC27386@skynet.ie> <20061101123451.3fd6cfa4.akpm@osdl.org> <Pine.LNX.4.64.0611012155340.29614@skynet.skynet.ie> <454A2CE5.6080003@shadowen.org> <Pine.LNX.4.64.0611021004270.8098@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0611022053490.27544@skynet.skynet.ie> <Pine.LNX.4.64.0611021345140.9877@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0611022153491.27544@skynet.skynet.ie> <Pine.LNX.4.64.0611021442210.10447@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0611030900480.9787@skynet.skynet.ie>
In-Reply-To: <Pine.LNX.4.64.0611030900480.9787@skynet.skynet.ie>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

>> An intemediate step that would make sense is starting to
>> marking pages as unmovable and then reclaim movable pages. Then we can
>> add
>> more and more logic to make move pages movable on top. With marking
>> pages for reclaim we wont get there.
>>
> 
> Ok, I can make that renaming change now so. The renaming will look like
> 
> Movable - These are userspace pages that are easily moved. This
>         flag is set when it is known that the pages will be trivially
>     moved by using page migration or if under significant
>     memory pressure, writing the page out to swap or syncing with
>     backing storage
>     These allocations are marked with __GFP_MOVABLE
> 
> Reclaimable - These are kernel allocations for caches that are
>         reclaimable or allocations that are known to be very short-lived.
>     These allocations are marked __GFP_RECLAIMABLE
> 
> Non-Movable - These are pages that are allocated by the kernel that
>         are not trivially reclaimed. For example, the memory allocated
> for a
>         loaded module would be in this category. By default, allocations
> are
>         considered to be of this type
>     These are allocations that are not marked otherwise
> 
> So, right now, page tables would not be marked __GFP_MOVABLE, but they
> would be later when defrag was developed. Would that be any better?

Ok, as far as I can tell you are both describing the same basic thing
with different names.

The key problem here is we want to be able to allocate non-order zero
pages, where there are such pages available all is well.  When there are
not we need to look for a group of contiguous 'emptyable' pages; and
recycle them.  This is the key, we do not care what is in them, only
whether we can get whatever it is out to release a single contiguous
block.  We do not care what the mechanism for that is, release, move or
even swap them.  The attribute of the memory is whether its pinned or
not, whether the page is emptyable.  We want to make sure we keep
emptyable pages with other emptyable pages so that our chances of
finding a higher order block emptyable is likely.

We currently talk about the act of selecting pages for release as
reclaim.  We should not get too caught up in thinking of that as
removing things from memory.  Yes, right now the only time we use
reclaim is when we do not have any free memory, and so its only goal is
to remove things from memory -- that is a side effect of it only
supporting order 0 reclaim, moving a page there is mostly useless.
Supporting higher order reclaim we might start reclaim at order 1 with
50% of memory free.  In this case the reclaim strategy could and should
include the option to relocate the relocatable memory object.

Now perhaps 'EMPTYABLE', 'RELEASABLE' or 'RECYCLABLE' is more
appropriate than 'RECLAIMABLE', but its not at all clear that 'MOVABLE'
is better.  Moving pages is but one strategy 'reclaim' could use to
achieve its aim, getting us the memory block we asked for.

I do not see how any of what Mel is saying precludes the use of
migration as a reclaim mechanism allowing more things to be placed in
the 'emptyable' set rather than the 'pinned' set.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
