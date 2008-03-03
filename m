Date: Mon, 3 Mar 2008 15:34:13 -0600
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 6/8] slub: Adjust order boundaries and minimum objects per slab.
Message-ID: <20080303213412.GD10223@waste.org>
References: <20080229044803.482012397@sgi.com> <20080229044819.800974712@sgi.com> <47C7BFFA.9010402@cs.helsinki.fi> <Pine.LNX.4.64.0802291139560.11084@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0803011148320.19118@sbz-30.cs.Helsinki.FI> <Pine.LNX.4.64.0803030950010.6010@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803030950010.6010@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 03, 2008 at 09:52:55AM -0800, Christoph Lameter wrote:
> On Sat, 1 Mar 2008, Pekka J Enberg wrote:
> 
> > On Fri, 29 Feb 2008, Christoph Lameter wrote:
> > > The defaults for slab are also 60 objects per slab. The PAGE_SHIFT says 
> > > nothing about the big iron. Our new big irons have a page shift of 12 and 
> > > are x86_64.
> > 
> > Where is that objects per slab limit? I only see calculate_slab_order() 
> > trying out bunch of page orders until we hit "acceptable" internal 
> > fragmentation. Also keep in mind how badly SLAB compares to SLUB and SLOB 
> > in terms of memory efficiency.
> 
> slub_min_objects sets that limit.
>  
> > On Fri, 29 Feb 2008, Christoph Lameter wrote:
> > > We could drop the limit if CONFIG_EMBEDDED is set but then this may waste 
> > > space. A higher order allows slub to reach a higher object density (in 
> > > particular for objects 500-2000 bytes size).
> > 
> > I am more worried about memory allocated for objects that are not used 
> > rather than memory wasted due to bad fitting.
> 
> Is there any way to quantify this? This is likely only an effect that 
> mostly matters for rarely used slabs (the merging reduces that effect). 
> F.e. fitting more inodes or dentries into a single slab increases object 
> density.

On the other hand, a single object can now pin 64k in memory rather
than 4k. So when we collapse some cache under memory pressure, we're
not likely to free as much.

I know you've put a lot of effort into dealing with the dcache and
icache instances of this, but this could very well offset most of that.

Also, we might consider only allocating an order-1 slab if we've
filled an order-0, and so on. When we hit pressure, we kick our
order counter back to 0.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
