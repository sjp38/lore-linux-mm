Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 63BAF6B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 14:32:12 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id p193so2508674vkd.11
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 11:32:12 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r64si281893vkb.122.2017.06.26.11.32.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 11:32:11 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm, hugetlb, soft_offline: use new_page_nodemask for
 soft offline migration
References: <20170622193034.28972-1-mhocko@kernel.org>
 <20170622193034.28972-4-mhocko@kernel.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <4e8d3e08-ec5d-7386-a592-4cf68e432c8c@oracle.com>
Date: Mon, 26 Jun 2017 11:32:02 -0700
MIME-Version: 1.0
In-Reply-To: <20170622193034.28972-4-mhocko@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 06/22/2017 12:30 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> new_page is yet another duplication of the migration callback which has
> to handle hugetlb migration specially. We can safely use the generic
> new_page_nodemask for the same purpose.
> 
> Please note that gigantic hugetlb pages do not need any special handling
> because alloc_huge_page_nodemask will make sure to check pages in all
> per node pools. The reason this was done previously was that
> alloc_huge_page_node treated NO_NUMA_NODE and a specific node
> differently and so alloc_huge_page_node(nid) would check on this
> specific node.

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
Tested-by: Mike Kravetz <mike.kravetz@oracle.com>

-- 
Mike Kravetz

> 
> Noticed-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/memory-failure.c | 10 +---------
>  1 file changed, 1 insertion(+), 9 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 3615bffbd269..7040f60ecb71 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1487,16 +1487,8 @@ EXPORT_SYMBOL(unpoison_memory);
>  static struct page *new_page(struct page *p, unsigned long private, int **x)
>  {
>  	int nid = page_to_nid(p);
> -	if (PageHuge(p)) {
> -		struct hstate *hstate = page_hstate(compound_head(p));
>  
> -		if (hstate_is_gigantic(hstate))
> -			return alloc_huge_page_node(hstate, NUMA_NO_NODE);
> -
> -		return alloc_huge_page_node(hstate, nid);
> -	} else {
> -		return __alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
> -	}
> +	return new_page_nodemask(p, nid, &node_states[N_MEMORY]);
>  }
>  
>  /*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
