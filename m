Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4828A6B0278
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 14:15:02 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l132so31471227wmf.0
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 11:15:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q1si9578958wma.87.2016.09.21.11.15.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Sep 2016 11:15:01 -0700 (PDT)
Date: Wed, 21 Sep 2016 20:14:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mem-hotplug: Use nodes that contain memory as mask in
 new_node_page()
Message-ID: <20160921181458.GJ24210@dhcp22.suse.cz>
References: <1473044391.4250.19.camel@TP420>
 <d7393a3e-73a7-7923-bc32-d4dcbc6523f9@suse.cz>
 <20160912091811.GE14524@dhcp22.suse.cz>
 <c144f768-7591-8bb8-4238-b3f1ecaf8b4b@suse.cz>
 <alpine.DEB.2.10.1609201413210.84794@chino.kir.corp.google.com>
 <1474447117.28370.6.camel@TP420>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474447117.28370.6.camel@TP420>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhong <zhong@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, jallen@linux.vnet.ibm.com, qiuxishi@huawei.com, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Wed 21-09-16 16:38:37, Li Zhong wrote:
> Commit 9bb627be47a5 ("mem-hotplug: don't clear the only node in
> new_node_page()") prevents allocating from an empty nodemask, but as David
> points out, it is still wrong. As node_online_map may include memoryless
> nodes, only allocating from these nodes is meaningless.
> 
> This patch uses node_states[N_MEMORY] mask to prevent the above case.
> 

OK, this is much better

I believe this should have

Fixes: 9bb627be47a5 ("mem-hotplug: don't clear the only node in new_node_page()")
Fixes: 394e31d2ceb4 ("mem-hotplug: alloc new page from a nearest neighbor node when mem-offline")

Fortunatelly everything is 4.8 so we do not need any backporting to
stable. Anyway this just shows that the hotplug patches need much better
review. E.g. 394e31d2ceb4 didn't have a single ack or r-b. Sigh

> Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
> ---
>  mm/memory_hotplug.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index b58906b..9d29ba0 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1555,8 +1555,8 @@ static struct page *new_node_page(struct page *page, unsigned long private,
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
> @@ -1567,14 +1567,14 @@ static struct page *new_node_page(struct page *page, unsigned long private,
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
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
