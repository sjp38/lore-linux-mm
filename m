Date: Thu, 23 Mar 2000 13:53:22 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: Re: madvise (MADV_FREE)
In-Reply-To: <20000322233147.A31795@pcep-jamie.cern.ch>
Message-ID: <Pine.BSO.4.10.10003231332080.20600-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie.lokier@cern.ch>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Mar 2000, Jamie Lokier wrote:
> > > The only effect of MADV_FREE is to eliminate the write to swap, after
> > > page ageing has decided to flush a page.  It doesn't change the page
> > > reclamation policy.
> > 
> > ok, here is where i'm confused.  i don't think MADV_DONTNEED and MADV_FREE
> > are different -- they both work this way.
> 
> No they don't.  MADV_DONTNEED always discards private modifications.
> (BTW I think it should be flushing the swap cache while it's at it).
> 
> MADV_FREE only discards private modifications when there is paging
> pressure to do so.  The decisions to do so are deferred, for
> architectures that support this.  (Includes x86).

i still don't see a big difference.  the private modifications, in both
cases, won't be written to swap.  in both cases, the application cannot
rely on the contents of these pages after the madvise call.

for private mappings, pages are freed immediately by DONTNEED; FREE will
cause the pages to be freed later if the system is low on memory.  that's
six of one, half dozen of the other.  freeing later may mean the
application saves a little time now, but freeing immediately could mean
postponing a low memory scenario, and would allow the system to reuse a
page that is still in hardware caches.

> > nah, i still say a better way to handle this case is to lower malloc's
> > "use an anon map instead of the heap" threshold to 4K or 8K.  right now
> > it's 32K by default.  
> 
> Try it.  I expect the malloc author chose a high threshold after
> extensive measurements -- that malloc implementation is the result of a
> series of implementations and studies.  Do you know that Glibc's malloc
> also limits the total number of mmaps?  I believe that's because
> performance plummets when you have too many vmas.

the AVL tree structure helps this.  there is still a linear search in the
number of vmas to find unused areas in a virtual address space.  this
makes mmap significantly slower when there are a large number of vmas.
i'll bet some clever person on this list could create a data structure
that fixes this problem.

but you said before that the number of small dynamically allocated objects
dwarfs the number of large objects.  so either there is a problem here, or
there isn't! :)  can this be any worse than mprotect?

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
