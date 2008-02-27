Subject: Re: [PATCH 00/28] Swap over NFS -v16
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <18372.64081.995262.986841@notabene.brown>
References: <20080220144610.548202000@chello.nl>
	 <20080223000620.7fee8ff8.akpm@linux-foundation.org>
	 <18371.43950.150842.429997@notabene.brown>
	 <1204023042.6242.271.camel@lappy>
	 <18372.64081.995262.986841@notabene.brown>
Content-Type: text/plain
Date: Wed, 27 Feb 2008 08:58:32 +0100
Message-Id: <1204099113.6242.353.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Wed, 2008-02-27 at 16:51 +1100, Neil Brown wrote:
> Hi Peter,
> 
> On Tuesday February 26, a.p.zijlstra@chello.nl wrote:
> > Hi Neil,
> > 
> > Thanks for taking a look, and giving such elaborate feedback. I'll try
> > and address these issues asap, but first let me reply to a few points
> > here.
> 
> Thanks... the tree thing is starting to make sense, and I'm not
> confused my __mem_reserve_add any more :-)
> 
> I've been having a closer read of some of the code that I skimmed over
> before and I have some more questions.
> 
> 1/ I note there is no way to tell if memory returned by kmalloc is
>   from the emergency reserve - which contrasts with alloc_page
>   which does make that information available through page->reserve.
>   This seems a slightly unfortunate aspect of the interface.

Yes, but alas there is no room to store such information in kmalloc().
That is, in a sane way. I think it was Daniel Phillips who suggested
encoding it in the return pointer by flipping the low bit - but that is
just too ugly and breaks all current kmalloc sites to boot.

>   It seems to me that __alloc_skb could be simpler if this
>   information was available.  It currently tries the allocation
>   normally, then if that fails it retries with __GFP_MEMALLOC set and
>   if that works it assume it was from the emergency pool ... which it
>   might not be, though the assumption is safe enough.
> 
>   It would seem to be nicer if you could just make the one alloc call,
>   setting GFP_MEMALLOC if that might be appropriate.  Then if the
>   memory came from the emergency reserve, flag it as an emergency skb.
> 
>   However doing that would have issues with reservations.... the
>   mem_reserve would need to be passed to kmalloc :-(

Yes, it would require a massive overhaul of quite a few things. I agree,
it would all be nicer, but I think you see why I didn't do it.

> 2/ It doesn't appear to be possible to wait on a reservation. i.e. if
>    mem_reserve_*_charge fails, we might sometimes want to wait until
>    it will succeed.  This feature is an integral part of how mempools
>    work and are used.  If you want reservations to (be able to)
>    replace mempools, then waiting really is needed.
> 
>    It seems that waiting would work best if it was done quite low down
>    inside kmalloc.  That would require kmalloc to know which
>    'mem_reserve' you are using which it currently doesn't.
> 
>    If it did, then it could choose to use emergency pages if the
>    mem_reserve allowed it more space, otherwise require a regular page.
>    And if __GFP_WAIT is set then each time around the loop it could
>    revise whether to use an emergency page or not, based on whether it
>    can successfully charge the reservation.

Like mempools, we could add a wrapper with a mem_reserve and waitqueue
inside, strip __GFP_WAIT, try, see if the reservation allows, and wait
if not.

I haven't yet done such a wrapper because it wasn't needed. But it could
be done.

>    Of course, having a mem_reserve available for PF_MEMALLOC
>    allocations would require changing every kmalloc call in the
>    protected region, which might not be ideal, but might not be a
>    major hassle, and would ensure that you find all kmalloc calls that
>    might be made while in PF_MALLOC state.

I assumed the current PF_MEMALLOC usage was good enough for the current
reserves - not quite true as its potentially unlimited, but it seems to
work in practise.

I did try to find all allocation sites in the paths I enabled
PF_MEMALLOC over.

> 3/ Thinking about the tree structure a bit more:  Your motivation
>    seems to be that it allows you to make two separate reservations,
>    and then charge some memory usage again either-one-of-the-other.
>    This seems to go against a key attribute of reservations.  I would
>    have thought that an important rule about reservations is that
>    no-one else can use memory reserved for a particular purpose.
>    So if IPv6 reserves some memory, and the IPv4 uses it, that doesn't
>    seem like something we want to encourage...

Well, we only have one kind of skb, a network packet doesn't know if it
belongs to IPv4 or IPv6 (or yet a whole different address familiy) when
it comes in. So we grow the skb pool to overflow both defragment caches.

But yeah, its something where you need to know what you're doing - as
with so many other things in the kernel, hence I didn't worry too much.

> 4/ __netdev_alloc_page is bothering me a bit.
>    This is used to allocate memory for incoming fragments in a
>    (potentially multi-fragment) packet.  But we only rx_emergency_get
>    for each page as it arrives rather than all at once at the start.
>    So you could have a situation where two very large packets are
>    arriving at the same time and there is enough reserve to hold
>    either of them but not both.  The current code will hand out that
>    reservation a little (well, one page) at a time to each packet and
>    will run out before either packet has been fully received.  This
>    seems like a bad thing.  Is it?
> 
>    Is it possible to do the rx_emergency_get just once of the whole
>    packet I wonder?

I honestly don't know enough about network cards and drivers to answer
this. It was a great feat I managed this much :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
