Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F0056B035C
	for <linux-mm@kvack.org>; Wed, 16 May 2018 16:39:05 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id z2-v6so819312pgo.17
        for <linux-mm@kvack.org>; Wed, 16 May 2018 13:39:05 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r74-v6si3381821pfe.168.2018.05.16.13.39.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 13:39:04 -0700 (PDT)
Date: Wed, 16 May 2018 13:41:50 -0700
From: Jacob Pan <jacob.jun.pan@linux.intel.com>
Subject: Re: [PATCH v2 01/40] iommu: Introduce Shared Virtual Addressing API
Message-ID: <20180516134150.34fc8857@jacob-builder>
In-Reply-To: <20180511190641.23008-2-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
	<20180511190641.23008-2-jean-philippe.brucker@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com, jacob.jun.pan@linux.intel.com

On Fri, 11 May 2018 20:06:02 +0100
Jean-Philippe Brucker <jean-philippe.brucker@arm.com> wrote:

> Shared Virtual Addressing (SVA) provides a way for device drivers to
> bind process address spaces to devices. This requires the IOMMU to
> support page table format and features compatible with the CPUs, and
> usually requires the system to support I/O Page Faults (IOPF) and
> Process Address Space ID (PASID). When all of these are available,
> DMA can access virtual addresses of a process. A PASID is allocated
> for each process, and the device driver programs it into the device
> in an implementation-specific way.
> 
> Add a new API for sharing process page tables with devices. Introduce
> two IOMMU operations, sva_device_init() and sva_device_shutdown(),
> that prepare the IOMMU driver for SVA. For example allocate PASID
> tables and fault queues. Subsequent patches will implement the bind()
> and unbind() operations.
> 
> Support for I/O Page Faults will be added in a later patch using a new
> feature bit (IOMMU_SVA_FEAT_IOPF). With the current API users must pin
> down all shared mappings. Other feature bits that may be added in the
> future are IOMMU_SVA_FEAT_PRIVATE, to support private PASID address
> spaces, and IOMMU_SVA_FEAT_NO_PASID, to bind the whole device address
> space to a process.
> 
> Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
> 
> ---
> v1->v2:
> * Add sva_param structure to iommu_param
> * CONFIG option is only selectable by IOMMU drivers
> ---
>  drivers/iommu/Kconfig     |   4 ++
>  drivers/iommu/Makefile    |   1 +
>  drivers/iommu/iommu-sva.c | 110
> ++++++++++++++++++++++++++++++++++++++ include/linux/iommu.h     |
> 32 +++++++++++ 4 files changed, 147 insertions(+)
>  create mode 100644 drivers/iommu/iommu-sva.c
> 
> diff --git a/drivers/iommu/Kconfig b/drivers/iommu/Kconfig
> index 7564237f788d..cca8e06903c7 100644
> --- a/drivers/iommu/Kconfig
> +++ b/drivers/iommu/Kconfig
> @@ -74,6 +74,10 @@ config IOMMU_DMA
>  	select IOMMU_IOVA
>  	select NEED_SG_DMA_LENGTH
>  
> +config IOMMU_SVA
> +	bool
> +	select IOMMU_API
> +
>  config FSL_PAMU
>  	bool "Freescale IOMMU support"
>  	depends on PCI
> diff --git a/drivers/iommu/Makefile b/drivers/iommu/Makefile
> index 1fb695854809..1dbcc89ebe4c 100644
> --- a/drivers/iommu/Makefile
> +++ b/drivers/iommu/Makefile
> @@ -3,6 +3,7 @@ obj-$(CONFIG_IOMMU_API) += iommu.o
>  obj-$(CONFIG_IOMMU_API) += iommu-traces.o
>  obj-$(CONFIG_IOMMU_API) += iommu-sysfs.o
>  obj-$(CONFIG_IOMMU_DMA) += dma-iommu.o
> +obj-$(CONFIG_IOMMU_SVA) += iommu-sva.o
>  obj-$(CONFIG_IOMMU_IO_PGTABLE) += io-pgtable.o
>  obj-$(CONFIG_IOMMU_IO_PGTABLE_ARMV7S) += io-pgtable-arm-v7s.o
>  obj-$(CONFIG_IOMMU_IO_PGTABLE_LPAE) += io-pgtable-arm.o
> diff --git a/drivers/iommu/iommu-sva.c b/drivers/iommu/iommu-sva.c
> new file mode 100644
> index 000000000000..8b4afb7c63ae
> --- /dev/null
> +++ b/drivers/iommu/iommu-sva.c
> @@ -0,0 +1,110 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * Manage PASIDs and bind process address spaces to devices.
> + *
> + * Copyright (C) 2018 ARM Ltd.
> + */
> +
> +#include <linux/iommu.h>
> +#include <linux/slab.h>
> +
> +/**
> + * iommu_sva_device_init() - Initialize Shared Virtual Addressing
> for a device
> + * @dev: the device
> + * @features: bitmask of features that need to be initialized
> + * @max_pasid: max PASID value supported by the device
> + *
> + * Users of the bind()/unbind() API must call this function to
> initialize all
> + * features required for SVA.
> + *
> + * The device must support multiple address spaces (e.g. PCI PASID).
> By default
> + * the PASID allocated during bind() is limited by the IOMMU
> capacity, and by
> + * the device PASID width defined in the PCI capability or in the
> firmware
> + * description. Setting @max_pasid to a non-zero value smaller than
> this limit
> + * overrides it.
> + *
seems the min_pasid never gets used. do you really need it?
 
> + * The device should not be performing any DMA while this function
> is running,
> + * otherwise the behavior is undefined.
> + *
> + * Return 0 if initialization succeeded, or an error.
> + */
> +int iommu_sva_device_init(struct device *dev, unsigned long features,
> +			  unsigned int max_pasid)
> +{
> +	int ret;
> +	struct iommu_sva_param *param;
> +	struct iommu_domain *domain = iommu_get_domain_for_dev(dev);
> +
> +	if (!domain || !domain->ops->sva_device_init)
> +		return -ENODEV;
> +
> +	if (features)
> +		return -EINVAL;
should it be !features?

> +
> +	param = kzalloc(sizeof(*param), GFP_KERNEL);
> +	if (!param)
> +		return -ENOMEM;
> +
> +	param->features		= features;
> +	param->max_pasid	= max_pasid;
> +
> +	/*
> +	 * IOMMU driver updates the limits depending on the IOMMU
> and device
> +	 * capabilities.
> +	 */
> +	ret = domain->ops->sva_device_init(dev, param);
> +	if (ret)
> +		goto err_free_param;
> +
> +	mutex_lock(&dev->iommu_param->lock);
> +	if (dev->iommu_param->sva_param)
> +		ret = -EEXIST;
> +	else
> +		dev->iommu_param->sva_param = param;
> +	mutex_unlock(&dev->iommu_param->lock);
> +	if (ret)
> +		goto err_device_shutdown;
> +
> +	return 0;
> +
> +err_device_shutdown:
> +	if (domain->ops->sva_device_shutdown)
> +		domain->ops->sva_device_shutdown(dev, param);
> +
> +err_free_param:
> +	kfree(param);
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(iommu_sva_device_init);
> +
> +/**
> + * iommu_sva_device_shutdown() - Shutdown Shared Virtual Addressing
> for a device
> + * @dev: the device
> + *
> + * Disable SVA. Device driver should ensure that the device isn't
> performing any
> + * DMA while this function is running.
> + */
> +int iommu_sva_device_shutdown(struct device *dev)
> +{
> +	struct iommu_sva_param *param;
> +	struct iommu_domain *domain = iommu_get_domain_for_dev(dev);
> +
> +	if (!domain)
> +		return -ENODEV;
> +
> +	mutex_lock(&dev->iommu_param->lock);
> +	param = dev->iommu_param->sva_param;
> +	dev->iommu_param->sva_param = NULL;
> +	mutex_unlock(&dev->iommu_param->lock);
> +	if (!param)
> +		return -ENODEV;
> +
> +	if (domain->ops->sva_device_shutdown)
> +		domain->ops->sva_device_shutdown(dev, param);
seems a little mismatch here, do you need pass the param. I don't think
there is anything else model specific iommu driver need to do for the
param.
> +
> +	kfree(param);
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(iommu_sva_device_shutdown);
> diff --git a/include/linux/iommu.h b/include/linux/iommu.h
> index 0933f726d2e6..2efe7738bedb 100644
> --- a/include/linux/iommu.h
> +++ b/include/linux/iommu.h
> @@ -212,6 +212,12 @@ struct page_response_msg {
>  	u64 private_data;
>  };
>  
> +struct iommu_sva_param {
> +	unsigned long features;
> +	unsigned int min_pasid;
> +	unsigned int max_pasid;
> +};
> +
>  /**
>   * struct iommu_ops - iommu ops and capabilities
>   * @capable: check capability
> @@ -219,6 +225,8 @@ struct page_response_msg {
>   * @domain_free: free iommu domain
>   * @attach_dev: attach device to an iommu domain
>   * @detach_dev: detach device from an iommu domain
> + * @sva_device_init: initialize Shared Virtual Adressing for a device
> + * @sva_device_shutdown: shutdown Shared Virtual Adressing for a
> device
>   * @map: map a physically contiguous memory region to an iommu domain
>   * @unmap: unmap a physically contiguous memory region from an iommu
> domain
>   * @map_sg: map a scatter-gather list of physically contiguous
> memory chunks @@ -256,6 +264,10 @@ struct iommu_ops {
>  
>  	int (*attach_dev)(struct iommu_domain *domain, struct device
> *dev); void (*detach_dev)(struct iommu_domain *domain, struct device
> *dev);
> +	int (*sva_device_init)(struct device *dev,
> +			       struct iommu_sva_param *param);
> +	void (*sva_device_shutdown)(struct device *dev,
> +				    struct iommu_sva_param *param);
>  	int (*map)(struct iommu_domain *domain, unsigned long iova,
>  		   phys_addr_t paddr, size_t size, int prot);
>  	size_t (*unmap)(struct iommu_domain *domain, unsigned long
> iova, @@ -413,6 +425,7 @@ struct iommu_fault_param {
>   * struct iommu_param - collection of per-device IOMMU data
>   *
>   * @fault_param: IOMMU detected device fault reporting data
> + * @sva_param: SVA parameters
>   *
>   * TODO: migrate other per device data pointers under
> iommu_dev_data, e.g.
>   *	struct iommu_group	*iommu_group;
> @@ -421,6 +434,7 @@ struct iommu_fault_param {
>  struct iommu_param {
>  	struct mutex lock;
>  	struct iommu_fault_param *fault_param;
> +	struct iommu_sva_param *sva_param;
>  };
>  
>  int  iommu_device_register(struct iommu_device *iommu);
> @@ -920,4 +934,22 @@ static inline int iommu_sva_invalidate(struct
> iommu_domain *domain, 
>  #endif /* CONFIG_IOMMU_API */
>  
> +#ifdef CONFIG_IOMMU_SVA
> +extern int iommu_sva_device_init(struct device *dev, unsigned long
> features,
> +				 unsigned int max_pasid);
> +extern int iommu_sva_device_shutdown(struct device *dev);
> +#else /* CONFIG_IOMMU_SVA */
> +static inline int iommu_sva_device_init(struct device *dev,
> +					unsigned long features,
> +					unsigned int max_pasid)
> +{
> +	return -ENODEV;
> +}
> +
> +static inline int iommu_sva_device_shutdown(struct device *dev)
> +{
> +	return -ENODEV;
> +}
> +#endif /* CONFIG_IOMMU_SVA */
> +
>  #endif /* __LINUX_IOMMU_H */

[Jacob Pan]
