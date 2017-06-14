Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5604483292
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 12:18:00 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v60so1492219wrc.7
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 09:18:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i9si457930wmb.35.2017.06.14.09.17.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 09:17:58 -0700 (PDT)
Subject: Re: [RFC PATCH 2/4] hugetlb: add support for preferred node to
 alloc_huge_page_nodemask
References: <20170613090039.14393-1-mhocko@kernel.org>
 <20170613090039.14393-3-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1b208520-8d4b-9a58-7384-1a031b610e15@suse.cz>
Date: Wed, 14 Jun 2017 18:17:18 +0200
MIME-Version: 1.0
In-Reply-To: <20170613090039.14393-3-mhocko@kernel.org>
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
> alloc_huge_page_nodemask tries to allocate from any numa node in the
> allowed node mask starting from lower numa nodes. This might lead to
> filling up those low NUMA nodes while others are not used. We can reduce
> this risk by introducing a concept of the preferred node similar to what
> we have in the regular page allocator. We will start allocating from the
> preferred nid and then iterate over all allowed nodes in the zonelist
> order until we try them all.
> 
> This is mimicking the page allocator logic except it operates on
> per-node mempools. dequeue_huge_page_vma already does this so distill
> the zonelist logic into a more generic dequeue_huge_page_nodemask
> and use it in alloc_huge_page_nodemask.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

I've reviewed the current version in git, where patch 3/4 is folded.

Noticed some things below, but after fixing:
Acked-by: Vlastimil Babka <vbabka@suse.cz>


> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -897,29 +897,58 @@ static struct page *dequeue_huge_page_node_exact(struct hstate *h, int nid)
>  	return page;
>  }
>  
> -static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
> +/* Movability of hugepages depends on migration support. */
> +static inline gfp_t htlb_alloc_mask(struct hstate *h)
>  {
> -	struct page *page;
> -	int node;
> +	if (hugepages_treat_as_movable || hugepage_migration_supported(h))
> +		return GFP_HIGHUSER_MOVABLE;
> +	else
> +		return GFP_HIGHUSER;
> +}
>  
> -	if (nid != NUMA_NO_NODE)
> -		return dequeue_huge_page_node_exact(h, nid);
> +static struct page *dequeue_huge_page_nodemask(struct hstate *h, int nid,
> +		nodemask_t *nmask)
> +{
> +	unsigned int cpuset_mems_cookie;
> +	struct zonelist *zonelist;
> +	struct page *page = NULL;
> +	struct zone *zone;
> +	struct zoneref *z;
> +	gfp_t gfp_mask;
> +	int node = -1;
> +
> +	gfp_mask = htlb_alloc_mask(h);
> +	zonelist = node_zonelist(nid, gfp_mask);
> +
> +retry_cpuset:
> +	cpuset_mems_cookie = read_mems_allowed_begin();
> +	for_each_zone_zonelist_nodemask(zone, z, zonelist, gfp_zone(gfp_mask), nmask) {
> +		if (!cpuset_zone_allowed(zone, gfp_mask))
> +			continue;
> +		/*
> +		 * no need to ask again on the same node. Pool is node rather than
> +		 * zone aware
> +		 */
> +		if (zone_to_nid(zone) == node)
> +			continue;
> +		node = zone_to_nid(zone);
>  
> -	for_each_online_node(node) {
>  		page = dequeue_huge_page_node_exact(h, node);
>  		if (page)
> -			return page;
> +			break;

Either keep return page here...

>  	}
> +	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
> +		goto retry_cpuset;
> +
>  	return NULL;

... or return page here.

>  }
>  
> -/* Movability of hugepages depends on migration support. */
> -static inline gfp_t htlb_alloc_mask(struct hstate *h)
> +static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
>  {
> -	if (hugepages_treat_as_movable || hugepage_migration_supported(h))
> -		return GFP_HIGHUSER_MOVABLE;
> -	else
> -		return GFP_HIGHUSER;
> +	if (nid != NUMA_NO_NODE)
> +		return dequeue_huge_page_node_exact(h, nid);
> +
> +	return dequeue_huge_page_nodemask(h, nid, NULL);
>  }
>  

...

> @@ -1655,25 +1661,25 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
>  	return page;
>  }
>  
> -struct page *alloc_huge_page_nodemask(struct hstate *h, nodemask_t *nmask)
> +
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

This doesn't seem needed?

>  	spin_unlock(&hugetlb_lock);
>  	if (page)
>  		return page;
>  
>  	/* No reservations, try to overcommit */
> -	return __alloc_buddy_huge_page(h, NUMA_NO_NODE, nmask);
> +	return __alloc_buddy_huge_page(h, preferred_nid, nmask);
>  }
>  
>  /*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
