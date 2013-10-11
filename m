Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id B591B6B0031
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 20:01:22 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so3399198pdj.15
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 17:01:22 -0700 (PDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so3528906pab.32
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 17:01:19 -0700 (PDT)
Message-ID: <52573FB5.5020100@gmail.com>
Date: Fri, 11 Oct 2013 08:00:53 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH part1 v7 0/6] x86, memblock: Allocate memory near kernel
 image before SRAT parsed
References: <52570A6E.2010806@gmail.com>
In-Reply-To: <52570A6E.2010806@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Tejun Heo <tj@kernel.org>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, mina86@mina86.com, Minchan Kim <minchan@kernel.org>, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

Hello Andrew,

Could you take this version now? Since the approach of
this patchset is suggested by tejun, and thanks him for
helping us explaining a lot to guys that have the concern
about the page table location. I've added some note in
the patch4 description to explain why we could be not worrisome
about the approach.

Thanks.

On 10/11/2013 04:13 AM, Zhang Yanfei wrote:
> Hello, here is the v7 version. Any comments are welcome!
> 
> The v7 version is based on linus's tree (3.12-rc4)
> HEAD is:
> commit d0e639c9e06d44e713170031fe05fb60ebe680af
> Author: Linus Torvalds <torvalds@linux-foundation.org>
> Date:   Sun Oct 6 14:00:20 2013 -0700
> 
>     Linux 3.12-rc4
> 
> 
> [Problem]
> 
> The current Linux cannot migrate pages used by the kerenl because
> of the kernel direct mapping. In Linux kernel space, va = pa + PAGE_OFFSET.
> When the pa is changed, we cannot simply update the pagetable and
> keep the va unmodified. So the kernel pages are not migratable.
> 
> There are also some other issues will cause the kernel pages not migratable.
> For example, the physical address may be cached somewhere and will be used.
> It is not to update all the caches.
> 
> When doing memory hotplug in Linux, we first migrate all the pages in one
> memory device somewhere else, and then remove the device. But if pages are
> used by the kernel, they are not migratable. As a result, memory used by
> the kernel cannot be hot-removed.
> 
> Modifying the kernel direct mapping mechanism is too difficult to do. And
> it may cause the kernel performance down and unstable. So we use the following
> way to do memory hotplug.
> 
> 
> [What we are doing]
> 
> In Linux, memory in one numa node is divided into several zones. One of the
> zones is ZONE_MOVABLE, which the kernel won't use.
> 
> In order to implement memory hotplug in Linux, we are going to arrange all
> hotpluggable memory in ZONE_MOVABLE so that the kernel won't use these memory.
> To do this, we need ACPI's help.
> 
> In ACPI, SRAT(System Resource Affinity Table) contains NUMA info. The memory
> affinities in SRAT record every memory range in the system, and also, flags
> specifying if the memory range is hotpluggable.
> (Please refer to ACPI spec 5.0 5.2.16)
> 
> With the help of SRAT, we have to do the following two things to achieve our
> goal:
> 
> 1. When doing memory hot-add, allow the users arranging hotpluggable as
>    ZONE_MOVABLE.
>    (This has been done by the MOVABLE_NODE functionality in Linux.)
> 
> 2. when the system is booting, prevent bootmem allocator from allocating
>    hotpluggable memory for the kernel before the memory initialization
>    finishes.
> 
> The problem 2 is the key problem we are going to solve. But before solving it,
> we need some preparation. Please see below.
> 
> 
> [Preparation]
> 
> Bootloader has to load the kernel image into memory. And this memory must be 
> unhotpluggable. We cannot prevent this anyway. So in a memory hotplug system, 
> we can assume any node the kernel resides in is not hotpluggable.
> 
> Before SRAT is parsed, we don't know which memory ranges are hotpluggable. But
> memblock has already started to work. In the current kernel, memblock allocates 
> the following memory before SRAT is parsed:
> 
> setup_arch()
>  |->memblock_x86_fill()            /* memblock is ready */
>  |......
>  |->early_reserve_e820_mpc_new()   /* allocate memory under 1MB */
>  |->reserve_real_mode()            /* allocate memory under 1MB */
>  |->init_mem_mapping()             /* allocate page tables, about 2MB to map 1GB memory */
>  |->dma_contiguous_reserve()       /* specified by user, should be low */
>  |->setup_log_buf()                /* specified by user, several mega bytes */
>  |->relocate_initrd()              /* could be large, but will be freed after boot, should reorder */
>  |->acpi_initrd_override()         /* several mega bytes */
>  |->reserve_crashkernel()          /* could be large, should reorder */
>  |......
>  |->initmem_init()                 /* Parse SRAT */
> 
> According to Tejun's advice, before SRAT is parsed, we should try our best to
> allocate memory near the kernel image. Since the whole node the kernel resides 
> in won't be hotpluggable, and for a modern server, a node may have at least 16GB
> memory, allocating several mega bytes memory around the kernel image won't cross
> to hotpluggable memory.
> 
> 
> [About this patch-set]
> 
> So this patch-set is the preparation for the problem 2 that we want to solve. It
> does the following:
> 
> 1. Make memblock be able to allocate memory bottom up.
>    1) Keep all the memblock APIs' prototype unmodified.
>    2) When the direction is bottom up, keep the start address greater than the 
>       end of kernel image.
> 
> 2. Improve init_mem_mapping() to support allocate page tables in bottom up direction.
> 
> 3. Introduce "movable_node" boot option to enable and disable this functionality.
> 
> Change log v6 -> v7:
> 1. Add toshi's ack in several patches.
> 2. Make __pa_symbol() available everywhere by putting a pesudo __pa_symbol define
>    in include/linux/mm.h. Thanks HPA.
> 3. Add notes about the page table allocation in bottom-up.
> 
> Change log v5 -> v6:
> 1. Add tejun and toshi's ack in several patches.
> 2. Change movablenode to movable_node boot option and update the description
>    for movable_node and CONFIG_MOVABLE_NODE. Thanks Ingo!
> 3. Fix the __pa_symbol() issue pointed by Andrew Morton.
> 4. Update some functions' comments and names.
> 
> Change log v4 -> v5:
> 1. Change memblock.current_direction to a boolean memblock.bottom_up. And remove 
>    the direction enum.
> 2. Update and add some comments to explain things clearer.
> 3. Misc fixes, such as removing unnecessary #ifdef
> 
> Change log v3 -> v4:
> 1. Use bottom-up/top-down to unify things. Thanks tj.
> 2. Factor out of current top-down implementation and then introduce bottom-up mode,
>    not mixing them in one patch. Thanks tj.
> 3. Changes function naming: memblock_direction_bottom_up -> memblock_bottom_up
> 4. Use memblock_set_bottom_up to replace memblock_set_current_direction, which makes
>    the code simpler. Thanks tj.
> 5. Define two implementions of function memblock_bottom_up and memblock_set_bottom_up
>    in order not to use #ifdef in the boot code. Thanks tj.
> 6. Add comments to explain why retry top-down allocation when bottom_up allocation
>    failed. Thanks tj and toshi!
> 
> Change log v2 -> v3:
> 1. According to Toshi's suggestion, move the direction checking logic into memblock.
>    And simply the code more.
> 
> Change log v1 -> v2:
> 1. According to tj's suggestion, implemented a new function memblock_alloc_bottom_up() 
>    to allocate memory from bottom upwards, whihc can simplify the code.
> 
> Tang Chen (6):
>   memblock: Factor out of top-down allocation
>   memblock: Introduce bottom-up allocation mode
>   x86/mm: Factor out of top-down direct mapping setup
>   x86/mem-hotplug: Support initialize page tables in bottom-up
>   x86, acpi, crash, kdump: Do reserve_crashkernel() after SRAT is
>     parsed.
>   mem-hotplug: Introduce movable_node boot option
> 
>  Documentation/kernel-parameters.txt |    3 +
>  arch/x86/kernel/setup.c             |    9 ++-
>  arch/x86/mm/init.c                  |  122 ++++++++++++++++++++++++++++------
>  arch/x86/mm/numa.c                  |   11 +++
>  include/linux/memblock.h            |   24 +++++++
>  include/linux/mm.h                  |    4 +
>  mm/Kconfig                          |   17 +++--
>  mm/memblock.c                       |  126 +++++++++++++++++++++++++++++++----
>  mm/memory_hotplug.c                 |   31 +++++++++
>  9 files changed, 306 insertions(+), 41 deletions(-)
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
