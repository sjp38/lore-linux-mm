Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 292DC6B0071
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 21:41:54 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id ft15so4667829pdb.17
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 18:41:53 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id s1si3819659pdi.266.2014.07.24.18.41.52
        for <linux-mm@kvack.org>;
        Thu, 24 Jul 2014 18:41:53 -0700 (PDT)
Message-ID: <53D1B5C2.6020700@linux.intel.com>
Date: Fri, 25 Jul 2014 09:41:22 +0800
From: Jiang Liu <jiang.liu@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [RFC Patch V1 29/30] mm, x86: Enable memoryless node support
 to better support CPU/memory hotplug
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com> <1405064267-11678-30-git-send-email-jiang.liu@linux.intel.com> <20140724232605.GB24458@linux.vnet.ibm.com>
In-Reply-To: <20140724232605.GB24458@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Toshi Kani <toshi.kani@hp.com>, Igor Mammedov <imammedo@redhat.com>, Borislav Petkov <bp@alien8.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Tang Chen <tangchen@cn.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Lans Zhang <jia.zhang@windriver.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-pm@vger.kernel.org



On 2014/7/25 7:26, Nishanth Aravamudan wrote:
> On 11.07.2014 [15:37:46 +0800], Jiang Liu wrote:
>> With current implementation, all CPUs within a NUMA node will be
>> assocaited with another NUMA node if the node has no memory installed.
> 
> <snip>
> 
>> ---
>>  arch/x86/Kconfig            |    3 +++
>>  arch/x86/kernel/acpi/boot.c |    5 ++++-
>>  arch/x86/kernel/smpboot.c   |    2 ++
>>  arch/x86/mm/numa.c          |   42 +++++++++++++++++++++++++++++++++++-------
>>  4 files changed, 44 insertions(+), 8 deletions(-)
>>
>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>> index a8f749ef0fdc..f35b25b88625 100644
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -1887,6 +1887,9 @@ config USE_PERCPU_NUMA_NODE_ID
>>  	def_bool y
>>  	depends on NUMA
>>
>> +config HAVE_MEMORYLESS_NODES
>> +	def_bool NUMA
>> +
>>  config ARCH_ENABLE_SPLIT_PMD_PTLOCK
>>  	def_bool y
>>  	depends on X86_64 || X86_PAE
>> diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
>> index 86281ffb96d6..3b5641703a49 100644
>> --- a/arch/x86/kernel/acpi/boot.c
>> +++ b/arch/x86/kernel/acpi/boot.c
>> @@ -612,6 +612,8 @@ static void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
>>  	if (nid != -1) {
>>  		set_apicid_to_node(physid, nid);
>>  		numa_set_node(cpu, nid);
>> +		if (node_online(nid))
>> +			set_cpu_numa_mem(cpu, local_memory_node(nid));
> 
> How common is it for this method to be called for a CPU on an offline
> node? Aren't you fixing this in the next patch (so maybe the order
> should be changed?)?
Hi Nishanth,
	For physical CPU hot-addition instead of logical CPU online through
sysfs, the node is always in offline state.
	In v2, I have reordered the patch set so patch 30 goes first.

> 
>>  	}
>>  #endif
>>  }
>> @@ -644,9 +646,10 @@ int acpi_unmap_lsapic(int cpu)
>>  {
>>  #ifdef CONFIG_ACPI_NUMA
>>  	set_apicid_to_node(per_cpu(x86_cpu_to_apicid, cpu), NUMA_NO_NODE);
>> +	set_cpu_numa_mem(cpu, NUMA_NO_NODE);
>>  #endif
>>
>> -	per_cpu(x86_cpu_to_apicid, cpu) = -1;
>> +	per_cpu(x86_cpu_to_apicid, cpu) = BAD_APICID;
> 
> I think this is an unrelated change?
Thanks for reminder, it's unrelated to support memoryless node.

> 
>>  	set_cpu_present(cpu, false);
>>  	num_processors--;
>>
>> diff --git a/arch/x86/kernel/smpboot.c b/arch/x86/kernel/smpboot.c
>> index 5492798930ef..4a5437989ffe 100644
>> --- a/arch/x86/kernel/smpboot.c
>> +++ b/arch/x86/kernel/smpboot.c
>> @@ -162,6 +162,8 @@ static void smp_callin(void)
>>  		      __func__, cpuid);
>>  	}
>>
>> +	set_numa_mem(local_memory_node(cpu_to_node(cpuid)));
>> +
> 
> Note that you might hit the same issue I reported on powerpc, if
> smp_callin() is part of smp_init(). The waitqueue initialization code
> depends on cpu_to_node() [and eventually cpu_to_mem()] to be initialized
> quite early.
Thanks for reminder. Patch 29/30 together will setup cpu_to_mem() array
when enumerating CPUs for hot-adding events, so it should be ready
for use when onlining those CPUs.

Regards!
Gerry
> 
> Thanks,
> Nish
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
