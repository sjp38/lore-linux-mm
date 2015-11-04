Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id E4FCB6B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 11:31:32 -0500 (EST)
Received: by igdg1 with SMTP id g1so109040760igd.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 08:31:32 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id b27si2874302iod.128.2015.11.04.08.31.31
        for <linux-mm@kvack.org>;
        Wed, 04 Nov 2015 08:31:31 -0800 (PST)
Subject: Re: [PATCH V8] mm: memory hot-add: hot-added memory can not be added
 to movable zone by default
References: <1446625415-11941-1-git-send-email-liuchangsheng@inspur.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <563A32DD.1040903@intel.com>
Date: Wed, 4 Nov 2015 08:31:25 -0800
MIME-Version: 1.0
In-Reply-To: <1446625415-11941-1-git-send-email-liuchangsheng@inspur.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: liuchangsheng <liuchangsheng@inspur.com>, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, vbabka@suse.cz, yasu.isimatu@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, wunan@inspur.com, yanxiaofeng@inspur.com, fandd@inspur.com, Wang Nan <wangnan0@huawei.com>, Yinghai Lu <yinghai@kernel.org>, Tang Chen <tangchen@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>, Xishi Qiu <qiuxishi@huawei.com>

On 11/04/2015 12:23 AM, liuchangsheng wrote:
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

I'm still a bit confused about the whole scenario here.

Is the core problem:
1. We add memory in a new node and that node can not be made entirely
   movable?
or
2. We add memory to an existing zone that has some non-movable memory
   and we want the new memory to be movable?

> @@ -1201,6 +1201,9 @@ static int check_hotplug_memory_range(u64 start, u64 size)
>  /*
>   * If movable zone has already been setup, newly added memory should be check.
>   * If its address is higher than movable zone, it should be added as movable.
> + * And if system boots up with movable_node and config CONFIG_MOVABLE_NOD and
> + * added memory does not overlap the zone before MOVABLE_ZONE,
> + * the memory is added as movable.
>   * Without this check, movable zone may overlap with other zone.
>   */

This comment is describing what the code does, but is rather sparse on
why.  This scenario is pretty convoluted and I can barely make sense of
why it is doing this today while looking at the whole changelog, much
less in a few years when the original changelog will be harder to come by.

Also please put the comment next to the new if() statement.  It's really
hard to match the comment to the code the way you have it now.

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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
