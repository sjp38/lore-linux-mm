Date: Thu, 6 Jul 2000 14:29:45 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on 2.4.0-test2
Message-ID: <20000706142945.A4237@redhat.com>
References: <20000629140039.N3473@redhat.com> <Pine.LNX.4.21.0007061211480.4810-100000@inspiron.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0007061211480.4810-100000@inspiron.random>; from andrea@suse.de on Thu, Jul 06, 2000 at 12:35:58PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Jul 06, 2000 at 12:35:58PM +0200, Andrea Arcangeli wrote:
> 
> I'm not sure what you planned exactly to do (maybe we can talk about this
> some time soon) but I'll tell you what I planned to do taking basic idea
> to throw-out-swap_out from the very _cool_ DaveM throw-swap_out patch
> floating around that's been the _only_ recent VM 2.[34].x patch that I
> seen floating around that really excited me (I've not focused all the
> details of his patch but I'm pretty sure it's very similar design even if
> probably not equal to what I'm trying to do).

Right, this is obviously needed for 2.5 (at least as an experimental
branch), but we simply can't do it in time for 2.4.  It's too big a
change.  If we get rid of swap_out, and do our reclaim based on
physical page lists, then suddenly a whole new class of problems
arises.  For example, our swap clustering relies on allocating
sequential swap addresses to sequentially scanned VM addresses, so
that clustered swapout and swapin work naturally.  Switch to
physically-ordered swapping and there's no longer any natural way of
getting the on-disk swap related to VA ordering, so that swapin
clustering breaks completely.  To fix this, you need the final swapout
to try to swap nearby pages in VA space at the same time.  It's a lot
of work to get it right.

> Then we'll need a page-to-pte_chain reverse lookup.

Right, and I think there are ways we can do this relatively cheaply.
Use the address_space's vma ring for shared pages, use the struct page
itself to encode the VA of the page for unshared anon pages, and keep
a separate hash of all shared anon ptes.

> Once we'll have that
> too we'll can remove swap_out and do everything (except dcache/icache
> things) in shrink_mmap

Right, but this is all completely orthogonal to the problems I was
talkiing about in my original email.  Those problems were to do with
things like write-throttling and managing free space, and did not
concern identifying which pages to throw out or how to age them.
Rik's multi-queued code, or the new code from Ludovic Fernandez which
separates out page aging to a different thread.

> So basically we'll have these completly different lists:
> 
> 	lru_swap_cache
> 	lru_cache
> 	lru_mapped
> 
> The three caches have completly different importance that is implicit by
> the semantics of the memory they are queuing.

I think this is entirely the wrong way to be thinking about the
problem.  It seems to me to be much more important that we know:

1) What pages are unreferenced by the VM (except for page cache
references) and which can therefore be freed at a moment's notice;

2) What pages are queued for write;

3) what pages are referenced and in use for other reasons.

Completely unreferenced pages can be freed on a moment's notice.  If
we are careful with the spinlocks we can even free them from within an
interrupt.  

By measuring the throughput of these different page classes we can
work out what the VM pressure and write pressure is.  When we get a
write page fault, we can (for example) block until the write queue
comes down to a certain size, to obtain write flow control.

More importantly, the scanning of the dirty and in-use queues can go
on separately from the freeing of clean pages.  The more memory
pressure we are under --- ie. the faster we are gobbling unmapped
pages off the unreferenced queue --- the more rapidly we let the aging
thread walk the referenced pages and try to age pages onto the
unreferenced queue.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
