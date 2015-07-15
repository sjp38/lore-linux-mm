Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1318C28027E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 18:02:45 -0400 (EDT)
Received: by ykay190 with SMTP id y190so48895015yka.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 15:02:44 -0700 (PDT)
Received: from mail-yk0-x22c.google.com (mail-yk0-x22c.google.com. [2607:f8b0:4002:c07::22c])
        by mx.google.com with ESMTPS id t3si4068140ywt.92.2015.07.15.15.02.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 15:02:44 -0700 (PDT)
Received: by ykdu72 with SMTP id u72so48899883ykd.2
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 15:02:43 -0700 (PDT)
Date: Wed, 15 Jul 2015 18:02:40 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/5] x86, acpi, cpu-hotplug: Introduce apicid_to_cpuid[]
 array to store persistent cpuid <-> apicid mapping.
Message-ID: <20150715220240.GM15934@mtj.duckdns.org>
References: <1436261425-29881-1-git-send-email-tangchen@cn.fujitsu.com>
 <1436261425-29881-4-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436261425-29881-4-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, laijs@cn.fujitsu.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, qiaonuohan@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>

Hello,

On Tue, Jul 07, 2015 at 05:30:23PM +0800, Tang Chen wrote:
> From: Gu Zheng <guz.fnst@cn.fujitsu.com>

It would be a good idea to briefly describe what the overall goal is
and why we want that.

> In this patch, we introduce a new static array named apicid_to_cpuid[],
> which is large enough to store info for all possible cpus.
> 
> And then, we modify the cpuid calculation. In generic_processor_info(),
> it simply finds the next unused cpuid. And it is also why the cpuid <-> nodeid
> mapping changes with node hotplug.
> 
> After this patch, we find the next unused cpuid, map it to an apicid,
> and store the mapping in apicid_to_cpuid[], so that cpuid <-> apicid
> mapping will be persistent.
> 
> And finally we will use this array to make cpuid <-> nodeid persistent.
> 
> cpuid <-> apicid mapping is established at local apic registeration time.
> But non-present or disabled cpus are ignored.
> 
> In this patch, we establish all possible cpuid <-> apicid mapping when
> registering local apic.
> 
> 
> Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> ---
...
> diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
> index e49ee24..bcc85b2 100644
> --- a/arch/x86/kernel/acpi/boot.c
> +++ b/arch/x86/kernel/acpi/boot.c
> @@ -174,15 +174,13 @@ static int acpi_register_lapic(int id, u8 enabled)
>  		return -EINVAL;
>  	}
>  
> -	if (!enabled) {
> +	if (!enabled)
>  		++disabled_cpus;
> -		return -EINVAL;
> -	}
>  
>  	if (boot_cpu_physical_apicid != -1U)
>  		ver = apic_version[boot_cpu_physical_apicid];
>  
> -	return generic_processor_info(id, ver);
> +	return __generic_processor_info(id, ver, enabled);
>  }
>  
>  static int __init
> diff --git a/arch/x86/kernel/apic/apic.c b/arch/x86/kernel/apic/apic.c
> index a9c9830..c744ffb 100644
> --- a/arch/x86/kernel/apic/apic.c
> +++ b/arch/x86/kernel/apic/apic.c
> @@ -1977,7 +1977,38 @@ void disconnect_bsp_APIC(int virt_wire_setup)
>  	apic_write(APIC_LVT1, value);
>  }
>  
> -static int __generic_processor_info(int apicid, int version, bool enabled)
> +/*
> + * Logic cpu number(cpuid) to local APIC id persistent mappings.

      Logical

Also, isn't it the other way around?

> + * Do not clear the mapping even if cpu is hot-removed.
> + */
> +static int apicid_to_cpuid[] = {
> +	[0 ... NR_CPUS - 1] = -1,
> +};
> +
> +/*
> + * Internal cpu id bits, set the bit once cpu present, and never clear it.
> + */
> +static cpumask_t cpuid_mask = CPU_MASK_NONE;
> +
> +static int get_cpuid(int apicid)
> +{
> +	int free_id, i;
> +
> +	free_id = cpumask_next_zero(-1, &cpuid_mask);
> +	if (free_id >= nr_cpu_ids)
> +		return -1;
> +
> +	for (i = 0; i < free_id; i++)
> +		if (apicid_to_cpuid[i] == apicid)
> +			return i;
> +
> +	apicid_to_cpuid[free_id] = apicid;
> +	cpumask_set_cpu(free_id, &cpuid_mask);
> +
> +	return free_id;

Why can't this function simply test whether apicid_to_cpuid[] is -1 or
not?  Also, why does it need cpuid_mask?  Isn't it just giving out cpu
id numbers sequentially?

> +}
> +
> +int __generic_processor_info(int apicid, int version, bool enabled)
>  {
>  	int cpu, max = nr_cpu_ids;
>  	bool boot_cpu_detected = physid_isset(boot_cpu_physical_apicid,
> @@ -2058,8 +2089,18 @@ static int __generic_processor_info(int apicid, int version, bool enabled)
>  		 * for BSP.
>  		 */
>  		cpu = 0;
> -	} else
> -		cpu = cpumask_next_zero(-1, cpu_present_mask);
> +	} else {
> +		cpu = get_cpuid(apicid);
> +		if (cpu < 0) {
> +			int thiscpu = max + disabled_cpus;
> +
> +			pr_warning("  Processor %d/0x%x ignored.\n",
> +				   thiscpu, apicid);

Given that the only failing condition is there are more possible cpus
than nr_cpu_ids, it might make more sense to warn this once in
get_cpuid().

Also, wouldn't it make more sense / safer to allocate all online cpus
first and then go through possible cpus?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
