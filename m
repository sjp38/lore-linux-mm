Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water
	marks
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20070823120819.GO13915@v2.random>
References: <20070820215040.937296148@sgi.com>
	 <1187692586.6114.211.camel@twins>
	 <Pine.LNX.4.64.0708211347480.3082@schroedinger.engr.sgi.com>
	 <1187730812.5463.12.camel@lappy>
	 <Pine.LNX.4.64.0708211418120.3267@schroedinger.engr.sgi.com>
	 <1187734144.5463.35.camel@lappy>  <20070823120819.GO13915@v2.random>
Content-Type: text/plain
Date: Thu, 23 Aug 2007 14:59:48 +0200
Message-Id: <1187873988.6114.388.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-23 at 14:08 +0200, Andrea Arcangeli wrote:
> On Wed, Aug 22, 2007 at 12:09:03AM +0200, Peter Zijlstra wrote:
> > Strictly speaking:
> > 
> > if:
> > 
> >  page = alloc_page(gfp);
> > 
> > fails but:
> > 
> >  obj = kmem_cache_alloc(s, gfp);
> > 
> > succeeds then its a bug.
> 
> Why? this is like saying that if alloc_pages(order=1) fails but
> alloc_pages(order=0) succeeds then it's a bug. Obviously it's not a
> bug.
> 
> The only bug is if slab allocations <=4k fails despite
> alloc_pages(order=0) would succeed.

That would be currently true. However I need it to be stricter.

I'm wanting to do networked swap. And in order to be able to receive
writeout completions when in the PF_MEMALLOC region I need to introduce
a new network state. This is because it needs to operate in a steady
state with limited (bounded) memory use.

Normal network either consumes memory, or fails to receive anything at
all.

So this new network state will allocate space for a packet, receive the
packet from the NIC, inspect the packet, and toss the packet when its
not found to be aimed at the VM (ie. does not contain a writeout
completion).

So the total memory consumption of this state is 0 - it always frees
what it takes, but the memory use is non 0 but bounded - it does
temporarily use memory, but will limit itself to never exceed a given
maximum)

Because the network stack runs on the slab allocator in generic (both
kmem_cache and kmalloc) I need this extra guarantee so that a slab
allocated from the reserves will not serve objects to some random
non-critical application.

If this is not restricted this network state can leak memory to outside
of PF_MEMALLOC and will not be stable.

So what I need is:

  kmem_cache_alloc(s, gfp) to fail when alloc_page(gfp) fails

agreeing on the extra condition:

  when kmem_cache_size(s) <= PAGE_SIZE

and the extra note that:

  I only really need it to fail for ALLOC_NO_WATERMARKS, the other
  levels like ALLOC_HIGH and ALLOC_HARDER are not critical.

Which ends up with:

  if the current gfp-context does not allow ALLOC_NO_WATERMARKS
allocations, and alloc_page() fails, so must kmem_cache_alloc(s,) if
kmem_cache_size(s) <= PAGE_SIZE.

(yes this leaves jumbo frames broken)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
