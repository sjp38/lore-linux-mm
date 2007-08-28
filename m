Message-ID: <000501c7e9b5$7f73db00$6501a8c0@earthlink.net>
Reply-To: "Mitchell Erblich" <erblichs@earthlink.net>
From: "Mitchell Erblich" <erblichs@earthlink.net>
Subject: Re: [RFC] : mm : / Patch / code : Suggestion :snip kswapd &get_page_from_freelist() : No more no page failures. (WHY????)
Date: Tue, 28 Aug 2007 13:53:31 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
>
> Mitchell@kvack.org wrote:
> > linux-mm@kvack.org
> > Sent: Friday, August 24, 2007 3:11 PM
> > Subject: Re: [RFC] : mm : / Patch / code : Suggestion :snip kswapd &
> > get_page_from_freelist() : No more no page failures.
> >
> > Mailer added a HTML subpart and chopped the earlier email.... :^(
>
> Hi Mitchell,
>
> Is it possible to send suggestions in the form of a unified diff, even
> if you haven't even compiled it (just add a note to let people know).
>
> Secondly, we already have a (supposedly working) system of asynch
> reclaim, with buffering and hysteresis. I don't exactly understand
> what problem you think it has that would be solved by rechecking
> watermarks after allocating a page.
>
> When we're in the (min,low) watermark range, we'll wake up kswapd
> _before_ allocating anything, so what is better about the change to
> wake up kswapd after allocating? Can you perhaps come up with an
> example situation also to make this more clear?
>
> Overhead of wakeup_kswapd isn't too much of a problem: if we _should_
> be waking it up when we currently aren't, then we should be calling
> it. However the extra checking in the allocator fastpath is something
> we want to avoid if possible, because this can be a really hot path.
>
> Thanks,
> Nick
>
> --
> SUSE Labs, Novell Inc.
> -
--------
Nick Piggin, et al,

    First diffs would generate alot of noise, since I rip and insert
    alot of code based on whether I think the code is REALLY
    needed for MY TEST environment. These suggestions are
    basicly minimal merge suggestions between my
    development envir and the public Linux tree.

    Now the why for this SUGGESTION/PATCH...

> When we're in the (min,low) watermark range, we'll wake up kswapd
> _before_ allocating anything, so what is better about the change to
> wake up kswapd after allocating? Can you perhaps come up with an
> example situation also to make this more clear?

Answer
    Will GFP_ATOMIC alloc be failing at that point? If yes, then why
    not allow kswapd attempt to prevent this condition from occuring?
    The existing code reads that the first call to get_page_from_freelist()
    has returned no page. Now you are going to start up something that
    is at best going to take millisecs to start helping out. Won't it first
    grab some pages to do its work? So we are going to be lower
    in free memory right when it starts up. Right?

    So, before the change, with  high memory consumption/pressure,
    various GFP_xxx allocations would fail or take an excessive
    amount of time due to the simple fact of low memory and/or
    Slub/slab consumption and/or first failure of
    get_page_from_freelist() when in a  low free memory condition.

    Once the above condition occurs the perception is that the
    current mainline Linux code then on demand increases its
    effort to find some memory. However, while this is happening
    the system is in a low memory bind and various performance
    parameters are being effected and some allocations are
    sleeping or being delayed or outright failing.

    What I could see is that CURR suggestions allow a new class
    of GFP_xxx allocations to succeed while in low memory,
    try again philosophy, wake-up kswapd , etc, are all AFTER the
    fact while something is WAITING for the memory. This
    wait is in effect a SYNCHRONOUS wait for memory.

   Assuming that kswapd is really what is mostly needed.
   Execute it BEFORE (JUST IN TIME) to PREVENT low
   memory since I/O needs pages and  GFP_ATOMIC
    allocs fails and other GFP allocs sleeeeeping and....

  The SUGGESTION is to
   take the fraction of microsec longer in the fast path to see if
   it is needed to be started up and to ATTEMPT to prevent
   the SLOW-PATH and low/min memory from occuring.

    The 2x low memory is
    to allow some scalability and to allow it ENOUGH time to do what
    it needs to do, since I expect a minimum number of millisecs
    before it can move us away from low free memory. As the
    amount of memory increases in a system this probably could
    be decreased somewhat to maybe 1.25x.

    IF the above is good then the issue is how to optimize the heck
    out of the check.

    Mitchell Erblich



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
