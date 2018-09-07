Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 085036B7F16
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 11:45:24 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t3-v6so17384425oif.20
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 08:45:24 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p129-v6si5680752oif.151.2018.09.07.08.45.22
        for <linux-mm@kvack.org>;
        Fri, 07 Sep 2018 08:45:22 -0700 (PDT)
Subject: Re: [PATCH v2 01/40] iommu: Introduce Shared Virtual Addressing API
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-2-jean-philippe.brucker@arm.com>
 <bf42affd-e9d0-e4fc-6d28-f3c3f7795348@redhat.com>
 <03d31ba5-1eda-ea86-8c0c-91d14c86fe83@arm.com>
 <ed39159c-087e-7e56-7d29-d1de9fa1677f@amd.com>
 <f0b317d5-e2e9-5478-952c-05e8b97bd68b@arm.com>
 <2fd4a0a1-1a35-bf82-df84-b995cce011d9@amd.com>
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Message-ID: <65e7accd-4446-19f5-c667-c6407e89cfa6@arm.com>
Date: Fri, 7 Sep 2018 16:45:02 +0100
MIME-Version: 1.0
In-Reply-To: <2fd4a0a1-1a35-bf82-df84-b995cce011d9@amd.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Auger Eric <eric.auger@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "liubo95@huawei.com" <liubo95@huawei.com>, "xuzaibo@huawei.com" <xuzaibo@huawei.com>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, Will Deacon <Will.Deacon@arm.com>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "yi.l.liu@intel.com" <yi.l.liu@intel.com>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "tn@semihalf.com" <tn@semihalf.com>, "joro@8bytes.org" <joro@8bytes.org>, "bharatku@xilinx.com" <bharatku@xilinx.com>, "liudongdong3@huawei.com" <liudongdong3@huawei.com>, "rfranz@cavium.com" <rfranz@cavium.com>, "kevin.tian@intel.com" <kevin.tian@intel.com>, "jacob.jun.pan@linux.intel.com" <jacob.jun.pan@linux.intel.com>, "jcrouse@codeaurora.org" <jcrouse@codeaurora.org>, "rgummal@xilinx.com" <rgummal@xilinx.com>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "shunyong.yang@hxt-semitech.com" <shunyong.yang@hxt-semitech.com>, Robin Murphy <Robin.Murphy@arm.com>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "robdclark@gmail.com" <robdclark@gmail.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "nwatters@codeaurora.org" <nwatters@codeaurora.org>, "baolu.lu@linux.intel.com" <baolu.lu@linux.intel.com>

On 07/09/2018 09:55, Christian KA?nig wrote:
> I will take this as an opportunity to summarize some of the requirements 
> we have for PASID management from the amdgpu driver point of view:

That's incredibly useful, thanks :)

> 1. We need to be able to allocate PASID between 1 and some maximum. Zero 
> is reserved as far as I know, but we don't necessary need a minimum.

Should be fine. The PASID range is restricted by the PCI PASID
capability, firmware description (for non-PCI devices), the IOMMU
capacity, and what the device driver passes to iommu_sva_device_init.
Not all IOMMUs reserve PASID 0 (AMD IOMMU without GIoSup doesn't, if I'm
not mistaken), so the KFD driver will need to pass min_pasid=1 to make
sure that 0 isn't allocated.

> 2. We need to be able to allocate PASIDs without a process address space 
> backing it. E.g. our hardware uses PASIDs even without Shared Virtual 
> Addressing enabled to distinct clients from each other.
>  A A A  A A A  Would be a pity if we need to still have a separate PASID 
> handling because the system wide is only available when IOMMU is turned on.

I'm still not sure about this one. From my point of view we shouldn't
add to the IOMMU subsystem helpers for devices without an IOMMU.
iommu-sva expects everywhere that the device has an iommu_domain, it's
the first thing we check on entry. Bypassing all of this would call
idr_alloc() directly, and wouldn't have any code in common with the
current iommu-sva. So it seems like you need a layer on top of iommu-sva
calling idr_alloc() when an IOMMU isn't present, but I don't think it
should be in drivers/iommu/

> 3. Even after destruction of a process address space we need some grace 
> period before a PASID is reused because it can be that the specific 
> PASID is still in some hardware queues etc...
>  A A A  A A A  At bare minimum all device drivers using process binding need 
> to explicitly note to the core when they are done with a PASID.

Right, much of the horribleness in iommu-sva deals with this:

The process dies, iommu-sva is notified and calls the mm_exit() function
passed by the device driver to iommu_sva_device_init(). In mm_exit() the
device driver needs to clear any reference to the PASID in hardware and
in its own structures. When the device driver returns from mm_exit(), it
effectively tells the core that it has finished using the PASID, and
iommu-sva can reuse the PASID for another process. mm_exit() is allowed
to block, so the device driver has time to clean up and flush the queues.

If the device driver finishes using the PASID before the process exits,
it just calls unbind().

> 4. It would be nice to have to be able to set a "void *" for each 
> PASID/device combination while binding to a process which then can be 
> queried later on based on the PASID.
>  A A A  A A A  E.g. when you have a per PASID/device structure around anyway, 
> just add an extra field.

iommu_sva_bind_device() takes a "drvdata" pointer that is stored
internally for the PASID/device combination (iommu_bond). It is passed
to mm_exit(), but I haven't added anything for the device driver to
query it back.

> 5. It would be nice to have to allocate multiple PASIDs for the same 
> process address space.
>  A A A  A A A  E.g. some teams at AMD want to use a separate GPU address space 
> for their userspace client library. I'm still trying to avoid that, but 
> it is perfectly possible that we are going to need that.

Two PASIDs pointing to the same process pgd? At first glance it seems
feasible, maybe with a flag passed to bind() and a few changes to
internal structures. It will duplicate ATC invalidation commands for
each process address space change (munmap etc) so you might take a
performance hit.

Intel's SVM code has the SVM_FLAG_PRIVATE_PASID which seems similar to
what you describe, but I don't plan to support it in this series (the
io_mm model is already pretty complicated). I think it can be added
without too much effort in a future series, though with a different flag
name since we'd like to use "private PASID" for something else
(https://www.spinics.net/lists/dri-devel/msg177007.html).

Thanks,
Jean

>  A A A  A A A  Additional to that it is sometimes quite useful for debugging 
> to isolate where exactly an incorrect access (segfault) is coming from.
> 
> Let me know if there are some problems with that, especially I want to 
> know if there is pushback on #5 so that I can forward that :)
> 
> Thanks,
> Christian.
> 
>>
>> Thanks,
>> Jean
> 
