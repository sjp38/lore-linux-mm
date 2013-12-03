Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 278046B0031
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 21:48:34 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id p10so19338914pdj.18
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 18:48:33 -0800 (PST)
Received: from song.cn.fujitsu.com ([222.73.24.84])
        by mx.google.com with ESMTP id f4si21620648pbm.145.2013.12.02.18.48.30
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 18:48:32 -0800 (PST)
Message-ID: <529D45E0.6000300@cn.fujitsu.com>
Date: Tue, 03 Dec 2013 10:45:52 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH RESEND part2 v2 0/8] Arrange hotpluggable memory as ZONE_MOVABLE
References: <529D3FC0.6000403@cn.fujitsu.com>
In-Reply-To: <529D3FC0.6000403@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Chen Tang <imtangchen@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>

Hello Andrew
CC: tejun

Now since the 3.13-rc2 is out, It will be appreciated that you take these
patches into -mm tree so that they start appearing in next to catch any
regressions, issues etc. It will give us some time to fix any issues
arises from next.

This is only the remaining part of the memory-hotplug work and the first part
has been merged in 3.12 so we hope this part will catch v3.13 to make
the functionality work asap.

I tested these patches on top of 3.13-rc2 and it works well.

Thank you very much!
Zhang

On 12/03/2013 10:19 AM, Zhang Yanfei wrote:
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
> 
> To do this, we need ACPI's help.
> 
> 
> [How we do this]
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
>    (This is what we are going to do. See below.)
> 
> 
> [About this patch-set]
> 
> In previous part's patches, we have made the kernel allocate memory near
> kernel image before SRAT parsed to avoid allocating hotpluggable memory
> for kernel. So this patch-set does the following things:
> 
> 1. Improve memblock to support flags, which are used to indicate different 
>    memory type.
> 
> 2. Mark all hotpluggable memory in memblock.memory[].
> 
> 3. Make the default memblock allocator skip hotpluggable memory.
> 
> 4. Improve "movable_node" boot option to have higher priority of movablecore
>    and kernelcore boot option.
> 
> Change log v1 -> v2:
> 1. Rebase this part on the v7 version of part1
> 2. Fix bug: If movable_node boot option not specified, memblock still
>    checks hotpluggable memory when allocating memory. 
> 
> Tang Chen (7):
>   memblock, numa: Introduce flag into memblock
>   memblock, mem_hotplug: Introduce MEMBLOCK_HOTPLUG flag to mark
>     hotpluggable regions
>   memblock: Make memblock_set_node() support different memblock_type
>   acpi, numa, mem_hotplug: Mark hotpluggable memory in memblock
>   acpi, numa, mem_hotplug: Mark all nodes the kernel resides
>     un-hotpluggable
>   memblock, mem_hotplug: Make memblock skip hotpluggable regions if
>     needed
>   x86, numa, acpi, memory-hotplug: Make movable_node have higher
>     priority
> 
> Yasuaki Ishimatsu (1):
>   x86: get pg_data_t's memory from other node
> 
>  arch/metag/mm/init.c      |    3 +-
>  arch/metag/mm/numa.c      |    3 +-
>  arch/microblaze/mm/init.c |    3 +-
>  arch/powerpc/mm/mem.c     |    2 +-
>  arch/powerpc/mm/numa.c    |    8 ++-
>  arch/sh/kernel/setup.c    |    4 +-
>  arch/sparc/mm/init_64.c   |    5 +-
>  arch/x86/mm/init_32.c     |    2 +-
>  arch/x86/mm/init_64.c     |    2 +-
>  arch/x86/mm/numa.c        |   63 +++++++++++++++++++++--
>  arch/x86/mm/srat.c        |    5 ++
>  include/linux/memblock.h  |   39 ++++++++++++++-
>  mm/memblock.c             |  123 ++++++++++++++++++++++++++++++++++++++-------
>  mm/memory_hotplug.c       |    1 +
>  mm/page_alloc.c           |   28 ++++++++++-
>  15 files changed, 252 insertions(+), 39 deletions(-)
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
