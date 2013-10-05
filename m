Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id BE98E6B0037
	for <linux-mm@kvack.org>; Sat,  5 Oct 2013 18:32:36 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so5657706pab.39
        for <linux-mm@kvack.org>; Sat, 05 Oct 2013 15:32:36 -0700 (PDT)
Message-ID: <1381012134.5429.86.camel@misato.fc.hp.com>
Subject: Re: [PATCH part1 v6 6/6] mem-hotplug: Introduce movable_node boot
 option
From: Toshi Kani <toshi.kani@hp.com>
Date: Sat, 05 Oct 2013 16:28:54 -0600
In-Reply-To: <524E21BC.7090104@gmail.com>
References: <524E2032.4020106@gmail.com> <524E21BC.7090104@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Tejun Heo <tj@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

On Fri, 2013-10-04 at 10:02 +0800, Zhang Yanfei wrote:
> From: Tang Chen <tangchen@cn.fujitsu.com>
> 
> The hot-Pluggable field in SRAT specifies which memory is hotpluggable.
> As we mentioned before, if hotpluggable memory is used by the kernel,
> it cannot be hot-removed. So memory hotplug users may want to set all
> hotpluggable memory in ZONE_MOVABLE so that the kernel won't use it.
> 
> Memory hotplug users may also set a node as movable node, which has
> ZONE_MOVABLE only, so that the whole node can be hot-removed.
> 
> But the kernel cannot use memory in ZONE_MOVABLE. By doing this, the
> kernel cannot use memory in movable nodes. This will cause NUMA
> performance down. And other users may be unhappy.
> 
> So we need a way to allow users to enable and disable this functionality.
> In this patch, we introduce movable_node boot option to allow users to
> choose to not to consume hotpluggable memory at early boot time and
> later we can set it as ZONE_MOVABLE.
> 
> To achieve this, the movable_node boot option will control the memblock
> allocation direction. That said, after memblock is ready, before SRAT is
> parsed, we should allocate memory near the kernel image as we explained
> in the previous patches. So if movable_node boot option is set, the kernel
> does the following:
> 
> 1. After memblock is ready, make memblock allocate memory bottom up.
> 2. After SRAT is parsed, make memblock behave as default, allocate memory
>    top down.
> 
> Users can specify "movable_node" in kernel commandline to enable this
> functionality. For those who don't use memory hotplug or who don't want
> to lose their NUMA performance, just don't specify anything. The kernel
> will work as before.
> 
> Suggested-by: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Suggested-by: Ingo Molnar <mingo@kernel.org>
> Acked-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> ---
>  Documentation/kernel-parameters.txt |    3 +++
>  arch/x86/mm/numa.c                  |   11 +++++++++++
>  mm/Kconfig                          |   17 ++++++++++++-----
>  mm/memory_hotplug.c                 |   31 +++++++++++++++++++++++++++++++
>  4 files changed, 57 insertions(+), 5 deletions(-)
> 
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index 539a236..13201d4 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -1769,6 +1769,9 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  			that the amount of memory usable for all allocations
>  			is not too small.
>  
> +	movable_node	[KNL,X86] Boot-time switch to disable the effects
> +			of CONFIG_MOVABLE_NODE=y. See mm/Kconfig for details.

I thought this is the option to "enable", not disable.

> +
>  	MTD_Partition=	[MTD]
>  			Format: <name>,<region-number>,<size>,<offset>
>  
> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> index 8bf93ba..24aec58 100644
> --- a/arch/x86/mm/numa.c
> +++ b/arch/x86/mm/numa.c
> @@ -567,6 +567,17 @@ static int __init numa_init(int (*init_func)(void))
>  	ret = init_func();
>  	if (ret < 0)
>  		return ret;
> +
> +	/*
> +	 * We reset memblock back to the top-down direction
> +	 * here because if we configured ACPI_NUMA, we have
> +	 * parsed SRAT in init_func(). It is ok to have the
> +	 * reset here even if we did't configure ACPI_NUMA
> +	 * or acpi numa init fails and fallbacks to dummy
> +	 * numa init.
> +	 */
> +	memblock_set_bottom_up(false);
> +
>  	ret = numa_cleanup_meminfo(&numa_meminfo);
>  	if (ret < 0)
>  		return ret;
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 026771a..0db1cc6 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -153,11 +153,18 @@ config MOVABLE_NODE
>  	help
>  	  Allow a node to have only movable memory.  Pages used by the kernel,
>  	  such as direct mapping pages cannot be migrated.  So the corresponding
> -	  memory device cannot be hotplugged.  This option allows users to
> -	  online all the memory of a node as movable memory so that the whole
> -	  node can be hotplugged.  Users who don't use the memory hotplug
> -	  feature are fine with this option on since they don't online memory
> -	  as movable.
> +	  memory device cannot be hotplugged.  This option allows the following
> +	  two things:
> +	  - When the system is booting, node full of hotpluggable memory can
> +	  be arranged to have only movable memory so that the whole node can
> +	  be hotplugged. (need movable_node boot option specified).

I think "hotplugged" should be "hot-removed".

> +	  - After the system is up, the option allows users to online all the
> +	  memory of a node as movable memory so that the whole node can be
> +	  hotplugged.

Same here. 

> +
> +	  Users who don't use the memory hotplug feature are fine with this
> +	  option on since they don't specify movable_node boot option or they
> +	  don't online memory as movable.
>  
>  	  Say Y here if you want to hotplug a whole node.
>  	  Say N here if you want kernel to use memory on all nodes evenly.
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index ed85fe3..6874c31 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -31,6 +31,7 @@
>  #include <linux/firmware-map.h>
>  #include <linux/stop_machine.h>
>  #include <linux/hugetlb.h>
> +#include <linux/memblock.h>
>  
>  #include <asm/tlbflush.h>
>  
> @@ -1412,6 +1413,36 @@ static bool can_offline_normal(struct zone *zone, unsigned long nr_pages)
>  }
>  #endif /* CONFIG_MOVABLE_NODE */
>  
> +static int __init cmdline_parse_movable_node(char *p)
> +{
> +#ifdef CONFIG_MOVABLE_NODE
> +	/*
> +	 * Memory used by the kernel cannot be hot-removed because Linux
> +	 * cannot migrate the kernel pages. When memory hotplug is
> +	 * enabled, we should prevent memblock from allocating memory
> +	 * for the kernel.
> +	 *
> +	 * ACPI SRAT records all hotpluggable memory ranges. But before
> +	 * SRAT is parsed, we don't know about it.
> +	 *
> +	 * The kernel image is loaded into memory at very early time. We
> +	 * cannot prevent this anyway. So on NUMA system, we set any
> +	 * node the kernel resides in as un-hotpluggable.
> +	 *
> +	 * Since on modern servers, one node could have double-digit
> +	 * gigabytes memory, we can assume the memory around the kernel
> +	 * image is also un-hotpluggable. So before SRAT is parsed, just
> +	 * allocate memory near the kernel image to try the best to keep
> +	 * the kernel away from hotpluggable memory.
> +	 */
> +	memblock_set_bottom_up(true);
> +#else
> +	pr_warn("movable_node option not supported");

"\n" is missing.

Thanks,
-Toshi


> +#endif
> +	return 0;
> +}
> +early_param("movable_node", cmdline_parse_movable_node);
> +
>  /* check which state of node_states will be changed when offline memory */
>  static void node_states_check_changes_offline(unsigned long nr_pages,
>  		struct zone *zone, struct memory_notify *arg)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
