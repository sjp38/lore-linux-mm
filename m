Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7780E6B7867
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 07:10:02 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id p11-v6so12236713oih.17
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 04:10:02 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i5-v6si2879485oii.19.2018.09.06.04.10.01
        for <linux-mm@kvack.org>;
        Thu, 06 Sep 2018 04:10:01 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: Re: [PATCH v2 02/40] iommu/sva: Bind process address spaces to
 devices
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-3-jean-philippe.brucker@arm.com>
 <471873d4-a1a6-1a3a-cf17-1e686b4ade96@redhat.com>
Message-ID: <fbe7615d-2236-8080-c54f-f53da8118f93@arm.com>
Date: Thu, 6 Sep 2018 12:09:42 +0100
MIME-Version: 1.0
In-Reply-To: <471873d4-a1a6-1a3a-cf17-1e686b4ade96@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Auger Eric <eric.auger@redhat.com>, linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: xieyisheng1@huawei.com, liubo95@huawei.com, xuzaibo@huawei.com, thunder.leizhen@huawei.com, will.deacon@arm.com, okaya@codeaurora.org, yi.l.liu@intel.com, ashok.raj@intel.com, tn@semihalf.com, joro@8bytes.org, bharatku@xilinx.com, liudongdong3@huawei.com, rfranz@cavium.com, kevin.tian@intel.com, jacob.jun.pan@linux.intel.com, jcrouse@codeaurora.org, rgummal@xilinx.com, jonathan.cameron@huawei.com, shunyong.yang@hxt-semitech.com, robin.murphy@arm.com, ilias.apalodimas@linaro.org, alex.williamson@redhat.com, robdclark@gmail.com, dwmw2@infradead.org, christian.koenig@amd.com, nwatters@codeaurora.org, baolu.lu@linux.intel.com

On 05/09/2018 12:29, Auger Eric wrote:
>> +/**
>> + * iommu_sva_bind_device() - Bind a process address space to a device
>> + * @dev: the device
>> + * @mm: the mm to bind, caller must hold a reference to it
>> + * @pasid: valid address where the PASID will be stored
>> + * @flags: bond properties
>> + * @drvdata: private data passed to the mm exit handler
>> + *
>> + * Create a bond between device and task, allowing the device to access the mm
>> + * using the returned PASID. If unbind() isn't called first, a subsequent bind()
>> + * for the same device and mm fails with -EEXIST.
>> + *
>> + * iommu_sva_device_init() must be called first, to initialize the required SVA
>> + * features. @flags is a subset of these features.
> @flags must be a subset of these features?

Ok

> don't you want to check flags is a subset of
> dev->iommu_param->sva_param->features?

Yes, that will be in next version

>> +/**
>> + * iommu_sva_unbind_device() - Remove a bond created with iommu_sva_bind_device
>> + * @dev: the device
>> + * @pasid: the pasid returned by bind()
>> + *
>> + * Remove bond between device and address space identified by @pasid. Users
>> + * should not call unbind() if the corresponding mm exited (as the PASID might
>> + * have been reallocated for another process).
>> + *
>> + * The device must not be issuing any more transaction for this PASID. All
>> + * outstanding page requests for this PASID must have been flushed to the IOMMU.
>> + *
>> + * Returns 0 on success, or an error value
>> + */
>> +int iommu_sva_unbind_device(struct device *dev, int pasid)
> returned value needed?

I'd rather keep this one, since it already pointed out some of my bugs
during regression testing.

Thanks,
Jean
