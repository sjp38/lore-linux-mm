Date: Fri, 9 Aug 2002 12:53:00 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Broad questions about the current design
In-Reply-To: <66ABF318-ABAA-11D6-8D07-000393829FA4@cs.amherst.edu>
Message-ID: <Pine.LNX.4.44L.0208091234050.23404-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Scott Kaplan <sfkaplan@cs.amherst.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 9 Aug 2002, Scott Kaplan wrote:

> 1) What happened to page ages?  I found them in 2.4.0, but they're
>     gone by 2.4.19, and remain gone in 2.5.30.  The active list scan
>     seems to start at the tail and work its way towards the head,
>     demoting to the inactive list those pages whose reference bit is
>     cleared.  This seems to be like some kind of hybrid inbetween a
>     FIFO policy and a CLOCK algorithm.  Pages are inserted and scanned
>     based on the FIFO ordering, but given a second chance much like a
>     CLOCK.  Is a similar approach used for queuing pages for cleaning
>     and for reclaimation?  Am I interpreting this code in
>     refill_inactive correctly?

The thing is that there are now 4 different VMs for Linux:

- 2.4 mainline
- 2.4 -aa
- 2.4 -rmap
- 2.5

2.4 mainline and 2.4-aa are mostly the same, but 2.4 rmap has
the LRU lists completely per zone and uses page aging.

2.5 is halfway between the two when it comes to page replacement.

> 2) Is there only one inactive list now?  Again, somewhere between
>     2.4.0 and 2.4.19, inactive_dirty_list and the per-zone
>     inactive_clean_lists disappeared.  How are the inactive_clean
>     and inactive_dirty pages separated?  Or are they no longer kept
>     separate in that way, and simply distinguished when trying to
>     reclaim pages?

They are no longer separated out.

> 3) Does the scanning of pages (roughly every page within a minute)
>     create a lot of avoidable overhead?  I can see that such scanning
>     is necessary when page aging is used, as the ages must be updated
>     to maintain this frequency-of-use information.  However, in the
>     absence of page ages, scanning seems superfluous.  Some amount of
>     scanning for the purpose of flushing groups of dirty pages seems
>     appropriate, but that doesn't requiring the continual scanning of
>     all pages.  Clearing reference bits on roughly the same time scale
>     with which those bits are set could require regular and complete
>     scanning, but the value of that reference-bit-clearing has not been
>     clearly demonstrated (or has it?).
>
>     How much overhead *does* this scanning introduce?  Does it really
>     yield performance that is so much better than, say, a SEGQ
>     (CLOCK->LRU) structure with a single-handed clock?  Is it worth
>     raising this point when justifying rmap?  Specifically, we're
>     already accustomed to some amount of overhead in VM bookkeeping in
>     order to avoid bad memory management -- what fraction of the total
>     overhead would be due to rmap in bad cases when compared to this
>     overhead?

Good questions, I hope you'll be able to find answers because
I don't have them ;)

> Many thanks for answers and thoughts that you can provide.  I do have one
> other important question to me:  How much should I expect this code to
> continue to change?  Is this basic structure likely to change, or will
> there only be tuning improvements and minor modifications?

The code will probably keep changing on an almost monthly
basis until 2.6.0 is out. Your input in deciding what to
change would be very much welcome...

kind regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
