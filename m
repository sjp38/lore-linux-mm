Date: Tue, 21 Mar 2000 02:20:53 +0100
From: Jamie Lokier <jamie.lokier@cern.ch>
Subject: madvise (MADV_FREE)
Message-ID: <20000321022053.A4271@pcep-jamie.cern.ch>
References: <20000320135939.A3390@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003201318050.23474-100000@funky.monkey.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.BSO.4.10.10003201318050.23474-100000@funky.monkey.org>; from Chuck Lever on Mon, Mar 20, 2000 at 02:09:26PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Chuck

About MADV_FREE
---------------

> >    The principle here is very simple: MADV_FREE marks all the pages in
> >    the region as "discardable", and clears the accessed and dirty bits
> >    of those pages.
> > 
> >    Later when the kernel needs to free some memory, it is permitted to
> >    free "discardable" pages immediately provided they are still not
> >    accessed or dirty.  When vmscan is clearing the accessed and dirty
> >    bits on pages, if they were set it must clear the " discardable" bit.
> > 
> >    This allows malloc() and other user space allocators to free pages
> >    back to the system.  Unlike DU's MADV_DONTNEED, or mmapping
> >    /dev/zero, if the system does not need the page there is no
> >    inefficient zero-copy.  If there was, malloc() would be better off
> >    not bothering to return the pages.
> 
> unless i've completely misunderstood what you are proposing, this is what
> MADV_DONTNEED does today,

No, your MADV_DONTNEED _always_ discards the data in those pages.  That
makes it too inefficient for application memory allocators, because they
will often want to reuse some of the pages soon after.  You don't want
redundant page zeroing, and you don't want to give up memory which is
still nice and warm in the CPU's cache.  Unless the kernel has a better
use for it than you.

MADV_FREE on the other hand simply permits the kernel to reclaim those
pages, if it is under memory pressure.

If there is no pressure, the pages are reused by the application
unchanged.  In this way different subsystems competing for memory get to
share it out -- essentially the fairness mechanisms in the kernel are
extending to application page management.  And the application hardly
knows a think about it.

Here's why MADV_FREE works, and the other things don't:

A typical memory allocator creates holes in its heap, which the kernel
has to swap out if it needs memory.  I guess about 1/4 of all data in
swap is this kind of junk (but it's just a guess).

But it's quite inefficient for an allocator to unconditionally give
pages back to the kernel.  The cost-benefit is "cost of giving page to
kernel" vs. "cost of maybe paging out".  The cost of giving up
pages is significant: each one implies a COW fault, clear_page
when you reuse the page, and loss of cache-warm memory.

You assume a page is not likely to swap, because there's a reasonable
chance the application will reallocate it before that happens.  So on
balance, giving pages unconditionally to the kernel is a loss.

--> No sane free(3) would call MADV_DONTNEED or msync(MS_INVALIDATE).

A better application allocator would base decisions about when to return
pages to the kernel on the likelihood of swapping and measured cost of
swapping vs. retaining pages.  Of course that's very difficult and
system specific.  And really only the kernel has access to all the
information on memory pressure.

So the best arrangment is to let the kernel make page reclamation
decisions.  And if a page is not reclaimed before it is reused, let the
application reuse the page unchanged and cache-warm.

MADV_FREE is the mechanism for doing that.  And it's a very nice, simple
one to use.  Paging decisions stay in the kernel where they belong.
Applications run fast if they have enough memory.  Everything is happy.

> ... except it doesn't schedule the "freed" pages for
> disposal ahead of other pages in the system.  but that should be easy
> enough to add once the semantics are nailed down and the bugs have been
> eliminated.

It's not clear you'd want to do that.  There is a cost for every "freed"
page disposed of, so you don't want to dispose of them ahead of other
pages.

> ok, i don't understand why you think this.  and besides, free(3) doesn't
> shrink the heap currently, i believe.  this would work if free(3) used
> sbrk() to shrink the heap in an intelligent fashion, freeing kernel VM
> resources along the way.  if you want something to help free(3), i would
> favor this design instead.

free(3) already uses sbrk() to shrink the heap at the end.  It's not
usable for the typical 1/3 of memory which becomes holes in the heap.

Yes the idea is to modify free(3) to permit the kernel to reclaim memory
that is free in the application.  However, none of sbrk() _or_
MADV_DONTNEED _or_ MADV_ZERO _or_ mmap(/dev/zero) have the desired
effect.

It has to be a win for the application to call this function -- and it
it's a loss to zero pages as soon as you free them.  But it's relatively
cheap to just mark the pages as "reclaimable" without losing them.

enjoy,
-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
