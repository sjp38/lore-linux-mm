Date: Wed, 22 Mar 2000 23:31:47 +0100
From: Jamie Lokier <jamie.lokier@cern.ch>
Subject: Re: madvise (MADV_FREE)
Message-ID: <20000322233147.A31795@pcep-jamie.cern.ch>
References: <20000322190532.A7212@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003221554170.17378-100000@funky.monkey.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.BSO.4.10.10003221554170.17378-100000@funky.monkey.org>; from Chuck Lever on Wed, Mar 22, 2000 at 04:39:12PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > it seems to me that normal page aging will adequately identify these
> > > pages and flush them out.
> > 
> > Exactly!  In fact page ageing is required for MADV_FREE to have any
> > effect.
> > 
> > The only effect of MADV_FREE is to eliminate the write to swap, after
> > page ageing has decided to flush a page.  It doesn't change the page
> > reclamation policy.
> 
> ok, here is where i'm confused.  i don't think MADV_DONTNEED and MADV_FREE
> are different -- they both work this way.

No they don't.  MADV_DONTNEED always discards private modifications.
(BTW I think it should be flushing the swap cache while it's at it).

MADV_FREE only discards private modifications when there is paging
pressure to do so.  The decisions to do so are deferred, for
architectures that support this.  (Includes x86).

Chuck Lever wrote:
> 1.  memory allocators can indicate pages that are not in use
> 
> now, for 1:
> 
> several studies i've read indicate that the average size of a dynamically
> allocated object is in the range of 40 bytes.  if an application is
> screwing with much bigger objects, it should probably manage the objects
> differently (use mmap explicitly, tweak malloc, or something like that).

The average object size is skewed towards small numbers because there
are usually many more small objects, allocated at a higher rate.  It
only takes a few larger objects to lead to holes, but they don't count
in the "average size" statistic because the time spent in the memory
allocator for larger objects isn't significant.

MADV_FREE isn't to optimise the time spent in a memory allocator.  It's
to optimise overall system performance.

And that is for a subset of applications.  Yes, by all means tweak
malloc.  Tweak it to call MADV_FREE :-)

> in fact, i'd say it is safe in general to lower DEFAULT_MMAP_THRESHOLD to
> the system page size.  that way you'd get closer to the behavior you're
> after, and you'd also win a much bigger effective heap size when
> allocating large objects, because you can only allocate up to 960M of a
> process's address space with sbrk().

A fine way to make performance suck.

Application heap fragmentation now appears as vma fragmentation -> that
means expect to see hundreds or more vmas.  Lost memory due to rounding
to a page size is also now also unusable.

Even if you manage to save memory, performance sucks.  A system call for
every medium size allocation and deallocation?  You gotta be kidding.
And now even normal page faults take longer because of the extra vmas.

You've just optimised for the minimum RAM, maximum paging case.

> > You're right, you wouldn't call MADV_FREE on every free().  Just when
> > you have a set of pages to free, every so often.  There are lots of
> > systems which can do that -- even a timer signal will do with a generic
> > malloc.
> 
> nah, i still say a better way to handle this case is to lower malloc's
> "use an anon map instead of the heap" threshold to 4K or 8K.  right now
> it's 32K by default.  

Try it.  I expect the malloc author chose a high threshold after
extensive measurements -- that malloc implementation is the result of a
series of implementations and studies.  Do you know that Glibc's malloc
also limits the total number of mmaps?  I believe that's because
performance plummets when you have too many vmas.

And even if we didn't use vmas or system calls, even if mmap were a
straightforward function call to ultra-fast code, explicitly returning
the memory to the kernel implies a significant overhead -- you're
forcing unnecessary clear_page() calls.

> 2.  applications that need to cache large files or big pieces of data that
> can be regenerated relatively cheaply
> 
> note carefully that my implementation of MADV_DONTNEED doesn't evict data
> from memory.  it simply tears down page mappings.  this will result in a
> minor fault if the application immediately reaccesses the address, or a
> major fault if the application accesses the address after the page
> contents have finally been evicted from physical memory.
> 
> to say this another way, the page mapping binds a virtual address to a
> page in the page cache. MADV_DONTNEED simply removes that binding.  
> normal page aging will discover the unbound pages in the page cache and
> remove them.  so really, MADV_DONTNEED is actually disconnected from the
> mechanism of swapping or discarding the page's data.

Let's see... zap_page_range.  That looks like the private modification
is discarded.

That's not what MADV_FREE does.  MADV_FREE does _not_ discard private
modifications unless they're reclaimed due to memory pressure.  And that
decision is magically deferred.

And that's what you want for caching calculated structures in an
application.  They are private mappings which will be zeroed _if_ (and
only if) the kernel decides there is pressure to use the memory
elsewhere.

> i think this is exactly what you want for cached files.

For reading a file, yes.  For a locally generated structure, such as a
parsed file, no.  BTW, I am sure that Netscape's "memory cache" is the
latter -- because they have "disk cache" for the former.

> the application can say "DONTNEED" this data, and the system is free
> to reclaim it as necessary.  if the application accesses it again
> later, it will get the old data back.  just be sure that if you change
> data in the file, you explicitly sync it back to disk.

You say "the system is free to reclaim it".  MADV_DONTNEED _forces_ the
system to reclaim the data, if it is not in swap cache at the time.

For a locally calculated structure in an anonymous mapping, you don't
get the data back.  (Yes, this means "cached files".  Sorry if I made it
sound like mapped files).

> 3.  applications that need to buffer data to control precisely its
> movement to and from permanent storage.
>
> for 3:
> 
> this area of memory is probably going to be mapped from /dev/zero, and
> pinned.  it's a nice way to get a clear page if you just re-read /dev/zero
> into that page.

Um.  I don't see how that response has anything to do with 3 :-)

> > At the moment, the kernel has a number of subsystems, and when memory is
> > required, it asks each subsystem to release some memory.  MADV_FREE is a
> > way for the kernel to include applications in memory balancing
> > decisions.
> 
> like adding another separate call in do_try_to_free_pages that trolls
> applications for free-able pages; expect with MADV_FREE and MADV_DONTNEED,
> you're causing shrink_mmap to do this for you automatically.

It should be added to vmscan and/or shrink_mmap.  The rough outline is:
MADV_FREE clears the pte accessed bit and marks the page as freeable.
Later, on finding one of these pages during the normal scans, just dump
the page if it is still not accessed.  If it has been accessed, it's no
longer freeable.

There are some interactions with the swap cache and vmscan algorithm I
have glossed over...

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
