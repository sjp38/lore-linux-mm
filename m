Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 44FCD6B0006
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 05:18:22 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [RESEND PATCH part1 0/9] Introduce movablemem_map boot option.
Date: Thu, 21 Mar 2013 17:20:46 +0800
Message-Id: <1363857655-30658-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rob@landley.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, akpm@linux-foundation.org, wency@cn.fujitsu.com, trenn@suse.de, liwanp@linux.vnet.ibm.com, mgorman@suse.de, walken@google.com, riel@redhat.com, khlebnikov@openvz.org, tj@kernel.org, minchan@kernel.org, m.szyprowski@samsung.com, mina86@mina86.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, kosaki.motohiro@jp.fujitsu.com, guz.fnst@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch-set introduces a new boot option "movablemem_map".

The functionality will be posted in two parts:
part1: Implement movablemem_map logic.
       In this part, pagetable and vmemmap are not allowed to be allocated
       on local node.
part2: Support allocating pagetable and vmemmap on local node.
       But introduced a new "bool hotpluggable" member into struct numa_memblk.
       This part needs some more review and comment.

This two patch-set are based on Yinghai's tree:
git://git.kernel.org/pub/scm/linux/kernel/git/yinghai/linux-yinghai.git for-x86-mm

For main line, we need to apply Yinghai's
"x86, ACPI, numa: Parse numa info early" patch-set first.
Please refer to:
v1: https://lkml.org/lkml/2013/3/7/642
v2: https://lkml.org/lkml/2013/3/10/47

===================================
[What we are doing]
This patchset introduces a boot option for user to specify ZONE_MOVABLE
memory map for each node in the system. Users can use it in two ways:

1. movablecore_map=nn[KMG]@ss[KMG]
   In this way, the kernel will make sure memory range from ss to ss+nn is
   on ZONE_MOVABLE. The hotplug info provided by SRAT will be ignored.

2. movablecore_map=acpi
   In this way, the kernel will use memory hotplug info in SRAT to determine
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
hot-remove the node. This is not implemented yet.)

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

So we proposed this new feature which specifies memory range to use as
movable memory.


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
We chose second way, because if we use first way, users cannot change
memory range to use as movable memory easily. We think if we create
movable memory, performance regression may occur by NUMA. In this case,
user can turn off the feature easily if we prepare the boot option.
And if we prepare the boot optino, the user can select which memory
to use as movable memory easily. 


[How to use]
1. For movablecore_map=nn[KMG]@ss[KMG]:
         *
         * SRAT:                |_____| |_____| |_________| |_________| ......
         * node id:                0       1         1           2
         * user specified:                |__|                 |___|
         * ZONE_MOVABLE:                  |___| |_________|    |______| ......
         *
   NOTE: 1) User can specify this option more than once, but at most MAX_NUMNODES
            times. The extra options will be ignored.
         2) In this case, SRAT info will be ingored.

2. For movablemem_map=acpi:
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


Tang Chen (8):
  acpi: Print hotplug info in SRAT.
  x86, mm, numa, acpi: Add movable_memmap boot option.
  x86, mm, numa, acpi: Introduce zone_movable_limit[] to store start
    pfn of ZONE_MOVABLE.
  x86, mm, numa, acpi: Extend movablemem_map to the end of each node.
  x86, mm, numa, acpi: Support getting hotplug info from SRAT.
  x86, mm, numa, acpi: Sanitize zone_movable_limit[].
  x86, mm, numa, acpi: make movablemem_map have higher priority
  x86, mm, numa, acpi: Memblock limit with movablemem_map

Yasuaki Ishimatsu (1):
  x86: get pg_data_t's memory from other node

 Documentation/kernel-parameters.txt |   36 +++++
 arch/x86/mm/numa.c                  |    5 +-
 arch/x86/mm/srat.c                  |  130 +++++++++++++++++-
 include/linux/memblock.h            |    2 +
 include/linux/mm.h                  |   22 +++
 mm/memblock.c                       |   50 +++++++
 mm/page_alloc.c                     |  265 ++++++++++++++++++++++++++++++++++-
 7 files changed, 500 insertions(+), 10 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
