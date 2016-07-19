Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC2A6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 16:01:46 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r190so19888718wmr.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 13:01:46 -0700 (PDT)
Received: from cloudserver094114.home.net.pl (cloudserver094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id 4si18492569lfi.385.2016.07.19.13.01.44
        for <linux-mm@kvack.org>;
        Tue, 19 Jul 2016 13:01:44 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH v8 5/7] x86, acpi, cpu-hotplug: Set persistent cpuid <-> nodeid mapping when booting.
Date: Tue, 19 Jul 2016 22:06:38 +0200
Message-ID: <1699870.UOpnC170VZ@vostro.rjw.lan>
In-Reply-To: <1468913288-16605-6-git-send-email-douly.fnst@cn.fujitsu.com>
References: <1468913288-16605-1-git-send-email-douly.fnst@cn.fujitsu.com> <1468913288-16605-6-git-send-email-douly.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dou Liyang <douly.fnst@cn.fujitsu.com>
Cc: cl@linux.com, tj@kernel.org, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn, rafael@kernel.org, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Zhu Guihua <zhugh.fnst@cn.fujitsu.com>

On Tuesday, July 19, 2016 03:28:06 PM Dou Liyang wrote:
> From: Gu Zheng <guz.fnst@cn.fujitsu.com>
> 
> The whole patch-set aims at making cpuid <-> nodeid mapping persistent. So that,
> when node online/offline happens, cache based on cpuid <-> nodeid mapping such as
> wq_numa_possible_cpumask will not cause any problem.
> It contains 4 steps:
> 1. Enable apic registeration flow to handle both enabled and disabled cpus.
> 2. Introduce a new array storing all possible cpuid <-> apicid mapping.
> 3. Enable _MAT and MADT relative apis to return non-presnet or disabled cpus' apicid.
> 4. Establish all possible cpuid <-> nodeid mapping.
> 
> This patch finishes step 4.
> 
> This patch set the persistent cpuid <-> nodeid mapping for all enabled/disabled
> processors at boot time via an additional acpi namespace walk for processors.
> 
> Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Signed-off-by: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
> Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>
> ---
>  arch/ia64/kernel/acpi.c       |  3 +-
>  arch/x86/kernel/acpi/boot.c   |  4 ++-
>  drivers/acpi/acpi_processor.c |  5 ++++
>  drivers/acpi/bus.c            |  3 ++
>  drivers/acpi/processor_core.c | 65 +++++++++++++++++++++++++++++++++++++++++++
>  include/linux/acpi.h          |  2 ++
>  6 files changed, 80 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
> index b1698bc..bb36515 100644
> --- a/arch/ia64/kernel/acpi.c
> +++ b/arch/ia64/kernel/acpi.c
> @@ -796,7 +796,7 @@ int acpi_isa_irq_to_gsi(unsigned isa_irq, u32 *gsi)
>   *  ACPI based hotplug CPU support
>   */
>  #ifdef CONFIG_ACPI_HOTPLUG_CPU
> -static int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
> +int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
>  {
>  #ifdef CONFIG_ACPI_NUMA
>  	/*
> @@ -811,6 +811,7 @@ static int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
>  #endif
>  	return 0;
>  }
> +EXPORT_SYMBOL(acpi_map_cpu2node);
>  
>  int additional_cpus __initdata = -1;
>  
> diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
> index 37248c3..0900264f 100644
> --- a/arch/x86/kernel/acpi/boot.c
> +++ b/arch/x86/kernel/acpi/boot.c
> @@ -695,7 +695,7 @@ static void __init acpi_set_irq_model_ioapic(void)
>  #ifdef CONFIG_ACPI_HOTPLUG_CPU
>  #include <acpi/processor.h>
>  
> -static void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
> +int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
>  {
>  #ifdef CONFIG_ACPI_NUMA
>  	int nid;
> @@ -706,7 +706,9 @@ static void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
>  		numa_set_node(cpu, nid);
>  	}
>  #endif
> +	return 0;
>  }
> +EXPORT_SYMBOL(acpi_map_cpu2node);
>  
>  int acpi_map_cpu(acpi_handle handle, phys_cpuid_t physid, int *pcpu)
>  {
> diff --git a/drivers/acpi/acpi_processor.c b/drivers/acpi/acpi_processor.c
> index e85b19a..0c15828 100644
> --- a/drivers/acpi/acpi_processor.c
> +++ b/drivers/acpi/acpi_processor.c
> @@ -182,6 +182,11 @@ int __weak arch_register_cpu(int cpu)
>  
>  void __weak arch_unregister_cpu(int cpu) {}
>  
> +int __weak acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
> +{
> +	return -ENODEV;
> +}
> +
>  static int acpi_processor_hotadd_init(struct acpi_processor *pr)
>  {
>  	unsigned long long sta;
> diff --git a/drivers/acpi/bus.c b/drivers/acpi/bus.c
> index 262ca31..d8b7272 100644
> --- a/drivers/acpi/bus.c
> +++ b/drivers/acpi/bus.c
> @@ -1124,6 +1124,9 @@ static int __init acpi_init(void)
>  	acpi_sleep_proc_init();
>  	acpi_wakeup_device_init();
>  	acpi_debugger_init();
> +#ifdef CONFIG_ACPI_HOTPLUG_CPU
> +	acpi_set_processor_mapping();
> +#endif

This doesn't look nice.

What about providing an empty definition of acpi_set_processor_mapping()
for CONFIG_ACPI_HOTPLUG_CPU unset?

>  	return 0;
>  }

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
