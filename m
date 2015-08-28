Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3A9BF6B0254
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 16:22:32 -0400 (EDT)
Received: by qgeh99 with SMTP id h99so38045177qge.0
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 13:22:32 -0700 (PDT)
Received: from mail-qk0-x22e.google.com (mail-qk0-x22e.google.com. [2607:f8b0:400d:c09::22e])
        by mx.google.com with ESMTPS id 140si8538123qhf.90.2015.08.28.13.22.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 13:22:31 -0700 (PDT)
Received: by qkbm65 with SMTP id m65so34893748qkb.2
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 13:22:31 -0700 (PDT)
Message-ID: <55e0c306.4521370a.5c130.ffffa456@mx.google.com>
Date: Fri, 28 Aug 2015 13:22:30 -0700 (PDT)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH V3] mm: memory hot-add: memory can not be added to
 movable zone defaultly
In-Reply-To: <1440665641-3839-1-git-send-email-liuchangsheng@inspur.com>
References: <1440665641-3839-1-git-send-email-liuchangsheng@inspur.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Changsheng Liu <liuchangsheng@inspur.com>
Cc: akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wunan@inspur.com, yanxiaofeng@inspur.com, fandd@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>


On Thu, 27 Aug 2015 04:54:01 -0400
Changsheng Liu <liuchangsheng@inspur.com> wrote:

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
> Signed-off-by: Changsheng Liu <liuchangcheng@inspur.com>i
> Tested-by: Dongdong Fan <fandd@inspur.com>
> ---
>  mm/memory_hotplug.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 26fbba7..b5f14fa 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1198,6 +1198,9 @@ static int should_add_memory_movable(int nid, u64 start, u64 size)
>  	pg_data_t *pgdat = NODE_DATA(nid);
>  	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
>  
> +	if (movable_node_is_enabled())
> +		return 1;
> +
>  	if (zone_is_empty(movable_zone))
>  		return 0;

Your patch cannot prevent from creating ZONE_MOVABLE before/in
ZONE_NORAML. Please check that start PFN of hot added memory is
after ZONE_NORAML.

Thanks,
Yasuaki Ishimatsu


>  
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
