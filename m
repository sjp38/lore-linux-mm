Message-ID: <3AB777E1.2B233E8A@uow.edu.au>
Date: Wed, 21 Mar 2001 02:31:45 +1100
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: Re: 3rd version of R/W mmap_sem patch available
References: <Pine.LNX.4.33.0103192254130.1320-100000@duckman.distro.conectiva> <Pine.LNX.4.31.0103191839510.1003-100000@penguin.transmeta.com> <3AB77311.77EB7D60@uow.edu.au> <3AB77443.55B42469@mandrakesoft.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jeff Garzik wrote:
> 
> Andrew Morton wrote:
> > General comment: an expensive part of a pagefault
> > is zeroing the new page.  It'd be nice if we could
> > drop the page_table_lock while doing the clear_user_page()
> > and, if possible, copy_user_page() functions.  Very nice.
> 
> People have talked before about creating zero pages in the background,
> or creating them as a side effect of another operation (don't recall
> details), so yeah this is definitely an area where some optimizations
> could be done.  I wouldn't want to do it until 2.5 though...

Actually, I did this for x86 last weekend :) Initial results are
disappointing. 

It creates a special uncachable mapping and sits there
zeroing pages in a low-priority thread (also tried
doing it in the idle task).

It was made uncachable because a lot of the
cost of clearing a page at fault time will be in
the eviction of live, useful data.

But clearing an uncachable page takes about eight times
as long as clearing a cachable, but uncached one.  Now,
if there was a hardware peripheral which could zero pages
quickly, that'd be good.

I dunno.  I need to test it on more workloads.  I was
using kernel compiles and these have a very low
sleeping-on-IO to faulting-zeropages-in ratio.  The
walltime for kernel builds was unaltered.

Certainly one can write silly applications which
speed up by a factor of ten with this change.

I'll finish this work off sometime in the next week,
stick it on the web.


But that's all orthogonal to my comment.  We'd
get significantly better threaded use of a single
mm if we didn't block it while clearing and copying 
pages.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
