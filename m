Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5960E6B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 20:42:50 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id md12so1755065pbc.7
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 17:42:48 -0700 (PDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id l4si1828136pbn.293.2014.04.08.17.42.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 17:42:48 -0700 (PDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 854733EE1BE
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 09:42:46 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 74AA945DF5C
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 09:42:46 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.nic.fujitsu.com [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5024E45DF57
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 09:42:46 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 40F5B1DB8040
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 09:42:46 +0900 (JST)
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DA3B31DB803E
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 09:42:45 +0900 (JST)
Message-ID: <53449759.6040207@jp.fujitsu.com>
Date: Wed, 9 Apr 2014 09:42:01 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] hugetlb: add support for gigantic page allocation
 at runtime
References: <1396983740-26047-1-git-send-email-lcapitulino@redhat.com> <1396983740-26047-6-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1396983740-26047-6-git-send-email-lcapitulino@redhat.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, yinghai@kernel.org, riel@redhat.com, n-horiguchi@ah.jp.nec.com

(2014/04/09 4:02), Luiz Capitulino wrote:
> HugeTLB is limited to allocating hugepages whose size are less than
> MAX_ORDER order. This is so because HugeTLB allocates hugepages via
> the buddy allocator. Gigantic pages (that is, pages whose size is
> greater than MAX_ORDER order) have to be allocated at boottime.
> 
> However, boottime allocation has at least two serious problems. First,
> it doesn't support NUMA and second, gigantic pages allocated at
> boottime can't be freed.
> 
> This commit solves both issues by adding support for allocating gigantic
> pages during runtime. It works just like regular sized hugepages,
> meaning that the interface in sysfs is the same, it supports NUMA,
> and gigantic pages can be freed.
> 
> For example, on x86_64 gigantic pages are 1GB big. To allocate two 1G
> gigantic pages on node 1, one can do:
> 
>   # echo 2 > \
>     /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages
> 
> And to free them all:
> 
>   # echo 0 > \
>     /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages
> 
> The one problem with gigantic page allocation at runtime is that it
> can't be serviced by the buddy allocator. To overcome that problem, this
> commit scans all zones from a node looking for a large enough contiguous
> region. When one is found, it's allocated by using CMA, that is, we call
> alloc_contig_range() to do the actual allocation. For example, on x86_64
> we scan all zones looking for a 1GB contiguous region. When one is found,
> it's allocated by alloc_contig_range().
> 
> One expected issue with that approach is that such gigantic contiguous
> regions tend to vanish as runtime goes by. The best way to avoid this for
> now is to make gigantic page allocations very early during system boot, say
> from a init script. Other possible optimization include using compaction,
> which is supported by CMA but is not explicitly used by this commit.
> 
> It's also important to note the following:
> 
>   1. Gigantic pages allocated at boottime by the hugepages= command-line
>      option can be freed at runtime just fine
> 
>   2. This commit adds support for gigantic pages only to x86_64. The
>      reason is that I don't have access to nor experience with other archs.
>      The code is arch indepedent though, so it should be simple to add
>      support to different archs
> 
>   3. I didn't add support for hugepage overcommit, that is allocating
>      a gigantic page on demand when
>     /proc/sys/vm/nr_overcommit_hugepages > 0. The reason is that I don't
>     think it's reasonable to do the hard and long work required for
>     allocating a gigantic page at fault time. But it should be simple
>     to add this if wanted
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
> ---
>   mm/hugetlb.c | 158 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
>   1 file changed, 147 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 9dded98..2258045 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -679,11 +679,141 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
>   		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
>   		nr_nodes--)
>   
> +#if defined(CONFIG_CMA) && defined(CONFIG_X86_64)
> +static void destroy_compound_gigantic_page(struct page *page,
> +					unsigned long order)
> +{
> +	int i;
> +	int nr_pages = 1 << order;
> +	struct page *p = page + 1;
> +
> +	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
> +		__ClearPageTail(p);
> +		set_page_refcounted(p);
> +		p->first_page = NULL;
> +	}
> +
> +	set_compound_order(page, 0);
> +	__ClearPageHead(page);
> +}
> +
> +static void free_gigantic_page(struct page *page, unsigned order)
> +{
> +	free_contig_range(page_to_pfn(page), 1 << order);
> +}
> +
> +static int __alloc_gigantic_page(unsigned long start_pfn, unsigned long count)
> +{
> +	unsigned long end_pfn = start_pfn + count;
> +	return alloc_contig_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
> +}
> +
> +static bool pfn_range_valid_gigantic(unsigned long start_pfn,
> +				unsigned long nr_pages)
> +{
> +	unsigned long i, end_pfn = start_pfn + nr_pages;
> +	struct page *page;
> +
> +	for (i = start_pfn; i < end_pfn; i++) {
> +		if (!pfn_valid(i))
> +			return false;
> +
> +		page = pfn_to_page(i);
> +
> +		if (PageReserved(page))
> +			return false;
> +
> +		if (page_count(page) > 0)
> +			return false;
> +
> +		if (PageHuge(page))
> +			return false;
> +	}
> +
> +	return true;
> +}
> +
> +static struct page *alloc_gigantic_page(int nid, unsigned order)
> +{
> +	unsigned long nr_pages = 1 << order;
> +	unsigned long ret, pfn, flags;
> +	struct zone *z;
> +
> +	z = NODE_DATA(nid)->node_zones;
> +	for (; z - NODE_DATA(nid)->node_zones < MAX_NR_ZONES; z++) {
> +		spin_lock_irqsave(&z->lock, flags);
> +
> +		pfn = ALIGN(z->zone_start_pfn, nr_pages);
> +		for (; pfn < zone_end_pfn(z); pfn += nr_pages) {

> +			if (pfn_range_valid_gigantic(pfn, nr_pages)) {

How about it. It can reduce the indentation level.
			if (!pfn_range_valid_gigantic(...))
				continue;

And I think following check is necessary:
			if (pfn + nr_pages >= zone_end_pfn(z))
				break;
Thanks,
Yasuaki Ishimatsu

> +				/*
> +				 * We release the zone lock here because
> +				 * alloc_contig_range() will also lock the zone
> +				 * at some point. If there's an allocation
> +				 * spinning on this lock, it may win the race
> +				 * and cause alloc_contig_range() to fail...
> +				 */
> +				spin_unlock_irqrestore(&z->lock, flags);
> +				ret = __alloc_gigantic_page(pfn, nr_pages);
> +				if (!ret)
> +					return pfn_to_page(pfn);
> +				spin_lock_irqsave(&z->lock, flags);
> +			}
> +		}
> +
> +		spin_unlock_irqrestore(&z->lock, flags);
> +	}
> +
> +	return NULL;
> +}
> +
> +static void prep_new_huge_page(struct hstate *h, struct page *page, int nid);
> +static void prep_compound_gigantic_page(struct page *page, unsigned long order);
> +
> +static struct page *alloc_fresh_gigantic_page_node(struct hstate *h, int nid)
> +{
> +	struct page *page;
> +
> +	page = alloc_gigantic_page(nid, huge_page_order(h));
> +	if (page) {
> +		prep_compound_gigantic_page(page, huge_page_order(h));
> +		prep_new_huge_page(h, page, nid);
> +	}
> +
> +	return page;
> +}
> +
> +static int alloc_fresh_gigantic_page(struct hstate *h,
> +				nodemask_t *nodes_allowed)
> +{
> +	struct page *page = NULL;
> +	int nr_nodes, node;
> +
> +	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
> +		page = alloc_fresh_gigantic_page_node(h, node);
> +		if (page)
> +			return 1;
> +	}
> +
> +	return 0;
> +}
> +
> +static inline bool gigantic_page_supported(void) { return true; }
> +#else
> +static inline bool gigantic_page_supported(void) { return false; }
> +static inline void free_gigantic_page(struct page *page, unsigned order) { }
> +static inline void destroy_compound_gigantic_page(struct page *page,
> +						unsigned long order) { }
> +static inline int alloc_fresh_gigantic_page(struct hstate *h,
> +					nodemask_t *nodes_allowed) { return 0; }
> +#endif
> +
>   static void update_and_free_page(struct hstate *h, struct page *page)
>   {
>   	int i;
>   
> -	VM_BUG_ON(hstate_is_gigantic(h));
> +	if (hstate_is_gigantic(h) && !gigantic_page_supported())
> +		return;
>   
>   	h->nr_huge_pages--;
>   	h->nr_huge_pages_node[page_to_nid(page)]--;
> @@ -697,8 +827,13 @@ static void update_and_free_page(struct hstate *h, struct page *page)
>   	VM_BUG_ON_PAGE(hugetlb_cgroup_from_page(page), page);
>   	set_compound_page_dtor(page, NULL);
>   	set_page_refcounted(page);
> -	arch_release_hugepage(page);
> -	__free_pages(page, huge_page_order(h));
> +	if (hstate_is_gigantic(h)) {
> +		destroy_compound_gigantic_page(page, huge_page_order(h));
> +		free_gigantic_page(page, huge_page_order(h));
> +	} else {
> +		arch_release_hugepage(page);
> +		__free_pages(page, huge_page_order(h));
> +	}
>   }
>   
>   struct hstate *size_to_hstate(unsigned long size)
> @@ -737,7 +872,7 @@ static void free_huge_page(struct page *page)
>   	if (restore_reserve)
>   		h->resv_huge_pages++;
>   
> -	if (h->surplus_huge_pages_node[nid] && !hstate_is_gigantic(h)) {
> +	if (h->surplus_huge_pages_node[nid]) {
>   		/* remove the page from active list */
>   		list_del(&page->lru);
>   		update_and_free_page(h, page);
> @@ -841,9 +976,6 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
>   {
>   	struct page *page;
>   
> -	if (hstate_is_gigantic(h))
> -		return NULL;
> -
>   	page = alloc_pages_exact_node(nid,
>   		htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
>   						__GFP_REPEAT|__GFP_NOWARN,
> @@ -1477,7 +1609,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
>   {
>   	unsigned long min_count, ret;
>   
> -	if (hstate_is_gigantic(h))
> +	if (hstate_is_gigantic(h) && !gigantic_page_supported())
>   		return h->max_huge_pages;
>   
>   	/*
> @@ -1504,7 +1636,11 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
>   		 * and reducing the surplus.
>   		 */
>   		spin_unlock(&hugetlb_lock);
> -		ret = alloc_fresh_huge_page(h, nodes_allowed);
> +		if (hstate_is_gigantic(h)) {
> +			ret = alloc_fresh_gigantic_page(h, nodes_allowed);
> +		} else {
> +			ret = alloc_fresh_huge_page(h, nodes_allowed);
> +		}
>   		spin_lock(&hugetlb_lock);
>   		if (!ret)
>   			goto out;
> @@ -1603,7 +1739,7 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
>   		goto out;
>   
>   	h = kobj_to_hstate(kobj, &nid);
> -	if (hstate_is_gigantic(h)) {
> +	if (hstate_is_gigantic(h) && !gigantic_page_supported()) {
>   		err = -EINVAL;
>   		goto out;
>   	}
> @@ -2111,7 +2247,7 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
>   
>   	tmp = h->max_huge_pages;
>   
> -	if (write && hstate_is_gigantic(h))
> +	if (write && hstate_is_gigantic(h) && !gigantic_page_supported())
>   		return -EINVAL;
>   
>   	table->data = &tmp;
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
