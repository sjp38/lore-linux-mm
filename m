Date: Wed, 22 Mar 2000 11:24:51 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: Re: madvise (MADV_FREE)
In-Reply-To: <20000321022053.A4271@pcep-jamie.cern.ch>
Message-ID: <Pine.BSO.4.10.10003221106150.16476-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie.lokier@cern.ch>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi jamie-

ok, i think i'm getting a more clear picture of what you are thinking.

On Tue, 21 Mar 2000, Jamie Lokier wrote:
> > >    The principle here is very simple: MADV_FREE marks all the pages in
> > >    the region as "discardable", and clears the accessed and dirty bits
> > >    of those pages.
> > > 
> > >    Later when the kernel needs to free some memory, it is permitted to
> > >    free "discardable" pages immediately provided they are still not
> > >    accessed or dirty.  When vmscan is clearing the accessed and dirty
> > >    bits on pages, if they were set it must clear the " discardable" bit.
> > > 
> > >    This allows malloc() and other user space allocators to free pages
> > >    back to the system.  Unlike DU's MADV_DONTNEED, or mmapping
> > >    /dev/zero, if the system does not need the page there is no
> > >    inefficient zero-copy.  If there was, malloc() would be better off
> > >    not bothering to return the pages.
> > 
> > unless i've completely misunderstood what you are proposing, this is what
> > MADV_DONTNEED does today,
> 
> No, your MADV_DONTNEED _always_ discards the data in those pages.  That
> makes it too inefficient for application memory allocators, because they
> will often want to reuse some of the pages soon after.  You don't want
> redundant page zeroing, and you don't want to give up memory which is
> still nice and warm in the CPU's cache.  Unless the kernel has a better
> use for it than you.
> 
> MADV_FREE on the other hand simply permits the kernel to reclaim those
> pages, if it is under memory pressure.
> 
> If there is no pressure, the pages are reused by the application
> unchanged.  In this way different subsystems competing for memory get to
> share it out -- essentially the fairness mechanisms in the kernel are
> extending to application page management.  And the application hardly
> knows a think about it.

ok, so you're asking for a lite(TM) version of DONTNEED that provides the
following hint to the kernel: "i may be finished with this page, but i may
also want to reuse it immediately."

memory allocation studies i've read show that dynamically allocated memory
objects are often re-used immediately after they are freed.  even if the
memory is being freed just before a process exits, it will be recycled
immediately by the kernel, so why use MADV_FREE if you are about to
munmap() it anyway?  finally, as you point out, the heap is generally too
fragmented to return page-sized chunks of it to the kernel, especially if
you consider that glibc uses *multiple* subheaps to reduce lock contention
in multithreaded applications.  it seems to me that normal page aging will
adequately identify these pages and flush them out.

if the application needs to recycle areas of a virtual address space
immediately, why should the kernel be involved at all?  i think even doing
an MADV_FREE during arbitrary free() operations would be more overhead
then you really want. in other words, i don't think free() as it exists
today harms performance in the ways you describe.

thus, either the application keeps the memory, or it is really completely
finished with it -- MADV_DONTNEED.

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
