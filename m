Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4FE4A6B0069
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 07:19:12 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id r2so8912695wra.4
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 04:19:12 -0800 (PST)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id w47si17414406wrc.191.2017.11.24.04.19.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 04:19:10 -0800 (PST)
Message-ID: <5A180DF1.8060009@huawei.com>
Date: Fri, 24 Nov 2017 20:17:53 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/5] mm: memory_hotplug: Add memory hotremove probe
 device
References: <cover.1511433386.git.ar@linux.vnet.ibm.com> <22d34fe30df0fbacbfceeb47e20cb1184af73585.1511433386.git.ar@linux.vnet.ibm.com> <5A17F5DF.2040108@huawei.com> <20171124104401.GD18120@samekh>
In-Reply-To: <20171124104401.GD18120@samekh>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Reale <ar@linux.vnet.ibm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, mark.rutland@arm.com, scott.branden@broadcom.com, will.deacon@arm.com, qiuxishi@huawei.com, catalin.marinas@arm.com, mhocko@suse.com, realean2@ie.ibm.com

Hi, Andrea

most of server will benefit from NUMA ,it is best to sovle the issue without
spcial restrictions.

At least we can obtain the numa information from dtb. therefore, The memory can
online correctly.

Thanks
zhongjiang

On 2017/11/24 18:44, Andrea Reale wrote:
> Hi zhongjiang,
>
> On Fri 24 Nov 2017, 18:35, zhong jiang wrote:
>> HI, Andrea
>>
>> I don't see "memory_add_physaddr_to_nid" in arch/arm64.
>> Am I miss something?
> When !CONFIG_NUMA it is defined in include/linux/memory_hotplug.h as 0.
> In patch 1/5 of this series we require !NUMA to enable
> ARCH_ENABLE_MEMORY_HOTPLUG.
>
> The reason for this simplification is simply that we would not know how
> to decide the correct node to which to add memory when NUMA is on.
> Any suggestion on that matter is welcome. 
>
> Thanks,
> Andrea
>
>> Thnaks
>> zhongjiang
>>
>> On 2017/11/23 19:14, Andrea Reale wrote:
>>> Adding a "remove" sysfs handle that can be used to trigger
>>> memory hotremove manually, exactly simmetrically with
>>> what happens with the "probe" device for hot-add.
>>>
>>> This is usueful for architecture that do not rely on
>>> ACPI for memory hot-remove.
>>>
>>> Signed-off-by: Andrea Reale <ar@linux.vnet.ibm.com>
>>> Signed-off-by: Maciej Bielski <m.bielski@virtualopensystems.com>
>>> ---
>>>  drivers/base/memory.c | 34 +++++++++++++++++++++++++++++++++-
>>>  1 file changed, 33 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>>> index 1d60b58..8ccb67c 100644
>>> --- a/drivers/base/memory.c
>>> +++ b/drivers/base/memory.c
>>> @@ -530,7 +530,36 @@ memory_probe_store(struct device *dev, struct device_attribute *attr,
>>>  }
>>>  
>>>  static DEVICE_ATTR(probe, S_IWUSR, NULL, memory_probe_store);
>>> -#endif
>>> +
>>> +#ifdef CONFIG_MEMORY_HOTREMOVE
>>> +static ssize_t
>>> +memory_remove_store(struct device *dev,
>>> +		struct device_attribute *attr, const char *buf, size_t count)
>>> +{
>>> +	u64 phys_addr;
>>> +	int nid, ret;
>>> +	unsigned long pages_per_block = PAGES_PER_SECTION * sections_per_block;
>>> +
>>> +	ret = kstrtoull(buf, 0, &phys_addr);
>>> +	if (ret)
>>> +		return ret;
>>> +
>>> +	if (phys_addr & ((pages_per_block << PAGE_SHIFT) - 1))
>>> +		return -EINVAL;
>>> +
>>> +	nid = memory_add_physaddr_to_nid(phys_addr);
>>> +	ret = lock_device_hotplug_sysfs();
>>> +	if (ret)
>>> +		return ret;
>>> +
>>> +	remove_memory(nid, phys_addr,
>>> +			 MIN_MEMORY_BLOCK_SIZE * sections_per_block);
>>> +	unlock_device_hotplug();
>>> +	return count;
>>> +}
>>> +static DEVICE_ATTR(remove, S_IWUSR, NULL, memory_remove_store);
>>> +#endif /* CONFIG_MEMORY_HOTREMOVE */
>>> +#endif /* CONFIG_ARCH_MEMORY_PROBE */
>>>  
>>>  #ifdef CONFIG_MEMORY_FAILURE
>>>  /*
>>> @@ -790,6 +819,9 @@ bool is_memblock_offlined(struct memory_block *mem)
>>>  static struct attribute *memory_root_attrs[] = {
>>>  #ifdef CONFIG_ARCH_MEMORY_PROBE
>>>  	&dev_attr_probe.attr,
>>> +#ifdef CONFIG_MEMORY_HOTREMOVE
>>> +	&dev_attr_remove.attr,
>>> +#endif
>>>  #endif
>>>  
>>>  #ifdef CONFIG_MEMORY_FAILURE
>>
>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
