Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 50E0682F64
	for <linux-mm@kvack.org>; Mon,  5 Sep 2016 10:18:44 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w12so9275560wmf.3
        for <linux-mm@kvack.org>; Mon, 05 Sep 2016 07:18:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i89si17608998wmc.142.2016.09.05.07.18.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Sep 2016 07:18:43 -0700 (PDT)
Subject: Re: [PATCH] mem-hotplug: Don't clear the only node in new_node_page()
References: <1473044391.4250.19.camel@TP420>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d7393a3e-73a7-7923-bc32-d4dcbc6523f9@suse.cz>
Date: Mon, 5 Sep 2016 16:18:29 +0200
MIME-Version: 1.0
In-Reply-To: <1473044391.4250.19.camel@TP420>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhong <zhong@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>
Cc: jallen@linux.vnet.ibm.com, qiuxishi@huawei.com, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, rientjes@google.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On 09/05/2016 04:59 AM, Li Zhong wrote:
> Commit 394e31d2c introduced new_node_page() for memory hotplug.
>
> In new_node_page(), the nid is cleared before calling __alloc_pages_nodemask().
> But if it is the only node of the system,

So the use case is that we are partially offlining the only online node?

> and the first round allocation fails,
> it will not be able to get memory from an empty nodemask, and trigger oom.

Hmm triggering OOM due to empty nodemask sounds like a wrong thing to do. CCing 
some OOM experts for insight. Also OOM is skipped for __GFP_THISNODE 
allocations, so we might also consider the same for nodemask-constrained 
allocations?

> The patch checks whether it is the last node on the system, and if it is, then
> don't clear the nid in the nodemask.

I'd rather see the allocation not OOM, and rely on the fallback in 
new_node_page() that doesn't have nodemask. But I suspect it might also make 
sense to treat empty nodemask as something unexpected and put some WARN_ON 
(instead of OOM) in the allocator.

> Reported-by: John Allen <jallen@linux.vnet.ibm.com>
> Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Fixes: 394e31d2ceb4 ("mem-hotplug: alloc new page from a nearest neighbor node 
when mem-offline")

> ---
>  mm/memory_hotplug.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 41266dc..b58906b 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1567,7 +1567,9 @@ static struct page *new_node_page(struct page *page, unsigned long private,
>  		return alloc_huge_page_node(page_hstate(compound_head(page)),
>  					next_node_in(nid, nmask));
>
> -	node_clear(nid, nmask);
> +	if (nid != next_node_in(nid, nmask))
> +		node_clear(nid, nmask);
> +
>  	if (PageHighMem(page)
>  	    || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
>  		gfp_mask |= __GFP_HIGHMEM;
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
