Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 490316B0253
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 10:33:06 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id l138so12792289oib.0
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 07:33:06 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q32si12089157ota.214.2017.11.27.07.33.04
        for <linux-mm@kvack.org>;
        Mon, 27 Nov 2017 07:33:05 -0800 (PST)
Subject: Re: [PATCH v2 4/5] mm: memory_hotplug: Add memory hotremove probe
 device
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
 <22d34fe30df0fbacbfceeb47e20cb1184af73585.1511433386.git.ar@linux.vnet.ibm.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <198063b0-fcc9-7beb-7476-86ed5f04734c@arm.com>
Date: Mon, 27 Nov 2017 15:33:01 +0000
MIME-Version: 1.0
In-Reply-To: <22d34fe30df0fbacbfceeb47e20cb1184af73585.1511433386.git.ar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Reale <ar@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org
Cc: mark.rutland@arm.com, realean2@ie.ibm.com, mhocko@suse.com, m.bielski@virtualopensystems.com, scott.branden@broadcom.com, catalin.marinas@arm.com, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arunks@qti.qualcomm.com, qiuxishi@huawei.com

On 23/11/17 11:14, Andrea Reale wrote:
> Adding a "remove" sysfs handle that can be used to trigger
> memory hotremove manually, exactly simmetrically with
> what happens with the "probe" device for hot-add.
> 
> This is usueful for architecture that do not rely on
> ACPI for memory hot-remove.

Is there a real-world use-case for this, or is it mostly just a handy 
development feature?

> Signed-off-by: Andrea Reale <ar@linux.vnet.ibm.com>
> Signed-off-by: Maciej Bielski <m.bielski@virtualopensystems.com>
> ---
>   drivers/base/memory.c | 34 +++++++++++++++++++++++++++++++++-
>   1 file changed, 33 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 1d60b58..8ccb67c 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -530,7 +530,36 @@ memory_probe_store(struct device *dev, struct device_attribute *attr,
>   }
>   
>   static DEVICE_ATTR(probe, S_IWUSR, NULL, memory_probe_store);
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

This call looks a bit odd, since you're not doing a memory add. In fact, 
any memory being removed should already be fully known-about, so AFAICS 
it should be simple to get everything you need to know (including 
potentially the online status as mentioned earlier), through 'normal' 
methods, e.g. page_to_nid() or similar.

Robin.

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
>   #ifdef CONFIG_MEMORY_FAILURE
>   /*
> @@ -790,6 +819,9 @@ bool is_memblock_offlined(struct memory_block *mem)
>   static struct attribute *memory_root_attrs[] = {
>   #ifdef CONFIG_ARCH_MEMORY_PROBE
>   	&dev_attr_probe.attr,
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +	&dev_attr_remove.attr,
> +#endif
>   #endif
>   
>   #ifdef CONFIG_MEMORY_FAILURE
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
