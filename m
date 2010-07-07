Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3683A6B024A
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 19:08:23 -0400 (EDT)
Date: Thu, 8 Jul 2010 00:07:10 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU, CPU and device
	memory management
Message-ID: <20100707230710.GA31792@n2100.arm.linux.org.uk>
References: <1278135507-20294-1-git-send-email-zpfeffer@codeaurora.org> <m14oggpepx.fsf@fess.ebiederm.org> <4C35034B.6040906@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C35034B.6040906@codeaurora.org>
Sender: owner-linux-mm@kvack.org
To: Zach Pfeffer <zpfeffer@codeaurora.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-arch@vger.kernel.org, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 07, 2010 at 03:44:27PM -0700, Zach Pfeffer wrote:
> The DMA API handles the allocation and use of DMA channels. It can
> configure physical transfer settings, manage scatter-gather lists,
> etc. 

You're confused about what the DMA API is.  You're talking about
the DMA engine subsystem (drivers/dma) not the DMA API (see
Documentation/DMA-API.txt, include/linux/dma-mapping.h, and
arch/arm/include/asm/dma-mapping.h)

> The VCM allows all device buffers to be passed between all devices in
> the system without passing those buffers through each domain's
> API. This means that instead of writing code to interoperate between
> DMA engines, IOMMU mapped spaces, CPUs and physically addressed
> devices the user can simply target a device with a buffer using the
> same API regardless of how that device maps or otherwise accesses the
> buffer.

With the DMA API, if we have a SG list which refers to the physical
pages (as a struct page, offset, length tuple), the DMA API takes
care of dealing with CPU caches and IOMMUs to make the data in the
buffer visible to the target device.  It provides you with a set of
cookies referring to the SG lists, which may be coalesced if the
IOMMU can do so.

If you have a kernel virtual address, the DMA API has single buffer
mapping/unmapping functions to do the same thing, and provide you
with a cookie to pass to the device to refer to that buffer.

These cookies are whatever the device needs to be able to access
the buffer - for instance, if system SDRAM is located at 0xc0000000
virtual, 0x80000000 physical and 0x40000000 as far as the DMA device
is concerned, then the cookie for a buffer at 0xc0000000 virtual will
be 0x40000000 and not 0x80000000.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
