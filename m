Date: Wed, 22 Mar 2000 19:05:32 +0100
From: Jamie Lokier <jamie.lokier@cern.ch>
Subject: Re: madvise (MADV_FREE)
Message-ID: <20000322190532.A7212@pcep-jamie.cern.ch>
References: <20000321022053.A4271@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003221106150.16476-100000@funky.monkey.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.BSO.4.10.10003221106150.16476-100000@funky.monkey.org>; from Chuck Lever on Wed, Mar 22, 2000 at 11:24:51AM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Chuck,

Think of this scenario:

   Allocate 20 x 20k blocks for images.
   Process images.
   Free 20 x 20k blocks (-> 100 page sized holes)
   Wait for user input.
   ...
   Allocate 20 x 20k blocks for images.
   Process images.
   Free 20 x 20k blocks.

Now, if the rest of your system (not just this app) is busy paging, the
best thing the app can do at "wait" is call MADV_DONTNEED.  But if the
rest of your system is not paging at all, the best thing the app can do
is _not_ call MADV_DONTNEED.

You see?  It doesn't matter whether you're going to reuse the pages soon.

The decision to use MADV_DONTNEED or not depends on overall system
behaviour, which the application doesn't know about.

Chuck Lever wrote:
> ok, so you're asking for a lite(TM) version of DONTNEED that provides the
> following hint to the kernel: "i may be finished with this page, but i may
> also want to reuse it immediately."

It does *not* mean "i may have finished with this page".
For free() it looks that way, but that is a special case.

It means "if you decide to swap this page out, you can skip the I/O".

The page age remains the same.  (You have MADV_WONTNEED if you want to
change the page age as well).

We let applications decide for themselves when it's best used.  It's for
long-lived holes after memory allocation, and cached objects such as
Netscapes in-memory image and document cache.

> memory allocation studies i've read show that dynamically allocated memory
> objects are often re-used immediately after they are freed.

True for programs which are continuously allocating and freeing memory.
Not true for interactive programs waiting for the user (for example).
See the scenario I wrote at the start of this message.

> even if the memory is being freed just before a process exits, it will
> be recycled immediately by the kernel, so why use MADV_FREE if you are
> about to munmap() it anyway?

You wouldn't use it in that situation.

I am thinking of long lived processes that aren't actively allocating
and have holes in their heap.  For example Emacs, Netscape etc.

My motivation for MADV_FREE is the observation that the optimal
behaviour for programs like Emacs and Netscape is to allocate and use
lots of memory (without changing it much) if there is no swapping, but
to release memory aggressively if there is swapping.

> finally, as you point out, the heap is generally too fragmented to
> return page-sized chunks of it to the kernel, especially if you
> consider that glibc uses *multiple* subheaps to reduce lock contention
> in multithreaded applications.

Multiple subheaps helps to produce page sized holes.  Larger allocations
(but not large enough to use mmap), when freed, leave page sized holes.
The holes aren't blocked because tiny allocations go on different
subheaps.

> it seems to me that normal page aging will adequately identify these
> pages and flush them out.

Exactly!  In fact page ageing is required for MADV_FREE to have any
effect.

The only effect of MADV_FREE is to eliminate the write to swap, after
page ageing has decided to flush a page.  It doesn't change the page
reclamation policy.

> if the application needs to recycle areas of a virtual address space
> immediately, why should the kernel be involved at all?

It is for long lived applications that have holes in their heap, who
aren't actively recycling.  Some memory allocators don't know if they
are about to be recycled, but some do.  It depends on the application.

> i think even doing an MADV_FREE during arbitrary free() operations
> would be more overhead then you really want. in other words, i don't
> think free() as it exists today harms performance in the ways you
> describe.

You're right, you wouldn't call MADV_FREE on every free().  Just when
you have a set of pages to free, every so often.  There are lots of
systems which can do that -- even a timer signal will do with a generic
malloc.

See for example GCC's ggc-page allocator -- every so often it decides to
free a set of pages.  And any GC system.  And any system which caches
objects in memory, for example Netscape.

> thus, either the application keeps the memory, or it is really completely
> finished with it -- MADV_DONTNEED.

MADV_FREE is, speaking generally, not for either of those situations.

It's for when the application has memory that it's _willing_ to give up,
at some cost to application performance.  For example cached objects
that can be recalculated or reread over the network.

Memory allocators are a special case of this.  Not just malloc/free, but
also garbage collecting systems.

At the moment, the kernel has a number of subsystems, and when memory is
required, it asks each subsystem to release some memory.  MADV_FREE is a
way for the kernel to include applications in memory balancing
decisions.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
