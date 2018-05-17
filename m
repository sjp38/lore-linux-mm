Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id DBE896B0508
	for <linux-mm@kvack.org>; Thu, 17 May 2018 12:43:19 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id r23-v6so3451018wrc.2
        for <linux-mm@kvack.org>; Thu, 17 May 2018 09:43:19 -0700 (PDT)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id y34-v6si4717621wry.85.2018.05.17.09.43.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 09:43:18 -0700 (PDT)
Date: Thu, 17 May 2018 17:07:48 +0100
From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: Re: [PATCH v2 17/40] iommu/arm-smmu-v3: Link domains and devices
Message-ID: <20180517170748.00004927@huawei.com>
In-Reply-To: <20180511190641.23008-18-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
	<20180511190641.23008-18-jean-philippe.brucker@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

On Fri, 11 May 2018 20:06:18 +0100
Jean-Philippe Brucker <jean-philippe.brucker@arm.com> wrote:

> When removing a mapping from a domain, we need to send an invalidation to
> all devices that might have stored it in their Address Translation Cache
> (ATC). In addition when updating the context descriptor of a live domain,
> we'll need to send invalidations for all devices attached to it.
> 
> Maintain a list of devices in each domain, protected by a spinlock. It is
> updated every time we attach or detach devices to and from domains.
> 
> It needs to be a spinlock because we'll invalidate ATC entries from
> within hardirq-safe contexts, but it may be possible to relax the read
> side with RCU later.
> 
> Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>

Trivial naming suggestion...

> ---
>  drivers/iommu/arm-smmu-v3.c | 28 ++++++++++++++++++++++++++++
>  1 file changed, 28 insertions(+)
> 
> diff --git a/drivers/iommu/arm-smmu-v3.c b/drivers/iommu/arm-smmu-v3.c
> index 1d647104bccc..c892f012fb43 100644
> --- a/drivers/iommu/arm-smmu-v3.c
> +++ b/drivers/iommu/arm-smmu-v3.c
> @@ -595,6 +595,11 @@ struct arm_smmu_device {
>  struct arm_smmu_master_data {
>  	struct arm_smmu_device		*smmu;
>  	struct arm_smmu_strtab_ent	ste;
> +
> +	struct arm_smmu_domain		*domain;
> +	struct list_head		list; /* domain->devices */

More meaningful name perhaps to avoid the need for the comment?

> +
> +	struct device			*dev;
>  };
>  
>  /* SMMU private data for an IOMMU domain */
> @@ -618,6 +623,9 @@ struct arm_smmu_domain {
>  	};
>  
>  	struct iommu_domain		domain;
> +
> +	struct list_head		devices;
> +	spinlock_t			devices_lock;
>  };
>  
>  struct arm_smmu_option_prop {
> @@ -1470,6 +1478,9 @@ static struct iommu_domain *arm_smmu_domain_alloc(unsigned type)
>  	}
>  
>  	mutex_init(&smmu_domain->init_mutex);
> +	INIT_LIST_HEAD(&smmu_domain->devices);
> +	spin_lock_init(&smmu_domain->devices_lock);
> +
>  	return &smmu_domain->domain;
>  }
>  
> @@ -1685,7 +1696,17 @@ static void arm_smmu_install_ste_for_dev(struct iommu_fwspec *fwspec)
>  
>  static void arm_smmu_detach_dev(struct device *dev)
>  {
> +	unsigned long flags;
>  	struct arm_smmu_master_data *master = dev->iommu_fwspec->iommu_priv;
> +	struct arm_smmu_domain *smmu_domain = master->domain;
> +
> +	if (smmu_domain) {
> +		spin_lock_irqsave(&smmu_domain->devices_lock, flags);
> +		list_del(&master->list);
> +		spin_unlock_irqrestore(&smmu_domain->devices_lock, flags);
> +
> +		master->domain = NULL;
> +	}
>  
>  	master->ste.assigned = false;
>  	arm_smmu_install_ste_for_dev(dev->iommu_fwspec);
> @@ -1694,6 +1715,7 @@ static void arm_smmu_detach_dev(struct device *dev)
>  static int arm_smmu_attach_dev(struct iommu_domain *domain, struct device *dev)
>  {
>  	int ret = 0;
> +	unsigned long flags;
>  	struct arm_smmu_device *smmu;
>  	struct arm_smmu_domain *smmu_domain = to_smmu_domain(domain);
>  	struct arm_smmu_master_data *master;
> @@ -1729,6 +1751,11 @@ static int arm_smmu_attach_dev(struct iommu_domain *domain, struct device *dev)
>  	}
>  
>  	ste->assigned = true;
> +	master->domain = smmu_domain;
> +
> +	spin_lock_irqsave(&smmu_domain->devices_lock, flags);
> +	list_add(&master->list, &smmu_domain->devices);
> +	spin_unlock_irqrestore(&smmu_domain->devices_lock, flags);
>  
>  	if (smmu_domain->stage == ARM_SMMU_DOMAIN_BYPASS) {
>  		ste->s1_cfg = NULL;
> @@ -1847,6 +1874,7 @@ static int arm_smmu_add_device(struct device *dev)
>  			return -ENOMEM;
>  
>  		master->smmu = smmu;
> +		master->dev = dev;
>  		fwspec->iommu_priv = master;
>  	}
>  
