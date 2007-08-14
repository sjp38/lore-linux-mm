Date: Tue, 14 Aug 2007 02:25:03 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 3/4] Embed zone_id information within the zonelist->zones pointer
Message-ID: <20070814002503.GQ3406@bingen.suse.de>
References: <20070813225841.GG3406@bingen.suse.de> <Pine.LNX.4.64.0708131506030.28502@schroedinger.engr.sgi.com> <20070813230801.GH3406@bingen.suse.de> <Pine.LNX.4.64.0708131518320.28626@schroedinger.engr.sgi.com> <20070813234217.GI3406@bingen.suse.de> <Pine.LNX.4.64.0708131550100.30626@schroedinger.engr.sgi.com> <20070813235518.GK3406@bingen.suse.de> <Pine.LNX.4.64.0708131611001.19910@schroedinger.engr.sgi.com> <20070814001624.GO3406@bingen.suse.de> <Pine.LNX.4.64.0708131622380.19910@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708131622380.19910@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Mel Gorman <mel@skynet.ie>, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 13, 2007 at 04:25:23PM -0700, Christoph Lameter wrote:
> On Tue, 14 Aug 2007, Andi Kleen wrote:
> 
> > > But they use GFP_DMA right now and drivers cannot use DMA32 if they want 
> > 
> > The way it was originally designed was that they use GFP_DMA32,
> > which would map to itself on x86-64, to GFP_DMA on ia64 and to
> > GFP_KERNEL on i386. Unfortunately that seems to have bitrotted
> > (perhaps I should have better documented it) 
> 
> The DMA boundaries are hardware depending. A 4GB boundary 
> may not make sense on certain platforms. 

If it makes sense for the driver it has to make sense
for the platform too. If not it cannot run the driver
(which might be fine; a lot of architectures only
run their own specialized drivers) 

> 
> > > to be cross platforms compatible? Doesnt the dma API completely do away 
> > > with these things?
> > 
> > No GFP_DMA32 in my current plan is still there.
> 
> AFAIK GFP_DMA32 is a x86_64 special that would be easy to remove. Dealing 
> with physical boundaries is current done via the dma interface right? Lets 
> keep it there?

The difference between the low dma allocation and GFP_DMA32 is that
the low dma allocation zone is isolated. This means it is not shared
with user pages, no LRU, no vmscan, no try_to_free_pages etc.

But that cannot be obviously done for a full 4GB, only for a small
area.  Right now on swiotlb systems we reserved 82MB for this
(64MB swiotlb + 16MB ZONE_DMA). So the new zone is by default <100MB
and can afford to be isolated.

If GFP_DMA32 was merged into the mask allocator then it would
need to learn about all that mess by itself. If GFP_DMA32
stays it can just use the current page allocator which avoids
a lot of code duplication.

The DMA allocator calls the normal page allocator implicitely
though for a 4GB mask, but that still needs such a bit to specify.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
