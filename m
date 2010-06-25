Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D094B6B01B0
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 02:48:51 -0400 (EDT)
Message-ID: <4C245152.1090301@codeaurora.org>
Date: Thu, 24 Jun 2010 23:48:50 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC] mm: iommu: An API to unify IOMMU, CPU and device memory
 management
References: <1277355096-15596-1-git-send-email-zpfeffer@codeaurora.org> <876318ager.fsf@basil.nowhere.org>
In-Reply-To: <876318ager.fsf@basil.nowhere.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: mel@csn.ul.ie, dwalker@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> Zach Pfeffer <zpfeffer@codeaurora.org> writes:
> 
>> This patch contains the documentation for and the main header file of
>> the API, termed the Virtual Contiguous Memory Manager. Its use would
>> allow all of the IOMMU to VM, VM to device and device to IOMMU
>> interoperation code to be refactored into platform independent code.
> 
> I read all the description and it's still unclear what advantage
> this all has over the current architecture? 
> 
> At least all the benefits mentioned seem to be rather nebulous.
> 
> Can you describe a concrete use case that is improved by this code
> directly?

Sure. On a SoC with many IOMMUs (10-100), where each IOMMU may have
its own set of page-tables or share page-tables, and where devices
with and without IOMMUs and CPUs with or without MMUS want to
communicate, an abstraction like the VCM helps manage all conceivable
mapping topologies. In the same way that the Linux MM manages pages
apart from page-frames, the VCMM allows the Linux MM to manage ideal
memory regions, VCMs, apart from the actual memory region.

One real scenario would be video playback from a file on a memory
card. To read and display the video, a DMA engine would read blocks of
data from the memory card controller into memory. These would
typically be managed using a scatter-gather list. This list would be
mapped into a contiguous buffer of the video decoder's IOMMU. The
video decoder would write into a buffer mapped by the display engine's
IOMMU as well as the CPU (if the kernel needed to intercept the
buffers). In this instance, the video decoder's IOMMU and the display
engine's IOMMU use different page-table formats.

Using the VCM API, this topology can be created without worrying about
the device's IOMMUs or how to map the buffers into the kernel, or how
to interoperate with the scatter-gather list. The call flow would would go:

1. Establish a memory region for the video decoder and the display engine
that's 128 MB and starts at 0x1000.

    vcm_out = vcm_create(0x1000, SZ_128M);


2. Associate the memory region with the video decoder's IOMMU and the
display engine's IOMMU.

    avcm_dec = vcm_assoc(vcm_out, video_dec_dev, 0);
    avcm_disp = vcm_assoc(vcm_out, disp_dev, 0);

The 2 dev_ids, video_dec_dev and disp_dev allow the right IOMMU
low-level functions to be called underneath.


3. Actually program the underlying IOMMUs.

    vcm_activate(avcm_dec);
    vcm_activate(avcm_disp);


4. Allocate 2 physical buffers that the DMA engine and video decoder will
use. Make sure each buffer is 64 KB contiguous.

    buf_64k = vcm_phys_alloc(MT0, 2*SZ_64K, VCM_64KB);


5. Allocate a 16 MB buffer for the output of the video decoder and the
input of the display engine. Use 1MB, 64KB and 4KB blocks to map the
buffer.

    buf_frame = vcm_phys_alloc(MT0, SZ_16M);


6. Program the DMA controller.

buf = vcm_get_next_phys_addr(buf_64k, NULL, &len);
while (buf) {
	   dma_prg(buf);
	   buf = vcm_get_next_phys_addr(buf_64k, NULL, &len);
}


7. Create virtual memory regions for the DMA buffers and the video
decoder output from the vcm_out region. Make sure the buffers are
aligned to the buffer size.

    res_64k = vcm_reserve(vcm_out, 8*SZ_64K, VCM_ALIGN_64K);
    res_16M = vcm_reserve(vcm_out, SZ_16M, VCM_ALIGN_16M);


8. Connect the virtual reservations with the physical allocations.

vcm_back(res_64k, buf_64k);
vcm_back(res_16M, buf_frame);


9. Program the decoder and the display engine with addresses from the
 IOMMU side of the mapping:

base_64k = vcm_get_dev_addr(res_64k);
base_16M = vcm_get_dev_addr(res_16M);


10. Create a kernel mapping to read and write the 16M buffer.

cpu_vcm = vcm_create_from_prebuilt(VCM_PREBUILT_KERNEL);


11. Create a reservation on that prebuilt VCM. Use any alignment.

res_cpu_16M = vcm_reserve(cpu_vcm, SZ_16M, 0);


12. Back the reservation using the same physical memory that the
decoder and the display engine are looking at.

vcm_back(res_cpu_16M, buf_frame);


13. Get a pointer that kernel can dereference.

base_cpu_16M = vcm_get_dev_addr(res_cpu_16M);


The general point of the VCMM is to allow users a higher level API
than the current IOMMU abstraction provides that solves the general
mapping problem. This means that all of the common mapping code would
be written once. In addition, the API allows all the low level details
of IOMMU programing and VM interoperation to be handled at the right
level.

Eventually the following functions could all be reworked and their
users could call VCM functions.

arch/arm/plat-omap/iovmm.c
map_iovm_area()

arch/m68k/sun3/sun3dvma.c
dvma_map_align()

arch/alpha/kernel/pci_iommu.c
pci_map_single_1()

arch/powerpc/platforms/pasemi/iommu.c
iobmap_build()

arch/powerpc/kernel/iommu.c
iommu_map_page()

arch/sparc/mm/iommu.c
iommu_map_dma_area()

arch/sparc/kernel/pci_sun4v_asm.S
ENTRY(pci_sun4v_iommu_map)

arch/ia64/hp/common/sba_iommu.c
sba_map_page()

arch/arm/mach-omap2/iommu2.c
omap2_iommu_init()

arch/arm/plat-omap/iovmm.c
map_iovm_area()

arch/x86/kernel/amd_iommu.c
iommu_map_page()

drivers/parisc/sba_iommu.c
sba_map_single()

drivers/pci/intel-iommu.c
intel_iommu_map()
 

> 
> -Andi
> 


-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
