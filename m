Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8FE6B72E5
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 07:29:47 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id l11-v6so4875183qkk.0
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 04:29:47 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id k63-v6si1319489qkk.327.2018.09.05.04.29.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 04:29:46 -0700 (PDT)
Subject: Re: [PATCH v2 02/40] iommu/sva: Bind process address spaces to
 devices
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-3-jean-philippe.brucker@arm.com>
From: Auger Eric <eric.auger@redhat.com>
Message-ID: <471873d4-a1a6-1a3a-cf17-1e686b4ade96@redhat.com>
Date: Wed, 5 Sep 2018 13:29:37 +0200
MIME-Version: 1.0
In-Reply-To: <20180511190641.23008-3-jean-philippe.brucker@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: xieyisheng1@huawei.com, liubo95@huawei.com, xuzaibo@huawei.com, thunder.leizhen@huawei.com, will.deacon@arm.com, okaya@codeaurora.org, yi.l.liu@intel.com, ashok.raj@intel.com, tn@semihalf.com, joro@8bytes.org, bharatku@xilinx.com, liudongdong3@huawei.com, rfranz@cavium.com, kevin.tian@intel.com, jacob.jun.pan@linux.intel.com, jcrouse@codeaurora.org, rgummal@xilinx.com, jonathan.cameron@huawei.com, shunyong.yang@hxt-semitech.com, robin.murphy@arm.com, ilias.apalodimas@linaro.org, alex.williamson@redhat.com, robdclark@gmail.com, dwmw2@infradead.org, christian.koenig@amd.com, nwatters@codeaurora.org, baolu.lu@linux.intel.com

Hi Jean-Philippe,

On 05/11/2018 09:06 PM, Jean-Philippe Brucker wrote:
> Add bind() and unbind() operations to the IOMMU API. Bind() returns a
> PASID that drivers can program in hardware, to let their devices access an
> mm. This patch only adds skeletons for the device driver API, most of the
> implementation is still missing.
> 
> IOMMU groups with more than one device aren't supported for SVA at the
> moment. There may be P2P traffic between devices within a group, which
> cannot be seen by an IOMMU (note that supporting PASID doesn't add any
> form of isolation with regard to P2P). Supporting groups would require
> calling bind() for all bound processes every time a device is added to a
> group, to perform sanity checks (e.g. ensure that new devices support
> PASIDs at least as big as those already allocated in the group). It also
> means making sure that reserved ranges (IOMMU_RESV_*) of all devices are
> carved out of processes. This is already tricky with single devices, but
> becomes very difficult with groups. Since SVA-capable devices are expected
> to be cleanly isolated, and since we don't have any way to test groups or
> hot-plug, we only allow singular groups for now.
> 
> Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
> 
> ---
> v1->v2: remove iommu_sva_bind/unbind_group
> ---
>  drivers/iommu/iommu-sva.c | 27 +++++++++++++
>  drivers/iommu/iommu.c     | 83 +++++++++++++++++++++++++++++++++++++++
>  include/linux/iommu.h     | 37 +++++++++++++++++
>  3 files changed, 147 insertions(+)
> 
> diff --git a/drivers/iommu/iommu-sva.c b/drivers/iommu/iommu-sva.c
> index 8b4afb7c63ae..8d98f9c09864 100644
> --- a/drivers/iommu/iommu-sva.c
> +++ b/drivers/iommu/iommu-sva.c
> @@ -93,6 +93,8 @@ int iommu_sva_device_shutdown(struct device *dev)
>  	if (!domain)
>  		return -ENODEV;
>  
> +	__iommu_sva_unbind_dev_all(dev);
> +
>  	mutex_lock(&dev->iommu_param->lock);
>  	param = dev->iommu_param->sva_param;
>  	dev->iommu_param->sva_param = NULL;
> @@ -108,3 +110,28 @@ int iommu_sva_device_shutdown(struct device *dev)
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(iommu_sva_device_shutdown);
> +
> +int __iommu_sva_bind_device(struct device *dev, struct mm_struct *mm,
> +			    int *pasid, unsigned long flags, void *drvdata)
> +{
> +	return -ENOSYS; /* TODO */
> +}
> +EXPORT_SYMBOL_GPL(__iommu_sva_bind_device);
> +
> +int __iommu_sva_unbind_device(struct device *dev, int pasid)
> +{
> +	return -ENOSYS; /* TODO */
> +}
> +EXPORT_SYMBOL_GPL(__iommu_sva_unbind_device);
> +
> +/**
> + * __iommu_sva_unbind_dev_all() - Detach all address spaces from this device
> + * @dev: the device
> + *
> + * When detaching @device from a domain, IOMMU drivers should use this helper.
> + */
> +void __iommu_sva_unbind_dev_all(struct device *dev)
> +{
> +	/* TODO */
> +}
> +EXPORT_SYMBOL_GPL(__iommu_sva_unbind_dev_all);
> diff --git a/drivers/iommu/iommu.c b/drivers/iommu/iommu.c
> index 9e28d88c8074..bd2819deae5b 100644
> --- a/drivers/iommu/iommu.c
> +++ b/drivers/iommu/iommu.c
> @@ -2261,3 +2261,86 @@ int iommu_fwspec_add_ids(struct device *dev, u32 *ids, int num_ids)
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(iommu_fwspec_add_ids);
> +
> +/**
> + * iommu_sva_bind_device() - Bind a process address space to a device
> + * @dev: the device
> + * @mm: the mm to bind, caller must hold a reference to it
> + * @pasid: valid address where the PASID will be stored
> + * @flags: bond properties
> + * @drvdata: private data passed to the mm exit handler
> + *
> + * Create a bond between device and task, allowing the device to access the mm
> + * using the returned PASID. If unbind() isn't called first, a subsequent bind()
> + * for the same device and mm fails with -EEXIST.
> + *
> + * iommu_sva_device_init() must be called first, to initialize the required SVA
> + * features. @flags is a subset of these features.
@flags must be a subset of these features?
> + *
> + * The caller must pin down using get_user_pages*() all mappings shared with the
> + * device. mlock() isn't sufficient, as it doesn't prevent minor page faults
> + * (e.g. copy-on-write).
> + *
> + * On success, 0 is returned and @pasid contains a valid ID. Otherwise, an error
> + * is returned.
> + */
> +int iommu_sva_bind_device(struct device *dev, struct mm_struct *mm, int *pasid,
> +			  unsigned long flags, void *drvdata)
> +{
> +	int ret = -EINVAL;
> +	struct iommu_group *group;
> +
> +	if (!pasid)
> +		return -EINVAL;
> +
> +	group = iommu_group_get(dev);
> +	if (!group)
> +		return -ENODEV;
> +
> +	/* Ensure device count and domain don't change while we're binding */
> +	mutex_lock(&group->mutex);
> +	if (iommu_group_device_count(group) != 1)
> +		goto out_unlock;
don't you want to check flags is a subset of
dev->iommu_param->sva_param->features?
> +
> +	ret = __iommu_sva_bind_device(dev, mm, pasid, flags, drvdata);
> +
> +out_unlock:
> +	mutex_unlock(&group->mutex);
> +	iommu_group_put(group);
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(iommu_sva_bind_device);
> +
> +/**
> + * iommu_sva_unbind_device() - Remove a bond created with iommu_sva_bind_device
> + * @dev: the device
> + * @pasid: the pasid returned by bind()
> + *
> + * Remove bond between device and address space identified by @pasid. Users
> + * should not call unbind() if the corresponding mm exited (as the PASID might
> + * have been reallocated for another process).
> + *
> + * The device must not be issuing any more transaction for this PASID. All
> + * outstanding page requests for this PASID must have been flushed to the IOMMU.
> + *
> + * Returns 0 on success, or an error value
> + */
> +int iommu_sva_unbind_device(struct device *dev, int pasid)
returned value needed?
> +{
> +	int ret = -EINVAL;
> +	struct iommu_group *group;
> +
> +	group = iommu_group_get(dev);
> +	if (!group)
> +		return -ENODEV;
> +
> +	mutex_lock(&group->mutex);
> +	ret = __iommu_sva_unbind_device(dev, pasid);
> +	mutex_unlock(&group->mutex);
> +
> +	iommu_group_put(group);
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(iommu_sva_unbind_device);
> diff --git a/include/linux/iommu.h b/include/linux/iommu.h
> index 2efe7738bedb..da59c20c4f12 100644
> --- a/include/linux/iommu.h
> +++ b/include/linux/iommu.h
> @@ -613,6 +613,10 @@ void iommu_fwspec_free(struct device *dev);
>  int iommu_fwspec_add_ids(struct device *dev, u32 *ids, int num_ids);
>  const struct iommu_ops *iommu_ops_from_fwnode(struct fwnode_handle *fwnode);
>  
> +extern int iommu_sva_bind_device(struct device *dev, struct mm_struct *mm,
> +				int *pasid, unsigned long flags, void *drvdata);
> +extern int iommu_sva_unbind_device(struct device *dev, int pasid);
> +
>  #else /* CONFIG_IOMMU_API */
>  
>  struct iommu_ops {};
> @@ -932,12 +936,29 @@ static inline int iommu_sva_invalidate(struct iommu_domain *domain,
>  	return -EINVAL;
>  }
>  
> +static inline int iommu_sva_bind_device(struct device *dev,
> +					struct mm_struct *mm, int *pasid,
> +					unsigned long flags, void *drvdata)
> +{
> +	return -ENODEV;
> +}
> +
> +static inline int iommu_sva_unbind_device(struct device *dev, int pasid)
> +{
> +	return -ENODEV;
> +}
> +
>  #endif /* CONFIG_IOMMU_API */
>  
>  #ifdef CONFIG_IOMMU_SVA
>  extern int iommu_sva_device_init(struct device *dev, unsigned long features,
>  				 unsigned int max_pasid);
>  extern int iommu_sva_device_shutdown(struct device *dev);
> +extern int __iommu_sva_bind_device(struct device *dev, struct mm_struct *mm,
> +				   int *pasid, unsigned long flags,
> +				   void *drvdata);
> +extern int __iommu_sva_unbind_device(struct device *dev, int pasid);
> +extern void __iommu_sva_unbind_dev_all(struct device *dev);
>  #else /* CONFIG_IOMMU_SVA */
>  static inline int iommu_sva_device_init(struct device *dev,
>  					unsigned long features,
> @@ -950,6 +971,22 @@ static inline int iommu_sva_device_shutdown(struct device *dev)
>  {
>  	return -ENODEV;
>  }
> +
> +static inline int __iommu_sva_bind_device(struct device *dev,
> +					  struct mm_struct *mm, int *pasid,
> +					  unsigned long flags, void *drvdata)
> +{
> +	return -ENODEV;
> +}
> +
> +static inline int __iommu_sva_unbind_device(struct device *dev, int pasid)
> +{
> +	return -ENODEV;
> +}
> +
> +static inline void __iommu_sva_unbind_dev_all(struct device *dev)
> +{
> +}
>  #endif /* CONFIG_IOMMU_SVA */
>  
>  #endif /* __LINUX_IOMMU_H */
> 
Thanks

Eric
