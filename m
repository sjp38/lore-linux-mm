Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A785A6B01B2
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 17:16:59 -0400 (EDT)
Message-ID: <4C291148.2020402@codeaurora.org>
Date: Mon, 28 Jun 2010 14:16:56 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC] mm: iommu: An API to unify IOMMU, CPU and device memory
 management
References: <1277355096-15596-1-git-send-email-zpfeffer@codeaurora.org>	<876318ager.fsf@basil.nowhere.org>	<4C245152.1090301@codeaurora.org> <20100627134401G.fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20100627134401G.fujita.tomonori@lab.ntt.co.jp>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: andi@firstfloor.org, mel@csn.ul.ie, dwalker@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org
List-ID: <linux-mm.kvack.org>

FUJITA Tomonori wrote:
> On Thu, 24 Jun 2010 23:48:50 -0700
> Zach Pfeffer <zpfeffer@codeaurora.org> wrote:
> 
>> Andi Kleen wrote:
>>> Zach Pfeffer <zpfeffer@codeaurora.org> writes:
>>>
>>>> This patch contains the documentation for and the main header file of
>>>> the API, termed the Virtual Contiguous Memory Manager. Its use would
>>>> allow all of the IOMMU to VM, VM to device and device to IOMMU
>>>> interoperation code to be refactored into platform independent code.
>>> I read all the description and it's still unclear what advantage
>>> this all has over the current architecture? 
>>>
>>> At least all the benefits mentioned seem to be rather nebulous.
>>>
>>> Can you describe a concrete use case that is improved by this code
>>> directly?
>> Sure. On a SoC with many IOMMUs (10-100), where each IOMMU may have
>> its own set of page-tables or share page-tables, and where devices
>> with and without IOMMUs and CPUs with or without MMUS want to
>> communicate, an abstraction like the VCM helps manage all conceivable
>> mapping topologies. In the same way that the Linux MM manages pages
>> apart from page-frames, the VCMM allows the Linux MM to manage ideal
>> memory regions, VCMs, apart from the actual memory region.
>>
>> One real scenario would be video playback from a file on a memory
>> card. To read and display the video, a DMA engine would read blocks of
>> data from the memory card controller into memory. These would
>> typically be managed using a scatter-gather list. This list would be
>> mapped into a contiguous buffer of the video decoder's IOMMU. The
>> video decoder would write into a buffer mapped by the display engine's
>> IOMMU as well as the CPU (if the kernel needed to intercept the
>> buffers). In this instance, the video decoder's IOMMU and the display
>> engine's IOMMU use different page-table formats.
>>
>> Using the VCM API, this topology can be created without worrying about
>> the device's IOMMUs or how to map the buffers into the kernel, or how
>> to interoperate with the scatter-gather list. The call flow would would go:
> 
> Can you explain how you can't do the above with the existing API?

Sure. You can do the same thing with the current API, but the VCM takes a
wider view; the mapper is a parameter.

Taking include/linux/iommu.h as a common interface, the key function
is iommu_map(). This function maps a physical memory region, paddr, of
gfp_order, to a virtual region starting at iova:

extern int iommu_map(struct iommu_domain *domain, unsigned long iova,
		     phys_addr_t paddr, int gfp_order, int prot);

Users who call this, kvm_iommu_map_pages() for instance, run similar
loops:

foreach page 
	iommu_map(domain, va(page), ...)
	
The VCM encapsulates this as vcm_back(). This function iterates over a
set of physical regions and maps those physical regions to a virtual
address space that has been associated with a mapper at run-time. The
loop above, and the other loops (and other associated IOMMU software)
that don't use the common interface like arch/powerpc/kernel/vio.c all
do similar work.

In the end the VCM's dynamic virtual region association mechanism (and
multihomed physical memory targeting) allows all IOMMU mapping code in
the system to use the same API.

This may seem like syntactic sugar, but treating devices with IOMMUs
(bus-masters), device with MMUs (CPUs) and devices without MMUs (DMA
engines) as endpoints in a mapping graph allows new features to be
developed. One such feature is system-wide memory migration (including
memory that devices map). With a common API a loop like this can be
written one place:

foreach mapper of pa_region
	remap(mapper, new_pa_region)

It could also be used for better power-management:

foreach mapper of soon_to_be_powered_off_pa_region
	ask(mapper, soon_to_be_powered_off_pa_region)

The VCM is just the first step.

More concretely, the way the VCM works allows the transparent use and
interoperation of different mapping chunk sizes. This is important in
multimedia devices because IOMMU TLB misses may cause multimedia
devices to miss their performance goals. Multi-chunk size support has
been added for IOMMU mappers and wouldn't be hard to add to CPU
mappers (CPU mappers still use 4KB).

>> The general point of the VCMM is to allow users a higher level API
>> than the current IOMMU abstraction provides that solves the general
>> mapping problem. This means that all of the common mapping code would
>> be written once. In addition, the API allows all the low level details
>> of IOMMU programing and VM interoperation to be handled at the right
>> level.
>>
>> Eventually the following functions could all be reworked and their
>> users could call VCM functions.
> 
> There are more IOMMUs (e.g. x86 has calgary, gart too). And what is
> the point of converting old IOMMUs (the majority of the below)? are
> there any potential users of your API for such old IOMMUs?

That's a good question. I gave the list of the current IOMMU mapping
functions to bring awareness to the fact that the general system-wide
mapping problem hasn't yet been solved and won't be solved completely
until something that looks at memory mapping from a system-wide
perspective, like the VCMM, has been built.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
