Message-ID: <3D2A07FF.AE1EC8FB@zip.com.au>
Date: Mon, 08 Jul 2002 14:45:35 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
References: <3D28042E.B93A318C@zip.com.au> <Pine.LNX.4.44.0207071128170.3271-100000@home.transmeta.com> <3D293E19.2AD24982@zip.com.au> <20020708080953.GC1350@dualathlon.random> <3D29F868.1338ACF3@zip.com.au> <20020708170841.Q13063@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, "Martin J. Bligh" <fletch@aracnet.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Benjamin LaHaise wrote:
> 
> On Mon, Jul 08, 2002 at 01:39:04PM -0700, Andrew Morton wrote:
> > I think I'll just go for pinning the damn page.  It's a spinlock and
> > maybe three cachelines but the kernel is about to do a 4k memcpy
> > anyway.  And get_user_pages() doesn't show up much on O_DIRECT
> > profiles and it'll be a net win and we need to do SOMETHING, dammit.
> 
> Pinning the page costs too much (remember, it's only a win with a
> reduced copy of more that 512 bytes).

Could you expand on that?

>  The right way of doing it is
> letting copy_*_user fail on a page fault for places like this where
> we need to drop locks before going into the page fault handler.

OK.  There are a few things which need to be fixed up in there.  One
is to drop and reacquire the atomic kmap.  Another is the page
lock (for the write-to-mmaped-page-from-the-same-file thing).
Another is to undo the ->prepare_write call.  Or to remember to not
run it again on the retry.

It's really the page lock which is the tricky one.  It could be
a new, uninitialised page.  It's in pagecache and it is not
fully uptodate.  If we drop the page lock and that page is
inside i_size then the kernel has exposed uninitialised data.

Tricky.   A sleazy approach would be to not unlock the page at
all. ie: no change.  Sure, the kernel can deadlock.  But it's
always been that way - the deadlock requires two improbable things,
whereas the schedule-inside-atomic-kmap requires just one.

hmm.  Bit stumped on that one.

Btw, is it safe to drop and reacquire an atomic kmap if you
found out that you accidentally slept while holding it?

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
