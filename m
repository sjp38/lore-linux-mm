Message-ID: <391080F0.C02C7F38@sgi.com>
Date: Wed, 03 May 2000 12:41:36 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
References: <200005031837.LAA71569@google.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Kanoj Sarcar wrote:
> 
> >
> >
> > On Wed, 3 May 2000, Kanoj Sarcar wrote:
> > >
> > > At no point between the time try_to_swap_out() is running, will is_page_shared()
> > > wrongly indicate the page is _not shared_, when it is really shared (as you
> > > say, it is pessimistic).
> >
> > Note that this is true only if you assume processor ordering.
> >
> 
> True ... not to deviate from the current topic, I would think that instead
> of imposing locks here, you would want to inject instructions (like the
> mips "sync") that makes sure memory is consistant. Imposing locks is a
> roundabout way of insuring memory consistancy, since the unlock normally
> has this "sync" type instruction encoded in it anyway.


Using "sync"-type operations to ensure memory ordering is not an
approach I'd recommend ... We've used it in only a couple of places
in IRIX synchronization code; but I'm yet to meet anyone who can
comfortably argue the correctness of it. Also, it opens up
chances of the compiler screwing up the writes ... and _those_ bugs
are really hard to pin down.

Further more, in the case at hand in Linux, we are not dealing with
high performance operations ... this is swapping after all.

Finally, in an MP system, the s/w synchronization primitives (lock/unlock/rwlock, etc.)
are the building blocks for ensuring correctness of interleaved execution.
Let's use those instead of low-level h/w primitives. Optimizations
can be pushed into (and isolated to) the implementation of the s/w
synchronization primtives.

-- 
--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
