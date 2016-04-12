Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 03E5C6B0253
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 04:04:43 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id e128so9296134pfe.3
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 01:04:42 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id 16si8561676pfi.41.2016.04.12.01.04.04
        for <linux-mm@kvack.org>;
        Tue, 12 Apr 2016 01:04:42 -0700 (PDT)
Message-ID: <570CABDE.7030902@cn.fujitsu.com>
Date: Tue, 12 Apr 2016 16:03:42 +0800
From: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 5/5] x86, acpi, cpu-hotplug: Set persistent cpuid <->
 nodeid mapping when booting.
References: <cover.1458177577.git.zhugh.fnst@cn.fujitsu.com> <0ecee1cba429e53220c7887c7a139ad598c5a4a2.1458177577.git.zhugh.fnst@cn.fujitsu.com> <20160406142916.GA1462@red-moon>
In-Reply-To: <20160406142916.GA1462@red-moon>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
Cc: cl@linux.com, tj@kernel.org, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dennis.chen@arm.com

Hi Lorenzo,

Thanks for your test and detailed suggestions.
I will update those later.

Thanks,
Zhu

On 04/06/2016 10:29 PM, Lorenzo Pieralisi wrote:
> [+Dennis since he reported ARM64 build breakage]
>
> On Thu, Mar 17, 2016 at 09:32:40AM +0800, Zhu Guihua wrote:
>> From: Gu Zheng <guz.fnst@cn.fujitsu.com>
>>
>> The whole patch-set aims at making cpuid <-> nodeid mapping persistent. So that,
>> when node online/offline happens, cache based on cpuid <-> nodeid mapping such as
>> wq_numa_possible_cpumask will not cause any problem.
>> It contains 4 steps:
>> 1. Enable apic registeration flow to handle both enabled and disabled cpus.
>> 2. Introduce a new array storing all possible cpuid <-> apicid mapping.
>> 3. Enable _MAT and MADT relative apis to return non-presnet or disabled cpus' apicid.
>> 4. Establish all possible cpuid <-> nodeid mapping.
>>
>> This patch finishes step 4.
> And it breaks the build on ARM64.
>
> drivers/acpi/processor_core.c: In function 'set_processor_node_mapping':
> drivers/acpi/processor_core.c:316:2: error: implicit declaration of
> function 'acpi_map_cpu2node' [-Werror=implicit-function-declaration]
>
> [...]
>
>> diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
>> index b1698bc..7db5563 100644
>> --- a/arch/ia64/kernel/acpi.c
>> +++ b/arch/ia64/kernel/acpi.c
>> @@ -796,7 +796,7 @@ int acpi_isa_irq_to_gsi(unsigned isa_irq, u32 *gsi)
>>    *  ACPI based hotplug CPU support
>>    */
>>   #ifdef CONFIG_ACPI_HOTPLUG_CPU
>> -static int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
>> +int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
> Return value seems to be ignored on IA64 so you can get rid of it,
> see below.
>
>>   {
>>   #ifdef CONFIG_ACPI_NUMA
>>   	/*
>> diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
>> index 0ce06ee..7d45261 100644
>> --- a/arch/x86/kernel/acpi/boot.c
>> +++ b/arch/x86/kernel/acpi/boot.c
>> @@ -696,7 +696,7 @@ static void __init acpi_set_irq_model_ioapic(void)
>>   #ifdef CONFIG_ACPI_HOTPLUG_CPU
>>   #include <acpi/processor.h>
>>   
>> -static void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
>> +void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
>>   {
>>   #ifdef CONFIG_ACPI_NUMA
>>   	int nid;
>> diff --git a/drivers/acpi/bus.c b/drivers/acpi/bus.c
>> index 0e85678..215177a 100644
>> --- a/drivers/acpi/bus.c
>> +++ b/drivers/acpi/bus.c
>> @@ -1110,6 +1110,9 @@ static int __init acpi_init(void)
>>   	acpi_sleep_proc_init();
>>   	acpi_wakeup_device_init();
>>   	acpi_debugger_init();
>> +#ifdef CONFIG_ACPI_HOTPLUG_CPU
>> +	acpi_set_processor_mapping();
>> +#endif
>>   	return 0;
>>   }
>>   
>> diff --git a/drivers/acpi/processor_core.c b/drivers/acpi/processor_core.c
>> index 824b98b..45580ff 100644
>> --- a/drivers/acpi/processor_core.c
>> +++ b/drivers/acpi/processor_core.c
>> @@ -261,6 +261,71 @@ int acpi_get_cpuid(acpi_handle handle, int type, u32 acpi_id)
>>   }
>>   EXPORT_SYMBOL_GPL(acpi_get_cpuid);
>>   
>> +#ifdef CONFIG_ACPI_HOTPLUG_CPU
>> +static bool map_processor(acpi_handle handle, int *phys_id, int *cpuid)
> phys_id size is 64 bits (phys_cpuid_t) on ARM64, (phys_cpuid_t *phys_id) is
> what you have to have here.
>
>> +{
>> +	int type;
>> +	u32 acpi_id;
>> +	acpi_status status;
>> +	acpi_object_type acpi_type;
>> +	unsigned long long tmp;
>> +	union acpi_object object = { 0 };
>> +	struct acpi_buffer buffer = { sizeof(union acpi_object), &object };
>> +
>> +	status = acpi_get_type(handle, &acpi_type);
>> +	if (ACPI_FAILURE(status))
>> +		return false;
>> +
>> +	switch (acpi_type) {
>> +	case ACPI_TYPE_PROCESSOR:
>> +		status = acpi_evaluate_object(handle, NULL, NULL, &buffer);
>> +		if (ACPI_FAILURE(status))
>> +			return false;
>> +		acpi_id = object.processor.proc_id;
>> +		break;
>> +	case ACPI_TYPE_DEVICE:
>> +		status = acpi_evaluate_integer(handle, "_UID", NULL, &tmp);
>> +		if (ACPI_FAILURE(status))
>> +			return false;
>> +		acpi_id = tmp;
>> +		break;
>> +	default:
>> +		return false;
>> +	}
>> +
>> +	type = (acpi_type == ACPI_TYPE_DEVICE) ? 1 : 0;
>> +
>> +	*phys_id = __acpi_get_phys_id(handle, type, acpi_id, false);
> Wrong on ARM64, see above.
>
>> +	*cpuid = acpi_map_cpuid(*phys_id, acpi_id);
>> +	if (*cpuid == -1)
>> +		return false;
>> +
>> +	return true;
>> +}
>> +
>> +static acpi_status __init
>> +set_processor_node_mapping(acpi_handle handle, u32 lvl, void *context,
>> +			   void **rv)
>> +{
>> +	u32 apic_id;
> - You can't use u32 here see above
> - This is generic code and on ARM64 I have no idea what apic_id means,
>    choose another variable name please (phys_id ?)
>
>> +	int cpu_id;
>> +
>> +	if (!map_processor(handle, &apic_id, &cpu_id))
>> +		return AE_ERROR;
>> +
>> +	acpi_map_cpu2node(handle, cpu_id, apic_id);
>> +	return AE_OK;
>> +}
>> +
>> +void __init acpi_set_processor_mapping(void)
>> +{
>> +	/* Set persistent cpu <-> node mapping for all processors. */
>> +	acpi_walk_namespace(ACPI_TYPE_PROCESSOR, ACPI_ROOT_OBJECT,
>> +			    ACPI_UINT32_MAX, set_processor_node_mapping,
>> +			    NULL, NULL, NULL);
>> +}
>> +#endif
>> +
>>   #ifdef CONFIG_ACPI_HOTPLUG_IOAPIC
>>   static int get_ioapic_id(struct acpi_subtable_header *entry, u32 gsi_base,
>>   			 u64 *phys_addr, int *ioapic_id)
>> diff --git a/include/linux/acpi.h b/include/linux/acpi.h
>> index 06ed7e5..ad9e7c7 100644
>> --- a/include/linux/acpi.h
>> +++ b/include/linux/acpi.h
>> @@ -265,6 +265,12 @@ static inline bool invalid_phys_cpuid(phys_cpuid_t phys_id)
>>   /* Arch dependent functions for cpu hotplug support */
>>   int acpi_map_cpu(acpi_handle handle, phys_cpuid_t physid, int *pcpu);
>>   int acpi_unmap_cpu(int cpu);
>> +#if defined(CONFIG_X86)
>> +void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid);
>> +#elif defined(CONFIG_IA64)
>> +int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid);
>> +#endif
> We do not need this per-arch ifdeffery unless I am missing something
> obvious here, either you change the IA64 prototype or X86 one and
> declare one prototype for all arches, either will do given that return
> value is always ignored (I think changing x86 to return an int is
> advisable).
>
> Lorenzo
>
>
> .
>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
