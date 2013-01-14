Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 738526B006E
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 04:16:11 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v5 0/5] Add movablecore_map boot option
Date: Mon, 14 Jan 2013 17:15:20 +0800
Message-Id: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Andrew, all,

Here is movablecore_map patch-set based on 3.8-rc3.

During the implementation of SRAT support, we met a problem.
In setup_arch(), we have the following call series:

1) memblock is ready;
2) some functions use memblock to allocate memory;
3) parse ACPI tables, such as SRAT.

Before 3), we don't know which memory is hotpluggable, and as a result, we cannot
prevent memblock from allocating hotpluggable memory. So, in 2), there could be
some hotpluggable memory allocated by memblock.

Now, we are trying to parse SRAT earlier, before memblock is ready. But I think we
need more investigation on this topic. So in this v5, I dropped all the SRAT
support, and v5 is just the same as v3, and it is based on 3.8-rc3.

As we planned, we will support getting info from SRAT without users' participation
at last. And we will post another patch-set to do so.


And also, I think for now, we can add this boot option as the first step of
supporting movable node. Since Linux cannot migrate the direct mapped pages,
the only way for now is to limit the whole node containing only movable memory.

Using SRAT is one way. But even if we can use SRAT, users still need an interface
to enable/disable this functionality if they don't want to loose their NUMA performance.

So I think, an user interface is always needed.

For now, users can disable this functionality by not specifying the boot option.
Later, we will post SRAT support, and add another option value "movablecore_map=acpi"
to using SRAT.

Thanks. :)

============================


[What we are doing]
This patchset provide a boot option for user to specify ZONE_MOVABLE memory
map for each node in the system.

movablecore_map=nn[KMG]@ss[KMG]

This option make sure memory range from ss to ss+nn is movable memory.


[Why we do this]
If we hot remove a memroy, the memory cannot have kernel memory,
because Linux cannot migrate kernel memory currently. Therefore,
we have to guarantee that the hot removed memory has only movable
memoroy.

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
We chose second way, because if we use first way, users cannot change
memory range to use as movable memory easily. We think if we create
movable memory, performance regression may occur by NUMA. In this case,
user can turn off the feature easily if we prepare the boot option.
And if we prepare the boot optino, the user can select which memory
to use as movable memory easily. 


[How to use]
Specify the following boot option:
movablecore_map=nn[KMG]@ss[KMG]

That means physical address range from ss to ss+nn will be allocated as
ZONE_MOVABLE.

And the following points should be considered.

1) If the range is involved in a single node, then from ss to the end of
   the node will be ZONE_MOVABLE.
2) If the range covers two or more nodes, then from ss to the end of
   the node will be ZONE_MOVABLE, and all the other nodes will only
   have ZONE_MOVABLE.
3) If no range is in the node, then the node will have no ZONE_MOVABLE
   unless kernelcore or movablecore is specified.
4) This option could be specified at most MAX_NUMNODES times.
5) If kernelcore or movablecore is also specified, movablecore_map will have
   higher priority to be satisfied.
6) This option has no conflict with memmap option.



Change log:

v4 -> v5:
1) remove all SRAT support. v5 is now the same as v3.

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


Tang Chen (4):
  page_alloc: add movable_memmap kernel parameter
  page_alloc: Introduce zone_movable_limit[] to keep movable limit for
    nodes
  page_alloc: Make movablecore_map has higher priority
  page_alloc: Bootmem limit with movablecore_map

Yasuaki Ishimatsu (1):
  x86: get pg_data_t's memory from other node

 Documentation/kernel-parameters.txt |   17 +++
 arch/x86/mm/numa.c                  |    5 +-
 include/linux/memblock.h            |    1 +
 include/linux/mm.h                  |   11 ++
 mm/memblock.c                       |   18 +++-
 mm/page_alloc.c                     |  233 ++++++++++++++++++++++++++++++++++-
 6 files changed, 277 insertions(+), 8 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
