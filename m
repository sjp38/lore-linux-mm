Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4501C6B02A4
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 03:49:07 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l138so65165472wmg.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 00:49:07 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id e189si24757998wmg.45.2016.09.29.00.49.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 00:49:06 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id w84so9345366wmg.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 00:49:06 -0700 (PDT)
Date: Thu, 29 Sep 2016 09:49:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: +
 mem-hotplug-use-nodes-that-contain-memory-as-mask-in-new_node_page.patch
 added to -mm tree
Message-ID: <20160929074904.GA408@dhcp22.suse.cz>
References: <57eaed8d.jsvNqvcRh8NfPZzb%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57eaed8d.jsvNqvcRh8NfPZzb%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: zhong@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, jallen@linux.vnet.ibm.com, n-horiguchi@ah.jp.nec.com, penguin-kernel@i-love.sakura.ne.jp, qiuxishi@huawei.com, rientjes@google.com, vbabka@suse.cz, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Tue 27-09-16 15:07:09, Andrew Morton wrote:
> From: Li Zhong <zhong@linux.vnet.ibm.com>
> Subject: mem-hotplug: use nodes that contain memory as mask in new_node_page()
> 
> 9bb627be47a5 ("mem-hotplug: don't clear the only node in new_node_page()")
> prevents allocating from an empty nodemask, but as David points out, it is
> still wrong.  As node_online_map may include memoryless nodes, only
> allocating from these nodes is meaningless.
> 
> This patch uses node_states[N_MEMORY] mask to prevent the above case.
> 
> Fixes: 9bb627be47a5 ("mem-hotplug: don't clear the only node in new_node_page()")
> Fixes: 394e31d2ceb4 ("mem-hotplug: alloc new page from a nearest neighbor node when mem-offline")
> Link: http://lkml.kernel.org/r/1474447117.28370.6.camel@TP420
> Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
> Suggested-by: David Rientjes <rientjes@google.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Michal Hocko <mhocko@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

> Cc: John Allen <jallen@linux.vnet.ibm.com>
> Cc: Xishi Qiu <qiuxishi@huawei.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/memory_hotplug.c |   10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff -puN mm/memory_hotplug.c~mem-hotplug-use-nodes-that-contain-memory-as-mask-in-new_node_page mm/memory_hotplug.c
> --- a/mm/memory_hotplug.c~mem-hotplug-use-nodes-that-contain-memory-as-mask-in-new_node_page
> +++ a/mm/memory_hotplug.c
> @@ -1555,8 +1555,8 @@ static struct page *new_node_page(struct
>  {
>  	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
>  	int nid = page_to_nid(page);
> -	nodemask_t nmask = node_online_map;
> -	struct page *new_page;
> +	nodemask_t nmask = node_states[N_MEMORY];
> +	struct page *new_page = NULL;
>  
>  	/*
>  	 * TODO: allocate a destination hugepage from a nearest neighbor node,
> @@ -1567,14 +1567,14 @@ static struct page *new_node_page(struct
>  		return alloc_huge_page_node(page_hstate(compound_head(page)),
>  					next_node_in(nid, nmask));
>  
> -	if (nid != next_node_in(nid, nmask))
> -		node_clear(nid, nmask);
> +	node_clear(nid, nmask);
>  
>  	if (PageHighMem(page)
>  	    || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
>  		gfp_mask |= __GFP_HIGHMEM;
>  
> -	new_page = __alloc_pages_nodemask(gfp_mask, 0,
> +	if (!nodes_empty(nmask))
> +		new_page = __alloc_pages_nodemask(gfp_mask, 0,
>  					node_zonelist(nid, gfp_mask), &nmask);
>  	if (!new_page)
>  		new_page = __alloc_pages(gfp_mask, 0,
> _
> 
> Patches currently in -mm which might be from zhong@linux.vnet.ibm.com are
> 
> mem-hotplug-use-nodes-that-contain-memory-as-mask-in-new_node_page.patch

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
