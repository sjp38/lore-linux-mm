Subject: Re: [PATCH 0/5] make slab gfp fair
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0705171516260.4593@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
	 <Pine.LNX.4.64.0705161957440.13458@schroedinger.engr.sgi.com>
	 <1179385718.27354.17.camel@twins>
	 <Pine.LNX.4.64.0705171027390.17245@schroedinger.engr.sgi.com>
	 <20070517175327.GX11115@waste.org>
	 <Pine.LNX.4.64.0705171101360.18085@schroedinger.engr.sgi.com>
	 <1179429499.2925.26.camel@lappy>
	 <Pine.LNX.4.64.0705171220120.3043@schroedinger.engr.sgi.com>
	 <1179437209.2925.29.camel@lappy>
	 <Pine.LNX.4.64.0705171516260.4593@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 18 May 2007 11:54:14 +0200
Message-Id: <1179482054.2925.52.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-05-17 at 15:27 -0700, Christoph Lameter wrote:
> On Thu, 17 May 2007, Peter Zijlstra wrote:
> 
> > The way I read the cpuset page allocator, it will only respect the
> > cpuset if there is memory aplenty. Otherwise it will grab whatever. So
> > still, it will only ever use ALLOC_NO_WATERMARKS if the whole system is
> > in distress.
> 
> Sorry no. The purpose of the cpuset is to limit memory for an application. 
> If the boundaries would be fluid then we would not need cpusets.

Right, I see that I missed an ALLOC_CPUSET yesterday; but like Paul
said, cpusets are ignored when in dire straights for an kernel alloc.

Just not enough to make inter-cpuset interaction on slabs go away wrt
ALLOC_NO_WATERMARK :-/

> But the same principles also apply for allocations to different zones in a 
> SMP system. There are 4 zones DMA DMA32 NORMAL and HIGHMEM and we have 
> general slabs for DMA and NORMAL. A slab that uses zone NORMAL falls back 
> to DMA32 and DMA depending on the watermarks of the 3 zones. So a 
> ZONE_NORMAL slab can exhaust memory available for ZONE_DMA.
> 
> Again the question is the watermarks of which zone? In case of the 
> ZONE_NORMAL allocation you have 3 to pick from. Its the last one? Then its 
> the same as ZONE_DMA, and you got a collision with the corresponding
> DMA slab. Depending the system deciding on a zone where we allocate the 
> page from you may get a different watermark situation.

Isn't the zone mask the same for all allocations from a specific slab?
If so, then the slab wide ->reserve_slab will still dtrt (barring
cpusets).

> On x86_64 systems you have the additional complication that there are 
> even multiple DMA32 or NORMAL zones per node. Some will have DMA32 and 
> NORMAL, others DMA32 alone or NORMAL alone. Which watermarks are we 
> talking about?

Watermarks like used by the page allocator given the slabs zone mask.
The page allocator will only fall back to ALLOC_NO_WATERMARKS when all
target zones are exhausted.

> The use of ALLOC_NO_WATERMARKS depends on the contraints of the allocation 
> in all cases. You can only compare the stresslevel (rank?) of allocations 
> that have the same allocation constraints. The allocation constraints are
> a result of gfp flags,

The gfp zone mask is constant per slab, no? It has to, because the zone
mask is only used when the slab is extended, other allocations live off
whatever was there before them.

>  cpuset configuration and memory policies in effect.

Yes, I see now that these might become an issue, I will have to think on
this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
