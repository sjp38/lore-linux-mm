Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id AB04C6B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 02:54:52 -0400 (EDT)
Message-ID: <51EF7ADD.6050500@cn.fujitsu.com>
Date: Wed, 24 Jul 2013 14:57:33 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 12/21] x86, acpi: Try to find if SRAT is overrided earlier.
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com> <1374220774-29974-13-git-send-email-tangchen@cn.fujitsu.com> <20130723202746.GQ21100@mtj.dyndns.org>
In-Reply-To: <20130723202746.GQ21100@mtj.dyndns.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On 07/24/2013 04:27 AM, Tejun Heo wrote:
> On Fri, Jul 19, 2013 at 03:59:25PM +0800, Tang Chen wrote:
>> As we mentioned in previous patches, to prevent the kernel
>
> Prolly best to briefly describe what the overall goal is about.

Sure. Here is the overall picture, and will add it to log.

Linux cannot migrate pages used by the kernel due to the direct mapping
(va = pa + PAGE_OFFSET), any memory used by the kernel cannot be 
hot-removed.
So in memory hotplug platform, we have to prevent the kernel from using
hotpluggable memory.

The ACPI table SRAT (System Resource Affinity Table) contains info to 
specify
which memory is hotpluggble. After SRAT is parsed, we are aware of which
memory is hotpluggable.

At the early time when system is booting, SRAT has not been parsed. The boot
memory allocator memblock will allocate any memory to the kernel. So we need
SRAT parsed before memblock starts to work.

In this patch, we are going to parse SRAT earlier, right after memblock 
is ready.

Generally speaking, SRAT is provided by firmware. But 
ACPI_INITRD_TABLE_OVERRIDE
functionality allows users to customize their own SRAT in initrd, and 
override
the one from firmware. So if we want to parse SRAT earlier, we also need 
to do
SRAT override earlier.

First, we introduce early_acpi_override_srat() to check if SRAT will be 
overridden
from initrd.

Second, we introduce reserve_hotpluggable_memory() to reserve 
hotpluggable memory,
which will firstly call early_acpi_override_srat() to find out which 
memory is
hotpluggable in the override SRAT.

>
>> diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
>> index 28d2e60..9717760 100644
>> --- a/arch/x86/kernel/setup.c
>> +++ b/arch/x86/kernel/setup.c
>> @@ -1078,6 +1078,15 @@ void __init setup_arch(char **cmdline_p)
>>   	/* Initialize ACPI root table */
>>   	acpi_root_table_init();
>>
>> +#ifdef CONFIG_ACPI_NUMA
>> +	/*
>> +	 * Linux kernel cannot migrate kernel pages, as a result, memory used
>> +	 * by the kernel cannot be hot-removed. Reserve hotpluggable memory to
>> +	 * prevent memblock from allocating hotpluggable memory for the kernel.
>> +	 */
>> +	reserve_hotpluggable_memory();
>> +#endif
>
> Hmmm, so you're gonna reserve all hotpluggable memory areas until
> everything is up and running, which probably is why allocating
> node_data on hotpluggable node doesn't work, right?

Yes, that's right. The node_data of hotpluggable node is now put on another
unhotpluggable node.

>
......
>> +phys_addr_t __init early_acpi_override_srat(void)
>> +{
>> +	int i;
>> +	u32 length;
>> +	long offset;
>> +	void *ramdisk_vaddr;
>> +	struct acpi_table_header *table;
>> +	unsigned long map_step = NR_FIX_BTMAPS<<  PAGE_SHIFT;
>> +	phys_addr_t ramdisk_image = get_ramdisk_image();
>> +	char cpio_path[32] = "kernel/firmware/acpi/";
>> +	struct cpio_data file;
>
> Don't we usually put variable declarations with initializers before
> others?  For some reason, the above block is painful to look at.

OK, followed.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
