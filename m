From: Daniel Phillips <phillips@istop.com>
Subject: Re: [RFC] Net vm deadlock fix (preliminary)
References: <200508031657.34948.phillips@istop.com> <Pine.LNX.4.58.0508030826230.23501@tux.rsn.bth.se>
In-Reply-To: <Pine.LNX.4.58.0508030826230.23501@tux.rsn.bth.se>
MIME-Version: 1.0
Content-Disposition: inline
Date: Thu, 4 Aug 2005 03:36:25 +1000
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200508040336.25761.phillips@istop.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Josefsson <gandalf@wlug.westbo.se>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 03 August 2005 16:59, Martin Josefsson wrote:
> On Wed, 3 Aug 2005, Daniel Phillips wrote:
> > Hi,
> >
> > Here is a preliminary patch, not tested at all, just to give everybody a
> > target to aim bricks at.
> >
> >   * A new __GFP_MEMALLOC flag gives access to the memalloc reserve.
> >
> >   * In dev_alloc_skb, if GFP_ATOMIC fails then try again with
> > __GFP_MEMALLOC.
>
> This might give some unwanted side effects... 

You are right, and it was a bad idea to try to do this fix generically for all 
drivers at once, see below.

> Normally a NIC driver 
> has an rx-ring with skbs that are allocated by using dev_alloc_skb()
> And before the memory got low the skbs in the ring was allocated using
> GFP_ATOMIC and when packets are recieved the skb is passed up the stack
> and if in the meantime (since the skb was allocated) memory got low the
> checks for __GFP_MEMALLOC won't trigger as it isn't set in the skb.
>
> And what's worse is that when memory is low new packets allocated with
> dev_alloc_skb() will allocate them from __GFP_MEMALLOC, and then they are
> placed in the rx-ring just waiting to be used which might not happen for a
> while. One positive thing might be that at least some GFP_ATOMIC memory is
> released in the befinning when the skbs in the rx-ring is beeing
> reallocated.
>
> So when memory gets tight, you won't notice __GFP_MEMALLOC for as many
> packets as the rx-ring contains skbs. But you do allocate skbs with
> __GFP_MEMALLOC just that they get stuffed into the rx-ring and will stay
> there until used by incoming packets.
> iirc, the e1000 driver defaults to a rx-ring size of 256 skbs.

Yep, yep and yep.

I can think of two ways to deal with this:

  1) Mindlessly include the entire maximum memory usage of the rx-ring in
     the reserve requirement (e.g., (maxskbs * (MTU + k)) / PAGE_SIZE).

  2) Never refill the rx-ring from the reserve.  Instead, if the skbs ever
     run out (because e1000_alloc_rx_buffers had too many GFP_ATOMIC alloc
     failures) then use __GFP_MEMALLOC instead of just giving up at that
     point.
     
(1) is the quick fix, (2) is the proper fix.  (2) also implies auditing every 
net driver to ensure its usage is "block IO safe".  I made a valiant attempt 
to handle this in just __dev_alloc_skb, but really it just drives the point 
home that there is no substitute for laying out the memory allocation 
rules for drivers and making sure they are followed.

We can soften the pain of this by classifying net drivers as block-io-safe or 
not with a capability flag, and fix them up incrementally.  The resulting 
memory usage audit can be nothing but good, I bet the code gets smaller too.  
It would be easy to log a warning any time network block IO is attempted over 
an unfixed driver.  This will be just as unsafe as it ever was and exactly as 
efficient.

If the driver is block-io-safe, it will use __GFP_MEMALLOC (if we ultimately 
decide to use that instead of mempools) and the fallback allocation+delivery 
path.  The fast path will be the same as it ever was, because packets taking 
the fallback path will be ones that would have been dropped before.  Packets 
allocated from reserve that pass the check in the protocol driver are ones 
that would have been dropped _in the block io path_, so rescuing these not 
only fixes the deadlock, but is a huge efficiency win.

> One thing could be to utilize the skb copybreak that certain NIC drivers
> implement. If the packetsize is rather small a new skb is allocated and
> the data is copied from the skb in the rx-ring to the new skb which then
> contains the __GFP_MEMALLOC and the GFP_ATOMIC skb stays in the rx-ring.
> This could be used to avoid the problems above, but... it adds overhead to
> all packets when memory isn't low since all packets needs to be copied and
> the copy is more expensive for larger packets which slows things down
> compared to not copying.

I am have not looked at the copybreak feature (its memory requirements 
certainly need to be analyzed) but my suggestion above does not hurt the 
fast path and does divide the allocation class properly between 
__GFP_MEMALLOC and GFP_ATOMIC, as you noticed is necessary.

(Note that, in all of this, there is the temptation to substitute mempools for 
__GFP_MEMALLOC.  This doesn't change the analysis at all, it just changes the 
details of the API.  We still have to fix the drivers and protocols in all 
the same places.)

> If there's another way of detecting the low 
> memory situation other than a failing copy the copybreak abuse could be
> enabled only when memory is low, that would probably get the best from
> both worlds.

Checking whether memory is low is a somewhat expensive operation because we 
have to walk through all the allocation zones according to the allocation 
class requested and check the bounds.  So at the moment, non-vm code detects 
low memory only through failed allocations.  We should have a separate, 
efficient api for detecting "out of normal memory", but the immediate issue is 
killing the network block io deadlock.

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
