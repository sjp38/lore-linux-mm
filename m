Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A53506B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 05:36:48 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id k84so11627277pfj.18
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 02:36:48 -0800 (PST)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id w24si17767311plq.427.2017.11.24.02.36.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 02:36:47 -0800 (PST)
Message-ID: <5A17F5DF.2040108@huawei.com>
Date: Fri, 24 Nov 2017 18:35:11 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/5] mm: memory_hotplug: Add memory hotremove probe
 device
References: <cover.1511433386.git.ar@linux.vnet.ibm.com> <22d34fe30df0fbacbfceeb47e20cb1184af73585.1511433386.git.ar@linux.vnet.ibm.com>
In-Reply-To: <22d34fe30df0fbacbfceeb47e20cb1184af73585.1511433386.git.ar@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Reale <ar@linux.vnet.ibm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, mark.rutland@arm.com, scott.branden@broadcom.com, will.deacon@arm.com, qiuxishi@huawei.com, catalin.marinas@arm.com, mhocko@suse.com, realean2@ie.ibm.com

HI, Andrea

I don't see "memory_add_physaddr_to_nid" in arch/arm64.
Am I miss something?

Thnaks
zhongjiang

On 2017/11/23 19:14, Andrea Reale wrote:
> Adding a "remove" sysfs handle that can be used to trigger
> memory hotremove manually, exactly simmetrically with
> what happens with the "probe" device for hot-add.
>
> This is usueful for architecture that do not rely on
> ACPI for memory hot-remove.
>
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


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
