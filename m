Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id CEA616B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 09:09:01 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so74231513wic.0
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 06:09:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gn12si26708941wjc.137.2015.08.31.06.08.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 31 Aug 2015 06:09:00 -0700 (PDT)
Subject: Re: [PATCH V4] mm: memory hot-add: memory can not be added to movable
 zone defaultly
References: <1441000720-28506-1-git-send-email-liuchangsheng@inspur.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55E451E8.1080005@suse.cz>
Date: Mon, 31 Aug 2015 15:08:56 +0200
MIME-Version: 1.0
In-Reply-To: <1441000720-28506-1-git-send-email-liuchangsheng@inspur.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Changsheng Liu <liuchangsheng@inspur.com>, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, yasu.isimatu@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, wunan@inspur.com, yanxiaofeng@inspur.com, fandd@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>

On 08/31/2015 07:58 AM, Changsheng Liu wrote:
> From: Changsheng Liu <liuchangcheng@inspur.com>
>
> After the user config CONFIG_MOVABLE_NODE and movable_node kernel option,
> When the memory is hot added, should_add_memory_movable() return 0
> because all zones including movable zone are empty,
> so the memory that was hot added will be added  to the normal zone
> and the normal zone will be created firstly.
> But we want the whole node to be added to movable zone defaultly.
>
> So we change should_add_memory_movable(): if the user config
> CONFIG_MOVABLE_NODE and movable_node kernel option
> it will always return 1 and all zones is empty at the same time,
> so that the movable zone will be created firstly
> and then the whole node will be added to movable zone defaultly.
> If we want the node to be added to normal zone,
> we can do it as follows:
> "echo online_kernel > /sys/devices/system/memory/memoryXXX/state"
>
> If the memory is added to movable zone defaultly,
> the user can offline it and add it to other zone again.
> But if the memory is added to normal zone defaultly,
> the user will not offline the memory used by kernel.
>
> Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
> Reviewed-by: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
> Reviewed-by: Vlastimil Babka <vbabka@suse.cz>
> Reviewed-by: Xiaofeng Yan <yanxiaofeng@inspur.com>

Thanks for the credit for commenting on the previous versions of the 
patch. However, "Reviewed-by" currently means that the reviewer believes 
the patch is OK, so you can add it only if the reviewer offers it 
explicitly. See Documentation/SubmittingPatches section 13. There was a 
discussion on ksummit-discuss about adding a new tag for this case, but 
nothing was decided yet AFAIK.

> Signed-off-by: Changsheng Liu <liuchangcheng@inspur.com>
> Tested-by: Dongdong Fan <fandd@inspur.com>
> ---
>   mm/memory_hotplug.c |    5 +++++
>   1 files changed, 5 insertions(+), 0 deletions(-)
>
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 26fbba7..d1149ff 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1197,6 +1197,11 @@ static int should_add_memory_movable(int nid, u64 start, u64 size)
>   	unsigned long start_pfn = start >> PAGE_SHIFT;
>   	pg_data_t *pgdat = NODE_DATA(nid);
>   	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
> +	struct zone *normal_zone = pgdat->node_zones + ZONE_NORMAL;
> +
> +	if (movable_node_is_enabled()
> +	&& (zone_end_pfn(normal_zone) <= start_pfn))
> +		return 1;

I wonder if the condition is true and ZONE_NORMAL exists (but it's 
empty?) if you intend to only add movable memory to a node, so you can 
still hot-remove it all with this patch?

>
>   	if (zone_is_empty(movable_zone))
>   		return 0;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
