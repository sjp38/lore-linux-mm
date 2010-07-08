Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D5BB86B02A3
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 20:00:24 -0400 (EDT)
Message-ID: <4C366678.60605@codeaurora.org>
Date: Thu, 08 Jul 2010 16:59:52 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU, CPU and device
 memory management
References: <1278135507-20294-1-git-send-email-zpfeffer@codeaurora.org> <m14oggpepx.fsf@fess.ebiederm.org> <4C35034B.6040906@codeaurora.org> <20100707230710.GA31792@n2100.arm.linux.org.uk>
In-Reply-To: <20100707230710.GA31792@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-arch@vger.kernel.org, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Russell King - ARM Linux wrote:
> On Wed, Jul 07, 2010 at 03:44:27PM -0700, Zach Pfeffer wrote:
>> The DMA API handles the allocation and use of DMA channels. It can
>> configure physical transfer settings, manage scatter-gather lists,
>> etc. 
> 
> You're confused about what the DMA API is.  You're talking about
> the DMA engine subsystem (drivers/dma) not the DMA API (see
> Documentation/DMA-API.txt, include/linux/dma-mapping.h, and
> arch/arm/include/asm/dma-mapping.h)

Thanks for the clarification. 

> 
>> The VCM allows all device buffers to be passed between all devices in
>> the system without passing those buffers through each domain's
>> API. This means that instead of writing code to interoperate between
>> DMA engines, IOMMU mapped spaces, CPUs and physically addressed
>> devices the user can simply target a device with a buffer using the
>> same API regardless of how that device maps or otherwise accesses the
>> buffer.
> 
> With the DMA API, if we have a SG list which refers to the physical
> pages (as a struct page, offset, length tuple), the DMA API takes
> care of dealing with CPU caches and IOMMUs to make the data in the
> buffer visible to the target device.  It provides you with a set of
> cookies referring to the SG lists, which may be coalesced if the
> IOMMU can do so.
> 
> If you have a kernel virtual address, the DMA API has single buffer
> mapping/unmapping functions to do the same thing, and provide you
> with a cookie to pass to the device to refer to that buffer.
> 
> These cookies are whatever the device needs to be able to access
> the buffer - for instance, if system SDRAM is located at 0xc0000000
> virtual, 0x80000000 physical and 0x40000000 as far as the DMA device
> is concerned, then the cookie for a buffer at 0xc0000000 virtual will
> be 0x40000000 and not 0x80000000.

It sounds like I've got some work to do. I appreciate the feedback.

The problem I'm trying to solve boils down to this: map a set of
contiguous physical buffers to an aligned IOMMU address. I need to
allocate the set of physical buffers in a particular way: use 1 MB
contiguous physical memory, then 64 KB, then 4 KB, etc. and I need to
align the IOMMU address in a particular way. I also need to swap out the
IOMMU address spaces and map the buffers into the kernel.

I have this all solved, but it sounds like I'll need to migrate to the DMA
API to upstream it.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
