Date: Fri, 24 Mar 2000 01:00:31 +0100
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: /dev/recycle
Message-ID: <20000324010031.B20140@pcep-jamie.cern.ch>
References: <20000322233147.A31795@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003231332080.20600-100000@funky.monkey.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.BSO.4.10.10003231332080.20600-100000@funky.monkey.org>; from Chuck Lever on Thu, Mar 23, 2000 at 01:53:22PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This discussion needs to split into two: one about memory allocators
responding to overall system memory pressure, and another about
applications cacheing recomputable objects, which also want to respond
to system memory pressure.pa

The issues are different and the requirements are different.
Perhaps trying to use the name MADV_FREE to cover them both is just
confusing.

For the record, I'm going to talk about memory allocators, and the
subject has changed to reflect that.

So hi Chuck!  I've thought of something maybe better than MADV_FREE for
memory allocators.  It's neat, it's simple, it's cute...  But first I'll
explain MADV_FREE a bit more.

Chuck Lever wrote:
> > MADV_FREE only discards private modifications when there is paging
> > pressure to do so.  The decisions to do so are deferred, for
> > architectures that support this.  (Includes x86).
> 
> i still don't see a big difference.  the private modifications, in both
> cases, won't be written to swap.  in both cases, the application cannot
> rely on the contents of these pages after the madvise call.

Correct.  The difference is that with MADV_FREE, clear_page() operations
are skipped when there's no memory pressure from the kernel.

> for private mappings, pages are freed immediately by DONTNEED; FREE will
> cause the pages to be freed later if the system is low on memory.  that's
> six of one, half dozen of the other.  freeing later may mean the
> application saves a little time now,

It may save the time overall -- if the page is next reused by the
application before the kernel recycles it.  Note that nobody, neither
the application nor the kernel, knows in advance if this will be the
case.

> but freeing immediately could mean postponing a low memory scenario,
> and would allow the system to reuse a page that is still in hardware
> caches.

The system is free to reuse MADV_FREE pages immediately if it wishes --
the system doesn't lose here.  In fact if you're already low on memory
at the time madvise() is called, the kernel would reclaim as many pages
as it needs immediately, just as if you'd called MADV_DONTNEED for those
pages.  The remainder get marked reclaimable.

Look at it from the point of view of an application writer.  Why would I
ever call MADV_DONTNEED for anything but large memory areas?  It
penalises my application on systems that aren't swapping..  (Though
MADV_FREE is also a penalty, but a smaller one).

> but you said before that the number of small dynamically allocated objects
> dwarfs the number of large objects.  so either there is a problem here, or
> there isn't! :)

We're talking about free areas, not objects :-) Think of the kernel,
specifically only the memory managed by kmalloc/slab.  It handles lots
of small allocations, but nevertheless produces free pages which the
kernel can use when there's memory pressure.

But anyway...

Better than MADV_FREE: /dev/recycle
--------------------------------------------------

What about this whacky idea?

MAP_RECYCLE|MAP_ANON initially allocates pages like MAP_ANON.  Mapping
/dev/recycle is similar (but subtly different).

MADV_DONTNEED or munmap discard private modifications, but record this
process as the page owner.  If the process later accesses the page, a
page is allocated again but the MAP_RECYCLE means it may return a page
already marked as belonging to this process without clearing it.

That's better for app allocators than MADV_FREE: they're giving the
kernel more freedom with not much loss in performance.  And the kernel
likes this too -- no need for vmscan to release references, as the pages
are free already.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
