Received: from oscar.casa.dyndns.org ([65.92.161.27])
          by tomts26-srv.bellnexxia.net
          (InterMail vM.5.01.04.19 201-253-122-122-119-20020516) with ESMTP
          id <20020828221156.ZHWU8287.tomts26-srv.bellnexxia.net@oscar.casa.dyndns.org>
          for <linux-mm@kvack.org>; Wed, 28 Aug 2002 18:11:56 -0400
Received: from oscar (localhost [127.0.0.1])
	by oscar.casa.dyndns.org (Postfix) with ESMTP id 552B0104A8
	for <linux-mm@kvack.org>; Wed, 28 Aug 2002 18:11:03 -0400 (EDT)
Content-Type: text/plain;
  charset="us-ascii"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: slablru for 2.5.32-mm1
Date: Wed, 28 Aug 2002 18:11:02 -0400
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200208281811.02568.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On August 28, 2002 05:24 pm, Andrew Morton wrote:
> Ed Tomlinson wrote:
> > Hi Andrew
> >
> > Here is slablru for 32-mm1.  This is based on a version ported to
> > 31ish-mm1.  It should be stable.  Its been booted as UP (32-mm1) and SMP
> > on UP  (31ish-mm1 only) and works as expected.
>
> Cool.  But the diff adds tons of stuff which is already added by -mm1.
> I suspect you diffed against 2.5.31 base?

Actually it was a typo.  I use bk for almost all my trees,  I typed the wrong 
rev number when generating the patch.  Net effect was a diff against
2.5.31 base.

> > Andrew, what do you thing about adding slablru to your experimental dir?
>
> No probs.

Thanks - I will not resend here.  Once its online I will announce here and on 
lkml.

> > One interesting change in this version.  We only add the first page of a
> > slab to the lru.  The reference bit setting logic for slabs has been
> > modified to set the bit on the first page. Pagevec created a little bit
> > of a problem for slablru.  How do we know the order of the slab page when
> > its being freed?   My solution is to use 3 bits in page->flags and save
> > the order there.  Then free_pages_ok was modified to take the order from
> > page->flags.  This was implement in a minimal fashion.  Think Wli is
> > working on a more elaborate version of this - fleshed out, it could be
> > used to support large pages in the vm.
>
> hm.  What happened to the idea of walking mem_map[], looking for
> continuation pages? (This would need to be done via pfn_to_page(), I
> guess).

Frankly, that idea made me shutter at bit.  Think this implementation is
cleaner at the expense of 3 bits (slab.c limits slab orders to 5) or 4 bits 
(system wide order limit is 10) if we use this for large 'page' support - 
Wli's comment was that code looked almost the same we just use 
different bits and names.  Think this way is safer and faster, costing 
a couple of bits more than the continuation page idea.

> > Second topic.
> >
> > I have also included an optimisation for vmscan.  I found that the
> > current code would reduce the inactive list to almost nothing when
> > applications create large numbers of active pages very quickly run (ie.
> > gimp loading and editing large 20m+ tiffs).  This reduces the problem.  
> > Always allowing nr_pages to be scanned caused the active list to be
> > reduced to almost nothing when something like gimp exited and we had
> > another task adding lots to the inactive list.  This is fixed here too. 
> > I do wonder if zone->refill_counter, as implemented, is a great idea.  Do
> > we really need/want to remember to scan the active list if it has
> > massively decreased in size because some app exited?  Maybe some sort of
> > decay logic should be used...
>
> Well the refill counter thingy is just an optimisation: rather than calling
> refill_inacative() lots of times to just grab two or three pages, we wait
> until it builds up to 32, and then go deactivate 32 pages.
>
> But ugh, it's a bit broken.  Yup, you're right.  Need to s/if/while/ in
> shrink_zone().

In some ways just do a simple s/if/while/ might be better.  This would
solve the 'memory' problem at the expense of more list activity.

> But we do need to slowly sift through the active list even when the
> inactive list is enormously bigger.  Otherwise, completely dead pages will
> remain in-core forever if there's a lot of pagecache activity going on.

Yes.  When I originally coded slablru I put the pages on the active list.  Turned
out that the time it took them to get to the bottom of the inactive list was such
that I ended up with _lots_ of dead pages in the active list... 

Ed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
