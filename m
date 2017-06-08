Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E726E6B02C3
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 04:36:17 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 56so4161996wrx.5
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 01:36:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j39si4674259wre.70.2017.06.08.01.36.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Jun 2017 01:36:16 -0700 (PDT)
Subject: Re: [PATCH 3/4] mm: unify new_node_page and alloc_migrate_target
References: <20170608074553.22152-1-mhocko@kernel.org>
 <20170608074553.22152-4-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7449f1dc-e51f-7b91-ef73-f69cf3eff294@suse.cz>
Date: Thu, 8 Jun 2017 10:36:13 +0200
MIME-Version: 1.0
In-Reply-To: <20170608074553.22152-4-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, zhong jiang <zhongjiang@huawei.com>, Joonsoo Kim <js1304@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 06/08/2017 09:45 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> 394e31d2ceb4 ("mem-hotplug: alloc new page from a nearest neighbor node
> when mem-offline") has duplicated a large part of alloc_migrate_target
> with some hotplug specific special casing. To be more precise it tried
> to enfore the allocation from a different node than the original page.
> As a result the two function diverged in their shared logic, e.g. the
> hugetlb allocation strategy. Let's unify the two and express different
> NUMA requirements by the given nodemask. new_node_page will simply
> exclude the node it doesn't care about and alloc_migrate_target will
> use all the available nodes. alloc_migrate_target will then learn to
> migrate hugetlb pages more sanely and use preallocated pool when
> possible.
> 
> Please note that alloc_migrate_target used to call alloc_page resp.
> alloc_pages_current so the memory policy of the current context which
> is quite strange when we consider that it is used in the context of
> alloc_contig_range which just tries to migrate pages which stand in the
> way.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 3606104893e0..757410d9f758 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -8,6 +8,7 @@
>  #include <linux/memory.h>
>  #include <linux/hugetlb.h>
>  #include <linux/page_owner.h>
> +#include <linux/migrate.h>
>  #include "internal.h"
>  
>  #define CREATE_TRACE_POINTS
> @@ -294,20 +295,5 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
>  struct page *alloc_migrate_target(struct page *page, unsigned long private,
>  				  int **resultp)
>  {
> -	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
> -
> -	/*
> -	 * TODO: allocate a destination hugepage from a nearest neighbor node,
> -	 * accordance with memory policy of the user process if possible. For
> -	 * now as a simple work-around, we use the next node for destination.
> -	 */
> -	if (PageHuge(page))
> -		return alloc_huge_page_node(page_hstate(compound_head(page)),
> -					    next_node_in(page_to_nid(page),
> -							 node_online_map));
> -
> -	if (PageHighMem(page))
> -		gfp_mask |= __GFP_HIGHMEM;
> -
> -	return alloc_page(gfp_mask);
> +	return new_page_nodemask(page, numa_node_id(), &node_states[N_MEMORY]);

This replaces the N_ONLINE (node_online_map) with N_MEMORY for huge
pages. Assuming that's OK.

>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
