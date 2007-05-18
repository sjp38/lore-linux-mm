Date: Fri, 18 May 2007 10:11:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/5] make slab gfp fair
In-Reply-To: <1179482054.2925.52.camel@lappy>
Message-ID: <Pine.LNX.4.64.0705181002400.9372@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
 <Pine.LNX.4.64.0705161957440.13458@schroedinger.engr.sgi.com>
 <1179385718.27354.17.camel@twins>  <Pine.LNX.4.64.0705171027390.17245@schroedinger.engr.sgi.com>
  <20070517175327.GX11115@waste.org>  <Pine.LNX.4.64.0705171101360.18085@schroedinger.engr.sgi.com>
  <1179429499.2925.26.camel@lappy>  <Pine.LNX.4.64.0705171220120.3043@schroedinger.engr.sgi.com>
  <1179437209.2925.29.camel@lappy>  <Pine.LNX.4.64.0705171516260.4593@schroedinger.engr.sgi.com>
 <1179482054.2925.52.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Fri, 18 May 2007, Peter Zijlstra wrote:

> On Thu, 2007-05-17 at 15:27 -0700, Christoph Lameter wrote:

> Isn't the zone mask the same for all allocations from a specific slab?
> If so, then the slab wide ->reserve_slab will still dtrt (barring
> cpusets).

All allocations from a single slab have the same set of allowed types of 
zones. I.e. a DMA slab can access only ZONE_DMA a regular slab 
ZONE_NORMAL, ZONE_DMA32 and ZONE_DMA.


> > On x86_64 systems you have the additional complication that there are 
> > even multiple DMA32 or NORMAL zones per node. Some will have DMA32 and 
> > NORMAL, others DMA32 alone or NORMAL alone. Which watermarks are we 
> > talking about?
> 
> Watermarks like used by the page allocator given the slabs zone mask.
> The page allocator will only fall back to ALLOC_NO_WATERMARKS when all
> target zones are exhausted.

That works if zones do not vary between slab requests. So on SMP (without 
extra gfp flags) we may be fine. But see other concerns below.

> > The use of ALLOC_NO_WATERMARKS depends on the contraints of the allocation 
> > in all cases. You can only compare the stresslevel (rank?) of allocations 
> > that have the same allocation constraints. The allocation constraints are
> > a result of gfp flags,
> 
> The gfp zone mask is constant per slab, no? It has to, because the zone
> mask is only used when the slab is extended, other allocations live off
> whatever was there before them.

The gfp zone mask is used to select the zones in a SMP config. But not in 
a NUMA configuration there the zones can come from multiple nodes.

Ok in an SMP configuration the zones are determined by the allocation 
flags. But then there are also the gfp flags that influence reclaim 
behavior. These also have an influence on the memory pressure.

These are

__GFP_IO
__GFP_FS
__GFP_NOMEMMALLOC
__GFP_NOFAIL
__GFP_NORETRY
__GFP_REPEAT

An allocation that can call into a filesystem or do I/O will have much 
less memory pressure to contend with. Are the ranks for an allocation
with __GFP_IO|__GFP_FS really comparable with an allocation that does not 
have these set?

> >  cpuset configuration and memory policies in effect.
> 
> Yes, I see now that these might become an issue, I will have to think on
> this.

Note that we have not yet investigated what weird effect memory policy 
constraints can have on this. There are issues with memory policies only 
applying to certain zones.....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
