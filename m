Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 875386B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 07:34:00 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fu12so130270501pac.1
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 04:34:00 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id 126si27226445pff.262.2016.09.13.04.33.57
        for <linux-mm@kvack.org>;
        Tue, 13 Sep 2016 04:33:58 -0700 (PDT)
Subject: Re: [PATCH v12 0/7] Make cpuid <-> nodeid mapping persistent
References: <1472114120-3281-1-git-send-email-douly.fnst@cn.fujitsu.com>
 <5cdaa83f-142b-b9a0-6b7b-57c9162fc537@cn.fujitsu.com>
From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Message-ID: <1c2fb3fb-be7b-8980-e70d-e57080888c94@cn.fujitsu.com>
Date: Tue, 13 Sep 2016 19:33:54 +0800
MIME-Version: 1.0
In-Reply-To: <5cdaa83f-142b-b9a0-6b7b-57c9162fc537@cn.fujitsu.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, tj@kernel.org, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn, rafael@kernel.org
Cc: x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Ping...

At 09/02/2016 02:57 PM, Dou Liyang wrote:
> Ping...
>
> At 08/25/2016 04:35 PM, Dou Liyang wrote:
>> [Summary]
>>
>> Use ACPI tables: MADT, DSDT.
>> 1. Create cpuid in order based on Local Apic ID in MADT(apicid).
>> 2. Obtain the nodeid by the proc_id in DSDT.
>> 3. Make the cpuid <-> nodeid mapping persistent.
>>
>> The mapping relations:
>>
>> proc_id in DSDT <--> Processor ID in MADT(acpiid) <--> Local Apic ID
>> in MADT(apicid)
>>         ^                                                        ^
>>         |                                                        |
>>         va??                                                       va??
>>    pxm in DSDT                                                 cpuid
>>         ^
>>         |
>>         v
>>      nodeid
>>
>> [Problem]
>>
>> cpuid <-> nodeid mapping is firstly established at boot time. And
>> workqueue caches
>> the mapping in wq_numa_possible_cpumask in wq_numa_init() at boot time.
>>
>> When doing node online/offline, cpuid <-> nodeid mapping is
>> established/destroyed,
>> which means, cpuid <-> nodeid mapping will change if node hotplug
>> happens. But
>> workqueue does not update wq_numa_possible_cpumask.
>>
>> So here is the problem:
>>
>> Assume we have the following cpuid <-> nodeid in the beginning:
>>
>>   Node | CPU
>> ------------------------
>> node 0 |  0-14, 60-74
>> node 1 | 15-29, 75-89
>> node 2 | 30-44, 90-104
>> node 3 | 45-59, 105-119
>>
>> and we hot-remove node2 and node3, it becomes:
>>
>>   Node | CPU
>> ------------------------
>> node 0 |  0-14, 60-74
>> node 1 | 15-29, 75-89
>>
>> and we hot-add node4 and node5, it becomes:
>>
>>   Node | CPU
>> ------------------------
>> node 0 |  0-14, 60-74
>> node 1 | 15-29, 75-89
>> node 4 | 30-59
>> node 5 | 90-119
>>
>> But in wq_numa_possible_cpumask, cpu30 is still mapped to node2, and
>> the like.
>>
>> When a pool workqueue is initialized, if its cpumask belongs to a
>> node, its
>> pool->node will be mapped to that node. And memory used by this
>> workqueue will
>> also be allocated on that node.
>>
>> static struct worker_pool *get_unbound_pool(const struct
>> workqueue_attrs *attrs){
>> ...
>>         /* if cpumask is contained inside a NUMA node, we belong to
>> that node */
>>         if (wq_numa_enabled) {
>>                 for_each_node(node) {
>>                         if (cpumask_subset(pool->attrs->cpumask,
>>
>> wq_numa_possible_cpumask[node])) {
>>                                 pool->node = node;
>>                                 break;
>>                         }
>>                 }
>>         }
>>
>> Since wq_numa_possible_cpumask is not updated, it could be mapped to
>> an offline node,
>> which will lead to memory allocation failure:
>>
>>  SLUB: Unable to allocate memory on node 2 (gfp=0x80d0)
>>   cache: kmalloc-192, object size: 192, buffer size: 192, default
>> order: 1, min order: 0
>>   node 0: slabs: 6172, objs: 259224, free: 245741
>>   node 1: slabs: 3261, objs: 136962, free: 127656
>>
>> It happens here:
>>
>> create_worker(struct worker_pool *pool)
>>  |--> worker = alloc_worker(pool->node);
>>
>> static struct worker *alloc_worker(int node)
>> {
>>         struct worker *worker;
>>
>>         worker = kzalloc_node(sizeof(*worker), GFP_KERNEL, node); -->
>> Here, useing the wrong node.
>>
>>         ......
>>
>>         return worker;
>> }
>>
>>
>> [Solution]
>>
>> There are four mappings in the kernel:
>> 1. nodeid (logical node id)   <->   pxm
>> 2. apicid (physical cpu id)   <->   nodeid
>> 3. cpuid (logical cpu id)     <->   apicid
>> 4. cpuid (logical cpu id)     <->   nodeid
>>
>> 1. pxm (proximity domain) is provided by ACPI firmware in SRAT, and
>> nodeid <-> pxm
>>    mapping is setup at boot time. This mapping is persistent, won't
>> change.
>>
>> 2. apicid <-> nodeid mapping is setup using info in 1. The mapping is
>> setup at boot
>>    time and CPU hotadd time, and cleared at CPU hotremove time. This
>> mapping is also
>>    persistent.
>>
>> 3. cpuid <-> apicid mapping is setup at boot time and CPU hotadd time.
>> cpuid is
>>    allocated, lower ids first, and released at CPU hotremove time,
>> reused for other
>>    hotadded CPUs. So this mapping is not persistent.
>>
>> 4. cpuid <-> nodeid mapping is also setup at boot time and CPU hotadd
>> time, and
>>    cleared at CPU hotremove time. As a result of 3, this mapping is
>> not persistent.
>>
>> To fix this problem, we establish cpuid <-> nodeid mapping for all the
>> possible
>> cpus at boot time, and make it persistent. And according to
>> init_cpu_to_node(),
>> cpuid <-> nodeid mapping is based on apicid <-> nodeid mapping and
>> cpuid <-> apicid
>> mapping. So the key point is obtaining all cpus' apicid.
>>
>> apicid can be obtained by _MAT (Multiple APIC Table Entry) method or
>> found in
>> MADT (Multiple APIC Description Table). So we finish the job in the
>> following steps:
>>
>> 1. Enable apic registeration flow to handle both enabled and disabled
>> cpus.
>>    This is done by introducing an extra parameter to
>> generic_processor_info to let the
>>    caller control if disabled cpus are ignored.
>>
>> 2. Introduce a new array storing all possible cpuid <-> apicid
>> mapping. And also modify
>>    the way cpuid is calculated. Establish all possible cpuid <->
>> apicid mapping when
>>    registering local apic. Store the mapping in this array.
>>
>> 3. Enable _MAT and MADT relative apis to return non-presnet or
>> disabled cpus' apicid.
>>    This is also done by introducing an extra parameter to these apis
>> to let the caller
>>    control if disabled cpus are ignored.
>>
>> 4. Establish all possible cpuid <-> nodeid mapping.
>>    This is done via an additional acpi namespace walk for processors.
>>
>>
>> For previous discussion, please refer to:
>> https://lkml.org/lkml/2015/2/27/145
>> https://lkml.org/lkml/2015/3/25/989
>> https://lkml.org/lkml/2015/5/14/244
>> https://lkml.org/lkml/2015/7/7/200
>> https://lkml.org/lkml/2015/9/27/209
>> https://lkml.org/lkml/2016/5/19/212
>> https://lkml.org/lkml/2016/7/19/181
>> https://lkml.org/lkml/2016/7/25/99
>> https://lkml.org/lkml/2016/7/26/52
>> https://lkml.org/lkml/2016/8/8/96
>>
>> Change log v11 -> v12:
>> 1. Rebase
>> 2. Add a short summary
>>
>> Change log v10 -> v11:
>> 1. Reduce the number of repeat judgment of online/offline
>> 2. Seperate out the functionality in the enable or disable situation
>>
>> Change log v9 -> v10:
>> 1. Providing an empty definition of acpi_set_processor_mapping() for
>> CONFIG_ACPI_HOTPLUG_CPU unset. In patch 5.
>> 2. Fix auto build test ERROR on ia64/next. In patch 5.
>> 3. Fix some comment.
>>
>> Change log v8 -> v9:
>> 1. Providing an empty definition of acpi_set_processor_mapping() for
>> CONFIG_ACPI_HOTPLUG_CPU unset.
>>
>> Change log v7 -> v8:
>> 1. Provide the mechanism to validate processors in the ACPI tables.
>> 2. Provide the interface to validate the proc_id when setting the
>> mapping.
>>
>> Change log v6 -> v7:
>> 1. Fix arm64 build failure.
>>
>> Change log v5 -> v6:
>> 1. Define func acpi_map_cpu2node() for x86 and ia64 respectively.
>>
>> Change log v4 -> v5:
>> 1. Remove useless code in patch 1.
>> 2. Small improvement of commit message.
>>
>> Change log v3 -> v4:
>> 1. Fix the kernel panic at boot time. The cause is that I tried to
>> build zonelists
>>    before per cpu areas were initialized.
>>
>> Change log v2 -> v3:
>> 1. Online memory-less nodes at boot time to map cpus of memory-less
>> nodes.
>> 2. Build zonelists for memory-less nodes so that memory allocator will
>> fall
>>    back to proper nodes automatically.
>>
>> Change log v1 -> v2:
>> 1. Split code movement and actual changes. Add patch 1.
>> 2. Synchronize best near online node record when node hotplug happens.
>> In patch 2.
>> 3. Fix some comment.
>>
>> Dou Liyang (2):
>>   acpi: Provide the mechanism to validate processors in the ACPI tables
>>   acpi: Provide the interface to validate the proc_id
>>
>> Gu Zheng (4):
>>   x86, acpi, cpu-hotplug: Enable acpi to register all possible cpus at
>>     boot time.
>>   x86, acpi, cpu-hotplug: Introduce cpuid_to_apicid[] array to store
>>     persistent cpuid <-> apicid mapping.
>>   x86, acpi, cpu-hotplug: Enable MADT APIs to return disabled apicid.
>>   x86, acpi, cpu-hotplug: Set persistent cpuid <-> nodeid mapping when
>>     booting.
>>
>> Tang Chen (1):
>>   x86, memhp, numa: Online memory-less nodes at boot time.
>>
>>  arch/ia64/kernel/acpi.c       |   3 +-
>>  arch/x86/include/asm/mpspec.h |   1 +
>>  arch/x86/kernel/acpi/boot.c   |  11 ++--
>>  arch/x86/kernel/apic/apic.c   |  77 +++++++++++++++++++++++--
>>  arch/x86/mm/numa.c            |  27 +++++----
>>  drivers/acpi/acpi_processor.c | 105 ++++++++++++++++++++++++++++++++-
>>  drivers/acpi/bus.c            |   1 +
>>  drivers/acpi/processor_core.c | 131
>> +++++++++++++++++++++++++++++++++++-------
>>  include/linux/acpi.h          |   6 ++
>>  9 files changed, 311 insertions(+), 51 deletions(-)
>>
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
