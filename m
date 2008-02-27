From: Neil Brown <neilb@suse.de>
Date: Wed, 27 Feb 2008 16:51:13 +1100
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18372.64081.995262.986841@notabene.brown>
Subject: Re: [PATCH 00/28] Swap over NFS -v16
In-Reply-To: message from Peter Zijlstra on Tuesday February 26
References: <20080220144610.548202000@chello.nl>
	<20080223000620.7fee8ff8.akpm@linux-foundation.org>
	<18371.43950.150842.429997@notabene.brown>
	<1204023042.6242.271.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

Hi Peter,

On Tuesday February 26, a.p.zijlstra@chello.nl wrote:
> Hi Neil,
> 
> Thanks for taking a look, and giving such elaborate feedback. I'll try
> and address these issues asap, but first let me reply to a few points
> here.

Thanks... the tree thing is starting to make sense, and I'm not
confused my __mem_reserve_add any more :-)

I've been having a closer read of some of the code that I skimmed over
before and I have some more questions.

1/ I note there is no way to tell if memory returned by kmalloc is
  from the emergency reserve - which contrasts with alloc_page
  which does make that information available through page->reserve.
  This seems a slightly unfortunate aspect of the interface.

  It seems to me that __alloc_skb could be simpler if this
  information was available.  It currently tries the allocation
  normally, then if that fails it retries with __GFP_MEMALLOC set and
  if that works it assume it was from the emergency pool ... which it
  might not be, though the assumption is safe enough.

  It would seem to be nicer if you could just make the one alloc call,
  setting GFP_MEMALLOC if that might be appropriate.  Then if the
  memory came from the emergency reserve, flag it as an emergency skb.

  However doing that would have issues with reservations.... the
  mem_reserve would need to be passed to kmalloc :-(

2/ It doesn't appear to be possible to wait on a reservation. i.e. if
   mem_reserve_*_charge fails, we might sometimes want to wait until
   it will succeed.  This feature is an integral part of how mempools
   work and are used.  If you want reservations to (be able to)
   replace mempools, then waiting really is needed.

   It seems that waiting would work best if it was done quite low down
   inside kmalloc.  That would require kmalloc to know which
   'mem_reserve' you are using which it currently doesn't.

   If it did, then it could choose to use emergency pages if the
   mem_reserve allowed it more space, otherwise require a regular page.
   And if __GFP_WAIT is set then each time around the loop it could
   revise whether to use an emergency page or not, based on whether it
   can successfully charge the reservation.

   Of course, having a mem_reserve available for PF_MEMALLOC
   allocations would require changing every kmalloc call in the
   protected region, which might not be ideal, but might not be a
   major hassle, and would ensure that you find all kmalloc calls that
   might be made while in PF_MALLOC state.

3/ Thinking about the tree structure a bit more:  Your motivation
   seems to be that it allows you to make two separate reservations,
   and then charge some memory usage again either-one-of-the-other.
   This seems to go against a key attribute of reservations.  I would
   have thought that an important rule about reservations is that
   no-one else can use memory reserved for a particular purpose.
   So if IPv6 reserves some memory, and the IPv4 uses it, that doesn't
   seem like something we want to encourage...


4/ __netdev_alloc_page is bothering me a bit.
   This is used to allocate memory for incoming fragments in a
   (potentially multi-fragment) packet.  But we only rx_emergency_get
   for each page as it arrives rather than all at once at the start.
   So you could have a situation where two very large packets are
   arriving at the same time and there is enough reserve to hold
   either of them but not both.  The current code will hand out that
   reservation a little (well, one page) at a time to each packet and
   will run out before either packet has been fully received.  This
   seems like a bad thing.  Is it?

   Is it possible to do the rx_emergency_get just once of the whole
   packet I wonder?

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
