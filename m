Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C34716B0292
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 07:53:53 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 56so22446386wrx.5
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 04:53:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z142si7175581wmc.38.2017.06.12.04.53.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Jun 2017 04:53:52 -0700 (PDT)
Subject: Re: [RFC PATCH 4/4] hugetlb: add support for preferred node to
 alloc_huge_page_nodemask
References: <20170608074553.22152-1-mhocko@kernel.org>
 <20170608074553.22152-5-mhocko@kernel.org>
 <a41926b2-1e49-d6a6-f92e-5ebf2fa101e3@suse.cz>
 <20170612090656.GD7476@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <cb18b8ad-af25-b269-3808-5a7452ee2d60@suse.cz>
Date: Mon, 12 Jun 2017 13:53:51 +0200
MIME-Version: 1.0
In-Reply-To: <20170612090656.GD7476@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, zhong jiang <zhongjiang@huawei.com>, Joonsoo Kim <js1304@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On 06/12/2017 11:06 AM, Michal Hocko wrote:
> On Thu 08-06-17 10:38:06, Vlastimil Babka wrote:
>> On 06/08/2017 09:45 AM, Michal Hocko wrote:
>>> From: Michal Hocko <mhocko@suse.com>
>>>
>>> alloc_huge_page_nodemask tries to allocate from any numa node in the
>>> allowed node mask. This might lead to filling up low NUMA nodes while
>>> others are not used. We can reduce this risk by introducing a concept
>>> of the preferred node similar to what we have in the regular page
>>> allocator. We will start allocating from the preferred nid and then
>>> iterate over all allowed nodes until we try them all. Introduce
>>> for_each_node_mask_preferred helper which does the iteration and reuse
>>> the available preferred node in new_page_nodemask which is currently
>>> the only caller of alloc_huge_page_nodemask.
>>>
>>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>>
>> That's better, yeah. I don't think it would be too hard to use a
>> zonelist though. What do others think?
> 
> OK, so I've given it a try. This is untested yet but it doesn't look all
> that bad. dequeue_huge_page_node will most proably see some clean up on
> top but I've kept it for simplicity for now.
> ---
> From 597ab787ac081b57db13ce5576700163d0c1208c Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 7 Jun 2017 10:31:59 +0200
> Subject: [PATCH] hugetlb: add support for preferred node to
>  alloc_huge_page_nodemask
> 
> alloc_huge_page_nodemask tries to allocate from any numa node in the
> allowed node mask. This might lead to filling up low NUMA nodes while
> others are not used. We can reduce this risk by introducing a concept
> of the preferred node similar to what we have in the regular page
> allocator. We will start allocating from the preferred nid and then
> iterate over all allowed nodes in the zonelist order until we try them
> all.
> 
> This is mimicking the page allocator logic except it operates on
> per-node mempools. dequeue_huge_page_vma already does this so distill
> the zonelist logic into a more generic dequeue_huge_page_nodemask
> and use it in alloc_huge_page_nodemask.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/hugetlb.h |   3 +-
>  include/linux/migrate.h |   2 +-
>  mm/hugetlb.c            | 111 +++++++++++++++++++++++++-----------------------
>  3 files changed, 60 insertions(+), 56 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index c469191bb13b..d4c33a8583be 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -349,7 +349,8 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
>  struct page *alloc_huge_page_node(struct hstate *h, int nid);
>  struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
>  				unsigned long addr, int avoid_reserve);
> -struct page *alloc_huge_page_nodemask(struct hstate *h, const nodemask_t *nmask);
> +struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
> +				nodemask_t *nmask);
>  int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
>  			pgoff_t idx);
>  
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
> index 01c11ceb47d6..bbb3a1a46c64 100644
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
>  	}
> +	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
> +		goto retry_cpuset;
> +
>  	return NULL;
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

This with nid == NUMA_NO_NODE will break at node_zonelist(nid,
gfp_mask); in dequeue_huge_page_nodemask(). I guess just use the local
node as preferred.

>  }
>  
>  static struct page *dequeue_huge_page_vma(struct hstate *h,
> @@ -927,15 +956,10 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
>  				unsigned long address, int avoid_reserve,
>  				long chg)
>  {
> -	struct page *page = NULL;
> +	struct page *page;
>  	struct mempolicy *mpol;
>  	nodemask_t *nodemask;
> -	gfp_t gfp_mask;
>  	int nid;
> -	struct zonelist *zonelist;
> -	struct zone *zone;
> -	struct zoneref *z;
> -	unsigned int cpuset_mems_cookie;
>  
>  	/*
>  	 * A child process with MAP_PRIVATE mappings created by their parent
> @@ -950,32 +974,14 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
>  	if (avoid_reserve && h->free_huge_pages - h->resv_huge_pages == 0)
>  		goto err;
>  
> -retry_cpuset:
> -	cpuset_mems_cookie = read_mems_allowed_begin();
> -	gfp_mask = htlb_alloc_mask(h);
> -	nid = huge_node(vma, address, gfp_mask, &mpol, &nodemask);
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
> +	nid = huge_node(vma, address, htlb_alloc_mask(h), &mpol, &nodemask);
> +	page = dequeue_huge_page_nodemask(h, nid, nodemask);
> +	if (page && !(avoid_reserve || (!vma_has_reserves(vma, chg)))) {

Ugh that's hard to parse.
What about: if (page && !avoid_reserve && vma_has_reserves(...)) ?

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
>  
>  	return NULL;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
