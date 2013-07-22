Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 693EE6B0032
	for <linux-mm@kvack.org>; Sun, 21 Jul 2013 22:45:37 -0400 (EDT)
Message-ID: <51EC9D6F.9010807@cn.fujitsu.com>
Date: Mon, 22 Jul 2013 10:48:15 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/21] Arrange hotpluggable memory as ZONE_MOVABLE.
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hi,

Forgot to mention, this patch-set is based on linux-3.10 release.

Thanks. :)

On 07/19/2013 03:59 PM, Tang Chen wrote:
> This patch-set aims to solve some problems at system boot time
> to enhance memory hotplug functionality.
>
> [Background]
>
> The Linux kernel cannot migrate pages used by the kernel because
> of the kernel direct mapping. Since va = pa + PAGE_OFFSET, if the
> physical address is changed, we cannot simply update the kernel
> pagetable. On the contrary, we have to update all the pointers
> pointing to the virtual address, which is very difficult to do.
>
> In order to do memory hotplug, we should prevent the kernel to use
> hotpluggable memory.
>
> In ACPI, there is a table named SRAT(System Resource Affinity Table).
> It contains system NUMA info (CPUs, memory ranges, PXM), and also a
> flag field indicating which memory ranges are hotpluggable.
>
>
> [Problem to be solved]
>
> At the very early time when the system is booting, we use a bootmem
> allocator, named memblock, to allocate memory for the kernel.
> memblock will start to work before the kernel parse SRAT, which
> means memblock won't know which memory is hotpluggable before SRAT
> is parsed.
>
> So at this time, memblock could allocate hotpluggable memory for
> the kernel to use permanently. For example, the kernel may allocate
> pagetables in hotpluggable memory, which cannot be freed when the
> system is up.
>
> So we have to prevent memblock allocating hotpluggable memory for
> the kernel at the early boot time.
>
>
> [Earlier solutions]>
> We have tried to parse SRAT earlier, before memblock is ready. To
> do this, we also have to do ACPI_INITRD_TABLE_OVERRIDE earlier.
> Otherwise the override tables won't be able to effect.
>
> This is not that easy to do because memblock is ready before direct
> mapping is setup. So Yinghai split the ACPI_INITRD_TABLE_OVERRIDE
> procedure into two steps: find and copy. Please refer to the
> following patch-set:
>          https://lkml.org/lkml/2013/6/13/587
>
> To this solution, tj gave a lot of comments and the following
> suggestions.
>
>
> [Suggestion from tj]
>
> tj mainly gave the following suggestions:
>
> 1. Necessary reordering is OK, but we should not rely on
>     reordering to achieve the goal because it makes the kernel
>     too fragile.
>
> 2. Memory allocated to kernel for temporary usage is OK because
>     it will be freed when the system is up. Doing relocation
>     for permanent allocated hotpluggable memory will make the
>     the kernel more robust.
>
> 3. Need to enhance memblock to discover and complain if any
>     hotpluggable memory is allocated to kernel.
>
> After a long thinking, we choose not to do the relocation for
> the following reasons:
>
> 1. It's easy to find out the allocated hotpluggable memory. But
>     memblock will merge the adjoined ranges owned by different users
>     and used for different purposes. It's hard to find the owners.
>
> 2. Different memory has different way to be relocated. I think one
>     function for each kind of memory will make the code too messy.
>
> 3. Pagetable could be in hotpluggable memory. Relocating pagetable
>     is too difficult and risky. We have to update all PUD, PMD pages.
>     And also, ACPI_INITRD_TABLE_OVERRIDE and parsing SRAT procedures
>     are not long after pagetable is initialized. If we relocate the
>     pagetable not long after it was initialized, the code will be
>     very ugly.
>
>
> [Solution in this patch-set]
>
> In this patch-set, we still do the reordering, but in a new way.
>
> 1. Improve memblock with flags, so that it is able to differentiate
>     memory regions for different usage. And also a MEMBLOCK_HOTPLUGGABLE
>     flag to mark hotpluggable memory.
>     (patch 1 ~ 3)
>
> 2. When memblock is ready (memblock_x86_fill() is called), initialize
>     acpi_gbl_root_table_list, fulfill all the ACPI tables' phys addrs.
>     Now, we have all the ACPI tables' phys addrs provided by firmware.
>     (patch 4 ~ 8)
>
> 3. Check if there is a SRAT in initrd file used to override the one
>     provided by firmware. If so, get its phys addr.
>     (patch 12)
>
> 4. If no override SRAT in initrd, get the phys addr of the SRAT
>     provided by firmware.
>     (patch 13)
>
>     Now, we have the phys addr of the to be used SRAT, the one in
>     initrd or the one in firmware.
>
> 5. Parse only the memory affinities in SRAT, find out all the
>     hotpluggable memory regions and reserve them in memblock with
>     MEMBLK_HOTPLUGGABLE flag.
>     (patch 14 ~ 15)
>
> 6. The kernel goes through the current path. Any other related parts,
>     such as ACPI_INITRD_TABLE_OVERRIDE path, the current parsing ACPI
>     tables pathes, global variable numa_meminfo, and so on, are not
>     modified. They work as before.
>
> 7. Free memory with MEMBLK_HOTPLUGGABLE flag when memory initialization
>     is finished.
>     (patch 16)
>
> 8. Introduce movablecore=acpi boot option to allow users to enable
>     and disable this functionality.
>     (patch 17 ~ 21)
>
> And patch 9 ~ 11 fix some small problems.
>
>
> In summary, in order to get hotpluggable memory info as early as possible,
> this patch-set only parse memory affinities in SRAT one more time right
> after memblock is ready, and leave all the other pathes untouched. With
> the hotpluggable memory info, we can arrange hotpluggable memory in
> ZONE_MOVABLE to prevent the kernel to use it.
>
> Thanks. :)
>
>
> Tang Chen (20):
>    acpi: Print Hot-Pluggable Field in SRAT.
>    memblock, numa: Introduce flag into memblock.
>    x86, acpi, numa, mem-hotplug: Introduce MEMBLK_HOTPLUGGABLE to
>      reserve hotpluggable memory.
>    acpi: Remove "continue" in macro INVALID_TABLE().
>    acpi: Introduce acpi_invalid_table() to check if a table is invalid.
>    x86, acpi: Split acpi_boot_table_init() into two parts.
>    x86, acpi: Initialize ACPI root table list earlier.
>    x86, acpi: Also initialize signature and length when parsing root
>      table.
>    x86: Make get_ramdisk_{image|size}() global.
>    earlycpio.c: Fix the confusing comment of find_cpio_data().
>    x86, acpi: Try to find if SRAT is overrided earlier.
>    x86, acpi: Try to find SRAT in firmware earlier.
>    x86, acpi, numa: Reserve hotpluggable memory at early time.
>    x86, acpi, numa: Don't reserve memory on nodes the kernel resides in.
>    x86, memblock, mem-hotplug: Free hotpluggable memory reserved by
>      memblock.
>    page_alloc, mem-hotplug: Improve movablecore to {en|dis}able using
>      SRAT.
>    x86, numa: Synchronize nid info in memblock.reserve with
>      numa_meminfo.
>    x86, numa: Save nid when reserve memory into memblock.reserved[].
>    x86, numa, acpi, memory-hotplug: Make movablecore=acpi have higher
>      priority.
>    doc, page_alloc, acpi, mem-hotplug: Add doc for movablecore=acpi boot
>      option.
>
> Yasuaki Ishimatsu (1):
>    x86: get pg_data_t's memory from other node
>
>   Documentation/kernel-parameters.txt |   10 ++
>   arch/x86/include/asm/setup.h        |    3 +
>   arch/x86/kernel/acpi/boot.c         |   38 +++--
>   arch/x86/kernel/setup.c             |   22 +++-
>   arch/x86/mm/numa.c                  |   55 +++++++-
>   arch/x86/mm/srat.c                  |   11 +-
>   drivers/acpi/acpica/tbutils.c       |   48 ++++++-
>   drivers/acpi/acpica/tbxface.c       |   34 +++++
>   drivers/acpi/osl.c                  |  262 ++++++++++++++++++++++++++++++++---
>   drivers/acpi/tables.c               |    7 +-
>   include/acpi/acpixf.h               |    6 +
>   include/linux/acpi.h                |   21 +++-
>   include/linux/memblock.h            |    9 ++
>   include/linux/memory_hotplug.h      |    5 +
>   include/linux/mm.h                  |    9 ++
>   lib/earlycpio.c                     |    7 +-
>   mm/memblock.c                       |   90 ++++++++++--
>   mm/memory_hotplug.c                 |   42 ++++++-
>   mm/nobootmem.c                      |    3 +
>   mm/page_alloc.c                     |   44 ++++++-
>   20 files changed, 656 insertions(+), 70 deletions(-)
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
