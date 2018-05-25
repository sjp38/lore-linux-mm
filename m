Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6596B0006
	for <linux-mm@kvack.org>; Fri, 25 May 2018 05:47:56 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id w12-v6so2092677otg.2
        for <linux-mm@kvack.org>; Fri, 25 May 2018 02:47:56 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k89-v6si8436974otc.189.2018.05.25.02.47.54
        for <linux-mm@kvack.org>;
        Fri, 25 May 2018 02:47:55 -0700 (PDT)
Subject: Re: [PATCH v2 13/40] vfio: Add support for Shared Virtual Addressing
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-14-jean-philippe.brucker@arm.com>
 <5B0536A3.1000304@huawei.com> <cd13f60d-b282-3804-4ca7-2d34476c597f@arm.com>
 <5B06B17C.1090809@huawei.com> <205c1729-8026-3efe-c363-d37d7150d622@arm.com>
 <5B077765.30703@huawei.com>
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Message-ID: <fea420ff-e738-e2ed-ab1e-a3f4dde4b6ef@arm.com>
Date: Fri, 25 May 2018 10:47:43 +0100
MIME-Version: 1.0
In-Reply-To: <5B077765.30703@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xu Zaibo <xuzaibo@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Will Deacon <Will.Deacon@arm.com>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "liguozhu@hisilicon.com" <liguozhu@hisilicon.com>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "bharatku@xilinx.com" <bharatku@xilinx.com>, "rfranz@cavium.com" <rfranz@cavium.com>, "rgummal@xilinx.com" <rgummal@xilinx.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "christian.koenig@amd.com" <christian.koenig@amd.com>

On 25/05/18 03:39, Xu Zaibo wrote:
> Hi,
> 
> On 2018/5/24 23:04, Jean-Philippe Brucker wrote:
>> On 24/05/18 13:35, Xu Zaibo wrote:
>>>> Right, sva_init() must be called once for any device that intends to use
>>>> bind(). For the second process though, group->sva_enabled will be true
>>>> so we won't call sva_init() again, only bind().
>>> Well, while I create mediated devices based on one parent device to support multiple
>>> processes(a new process will create a new 'vfio_group' for the corresponding mediated device,
>>> and 'sva_enabled' cannot work any more), in fact, *sva_init and *sva_shutdown are basically
>>> working on parent device, so, as a result, I just only need sva initiation and shutdown on the
>>> parent device only once. So I change the two as following:
>>>
>>> @@ -551,8 +565,18 @@ int iommu_sva_device_init(struct device *dev, unsigned long features,
>>>        if (features & ~IOMMU_SVA_FEAT_IOPF)
>>>           return -EINVAL;
>>>
>>> +    /* If already exists, do nothing  */
>>> +    mutex_lock(&dev->iommu_param->lock);
>>> +    if (dev->iommu_param->sva_param) {
>>> +        mutex_unlock(&dev->iommu_param->lock);
>>> +        return 0;
>>> +    }
>>> +    mutex_unlock(&dev->iommu_param->lock);
>>>
>>>       if (features & IOMMU_SVA_FEAT_IOPF) {
>>>           ret = iommu_register_device_fault_handler(dev, iommu_queue_iopf,
>>>
>>>
>>> @@ -621,6 +646,14 @@ int iommu_sva_device_shutdown(struct device *dev)
>>>       if (!domain)
>>>           return -ENODEV;
>>>
>>> +    /* If any other process is working on the device, shut down does nothing. */
>>> +    mutex_lock(&dev->iommu_param->lock);
>>> +    if (!list_empty(&dev->iommu_param->sva_param->mm_list)) {
>>> +        mutex_unlock(&dev->iommu_param->lock);
>>> +        return 0;
>>> +    }
>>> +    mutex_unlock(&dev->iommu_param->lock);
>> I don't think iommu-sva.c is the best place for this, it's probably
>> better to implement an intermediate layer (the mediating driver), that
>> calls iommu_sva_device_init() and iommu_sva_device_shutdown() once. Then
>> vfio-pci would still call these functions itself, but for mdev the
>> mediating driver keeps a refcount of groups, and calls device_shutdown()
>> only when freeing the last mdev.
>>
>> A device driver (non mdev in this example) expects to be able to free
>> all its resources after sva_device_shutdown() returns. Imagine the
>> mm_list isn't empty (mm_exit() is running late), and instead of waiting
>> in unbind_dev_all() below, we return 0 immediately. Then the calling
>> driver frees its resources, and the mm_exit callback along with private
>> data passed to bind() disappear. If a mm_exit() is still running in
>> parallel, then it will try to access freed data and corrupt memory. So
>> in this function if mm_list isn't empty, the only thing we can do is wait.
>>
> I still don't understand why we should 'unbind_dev_all', is it possible 
> to do a 'unbind_dev_pasid'?

Not in sva_device_shutdown(), it needs to clean up everything. For
example you want to physically unplug the device, or assign it to a VM.
To prevent any leak sva_device_shutdown() needs to remove all bonds. In
theory there shouldn't be any, since either the driver did unbind_dev(),
or all process exited. This is a safety net.

> Then we can do other things instead of waiting that user may not like. :)

They may not like it, but it's for their own good :) At the moment we're
waiting that:

* All exit_mm() callback for this device have finished. If we don't wait
  then the caller will free the private data passed to bind and the
  mm_exit() callback while they are still being used.

* All page requests targeting this device are dealt with. If we don't
  wait then some requests, that are lingering in the IOMMU PRI queue,
  may hit the next contexts bound to this device, possibly in a
  different VM. It may not be too risky (though probably exploitable in
  some way), but is incredibly messy.

All of this is bounded in time, and normally should be over pretty fast
unless the device driver's exit_mm() does something strange. If the
driver did the right thing, there shouldn't be any wait here (although
there may be one in unbind_dev() for the same reasons - prevent use
after free).

Thanks,
Jean
