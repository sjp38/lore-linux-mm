Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 5A47E6B003B
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 05:37:19 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 00/11] Introduce movablemem_map=acpi boot option.
Date: Fri, 5 Apr 2013 17:39:50 +0800
Message-Id: <1365154801-473-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rob@landley.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, akpm@linux-foundation.org, wency@cn.fujitsu.com, trenn@suse.de, liwanp@linux.vnet.ibm.com, mgorman@suse.de, walken@google.com, riel@redhat.com, khlebnikov@openvz.org, tj@kernel.org, minchan@kernel.org, m.szyprowski@samsung.com, mina86@mina86.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, linfeng@cn.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, jiang.liu@huawei.com, guz.fnst@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Before this patch-set, we introduced movablemem_map boot option which allowed
users to specify physical address ranges to set memory as movable. This is not
user friendly enough for normal users.

So now, we introduce just movablemem_map=acpi to allow users to enable/disable
the kernel to use Hot Pluggable bit in SRAT to determine which memory ranges are
hotpluggable, and set them as ZONE_MOVABLE.

This patch-set is based on Yinghai's patch-set:
v1: https://lkml.org/lkml/2013/3/7/642
v2: https://lkml.org/lkml/2013/3/10/47

So it supports to allocate pagetable pages in local nodes.

We also split the large patch-set into smaller ones, and it seems easier to review.


========================================================================
[What we are doing]
This patchset introduces a boot option for users to specify ZONE_MOVABLE
memory map for each node in the system. Users can use it in two ways:

1. movablecore_map=acpi
   In this way, the kernel will use Hot Pluggable bit in SRAT to determine
   ZONE_MOVABLE for each node. All the ranges user has specified will be
   ignored.


[Why we do this]
If we hot remove a memroy device, it cannot have kernel memory,
because Linux cannot migrate kernel memory currently. Therefore,
we have to guarantee that the hot removed memory has only movable
memoroy.
(Here is an exception: When we implement the node hotplug functionality,
for those kernel memory whose life cycle is the same as the node, such as
pagetables, vmemmap and so on, although the kernel cannot migrate them,
we can still put them on local node because we can free them before we
hot-remove the node. This is not completely implemented yet.)

Linux has two boot options, kernelcore= and movablecore=, for
creating movable memory. These boot options can specify the amount
of memory use as kernel or movable memory. Using them, we can
create ZONE_MOVABLE which has only movable memory.
(NOTE: doing this will cause NUMA performance because the kernel won't
 be able to distribute kernel memory evenly to each node.)

But it does not fulfill a requirement of memory hot remove, because
even if we specify the boot options, movable memory is distributed
in each node evenly. So when we want to hot remove memory which
memory range is 0x80000000-0c0000000, we have no way to specify
the memory as movable memory.

Furthermore, even if we can use SRAT, users still need an interface
to enable/disable this functionality if they don't want to lose their
NUMA performance.  So I think, a user interface is always needed.

So we proposed this new feature which enable/disable the kernel to set
hotpluggable memory as ZONE_MOVABLE.


[Ways to do this]
There may be 2 ways to specify movable memory.
1. use firmware information
2. use boot option

1. use firmware information
  According to ACPI spec 5.0, SRAT table has memory affinity structure
  and the structure has Hot Pluggable Filed. See "5.2.16.2 Memory
  Affinity Structure". If we use the information, we might be able to
  specify movable memory by firmware. For example, if Hot Pluggable
  Filed is enabled, Linux sets the memory as movable memory.

2. use boot option
  This is our proposal. New boot option can specify memory range to use
  as movable memory.


[How we do this]
We now propose a boot option, but support the first way above. A boot option
is always needed because set memory as movable will cause NUMA performance
down. So at least, we need an interface to enable/disable it so that users
who don't want to use memory hotplug functionality will also be happy.


[How to use]
Specify movablemem_map=acpi in kernel commandline:
         *
         * SRAT:                |_____| |_____| |_________| |_________| ......
         * node id:                0       1         1           2
         * hotpluggable:           n       y         y           n
         * ZONE_MOVABLE:                |_____| |_________|
         *
   NOTE: 1) Before parsing SRAT, memblock has already reserve some memory ranges
            for other purposes, such as for kernel image. We cannot prevent
            kernel from using these memory, so we need to exclude these memory
            even if it is hotpluggable.
            Furthermore, to ensure the kernel has enough memory to boot, we make
            all the memory on the node which the kernel resides in should be
            un-hotpluggable.
         2) In this case, all the user specified memory ranges will be ingored.

We also need to consider the following points:
1) Using this boot option could cause NUMA performance down because the kernel
   memory will not be distributed on each node evenly. So for users who don't
   want to lose their NUMA performance, just don't use it.
2) If kernelcore or movablecore is also specified, movablecore_map will have
   higher priority to be satisfied.
3) This option has no conflict with memmap option.

Tane Chen (10):
  acpi: Print hotplug info in SRAT.
  numa, acpi, memory-hotplug: Add movablemem_map=acpi boot option.
  x86, numa, acpi, memory-hotplug: Introduce hotplug info into struct
    numa_meminfo.
  x86, numa, acpi, memory-hotplug: Consider hotplug info when cleanup
    numa_meminfo.
  X86, numa, acpi, memory-hotplug: Add hotpluggable ranges to
    movablemem_map.
  x86, numa, acpi, memory-hotplug: Make any node which the kernel
    resides in un-hotpluggable.
  x86, numa, acpi, memory-hotplug: Introduce zone_movable_limit[] to
    store start pfn of ZONE_MOVABLE.
  x86, numa, acpi, memory-hotplug: Sanitize zone_movable_limit[].
  x86, numa, acpi, memory-hotplug: make movablemem_map have higher
    priority
  x86, numa, acpi, memory-hotplug: Memblock limit with movablemem_map

Yasuaki Ishimatsu (1):
  x86: get pg_data_t's memory from other node

 Documentation/kernel-parameters.txt |   11 ++
 arch/x86/include/asm/numa.h         |    3 +-
 arch/x86/kernel/apic/numaq_32.c     |    2 +-
 arch/x86/mm/amdtopology.c           |    3 +-
 arch/x86/mm/numa.c                  |   92 ++++++++++++++--
 arch/x86/mm/numa_internal.h         |    1 +
 arch/x86/mm/srat.c                  |   28 ++++-
 include/linux/memblock.h            |    2 +
 include/linux/mm.h                  |   19 +++
 mm/memblock.c                       |   50 ++++++++
 mm/page_alloc.c                     |  210 ++++++++++++++++++++++++++++++++++-
 11 files changed, 399 insertions(+), 22 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
