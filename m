From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 0/5] Add movablecore_map boot option
Date: Thu, 29 Nov 2012 10:49:17 +0800
Message-ID: <45908.1093933948$1354157404@news.gmane.org>
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com>
 <50B5CFAE.80103@huawei.com>
 <20121129014251.GA9217@kernel>
 <50B6C7A4.806@huawei.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1TduCH-0003GK-E0
	for glkm-linux-mm-2@m.gmane.org; Thu, 29 Nov 2012 03:49:53 +0100
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id AF97A6B0068
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 21:49:35 -0500 (EST)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 29 Nov 2012 12:43:48 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qAT2nKPj61079632
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 13:49:21 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qAT2nIvO026814
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 13:49:20 +1100
Content-Disposition: inline
In-Reply-To: <50B6C7A4.806@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, hpa@zytor.com, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, "Wang, Frank" <frank.wang@intel.com>

On Thu, Nov 29, 2012 at 10:25:40AM +0800, Jiang Liu wrote:
>On 2012-11-29 9:42, Jaegeuk Hanse wrote:
>> On Wed, Nov 28, 2012 at 04:47:42PM +0800, Jiang Liu wrote:
>>> Hi all,
>>> 	Seems it's a great chance to discuss about the memory hotplug feature
>>> within this thread. So I will try to give some high level thoughts about memory
>>> hotplug feature on x86/IA64. Any comments are welcomed!
>>> 	First of all, I think usability really matters. Ideally, memory hotplug
>>> feature should just work out of box, and we shouldn't expect administrators to 
>>> add several extra platform dependent parameters to enable memory hotplug. 
>>> But how to enable memory (or CPU/node) hotplug out of box? I think the key point
>>> is to cooperate with BIOS/ACPI/firmware/device management teams. 
>>> 	I still position memory hotplug as an advanced feature for high end 
>>> servers and those systems may/should provide some management interfaces to 
>>> configure CPU/memory/node hotplug features. The configuration UI may be provided
>>> by BIOS, BMC or centralized system management suite. Once administrator enables
>>> hotplug feature through those management UI, OS should support system device
>>> hotplug out of box. For example, HP SuperDome2 management suite provides interface
>>> to configure a node as floating node(hot-removable). And OpenSolaris supports
>>> CPU/memory hotplug out of box without any extra configurations. So we should
>>> shape interfaces between firmware and OS to better support system device hotplug.
>>> 	On the other hand, I think there are no commercial available x86/IA64
>>> platforms with system device hotplug capabilities in the field yet, at least only
>>> limited quantity if any. So backward compatibility is not a big issue for us now.
>>> So I think it's doable to rely on firmware to provide better support for system
>>> device hotplug.
>>> 	Then what should be enhanced to better support system device hotplug?
>>>
>>> 1) ACPI specification should be enhanced to provide a static table to describe
>>> components with hotplug features, so OS could reserve special resources for
>>> hotplug at early boot stages. For example, to reserve enough CPU ids for CPU
>>> hot-add. Currently we guess maximum number of CPUs supported by the platform
>>> by counting CPU entries in APIC table, that's not reliable.
>>>
>>> 2) BIOS should implement SRAT, MPST and PMTT tables to better support memory
>>> hotplug. SRAT associates memory ranges with proximity domains with an extra
>>> "hotpluggable" flag. PMTT provides memory device topology information, such
>>> as "socket->memory controller->DIMM". MPST is used for memory power management
>>> and provides a way to associate memory ranges with memory devices in PMTT.
>>> With all information from SRAT, MPST and PMTT, OS could figure out hotplug
>>> memory ranges automatically, so no extra kernel parameters needed.
>>>
>>> 3) Enhance ACPICA to provide a method to scan static ACPI tables before
>>> memory subsystem has been initialized because OS need to access SRAT,
>>> MPST and PMTT when initializing memory subsystem.
>>>
>>> 4) The last and the most important issue is how to minimize performance
>>> drop caused by memory hotplug. As proposed by this patchset, once we
>>> configure all memory of a NUMA node as movable, it essentially disable
>>> NUMA optimization of kernel memory allocation from that node. According
>>> to experience, that will cause huge performance drop. We have observed
>>> 10-30% performance drop with memory hotplug enabled. And on another
>>> OS the average performance drop caused by memory hotplug is about 10%.
>>> If we can't resolve the performance drop, memory hotplug is just a feature
>>> for demo:( With help from hardware, we do have some chances to reduce
>>> performance penalty caused by memory hotplug.
>>> 	As we know, Linux could migrate movable page, but can't migrate
>>> non-movable pages used by kernel/DMA etc. And the most hard part is how
>>> to deal with those unmovable pages when hot-removing a memory device.
>>> Now hardware has given us a hand with a technology named memory migration,
>>> which could transparently migrate memory between memory devices. There's
>>> no OS visible changes except NUMA topology before and after hardware memory
>>> migration.
>>> 	And if there are multiple memory devices within a NUMA node,
>>> we could configure some memory devices to host unmovable memory and the
>>> other to host movable memory. With this configuration, there won't be
>>> bigger performance drop because we have preserved all NUMA optimizations.
>>> We also could achieve memory hotplug remove by:
>>> 1) Use existing page migration mechanism to reclaim movable pages.
>>> 2) For memory devices hosting unmovable pages, we need:
>>> 2.1) find a movable memory device on other nodes with enough capacity
>>> and reclaim it.
>>> 2.2) use hardware migration technology to migrate unmovable memory to
>> 
>> Hi Jiang,
>> 
>> Could you give an explanation how hardware migration technology works?
>Hi Jaegeuk,
>	Now some severs support a hardware memory RAS feature called memory
>mirror, something like RAID1. The mirrored memory devices will be configured
>with the same address and host same contents. And you could transparently
>hot-remove one of the mirrored memory device without any help from OS.
>
>We could think memory migration as an extension to the memory mirror technology.
>The basic flow for memory migration is:
>1) Find a spare memory device with enough capacity in the system.
>2) OS issues a request to firmware to migrate from source memory device (A)
>   to the spare memory device (B).
>3) Firmware configures A and B into memory mode, and configure A as master
>   and B as slave.

Hi Jiang,

THanks for your detail explanation. Then why should configure who is
master and who is slave? It seems that in your explanation OS only can 
know the change after firmware report the results.

Regards,
Jaegeuk

>4) Firmware resilver the mirror to synchronize the content from A to B
>5) Firmware reconfigure B as master and A as slave.
>6) Firmware deconfigures the memory mirror and removes A
>7) Firmware report results to OS.
>8) Now user could hot-remove the source memory device A from system.
>
>During memory migration, A and B are in mirror mode, so CPUs and IO devices
>could access it as normal. After memory migration, memory device B will have
>the same address ranges and content as memory device A, so there's no OS 
>visible changes except latency (because A and B may belong to different NUMA
>domains).
>
>So hardware memory migration could be used to migrate pages can't be migrated
>by OS.
>
>Regards!
>Gerry
>
>> 
>> Regards,
>> Jaegeuk
>> 
>>> the just reclaimed memory device on other nodes.
>>>
>>> 	I hope we could expect users to adopt memory hotplug technology
>>> with all these implemented.
>>>
>>> 	Back to this patch, we could rely on the mechanism provided
>>> by it to automatically mark memory ranges as movable with information
>>>from ACPI SRAT/MPST/PMTT tables. So we don't need administrator to
>>> manually configure kernel parameters to enable memory hotplug.
>>>
>>> 	Again, any comments are welcomed!
>>>
>>> Regards!
>>> Gerry
>>>
>>>
>>> On 2012-11-23 18:44, Tang Chen wrote:
>>>> [What we are doing]
>>>> This patchset provide a boot option for user to specify ZONE_MOVABLE memory
>>>> map for each node in the system.
>>>>
>>>> movablecore_map=nn[KMG]@ss[KMG]
>>>>
>>>> This option make sure memory range from ss to ss+nn is movable memory.
>>>>
>>>>
>>>> [Why we do this]
>>>> If we hot remove a memroy, the memory cannot have kernel memory,
>>>> because Linux cannot migrate kernel memory currently. Therefore,
>>>> we have to guarantee that the hot removed memory has only movable
>>>> memoroy.
>>>>
>>>> Linux has two boot options, kernelcore= and movablecore=, for
>>>> creating movable memory. These boot options can specify the amount
>>>> of memory use as kernel or movable memory. Using them, we can
>>>> create ZONE_MOVABLE which has only movable memory.
>>>>
>>>> But it does not fulfill a requirement of memory hot remove, because
>>>> even if we specify the boot options, movable memory is distributed
>>>> in each node evenly. So when we want to hot remove memory which
>>>> memory range is 0x80000000-0c0000000, we have no way to specify
>>>> the memory as movable memory.
>>>>
>>>> So we proposed a new feature which specifies memory range to use as
>>>> movable memory.
>>>>
>>>>
>>>> [Ways to do this]
>>>> There may be 2 ways to specify movable memory.
>>>>  1. use firmware information
>>>>  2. use boot option
>>>>
>>>> 1. use firmware information
>>>>   According to ACPI spec 5.0, SRAT table has memory affinity structure
>>>>   and the structure has Hot Pluggable Filed. See "5.2.16.2 Memory
>>>>   Affinity Structure". If we use the information, we might be able to
>>>>   specify movable memory by firmware. For example, if Hot Pluggable
>>>>   Filed is enabled, Linux sets the memory as movable memory.
>>>>
>>>> 2. use boot option
>>>>   This is our proposal. New boot option can specify memory range to use
>>>>   as movable memory.
>>>>
>>>>
>>>> [How we do this]
>>>> We chose second way, because if we use first way, users cannot change
>>>> memory range to use as movable memory easily. We think if we create
>>>> movable memory, performance regression may occur by NUMA. In this case,
>>>> user can turn off the feature easily if we prepare the boot option.
>>>> And if we prepare the boot optino, the user can select which memory
>>>> to use as movable memory easily. 
>>>>
>>>>
>>>> [How to use]
>>>> Specify the following boot option:
>>>> movablecore_map=nn[KMG]@ss[KMG]
>>>>
>>>> That means physical address range from ss to ss+nn will be allocated as
>>>> ZONE_MOVABLE.
>>>>
>>>> And the following points should be considered.
>>>>
>>>> 1) If the range is involved in a single node, then from ss to the end of
>>>>    the node will be ZONE_MOVABLE.
>>>> 2) If the range covers two or more nodes, then from ss to the end of
>>>>    the node will be ZONE_MOVABLE, and all the other nodes will only
>>>>    have ZONE_MOVABLE.
>>>> 3) If no range is in the node, then the node will have no ZONE_MOVABLE
>>>>    unless kernelcore or movablecore is specified.
>>>> 4) This option could be specified at most MAX_NUMNODES times.
>>>> 5) If kernelcore or movablecore is also specified, movablecore_map will have
>>>>    higher priority to be satisfied.
>>>> 6) This option has no conflict with memmap option.
>>>>
>>>>
>>>>
>>>> Tang Chen (4):
>>>>   page_alloc: add movable_memmap kernel parameter
>>>>   page_alloc: Introduce zone_movable_limit[] to keep movable limit for
>>>>     nodes
>>>>   page_alloc: Make movablecore_map has higher priority
>>>>   page_alloc: Bootmem limit with movablecore_map
>>>>
>>>> Yasuaki Ishimatsu (1):
>>>>   x86: get pg_data_t's memory from other node
>>>>
>>>>  Documentation/kernel-parameters.txt |   17 +++
>>>>  arch/x86/mm/numa.c                  |   11 ++-
>>>>  include/linux/memblock.h            |    1 +
>>>>  include/linux/mm.h                  |   11 ++
>>>>  mm/memblock.c                       |   15 +++-
>>>>  mm/page_alloc.c                     |  216 ++++++++++++++++++++++++++++++++++-
>>>>  6 files changed, 263 insertions(+), 8 deletions(-)
>>>>
>>>>
>>>> .
>>>>
>>>
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>> 
>> .
>> 
>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
