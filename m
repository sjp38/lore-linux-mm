Date: Sun, 29 Apr 2001 16:10:12 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: RFC: Bouncebuffer fixes
Message-ID: <20010429161012.F11395@athlon.random>
References: <20010428170648.A10582@devserv.devel.redhat.com> <20010429020757.C816@athlon.random> <20010429035626.B14210@devserv.devel.redhat.com> <20010429151711.A11395@athlon.random> <20010429094121.B3131@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010429094121.B3131@devserv.devel.redhat.com>; from arjanv@redhat.com on Sun, Apr 29, 2001 at 09:41:21AM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjanv@redhat.com>
Cc: linux-mm@kvack.org, alan@lxorguk.ukuu.org.uk, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Sun, Apr 29, 2001 at 09:41:21AM -0400, Arjan van de Ven wrote:
> On Sun, Apr 29, 2001 at 03:17:11PM +0200, Andrea Arcangeli wrote:
> 
> > GFP_BUFFER doesn't provide guarantee of progress and that's fine, as far
> > as GFP_BUFFER allocations returns NULL eventually there should be no
> > problem. The fact some emergency buffer is in flight is just the guarantee
> > of progress because after unplugging tq_disk we know those emergency
> > buffers will be released without the need of further memory allocations.
> 
> This is NOT what is happening. Look at the code. It does a GFP_BUFFER
> allocation before even attempting to use the bounce-buffers! So there is no
> guarantee of having emergency bouncebuffers in flight.

Of course _the first time_ the GFP_BUFFER fails, you have the guarantee
that the pool is _full_ of emergency bounce buffers.

Note that the fact GFP_BUFFER fails or succeed is absolutely not
interesting and unrelated to the anti-deadlock logic. You could drop the
GFP_BUFFER and the code should keep working (if it wouldn't be the case
_that_ would be the real bug).

The only reason of the GFP_BUFFER is to keep more I/O in flight when
normal memory is available.

The only "interesting" part of the algorithm I was talking about in the
last email is when the emergency pool is _empty_ (which in turn also
means GFP_BUFFER _just_ failed as we tried to allocate from the
emergency pool) and I wasn't even considering the case when the
emergency pool is not empty.

> Also, I'm not totally convinced that GFP_BUFFER will never sleep before
> running the tq_disk, but I agree that that can qualify as a seprate bug.

GFP_BUFFER is perfectly fine to sleep, the only thing GFP_BUFFER must
_not_ do is to start additional I/O (to avoid recursing on the fs locks)
and to deadlock (and this second property is common to all the GFP_*
indeed).

As far I can tell, if you use my patch on top of vanilla 2.4.4 and you
still get a deadlock in highmem.c it can only because GFP_BUFFER
deadlocksed and that can only be unrelated to the code in highmem.c. I
also suggest to verify that GFP_BUFFER really deadlocks in 2.4.4 vanilla
too because I didn't reproduced that yet.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
