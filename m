Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 4C0526B0083
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 05:20:31 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [RFC v9 PATCH 00/21] memory-hotplug: hot-remove physical memory
Date: Wed, 5 Sep 2012 17:25:34 +0800
Message-Id: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

From: Wen Congyang <wency@cn.fujitsu.com>

This patch series aims to support physical memory hot-remove.

The patches can free/remove the following things:

  - acpi_memory_info                          : [RFC PATCH 4/19]
  - /sys/firmware/memmap/X/{end, start, type} : [RFC PATCH 8/19]
  - iomem_resource                            : [RFC PATCH 9/19]
  - mem_section and related sysfs files       : [RFC PATCH 10-11, 13-16/19]
  - page table of removed memory              : [RFC PATCH 12/19]
  - node and related sysfs files              : [RFC PATCH 18-19/19]

If you find lack of function for physical memory hot-remove, please let me
know.

How to test this patchset?
1. apply this patchset and build the kernel. MEMORY_HOTPLUG, MEMORY_HOTREMOVE,
   ACPI_HOTPLUG_MEMORY must be selected.
2. load the module acpi_memhotplug
3. hotplug the memory device(it depends on your hardware)
   You will see the memory device under the directory /sys/bus/acpi/devices/.
   Its name is PNP0C80:XX.
4. online/offline pages provided by this memory device
   You can write online/offline to /sys/devices/system/memory/memoryX/state to
   online/offline pages provided by this memory device
5. hotremove the memory device
   You can hotremove the memory device by the hardware, or writing 1 to
   /sys/bus/acpi/devices/PNP0C80:XX/eject.

Note: if the memory provided by the memory device is used by the kernel, it
can't be offlined. It is not a bug.

Known problems:
1. memory can't be offlined when CONFIG_MEMCG is selected.
   For example: there is a memory device on node 1. The address range
   is [1G, 1.5G). You will find 4 new directories memory8, memory9, memory10,
   and memory11 under the directory /sys/devices/system/memory/.
   If CONFIG_MEMCG is selected, we will allocate memory to store page cgroup
   when we online pages. When we online memory8, the memory stored page cgroup
   is not provided by this memory device. But when we online memory9, the memory
   stored page cgroup may be provided by memory8. So we can't offline memory8
   now. We should offline the memory in the reversed order.
   When the memory device is hotremoved, we will auto offline memory provided
   by this memory device. But we don't know which memory is onlined first, so
   offlining memory may fail. In such case, you should offline the memory by
   hand before hotremoving the memory device.
2. hotremoving memory device may cause kernel panicked
   This bug will be fixed by Liu Jiang's patch:
   https://lkml.org/lkml/2012/7/3/1

change log of v9:
 [RFC PATCH v9 8/21]
   * add a lock to protect the list map_entries
   * add an indicator to firmware_map_entry to remember whether the memory
     is allocated from bootmem
 [RFC PATCH v9 10/21]
   * change the macro to inline function
 [RFC PATCH v9 19/21]
   * don't offline the node if the cpu on the node is onlined
 [RFC PATCH v9 21/21]
   * create new patch: auto offline page_cgroup when onlining memory block
     failed

change log of v8:
 [RFC PATCH v8 17/20]
   * Fix problems when one node's range include the other nodes
 [RFC PATCH v8 18/20]
   * fix building error when CONFIG_MEMORY_HOTPLUG_SPARSE or CONFIG_HUGETLBFS
     is not defined.
 [RFC PATCH v8 19/20]
   * don't offline node when some memory sections are not removed
 [RFC PATCH v8 20/20]
   * create new patch: clear hwpoisoned flag when onlining pages

change log of v7:
 [RFC PATCH v7 4/19]
   * do not continue if acpi_memory_device_remove_memory() fails.
 [RFC PATCH v7 15/19]
   * handle usemap in register_page_bootmem_info_section() too.

change log of v6:
 [RFC PATCH v6 12/19]
   * fix building error on other archtitectures than x86

 [RFC PATCH v6 15-16/19]
   * fix building error on other archtitectures than x86

change log of v5:
 * merge the patchset to clear page table and the patchset to hot remove
   memory(from ishimatsu) to one big patchset.

 [RFC PATCH v5 1/19]
   * rename remove_memory() to offline_memory()/offline_pages()

 [RFC PATCH v5 2/19]
   * new patch: implement offline_memory(). This function offlines pages,
     update memory block's state, and notify the userspace that the memory
     block's state is changed.

 [RFC PATCH v5 4/19]
   * offline and remove memory in acpi_memory_disable_device() too.

 [RFC PATCH v5 17/19]
   * new patch: add a new function __remove_zone() to revert the things done
     in the function __add_zone().

 [RFC PATCH v5 18/19]
   * flush work befor reseting node device.

change log of v4:
 * remove "memory-hotplug : unify argument of firmware_map_add_early/hotplug"
   from the patch series, since the patch is a bugfix. It is being disccussed
   on other thread. But for testing the patch series, the patch is needed.
   So I added the patch as [PATCH 0/13].

 [RFC PATCH v4 2/13]
   * check memory is online or not at remove_memory()
   * add memory_add_physaddr_to_nid() to acpi_memory_device_remove() for
     getting node id
 
 [RFC PATCH v4 3/13]
   * create new patch : check memory is online or not at online_pages()

 [RFC PATCH v4 4/13]
   * add __ref section to remove_memory()
   * call firmware_map_remove_entry() before remove_sysfs_fw_map_entry()

 [RFC PATCH v4 11/13]
   * rewrite register_page_bootmem_memmap() for removing page used as PT/PMD

change log of v3:
 * rebase to 3.5.0-rc6

 [RFC PATCH v2 2/13]
   * remove extra kobject_put()

   * The patch was commented by Wen. Wen's comment is
     "acpi_memory_device_remove() should ignore a return value of
     remove_memory() since caller does not care the return value".
     But I did not change it since I think caller should care the
     return value. And I am trying to fix it as follow:

     https://lkml.org/lkml/2012/7/5/624

 [RFC PATCH v2 4/13]
   * remove a firmware_memmap_entry allocated by kzmalloc()

change log of v2:
 [RFC PATCH v2 2/13]
   * check whether memory block is offline or not before calling offline_memory()
   * check whether section is valid or not in is_memblk_offline()
   * call kobject_put() for each memory_block in is_memblk_offline()

 [RFC PATCH v2 3/13]
   * unify the end argument of firmware_map_add_early/hotplug

 [RFC PATCH v2 4/13]
   * add release_firmware_map_entry() for freeing firmware_map_entry

 [RFC PATCH v2 6/13]
  * add release_memory_block() for freeing memory_block

 [RFC PATCH v2 11/13]
  * fix wrong arguments of free_pages()


Wen Congyang (8):
  memory-hotplug: implement offline_memory()
  memory-hotplug: store the node id in acpi_memory_device
  memory-hotplug: export the function acpi_bus_remove()
  memory-hotplug: call acpi_bus_remove() to remove memory device
  memory-hotplug: introduce new function arch_remove_memory()
  memory-hotplug: remove sysfs file of node
  memory-hotplug: clear hwpoisoned flag when onlining pages
  memory-hotplug: auto offline page_cgroup when onlining memory block
    failed

Yasuaki Ishimatsu (13):
  memory-hotplug: rename remove_memory() to
    offline_memory()/offline_pages()
  memory-hotplug: offline and remove memory when removing the memory
    device
  memory-hotplug: check whether memory is present or not
  memory-hotplug: remove /sys/firmware/memmap/X sysfs
  memory-hotplug: does not release memory region in PAGES_PER_SECTION
    chunks
  memory-hotplug: add memory_block_release
  memory-hotplug: remove_memory calls __remove_pages
  memory-hotplug: check page type in get_page_bootmem
  memory-hotplug: move register_page_bootmem_info_node and
    put_page_bootmem for sparse-vmemmap
  memory-hotplug: implement register_page_bootmem_info_section of
    sparse-vmemmap
  memory-hotplug: free memmap of sparse-vmemmap
  memory_hotplug: clear zone when the memory is removed
  memory-hotplug: add node_device_release

 arch/ia64/mm/discontig.c                        |   14 +
 arch/ia64/mm/init.c                             |   16 +
 arch/powerpc/mm/init_64.c                       |   14 +
 arch/powerpc/mm/mem.c                           |   14 +
 arch/powerpc/platforms/pseries/hotplug-memory.c |   16 +-
 arch/s390/mm/init.c                             |   12 +
 arch/s390/mm/vmem.c                             |   14 +
 arch/sh/mm/init.c                               |   15 +
 arch/sparc/mm/init_64.c                         |   14 +
 arch/tile/mm/init.c                             |    8 +
 arch/x86/include/asm/pgtable_types.h            |    1 +
 arch/x86/mm/init_32.c                           |   10 +
 arch/x86/mm/init_64.c                           |  331 ++++++++++++++++++
 arch/x86/mm/pageattr.c                          |   47 ++--
 drivers/acpi/acpi_memhotplug.c                  |   54 +++-
 drivers/acpi/scan.c                             |    3 +-
 drivers/base/memory.c                           |   88 ++++-
 drivers/base/node.c                             |   11 +
 drivers/firmware/memmap.c                       |   98 +++++-
 include/acpi/acpi_bus.h                         |    1 +
 include/linux/firmware-map.h                    |    6 +
 include/linux/memory.h                          |    5 +
 include/linux/memory_hotplug.h                  |   25 +-
 include/linux/mm.h                              |    5 +-
 include/linux/mmzone.h                          |   19 +
 mm/memory_hotplug.c                             |  424 +++++++++++++++++++++--
 mm/page_cgroup.c                                |    3 +
 mm/sparse.c                                     |    5 +-
 28 files changed, 1181 insertions(+), 92 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
