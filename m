Date: Wed, 22 Mar 2000 16:39:12 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: Re: madvise (MADV_FREE)
In-Reply-To: <20000322190532.A7212@pcep-jamie.cern.ch>
Message-ID: <Pine.BSO.4.10.10003221554170.17378-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie.lokier@cern.ch>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Mar 2000, Jamie Lokier wrote:
> Think of this scenario:
> 
>    Allocate 20 x 20k blocks for images.
>    Process images.
>    Free 20 x 20k blocks (-> 100 page sized holes)
>    Wait for user input.
>    ...
>    Allocate 20 x 20k blocks for images.
>    Process images.
>    Free 20 x 20k blocks.
> 
> Now, if the rest of your system (not just this app) is busy paging, the
> best thing the app can do at "wait" is call MADV_DONTNEED.  But if the
> rest of your system is not paging at all, the best thing the app can do
> is _not_ call MADV_DONTNEED.
> 
> You see?  It doesn't matter whether you're going to reuse the pages soon.
> 
> The decision to use MADV_DONTNEED or not depends on overall system
> behaviour, which the application doesn't know about.
> 
> > ok, so you're asking for a lite(TM) version of DONTNEED that provides the
> > following hint to the kernel: "i may be finished with this page, but i may
> > also want to reuse it immediately."
> 
> It does *not* mean "i may have finished with this page".
> For free() it looks that way, but that is a special case.
> 
> It means "if you decide to swap this page out, you can skip the I/O".
> 
> The page age remains the same.  (You have MADV_WONTNEED if you want to
> change the page age as well).
> 
> We let applications decide for themselves when it's best used.  It's for
> long-lived holes after memory allocation, and cached objects such as
> Netscapes in-memory image and document cache.

we have several generic applications we are interested in optimizing:

1.  memory allocators can indicate pages that are not in use

2.  applications that need to cache large files or big pieces of data that
can be regenerated relatively cheaply

3.  applications that need to buffer data to control precisely its
movement to and from permanent storage.

now, for 1:

several studies i've read indicate that the average size of a dynamically
allocated object is in the range of 40 bytes.  if an application is
screwing with much bigger objects, it should probably manage the objects
differently (use mmap explicitly, tweak malloc, or something like that).

in fact, i'd say it is safe in general to lower DEFAULT_MMAP_THRESHOLD to
the system page size.  that way you'd get closer to the behavior you're
after, and you'd also win a much bigger effective heap size when
allocating large objects, because you can only allocate up to 960M of a
process's address space with sbrk().

on Linux with glibc, you can use mallopt to do this. something like:

	mallopt(M_MMAP_THRESHOLD, getpagesize());

for 2:

note carefully that my implementation of MADV_DONTNEED doesn't evict data
from memory.  it simply tears down page mappings.  this will result in a
minor fault if the application immediately reaccesses the address, or a
major fault if the application accesses the address after the page
contents have finally been evicted from physical memory.

to say this another way, the page mapping binds a virtual address to a
page in the page cache. MADV_DONTNEED simply removes that binding.  
normal page aging will discover the unbound pages in the page cache and
remove them.  so really, MADV_DONTNEED is actually disconnected from the
mechanism of swapping or discarding the page's data.

there are probably nicer ways to do this, but there it is.

i think this is exactly what you want for cached files.  the application
can say "DONTNEED" this data, and the system is free to reclaim it as
necessary.  if the application accesses it again later, it will get the
old data back.  just be sure that if you change data in the file, you
explicitly sync it back to disk.

for 3:

this area of memory is probably going to be mapped from /dev/zero, and
pinned.  it's a nice way to get a clear page if you just re-read /dev/zero
into that page.

> > it seems to me that normal page aging will adequately identify these
> > pages and flush them out.
> 
> Exactly!  In fact page ageing is required for MADV_FREE to have any
> effect.
> 
> The only effect of MADV_FREE is to eliminate the write to swap, after
> page ageing has decided to flush a page.  It doesn't change the page
> reclamation policy.

ok, here is where i'm confused.  i don't think MADV_DONTNEED and MADV_FREE
are different -- they both work this way.

> > i think even doing an MADV_FREE during arbitrary free() operations
> > would be more overhead then you really want. in other words, i don't
> > think free() as it exists today harms performance in the ways you
> > describe.
> 
> You're right, you wouldn't call MADV_FREE on every free().  Just when
> you have a set of pages to free, every so often.  There are lots of
> systems which can do that -- even a timer signal will do with a generic
> malloc.

nah, i still say a better way to handle this case is to lower malloc's
"use an anon map instead of the heap" threshold to 4K or 8K.  right now
it's 32K by default.  

> At the moment, the kernel has a number of subsystems, and when memory is
> required, it asks each subsystem to release some memory.  MADV_FREE is a
> way for the kernel to include applications in memory balancing
> decisions.

like adding another separate call in do_try_to_free_pages that trolls
applications for free-able pages; expect with MADV_FREE and MADV_DONTNEED,
you're causing shrink_mmap to do this for you automatically.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
