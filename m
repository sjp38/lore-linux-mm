Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 95CD56B72C3
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 07:02:50 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id l191-v6so7973469oig.23
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 04:02:50 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y136-v6si1124268oia.410.2018.09.05.04.02.49
        for <linux-mm@kvack.org>;
        Wed, 05 Sep 2018 04:02:49 -0700 (PDT)
Subject: Re: [PATCH v2 13/40] vfio: Add support for Shared Virtual Addressing
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-14-jean-philippe.brucker@arm.com>
 <5B83B11E.7010807@huawei.com> <1d5b6529-4e5a-723c-3f1b-dd5a9adb490c@arm.com>
 <5B89F818.7060300@huawei.com> <3a961aff-e830-64bb-b6a9-14e08de1abf5@arm.com>
 <5B8DEA15.7020404@huawei.com> <bc27f902-4d12-21b7-b9e9-18bcae170503@arm.com>
 <5B8F4A59.20004@huawei.com>
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Message-ID: <b51107b8-a525-13ce-f4c3-d423b8502c27@arm.com>
Date: Wed, 5 Sep 2018 12:02:29 +0100
MIME-Version: 1.0
In-Reply-To: <5B8F4A59.20004@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xu Zaibo <xuzaibo@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "joro@8bytes.org" <joro@8bytes.org>, Will Deacon <Will.Deacon@arm.com>, Robin Murphy <Robin.Murphy@arm.com>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "tn@semihalf.com" <tn@semihalf.com>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "liudongdong3@huawei.com" <liudongdong3@huawei.com>, "shunyong.yang@hxt-semitech.com" <shunyong.yang@hxt-semitech.com>, "nwatters@codeaurora.org" <nwatters@codeaurora.org>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "jcrouse@codeaurora.org" <jcrouse@codeaurora.org>, "rfranz@cavium.com" <rfranz@cavium.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "jacob.jun.pan@linux.intel.com" <jacob.jun.pan@linux.intel.com>, "yi.l.liu@intel.com" <yi.l.liu@intel.com>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "kevin.tian@intel.com" <kevin.tian@intel.com>, "baolu.lu@linux.intel.com" <baolu.lu@linux.intel.com>, "robdclark@gmail.com" <robdclark@gmail.com>, "christian.koenig@amd.com" <christian.koenig@amd.com>, "bharatku@xilinx.com" <bharatku@xilinx.com>, "rgummal@xilinx.com" <rgummal@xilinx.com>, =?UTF-8?B?57Gz57Gz?= <kenneth-lee-2012@foxmail.com>, wangzhou1 <wangzhou1@hisilicon.com>, "liguozhu@hisilicon.com" <liguozhu@hisilicon.com>, fanghao11 <fanghao11@huawei.com>

On 05/09/2018 04:15, Xu Zaibo wrote:
>>>       1. While the series are finished well, VFIO-PCI device can be held
>>> by only one process
>>>           through binding IOCTL command without PASID (without PASID
>>> being exposed user space).
>> It could, but isn't supported at the moment. In addition to adding
>> support in the I/O page fault code, we'd also need to update the VFIO
>> API. Currently a VFIO_TYPE1 domain always supports the MAP/UNMAP ioctl.
>> The case you describe isn't compatible with MAP/UNMAP, since the process
>> manages the shared address space with mmap or malloc. We'd probably need
>> to introduce a new VFIO IOMMU type, in which case the bind could be
>> performed implicitly when the process does VFIO_SET_IOMMU. Then the
>> process wouldn't need to send an additional BIND IOCTL.
> ok. got it.  This is the legacy mode, so all the VFIO APIs are kept 
> unchanged?

Yes, existing VFIO semantics are preserved

>>>       2. While using VFIO-PCI device to support multiple processes with
>>> SVA series, a primary
>>>           process with multiple secondary processes must be deployed just
>>> like DPDK(https://www.dpdk.org/).
>>>           And, the PASID still has to be exposed to user land.
>> Right. A third case, also implemented by this patch (and complete), is
>> the primary process simply doing a BIND for itself, and using the
>> returned PASID to share its own address space with the device.
>>
> ok. But I am worried that the sulotion of one primary processes with 
> several secondary ones
> 
> is a little bit limited. Maybe, users don't want to depend on the 
> primary process. :)

I don't see a better way for vfio-pci, though. But more importantly, I
don't know of any users :) While the feature is great for testing new
hardware, and I've been using it for all kinds of stress testing, I
haven't received feedback from possible users in production settings
(DPDK etc) and can't speculate about what they'd prefer.

Thanks,
Jean
