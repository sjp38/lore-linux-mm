Date: Mon, 8 Jul 2002 18:24:29 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <20020708182429.R13063@redhat.com>
References: <3D28042E.B93A318C@zip.com.au> <Pine.LNX.4.44.0207071128170.3271-100000@home.transmeta.com> <3D293E19.2AD24982@zip.com.au> <20020708080953.GC1350@dualathlon.random> <3D29F868.1338ACF3@zip.com.au> <20020708170841.Q13063@redhat.com> <3D2A07FF.AE1EC8FB@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D2A07FF.AE1EC8FB@zip.com.au>; from akpm@zip.com.au on Mon, Jul 08, 2002 at 02:45:35PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, "Martin J. Bligh" <fletch@aracnet.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 08, 2002 at 02:45:35PM -0700, Andrew Morton wrote:
> > Pinning the page costs too much (remember, it's only a win with a
> > reduced copy of more that 512 bytes).
> 
> Could you expand on that?

I'm going from data that I gather while fiddling with aio and the pipe 
code.  As a thought experiment, look at it this way: pinning the page 
involves a minimum 4-5 data dependent cache line accesses (mm struct, 
2-3 page table levels, then a locked cycle on the page struct itself) 
compared to the use of tlb entries that are likely to be present (free, 
plus recent cpus have hardware to prefect them completely asynchronous 
to instruction execution).

> >  The right way of doing it is
> > letting copy_*_user fail on a page fault for places like this where
> > we need to drop locks before going into the page fault handler.
> 
> OK.  There are a few things which need to be fixed up in there.  One
> is to drop and reacquire the atomic kmap.  Another is the page
> lock (for the write-to-mmaped-page-from-the-same-file thing).
> Another is to undo the ->prepare_write call.  Or to remember to not
> run it again on the retry.
> 
> It's really the page lock which is the tricky one.  It could be
> a new, uninitialised page.  It's in pagecache and it is not
> fully uptodate.  If we drop the page lock and that page is
> inside i_size then the kernel has exposed uninitialised data.

Hmmm, do we really need to insert a new, uninitialised page into 
the page cache before filling it with data?  If we could defer that 
until the data is copied into the page (most of the time there would 
be no collisions during writes, so a spurious copy is unlikely)

Side note: I did an alternative fix for this which just stuffed a 
copy of the struct page * into the task struct, and checked for this 
inside filemap.c.  Very gross, but it worked.

> Tricky.   A sleazy approach would be to not unlock the page at
> all. ie: no change.  Sure, the kernel can deadlock.  But it's
> always been that way - the deadlock requires two improbable things,
> whereas the schedule-inside-atomic-kmap requires just one.

It's not unlikely if you've got a malicious user behind the shell.

> Btw, is it safe to drop and reacquire an atomic kmap if you
> found out that you accidentally slept while holding it?

Yes and no: it works, but if debugging is enabled it bugs out.

		-ben
-- 
"You will be reincarnated as a toad; and you will be much happier."
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
