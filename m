Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3303E6B0031
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 23:06:03 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so2686295pde.38
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 20:06:02 -0700 (PDT)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id se7si3977682pbb.96.2014.04.03.20.06.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 03 Apr 2014 20:06:02 -0700 (PDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 46C113EE0C0
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 12:06:00 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3372745DED0
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 12:06:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.nic.fujitsu.com [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E54545DECA
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 12:06:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 016A11DB8032
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 12:06:00 +0900 (JST)
Received: from g01jpfmpwkw02.exch.g01.fujitsu.local (g01jpfmpwkw02.exch.g01.fujitsu.local [10.0.193.56])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A2D9A1DB803F
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 12:05:59 +0900 (JST)
Message-ID: <533E216D.1050609@jp.fujitsu.com>
Date: Fri, 4 Apr 2014 12:05:17 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] hugetlb: add support for gigantic page allocation
 at runtime
References: <1396462128-32626-1-git-send-email-lcapitulino@redhat.com> <1396462128-32626-5-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1396462128-32626-5-git-send-email-lcapitulino@redhat.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, yinghai@kernel.org, riel@redhat.com

(2014/04/03 3:08), Luiz Capitulino wrote:
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
> And to free them later:
> 
>   # echo 0 > \
>     /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages
> 
> The one problem with gigantic page allocation at runtime is that it
> can't be serviced by the buddy allocator. To overcome that problem, this
> series scans all zones from a node looking for a large enough contiguous
> region. When one is found, it's allocated by using CMA, that is, we call
> alloc_contig_range() to do the actual allocation. For example, on x86_64
> we scan all zones looking for a 1GB contiguous region. When one is found
> it's allocated by alloc_contig_range().
> 
> One expected issue with that approach is that such gigantic contiguous
> regions tend to vanish as time goes by. The best way to avoid this for
> now is to make gigantic page allocations very early during boot, say
> from a init script. Other possible optimization include using compaction,
> which is supported by CMA but is not explicitly used by this commit.
> 
> It's also important to note the following:
> 
>   1. My target systems are x86_64 machines, so I have only tested 1GB
>      pages allocation/release. I did try to make this arch indepedent
>      and expect it to work on other archs but didn't try it myself
> 
>   2. I didn't add support for hugepage overcommit, that is allocating
>      a gigantic page on demand when
>     /proc/sys/vm/nr_overcommit_hugepages > 0. The reason is that I don't
>     think it's reasonable to do the hard and long work required for
>     allocating a gigantic page at fault time. But it should be simple
>     to add this if wanted
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
> ---
>   arch/x86/include/asm/hugetlb.h |  10 +++
>   mm/hugetlb.c                   | 177 ++++++++++++++++++++++++++++++++++++++---
>   2 files changed, 176 insertions(+), 11 deletions(-)
> 
> diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
> index a809121..2b262f7 100644
> --- a/arch/x86/include/asm/hugetlb.h
> +++ b/arch/x86/include/asm/hugetlb.h
> @@ -91,6 +91,16 @@ static inline void arch_release_hugepage(struct page *page)
>   {
>   }
>   
> +static inline int arch_prepare_gigantic_page(struct page *page)
> +{
> +	return 0;
> +}
> +
> +static inline void arch_release_gigantic_page(struct page *page)
> +{
> +}
> +
> +
>   static inline void arch_clear_hugepage_flags(struct page *page)
>   {
>   }
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 2c7a44a..c68515e 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -643,11 +643,159 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
>   		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
>   		nr_nodes--)
>   
> +#ifdef CONFIG_CMA
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
> +static bool pfn_valid_gigantic(unsigned long pfn)
> +{
> +	struct page *page;
> +
> +	if (!pfn_valid(pfn))
> +		return false;
> +
> +	page = pfn_to_page(pfn);
> +
> +	if (PageReserved(page))
> +		return false;
> +
> +	if (page_count(page) > 0)
> +		return false;
> +
> +	return true;
> +}
> +
> +static inline bool pfn_aligned_gigantic(unsigned long pfn, unsigned order)
> +{
> +	return IS_ALIGNED((phys_addr_t) pfn << PAGE_SHIFT, PAGE_SIZE << order);
> +}
> +
> +static struct page *alloc_gigantic_page(int nid, unsigned order)
> +{
> +	unsigned long ret, i, count, start_pfn, flags;
> +	unsigned long nr_pages = 1 << order;
> +	struct zone *z;
> +
> +	z = NODE_DATA(nid)->node_zones;
> +	for (; z - NODE_DATA(nid)->node_zones < MAX_NR_ZONES; z++) {
> +		spin_lock_irqsave(&z->lock, flags);
> +		if (z->spanned_pages < nr_pages) {
> +			spin_unlock_irqrestore(&z->lock, flags);
> +			continue;
> +		}
> +
> +		/* scan zone 'z' looking for a contiguous 'nr_pages' range */
> +		count = 0;

> +		start_pfn = z->zone_start_pfn; /* to silence gcc */
> +		for (i = z->zone_start_pfn; i < zone_end_pfn(z); i++) {

This loop is not smart. On our system, one node has serveral TBytes.
So the maximum loop count is "TBytes/Page size".

First page of gigantic page must be aligned.
So how about it:

		start_pfn = zone_start_pfn aligned gigantic page
		for (i = start_pfn; i < zone_end_pfn; i += size of gigantic page) {
			if (!pfn_valid_gigantic(i)) {
				count = 0;
				continue;
			}
			
			...
		}

Thanks,
Yasuaki Ishimatsu

> +			if (!pfn_valid_gigantic(i)) {
> +				count = 0;
> +				continue;
> +			}
> +			if (!count) {
> +				if (!pfn_aligned_gigantic(i, order))
> +					continue;
> +				start_pfn = i;
> +			}
> +			if (++count == nr_pages) {
> +				/*
> +				 * We release the zone lock here because
> +				 * alloc_contig_range() will also lock the zone
> +				 * at some point. If there's an allocation
> +				 * spinning on this lock, it may win the race
> +				 * and cause alloc_contig_range() to fail...
> +				 */
> +				spin_unlock_irqrestore(&z->lock, flags);
> +				ret = __alloc_gigantic_page(start_pfn, count);
> +				if (!ret)
> +					return pfn_to_page(start_pfn);
> +				count = 0;
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
> +		if (arch_prepare_gigantic_page(page)) {
> +			free_gigantic_page(page, huge_page_order(h));
> +			return NULL;
> +		}
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
> +#else /* !CONFIG_CMA */
> +static inline bool gigantic_page_supported(void) { return false; }
> +static inline void free_gigantic_page(struct page *page, unsigned order) { }
> +static inline void destroy_compound_gigantic_page(struct page *page,
> +						unsigned long order) { }
> +static inline int alloc_fresh_gigantic_page(struct hstate *h,
> +					nodemask_t *nodes_allowed) { return 0; }
> +#endif /* CONFIG_CMA */
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
> @@ -661,8 +809,14 @@ static void update_and_free_page(struct hstate *h, struct page *page)
>   	VM_BUG_ON_PAGE(hugetlb_cgroup_from_page(page), page);
>   	set_compound_page_dtor(page, NULL);
>   	set_page_refcounted(page);
> -	arch_release_hugepage(page);
> -	__free_pages(page, huge_page_order(h));
> +	if (hstate_is_gigantic(h)) {
> +		arch_release_gigantic_page(page);
> +		destroy_compound_gigantic_page(page, huge_page_order(h));
> +		free_gigantic_page(page, huge_page_order(h));
> +	} else {
> +		arch_release_hugepage(page);
> +		__free_pages(page, huge_page_order(h));
> +	}
>   }
>   
>   struct hstate *size_to_hstate(unsigned long size)
> @@ -701,7 +855,7 @@ static void free_huge_page(struct page *page)
>   	if (restore_reserve)
>   		h->resv_huge_pages++;
>   
> -	if (h->surplus_huge_pages_node[nid] && !hstate_is_gigantic(h)) {
> +	if (h->surplus_huge_pages_node[nid]) {
>   		/* remove the page from active list */
>   		list_del(&page->lru);
>   		update_and_free_page(h, page);
> @@ -805,9 +959,6 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
>   {
>   	struct page *page;
>   
> -	if (hstate_is_gigantic(h))
> -		return NULL;
> -
>   	page = alloc_pages_exact_node(nid,
>   		htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
>   						__GFP_REPEAT|__GFP_NOWARN,
> @@ -1452,7 +1603,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
>   {
>   	unsigned long min_count, ret;
>   
> -	if (hstate_is_gigantic(h))
> +	if (hstate_is_gigantic(h) && !gigantic_page_supported())
>   		return h->max_huge_pages;
>   
>   	/*
> @@ -1479,7 +1630,11 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
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
> @@ -1578,7 +1733,7 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
>   		goto out;
>   
>   	h = kobj_to_hstate(kobj, &nid);
> -	if (hstate_is_gigantic(h)) {
> +	if (hstate_is_gigantic(h) && !gigantic_page_supported()) {
>   		err = -EINVAL;
>   		goto out;
>   	}
> @@ -2072,7 +2227,7 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
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
