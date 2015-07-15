Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 96128280277
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 23:33:18 -0400 (EDT)
Received: by padck2 with SMTP id ck2so16019913pad.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 20:33:18 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id gj3si5158274pac.14.2015.07.14.20.33.16
        for <linux-mm@kvack.org>;
        Tue, 14 Jul 2015 20:33:17 -0700 (PDT)
Message-ID: <55A5D4A5.8040806@cn.fujitsu.com>
Date: Wed, 15 Jul 2015 11:33:57 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] x86, acpi, cpu-hotplug: Introduce apicid_to_cpuid[]
 array to store persistent cpuid <-> apicid mapping.
References: <1436261425-29881-1-git-send-email-tangchen@cn.fujitsu.com>	<1436261425-29881-4-git-send-email-tangchen@cn.fujitsu.com> <CAChTCPw6ZLs7XgApfN1exeB6TVcQji6ryq+HrK-admp=FGfiTA@mail.gmail.com>
In-Reply-To: <CAChTCPw6ZLs7XgApfN1exeB6TVcQji6ryq+HrK-admp=FGfiTA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?TWlrYSBQZW50dGlsw6Q=?= <mika.j.penttila@gmail.com>
Cc: rjw@rjwysocki.net, gongzhaogang@inspur.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Mika,

On 07/07/2015 07:14 PM, Mika Penttil=C3=A4 wrote:
> I think you forgot to reserve CPU 0 for BSP in cpuid mask.

Sorry for the late reply.

I'm not familiar with BSP.  Do you mean in get_cpuid(),
I should reserve 0 for physical cpu0 in BSP ?

Would you please share more detail ?

Thanks.

>
> --Mika
>
> On Tue, Jul 7, 2015 at 12:30 PM, Tang Chen <tangchen@cn.fujitsu.com> wrot=
e:
>> From: Gu Zheng <guz.fnst@cn.fujitsu.com>
>>
>> In this patch, we introduce a new static array named apicid_to_cpuid[],
>> which is large enough to store info for all possible cpus.
>>
>> And then, we modify the cpuid calculation. In generic_processor_info(),
>> it simply finds the next unused cpuid. And it is also why the cpuid <-> =
nodeid
>> mapping changes with node hotplug.
>>
>> After this patch, we find the next unused cpuid, map it to an apicid,
>> and store the mapping in apicid_to_cpuid[], so that cpuid <-> apicid
>> mapping will be persistent.
>>
>> And finally we will use this array to make cpuid <-> nodeid persistent.
>>
>> cpuid <-> apicid mapping is established at local apic registeration time=
.
>> But non-present or disabled cpus are ignored.
>>
>> In this patch, we establish all possible cpuid <-> apicid mapping when
>> registering local apic.
>>
>>
>> Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
>> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
>> ---
>>   arch/x86/include/asm/mpspec.h |  1 +
>>   arch/x86/kernel/acpi/boot.c   |  6 ++----
>>   arch/x86/kernel/apic/apic.c   | 47 +++++++++++++++++++++++++++++++++++=
+++++---
>>   3 files changed, 47 insertions(+), 7 deletions(-)
>>
>> diff --git a/arch/x86/include/asm/mpspec.h b/arch/x86/include/asm/mpspec=
.h
>> index b07233b..db902d8 100644
>> --- a/arch/x86/include/asm/mpspec.h
>> +++ b/arch/x86/include/asm/mpspec.h
>> @@ -86,6 +86,7 @@ static inline void early_reserve_e820_mpc_new(void) { =
}
>>   #endif
>>
>>   int generic_processor_info(int apicid, int version);
>> +int __generic_processor_info(int apicid, int version, bool enabled);
>>
>>   #define PHYSID_ARRAY_SIZE      BITS_TO_LONGS(MAX_LOCAL_APIC)
>>
>> diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
>> index e49ee24..bcc85b2 100644
>> --- a/arch/x86/kernel/acpi/boot.c
>> +++ b/arch/x86/kernel/acpi/boot.c
>> @@ -174,15 +174,13 @@ static int acpi_register_lapic(int id, u8 enabled)
>>                  return -EINVAL;
>>          }
>>
>> -       if (!enabled) {
>> +       if (!enabled)
>>                  ++disabled_cpus;
>> -               return -EINVAL;
>> -       }
>>
>>          if (boot_cpu_physical_apicid !=3D -1U)
>>                  ver =3D apic_version[boot_cpu_physical_apicid];
>>
>> -       return generic_processor_info(id, ver);
>> +       return __generic_processor_info(id, ver, enabled);
>>   }
>>
>>   static int __init
>> diff --git a/arch/x86/kernel/apic/apic.c b/arch/x86/kernel/apic/apic.c
>> index a9c9830..c744ffb 100644
>> --- a/arch/x86/kernel/apic/apic.c
>> +++ b/arch/x86/kernel/apic/apic.c
>> @@ -1977,7 +1977,38 @@ void disconnect_bsp_APIC(int virt_wire_setup)
>>          apic_write(APIC_LVT1, value);
>>   }
>>
>> -static int __generic_processor_info(int apicid, int version, bool enabl=
ed)
>> +/*
>> + * Logic cpu number(cpuid) to local APIC id persistent mappings.
>> + * Do not clear the mapping even if cpu is hot-removed.
>> + */
>> +static int apicid_to_cpuid[] =3D {
>> +       [0 ... NR_CPUS - 1] =3D -1,
>> +};
>> +
>> +/*
>> + * Internal cpu id bits, set the bit once cpu present, and never clear =
it.
>> + */
>> +static cpumask_t cpuid_mask =3D CPU_MASK_NONE;
>> +
>> +static int get_cpuid(int apicid)
>> +{
>> +       int free_id, i;
>> +
>> +       free_id =3D cpumask_next_zero(-1, &cpuid_mask);
>> +       if (free_id >=3D nr_cpu_ids)
>> +               return -1;
>> +
>> +       for (i =3D 0; i < free_id; i++)
>> +               if (apicid_to_cpuid[i] =3D=3D apicid)
>> +                       return i;
>> +
>> +       apicid_to_cpuid[free_id] =3D apicid;
>> +       cpumask_set_cpu(free_id, &cpuid_mask);
>> +
>> +       return free_id;
>> +}
>> +
>> +int __generic_processor_info(int apicid, int version, bool enabled)
>>   {
>>          int cpu, max =3D nr_cpu_ids;
>>          bool boot_cpu_detected =3D physid_isset(boot_cpu_physical_apici=
d,
>> @@ -2058,8 +2089,18 @@ static int __generic_processor_info(int apicid, i=
nt version, bool enabled)
>>                   * for BSP.
>>                   */
>>                  cpu =3D 0;
>> -       } else
>> -               cpu =3D cpumask_next_zero(-1, cpu_present_mask);
>> +       } else {
>> +               cpu =3D get_cpuid(apicid);
>> +               if (cpu < 0) {
>> +                       int thiscpu =3D max + disabled_cpus;
>> +
>> +                       pr_warning("  Processor %d/0x%x ignored.\n",
>> +                                  thiscpu, apicid);
>> +                       if (enabled)
>> +                               disabled_cpus++;
>> +                       return -EINVAL;
>> +               }
>> +       }
>>
>>          /*
>>           * Validate version
>> --
>> 1.9.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
> .
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
