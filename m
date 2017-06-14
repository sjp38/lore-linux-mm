Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 77AE083292
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 12:23:02 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y39so1505749wry.10
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 09:23:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b51si470547wrd.208.2017.06.14.09.23.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 09:23:01 -0700 (PDT)
Subject: Re: [RFC PATCH 4/4] mm, hugetlb, soft_offline: use new_page_nodemask
 for soft offline migration
References: <20170613090039.14393-1-mhocko@kernel.org>
 <20170613090039.14393-5-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1fdaa94e-33a7-f280-d682-1ffb0b8547db@suse.cz>
Date: Wed, 14 Jun 2017 18:22:21 +0200
MIME-Version: 1.0
In-Reply-To: <20170613090039.14393-5-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 06/13/2017 11:00 AM, Michal Hocko wrote:
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
> 
> Noticed-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

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
