Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4FFED6B06D5
	for <linux-mm@kvack.org>; Sat, 19 May 2018 13:25:16 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id b31-v6so7185770plb.5
        for <linux-mm@kvack.org>; Sat, 19 May 2018 10:25:16 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id c24-v6si9877411plo.489.2018.05.19.10.25.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 May 2018 10:25:14 -0700 (PDT)
Subject: Re: [PATCH v2 35/40] iommu/arm-smmu-v3: Add support for PCI ATS
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-36-jean-philippe.brucker@arm.com>
From: Sinan Kaya <okaya@codeaurora.org>
Message-ID: <922474e8-0aa5-e022-0502-f1e51b0d4859@codeaurora.org>
Date: Sat, 19 May 2018 13:25:06 -0400
MIME-Version: 1.0
In-Reply-To: <20180511190641.23008-36-jean-philippe.brucker@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

On 5/11/2018 3:06 PM, Jean-Philippe Brucker wrote:
> PCIe devices can implement their own TLB, named Address Translation Cache
> (ATC). Enable Address Translation Service (ATS) for devices that support
> it and send them invalidation requests whenever we invalidate the IOTLBs.
> 
>   Range calculation
>   -----------------
> 
> The invalidation packet itself is a bit awkward: range must be naturally
> aligned, which means that the start address is a multiple of the range
> size. In addition, the size must be a power of two number of 4k pages. We
> have a few options to enforce this constraint:
> 
> (1) Find the smallest naturally aligned region that covers the requested
>     range. This is simple to compute and only takes one ATC_INV, but it
>     will spill on lots of neighbouring ATC entries.
> 
> (2) Align the start address to the region size (rounded up to a power of
>     two), and send a second invalidation for the next range of the same
>     size. Still not great, but reduces spilling.
> 
> (3) Cover the range exactly with the smallest number of naturally aligned
>     regions. This would be interesting to implement but as for (2),
>     requires multiple ATC_INV.
> 
> As I suspect ATC invalidation packets will be a very scarce resource, I'll
> go with option (1) for now, and only send one big invalidation. We can
> move to (2), which is both easier to read and more gentle with the ATC,
> once we've observed on real systems that we can send multiple smaller
> Invalidation Requests for roughly the same price as a single big one.
> 
> Note that with io-pgtable, the unmap function is called for each page, so
> this doesn't matter. The problem shows up when sharing page tables with
> the MMU.
> 
>   Timeout
>   -------
> 
> ATC invalidation is allowed to take up to 90 seconds, according to the
> PCIe spec, so it is possible to hit the SMMU command queue timeout during
> normal operations.
> 
> Some SMMU implementations will raise a CERROR_ATC_INV_SYNC when a CMD_SYNC
> fails because of an ATC invalidation. Some will just abort the CMD_SYNC.
> Others might let CMD_SYNC complete and have an asynchronous IMPDEF
> mechanism to record the error. When we receive a CERROR_ATC_INV_SYNC, we
> could retry sending all ATC_INV since last successful CMD_SYNC. When a
> CMD_SYNC fails without CERROR_ATC_INV_SYNC, we could retry sending *all*
> commands since last successful CMD_SYNC.
> 
> We cannot afford to wait 90 seconds in iommu_unmap, let alone MMU
> notifiers. So we'd have to introduce a more clever system if this timeout
> becomes a problem, like keeping hold of mappings and invalidating in the
> background. Implementing safe delayed invalidations is a very complex
> problem and deserves a series of its own. We'll assess whether more work
> is needed to properly handle ATC invalidation timeouts once this code runs
> on real hardware.
> 
>   Misc
>   ----
> 
> I didn't put ATC and TLB invalidations in the same functions for three
> reasons:
> 
> * TLB invalidation by range is batched and committed with a single sync.
>   Batching ATC invalidation is inconvenient, endpoints limit the number of
>   inflight invalidations. We'd have to count the number of invalidations
>   queued and send a sync periodically. In addition, I suspect we always
>   need a sync between TLB and ATC invalidation for the same page.
> 
> * Doing ATC invalidation outside tlb_inv_range also allows to send less
>   requests, since TLB invalidations are done per page or block, while ATC
>   invalidations target IOVA ranges.
> 
> * TLB invalidation by context is performed when freeing the domain, at
>   which point there isn't any device attached anymore.
> 
> Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>


Nothing specific about this patch but just a general observation. Last time I
looked at the code, it seemed to require both ATS and PRI support from a given
hardware.

I think you can assume that for ATS 1.1 specification but ATS 1.0 specification
allows a system to have ATS+PASID without PRI. 

QDF2400 is ATS 1.0 compatible as an example. 

Is this an assumption / my misinterpretation?


-- 
Sinan Kaya
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the Code Aurora Forum, a Linux Foundation Collaborative Project.
