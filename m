Date: Thu, 29 Jun 2000 14:00:39 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on 2.4.0-test2
Message-ID: <20000629140039.N3473@redhat.com>
References: <20000629114407.A3914@redhat.com> <Pine.LNX.4.21.0006291330520.1713-100000@inspiron.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0006291330520.1713-100000@inspiron.random>; from andrea@suse.de on Thu, Jun 29, 2000 at 01:55:07PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Jun 29, 2000 at 01:55:07PM +0200, Andrea Arcangeli wrote:
> 
> I agree, the current swap_out design is too much fragile.
> 
> btw, in such area we also have a subtle hack/magic: when we unmap a clean
> page we consider that a "fail" ;), while instead we really did some kind
> of progress.

I really think we need to avoid such hacks entirely and just fix the
design.  The thing is, fixing the design isn't actually all that hard.

Rik's multi-queue stuff is the place to start (this is not a
coincidence --- we spent quite a bit of time talking this through).
Aging process pages and unmapping them should be considered part of
the same job.  Removing pages from memory completely is a separate
job.  I can't emphasise this enough --- this separation just fixes so
many problems in our current VM that we really, really need it for
2.4.

Look at how such a separation affects the swap_out problem above.  We
now have two jobs to do --- the aging code needs to keep a certain
number of pages freeable on the last-chance list (whatever you happen
to call it), that number being dependent on current memory pressure.
That list consists of nothing but unmapped, clean pages.  (A separate
list for unmapped, dirty pages is probably desirable for completely
different reasons.)

Do this and there is no longer any confusion in the swapper itself
about whether a page has become freed or not.  Either a foreground
call to the swapout code, or a background kswapd loop, can keep
populating the last chance lists; it doesn't matter, because we
decouple the concept of swapout from the concept of freeing memory.
When we actually want to free pages now, we can *always* tell how much
cheap page reclaim can be done, just by looking at the length of the
last-chance list. 

We can play all sorts of games with this, easily.  For example, when
the real free page count gets too low, we can force all normal page
allocations to be done from the last-chance list instead of the free
list, allowing only GFP_ATOMIC allocations to use up genuine free
pages.  That gives us proper flow control for non-atomic memory
allocations without all of the current races between one process
freeing a page and then trying to allocate it once try_to_free_page()
has returned (right now, an interrupt may have gobbled the page in the
mean time because we use the same list for the pages returned by
swap_out as for allocations).

I really think we need to forget about tuning the 2.4 VM until we have
such fundamental structures in place.  Until we have done that hard
work, we're fine-tuning a system which is ultimately fragile.  Any
structural changes will make the fine-tuning obsolete, so we need to
get the changes necessary for a robust VM in _first_, and then do the
performance fine-tuning.

One obvious consequence of doing this is that we need to separate out
mechanisms from policy.  With multiple queues in the VM for these
different jobs --- aging, cleaning, reclaiming --- we can separate out
the different mechanisms in the VM much more easily, which makes it
far easier to tune the policy for performance optimisations later on.
Right now, to do policy tuning we end up playing with core mechanisms
like the flow control loops all over the place.  Nasty.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
