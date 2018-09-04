Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4FABA6B6D1C
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 06:57:24 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id 20-v6so3670433ois.21
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 03:57:24 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k189-v6si13411122oia.257.2018.09.04.03.57.22
        for <linux-mm@kvack.org>;
        Tue, 04 Sep 2018 03:57:22 -0700 (PDT)
Subject: Re: [PATCH v2 13/40] vfio: Add support for Shared Virtual Addressing
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-14-jean-philippe.brucker@arm.com>
 <5B83B11E.7010807@huawei.com> <1d5b6529-4e5a-723c-3f1b-dd5a9adb490c@arm.com>
 <5B89F818.7060300@huawei.com> <3a961aff-e830-64bb-b6a9-14e08de1abf5@arm.com>
 <5B8DEA15.7020404@huawei.com>
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Message-ID: <bc27f902-4d12-21b7-b9e9-18bcae170503@arm.com>
Date: Tue, 4 Sep 2018 11:57:02 +0100
MIME-Version: 1.0
In-Reply-To: <5B8DEA15.7020404@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xu Zaibo <xuzaibo@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "joro@8bytes.org" <joro@8bytes.org>, Will Deacon <Will.Deacon@arm.com>, Robin Murphy <Robin.Murphy@arm.com>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "tn@semihalf.com" <tn@semihalf.com>, "liubo95@huawei.com" <liubo95@huawei.com>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "liudongdong3@huawei.com" <liudongdong3@huawei.com>, "shunyong.yang@hxt-semitech.com" <shunyong.yang@hxt-semitech.com>, "nwatters@codeaurora.org" <nwatters@codeaurora.org>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "jcrouse@codeaurora.org" <jcrouse@codeaurora.org>, "rfranz@cavium.com" <rfranz@cavium.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "jacob.jun.pan@linux.intel.com" <jacob.jun.pan@linux.intel.com>, "yi.l.liu@intel.com" <yi.l.liu@intel.com>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "kevin.tian@intel.com" <kevin.tian@intel.com>, "baolu.lu@linux.intel.com" <baolu.lu@linux.intel.com>, "robdclark@gmail.com" <robdclark@gmail.com>, "christian.koenig@amd.com" <christian.koenig@amd.com>, "bharatku@xilinx.com" <bharatku@xilinx.com>, "rgummal@xilinx.com" <rgummal@xilinx.com>, =?UTF-8?B?57Gz57Gz?= <kenneth-lee-2012@foxmail.com>, wangzhou1 <wangzhou1@hisilicon.com>, "liguozhu@hisilicon.com" <liguozhu@hisilicon.com>, fanghao11 <fanghao11@huawei.com>

On 04/09/2018 03:12, Xu Zaibo wrote:
> On 2018/9/3 18:34, Jean-Philippe Brucker wrote:
>> On 01/09/18 03:23, Xu Zaibo wrote:
>>> As one application takes a whole function while using VFIO-PCI, why do
>>> the application and the
>>> function need to enable PASID capability? (Since just one I/O page table
>>> is enough for them.)
>> At the moment the series doesn't provide support for SVA without PASID
>> (on the I/O page fault path, 08/40). In addition the BIND ioctl could be
>> used by the owner application to bind other processes (slaves) and
>> perform sub-assignment. But that feature is incomplete because we don't
>> send stop_pasid notification to the owner when a slave dies.
>>
> So, Could I understand like this?
> 
>      1. While the series are finished well, VFIO-PCI device can be held 
> by only one process
>          through binding IOCTL command without PASID (without PASID 
> being exposed user space).

It could, but isn't supported at the moment. In addition to adding
support in the I/O page fault code, we'd also need to update the VFIO
API. Currently a VFIO_TYPE1 domain always supports the MAP/UNMAP ioctl.
The case you describe isn't compatible with MAP/UNMAP, since the process
manages the shared address space with mmap or malloc. We'd probably need
to introduce a new VFIO IOMMU type, in which case the bind could be
performed implicitly when the process does VFIO_SET_IOMMU. Then the
process wouldn't need to send an additional BIND IOCTL.

>      2. While using VFIO-PCI device to support multiple processes with 
> SVA series, a primary
>          process with multiple secondary processes must be deployed just 
> like DPDK(https://www.dpdk.org/).
>          And, the PASID still has to be exposed to user land.

Right. A third case, also implemented by this patch (and complete), is
the primary process simply doing a BIND for itself, and using the
returned PASID to share its own address space with the device.

Thanks,
Jean
