Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 78B976B0037
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 19:38:18 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH v3 00/25] Arrange hotpluggable memory as ZONE_MOVABLE.
Date: Thu, 08 Aug 2013 01:48:33 +0200
Message-ID: <1786839.lAdBpJ22ie@vostro.rjw.lan>
In-Reply-To: <1375872736-4822-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1375872736-4822-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: robert.moore@intel.com, lv.zheng@intel.com, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Wednesday, August 07, 2013 06:51:51 PM Tang Chen wrote:
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
> [Earlier solutions]
> 
> We have tried to parse SRAT earlier, before memblock is ready. To
> do this, we also have to do ACPI_INITRD_TABLE_OVERRIDE earlier.
> Otherwise the override tables won't be able to effect.
> 
> This is not that easy to do because memblock is ready before direct
> mapping is setup. So Yinghai split the ACPI_INITRD_TABLE_OVERRIDE
> procedure into two steps: find and copy. Please refer to the
> following patch-set:
>         https://lkml.org/lkml/2013/6/13/587
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
>    reordering to achieve the goal because it makes the kernel
>    too fragile.
> 
> 2. Memory allocated to kernel for temporary usage is OK because
>    it will be freed when the system is up. Doing relocation
>    for permanent allocated hotpluggable memory will make the
>    the kernel more robust.
> 
> 3. Need to enhance memblock to discover and complain if any
>    hotpluggable memory is allocated to kernel.
> 
> After a long thinking, we choose not to do the relocation for
> the following reasons:
> 
> 1. It's easy to find out the allocated hotpluggable memory. But
>    memblock will merge the adjoined ranges owned by different users
>    and used for different purposes. It's hard to find the owners.
> 
> 2. Different memory has different way to be relocated. I think one
>    function for each kind of memory will make the code too messy.
> 
> 3. Pagetable could be in hotpluggable memory. Relocating pagetable
>    is too difficult and risky. We have to update all PUD, PMD pages.
>    And also, ACPI_INITRD_TABLE_OVERRIDE and parsing SRAT procedures
>    are not long after pagetable is initialized. If we relocate the
>    pagetable not long after it was initialized, the code will be
>    very ugly.
> 
> 
> [Solution in this patch-set]
> 
> In this patch-set, we still do the reordering, but in a new way.
> 
> 1. Improve memblock with flags, so that it is able to differentiate
>    memory regions for different usage. And also a MEMBLOCK_HOTPLUG
>    flag to mark hotpluggable memory.
> 
> 2. When memblock is ready (memblock_x86_fill() is called), initialize
>    acpi_gbl_root_table_list, fulfill all the ACPI tables' phys addrs.
>    Now, we have all the ACPI tables' phys addrs provided by firmware.
> 
> 3. Check if there is a SRAT in initrd file used to override the one
>    provided by firmware. If so, get its phys addr.
> 
> 4. If no override SRAT in initrd, get the phys addr of the SRAT
>    provided by firmware.
> 
>    Now, we have the phys addr of the to be used SRAT, the one in
>    initrd or the one in firmware.
> 
> 5. Parse only the memory affinities in SRAT, find out all the
>    hotpluggable memory regions and mark them in memblock.memory with
>    MEMBLOCK_HOTPLUG flag.
> 
> 6. The kernel goes through the current path. Any other related parts,
>    such as ACPI_INITRD_TABLE_OVERRIDE path, the current parsing ACPI
>    tables pathes, global variable numa_meminfo, and so on, are not
>    modified. They work as before.
> 
> 7. Make memblock default allocator skip hotpluggable memory.
> 
> 8. Introduce movablenode boot option to allow users to enable
>    and disable this functionality.
> 
> 
> In summary, in order to get hotpluggable memory info as early as possible,
> this patch-set only parse memory affinities in SRAT one more time right
> after memblock is ready, and leave all the other pathes untouched. With
> the hotpluggable memory info, we can arrange hotpluggable memory in
> ZONE_MOVABLE to prevent the kernel to use it.
> 
> change log v2 RESEND -> v3:
> 1. As Rafael and Lv Zheng suggested, split acpi global root table list 
>    initialization procedure into two steps: install and override. And 
>    do the "install" step earlier.

This looks a bit more manageable than before, but please do one more thing:
Please split all of the ACPICA changes out into separate patches and put those
patched in front of everything else.

The reason is we may need to merge them through upstream ACPICA as the first
step (if they are accepted by the ACPICA maintainers).

Thanks,
Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
