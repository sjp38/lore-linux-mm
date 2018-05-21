Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id D4EBE6B0005
	for <linux-mm@kvack.org>; Mon, 21 May 2018 10:51:39 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id 22-v6so10622732oix.13
        for <linux-mm@kvack.org>; Mon, 21 May 2018 07:51:39 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e79-v6si4573725oib.370.2018.05.21.07.51.38
        for <linux-mm@kvack.org>;
        Mon, 21 May 2018 07:51:38 -0700 (PDT)
Subject: Re: [PATCH v2 13/40] vfio: Add support for Shared Virtual Addressing
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-14-jean-philippe.brucker@arm.com>
 <20180517165845.00000cc9@huawei.com>
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Message-ID: <5775e215-9a71-355a-98f5-397f1917b7f7@arm.com>
Date: Mon, 21 May 2018 15:51:29 +0100
MIME-Version: 1.0
In-Reply-To: <20180517165845.00000cc9@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Cc: kvm@vger.kernel.org, linux-pci@vger.kernel.org, xuzaibo@huawei.com, will.deacon@arm.com, okaya@codeaurora.org, linux-mm@kvack.org, ashok.raj@intel.com, bharatku@xilinx.com, linux-acpi@vger.kernel.org, rfranz@cavium.com, devicetree@vger.kernel.org, rgummal@xilinx.com, linux-arm-kernel@lists.infradead.org, dwmw2@infradead.org, ilias.apalodimas@linaro.org, iommu@lists.linux-foundation.org, christian.koenig@amd.com, "yi.l.liu@intel.com" <yi.l.liu@intel.com>, "jacob.jun.pan@linux.intel.com" <jacob.jun.pan@linux.intel.com>

On 17/05/18 16:58, Jonathan Cameron wrote:
>> +static int vfio_iommu_bind_group(struct vfio_iommu *iommu,
>> +				 struct vfio_group *group,
>> +				 struct vfio_mm *vfio_mm)
>> +{
>> +	int ret;
>> +	bool enabled_sva = false;
>> +	struct vfio_iommu_sva_bind_data data = {
>> +		.vfio_mm	= vfio_mm,
>> +		.iommu		= iommu,
>> +		.count		= 0,
>> +	};
>> +
>> +	if (!group->sva_enabled) {
>> +		ret = iommu_group_for_each_dev(group->iommu_group, NULL,
>> +					       vfio_iommu_sva_init);
>> +		if (ret)
>> +			return ret;
>> +
>> +		group->sva_enabled = enabled_sva = true;
>> +	}
>> +
>> +	ret = iommu_group_for_each_dev(group->iommu_group, &data,
>> +				       vfio_iommu_sva_bind_dev);
>> +	if (ret && data.count > 1)
> 
> Are we safe to run this even if data.count == 1?  I assume that at
> that point we would always not have an iommu domain associated with the
> device so the initial check would error out.

If data.count == 1, then the first bind didn't succeed. But it's not
necessarily a domain missing, failure to bind may come from various
places. If this vfio_mm was already bound to another device then it
contains a valid PASID and it's safe to call unbind(). Otherwise we call
it with PASID -1 (VFIO_INVALID_PASID) and that's a bit of a grey area.
-1 is currently invalid everywhere, but in the future someone might
implement 32 bits of PASIDs, in which case a bond between this dev and
PASID -1 might exist. But I think it's safe for now, and whoever
redefines VFIO_INVALID_PASID when such implementation appears will also
fix this case.

> Just be nice to get rid of the special casing in this error path as then
> could just do it all under if (ret) and make it visually clearer these
> are different aspects of the same error path.

[...]
>>  static long vfio_iommu_type1_ioctl(void *iommu_data,
>>  				   unsigned int cmd, unsigned long arg)
>>  {
>> @@ -1728,6 +2097,44 @@ static long vfio_iommu_type1_ioctl(void *iommu_data,
>>  
>>  		return copy_to_user((void __user *)arg, &unmap, minsz) ?
>>  			-EFAULT : 0;
>> +
>> +	} else if (cmd == VFIO_IOMMU_BIND) {
>> +		struct vfio_iommu_type1_bind bind;
>> +
>> +		minsz = offsetofend(struct vfio_iommu_type1_bind, flags);
>> +
>> +		if (copy_from_user(&bind, (void __user *)arg, minsz))
>> +			return -EFAULT;
>> +
>> +		if (bind.argsz < minsz)
>> +			return -EINVAL;
>> +
>> +		switch (bind.flags) {
>> +		case VFIO_IOMMU_BIND_PROCESS:
>> +			return vfio_iommu_type1_bind_process(iommu, (void *)arg,
>> +							     &bind);
> 
> Can we combine these two blocks given it is only this case statement that is different?

That would be nicer, though I don't know yet what's needed for vSVA (by
Yi Liu on Cc), which will add statements to the switches.

Thanks,
Jean

> 
>> +		default:
>> +			return -EINVAL;
>> +		}
>> +
>> +	} else if (cmd == VFIO_IOMMU_UNBIND) {
>> +		struct vfio_iommu_type1_bind bind;
>> +
>> +		minsz = offsetofend(struct vfio_iommu_type1_bind, flags);
>> +
>> +		if (copy_from_user(&bind, (void __user *)arg, minsz))
>> +			return -EFAULT;
>> +
>> +		if (bind.argsz < minsz)
>> +			return -EINVAL;
>> +
>> +		switch (bind.flags) {
>> +		case VFIO_IOMMU_BIND_PROCESS:
>> +			return vfio_iommu_type1_unbind_process(iommu, (void *)arg,
>> +							       &bind);
>> +		default:
>> +			return -EINVAL;
>> +		}
>>  	}
