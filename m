Date: Wed, 16 May 2001 13:57:07 -0400
From: Alfred Perlstein <bright@rush.net>
Subject: Re: on load control / process swapping
Message-ID: <20010516135707.H12365@superconductor.rush.net>
References: <200105161714.f4GHEFs72217@earth.backplane.com> <Pine.LNX.4.33.0105161439140.18102-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.33.0105161439140.18102-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Wed, May 16, 2001 at 02:41:35PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Matt Dillon <dillon@earth.backplane.com>, Charles Randall <crandall@matchlogic.com>, Roger Larsson <roger.larsson@norran.net>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

* Rik van Riel <riel@conectiva.com.br> [010516 13:42] wrote:
> On Wed, 16 May 2001, Matt Dillon wrote:
> 
> >     In regards to the particular case of scanning a huge multi-gigabyte
> >     file, FreeBSD has a sequential detection heuristic which does a
> >     pretty good job preventing cache blow-aways by depressing the priority
> >     of the data as it is read or written.  FreeBSD will still try to cache
> >     a good chunk, but it won't sacrifice all available memory.  If you
> >     access the data via the VM system, through mmap, you get even more
> >     control through the madvise() syscall.
> 
> There's one thing "wrong" with the drop-behind idea though;
> it penalises data even when it's still in core and we're
> reading it for the second or third time.
> 
> Maybe it would be better to only do drop-behind when we're
> actually allocating new memory for the vnode in question and
> let re-use of already present memory go "unpunished" ?
> 
> Hmmm, now that I think about this more, it _could_ introduce
> some different fairness issues. Darn ;)

Both of you guys are missing the point.

The directio interface is meant to reduce the stress of a large
seqential operation on a file where caching is of no use.

Even if you depress the worthyness of the pages you've still
blown rather large amounts of unrelated data out of the cache
in order to allocate new cacheable pages.

A simple solution would involve passing along flags such that if
the IO occurs to a non-previously-cached page the buf/page is
immediately placed on the free list upon completion.  That way the
next IO can pull the now useless bufferspace from the freelist.

Basically you add another buffer queue for "throw away" data that
exists as a "barely cached" queue.  This way your normal data
doesn't compete on the LRU with non-cached data.

As a hack one it looks like one could use the QUEUE_EMPTYKVA
buffer queue under FreeBSD for this, however I think one might
loose the minimal amount of caching that could be done.

If the direct IO happens to a page that's previously cached
you adhere to the previous behavior.

A more fancy approach might map in user pages into the kernel to
do the IO directly, however on large MP this may cause pain because
the vm may need to issue ipi to invalidate tlb entries.

It's quite simple in theory, the hard part is the code.

-Alfred Perlstein
--
Instead of asking why a piece of software is using "1970s technology,"
start asking why software is ignoring 30 years of accumulated wisdom.
  http://www.egr.unlv.edu/~slumos/on-netbsd.html
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
