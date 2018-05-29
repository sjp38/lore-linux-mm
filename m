Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0416B0010
	for <linux-mm@kvack.org>; Tue, 29 May 2018 07:56:02 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id e10-v6so7020442oig.16
        for <linux-mm@kvack.org>; Tue, 29 May 2018 04:56:02 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b11-v6si3891664otd.403.2018.05.29.04.56.01
        for <linux-mm@kvack.org>;
        Tue, 29 May 2018 04:56:01 -0700 (PDT)
Subject: Re: [PATCH v2 13/40] vfio: Add support for Shared Virtual Addressing
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-14-jean-philippe.brucker@arm.com>
 <5B0536A3.1000304@huawei.com> <cd13f60d-b282-3804-4ca7-2d34476c597f@arm.com>
 <5B06B17C.1090809@huawei.com> <205c1729-8026-3efe-c363-d37d7150d622@arm.com>
 <5B077765.30703@huawei.com> <fea420ff-e738-e2ed-ab1e-a3f4dde4b6ef@arm.com>
 <5B08DA21.3070507@huawei.com>
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Message-ID: <99ff4f89-86ef-a251-894c-8aa8a47d2a69@arm.com>
Date: Tue, 29 May 2018 12:55:49 +0100
MIME-Version: 1.0
In-Reply-To: <5B08DA21.3070507@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xu Zaibo <xuzaibo@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Will Deacon <Will.Deacon@arm.com>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "liguozhu@hisilicon.com" <liguozhu@hisilicon.com>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "bharatku@xilinx.com" <bharatku@xilinx.com>, "rfranz@cavium.com" <rfranz@cavium.com>, "rgummal@xilinx.com" <rgummal@xilinx.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "christian.koenig@amd.com" <christian.koenig@amd.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

(If possible, please reply in plain text to the list. Reading this in a
text-only reader is confusing, because all quotes have the same level)

On 26/05/18 04:53, Xu Zaibo wrote:
> I guess there may be some misunderstandings :).
> 
> From the current patches, 'iommu_sva_device_shutdown' is called by 'vfio_iommu_sva_shutdown', which
> is mainly used by 'vfio_iommu_type1_detach_group' that is finally called by processes' release of vfio facilitiy
> automatically or called by 'VFIO_GROUP_UNSET_CONTAINER' manually in the processes.
> 
> So, just image that 2 processes is working on the device with IOPF feature, and the 2 do the following to enable SVA:
> 
>     1.open("/dev/vfio/vfio") ;
> 
>    2.open the group of the devcie by calling open("/dev/vfio/x"), but now,
>      I think the second processes will fail to open the group because current VFIO thinks that one group only can be used by one process/vm,
>      at present, I use mediated device to create more groups on the parent device to support multiple processes;
> 
>     3.VFIO_GROUP_SET_CONTAINER;
> 
>     4.VFIO_SET_IOMMU;
> 
>     5.VFIO_IOMMU_BIND;

I have a concern regarding your driver. With mdev you can't allow
processes to program the PASID themselves, since the parent device has a
single PASID table. You lose all isolation since processes could write
any value in the PASID field and access address spaces of other
processes bound to this parent device (even if the BIND call was for
other mdevs).

The wrap driver has to mediate calls to bind(), and either program the
PASID into the device itself, or at least check that, when receiving a
SET_PASID ioctl from a process, the given PASID was actually allocated
to the process.

>     6.Do some works with the hardware working unit filled by PASID on the device;
> 
>    7.VFIO_IOMMU_UNBIND;
> 
>     8.VFIO_GROUP_UNSET_CONTAINER;---here, have to sleep to wait another process to finish works of the step 6;
> 
>     9. close(group); close(containner);
> 
> 
> So, my idea is: If it is possible to just release the params or facilities that only belong to the current process while the process shutdown the device,
> and while the last process releases them all. Then, as in the above step 8, we
> don't need to wait, or maybe wait for a very long time if the other process is doing lots of work on the device.
Given that you need to notify the mediating driver of IOMMU_BIND calls
as explained above, you could do something similar for shutdown: from
the mdev driver, call iommu_sva_shutdown_device() only for the last mdev.

Thanks,
Jean
