Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0CEAD6B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 09:12:23 -0400 (EDT)
Received: by qkda128 with SMTP id a128so50050367qkd.3
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 06:12:22 -0700 (PDT)
Received: from mail-qg0-x22d.google.com (mail-qg0-x22d.google.com. [2607:f8b0:400d:c04::22d])
        by mx.google.com with ESMTPS id n63si18774233qkh.4.2015.08.25.06.12.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 06:12:22 -0700 (PDT)
Received: by qgeg42 with SMTP id g42so106166490qge.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 06:12:22 -0700 (PDT)
Message-ID: <55dc69b5.46268c0a.faa78.24eb@mx.google.com>
Date: Tue, 25 Aug 2015 06:12:21 -0700 (PDT)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH V2] mm:memory hot-add: memory can not been added to
 movable zone
In-Reply-To: <1440055685-6083-1-git-send-email-liuchangsheng@inspur.com>
References: <1440055685-6083-1-git-send-email-liuchangsheng@inspur.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Changsheng Liu <liuchangsheng@inspur.com>
Cc: akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yanxiaofeng@inspur.com, fandd@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>


On Thu, 20 Aug 2015 03:28:05 -0400
Changsheng Liu <liuchangsheng@inspur.com> wrote:

> From: Changsheng Liu <liuchangcheng@inspur.com>
> 
> When memory is hot added, should_add_memory_movable() always returns 0
> because the movable zone is empty, so the memory that was hot added will
> add to the normal zone even if we want to remove the memory.
> 
> So we change should_add_memory_movable(): if the user config
> CONFIG_MOVABLE_NODE it will return 1 when the movable zone is empty.
> 
> Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Changsheng Liu <liuchangcheng@inspur.com>
> Tested-by: Dongdong Fan <fandd@inspur.com>
> ---
>  mm/memory_hotplug.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 26fbba7..ff658f2 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1199,8 +1199,7 @@ static int should_add_memory_movable(int nid, u64 start, u64 size)
>  	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
>  

>  	if (zone_is_empty(movable_zone))
> -		return 0;
> -
> +		return IS_ENABLED(CONFIG_MOVABLE_NODE);
>  	if (movable_zone->zone_start_pfn <= start_pfn)
>  		return 1;

Currently, kernel allows to create ZONE_MOVABLE after ZONE_NORMAL as follows:
 PFN low                                 high 
       ---|-------------|-------------|---
            ZONE_NORMAL   ZONE_MOVABLE

But kernel does not allow to create ZONE_MOVABLE before ZONE_NORMAL as follows:
 PFN low                                 high 
       ---|-------------|-------------|---
            ZONE_MOVABLE  ZONE_NORMAL

Also, kernel does not allow to create ZONE_MOVABLE in ZOME_NORMAL as follows:
 PFN low                                              high 
       ---|-------------|-------------|-------------|---
            ZONE_NORMAL   ZONE_MOVABLE  ZONE_NORMAL

So should_add_memory_movable() checks them.

Accoring to your patch, when movable_zone is empty, the hot added memory is
always managed to ZONE_MOVABLE. It means that ZONE_MOVALBE will puts before/in
ZONE_NORMAL.

You must prevent from creating ZONE_MOVABLE before/in ZONE_NORMAL.

Thanks,
Yasuaki Ishimatsu

>  
> -- 
> 1.7.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
