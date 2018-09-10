Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8C1BF8E0003
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 11:16:37 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id e14-v6so21426639qtp.17
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 08:16:37 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id o1-v6si1900758qvm.174.2018.09.10.08.16.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 08:16:36 -0700 (PDT)
Subject: Re: [PATCH v2 17/40] iommu/arm-smmu-v3: Link domains and devices
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-18-jean-philippe.brucker@arm.com>
From: Auger Eric <eric.auger@redhat.com>
Message-ID: <b4154adb-313c-133b-6c5d-6e789bd754c7@redhat.com>
Date: Mon, 10 Sep 2018 17:16:25 +0200
MIME-Version: 1.0
In-Reply-To: <20180511190641.23008-18-jean-philippe.brucker@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: xieyisheng1@huawei.com, liubo95@huawei.com, xuzaibo@huawei.com, thunder.leizhen@huawei.com, will.deacon@arm.com, okaya@codeaurora.org, yi.l.liu@intel.com, ashok.raj@intel.com, tn@semihalf.com, joro@8bytes.org, bharatku@xilinx.com, liudongdong3@huawei.com, rfranz@cavium.com, kevin.tian@intel.com, jacob.jun.pan@linux.intel.com, jcrouse@codeaurora.org, rgummal@xilinx.com, jonathan.cameron@huawei.com, shunyong.yang@hxt-semitech.com, robin.murphy@arm.com, ilias.apalodimas@linaro.org, alex.williamson@redhat.com, robdclark@gmail.com, dwmw2@infradead.org, christian.koenig@amd.com, nwatters@codeaurora.org, baolu.lu@linux.intel.com

Hi Jean-Philippe,

On 05/11/2018 09:06 PM, Jean-Philippe Brucker wrote:
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
> +
> +	struct device			*dev;
This field addition and associated assignment in arm_smmu_attach_dev()
is not really documented in the commit message.

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
it is not totally obvious to me why master->domain = smmu_domain isn't
within the lock either for consistency. Same when deleting the node.

Thanks

Eric
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
> 
