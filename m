Date: Mon, 27 Mar 2000 19:48:52 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: Re: /dev/recycle
In-Reply-To: <20000324010031.B20140@pcep-jamie.cern.ch>
Message-ID: <Pine.BSO.4.10.10003271940511.24561-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 Mar 2000, Jamie Lokier wrote:
> Chuck Lever wrote:
> > > MADV_FREE only discards private modifications when there is paging
> > > pressure to do so.  The decisions to do so are deferred, for
> > > architectures that support this.  (Includes x86).
> > 
> > i still don't see a big difference.  the private modifications, in both
> > cases, won't be written to swap.  in both cases, the application cannot
> > rely on the contents of these pages after the madvise call.
> 
> Correct.  The difference is that with MADV_FREE, clear_page() operations
> are skipped when there's no memory pressure from the kernel.
> 
> > for private mappings, pages are freed immediately by DONTNEED; FREE will
> > cause the pages to be freed later if the system is low on memory.  that's
> > six of one, half dozen of the other.  freeing later may mean the
> > application saves a little time now,
> 
> It may save the time overall -- if the page is next reused by the
> application before the kernel recycles it.  Note that nobody, neither
> the application nor the kernel, knows in advance if this will be the
> case.
> 
> > but freeing immediately could mean postponing a low memory scenario,
> > and would allow the system to reuse a page that is still in hardware
> > caches.
> 
> The system is free to reuse MADV_FREE pages immediately if it wishes --
> the system doesn't lose here.  In fact if you're already low on memory
> at the time madvise() is called, the kernel would reclaim as many pages
> as it needs immediately, just as if you'd called MADV_DONTNEED for those
> pages.  The remainder get marked reclaimable.

ok, i just want to make sure we really are talking about the same thing,
at least from the point of view of the semantics that the application will
depend on.  the only difference is how/when the kernel disposes of the
pages.

reducing the number of clear_page() operations and reducing the amount of
page table jiggling on SMP are both good goals.  is it your view that
MADV_FREE is a better implementation of MADV_DONTNEED?  should we replace
the current implementation of MADV_DONTNEED with one that behaves more
like MADV_FREE?  is there a reason to have both behaviors available to
applications?

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
