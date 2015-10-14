Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6CF6B0038
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 12:18:36 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so4750465wic.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 09:18:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hg7si12430748wib.23.2015.10.14.09.18.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Oct 2015 09:18:34 -0700 (PDT)
Subject: Re: [PATCH V7] mm: memory hot-add: memory can not be added to movable
 zone defaultly
References: <1444633113-27607-1-git-send-email-liuchangsheng@inspur.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <561E8056.7050609@suse.cz>
Date: Wed, 14 Oct 2015 18:18:30 +0200
MIME-Version: 1.0
In-Reply-To: <1444633113-27607-1-git-send-email-liuchangsheng@inspur.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Changsheng Liu <liuchangsheng@inspur.com>, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, yasu.isimatu@gmail.com, tangchen@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, wangnan0@huawei.com, dave.hansen@intel.com, yinghai@kernel.org, toshi.kani@hp.com, qiuxishi@huawei.com, wunan@inspur.com, yanxiaofeng@inspur.com, fandd@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>

On 10/12/2015 08:58 AM, Changsheng Liu wrote:
> From: Changsheng Liu <liuchangcheng@inspur.com>
> 
> After the user config CONFIG_MOVABLE_NODE,
> When the memory is hot added, should_add_memory_movable() return 0
> because all zones including ZONE_MOVABLE are empty,
> so the memory that was hot added will be assigned to ZONE_NORMAL
> and ZONE_NORMAL will be created firstly.
> But we want the whole node to be added to ZONE_MOVABLE by default.
> 
> So we change should_add_memory_movable(): if the user config
> CONFIG_MOVABLE_NODE and sysctl parameter hotadd_memory_as_movable is 1
> and the ZONE_NORMAL is empty or the pfn of the hot-added memory
> is after the end of the ZONE_NORMAL it will always return 1
> and then the whole node will be added to ZONE_MOVABLE by default.
> If we want the node to be assigned to ZONE_NORMAL,
> we can do it as follows:
> "echo online_kernel > /sys/devices/system/memory/memoryXXX/state"
> 
> By the patch, the behavious of kernel is changed by sysctl,
> user can automatically create movable memory
> by only the following udev rule:
> SUBSYSTEM=="memory", ACTION=="add",
> ATTR{state}=="offline", ATTR{state}="online"

So just to be clear, we are adding a new sysctl, because the existing
movable_node kernel option, which is checked by movable_node_is_enabled(), and
does the same thing for non-hot-added-memory (?) cannot be reused for hot-added
memory, as that would be a potentially surprising behavior change? Correct? Then
this should be mentioned in the changelog too, and wherever "movable_node" is
documented should also mention the new sysctl. Personally, I would expect
movable_node to affect hot-added memory as well, and would be surprised that it
doesn't...

> Signed-off-by: Changsheng Liu <liuchangsheng@inspur.com>
> Signed-off-by: Xiaofeng Yan <yanxiaofeng@inspur.com>
> Tested-by: Dongdong Fan <fandd@inspur.com>
> Cc: Wang Nan <wangnan0@huawei.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Yinghai Lu <yinghai@kernel.org>
> Cc: Tang Chen <tangchen@cn.fujitsu.com>
> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Cc: Toshi Kani <toshi.kani@hp.com>
> Cc: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  Documentation/memory-hotplug.txt |    5 ++++-
>  kernel/sysctl.c                  |   15 +++++++++++++++
>  mm/memory_hotplug.c              |   24 ++++++++++++++++++++++++
>  3 files changed, 43 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
> index ce2cfcf..7ac7485 100644
> --- a/Documentation/memory-hotplug.txt
> +++ b/Documentation/memory-hotplug.txt
> @@ -277,7 +277,7 @@ And if the memory block is in ZONE_MOVABLE, you can change it to ZONE_NORMAL:
>  After this, memory block XXX's state will be 'online' and the amount of
>  available memory will be increased.
>  
> -Currently, newly added memory is added as ZONE_NORMAL (for powerpc, ZONE_DMA).
> +Currently, newly added memory is added as ZONE_NORMAL or ZONE_MOVABLE (for powerpc, ZONE_DMA).
>  This may be changed in future.
>  
>  
> @@ -319,6 +319,9 @@ creates ZONE_MOVABLE as following.
>    Size of memory not for movable pages (not for offline) is TOTAL - ZZZZ.
>    Size of memory for movable pages (for offline) is ZZZZ.
>  
> +And a sysctl parameter for assigning the hot added memory to ZONE_MOVABLE is
> +supported. If the value of "kernel/hotadd_memory_as_movable" is 1,the hot added
> +memory will be assigned to ZONE_MOVABLE by default.
>  
>  Note: Unfortunately, there is no information to show which memory block belongs
>  to ZONE_MOVABLE. This is TBD.
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 19b62b5..16b1501 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -166,6 +166,10 @@ extern int unaligned_dump_stack;
>  extern int no_unaligned_warning;
>  #endif
>  
> +#ifdef CONFIG_MOVABLE_NODE
> +extern int hotadd_memory_as_movable;
> +#endif
> +
>  #ifdef CONFIG_PROC_SYSCTL
>  
>  #define SYSCTL_WRITES_LEGACY	-1
> @@ -1139,6 +1143,17 @@ static struct ctl_table kern_table[] = {
>  		.proc_handler	= timer_migration_handler,
>  	},
>  #endif
> +/*If the value of "kernel/hotadd_memory_as_movable" is 1,the hot added
> + * memory will be assigned to ZONE_MOVABLE by default.*/
> +#ifdef CONFIG_MOVABLE_NODE
> +	{
> +		.procname	= "hotadd_memory_as_movable",
> +		.data		= &hotadd_memory_as_movable,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
> +#endif
>  	{ }
>  };
>  
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 26fbba7..eca5512 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -37,6 +37,11 @@
>  
>  #include "internal.h"
>  
> +/*If the global variable value is 1,
> + * the hot added memory will be assigned to ZONE_MOVABLE by default
> + */
> +int hotadd_memory_as_movable;
> +
>  /*
>   * online_page_callback contains pointer to current page onlining function.
>   * Initially it is generic_online_page(). If it is required it could be
> @@ -1190,6 +1195,9 @@ static int check_hotplug_memory_range(u64 start, u64 size)
>  /*
>   * If movable zone has already been setup, newly added memory should be check.
>   * If its address is higher than movable zone, it should be added as movable.
> + * And if system config CONFIG_MOVABLE_NODE and set the sysctl parameter
> + * "hotadd_memory_as_movable" and added memory does not overlap the zone
> + * before MOVABLE_ZONE,the memory will be added as movable.
>   * Without this check, movable zone may overlap with other zone.
>   */
>  static int should_add_memory_movable(int nid, u64 start, u64 size)
> @@ -1197,6 +1205,22 @@ static int should_add_memory_movable(int nid, u64 start, u64 size)
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	pg_data_t *pgdat = NODE_DATA(nid);
>  	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
> +	struct zone *pre_zone = pgdat->node_zones + (ZONE_MOVABLE - 1);
> +	/*
> +	 * The system configs CONFIG_MOVABLE_NODE to assign a node
> +	 * which has only movable memory,so the hot-added memory should
> +	 * be assigned to ZONE_MOVABLE by default,
> +	 * but the function zone_for_memory() assign the hot-added memory
> +	 * to ZONE_NORMAL(x86_64) by default.Kernel does not allow to
> +	 * create ZONE_MOVABLE before ZONE_NORMAL,So if the value of
> +	 * sysctl parameter "hotadd_memory_as_movable" is 1
> +	 * and the ZONE_NORMAL is empty or the pfn of the hot-added memory
> +	 * is after the end of ZONE_NORMAL
> +	 * the hot-added memory will be assigned to ZONE_MOVABLE.
> +	 */
> +	if (hotadd_memory_as_movable
> +	&& (zone_is_empty(pre_zone) || zone_end_pfn(pre_zone) <= start_pfn))
> +		return 1;
>  
>  	if (zone_is_empty(movable_zone))
>  		return 0;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
