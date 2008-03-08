Date: Sat, 8 Mar 2008 12:54:08 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [8/13] Enable the mask allocator for x86
Message-ID: <20080308115408.GC27074@one.firstfloor.org>
References: <200803071007.493903088@firstfloor.org> <20080307090718.A609E1B419C@basil.firstfloor.org> <Pine.LNX.4.64.0803071832500.12220@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803071832500.12220@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 07, 2008 at 06:37:28PM -0800, Christoph Lameter wrote:
> On Fri, 7 Mar 2008, Andi Kleen wrote:
> 
> > - Disable old ZONE_DMA
> > No fixed size ZONE_DMA now anymore. All existing users of __GFP_DMA rely 
> > on the compat call to the maskable allocator in alloc/free_pages
> > - Call maskable allocator initialization functions at boot
> > - Add TRAD_DMA_MASK for the compat functions 
> > - Remove dma_reserve call
> 
> This looks okay for the disabling part. But note that there are various 
> uses of MAX_DMA_ADDRESS (sparsemem, bootmem allocator) that are currently 

I didn't bother change bootmem because the mask allocation runs sufficiently
early that it just allocates the memory it needs and bootmem will skip
that then because it sees it as used. Moving it up would just save
a few cycles in skipping bits in the bitmap. Ok it wouldn't hurt 
I guess, but also not really help.

What sparsemem reference do you mean?

> suboptimal because they set a boundary at 16MB for allocation of 
> potentially large operating system structures. That boundary continues to 
> exist despite the removal of ZONE_DMA?

It still exists, but is variable now.
 
> 
> It would be better to remove ZONE_DMA32 instead and enlarge ZONE_DMA so 
> that it can take over the role of ZONE_DMA. Set the boundary for 

I didn't want to do this because the DMA zone is ill defined (see my
long intro in 0/0), so really nobody should be using it directly.

But the ZONE_DMA32 actually makes sense, but changing the semantics
under such a large driver base isn't a good idea. 

My goal is still to eliminate all the GFP_DMAs for x86
(it is not that much work left ...) and then just 
remove the compat hooks. The few GFP_DMA32 users can stay
though.

> MAX_DMA_ADDRESS to the boundary for ZONE_DMA32. Then the 
> allocations for sparse and bootmem will be allocated above 4GB which 

It depends on the requirements of the bootmem user.  Some do need
memory <4GB, some do not. The mask allocator itself is a client in fact
and it requires low memory of course.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
