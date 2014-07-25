Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 951486B0072
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 21:43:26 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so5087683pab.2
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 18:43:26 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id gx11si7637838pbd.66.2014.07.24.18.43.25
        for <linux-mm@kvack.org>;
        Thu, 24 Jul 2014 18:43:25 -0700 (PDT)
Message-ID: <53D1B634.4080902@linux.intel.com>
Date: Fri, 25 Jul 2014 09:43:16 +0800
From: Jiang Liu <jiang.liu@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [RFC Patch V1 30/30] x86, NUMA: Online node earlier when doing
 CPU hot-addition
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com> <1405064267-11678-31-git-send-email-jiang.liu@linux.intel.com> <20140724233027.GC24458@linux.vnet.ibm.com>
In-Reply-To: <20140724233027.GC24458@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org



On 2014/7/25 7:30, Nishanth Aravamudan wrote:
> On 11.07.2014 [15:37:47 +0800], Jiang Liu wrote:
>> With typical CPU hot-addition flow on x86, PCI host bridges embedded
>> in physical processor are always associated with NOMA_NO_NODE, which
>> may cause sub-optimal performance.
>> 1) Handle CPU hot-addition notification
>> 	acpi_processor_add()
>> 		acpi_processor_get_info()
>> 			acpi_processor_hotadd_init()
>> 				acpi_map_lsapic()
>> 1.a)					acpi_map_cpu2node()
>>
>> 2) Handle PCI host bridge hot-addition notification
>> 	acpi_pci_root_add()
>> 		pci_acpi_scan_root()
>> 2.a)			if (node != NUMA_NO_NODE && !node_online(node)) node = NUMA_NO_NODE;
>>
>> 3) Handle memory hot-addition notification
>> 	acpi_memory_device_add()
>> 		acpi_memory_enable_device()
>> 			add_memory()
>> 3.a)				node_set_online();
>>
>> 4) Online CPUs through sysfs interfaces
>> 	cpu_subsys_online()
>> 		cpu_up()
>> 			try_online_node()
>> 4.a)				node_set_online();
>>
>> So associated node is always in offline state because it is onlined
>> until step 3.a or 4.a.
>>
>> We could improve performance by online node at step 1.a. This change
>> also makes the code symmetric. Nodes are always created when handling
>> CPU/memory hot-addition events instead of handling user requests from
>> sysfs interfaces, and are destroyed when handling CPU/memory hot-removal
>> events.
> 
> It seems like this patch has little to nothing to do with the rest of
> the series and can be sent on its own?
> 
>> It also close a race window caused by kmalloc_node(cpu_to_node(cpu)),
> 
> To be clear, the race is that on some x86 platforms, there is a period
> of time where a node ID returned by cpu_to_node() is offline.
> 
> <snip>
> 
>> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
>> ---
>>  arch/x86/kernel/acpi/boot.c |    1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
>> index 3b5641703a49..00c2ed507460 100644
>> --- a/arch/x86/kernel/acpi/boot.c
>> +++ b/arch/x86/kernel/acpi/boot.c
>> @@ -611,6 +611,7 @@ static void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
>>  	nid = acpi_get_node(handle);
>>  	if (nid != -1) {
>>  		set_apicid_to_node(physid, nid);
>> +		try_online_node(nid);
> 
> try_online_node() seems like it can fail? I assume it's a pretty rare
> case, but should the return code be checked?
Good suggestion, I should split out this patch to fix the crash.

> 
> If it does fail, it seems like there are pretty serious problems and we
> shouldn't be onlining this CPU, etc.?
> 
>>  		numa_set_node(cpu, nid);
>>  		if (node_online(nid))
>>  			set_cpu_numa_mem(cpu, local_memory_node(nid));
> 
> Which means you can remove this check presuming try_online_node()
> returned 0.
Yes, that's true.

> 
> Thanks,
> Nish
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
