Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D96B76B01B5
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 04:22:30 -0400 (EDT)
Date: Fri, 2 Jul 2010 10:22:25 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
Message-ID: <20100702082225.GA12221@basil.fritz.box>
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org>
 <1277877350-2147-3-git-send-email-zpfeffer@codeaurora.org>
 <20100701101746.3810cc3b.randy.dunlap@oracle.com>
 <20100701180241.GA3594@basil.fritz.box>
 <1278012503.7738.17.camel@c-dwalke-linux.qualcomm.com>
 <20100701193850.GB3594@basil.fritz.box>
 <4C2D0FF1.6010206@codeaurora.org>
 <20100701230056.GD3594@basil.fritz.box>
 <4C2D847E.5080602@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C2D847E.5080602@codeaurora.org>
Sender: owner-linux-mm@kvack.org
To: Zach Pfeffer <zpfeffer@codeaurora.org>
Cc: Andi Kleen <andi@firstfloor.org>, Daniel Walker <dwalker@codeaurora.org>, Randy Dunlap <randy.dunlap@oracle.com>, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 01, 2010 at 11:17:34PM -0700, Zach Pfeffer wrote:
> Andi Kleen wrote:
> >> The VCMM provides a more abstract, global view with finer-grained
> >> control of each mapping a user wants to create. For instance, the
> >> semantics of iommu_map preclude its use in setting up just the IOMMU
> >> side of a mapping. With a one-sided map, two IOMMU devices can be
> > 
> > Hmm? dma_map_* does not change any CPU mappings. It only sets up
> > DMA mapping(s).
> 
> Sure, but I was saying that iommu_map() doesn't just set up the IOMMU
> mappings, its sets up both the iommu and kernel buffer mappings.

Normally the data is already in the kernel or mappings, so why
would you need another CPU mapping too? Sometimes the CPU
code has to scatter-gather, but that is considered acceptable
(and if it really cannot be rewritten to support sg it's better
to have an explicit vmap operation) 

In general on larger systems with many CPUs changing CPU mappings
also gets expensive (because you have to communicate with all cores), 
and is not a good idea on frequent IO paths.

> 
> > 
> >> Additionally, the current IOMMU interface does not allow users to
> >> associate one page table with multiple IOMMUs unless the user explicitly
> > 
> > That assumes that all the IOMMUs on the system support the same page table
> > format, right?
> 
> Actually no. Since the VCMM abstracts a page-table as a Virtual
> Contiguous Region (VCM) a VCM can be associated with any device,
> regardless of their individual page table format.

But then there is no real page table sharing, isn't it? 
The real information should be in the page tables, nowhere else.

> > The standard Linux approach to such a problem is to write
> > a library that drivers can use for common functionality, not put a middle 
> > layer in between. Libraries are much more flexible than layers.
> 
> That's true up to the, "is this middle layer so useful that its worth
> it" point. The VM is a middle layer, you could make the same argument
> about it, "the mapping code isn't too hard, just map in the memory
> that you need and be done with it". But the VM middle layer provides a
> clean separation between page frames and pages which turns out to be

Actually we use both PFNs and struct page *s in many layers up
and down, there's not really any layering in that.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
