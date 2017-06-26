Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 799CF6B02B4
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 14:31:29 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 19so673472qty.2
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 11:31:29 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id v44si669583qtc.157.2017.06.26.11.31.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 11:31:28 -0700 (PDT)
Subject: Re: [PATCH 2/3] hugetlb: add support for preferred node to
 alloc_huge_page_nodemask
References: <20170622193034.28972-1-mhocko@kernel.org>
 <20170622193034.28972-3-mhocko@kernel.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <7adc4fb3-c1ef-3c9e-567f-30d91d96cbe4@oracle.com>
Date: Mon, 26 Jun 2017 11:31:18 -0700
MIME-Version: 1.0
In-Reply-To: <20170622193034.28972-3-mhocko@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 06/22/2017 12:30 PM, Michal Hocko wrote:
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
> This will allow us to use proper per numa distance fallback also for
> alloc_huge_page_node which can use alloc_huge_page_nodemask now and we
> can get rid of alloc_huge_page_node helper which doesn't have any user
> anymore.
> 
> Changes since v1
> - get rid of dequeue_huge_page_node because it is not really needed
> - simplify dequeue_huge_page_nodemask and alloc_huge_page_nodemask a bit
>   as per Vlastimil

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
Tested-by: Mike Kravetz <mike.kravetz@oracle.com>

-- 
Mike Kravetz

> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/hugetlb.h |  5 +--
>  include/linux/migrate.h |  2 +-
>  mm/hugetlb.c            | 88 ++++++++++++++++++++++++-------------------------
>  3 files changed, 48 insertions(+), 47 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 66b621469f52..8d9fe131a240 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -349,7 +349,8 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
>  struct page *alloc_huge_page_node(struct hstate *h, int nid);
>  struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
>  				unsigned long addr, int avoid_reserve);
> -struct page *alloc_huge_page_nodemask(struct hstate *h, nodemask_t *nmask);
> +struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
> +				nodemask_t *nmask);
>  int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
>  			pgoff_t idx);
>  
> @@ -525,7 +526,7 @@ static inline void set_huge_swap_pte_at(struct mm_struct *mm, unsigned long addr
>  struct hstate {};
>  #define alloc_huge_page(v, a, r) NULL
>  #define alloc_huge_page_node(h, nid) NULL
> -#define alloc_huge_page_nodemask(h, nmask) NULL
> +#define alloc_huge_page_nodemask(h, preferred_nid, nmask) NULL
>  #define alloc_huge_page_noerr(v, a, r) NULL
>  #define alloc_bootmem_huge_page(h) NULL
>  #define hstate_file(f) NULL
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index f80c9882403a..af3ccf93efaa 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -38,7 +38,7 @@ static inline struct page *new_page_nodemask(struct page *page, int preferred_ni
>  
>  	if (PageHuge(page))
>  		return alloc_huge_page_nodemask(page_hstate(compound_head(page)),
> -				nodemask);
> +				preferred_nid, nodemask);
>  
>  	if (PageHighMem(page)
>  	    || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index fd6e0c50f949..1e516520433d 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -887,19 +887,39 @@ static struct page *dequeue_huge_page_node_exact(struct hstate *h, int nid)
>  	return page;
>  }
>  
> -static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
> +static struct page *dequeue_huge_page_nodemask(struct hstate *h, gfp_t gfp_mask, int nid,
> +		nodemask_t *nmask)
>  {
> -	struct page *page;
> -	int node;
> +	unsigned int cpuset_mems_cookie;
> +	struct zonelist *zonelist;
> +	struct zone *zone;
> +	struct zoneref *z;
> +	int node = -1;
>  
> -	if (nid != NUMA_NO_NODE)
> -		return dequeue_huge_page_node_exact(h, nid);
> +	zonelist = node_zonelist(nid, gfp_mask);
> +
> +retry_cpuset:
> +	cpuset_mems_cookie = read_mems_allowed_begin();
> +	for_each_zone_zonelist_nodemask(zone, z, zonelist, gfp_zone(gfp_mask), nmask) {
> +		struct page *page;
> +
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
>  			return page;
>  	}
> +	if (unlikely(read_mems_allowed_retry(cpuset_mems_cookie)))
> +		goto retry_cpuset;
> +
>  	return NULL;
>  }
>  
> @@ -917,15 +937,11 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
>  				unsigned long address, int avoid_reserve,
>  				long chg)
>  {
> -	struct page *page = NULL;
> +	struct page *page;
>  	struct mempolicy *mpol;
> -	nodemask_t *nodemask;
>  	gfp_t gfp_mask;
> +	nodemask_t *nodemask;
>  	int nid;
> -	struct zonelist *zonelist;
> -	struct zone *zone;
> -	struct zoneref *z;
> -	unsigned int cpuset_mems_cookie;
>  
>  	/*
>  	 * A child process with MAP_PRIVATE mappings created by their parent
> @@ -940,32 +956,15 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
>  	if (avoid_reserve && h->free_huge_pages - h->resv_huge_pages == 0)
>  		goto err;
>  
> -retry_cpuset:
> -	cpuset_mems_cookie = read_mems_allowed_begin();
>  	gfp_mask = htlb_alloc_mask(h);
>  	nid = huge_node(vma, address, gfp_mask, &mpol, &nodemask);
> -	zonelist = node_zonelist(nid, gfp_mask);
> -
> -	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> -						MAX_NR_ZONES - 1, nodemask) {
> -		if (cpuset_zone_allowed(zone, gfp_mask)) {
> -			page = dequeue_huge_page_node(h, zone_to_nid(zone));
> -			if (page) {
> -				if (avoid_reserve)
> -					break;
> -				if (!vma_has_reserves(vma, chg))
> -					break;
> -
> -				SetPagePrivate(page);
> -				h->resv_huge_pages--;
> -				break;
> -			}
> -		}
> +	page = dequeue_huge_page_nodemask(h, gfp_mask, nid, nodemask);
> +	if (page && !avoid_reserve && vma_has_reserves(vma, chg)) {
> +		SetPagePrivate(page);
> +		h->resv_huge_pages--;
>  	}
>  
>  	mpol_cond_put(mpol);
> -	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
> -		goto retry_cpuset;
>  	return page;
>  
>  err:
> @@ -1633,7 +1632,7 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
>  
>  	spin_lock(&hugetlb_lock);
>  	if (h->free_huge_pages - h->resv_huge_pages > 0)
> -		page = dequeue_huge_page_node(h, nid);
> +		page = dequeue_huge_page_nodemask(h, gfp_mask, nid, NULL);
>  	spin_unlock(&hugetlb_lock);
>  
>  	if (!page)
> @@ -1642,26 +1641,27 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
>  	return page;
>  }
>  
> -struct page *alloc_huge_page_nodemask(struct hstate *h, nodemask_t *nmask)
> +
> +struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
> +		nodemask_t *nmask)
>  {
>  	gfp_t gfp_mask = htlb_alloc_mask(h);
> -	struct page *page = NULL;
> -	int node;
>  
>  	spin_lock(&hugetlb_lock);
>  	if (h->free_huge_pages - h->resv_huge_pages > 0) {
> -		for_each_node_mask(node, *nmask) {
> -			page = dequeue_huge_page_node_exact(h, node);
> -			if (page)
> -				break;
> +		struct page *page;
> +
> +		page = dequeue_huge_page_nodemask(h, gfp_mask, preferred_nid, nmask);
> +		if (page) {
> +			spin_unlock(&hugetlb_lock);
> +			return page;
>  		}
>  	}
>  	spin_unlock(&hugetlb_lock);
> -	if (page)
> -		return page;
>  
>  	/* No reservations, try to overcommit */
> -	return __alloc_buddy_huge_page(h, gfp_mask, NUMA_NO_NODE, nmask);
> +
> +	return __alloc_buddy_huge_page(h, gfp_mask, preferred_nid, nmask);
>  }
>  
>  /*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
