Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 675046B0075
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 04:58:18 -0500 (EST)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [Patch v4 00/12] memory-hotplug: hot-remove physical memory
Date: Tue, 27 Nov 2012 18:00:10 +0800
Message-Id: <1354010422-19648-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, benh@kernel.crashing.org, paulus@samba.org, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Jianguo Wu <wujianguo@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>

The patch-set was divided from following thread's patch-set.
    https://lkml.org/lkml/2012/9/5/201

The last version of this patchset:
    https://lkml.org/lkml/2012/11/1/93

If you want to know the reason, please read following thread.

https://lkml.org/lkml/2012/10/2/83

The patch-set has only the function of kernel core side for physical
memory hot remove. So if you use the patch, please apply following
patches.

- bug fix for memory hot remove
  https://lkml.org/lkml/2012/10/31/269
  
- acpi framework
  https://lkml.org/lkml/2012/10/26/175

The patches can free/remove the following things:

  - /sys/firmware/memmap/X/{end, start, type} : [PATCH 2/10]
  - mem_section and related sysfs files       : [PATCH 3-4/10]
  - memmap of sparse-vmemmap                  : [PATCH 5-7/10]
  - page table of removed memory              : [RFC PATCH 8/10]
  - node and related sysfs files              : [RFC PATCH 9-10/10]

* [PATCH 2/10] checks whether the memory can be removed or not.

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
1. hotremoving memory device may cause kernel panicked
   This bug will be fixed by Liu Jiang's patch:
   https://lkml.org/lkml/2012/7/3/1

Changelogs from v3 to v4:
 Patch7: remove unused codes.
 Patch8: fix nr_pages that is passed to free_map_bootmem()

Changelogs from v2 to v3:
 Patch9: call sync_global_pgds() if pgd is changed
 Patch10: fix a problem int the patch

Changelogs from v1 to v2:
 Patch1: new patch, offline memory twice. 1st iterate: offline every non primary
         memory block. 2nd iterate: offline primary (i.e. first added) memory
         block.

 Patch3: new patch, no logical change, just remove reduntant codes.

 Patch9: merge the patch from wujianguo into this patch. flush tlb on all cpu
         after the pagetable is changed.

 Patch12: new patch, free node_data when a node is offlined

Wen Congyang (6):
  memory-hotplug: try to offline the memory twice to avoid dependence
  memory-hotplug: remove redundant codes
  memory-hotplug: introduce new function arch_remove_memory() for
    removing page table depends on architecture
  memory-hotplug: remove page table of x86_64 architecture
  memory-hotplug: remove sysfs file of node
  memory-hotplug: free node_data when a node is offlined

Yasuaki Ishimatsu (6):
  memory-hotplug: check whether all memory blocks are offlined or not
    when removing memory
  memory-hotplug: remove /sys/firmware/memmap/X sysfs
  memory-hotplug: unregister memory section on SPARSEMEM_VMEMMAP
  memory-hotplug: implement register_page_bootmem_info_section of
    sparse-vmemmap
  memory-hotplug: remove memmap of sparse-vmemmap
  memory-hotplug: memory_hotplug: clear zone when removing the memory

 arch/ia64/mm/discontig.c             |  14 ++
 arch/ia64/mm/init.c                  |  18 ++
 arch/powerpc/mm/init_64.c            |  14 ++
 arch/powerpc/mm/mem.c                |  12 +
 arch/s390/mm/init.c                  |  12 +
 arch/s390/mm/vmem.c                  |  14 ++
 arch/sh/mm/init.c                    |  17 ++
 arch/sparc/mm/init_64.c              |  14 ++
 arch/tile/mm/init.c                  |   8 +
 arch/x86/include/asm/pgtable_types.h |   1 +
 arch/x86/mm/init_32.c                |  12 +
 arch/x86/mm/init_64.c                | 417 +++++++++++++++++++++++++++++++++++
 arch/x86/mm/pageattr.c               |  47 ++--
 drivers/acpi/acpi_memhotplug.c       |   8 +-
 drivers/base/memory.c                |   6 +
 drivers/firmware/memmap.c            |  98 +++++++-
 include/linux/firmware-map.h         |   6 +
 include/linux/memory_hotplug.h       |  15 +-
 include/linux/mm.h                   |   5 +-
 mm/memory_hotplug.c                  | 405 ++++++++++++++++++++++++++++++++--
 mm/sparse.c                          |  19 +-
 21 files changed, 1098 insertions(+), 64 deletions(-)

-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
