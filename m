Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 750396B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 11:18:12 -0500 (EST)
Received: by qkct129 with SMTP id t129so21915979qkc.2
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 08:18:12 -0800 (PST)
Received: from mail-qg0-x22d.google.com (mail-qg0-x22d.google.com. [2607:f8b0:400d:c04::22d])
        by mx.google.com with ESMTPS id n61si1195371qge.12.2015.11.04.08.18.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 08:18:11 -0800 (PST)
Received: by qgeo38 with SMTP id o38so44609174qge.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 08:18:11 -0800 (PST)
Message-ID: <563a2fc3.d2298c0a.c4806.3331@mx.google.com>
Date: Wed, 04 Nov 2015 08:18:11 -0800 (PST)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH V8] mm: memory hot-add: hot-added memory can not be
 added to movable zone by default
In-Reply-To: <1446625415-11941-1-git-send-email-liuchangsheng@inspur.com>
References: <3bafc5b1154429e3cb6015dbc1c3fd88@s.corp-email.com>
	<1446625415-11941-1-git-send-email-liuchangsheng@inspur.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: liuchangsheng <liuchangsheng@inspur.com>
Cc: akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wunan@inspur.com, yanxiaofeng@inspur.com, fandd@inspur.com, Wang Nan <wangnan0@huawei.com>, Dave Hansen <dave.hansen@intel.com>, Yinghai Lu <yinghai@kernel.org>, Tang Chen <tangchen@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>, Xishi Qiu <qiuxishi@huawei.com>


On Wed, 4 Nov 2015 03:23:35 -0500
liuchangsheng <liuchangsheng@inspur.com> wrote:

> After the user config CONFIG_MOVABLE_NODE,
> When the memory is hot added, should_add_memory_movable() return 0
> because all zones including ZONE_MOVABLE are empty,
> so the memory that was hot added will be assigned to ZONE_NORMAL,
> and we need using the udev rules to online the memory automatically:
> SUBSYSTEM=="memory", ACTION=="add", ATTR{state}=="offline",
> ATTR{state}="online_movable"
> The memory block onlined by udev must be adjacent to ZONE_MOVABLE.
> The events of memory section are notified to udev asynchronously,
> so it can not ensure that the memory block onlined by udev is
> adjacent to ZONE_MOVABLE.So it can't ensure memory online always success.
> But we want the whole node to be added to ZONE_MOVABLE by default.
> 
> So we change should_add_memory_movable(): if the user config
> CONFIG_MOVABLE_NODE and movable_node kernel option
> and the ZONE_NORMAL is empty or the pfn of the hot-added memory
> is after the end of the ZONE_NORMAL it will always return 1
> and then the whole node will be added to ZONE_MOVABLE by default.
> If we want the node to be assigned to ZONE_NORMAL,
> we can do it as follows:
> "echo online_kernel > /sys/devices/system/memory/memoryXXX/state"
> 
> Signed-off-by: liuchangsheng <liuchangsheng@inspur.com>
> Signed-off-by: Xiaofeng Yan <yanxiaofeng@inspur.com>
> Tested-by: Dongdong Fan <fandd@inspur.com>
> Reviewed-by: <yasu.isimatu@gmail.com>
> Cc: Wang Nan <wangnan0@huawei.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Yinghai Lu <yinghai@kernel.org>
> Cc: Tang Chen <tangchen@cn.fujitsu.com>
> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Cc: Toshi Kani <toshi.kani@hp.com>
> Cc: Xishi Qiu <qiuxishi@huawei.com>
> ---

Looks good to me.

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

>  mm/memory_hotplug.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index aa992e2..8617b9f 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1201,6 +1201,9 @@ static int check_hotplug_memory_range(u64 start, u64 size)
>  /*
>   * If movable zone has already been setup, newly added memory should be check.
>   * If its address is higher than movable zone, it should be added as movable.
> + * And if system boots up with movable_node and config CONFIG_MOVABLE_NOD and
> + * added memory does not overlap the zone before MOVABLE_ZONE,
> + * the memory is added as movable.
>   * Without this check, movable zone may overlap with other zone.
>   */
>  static int should_add_memory_movable(int nid, u64 start, u64 size)
> @@ -1208,6 +1211,10 @@ static int should_add_memory_movable(int nid, u64 start, u64 size)
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	pg_data_t *pgdat = NODE_DATA(nid);
>  	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
> +	struct zone *pre_zone = pgdat->node_zones + (ZONE_MOVABLE - 1);
> +
> +	if (movable_node_is_enabled() && (zone_end_pfn(pre_zone) <= start_pfn))
> +		return 1;
>  
>  	if (zone_is_empty(movable_zone))
>  		return 0;
> -- 
> 1.8.3.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
