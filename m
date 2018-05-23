Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0779A6B0007
	for <linux-mm@kvack.org>; Wed, 23 May 2018 05:39:26 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b25-v6so12788226pfn.10
        for <linux-mm@kvack.org>; Wed, 23 May 2018 02:39:25 -0700 (PDT)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id p15-v6si14067981pgc.463.2018.05.23.02.39.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 02:39:25 -0700 (PDT)
Subject: Re: [PATCH v2 13/40] vfio: Add support for Shared Virtual Addressing
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-14-jean-philippe.brucker@arm.com>
From: Xu Zaibo <xuzaibo@huawei.com>
Message-ID: <5B0536A3.1000304@huawei.com>
Date: Wed, 23 May 2018 17:38:43 +0800
MIME-Version: 1.0
In-Reply-To: <20180511190641.23008-14-jean-philippe.brucker@arm.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com, liguozhu <liguozhu@hisilicon.com>

Hi,

On 2018/5/12 3:06, Jean-Philippe Brucker wrote:
> Add two new ioctls for VFIO containers. VFIO_IOMMU_BIND_PROCESS creates a
> bond between a container and a process address space, identified by a
> Process Address Space ID (PASID). Devices in the container append this
> PASID to DMA transactions in order to access the process' address space.
> The process page tables are shared with the IOMMU, and mechanisms such as
> PCI ATS/PRI are used to handle faults. VFIO_IOMMU_UNBIND_PROCESS removes a
> bond created with VFIO_IOMMU_BIND_PROCESS.
>
> Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
>
>
>
>
>
>
> +static int vfio_iommu_bind_group(struct vfio_iommu *iommu,
> +				 struct vfio_group *group,
> +				 struct vfio_mm *vfio_mm)
> +{
> +	int ret;
> +	bool enabled_sva = false;
> +	struct vfio_iommu_sva_bind_data data = {
> +		.vfio_mm	= vfio_mm,
> +		.iommu		= iommu,
> +		.count		= 0,
> +	};
> +
> +	if (!group->sva_enabled) {
> +		ret = iommu_group_for_each_dev(group->iommu_group, NULL,
> +					       vfio_iommu_sva_init);
Do we need to do *sva_init here or do anything to avoid repeated initiation?
while another process already did initiation at this device, I think 
that current process will get an EEXIST.

Thanks.
> +		if (ret)
> +			return ret;
> +
> +		group->sva_enabled = enabled_sva = true;
> +	}
> +
> +	ret = iommu_group_for_each_dev(group->iommu_group, &data,
> +				       vfio_iommu_sva_bind_dev);
> +	if (ret && data.count > 1)
> +		iommu_group_for_each_dev(group->iommu_group, vfio_mm,
> +					 vfio_iommu_sva_unbind_dev);
> +	if (ret && enabled_sva) {
> +		iommu_group_for_each_dev(group->iommu_group, NULL,
> +					 vfio_iommu_sva_shutdown);
> +		group->sva_enabled = false;
> +	}
> +
> +	return ret;
> +}
>
>
>   
> @@ -1442,6 +1636,10 @@ static int vfio_iommu_type1_attach_group(void *iommu_data,
>   	if (ret)
>   		goto out_detach;
>   
> +	ret = vfio_iommu_replay_bind(iommu, group);
> +	if (ret)
> +		goto out_detach;
> +
>   	if (resv_msi) {
>   		ret = iommu_get_msi_cookie(domain->domain, resv_msi_base);
>   		if (ret)
> @@ -1547,6 +1745,11 @@ static void vfio_iommu_type1_detach_group(void *iommu_data,
>   			continue;
>   
>   		iommu_detach_group(domain->domain, iommu_group);
> +		if (group->sva_enabled) {
> +			iommu_group_for_each_dev(iommu_group, NULL,
> +						 vfio_iommu_sva_shutdown);
> +			group->sva_enabled = false;
> +		}
Here, why shut down here? If another process is working on the device, 
there may be a crash?

Thanks.
>   		list_del(&group->next);
>   		kfree(group);
>   		/*
> @@ -1562,6 +1765,7 @@ static void vfio_iommu_type1_detach_group(void *iommu_data,
>
