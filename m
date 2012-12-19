Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 00F876B002B
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 03:16:06 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v4 0/6] Add movablecore_map boot option with SRAT support.
Date: Wed, 19 Dec 2012 16:14:57 +0800
Message-Id: <1355904903-22699-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, akpm@linux-foundation.org, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

[What we are doing]
This patchset provide a boot option for user to specify ZONE_MOVABLE memory
map for each node in the system.

movablecore_map=nn[KMG]@ss[KMG] or movablecore_map=acpi

movablecore_map=nn[KMG]@ss[KMG]:
This option makes sure memory range from ss to ss+nn is movable memory.

movablecore_map=acpi:
This option informs the kernel to use Hot Pluggable bit in SRAT from ACPI BIOS
to determine which memory device could be hotplugged. Users don't need to
take part in.


[Why we do this]
If we hot remove a memroy, the memory cannot have kernel memory,
because Linux cannot migrate kernel memory currently. Therefore,
we have to guarantee that the hot removed memory has only movable
memory.

Linux has two boot options, kernelcore= and movablecore=, for
creating movable memory. These boot options can specify the amount
of memory use as kernel or movable memory. Using them, we can
create ZONE_MOVABLE which has only movable memory.

But it does not fulfill a requirement of memory hot remove, because
even if we specify the boot options, movable memory is distributed
in each node evenly. So when we want to hot remove memory which
memory range is 0x80000000-0c0000000, we have no way to specify
the memory as movable memory.

So we proposed a new feature which specifies memory range to use as
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
We chose second way at first, because if we use first way, users cannot change
memory range to use as movable memory easily. We think if we create
movable memory, performance regression may occur by NUMA. In this case,
user can turn off the feature easily if we prepare the boot option.
And if we prepare the boot optino, the user can select which memory
to use as movable memory easily.

And from v4, we also support the first way, using Hot Pluggable bit.


[How to use]
Specify the following boot option:
movablecore_map=nn[KMG]@ss[KMG] or movablecore_map=acpi.

1. If user want to specify hotpluggable memory ranges by himself, then specify
   as the following:
        movablecore_map=nn[KMG]@ss[KMG]
   In this way, the kernel will check if the ranges are hotpluggable with info
   from SRAT from ACPI BIOS.
   - If a range is hotpluggable, then from ss to the end of the corresponding
     node will be ZONE_MOVABLE.
   - If a range is not hotpluggable, then the range will be ignored.

2. If user want to leave the configuration work to the kernel, then specify
   as the following:
        movablecore_map=acpi
   In this way, the kernel will get hotplug info from SRAT in ACPI BIOS, and
   auto decide which memory devices could be hotplugged. And all the memory
   on these devices will be in ZONE_MOVABLE.

3. If user didn't specify this option, then the kernel will use all the
   memory on all the nodes evenly. And there is no performance drawback.

And the following points should be considered.

1) If the range is involved in a single node, then from ss to the end of
   the node will be ZONE_MOVABLE.
2) If the range covers two or more nodes, then from ss to the end of
   the 1st node will be ZONE_MOVABLE, and all the other nodes will only
   have ZONE_MOVABLE.
3) If no range is in the node, then the node will have no ZONE_MOVABLE
   unless kernelcore or movablecore is specified.
4) This option could be specified at most MAX_NUMNODES times.
5) If kernelcore or movablecore is also specified, movablecore_map will have
   higher priority to be satisfied.
6) This option has no conflict with memmap option.


Change log:

v3 -> v4:
1) patch2: Add new function remove_movablecore_map() to remove a range from
           movablecore_map.map[].
2) patch2: Add movablecore_map=acpi logic to allow user to skip the physical
           address config. If this option is specified, movablecore_map.map[]
           will be clear at first, and add all the hotpluggable memory ranges
           into it when parsing SRAT.
3) patch3: New patch, add logic to check the Hot Pluggable bit when parsing SRAT.
           If user also specifies a memory range, the logic will check if it is
           hotpluggable and remove it from movablecore_map.map[] if not.

v2 -> v3:
1) Use memblock_alloc_try_nid() instead of memblock_alloc_nid() to allocate
   memory twice if a whole node is ZONE_MOVABLE.
2) Add DMA, DMA32 addresses check, make sure ZONE_MOVABLE won't use these addresses.
   Suggested by Wu Jianguo <wujianguo@huawei.com>
3) Add lowmem addresses check, when the system has highmem, make sure ZONE_MOVABLE
   won't use lowmem. Suggested by Liu Jiang <jiang.liu@huawei.com>
4) Fix misuse of pfns in movablecore_map.map[] as physical addresses.



Tang Chen (5):
  page_alloc: add movablecore_map kernel parameter
  ACPI: Restructure movablecore_map with memory info from SRAT.
  page_alloc: Introduce zone_movable_limit[] to keep movable limit for
    nodes
  page_alloc: Make movablecore_map has higher priority
  page_alloc: Bootmem limit with movablecore_map

Yasuaki Ishimatsu (1):
  x86: get pg_data_t's memory from other node

 Documentation/kernel-parameters.txt |   29 ++++
 arch/x86/mm/numa.c                  |    5 +-
 arch/x86/mm/srat.c                  |   38 ++++-
 include/linux/memblock.h            |    1 +
 include/linux/mm.h                  |   17 ++
 mm/memblock.c                       |   18 ++-
 mm/page_alloc.c                     |  318 ++++++++++++++++++++++++++++++++++-
 7 files changed, 415 insertions(+), 11 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
