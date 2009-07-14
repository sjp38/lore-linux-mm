Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2B4B26B004F
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 05:07:20 -0400 (EDT)
Date: Tue, 14 Jul 2009 10:37:19 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC][PATCH 1/2] HugeTLB mapping for drivers (Alloc/free for
	drivers, hstate_nores)
Message-ID: <20090714093718.GB28569@csn.ul.ie>
References: <alpine.LFD.2.00.0907140244220.25576@casper.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0907140244220.25576@casper.infradead.org>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolev@infradead.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 14, 2009 at 02:47:57AM +0100, Alexey Korolev wrote:
> This patch provides interface  functions for allocating/dealocating of
> hugepages for use of device drivers. The main difference from
> alloc_buddy_huge_page is related to using of special hstate which does not
> interact with hugetlbfs reservations.

Ok, this makes me raise an eyebrow immediately. Things to watch out for
are

o allocations made by the driver that are not faulted immediately can
  potentially fail at fault time if reservations are not made
o allocations that ignore the userspace reservations and allocate huge
  pages from the pool potentially cause application failure later

You deal with the latter but the former will depend on how the driver is
implemented.

> This is different to prototype. Why it is implemented? HugetlbFs and
> drivers reservations has completely different sources of reservations. 
> In hugetlbfs case it is dictated by users. So it is necessary to bother
> about restrictions/ quotas etc.

The reservations in the hugetlbfs case are about stability. If hugepages
were not reserved or allocated at mmap() time, a failure to allocate a
page at fault time will force-kill the application. Be careful that
drivers really are immune from the same problem.

> In driver case it is dictated by HW. In thius case it is necessary involve user 
> in tuning process as less as possible. 
> If we would use HugeTlbFs reservations - we would need to force user to
> supply how much huge pages needs to be reserved for drivers.
> To protect drivers to interract with htlbfs reservations the state hstate_nores was 
> introduced.

What does nores mean?

> Reservations with a state hstate_nores should not touch htlb
> pools.
> 

Ok, that's good, but you still need to be careful in the event you setup
a mapping that doesn't have associated hugepages allocated.

> Note: Introduced interface functions have some elements of common code.
> I did not bother about duplications as it is an early revision. 
> 
> P/S: In patch description I forgot to mention where it make sence to have
> htlb mapping for drivers:
> HD video capture/frame buffer (LFB)
> Plenty of different data acquisition systems(logic analyzers, DSO, packet capture)
> Probably RDMA (Infiniband)
> 
> hugetlb.c |   53 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
> 1 file changed, 52 insertions(+), 1 deletion(-)
> 
> Signed-off-by: Alexey Korolev <akorolev@infradead.org>
> ---
> diff -aurp ORIG/mm/hugetlb.c NEW/mm/hugetlb.c
> --- ORIG/mm/hugetlb.c	2009-07-05 05:58:48.000000000 +1200
> +++ NEW/mm/hugetlb.c	2009-07-13 18:38:45.000000000 +1200
> @@ -33,6 +33,7 @@ unsigned long hugepages_treat_as_movable
>  static int max_hstate;
>  unsigned int default_hstate_idx;
>  struct hstate hstates[HUGE_MAX_HSTATE];
> +struct hstate hstate_nores;
>  
>  __initdata LIST_HEAD(huge_boot_pages);
>  
> @@ -1040,6 +1041,50 @@ static void prep_compound_huge_page(stru
>  		prep_compound_page(page, order);
>  }
>  
> +/*
> + * hugetlb_alloc_pages_node - Allocate a single huge page for use with a driver
> + * @nid: The node to allocate memory on
> + * @gfp_mask: GFP flags for the allocation
> + * This function is intended for use by device drivers that want to
> + * back regions of memory with huge pages that will be later mapped to
> + * userspace. This is done outside of hugetlbfs and pages are allocated
> + * directly from the buddy allocator. It doesn't interact with hugetlbfs
> + * reservations.
> + */
> +struct page *hugetlb_alloc_pages_node(int nid, gfp_t gfp_mask)
> +{
> +	struct page *page;
> +	struct hstate *h = &hstate_nores;
> +
> +	page = alloc_pages_exact_node(nid, gfp_mask|__GFP_COMP,
> +					huge_page_order(h));
> +	if (page && arch_prepare_hugepage(page)) {
> +		__free_pages(page, huge_page_order(h));
> +		return NULL;
> +	}
> +	return page;
> +}
> +EXPORT_SYMBOL(hugetlb_alloc_pages_node);
> +
> +void hugetlb_free_pages(struct page *page)
> +{

This name is too general. There is nothing to indicate that it is only
used by drivers.

> +	int i;
> +	struct hstate *h = &hstate_nores;
> +
> +	VM_BUG_ON(h->order >= MAX_ORDER);
> +

This is a perfectly possible condition for you unfortunately in the current
initialisation of hstate_nores. Nothing stops the default hugepage size being
set to 1G or 16G on machines that wanted that pagesize used for shared memory
segments. On such configurations, you should either be failing the allocation
or having hstate_nores use a smaller hugepage size.

> +	for (i = 0; i < pages_per_huge_page(h); i++) {
> +		page[i].flags &= ~(1 << PG_locked | 1 << PG_error |
> +			1 << PG_referenced | 1 << PG_dirty | 1 << PG_active |
> +			1 << PG_reserved | 1 << PG_private | 1 << PG_writeback);
> +	}
> +	set_compound_page_dtor(page, NULL);
> +	set_page_refcounted(page);
> +	arch_release_hugepage(page);
> +	__free_pages(page, huge_page_order(h));
> +}
> +EXPORT_SYMBOL(hugetlb_free_pages);

You need to reuse update_and_free_page() somehow here by splitting the
accounting portion from the page free portion. I know this is a
prototype but at least comment that it's copied from
update_and_free_page() for anyone else looking to review this that is
not familiar with hugetlbfs.

> +
>  /* Put bootmem huge pages into the standard lists after mem_map is up */
>  static void __init gather_bootmem_prealloc(void)
>  {
> @@ -1078,7 +1123,13 @@ static void __init hugetlb_init_hstates(
>  		if (h->order < MAX_ORDER)
>  			hugetlb_hstate_alloc_pages(h);
>  	}
> +	/* Special hstate for use of drivers, allocations are not
> +	 * tracked by hugetlbfs */

The term "tracked" doesn't really say anything. How about something
like;

/*
 * hstate_nores is used by drivers. Allocations are immediate,
 * there is no hugepage pool and there are no reservations made
 */

> +	hstate_nores.order = default_hstate.order;
> +	hstate_nores.mask = default_hstate.mask;
> +
>  }
> +EXPORT_SYMBOL(hstate_nores);
>  
>  static char * __init memfmt(char *buf, unsigned long n)
>  {
> @@ -2309,7 +2360,7 @@ int hugetlb_reserve_pages(struct inode *
>  	 * attempt will be made for VM_NORESERVE to allocate a page
>  	 * and filesystem quota without using reserves
>  	 */
> -	if (acctflag & VM_NORESERVE)
> +	if ((acctflag & VM_NORESERVE) || (h == &hstate_nores))
>  		return 0;
>  
>  	/*
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
