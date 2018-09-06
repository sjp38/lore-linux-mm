Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 35D276B7872
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 07:13:03 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f32-v6so5390724pgm.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 04:13:03 -0700 (PDT)
Received: from NAM05-DM3-obe.outbound.protection.outlook.com (mail-eopbgr730047.outbound.protection.outlook.com. [40.107.73.47])
        by mx.google.com with ESMTPS id gn12si4610240plb.147.2018.09.06.04.13.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 06 Sep 2018 04:13:02 -0700 (PDT)
Subject: Re: [PATCH v2 01/40] iommu: Introduce Shared Virtual Addressing API
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-2-jean-philippe.brucker@arm.com>
 <bf42affd-e9d0-e4fc-6d28-f3c3f7795348@redhat.com>
 <03d31ba5-1eda-ea86-8c0c-91d14c86fe83@arm.com>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Message-ID: <ed39159c-087e-7e56-7d29-d1de9fa1677f@amd.com>
Date: Thu, 6 Sep 2018 13:12:42 +0200
MIME-Version: 1.0
In-Reply-To: <03d31ba5-1eda-ea86-8c0c-91d14c86fe83@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, Auger Eric <eric.auger@redhat.com>, linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: xieyisheng1@huawei.com, liubo95@huawei.com, xuzaibo@huawei.com, thunder.leizhen@huawei.com, will.deacon@arm.com, okaya@codeaurora.org, yi.l.liu@intel.com, ashok.raj@intel.com, tn@semihalf.com, joro@8bytes.org, bharatku@xilinx.com, liudongdong3@huawei.com, rfranz@cavium.com, kevin.tian@intel.com, jacob.jun.pan@linux.intel.com, jcrouse@codeaurora.org, rgummal@xilinx.com, jonathan.cameron@huawei.com, shunyong.yang@hxt-semitech.com, robin.murphy@arm.com, ilias.apalodimas@linaro.org, alex.williamson@redhat.com, robdclark@gmail.com, dwmw2@infradead.org, nwatters@codeaurora.org, baolu.lu@linux.intel.com

Am 06.09.2018 um 13:09 schrieb Jean-Philippe Brucker:
> Hi Eric,
>
> Thanks for reviewing
>
> On 05/09/2018 12:29, Auger Eric wrote:
>>> +int iommu_sva_device_init(struct device *dev, unsigned long features,
>>> +			  unsigned int max_pasid)
>> what about min_pasid?
> No one asked for it... The max_pasid parameter is here for drivers that
> have vendor-specific PASID size limits, such as AMD KFD (see
> kfd_iommu_device_init and
> https://patchwork.kernel.org/patch/9989307/#21389571). But in most cases
> the PASID size will only depend on the PCI PASID capability and the
> IOMMU limits, both known by the IOMMU driver, so device drivers won't
> have to set max_pasid.
>
> IOMMU drivers need to set min_pasid in the sva_device_init callback
> because it may be either 1 (e.g. Arm where PASID #0 is reserved) or 0
> (Intel Vt-d rev2), but at the moment I can't see a reason for device
> drivers to override min_pasid

Sorry to ruin your day, but if I'm not completely mistaken PASID zero is 
reserved in the AMD KFD as well.

Regards,
Christian.

>
>>> +	/*
>>> +	 * IOMMU driver updates the limits depending on the IOMMU and device
>>> +	 * capabilities.
>>> +	 */
>>> +	ret = domain->ops->sva_device_init(dev, param);
>>> +	if (ret)
>>> +		goto err_free_param;
>> So you are likely to call sva_device_init even if it was already called
>> (ie. dev->iommu_param->sva_param is already set). Can't you test whether
>> dev->iommu_param->sva_param is already set first?
> Right, that's probably better
>
>>> +/**
>>> + * iommu_sva_device_shutdown() - Shutdown Shared Virtual Addressing for a device
>>> + * @dev: the device
>>> + *
>>> + * Disable SVA. Device driver should ensure that the device isn't performing any
>>> + * DMA while this function is running.
>>> + */
>>> +int iommu_sva_device_shutdown(struct device *dev)
>> Not sure the returned value is required for a shutdown operation.
> I don't know either. I like them because they help me debug, but are
> otherwise rather useless if we don't describe precise semantics. The
> caller cannot do anything with it. Given that the corresponding IOMMU op
> is already void, I can change this function to void as well
>
>>> +struct iommu_sva_param {
>> What are the feature values?
> At the moment only IOMMU_SVA_FEAT_IOPF, introduced by patch 09
>
>>> +	unsigned long features;
>>> +	unsigned int min_pasid;
>>> +	unsigned int max_pasid;
>>> +};
>>> +
>>>   /**
>>>    * struct iommu_ops - iommu ops and capabilities
>>>    * @capable: check capability
>>> @@ -219,6 +225,8 @@ struct page_response_msg {
>>>    * @domain_free: free iommu domain
>>>    * @attach_dev: attach device to an iommu domain
>>>    * @detach_dev: detach device from an iommu domain
>>> + * @sva_device_init: initialize Shared Virtual Adressing for a device
>> Addressing
>>> + * @sva_device_shutdown: shutdown Shared Virtual Adressing for a device
>> Addressing
> Nice catch
>
> Thanks,
> Jean
