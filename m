Date: Fri, 9 Aug 2002 08:52:31 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Broad questions about the current design
Message-ID: <20020809155231.GA10785@holomorphy.com>
References: <66ABF318-ABAA-11D6-8D07-000393829FA4@cs.amherst.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <66ABF318-ABAA-11D6-8D07-000393829FA4@cs.amherst.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Scott Kaplan <sfkaplan@cs.amherst.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2002 at 11:12:20AM -0400, Scott Kaplan wrote:
> 1) What happened to page ages?  I found them in 2.4.0, but they're
>    gone by 2.4.19, and remain gone in 2.5.30.  The active list scan
>    seems to start at the tail and work its way towards the head,
>    demoting to the inactive list those pages whose reference bit is
>    cleared.  This seems to be like some kind of hybrid inbetween a
>    FIFO policy and a CLOCK algorithm.  Pages are inserted and scanned
>    based on the FIFO ordering, but given a second chance much like a
>    CLOCK.  Is a similar approach used for queuing pages for cleaning
>    and for reclaimation?  Am I interpreting this code in
>    refill_inactive correctly?

The cleaning and reclamation are done in the same pass AFAICT.
As (little as) I understand it, it's a highly unusual algorithm.


On Fri, Aug 09, 2002 at 11:12:20AM -0400, Scott Kaplan wrote:
> 2) Is there only one inactive list now?  Again, somewhere between
>    2.4.0 and 2.4.19, inactive_dirty_list and the per-zone
>    inactive_clean_lists disappeared.  How are the inactive_clean
>    and inactive_dirty pages separated?  Or are they no longer kept
>    separate in that way, and simply distinguished when trying to
>    reclaim pages?

Pending patches for 2.5.30 make it per-zone. 2.4.x will stay as it is.
The search problem created by ZONE_DMA/ZONE_NORMAL/ZONE_HIGHMEM
mixtures in queues can be severe.


On Fri, Aug 09, 2002 at 11:12:20AM -0400, Scott Kaplan wrote:
> 3) Does the scanning of pages (roughly every page within a minute)
>    create a lot of avoidable overhead?  I can see that such scanning
>    is necessary when page aging is used, as the ages must be updated
>    to maintain this frequency-of-use information.  However, in the
>    absence of page ages, scanning seems superfluous.  Some amount of
>    scanning for the purpose of flushing groups of dirty pages seems
>    appropriate, but that doesn't requiring the continual scanning of
>    all pages.  Clearing reference bits on roughly the same time scale
>    with which those bits are set could require regular and complete
>    scanning, but the value of that reference-bit-clearing has not been
>    clearly demonstrated (or has it?).

I suspect it is overzealous. The attack on the CPU consumption of the
page replacement algorithms has generally been on making the searches
more efficient, not on reducing the frequency of scanning. rmap *should*
be able to get away with a lot less scanning because it can get at the
pte's directly. Page replacement is not my primary focus, though.


On Fri, Aug 09, 2002 at 11:12:20AM -0400, Scott Kaplan wrote:
>    How much overhead *does* this scanning introduce?  Does it really
>    yield performance that is so much better than, say, a SEGQ
>    (CLOCK->LRU) structure with a single-handed clock?  Is it worth
>    raising this point when justifying rmap?  Specifically, we're
>    already accustomed to some amount of overhead in VM bookkeeping in
>    order to avoid bad memory management -- what fraction of the total
>    overhead would be due to rmap in bad cases when compared to this
>    overhead?

I haven't seen an implementation of it. Not sure if others have, either.
Might be worth checking out, but I'm tied up with superpages (yes,
Hubertus, I've got a diff or two for you after I finish this mail).


On Fri, Aug 09, 2002 at 11:12:20AM -0400, Scott Kaplan wrote:
> Many thanks for answers and thoughts that you can provide.  I do have one 
> other important question to me:  How much should I expect this code to 
> continue to change?  Is this basic structure likely to change, or will 
> there only be tuning improvements and minor modifications?

The page replacement bits in the VM are *ahem* frequently rewritten,
though some things (e.g. buddy system, software pagetable stuff) seem
to rarely be touched.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
