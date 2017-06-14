Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 31C456B02F4
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 12:58:36 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y39so1734750wry.10
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 09:58:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s71si548144wma.14.2017.06.14.09.58.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 09:58:34 -0700 (PDT)
Subject: Re: [RFC PATCH 2/4] hugetlb: add support for preferred node to
 alloc_huge_page_nodemask
References: <20170613090039.14393-1-mhocko@kernel.org>
 <20170613090039.14393-3-mhocko@kernel.org>
 <1b208520-8d4b-9a58-7384-1a031b610e15@suse.cz>
 <20170614164151.GA11240@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <164b0a5f-80a5-30dc-71d9-79f8a0ffe34c@suse.cz>
Date: Wed, 14 Jun 2017 18:57:55 +0200
MIME-Version: 1.0
In-Reply-To: <20170614164151.GA11240@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 06/14/2017 06:41 PM, Michal Hocko wrote:
> 
> This on top?
> ---
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 9ac0ae725c5e..f9868e095afa 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -902,7 +902,6 @@ static struct page *dequeue_huge_page_nodemask(struct hstate *h, gfp_t gfp_mask,
>  {
>  	unsigned int cpuset_mems_cookie;
>  	struct zonelist *zonelist;
> -	struct page *page = NULL;
>  	struct zone *zone;
>  	struct zoneref *z;
>  	int node = -1;
> @@ -912,6 +911,8 @@ static struct page *dequeue_huge_page_nodemask(struct hstate *h, gfp_t gfp_mask,
>  retry_cpuset:
>  	cpuset_mems_cookie = read_mems_allowed_begin();
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist, gfp_zone(gfp_mask), nmask) {
> +		struct page *page;
> +
>  		if (!cpuset_zone_allowed(zone, gfp_mask))
>  			continue;
>  		/*
> @@ -924,9 +925,9 @@ static struct page *dequeue_huge_page_nodemask(struct hstate *h, gfp_t gfp_mask,
>  
>  		page = dequeue_huge_page_node_exact(h, node);
>  		if (page)
> -			break;
> +			return page;
>  	}
> -	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
> +	if (unlikely(read_mems_allowed_retry(cpuset_mems_cookie)))
>  		goto retry_cpuset;
>  
>  	return NULL;

OK

> @@ -1655,18 +1656,18 @@ struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
>  		nodemask_t *nmask)
>  {
>  	gfp_t gfp_mask = htlb_alloc_mask(h);
> -	struct page *page = NULL;
>  
>  	spin_lock(&hugetlb_lock);
>  	if (h->free_huge_pages - h->resv_huge_pages > 0) {
> +		struct page *page;
> +
>  		page = dequeue_huge_page_nodemask(h, gfp_mask, preferred_nid, nmask);
> -		if (page)
> -			goto unlock;
> +		if (page) {
> +			spin_unlock(&hugetlb_lock);
> +			return page;
> +		}

I thought you would just continue after the if (this is not a for-loop
after all), but this works too.

>  	}
> -unlock:
>  	spin_unlock(&hugetlb_lock);
> -	if (page)
> -		return page;
>  
>  	/* No reservations, try to overcommit */
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
