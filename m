Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 853A26B0315
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 07:48:06 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id c52so22391516wra.12
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 04:48:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u66si8096312wrb.292.2017.06.12.04.48.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Jun 2017 04:48:05 -0700 (PDT)
Date: Mon, 12 Jun 2017 13:48:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 4/4] hugetlb: add support for preferred node to
 alloc_huge_page_nodemask
Message-ID: <20170612114800.GJ7476@dhcp22.suse.cz>
References: <20170608074553.22152-1-mhocko@kernel.org>
 <20170608074553.22152-5-mhocko@kernel.org>
 <a41926b2-1e49-d6a6-f92e-5ebf2fa101e3@suse.cz>
 <20170612090656.GD7476@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170612090656.GD7476@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, zhong jiang <zhongjiang@huawei.com>, Joonsoo Kim <js1304@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Mon 12-06-17 11:06:56, Michal Hocko wrote:
[...]
> @@ -1723,29 +1729,26 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
>  	return page;
>  }
>  
> -struct page *alloc_huge_page_nodemask(struct hstate *h, const nodemask_t *nmask)
> +struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
> +		nodemask_t *nmask)
>  {
>  	struct page *page = NULL;
> -	int node;
>  
>  	spin_lock(&hugetlb_lock);
>  	if (h->free_huge_pages - h->resv_huge_pages > 0) {
> -		for_each_node_mask(node, *nmask) {
> -			page = dequeue_huge_page_node_exact(h, node);
> -			if (page)
> -				break;
> -		}
> +		page = dequeue_huge_page_nodemask(h, preferred_nid, nmask);
> +		if (page)
> +			goto unlock;
>  	}
> +unlock:
>  	spin_unlock(&hugetlb_lock);
>  	if (page)
>  		return page;
>  
>  	/* No reservations, try to overcommit */
> -	for_each_node_mask(node, *nmask) {
> -		page = __alloc_buddy_huge_page_no_mpol(h, node);
> -		if (page)
> -			return page;
> -	}
> +	page = __alloc_buddy_huge_page_no_mpol(h, preferred_nid);
> +	if (page)
> +		return page;

I was too quick. The fallback allocation needs some more love. I am
working on this but it quickly gets quite hairy so let's see whether
this still can converge to something reasonable.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
