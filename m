Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: Broad questions about the current design
Date: Mon, 12 Aug 2002 11:13:15 +0200
References: <66ABF318-ABAA-11D6-8D07-000393829FA4@cs.amherst.edu>
In-Reply-To: <66ABF318-ABAA-11D6-8D07-000393829FA4@cs.amherst.edu>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17eBGG-0001nL-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Scott Kaplan <sfkaplan@cs.amherst.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 09 August 2002 17:12, Scott Kaplan wrote:
> 1) What happened to page ages?  I found them in 2.4.0, but they're
>     gone by 2.4.19, and remain gone in 2.5.30.

One day, around 2.4.9, Andrea showed up on lkml with a 'VM rewrite', which 
replaced the page aging with a simpler LRU mechanism (described below).  As 
we had never managed to get Rik's aging mechanism tuned so that it would 
behave predictably in corner cases, Linus decided to switch out the whole 
aging mechanism in favor or Andrea's patch.  Though the decision was 
controversial at the time, it turned out to be quite correct, as you can see 
that VM-related complaints on lkml dropped off rapidly starting from that 
time.

The jury is still out as to whether aging or LRU is the better page 
replacement policy, and to date, no formal comparisons have been done.

>     The active list scan
>     seems to start at the tail and work its way towards the head,
>     demoting to the inactive list those pages whose reference bit is
>     cleared.  This seems to be like some kind of hybrid inbetween a
>     FIFO policy and a CLOCK algorithm.  Pages are inserted and scanned
>     based on the FIFO ordering, but given a second chance much like a
>     CLOCK.  Is a similar approach used for queuing pages for cleaning
>     and for reclaimation?  Am I interpreting this code in
>     refill_inactive correctly?
>

This code implements the LRU on the active list:

http://lxr.linux.no/source/mm/vmscan.c?v=2.5.28#L349:

349                 if (page->pte.chain && page_referenced(page)) {
350                         list_del(&page->lru);
351                         list_add(&page->lru, &active_list);
352                         pte_chain_unlock(page);
353                         continue;
354                 }

Yes, it was supposed to be LRU but as you point out, it's merely a clock.
It would be an LRU if the list deletion and reinsertion occured directly in 
try_to_swap_out, but there the page referenced bit is merely set.  I asked
Andrea why he did not do this and he wasn't sure, but he thought that maybe 
the way he did it was more efficient.

For any page that is explicitly touched, e.g., by file IO, we use 
activate_page, which moves the page to the head of the active list regardless 
of which list the page is currently on.  This is a classic LRU.

http://lxr.linux.no/source/mm/swap.c?v=2.5.28#L39:

39 static inline void activate_page_nolock(struct page * page)
40 {
41         if (PageLRU(page) && !PageActive(page)) {
42                 del_page_from_inactive_list(page);
43                 add_page_to_active_list(page);
44                 KERNEL_STAT_INC(pgactivate);
45         }
46 }

The inactive list is a fifo queue.  So you have a (sort-of) LRU feeding pages
from its cold end into the FIFO, and if the page stays on the FIFO long 
enough to reach the code end it gets evicted, or at least it starts on the
process.  It's a fairly effective arrangement, except for the part about not 
really implementing the LRU properly, and needing to find page referenced 
bits by virtual scanning.  The latter means that the referenced information 
at the cold end of the LRU and FIFO is unreliable.

The LRU behavior would be better, I suppose, if the page activation were done 
in try_to_swap_out.  I haven't tried this, because I think it's more 
important to get the reverse mapping work nailed down so that the page 
referenced information is reliable.  Otherwise, tuning the scanner is just 
too frustrating, and better left to those who, by instinct, can keep Fiats 
running ;-)

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
