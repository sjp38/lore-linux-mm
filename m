Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AB0016B01B0
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 19:01:00 -0400 (EDT)
Date: Fri, 2 Jul 2010 01:00:56 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
Message-ID: <20100701230056.GD3594@basil.fritz.box>
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org>
 <1277877350-2147-3-git-send-email-zpfeffer@codeaurora.org>
 <20100701101746.3810cc3b.randy.dunlap@oracle.com>
 <20100701180241.GA3594@basil.fritz.box>
 <1278012503.7738.17.camel@c-dwalke-linux.qualcomm.com>
 <20100701193850.GB3594@basil.fritz.box>
 <4C2D0FF1.6010206@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C2D0FF1.6010206@codeaurora.org>
Sender: owner-linux-mm@kvack.org
To: Zach Pfeffer <zpfeffer@codeaurora.org>
Cc: Andi Kleen <andi@firstfloor.org>, Daniel Walker <dwalker@codeaurora.org>, Randy Dunlap <randy.dunlap@oracle.com>, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

> The VCMM provides a more abstract, global view with finer-grained
> control of each mapping a user wants to create. For instance, the
> symantics of iommu_map preclude its use in setting up just the IOMMU
> side of a mapping. With a one-sided map, two IOMMU devices can be

Hmm? dma_map_* does not change any CPU mappings. It only sets up
DMA mapping(s).

> Additionally, the current IOMMU interface does not allow users to
> associate one page table with multiple IOMMUs unless the user explicitly

That assumes that all the IOMMUs on the system support the same page table
format, right?

As I understand your approach would help if you have different
IOMMus with an different low level interface, which just 
happen to have the same pte format. Is that very likely?

I would assume if you have lots of copies of the same IOMMU
in the system then you could just use a single driver with multiple
instances that share some state for all of them.  That model
would fit in the current interfaces. There's no reason multiple
instances couldn't share the same allocation data structure.

And if you have lots of truly different IOMMUs then they likely
won't be able to share PTEs at the hardware level anyways, because
the formats are too different.

> The VCMM takes the long view. Its designed for a future in which the
> number of IOMMUs will go up and the ways in which these IOMMUs are
> composed will vary from system to system, and may vary at
> runtime. Already, there are ~20 different IOMMU map implementations in
> the kernel. Had the Linux kernel had the VCMM, many of those
> implementations could have leveraged the mapping and topology management
> of a VCMM, while focusing on a few key hardware specific functions (map
> this physical address, program the page table base register).

The standard Linux approach to such a problem is to write
a library that drivers can use for common functionality, not put a middle 
layer inbetween. Libraries are much more flexible than layers.

That said I'm not sure there's all that much duplicated code anyways.
A lot of the code is always IOMMU specific. The only piece
which might be shareable is the mapping allocation, but I don't
think that's very much of a typical driver

In my old pci-gart driver the allocation was all only a few lines of code, 
although given it was somewhat dumb in this regard because it only managed a 
small remapping window.

-Andi 
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
