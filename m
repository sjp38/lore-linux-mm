Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 20B0B6B0292
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 11:21:13 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 56so23491706wrx.5
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 08:21:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 36si9634480wrt.302.2017.06.12.08.21.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Jun 2017 08:21:11 -0700 (PDT)
Date: Mon, 12 Jun 2017 17:21:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 4/4] hugetlb: add support for preferred node to
 alloc_huge_page_nodemask
Message-ID: <20170612152108.GM7476@dhcp22.suse.cz>
References: <20170608074553.22152-1-mhocko@kernel.org>
 <20170608074553.22152-5-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170608074553.22152-5-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, zhong jiang <zhongjiang@huawei.com>, Joonsoo Kim <js1304@gmail.com>, LKML <linux-kernel@vger.kernel.org>

JFTR, I am dropping this patch and will follow up with a series which
will make the hugetlb allocation reflect node/zone ordering. It doesn't
make much sense to wait for those with this series because it doesn't
depend  on it.

I have some preliminary work but I would like to give it few days before
I post it.

On Thu 08-06-17 09:45:53, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> alloc_huge_page_nodemask tries to allocate from any numa node in the
> allowed node mask. This might lead to filling up low NUMA nodes while
> others are not used. We can reduce this risk by introducing a concept
> of the preferred node similar to what we have in the regular page
> allocator. We will start allocating from the preferred nid and then
> iterate over all allowed nodes until we try them all. Introduce
> for_each_node_mask_preferred helper which does the iteration and reuse
> the available preferred node in new_page_nodemask which is currently
> the only caller of alloc_huge_page_nodemask.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/hugetlb.h  |  3 ++-
>  include/linux/migrate.h  |  2 +-
>  include/linux/nodemask.h | 20 ++++++++++++++++++++
>  mm/hugetlb.c             |  9 ++++++---
>  4 files changed, 29 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index c469191bb13b..9831a4434dd7 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -349,7 +349,8 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
>  struct page *alloc_huge_page_node(struct hstate *h, int nid);
>  struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
>  				unsigned long addr, int avoid_reserve);
> -struct page *alloc_huge_page_nodemask(struct hstate *h, const nodemask_t *nmask);
> +struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
> +				const nodemask_t *nmask);
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
> diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
> index cf0b91c3ec12..797aa74392bc 100644
> --- a/include/linux/nodemask.h
> +++ b/include/linux/nodemask.h
> @@ -42,6 +42,8 @@
>   * void nodes_shift_left(dst, src, n)	Shift left
>   *
>   * int first_node(mask)			Number lowest set bit, or MAX_NUMNODES
> + * int first_node_from(nid, mask)	First node starting from nid, or wrap
> + * 					from first or MAX_NUMNODES
>   * int next_node(node, mask)		Next node past 'node', or MAX_NUMNODES
>   * int next_node_in(node, mask)		Next node past 'node', or wrap to first,
>   *					or MAX_NUMNODES
> @@ -268,6 +270,15 @@ static inline int __next_node(int n, const nodemask_t *srcp)
>  #define next_node_in(n, src) __next_node_in((n), &(src))
>  int __next_node_in(int node, const nodemask_t *srcp);
>  
> +#define first_node_from(nid, mask) __first_node_from(nid, &(mask))
> +static inline int __first_node_from(int nid, const nodemask_t *mask)
> +{
> +	if (test_bit(nid, mask->bits))
> +		return nid;
> +
> +	return __next_node_in(nid, mask);
> +}
> +
>  static inline void init_nodemask_of_node(nodemask_t *mask, int node)
>  {
>  	nodes_clear(*mask);
> @@ -369,10 +380,19 @@ static inline void __nodes_fold(nodemask_t *dstp, const nodemask_t *origp,
>  	for ((node) = first_node(mask);			\
>  		(node) < MAX_NUMNODES;			\
>  		(node) = next_node((node), (mask)))
> +
> +#define for_each_node_mask_preferred(node, iter, preferred, mask)	\
> +	for ((node) = first_node_from((preferred), (mask)), iter = 0;	\
> +		(iter) < nodes_weight((mask));				\
> +		(node) = next_node_in((node), (mask)), (iter)++)
> +
>  #else /* MAX_NUMNODES == 1 */
>  #define for_each_node_mask(node, mask)			\
>  	if (!nodes_empty(mask))				\
>  		for ((node) = 0; (node) < 1; (node)++)
> +
> +#define for_each_node_mask_preferred(node, iter, preferred, mask) \
> +	for_each_node_mask(node, mask)
>  #endif /* MAX_NUMNODES */
>  
>  /*
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 01c11ceb47d6..ebf5c9b890d5 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1723,14 +1723,17 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
>  	return page;
>  }
>  
> -struct page *alloc_huge_page_nodemask(struct hstate *h, const nodemask_t *nmask)
> +struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
> +		const nodemask_t *nmask)
>  {
>  	struct page *page = NULL;
> +	int iter;
>  	int node;
>  
>  	spin_lock(&hugetlb_lock);
>  	if (h->free_huge_pages - h->resv_huge_pages > 0) {
> -		for_each_node_mask(node, *nmask) {
> +		/* It would be nicer to iterate in the node distance order */
> +		for_each_node_mask_preferred(node, iter, preferred_nid, *nmask) {
>  			page = dequeue_huge_page_node_exact(h, node);
>  			if (page)
>  				break;
> @@ -1741,7 +1744,7 @@ struct page *alloc_huge_page_nodemask(struct hstate *h, const nodemask_t *nmask)
>  		return page;
>  
>  	/* No reservations, try to overcommit */
> -	for_each_node_mask(node, *nmask) {
> +	for_each_node_mask_preferred(node, iter, preferred_nid, *nmask) {
>  		page = __alloc_buddy_huge_page_no_mpol(h, node);
>  		if (page)
>  			return page;
> -- 
> 2.11.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
