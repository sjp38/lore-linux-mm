From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] Make the slab allocator observe NUMA policies
Date: Mon, 14 Nov 2005 19:44:33 +0100
References: <Pine.LNX.4.62.0511101401390.16481@schroedinger.engr.sgi.com> <200511131222.48690.ak@suse.de> <Pine.LNX.4.62.0511141002050.353@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0511141002050.353@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511141944.33478.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: steiner@sgi.com, linux-mm@kvack.org, alokk@calsoftinc.com
List-ID: <linux-mm.kvack.org>

On Monday 14 November 2005 19:05, Christoph Lameter wrote:
> On Sun, 13 Nov 2005, Andi Kleen wrote:
> 
> > On Friday 11 November 2005 18:40, Christoph Lameter wrote:
> > 
> > > Hmm. Thats not easy to do since the slab allocator is managing the pages 
> > > in terms of the nodes where they are located. The whole thing is geared to 
> > > first inspect the lists for one node and then expand if no page is 
> > > available.
> > 
> > Yes, that's fine - as long as it doesn't allocate too many 
> > pages at one go (which it doesn't) then the interleaving should
> > even the allocations out at page level.
> 
> The slab allocator may allocate pages higher orders which need to 
> be physically continuous. 

> Any idea how to push this to the page allocation within the slab without 
> rearchitecting the thing?

I believe that's only a small fraction of the allocations, for where
the slabs are big enough to be an significant part of the page.

Proof: VM breaks down with higher orders. If slab would use them
all the time it would break down too. It doesn't. Q.E.D ;-)

Also looking at the objsize colum in /proc/slabinfo most slabs are
significantly smaller than a page and the higher kmalloc slabs don't have 
too many objects, so slab shouldn't do this too often.

You're right they're a problem, but perhaps they can be just ignored
(like if they are <20% of the allocations the inbalance resulting
from them might not be too bad)

Another way (as a backup option) would be to RR them as higher order pages, 
but that would need new special code.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
