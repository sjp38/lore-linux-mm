Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 115BD6B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 07:14:13 -0400 (EDT)
Received: by qgef3 with SMTP id f3so32250119qge.0
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 04:14:12 -0700 (PDT)
Received: from mail-qk0-x22b.google.com (mail-qk0-x22b.google.com. [2607:f8b0:400d:c09::22b])
        by mx.google.com with ESMTPS id 123si24456404qhv.14.2015.07.07.04.14.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 04:14:12 -0700 (PDT)
Received: by qkhu186 with SMTP id u186so136930848qkh.0
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 04:14:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1436261425-29881-4-git-send-email-tangchen@cn.fujitsu.com>
References: <1436261425-29881-1-git-send-email-tangchen@cn.fujitsu.com>
	<1436261425-29881-4-git-send-email-tangchen@cn.fujitsu.com>
Date: Tue, 7 Jul 2015 14:14:12 +0300
Message-ID: <CAChTCPw6ZLs7XgApfN1exeB6TVcQji6ryq+HrK-admp=FGfiTA@mail.gmail.com>
Subject: Re: [PATCH 3/5] x86, acpi, cpu-hotplug: Introduce apicid_to_cpuid[]
 array to store persistent cpuid <-> apicid mapping.
From: =?UTF-8?Q?Mika_Penttil=C3=A4?= <mika.j.penttila@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rjw@rjwysocki.net, gongzhaogang@inspur.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

I think you forgot to reserve CPU 0 for BSP in cpuid mask.

--Mika

On Tue, Jul 7, 2015 at 12:30 PM, Tang Chen <tangchen@cn.fujitsu.com> wrote:
> From: Gu Zheng <guz.fnst@cn.fujitsu.com>
>
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
>  arch/x86/include/asm/mpspec.h |  1 +
>  arch/x86/kernel/acpi/boot.c   |  6 ++----
>  arch/x86/kernel/apic/apic.c   | 47 ++++++++++++++++++++++++++++++++++++++++---
>  3 files changed, 47 insertions(+), 7 deletions(-)
>
> diff --git a/arch/x86/include/asm/mpspec.h b/arch/x86/include/asm/mpspec.h
> index b07233b..db902d8 100644
> --- a/arch/x86/include/asm/mpspec.h
> +++ b/arch/x86/include/asm/mpspec.h
> @@ -86,6 +86,7 @@ static inline void early_reserve_e820_mpc_new(void) { }
>  #endif
>
>  int generic_processor_info(int apicid, int version);
> +int __generic_processor_info(int apicid, int version, bool enabled);
>
>  #define PHYSID_ARRAY_SIZE      BITS_TO_LONGS(MAX_LOCAL_APIC)
>
> diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
> index e49ee24..bcc85b2 100644
> --- a/arch/x86/kernel/acpi/boot.c
> +++ b/arch/x86/kernel/acpi/boot.c
> @@ -174,15 +174,13 @@ static int acpi_register_lapic(int id, u8 enabled)
>                 return -EINVAL;
>         }
>
> -       if (!enabled) {
> +       if (!enabled)
>                 ++disabled_cpus;
> -               return -EINVAL;
> -       }
>
>         if (boot_cpu_physical_apicid != -1U)
>                 ver = apic_version[boot_cpu_physical_apicid];
>
> -       return generic_processor_info(id, ver);
> +       return __generic_processor_info(id, ver, enabled);
>  }
>
>  static int __init
> diff --git a/arch/x86/kernel/apic/apic.c b/arch/x86/kernel/apic/apic.c
> index a9c9830..c744ffb 100644
> --- a/arch/x86/kernel/apic/apic.c
> +++ b/arch/x86/kernel/apic/apic.c
> @@ -1977,7 +1977,38 @@ void disconnect_bsp_APIC(int virt_wire_setup)
>         apic_write(APIC_LVT1, value);
>  }
>
> -static int __generic_processor_info(int apicid, int version, bool enabled)
> +/*
> + * Logic cpu number(cpuid) to local APIC id persistent mappings.
> + * Do not clear the mapping even if cpu is hot-removed.
> + */
> +static int apicid_to_cpuid[] = {
> +       [0 ... NR_CPUS - 1] = -1,
> +};
> +
> +/*
> + * Internal cpu id bits, set the bit once cpu present, and never clear it.
> + */
> +static cpumask_t cpuid_mask = CPU_MASK_NONE;
> +
> +static int get_cpuid(int apicid)
> +{
> +       int free_id, i;
> +
> +       free_id = cpumask_next_zero(-1, &cpuid_mask);
> +       if (free_id >= nr_cpu_ids)
> +               return -1;
> +
> +       for (i = 0; i < free_id; i++)
> +               if (apicid_to_cpuid[i] == apicid)
> +                       return i;
> +
> +       apicid_to_cpuid[free_id] = apicid;
> +       cpumask_set_cpu(free_id, &cpuid_mask);
> +
> +       return free_id;
> +}
> +
> +int __generic_processor_info(int apicid, int version, bool enabled)
>  {
>         int cpu, max = nr_cpu_ids;
>         bool boot_cpu_detected = physid_isset(boot_cpu_physical_apicid,
> @@ -2058,8 +2089,18 @@ static int __generic_processor_info(int apicid, int version, bool enabled)
>                  * for BSP.
>                  */
>                 cpu = 0;
> -       } else
> -               cpu = cpumask_next_zero(-1, cpu_present_mask);
> +       } else {
> +               cpu = get_cpuid(apicid);
> +               if (cpu < 0) {
> +                       int thiscpu = max + disabled_cpus;
> +
> +                       pr_warning("  Processor %d/0x%x ignored.\n",
> +                                  thiscpu, apicid);
> +                       if (enabled)
> +                               disabled_cpus++;
> +                       return -EINVAL;
> +               }
> +       }
>
>         /*
>          * Validate version
> --
> 1.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
