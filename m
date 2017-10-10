Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B9FF76B0253
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 14:16:54 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p2so37485454pfk.0
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 11:16:54 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 1si9617621pli.46.2017.10.10.11.16.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 11:16:53 -0700 (PDT)
Date: Tue, 10 Oct 2017 07:40:01 -0700
From: "Raj, Ashok" <ashok.raj@intel.com>
Subject: Re: [PATCH v8] dma-mapping: introduce dma_get_iommu_domain()
Message-ID: <20171010144001.GA17322@otc-nc-03>
References: <150732935473.22363.1853399637339625023.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150743420333.12880.6968831423519457797.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150743420333.12880.6968831423519457797.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Joerg Roedel <joro@8bytes.org>, Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, David Woodhouse <dwmw2@infradead.org>, Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>

Hi Dan

On Sat, Oct 07, 2017 at 08:45:00PM -0700, Dan Williams wrote:
> Add a dma-mapping api helper to retrieve the generic iommu_domain for a device.
> The motivation for this interface is making RDMA transfers to DAX mappings
> safe. If the DAX file's block map changes we need to be to reliably stop
> accesses to blocks that have been freed or re-assigned to a new file. With the
> iommu_domain and a callback from the DAX filesystem the kernel can safely
> revoke access to a DMA device. The process that performed the RDMA memory
> registration is also notified of this revocation event, but the kernel can not
> otherwise be in the position of waiting for userspace to quiesce the device.
> 
> Since PMEM+DAX is currently only enabled for x86, we only update the x86
> iommu drivers.
> 
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Robin Murphy <robin.murphy@arm.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Joerg Roedel <joro@8bytes.org>
> Cc: David Woodhouse <dwmw2@infradead.org>
> Cc: Ashok Raj <ashok.raj@intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Jeff Moyer <jmoyer@redhat.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
> Changes since v7:
> * retrieve the iommu_domain so that we can later pass the results of
>   dma_map_* to iommu_unmap() in advance of the actual dma_unmap_*.
> 
>  drivers/base/dma-mapping.c  |   10 ++++++++++
>  drivers/iommu/amd_iommu.c   |   10 ++++++++++
>  drivers/iommu/intel-iommu.c |   15 +++++++++++++++
>  include/linux/dma-mapping.h |    3 +++
>  4 files changed, 38 insertions(+)
> 
> diff --git a/drivers/base/dma-mapping.c b/drivers/base/dma-mapping.c
> index e584eddef0a7..fdb9764f95a4 100644
> --- a/drivers/base/dma-mapping.c
> +++ b/drivers/base/dma-mapping.c
> @@ -369,3 +369,13 @@ void dma_deconfigure(struct device *dev)
>  	of_dma_deconfigure(dev);
>  	acpi_dma_deconfigure(dev);
>  }
> +
> +struct iommu_domain *dma_get_iommu_domain(struct device *dev)
> +{
> +	const struct dma_map_ops *ops = get_dma_ops(dev);
> +
> +	if (ops && ops->get_iommu)
> +		return ops->get_iommu(dev);
> +	return NULL;
> +}
> +EXPORT_SYMBOL(dma_get_iommu_domain);
> diff --git a/drivers/iommu/amd_iommu.c b/drivers/iommu/amd_iommu.c
> index 51f8215877f5..c8e1a45af182 100644
> --- a/drivers/iommu/amd_iommu.c
> +++ b/drivers/iommu/amd_iommu.c
> @@ -2271,6 +2271,15 @@ static struct protection_domain *get_domain(struct device *dev)
>  	return domain;
>  }
>  
> +static struct iommu_domain *amd_dma_get_iommu(struct device *dev)

Minor: Do you want to keep the naming consistent.. amd_dma_get_domain() vs
get_iommu?

> +{
> +	struct protection_domain *domain = get_domain(dev);
> +
> +	if (IS_ERR(domain))
> +		return NULL;
> +	return &domain->domain;
> +}
> +
>  static void update_device_table(struct protection_domain *domain)
>  {
>  	struct iommu_dev_data *dev_data;
> @@ -2689,6 +2698,7 @@ static const struct dma_map_ops amd_iommu_dma_ops = {
>  	.unmap_sg	= unmap_sg,
>  	.dma_supported	= amd_iommu_dma_supported,
>  	.mapping_error	= amd_iommu_mapping_error,
> +	.get_iommu	= amd_dma_get_iommu,

ditto for here and other places below:

>  };
>  
>  static int init_reserved_iova_ranges(void)
> diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
> index 6784a05dd6b2..f3f4939cebad 100644
> --- a/drivers/iommu/intel-iommu.c
> +++ b/drivers/iommu/intel-iommu.c
> @@ -3578,6 +3578,20 @@ static int iommu_no_mapping(struct device *dev)
>  	return 0;
>  }
>  
> +static struct iommu_domain *intel_dma_get_iommu(struct device *dev)
> +{
> +	struct dmar_domain *domain;
> +
> +	if (iommu_no_mapping(dev))
> +		return NULL;
> +
> +	domain = get_valid_domain_for_dev(dev);
> +	if (!domain)
> +		return NULL;
> +
> +	return &domain->domain;
> +}
> +
>  static dma_addr_t __intel_map_single(struct device *dev, phys_addr_t paddr,
>  				     size_t size, int dir, u64 dma_mask)
>  {
> @@ -3872,6 +3886,7 @@ const struct dma_map_ops intel_dma_ops = {
>  	.map_page = intel_map_page,
>  	.unmap_page = intel_unmap_page,
>  	.mapping_error = intel_mapping_error,
> +	.get_iommu = intel_dma_get_iommu,
>  #ifdef CONFIG_X86
>  	.dma_supported = x86_dma_supported,
>  #endif
> diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
> index 29ce9815da87..aa62df1d0d72 100644
> --- a/include/linux/dma-mapping.h
> +++ b/include/linux/dma-mapping.h
> @@ -128,6 +128,7 @@ struct dma_map_ops {
>  				   enum dma_data_direction dir);
>  	int (*mapping_error)(struct device *dev, dma_addr_t dma_addr);
>  	int (*dma_supported)(struct device *dev, u64 mask);
> +	struct iommu_domain *(*get_iommu)(struct device *dev);
>  #ifdef ARCH_HAS_DMA_GET_REQUIRED_MASK
>  	u64 (*get_required_mask)(struct device *dev);
>  #endif
> @@ -221,6 +222,8 @@ static inline const struct dma_map_ops *get_dma_ops(struct device *dev)
>  }
>  #endif
>  
> +extern struct iommu_domain *dma_get_iommu_domain(struct device *dev);
> +
>  static inline dma_addr_t dma_map_single_attrs(struct device *dev, void *ptr,
>  					      size_t size,
>  					      enum dma_data_direction dir,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
