From: Daniel Phillips <phillips@istop.com>
Subject: Re: [RFC] Net vm deadlock fix (preliminary)
Date: Thu, 4 Aug 2005 06:06:07 +1000
References: <200508031657.34948.phillips@istop.com> <200508040336.25761.phillips@istop.com> <1123093305.11483.21.camel@localhost.localdomain>
In-Reply-To: <1123093305.11483.21.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508040606.07769.phillips@istop.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Josefsson <gandalf@wlug.westbo.se>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 04 August 2005 04:21, Martin Josefsson wrote:
> On Thu, 2005-08-04 at 03:36 +1000, Daniel Phillips wrote:
> > I can think of two ways to deal with this:
> >
> >   1) Mindlessly include the entire maximum memory usage of the rx-ring in
> >      the reserve requirement (e.g., (maxskbs * (MTU + k)) / PAGE_SIZE).
>
> Would be dependent on the numberof interfaces as well.

Actually, just the number of interfaces being used by network block IO.  
Theoretically unbounded, but not an immediate problem.  This goes on the 
"must fix in order to be perfect" list.

> >   2) Never refill the rx-ring from the reserve.  Instead, if the skbs
> > ever run out (because e1000_alloc_rx_buffers had too many GFP_ATOMIC
> > alloc failures) then use __GFP_MEMALLOC instead of just giving up at that
> > point.
>
> This is how e1000 currently works (suggestions have been made to change
> this to work like the tg3 driver does which has copybreak support etc)
>
> 1. Allocate skbs filling the rx-ring as much as possible
> 2. tell hardware there's new skbs to DMA packets into
> 3. note that an skb has been filled with data (interrupt or polling)
> 4. remove that skb from the rx-ring
> 5. pass the skb up the stack
> 6. goto 3 if quota hasn't been filled
> 7. goto 1 if quota has been filled

Thanks, I originally missed the part about the hardware requiring at least one 
skb in the ring, or else it will drop a packet.

> The skbs allocated to fill the rx-ring are the _same_ skbs that are
> passed up the stack. So you won't see __GFP_MEMALLOC allocated skbs
> until RX_RINGSIZE packets after we got low on memory (fifo ring). I
> can't really say I see how #2 above solves that since we _have_ to
> allocate skbs to fill the rx-ring, otherwise the NIC won't have anywhere
> to put the received packets and will thus drop them in hardware.
>
> Or are you suggesting to let the rx-ring deplete until completely empty
> (or nearly empty) if we are low on memory, and only then start falling
> back to allocating with __GFP_MEMALLOC if GFP_ATOMIC fails?

Yes, exactly.  Except as you point out "completely empty" won't do.  We will 
use the __GFP_MEMALLOC (or alternatively, mempool) to ensure that the rx_ring 
always has at least some minimum number N of packets in it, and reserve N*MTU 
pages for the interface.  Actually, we will reserve considerably more than 
that, because we want to be able to have a fairly large number of packets in 
flight on the block IO path, particularly under memory pressure.

It doesn't actually matter which packet we return to the reserve, so we might 
want to just count the number of __GFP_MEMALLOC packets in the ring and 
deliver on the direct (non-softnet) path until the count drops to zero.  
Which implies a slightly different approach to the is_memalloc_skb flagging.  
This is just a refinement though, it does not really matter when we reclaim a 
reserve buffer as long as we are certain to reclaim it.

> That could and probably would cause hardware to drop packets because it
> can run out of fresh rx-descriptors before we manage to start allocating
> with __GFP_MEMALLOC if the packetrate is high, at least it makes it much
> more likely to happen.

It is a matter of setting N, the minimum number of packets in the rx ring high 
enough, no?

OK, the next step is to reroll the patch and make it specific to e1000, which 
I happen to have here and can test.  Also, I will use a mempool this time, so 
we will see how that code looks.

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
