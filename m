Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2F1456B0253
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 09:49:09 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w95so4023052wrc.20
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 06:49:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b13si4037800edk.466.2017.11.30.06.49.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Nov 2017 06:49:07 -0800 (PST)
Date: Thu, 30 Nov 2017 15:49:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 4/5] mm: memory_hotplug: Add memory hotremove probe
 device
Message-ID: <20171130144905.ntpovhy66gekj6e6@dhcp22.suse.cz>
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
 <22d34fe30df0fbacbfceeb47e20cb1184af73585.1511433386.git.ar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <22d34fe30df0fbacbfceeb47e20cb1184af73585.1511433386.git.ar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Reale <ar@linux.vnet.ibm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, mark.rutland@arm.com, scott.branden@broadcom.com, will.deacon@arm.com, qiuxishi@huawei.com, catalin.marinas@arm.com, realean2@ie.ibm.com

On Thu 23-11-17 11:14:52, Andrea Reale wrote:
> Adding a "remove" sysfs handle that can be used to trigger
> memory hotremove manually, exactly simmetrically with
> what happens with the "probe" device for hot-add.
> 
> This is usueful for architecture that do not rely on
> ACPI for memory hot-remove.

As already said elsewhere, this really has to check the online status of
the range and fail some is still online.

> Signed-off-by: Andrea Reale <ar@linux.vnet.ibm.com>
> Signed-off-by: Maciej Bielski <m.bielski@virtualopensystems.com>
> ---
>  drivers/base/memory.c | 34 +++++++++++++++++++++++++++++++++-
>  1 file changed, 33 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 1d60b58..8ccb67c 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -530,7 +530,36 @@ memory_probe_store(struct device *dev, struct device_attribute *attr,
>  }
>  
>  static DEVICE_ATTR(probe, S_IWUSR, NULL, memory_probe_store);
> -#endif
> +
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +static ssize_t
> +memory_remove_store(struct device *dev,
> +		struct device_attribute *attr, const char *buf, size_t count)
> +{
> +	u64 phys_addr;
> +	int nid, ret;
> +	unsigned long pages_per_block = PAGES_PER_SECTION * sections_per_block;
> +
> +	ret = kstrtoull(buf, 0, &phys_addr);
> +	if (ret)
> +		return ret;
> +
> +	if (phys_addr & ((pages_per_block << PAGE_SHIFT) - 1))
> +		return -EINVAL;
> +
> +	nid = memory_add_physaddr_to_nid(phys_addr);
> +	ret = lock_device_hotplug_sysfs();
> +	if (ret)
> +		return ret;
> +
> +	remove_memory(nid, phys_addr,
> +			 MIN_MEMORY_BLOCK_SIZE * sections_per_block);
> +	unlock_device_hotplug();
> +	return count;
> +}
> +static DEVICE_ATTR(remove, S_IWUSR, NULL, memory_remove_store);
> +#endif /* CONFIG_MEMORY_HOTREMOVE */
> +#endif /* CONFIG_ARCH_MEMORY_PROBE */
>  
>  #ifdef CONFIG_MEMORY_FAILURE
>  /*
> @@ -790,6 +819,9 @@ bool is_memblock_offlined(struct memory_block *mem)
>  static struct attribute *memory_root_attrs[] = {
>  #ifdef CONFIG_ARCH_MEMORY_PROBE
>  	&dev_attr_probe.attr,
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +	&dev_attr_remove.attr,
> +#endif
>  #endif
>  
>  #ifdef CONFIG_MEMORY_FAILURE
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
