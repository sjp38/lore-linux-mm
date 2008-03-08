Date: Fri, 7 Mar 2008 18:37:28 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] [8/13] Enable the mask allocator for x86
In-Reply-To: <20080307090718.A609E1B419C@basil.firstfloor.org>
Message-ID: <Pine.LNX.4.64.0803071832500.12220@schroedinger.engr.sgi.com>
References: <200803071007.493903088@firstfloor.org>
 <20080307090718.A609E1B419C@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Mar 2008, Andi Kleen wrote:

> - Disable old ZONE_DMA
> No fixed size ZONE_DMA now anymore. All existing users of __GFP_DMA rely 
> on the compat call to the maskable allocator in alloc/free_pages
> - Call maskable allocator initialization functions at boot
> - Add TRAD_DMA_MASK for the compat functions 
> - Remove dma_reserve call

This looks okay for the disabling part. But note that there are various 
uses of MAX_DMA_ADDRESS (sparsemem, bootmem allocator) that are currently 
suboptimal because they set a boundary at 16MB for allocation of 
potentially large operating system structures. That boundary continues to 
exist despite the removal of ZONE_DMA?

It would be better to remove ZONE_DMA32 instead and enlarge ZONE_DMA so 
that it can take over the role of ZONE_DMA. Set the boundary for 
MAX_DMA_ADDRESS to the boundary for ZONE_DMA32. Then the 
allocations for sparse and bootmem will be allocated above 4GB which 
leaves lots of the lower space available for 32 bit DMA capable devices.

Removal of ZONE_DMA32 would allow us to remove support for that zone from 
the kernel in general since x86_64 is the only user of that zone.

Trouble is likely that there are existing users that have the expectation 
of a 4GB boundary on ZONE_DMA32 and 16MB on ZONE_DMA (particularly old 
drivers). Could we not clean that up?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
