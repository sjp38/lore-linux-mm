Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA15553
	for <linux-mm@kvack.org>; Mon, 23 Nov 1998 15:42:33 -0500
Date: Mon, 23 Nov 1998 21:12:20 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Linux-2.1.129..
In-Reply-To: <199811231713.RAA17361@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981123204943.417I-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Dr. Werner Fink" <werner@suse.de>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Nov 1998, Stephen C. Tweedie wrote:

> So, I have still seen no cases where overall performance with no
> page cache aging was better than performance with it.  However, with
> the swap aging removed as well, we seem to have a page/swap balance
> which doesn't work well on 64MB.  To be honest, I just haven't spent
> much time playing with swap page aging since the early kswap work,
> and that was all done before the page cache was added. 

What way does the balance go? Too much cache/buffer memory
can be 'fixed' by adjusting the settings in /proc/sys/vm/*
(yes, I know it goes against your principles, but some folks
need special behaviour for special-purpose systems anyway)

> On Thu, 19 Nov 1998 22:58:30 +0100 (CET), Rik van Riel
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > It was certainly a huge win when page aging was implemented, but we
> > mainly felt that because there used to be an obscure bug in vmscan.c,
> > causing the kernel to always start scanning at the start of the
> > process' address space.
> 
> Rik, you keep asserting this but I have never understood it.  I have
> asked you several times for a precise description of what benchmarks
> improved when page cache aging was added,

I mean the addition of page aging in kernel version 1.2.x.

Back then there certainly was a big improvement vs 1.1.x,
but unfortunately I was not really into kernel hacking
back then (I didn't even have a Net connection) so I
might have misunderstood things...

> And the "obscure bug" you describe was never there: I've said to you
> more than once that you were misreading the source, and that the
> field you pointed to which was being reset to zero at the start of
> the swapout loop was *guaranteed* to be overwritten with the last
> address scanned before we exited that loop. 

Nevertheless I observed a much more stable and less thash-
prone system with my small patch included.

> swap_out_pmd(), there is a line
> 
> 		tsk->swap_address = address + PAGE_SIZE;

Hmm, this means that it should work as you say. The
system seemed to be much more thash-prone however...(?)

> > This gives the process a chance of reclaiming the page without
> > incurring any I/O and it gives the kernel the possibility of keeping a
> > lot of easily-freeable pages around.
> 
> That would be true if we didn't do the free_page_and_swap_cache trick.
> However, doing that would require two passes: once by the swapper, and
> once by shrink_mmap(): before actually freeing a page.  This actually
> sounds like a *very* good idea to explore, since it means that vmscan.c
> will be concerned exclusively with returning mapped and anonymous pages
> to the page cache.

It is also what *BSD and OSF/1 seem to do. They have tuned
and balanced this system for the last 15 years so the system
should be rather well tuned...

> > Maybe we even want to keep a 3:1 ratio or something like that for
> > mapped:swap_cached pages and a semi- FIFO reclamation of swap cached
> > pages so we can simulate a bit of (very cheap) page aging.
> 
> I will just restate my profound conviction that any VM balancing which
> works by imposing precalculated limits on resources is fundamentally
> wrong.

The reason for a ratio like this is to ensure that:
- there are enough pages that can be free()d at any time,
  without us needing to scan the page tables, this also
  serves as a 'buffer' for high-pressure moments
- pages will spend enough time in 'unmapped' mode to have
  some serious aging imposed on them, not doing this might
  cancel out the effect we want (multi queue semantics)
- pages that are used semi-often will have some soft faults,
  always-used pages won't. keeping the soft-fault stats will
  enable us to make better pageout decisions cheaply
- when a page softfaults (is remapped in from the unmapped
  state) we can get below the wanted ratio and push out
  something else, this gives a nice, slow and uniform page
  aging system (especially when we observe a second chance FIFO
  algorithm for reclaiming the page-/swapcached and buffer
  pages, only breaking the FIFO style when memory is fragmented)
- keeping 25% of memory in unmapped state allows us to easily
  'fix' memory fragmentation, solving that problem as well --
  without having to give up the fast & cheap memory allocator
  we use now
- the easy-free buffer will allow us to keep less free memory,
  a few higher-order buffers should be all since we can free
  cached pages (shrink_mmap()) pages immediately,
- this in turn might slightly reduce swapping, especially on
  smaller machines

cheers,

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
