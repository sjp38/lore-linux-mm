Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9D4E76B0494
	for <linux-mm@kvack.org>; Thu, 17 May 2018 06:02:17 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id j75-v6so2627659oib.5
        for <linux-mm@kvack.org>; Thu, 17 May 2018 03:02:17 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g14-v6si1766581otc.360.2018.05.17.03.02.16
        for <linux-mm@kvack.org>;
        Thu, 17 May 2018 03:02:16 -0700 (PDT)
Subject: Re: [PATCH v2 01/40] iommu: Introduce Shared Virtual Addressing API
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-2-jean-philippe.brucker@arm.com>
 <20180516134150.34fc8857@jacob-builder>
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Message-ID: <96c1e0f0-0aa7-badf-123e-cbb1b05e645e@arm.com>
Date: Thu, 17 May 2018 11:02:02 +0100
MIME-Version: 1.0
In-Reply-To: <20180516134150.34fc8857@jacob-builder>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jacob Pan <jacob.jun.pan@linux.intel.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "joro@8bytes.org" <joro@8bytes.org>, Will Deacon <Will.Deacon@arm.com>, Robin Murphy <Robin.Murphy@arm.com>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "tn@semihalf.com" <tn@semihalf.com>, "liubo95@huawei.com" <liubo95@huawei.com>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "xuzaibo@huawei.com" <xuzaibo@huawei.com>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "liudongdong3@huawei.com" <liudongdong3@huawei.com>, "shunyong.yang@hxt-semitech.com" <shunyong.yang@hxt-semitech.com>, "nwatters@codeaurora.org" <nwatters@codeaurora.org>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "jcrouse@codeaurora.org" <jcrouse@codeaurora.org>, "rfranz@cavium.com" <rfranz@cavium.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "yi.l.liu@intel.com" <yi.l.liu@intel.com>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "kevin.tian@intel.com" <kevin.tian@intel.com>, "baolu.lu@linux.intel.com" <baolu.lu@linux.intel.com>, "robdclark@gmail.com" <robdclark@gmail.com>, "christian.koenig@amd.com" <christian.koenig@amd.com>, "bharatku@xilinx.com" <bharatku@xilinx.com>, "rgummal@xilinx.com" <rgummal@xilinx.com>

Hi Jacob,

Thanks for reviewing this

On 16/05/18 21:41, Jacob Pan wrote:
>> + * The device must support multiple address spaces (e.g. PCI PASID).
>> By default
>> + * the PASID allocated during bind() is limited by the IOMMU
>> capacity, and by
>> + * the device PASID width defined in the PCI capability or in the
>> firmware
>> + * description. Setting @max_pasid to a non-zero value smaller than
>> this limit
>> + * overrides it.
>> + *
> seems the min_pasid never gets used. do you really need it?

Yes, the SMMU sets it to 1 in patch 28/40, because it needs to reserve
PASID 0

>> + * The device should not be performing any DMA while this function
>> is running,
>> + * otherwise the behavior is undefined.
>> + *
>> + * Return 0 if initialization succeeded, or an error.
>> + */
>> +int iommu_sva_device_init(struct device *dev, unsigned long features,
>> +			  unsigned int max_pasid)
>> +{
>> +	int ret;
>> +	struct iommu_sva_param *param;
>> +	struct iommu_domain *domain = iommu_get_domain_for_dev(dev);
>> +
>> +	if (!domain || !domain->ops->sva_device_init)
>> +		return -ENODEV;
>> +
>> +	if (features)
>> +		return -EINVAL;
> should it be !features?

This checks if the user sets any unsupported bit in features. No feature
is supported right now, but patch 09/40 adds IOMMU_SVA_FEAT_IOPF, and
changes this line to "features & ~IOMMU_SVA_FEAT_IOPF"

>> +	mutex_lock(&dev->iommu_param->lock);
>> +	param = dev->iommu_param->sva_param;
>> +	dev->iommu_param->sva_param = NULL;
>> +	mutex_unlock(&dev->iommu_param->lock);
>> +	if (!param)
>> +		return -ENODEV;
>> +
>> +	if (domain->ops->sva_device_shutdown)
>> +		domain->ops->sva_device_shutdown(dev, param);
> seems a little mismatch here, do you need pass the param. I don't think
> there is anything else model specific iommu driver need to do for the
> param.

SMMU doesn't use it, but maybe it would remind other IOMMU driver which
features were enabled, so they don't have to keep track of that
themselves? I can remove it if it isn't useful

Thanks,
Jean
