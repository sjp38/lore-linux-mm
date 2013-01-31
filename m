Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id B548F6B0007
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 20:22:33 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id un15so1304833pbc.10
        for <linux-mm@kvack.org>; Wed, 30 Jan 2013 17:22:33 -0800 (PST)
Message-ID: <1359595344.1557.13.camel@kernel>
Subject: Re: [PATCH v6 00/15] memory-hotplug: hot-remove physical memory
From: Simon Jeons <simon.jeons@gmail.com>
Date: Wed, 30 Jan 2013 19:22:24 -0600
In-Reply-To: <5108F2B3.3090506@cn.fujitsu.com>
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
	 <1359463973.1624.15.camel@kernel> <5108F2B3.3090506@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

Hi Tang,
On Wed, 2013-01-30 at 18:15 +0800, Tang Chen wrote:
> Hi Simon,
> 
> Please see below. :)
> 
> On 01/29/2013 08:52 PM, Simon Jeons wrote:
> > Hi Tang,
> >
> > On Wed, 2013-01-09 at 17:32 +0800, Tang Chen wrote:
> >> Here is the physical memory hot-remove patch-set based on 3.8rc-2.
> >
> > Some questions ask you, not has relationship with this patchset, but is
> > memory hotplug stuff.
> >
> > 1. In function node_states_check_changes_online:
> >
> > comments:
> > * If we don't have HIGHMEM nor movable node,
> > * node_states[N_NORMAL_MEMORY] contains nodes which have zones of
> > * 0...ZONE_MOVABLE, set zone_last to ZONE_MOVABLE.
> >
> > How to understand it? Why we don't have HIGHMEM nor movable node and
> > node_staes[N_NORMAL_MEMORY] contains 0...ZONE_MOVABLE, IIUC,
> > N_NORMAL_MEMORY only means the node has regular memory.
> >
> 
> First of all, I think we need to understand why we need N_MEMORY.
> 
> In order to support movable node, which has only ZONE_MOVABLE (the last 
> zone),
> we introduce N_MEMORY to represent the node has normal, highmem and 
> movable memory.
> 
> Here, "we have movable node" means you configured CONFIG_MOVABLE_NODE.
> This config option doesn't mean we don't have movable pages, (NO)
> it means we don't have a node which has only movable pages (only have 
> ZONE_MOVABLE). (YES)
> 
> Here, if we don't have CONFIG_MOVABLE_NODE (we don't have movable node), 
> we don't need a
> separate node_states[] element to represent a particular node because we 
> won't have a node
> which has only ZONE_MOVABLE.
> 
> So,
> 1) if we don't have highmem nor movable node, N_MEMORY == N_HIGH_MEMORY 
> == N_NORMAL_MEMORY,
>     which means N_NORMAL_MEMORY effects as N_MEMORY. If we online pages 
> as movable, we need
>     to update node_states[N_NORMAL_MEMORY].

Sorry, I still confuse. :( 
update node_states[N_NORMAL_MEMORY] to node_states[N_MEMORY] or
node_states[N_NORMAL_MEMOR] present 0...ZONE_MOVABLE?

> 
> Please refer to the definition of enum zone_type, if we don't have 
> CONFIG_HIGHMEM, we won't
> have ZONE_HIGHMEM, but ZONE_NORMAL and ZONE_MOVABLE will always there. 
> So we can have movable
> pages, and the zone_last should be ZONE_MOVABLE.

node_states is what? node_states[N_NORMAL_MEMOR] or
node_states[N_MEMORY]?

> 
> Again, because we won't have a node only having ZONE_MOVABLE, so we just 
> need to update
> node_states[N_NORMAL_MEMORY].
> 
> > * If we don't have movable node, node_states[N_NORMAL_MEMORY]
> > * contains nodes which have zones of 0...ZONE_MOVABLE,
> > * set zone_last to ZONE_MOVABLE.
> >
> > How to understand?
> 
> 2) this code is in #ifdef CONFIG_HIGHMEM, which means we have highmem, 
> so if we don't have
>     movable node, N_MEMORY == N_HIGH_MEMORY, and N_HIGH_MEMORY effects 
> as N_MEMORY. If we
>     online pages as movable, we need to update node_states[N_NORMAL_MEMORY].
> 
> >
> > 2. In function move_pfn_range_left, why end<= z2->zone_start_pfn is not
> > correct? The comments said that must include/overlap, why?
> >
> 
> This one is easy, if I understand you correctly.
> move_pfn_range_left() is used to move the left most part [start_pfn, 
> end_pfn) of z2 to z1.
> So if end_pfn<= z2->zone_start_pfn, it means [start_pfn, end_pfn) is not 
> part of z2.
> Then it fails.

Yup, very clear now. :)
Why check !z1->wait_table in function move_pfn_range_left and function
__add_zone? I think zone->wait_table is initialized in
free_area_init_core, which will be called during system initialization
and hotadd_new_pgdat path.

> 
> > 3. In function online_pages, the normal case(w/o online_kenrel,
> > online_movable), why not check if the new zone is overlap with adjacent
> > zones?
> >
> 
> Can a zone overlap with the others ? I don't think so.
> 
> One pfn could only be in one zone,
>     zone = page_zone(pfn_to_page(pfn));

thanks. :)

There is a zone populated check in function online_pages. But zone is
populated in free_area_init_core which will be called during system
initialization and hotadd_new_pgdat path. Why still need this check?

> 
> it could overlap with others, I think. :)
> 
> But maybe I misunderstand you. :)
> 
> > 4. Could you summarize the difference implementation between hot-add and
> > logic-add, hot-remove and logic-remove?
> 
> Sorry, I don't quite understand what do you mean by logic-add/remove.
> Would you please explain more ?
> 
> If you meant the sys fs interfaces, I think they are just another set of 
> entrances
> of memory hotplug.

Please ingore this silly question. :(

> 
> Thanks.  :)
> 
> >
> >
> >>
> >> This patch-set aims to implement physical memory hot-removing.
> >>
> >> The patches can free/remove the following things:
> >>
> >>    - /sys/firmware/memmap/X/{end, start, type} : [PATCH 4/15]
> >>    - memmap of sparse-vmemmap                  : [PATCH 6,7,8,10/15]
> >>    - page table of removed memory              : [RFC PATCH 7,8,10/15]
> >>    - node and related sysfs files              : [RFC PATCH 13-15/15]
> >>
> >>
> >> Existing problem:
> >> If CONFIG_MEMCG is selected, we will allocate memory to store page cgroup
> >> when we online pages.
> >>
> >> For example: there is a memory device on node 1. The address range
> >> is [1G, 1.5G). You will find 4 new directories memory8, memory9, memory10,
> >> and memory11 under the directory /sys/devices/system/memory/.
> >>
> >> If CONFIG_MEMCG is selected, when we online memory8, the memory stored page
> >> cgroup is not provided by this memory device. But when we online memory9, the
> >> memory stored page cgroup may be provided by memory8. So we can't offline
> >> memory8 now. We should offline the memory in the reversed order.
> >>
> >> When the memory device is hotremoved, we will auto offline memory provided
> >> by this memory device. But we don't know which memory is onlined first, so
> >> offlining memory may fail.
> >>
> >> In patch1, we provide a solution which is not good enough:
> >> Iterate twice to offline the memory.
> >> 1st iterate: offline every non primary memory block.
> >> 2nd iterate: offline primary (i.e. first added) memory block.
> >>
> >> And a new idea from Wen Congyang<wency@cn.fujitsu.com>  is:
> >> allocate the memory from the memory block they are describing.
> >>
> >> But we are not sure if it is OK to do so because there is not existing API
> >> to do so, and we need to move page_cgroup memory allocation from MEM_GOING_ONLINE
> >> to MEM_ONLINE. And also, it may interfere the hugepage.
> >>
> >>
> >>
> >> How to test this patchset?
> >> 1. apply this patchset and build the kernel. MEMORY_HOTPLUG, MEMORY_HOTREMOVE,
> >>     ACPI_HOTPLUG_MEMORY must be selected.
> >> 2. load the module acpi_memhotplug
> >> 3. hotplug the memory device(it depends on your hardware)
> >>     You will see the memory device under the directory /sys/bus/acpi/devices/.
> >>     Its name is PNP0C80:XX.
> >> 4. online/offline pages provided by this memory device
> >>     You can write online/offline to /sys/devices/system/memory/memoryX/state to
> >>     online/offline pages provided by this memory device
> >> 5. hotremove the memory device
> >>     You can hotremove the memory device by the hardware, or writing 1 to
> >>     /sys/bus/acpi/devices/PNP0C80:XX/eject.
> >
> > Is there a similar knode to hot-add the memory device?
> >
> >>
> >>
> >> Note: if the memory provided by the memory device is used by the kernel, it
> >> can't be offlined. It is not a bug.
> >>
> >>
> >> Changelogs from v5 to v6:
> >>   Patch3: Add some more comments to explain memory hot-remove.
> >>   Patch4: Remove bootmem member in struct firmware_map_entry.
> >>   Patch6: Repeatedly register bootmem pages when using hugepage.
> >>   Patch8: Repeatedly free bootmem pages when using hugepage.
> >>   Patch14: Don't free pgdat when offlining a node, just reset it to 0.
> >>   Patch15: New patch, pgdat is not freed in patch14, so don't allocate a new
> >>            one when online a node.
> >>
> >> Changelogs from v4 to v5:
> >>   Patch7: new patch, move pgdat_resize_lock into sparse_remove_one_section() to
> >>           avoid disabling irq because we need flush tlb when free pagetables.
> >>   Patch8: new patch, pick up some common APIs that are used to free direct mapping
> >>           and vmemmap pagetables.
> >>   Patch9: free direct mapping pagetables on x86_64 arch.
> >>   Patch10: free vmemmap pagetables.
> >>   Patch11: since freeing memmap with vmemmap has been implemented, the config
> >>            macro CONFIG_SPARSEMEM_VMEMMAP when defining __remove_section() is
> >>            no longer needed.
> >>   Patch13: no need to modify acpi_memory_disable_device() since it was removed,
> >>            and add nid parameter when calling remove_memory().
> >>
> >> Changelogs from v3 to v4:
> >>   Patch7: remove unused codes.
> >>   Patch8: fix nr_pages that is passed to free_map_bootmem()
> >>
> >> Changelogs from v2 to v3:
> >>   Patch9: call sync_global_pgds() if pgd is changed
> >>   Patch10: fix a problem int the patch
> >>
> >> Changelogs from v1 to v2:
> >>   Patch1: new patch, offline memory twice. 1st iterate: offline every non primary
> >>           memory block. 2nd iterate: offline primary (i.e. first added) memory
> >>           block.
> >>
> >>   Patch3: new patch, no logical change, just remove reduntant codes.
> >>
> >>   Patch9: merge the patch from wujianguo into this patch. flush tlb on all cpu
> >>           after the pagetable is changed.
> >>
> >>   Patch12: new patch, free node_data when a node is offlined.
> >>
> >>
> >> Tang Chen (6):
> >>    memory-hotplug: move pgdat_resize_lock into
> >>      sparse_remove_one_section()
> >>    memory-hotplug: remove page table of x86_64 architecture
> >>    memory-hotplug: remove memmap of sparse-vmemmap
> >>    memory-hotplug: Integrated __remove_section() of
> >>      CONFIG_SPARSEMEM_VMEMMAP.
> >>    memory-hotplug: remove sysfs file of node
> >>    memory-hotplug: Do not allocate pdgat if it was not freed when
> >>      offline.
> >>
> >> Wen Congyang (5):
> >>    memory-hotplug: try to offline the memory twice to avoid dependence
> >>    memory-hotplug: remove redundant codes
> >>    memory-hotplug: introduce new function arch_remove_memory() for
> >>      removing page table depends on architecture
> >>    memory-hotplug: Common APIs to support page tables hot-remove
> >>    memory-hotplug: free node_data when a node is offlined
> >>
> >> Yasuaki Ishimatsu (4):
> >>    memory-hotplug: check whether all memory blocks are offlined or not
> >>      when removing memory
> >>    memory-hotplug: remove /sys/firmware/memmap/X sysfs
> >>    memory-hotplug: implement register_page_bootmem_info_section of
> >>      sparse-vmemmap
> >>    memory-hotplug: memory_hotplug: clear zone when removing the memory
> >>
> >>   arch/arm64/mm/mmu.c                  |    3 +
> >>   arch/ia64/mm/discontig.c             |   10 +
> >>   arch/ia64/mm/init.c                  |   18 ++
> >>   arch/powerpc/mm/init_64.c            |   10 +
> >>   arch/powerpc/mm/mem.c                |   12 +
> >>   arch/s390/mm/init.c                  |   12 +
> >>   arch/s390/mm/vmem.c                  |   10 +
> >>   arch/sh/mm/init.c                    |   17 ++
> >>   arch/sparc/mm/init_64.c              |   10 +
> >>   arch/tile/mm/init.c                  |    8 +
> >>   arch/x86/include/asm/pgtable_types.h |    1 +
> >>   arch/x86/mm/init_32.c                |   12 +
> >>   arch/x86/mm/init_64.c                |  390 +++++++++++++++++++++++++++++
> >>   arch/x86/mm/pageattr.c               |   47 ++--
> >>   drivers/acpi/acpi_memhotplug.c       |    8 +-
> >>   drivers/base/memory.c                |    6 +
> >>   drivers/firmware/memmap.c            |   96 +++++++-
> >>   include/linux/bootmem.h              |    1 +
> >>   include/linux/firmware-map.h         |    6 +
> >>   include/linux/memory_hotplug.h       |   15 +-
> >>   include/linux/mm.h                   |    4 +-
> >>   mm/memory_hotplug.c                  |  459 +++++++++++++++++++++++++++++++---
> >>   mm/sparse.c                          |    8 +-
> >>   23 files changed, 1094 insertions(+), 69 deletions(-)
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>
> >
> >
> >


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
