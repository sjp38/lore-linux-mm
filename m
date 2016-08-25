Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8468283093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 04:57:42 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o124so79620535pfg.1
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 01:57:42 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id lu15si14520874pab.140.2016.08.25.01.57.40
        for <linux-mm@kvack.org>;
        Thu, 25 Aug 2016 01:57:41 -0700 (PDT)
Subject: Re: [PATCH v12 2/7] x86, acpi, cpu-hotplug: Enable acpi to register
 all possible cpus at boot time.
References: <1472114120-3281-1-git-send-email-douly.fnst@cn.fujitsu.com>
 <1472114120-3281-3-git-send-email-douly.fnst@cn.fujitsu.com>
From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Message-ID: <c716d43a-8b9f-f517-2c84-a3a61ab361b0@cn.fujitsu.com>
Date: Thu, 25 Aug 2016 16:57:37 +0800
MIME-Version: 1.0
In-Reply-To: <1472114120-3281-3-git-send-email-douly.fnst@cn.fujitsu.com>
Content-Type: text/plain; charset="gbk"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de
Cc: tj@kernel.org, rjw@rjwysocki.net, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, rafael@kernel.org, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi tglx,

At 08/25/2016 04:35 PM, Dou Liyang wrote:
>  arch/x86/kernel/apic/apic.c | 18 ++++++++++++++----
>  1 file changed, 14 insertions(+), 4 deletions(-)
>
> diff --git a/arch/x86/kernel/apic/apic.c b/arch/x86/kernel/apic/apic.c
> index cea4fc1..e5612a9 100644
> --- a/arch/x86/kernel/apic/apic.c
> +++ b/arch/x86/kernel/apic/apic.c
> @@ -2024,7 +2024,7 @@ void disconnect_bsp_APIC(int virt_wire_setup)
>  	apic_write(APIC_LVT1, value);
>  }
>
> -int generic_processor_info(int apicid, int version)
> +static int __generic_processor_info(int apicid, int version, bool enabled)
>  {
>  	int cpu, max = nr_cpu_ids;
>  	bool boot_cpu_detected = physid_isset(boot_cpu_physical_apicid,
> @@ -2090,7 +2090,6 @@ int generic_processor_info(int apicid, int version)
>  		return -EINVAL;
>  	}
>
> -	num_processors++;
>  	if (apicid == boot_cpu_physical_apicid) {

I move the "num_processors++" below.
Because I think that if "apicid == boot_cpu_physical_apicid" is true,
The "disabled_cpus" will plus one that may conflict with the
"num_processors++"

Is my thought right?

>  		/*
>  		 * x86_bios_cpu_apicid is required to have processors listed
> @@ -2113,6 +2112,7 @@ int generic_processor_info(int apicid, int version)
>
>  		pr_warning("APIC: Package limit reached. Processor %d/0x%x ignored.\n",
>  			   thiscpu, apicid);
> +
>  		disabled_cpus++;
>  		return -ENOSPC;
>  	}
> @@ -2132,7 +2132,6 @@ int generic_processor_info(int apicid, int version)
>  			apic_version[boot_cpu_physical_apicid], cpu, version);
>  	}
>
> -	physid_set(apicid, phys_cpu_present_map);
>  	if (apicid > max_physical_apicid)
>  		max_physical_apicid = apicid;
>
> @@ -2145,11 +2144,22 @@ int generic_processor_info(int apicid, int version)
>  		apic->x86_32_early_logical_apicid(cpu);
>  #endif
>  	set_cpu_possible(cpu, true);
> -	set_cpu_present(cpu, true);
> +
> +	if (enabled) {
> +		num_processors++;
> +		physid_set(apicid, phys_cpu_present_map);
> +		set_cpu_present(cpu, true);
> +	} else
> +		disabled_cpus++;
>

I remove all the "if (enabled)" code and do the unified
judgment here.

Thanks,
Dou


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
