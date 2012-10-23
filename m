Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 5B98D6B0062
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 06:33:56 -0400 (EDT)
Message-ID: <508673E2.7070203@cn.fujitsu.com>
Date: Tue, 23 Oct 2012 18:39:30 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/12] memory-hotplug: hot-remove physical memory
References: <1350988250-31294-1-git-send-email-wency@cn.fujitsu.com> <508671AD.6000704@gmail.com>
In-Reply-To: <508671AD.6000704@gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ni zhan Chen <nizhan.chen@gmail.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

At 10/23/2012 06:30 PM, Ni zhan Chen Wrote:
> On 10/23/2012 06:30 PM, wency@cn.fujitsu.com wrote:
>> From: Wen Congyang <wency@cn.fujitsu.com>
> 
> The patchset doesn't support kernel memory hot-remove, correct? If the
> answer is yes, you should point out in your patchset changelog.

The answer is no. If you only apply this patchset, you only can hotremove
the memory by SCI. If you want to hotremove it by writing 1 to the file
/sys/bus/acpi/devices/PNP0C80:XX/eject, you should apply the following
patchset:
https://lkml.org/lkml/2012/10/19/156

Thanks
Wen Congyang

> 
>>
>> The patch-set was divided from following thread's patch-set.
>>
>> https://lkml.org/lkml/2012/9/5/201
>>
>> The last version of this patchset:
>> https://lkml.org/lkml/2012/10/5/469
>>
>> If you want to know the reason, please read following thread.
>>
>> https://lkml.org/lkml/2012/10/2/83
>>
>> The patch-set has only the function of kernel core side for physical
>> memory hot remove. So if you use the patch, please apply following
>> patches.
>>
>> - bug fix for memory hot remove
>>    https://lkml.org/lkml/2012/10/19/56
>>    - acpi framework
>>    https://lkml.org/lkml/2012/10/19/156
>>
>> The patches can free/remove the following things:
>>
>>    - /sys/firmware/memmap/X/{end, start, type} : [PATCH 2/10]
>>    - mem_section and related sysfs files       : [PATCH 3-4/10]
>>    - memmap of sparse-vmemmap                  : [PATCH 5-7/10]
>>    - page table of removed memory              : [RFC PATCH 8/10]
>>    - node and related sysfs files              : [RFC PATCH 9-10/10]
>>
>> * [PATCH 2/10] checks whether the memory can be removed or not.
>>
>> If you find lack of function for physical memory hot-remove, please
>> let me
>> know.
>>
>> How to test this patchset?
>> 1. apply this patchset and build the kernel. MEMORY_HOTPLUG,
>> MEMORY_HOTREMOVE,
>>     ACPI_HOTPLUG_MEMORY must be selected.
>> 2. load the module acpi_memhotplug
>> 3. hotplug the memory device(it depends on your hardware)
>>     You will see the memory device under the directory
>> /sys/bus/acpi/devices/.
>>     Its name is PNP0C80:XX.
>> 4. online/offline pages provided by this memory device
>>     You can write online/offline to
>> /sys/devices/system/memory/memoryX/state to
>>     online/offline pages provided by this memory device
>> 5. hotremove the memory device
>>     You can hotremove the memory device by the hardware, or writing 1 to
>>     /sys/bus/acpi/devices/PNP0C80:XX/eject.
>>
>> Note: if the memory provided by the memory device is used by the
>> kernel, it
>> can't be offlined. It is not a bug.
>>
>> Known problems:
>> 1. hotremoving memory device may cause kernel panicked
>>     This bug will be fixed by Liu Jiang's patch:
>>     https://lkml.org/lkml/2012/7/3/1
>>
>>
>> Changelogs from v1 to v2:
>>   Patch1: new patch, offline memory twice. 1st iterate: offline every
>> non primary
>>           memory block. 2nd iterate: offline primary (i.e. first
>> added) memory
>>           block.
>>
>>   Patch3: new patch, no logical change, just remove reduntant codes.
>>
>>   Patch9: merge the patch from wujianguo into this patch. flush tlb on
>> all cpu
>>           after the pagetable is changed.
>>
>>   Patch12: new patch, free node_data when a node is offlined
>>
>> Wen Congyang (6):
>>    memory-hotplug: try to offline the memory twice to avoid dependence
>>    memory-hotplug: remove redundant codes
>>    memory-hotplug: introduce new function arch_remove_memory() for
>>      removing page table depends on architecture
>>    memory-hotplug: remove page table of x86_64 architecture
>>    memory-hotplug: remove sysfs file of node
>>    memory-hotplug: free node_data when a node is offlined
>>
>> Yasuaki Ishimatsu (6):
>>    memory-hotplug: check whether all memory blocks are offlined or not
>>      when removing memory
>>    memory-hotplug: remove /sys/firmware/memmap/X sysfs
>>    memory-hotplug: unregister memory section on SPARSEMEM_VMEMMAP
>>    memory-hotplug: implement register_page_bootmem_info_section of
>>      sparse-vmemmap
>>    memory-hotplug: remove memmap of sparse-vmemmap
>>    memory-hotplug: memory_hotplug: clear zone when removing the memory
>>
>>   arch/ia64/mm/discontig.c             |   14 ++
>>   arch/ia64/mm/init.c                  |   18 ++
>>   arch/powerpc/mm/init_64.c            |   14 ++
>>   arch/powerpc/mm/mem.c                |   12 +
>>   arch/s390/mm/init.c                  |   12 +
>>   arch/s390/mm/vmem.c                  |   14 ++
>>   arch/sh/mm/init.c                    |   17 ++
>>   arch/sparc/mm/init_64.c              |   14 ++
>>   arch/tile/mm/init.c                  |    8 +
>>   arch/x86/include/asm/pgtable_types.h |    1 +
>>   arch/x86/mm/init_32.c                |   12 +
>>   arch/x86/mm/init_64.c                |  409
>> ++++++++++++++++++++++++++++++++++
>>   arch/x86/mm/pageattr.c               |   47 ++--
>>   drivers/acpi/acpi_memhotplug.c       |    8 +-
>>   drivers/base/memory.c                |    6 +
>>   drivers/firmware/memmap.c            |   98 ++++++++-
>>   include/linux/firmware-map.h         |    6 +
>>   include/linux/memory_hotplug.h       |   15 +-
>>   include/linux/mm.h                   |    5 +-
>>   mm/memory_hotplug.c                  |  409
>> ++++++++++++++++++++++++++++++++--
>>   mm/sparse.c                          |    5 +-
>>   21 files changed, 1087 insertions(+), 57 deletions(-)
>>
>> -- 
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
