Date: Wed, 3 Aug 2005 08:59:33 +0200 (CEST)
From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: [RFC] Net vm deadlock fix (preliminary)
In-Reply-To: <200508031657.34948.phillips@istop.com>
Message-ID: <Pine.LNX.4.58.0508030826230.23501@tux.rsn.bth.se>
References: <200508031657.34948.phillips@istop.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@istop.com>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Aug 2005, Daniel Phillips wrote:

> Hi,
>
> Here is a preliminary patch, not tested at all, just to give everybody a
> target to aim bricks at.
>
>   * A new __GFP_MEMALLOC flag gives access to the memalloc reserve.
>
>   * In dev_alloc_skb, if GFP_ATOMIC fails then try again with __GFP_MEMALLOC.

This might give some unwanted side effects... Normally a NIC driver
has an rx-ring with skbs that are allocated by using dev_alloc_skb()
And before the memory got low the skbs in the ring was allocated using
GFP_ATOMIC and when packets are recieved the skb is passed up the stack
and if in the meantime (since the skb was allocated) memory got low the
checks for __GFP_MEMALLOC won't trigger as it isn't set in the skb.

And what's worse is that when memory is low new packets allocated with
dev_alloc_skb() will allocate them from __GFP_MEMALLOC, and then they are
placed in the rx-ring just waiting to be used which might not happen for a
while. One positive thing might be that at least some GFP_ATOMIC memory is
released in the befinning when the skbs in the rx-ring is beeing
reallocated.

So when memory gets tight, you won't notice __GFP_MEMALLOC for as many
packets as the rx-ring contains skbs. But you do allocate skbs with
__GFP_MEMALLOC just that they get stuffed into the rx-ring and will stay
there until used by incoming packets.
iirc, the e1000 driver defaults to a rx-ring size of 256 skbs.

One thing could be to utilize the skb copybreak that certain NIC drivers
implement. If the packetsize is rather small a new skb is allocated and
the data is copied from the skb in the rx-ring to the new skb which then
contains the __GFP_MEMALLOC and the GFP_ATOMIC skb stays in the rx-ring.
This could be used to avoid the problems above, but... it adds overhead to
all packets when memory isn't low since all packets needs to be copied and
the copy is more expensive for larger packets which slows things down
compared to not copying. If there's another way of detecting the low
memory situation other than a failing copy the copybreak abuse could be
enabled only when memory is low, that would probably get the best from
both worlds.

/Martin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
