Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4RKc8bR020837
	for <linux-mm@kvack.org>; Tue, 27 May 2008 16:38:08 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RKc8pP145826
	for <linux-mm@kvack.org>; Tue, 27 May 2008 16:38:08 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RKc7Bu028023
	for <linux-mm@kvack.org>; Tue, 27 May 2008 16:38:08 -0400
Subject: Re: [patch 03/23] hugetlb: modular state
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080525143452.408189000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
	 <20080525143452.408189000@nick.local0.net>
Content-Type: text/plain
Date: Tue, 27 May 2008 15:38:07 -0500
Message-Id: <1211920687.12036.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, nacc@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Phew.  At last I made it to the end of this one :)  It seems okay to me
though.  Have you done any performance testing on this patch series yet?
I don't expect the hstate structure to introduce any measurable
performance degradation, but it would be nice to have some numbers to
back up that educated guess.

Acked-by: Adam Litke <agl@us.ibm.com>

On Mon, 2008-05-26 at 00:23 +1000, npiggin@suse.de wrote:
> plain text document attachment (hugetlb-modular-state.patch)
> Large, but rather mechanical patch that converts most of the hugetlb.c
> globals into structure members and passes them around.
> 
> Right now there is only a single global hstate structure, but 
> most of the infrastructure to extend it is there.
> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
>  arch/ia64/mm/hugetlbpage.c    |    6 
>  arch/powerpc/mm/hugetlbpage.c |    2 
>  arch/sh/mm/hugetlbpage.c      |    2 
>  arch/sparc64/mm/hugetlbpage.c |    4 
>  arch/x86/mm/hugetlbpage.c     |    4 
>  fs/hugetlbfs/inode.c          |   49 +++---
>  include/asm-ia64/hugetlb.h    |    2 
>  include/asm-powerpc/hugetlb.h |    2 
>  include/asm-s390/hugetlb.h    |    2 
>  include/asm-sh/hugetlb.h      |    2 
>  include/asm-sparc64/hugetlb.h |    2 
>  include/asm-x86/hugetlb.h     |    7 
>  include/linux/hugetlb.h       |   81 +++++++++-
>  ipc/shm.c                     |    3 
>  mm/hugetlb.c                  |  321 ++++++++++++++++++++++--------------------
>  mm/memory.c                   |    2 
>  mm/mempolicy.c                |    9 -
>  mm/mmap.c                     |    3 
>  18 files changed, 308 insertions(+), 195 deletions(-)
> 
> Index: linux-2.6/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.orig/mm/hugetlb.c
> +++ linux-2.6/mm/hugetlb.c
> @@ -22,30 +22,24 @@
>  #include "internal.h"
> 
>  const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
> -static unsigned long nr_huge_pages, free_huge_pages, resv_huge_pages;
> -static unsigned long surplus_huge_pages;
> -static unsigned long nr_overcommit_huge_pages;
>  unsigned long max_huge_pages;
>  unsigned long sysctl_overcommit_huge_pages;
> -static struct list_head hugepage_freelists[MAX_NUMNODES];
> -static unsigned int nr_huge_pages_node[MAX_NUMNODES];
> -static unsigned int free_huge_pages_node[MAX_NUMNODES];
> -static unsigned int surplus_huge_pages_node[MAX_NUMNODES];
>  static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
>  unsigned long hugepages_treat_as_movable;
> -static int hugetlb_next_nid;
> +
> +struct hstate global_hstate;
> 
>  /*
>   * Protects updates to hugepage_freelists, nr_huge_pages, and free_huge_pages
>   */
>  static DEFINE_SPINLOCK(hugetlb_lock);
> 
> -static void clear_huge_page(struct page *page, unsigned long addr)
> +static void clear_huge_page(struct page *page, unsigned long addr, unsigned long sz)
>  {
>  	int i;
> 
>  	might_sleep();
> -	for (i = 0; i < (HPAGE_SIZE/PAGE_SIZE); i++) {
> +	for (i = 0; i < sz/PAGE_SIZE; i++) {
>  		cond_resched();
>  		clear_user_highpage(page + i, addr + i * PAGE_SIZE);
>  	}
> @@ -55,42 +49,43 @@ static void copy_huge_page(struct page *
>  			   unsigned long addr, struct vm_area_struct *vma)
>  {
>  	int i;
> +	struct hstate *h = hstate_vma(vma);
> 
>  	might_sleep();
> -	for (i = 0; i < HPAGE_SIZE/PAGE_SIZE; i++) {
> +	for (i = 0; i < 1 << huge_page_order(h); i++) {
>  		cond_resched();
>  		copy_user_highpage(dst + i, src + i, addr + i*PAGE_SIZE, vma);
>  	}
>  }
> 
> -static void enqueue_huge_page(struct page *page)
> +static void enqueue_huge_page(struct hstate *h, struct page *page)
>  {
>  	int nid = page_to_nid(page);
> -	list_add(&page->lru, &hugepage_freelists[nid]);
> -	free_huge_pages++;
> -	free_huge_pages_node[nid]++;
> +	list_add(&page->lru, &h->hugepage_freelists[nid]);
> +	h->free_huge_pages++;
> +	h->free_huge_pages_node[nid]++;
>  }
> 
> -static struct page *dequeue_huge_page(void)
> +static struct page *dequeue_huge_page(struct hstate *h)
>  {
>  	int nid;
>  	struct page *page = NULL;
> 
>  	for (nid = 0; nid < MAX_NUMNODES; ++nid) {
> -		if (!list_empty(&hugepage_freelists[nid])) {
> -			page = list_entry(hugepage_freelists[nid].next,
> +		if (!list_empty(&h->hugepage_freelists[nid])) {
> +			page = list_entry(h->hugepage_freelists[nid].next,
>  					  struct page, lru);
>  			list_del(&page->lru);
> -			free_huge_pages--;
> -			free_huge_pages_node[nid]--;
> +			h->free_huge_pages--;
> +			h->free_huge_pages_node[nid]--;
>  			break;
>  		}
>  	}
>  	return page;
>  }
> 
> -static struct page *dequeue_huge_page_vma(struct vm_area_struct *vma,
> -				unsigned long address)
> +static struct page *dequeue_huge_page_vma(struct hstate *h,
> +			struct vm_area_struct *vma, unsigned long address)
>  {
>  	int nid;
>  	struct page *page = NULL;
> @@ -105,14 +100,14 @@ static struct page *dequeue_huge_page_vm
>  						MAX_NR_ZONES - 1, nodemask) {
>  		nid = zone_to_nid(zone);
>  		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask) &&
> -		    !list_empty(&hugepage_freelists[nid])) {
> -			page = list_entry(hugepage_freelists[nid].next,
> +		    !list_empty(&h->hugepage_freelists[nid])) {
> +			page = list_entry(h->hugepage_freelists[nid].next,
>  					  struct page, lru);
>  			list_del(&page->lru);
> -			free_huge_pages--;
> -			free_huge_pages_node[nid]--;
> +			h->free_huge_pages--;
> +			h->free_huge_pages_node[nid]--;
>  			if (vma && vma->vm_flags & VM_MAYSHARE)
> -				resv_huge_pages--;
> +				h->resv_huge_pages--;
>  			break;
>  		}
>  	}
> @@ -120,12 +115,13 @@ static struct page *dequeue_huge_page_vm
>  	return page;
>  }
> 
> -static void update_and_free_page(struct page *page)
> +static void update_and_free_page(struct hstate *h, struct page *page)
>  {
>  	int i;
> -	nr_huge_pages--;
> -	nr_huge_pages_node[page_to_nid(page)]--;
> -	for (i = 0; i < (HPAGE_SIZE / PAGE_SIZE); i++) {
> +
> +	h->nr_huge_pages--;
> +	h->nr_huge_pages_node[page_to_nid(page)]--;
> +	for (i = 0; i < (1 << huge_page_order(h)); i++) {
>  		page[i].flags &= ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
>  				1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
>  				1 << PG_private | 1<< PG_writeback);
> @@ -133,11 +129,16 @@ static void update_and_free_page(struct 
>  	set_compound_page_dtor(page, NULL);
>  	set_page_refcounted(page);
>  	arch_release_hugepage(page);
> -	__free_pages(page, HUGETLB_PAGE_ORDER);
> +	__free_pages(page, huge_page_order(h));
>  }
> 
>  static void free_huge_page(struct page *page)
>  {
> +	/*
> +	 * Can't pass hstate in here because it is called from the
> +	 * compound page destructor.
> +	 */
> +	struct hstate *h = &global_hstate;
>  	int nid = page_to_nid(page);
>  	struct address_space *mapping;
> 
> @@ -147,12 +148,12 @@ static void free_huge_page(struct page *
>  	INIT_LIST_HEAD(&page->lru);
> 
>  	spin_lock(&hugetlb_lock);
> -	if (surplus_huge_pages_node[nid]) {
> -		update_and_free_page(page);
> -		surplus_huge_pages--;
> -		surplus_huge_pages_node[nid]--;
> +	if (h->surplus_huge_pages_node[nid]) {
> +		update_and_free_page(h, page);
> +		h->surplus_huge_pages--;
> +		h->surplus_huge_pages_node[nid]--;
>  	} else {
> -		enqueue_huge_page(page);
> +		enqueue_huge_page(h, page);
>  	}
>  	spin_unlock(&hugetlb_lock);
>  	if (mapping)
> @@ -164,7 +165,7 @@ static void free_huge_page(struct page *
>   * balanced by operating on them in a round-robin fashion.
>   * Returns 1 if an adjustment was made.
>   */
> -static int adjust_pool_surplus(int delta)
> +static int adjust_pool_surplus(struct hstate *h, int delta)
>  {
>  	static int prev_nid;
>  	int nid = prev_nid;
> @@ -177,15 +178,15 @@ static int adjust_pool_surplus(int delta
>  			nid = first_node(node_online_map);
> 
>  		/* To shrink on this node, there must be a surplus page */
> -		if (delta < 0 && !surplus_huge_pages_node[nid])
> +		if (delta < 0 && !h->surplus_huge_pages_node[nid])
>  			continue;
>  		/* Surplus cannot exceed the total number of pages */
> -		if (delta > 0 && surplus_huge_pages_node[nid] >=
> -						nr_huge_pages_node[nid])
> +		if (delta > 0 && h->surplus_huge_pages_node[nid] >=
> +						h->nr_huge_pages_node[nid])
>  			continue;
> 
> -		surplus_huge_pages += delta;
> -		surplus_huge_pages_node[nid] += delta;
> +		h->surplus_huge_pages += delta;
> +		h->surplus_huge_pages_node[nid] += delta;
>  		ret = 1;
>  		break;
>  	} while (nid != prev_nid);
> @@ -194,46 +195,46 @@ static int adjust_pool_surplus(int delta
>  	return ret;
>  }
> 
> -static void prep_new_huge_page(struct page *page, int nid)
> +static void prep_new_huge_page(struct hstate *h, struct page *page, int nid)
>  {
>  	set_compound_page_dtor(page, free_huge_page);
>  	spin_lock(&hugetlb_lock);
> -	nr_huge_pages++;
> -	nr_huge_pages_node[nid]++;
> +	h->nr_huge_pages++;
> +	h->nr_huge_pages_node[nid]++;
>  	spin_unlock(&hugetlb_lock);
>  	put_page(page); /* free it into the hugepage allocator */
>  }
> 
> -static struct page *alloc_fresh_huge_page_node(int nid)
> +static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
>  {
>  	struct page *page;
> 
>  	page = alloc_pages_node(nid,
>  		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|
>  						__GFP_REPEAT|__GFP_NOWARN,
> -		HUGETLB_PAGE_ORDER);
> +		huge_page_order(h));
>  	if (page) {
>  		if (arch_prepare_hugepage(page)) {
>  			__free_pages(page, HUGETLB_PAGE_ORDER);
>  			return NULL;
>  		}
> -		prep_new_huge_page(page, nid);
> +		prep_new_huge_page(h, page, nid);
>  	}
> 
>  	return page;
>  }
> 
> -static int alloc_fresh_huge_page(void)
> +static int alloc_fresh_huge_page(struct hstate *h)
>  {
>  	struct page *page;
>  	int start_nid;
>  	int next_nid;
>  	int ret = 0;
> 
> -	start_nid = hugetlb_next_nid;
> +	start_nid = h->hugetlb_next_nid;
> 
>  	do {
> -		page = alloc_fresh_huge_page_node(hugetlb_next_nid);
> +		page = alloc_fresh_huge_page_node(h, h->hugetlb_next_nid);
>  		if (page)
>  			ret = 1;
>  		/*
> @@ -247,11 +248,11 @@ static int alloc_fresh_huge_page(void)
>  		 * if we just successfully allocated a hugepage so that
>  		 * the next caller gets hugepages on the next node.
>  		 */
> -		next_nid = next_node(hugetlb_next_nid, node_online_map);
> +		next_nid = next_node(h->hugetlb_next_nid, node_online_map);
>  		if (next_nid == MAX_NUMNODES)
>  			next_nid = first_node(node_online_map);
> -		hugetlb_next_nid = next_nid;
> -	} while (!page && hugetlb_next_nid != start_nid);
> +		h->hugetlb_next_nid = next_nid;
> +	} while (!page && h->hugetlb_next_nid != start_nid);
> 
>  	if (ret)
>  		count_vm_event(HTLB_BUDDY_PGALLOC);
> @@ -261,8 +262,8 @@ static int alloc_fresh_huge_page(void)
>  	return ret;
>  }
> 
> -static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
> -						unsigned long address)
> +static struct page *alloc_buddy_huge_page(struct hstate *h,
> +			struct vm_area_struct *vma, unsigned long address)
>  {
>  	struct page *page;
>  	unsigned int nid;
> @@ -291,18 +292,18 @@ static struct page *alloc_buddy_huge_pag
>  	 * per-node value is checked there.
>  	 */
>  	spin_lock(&hugetlb_lock);
> -	if (surplus_huge_pages >= nr_overcommit_huge_pages) {
> +	if (h->surplus_huge_pages >= h->nr_overcommit_huge_pages) {
>  		spin_unlock(&hugetlb_lock);
>  		return NULL;
>  	} else {
> -		nr_huge_pages++;
> -		surplus_huge_pages++;
> +		h->nr_huge_pages++;
> +		h->surplus_huge_pages++;
>  	}
>  	spin_unlock(&hugetlb_lock);
> 
>  	page = alloc_pages(htlb_alloc_mask|__GFP_COMP|
>  					__GFP_REPEAT|__GFP_NOWARN,
> -					HUGETLB_PAGE_ORDER);
> +					huge_page_order(h));
> 
>  	spin_lock(&hugetlb_lock);
>  	if (page) {
> @@ -317,12 +318,12 @@ static struct page *alloc_buddy_huge_pag
>  		/*
>  		 * We incremented the global counters already
>  		 */
> -		nr_huge_pages_node[nid]++;
> -		surplus_huge_pages_node[nid]++;
> +		h->nr_huge_pages_node[nid]++;
> +		h->surplus_huge_pages_node[nid]++;
>  		__count_vm_event(HTLB_BUDDY_PGALLOC);
>  	} else {
> -		nr_huge_pages--;
> -		surplus_huge_pages--;
> +		h->nr_huge_pages--;
> +		h->surplus_huge_pages--;
>  		__count_vm_event(HTLB_BUDDY_PGALLOC_FAIL);
>  	}
>  	spin_unlock(&hugetlb_lock);
> @@ -334,16 +335,16 @@ static struct page *alloc_buddy_huge_pag
>   * Increase the hugetlb pool such that it can accomodate a reservation
>   * of size 'delta'.
>   */
> -static int gather_surplus_pages(int delta)
> +static int gather_surplus_pages(struct hstate *h, int delta)
>  {
>  	struct list_head surplus_list;
>  	struct page *page, *tmp;
>  	int ret, i;
>  	int needed, allocated;
> 
> -	needed = (resv_huge_pages + delta) - free_huge_pages;
> +	needed = (h->resv_huge_pages + delta) - h->free_huge_pages;
>  	if (needed <= 0) {
> -		resv_huge_pages += delta;
> +		h->resv_huge_pages += delta;
>  		return 0;
>  	}
> 
> @@ -354,7 +355,7 @@ static int gather_surplus_pages(int delt
>  retry:
>  	spin_unlock(&hugetlb_lock);
>  	for (i = 0; i < needed; i++) {
> -		page = alloc_buddy_huge_page(NULL, 0);
> +		page = alloc_buddy_huge_page(h, NULL, 0);
>  		if (!page) {
>  			/*
>  			 * We were not able to allocate enough pages to
> @@ -375,7 +376,8 @@ retry:
>  	 * because either resv_huge_pages or free_huge_pages may have changed.
>  	 */
>  	spin_lock(&hugetlb_lock);
> -	needed = (resv_huge_pages + delta) - (free_huge_pages + allocated);
> +	needed = (h->resv_huge_pages + delta) -
> +			(h->free_huge_pages + allocated);
>  	if (needed > 0)
>  		goto retry;
> 
> @@ -388,7 +390,7 @@ retry:
>  	 * before they are reserved.
>  	 */
>  	needed += allocated;
> -	resv_huge_pages += delta;
> +	h->resv_huge_pages += delta;
>  	ret = 0;
>  free:
>  	/* Free the needed pages to the hugetlb pool */
> @@ -396,7 +398,7 @@ free:
>  		if ((--needed) < 0)
>  			break;
>  		list_del(&page->lru);
> -		enqueue_huge_page(page);
> +		enqueue_huge_page(h, page);
>  	}
> 
>  	/* Free unnecessary surplus pages to the buddy allocator */
> @@ -424,7 +426,8 @@ free:
>   * allocated to satisfy the reservation must be explicitly freed if they were
>   * never used.
>   */
> -static void return_unused_surplus_pages(unsigned long unused_resv_pages)
> +static void return_unused_surplus_pages(struct hstate *h,
> +					unsigned long unused_resv_pages)
>  {
>  	static int nid = -1;
>  	struct page *page;
> @@ -439,27 +442,27 @@ static void return_unused_surplus_pages(
>  	unsigned long remaining_iterations = num_online_nodes();
> 
>  	/* Uncommit the reservation */
> -	resv_huge_pages -= unused_resv_pages;
> +	h->resv_huge_pages -= unused_resv_pages;
> 
> -	nr_pages = min(unused_resv_pages, surplus_huge_pages);
> +	nr_pages = min(unused_resv_pages, h->surplus_huge_pages);
> 
>  	while (remaining_iterations-- && nr_pages) {
>  		nid = next_node(nid, node_online_map);
>  		if (nid == MAX_NUMNODES)
>  			nid = first_node(node_online_map);
> 
> -		if (!surplus_huge_pages_node[nid])
> +		if (!h->surplus_huge_pages_node[nid])
>  			continue;
> 
> -		if (!list_empty(&hugepage_freelists[nid])) {
> -			page = list_entry(hugepage_freelists[nid].next,
> +		if (!list_empty(&h->hugepage_freelists[nid])) {
> +			page = list_entry(h->hugepage_freelists[nid].next,
>  					  struct page, lru);
>  			list_del(&page->lru);
> -			update_and_free_page(page);
> -			free_huge_pages--;
> -			free_huge_pages_node[nid]--;
> -			surplus_huge_pages--;
> -			surplus_huge_pages_node[nid]--;
> +			update_and_free_page(h, page);
> +			h->free_huge_pages--;
> +			h->free_huge_pages_node[nid]--;
> +			h->surplus_huge_pages--;
> +			h->surplus_huge_pages_node[nid]--;
>  			nr_pages--;
>  			remaining_iterations = num_online_nodes();
>  		}
> @@ -471,9 +474,10 @@ static struct page *alloc_huge_page_shar
>  						unsigned long addr)
>  {
>  	struct page *page;
> +	struct hstate *h = hstate_vma(vma);
> 
>  	spin_lock(&hugetlb_lock);
> -	page = dequeue_huge_page_vma(vma, addr);
> +	page = dequeue_huge_page_vma(h, vma, addr);
>  	spin_unlock(&hugetlb_lock);
>  	return page ? page : ERR_PTR(-VM_FAULT_OOM);
>  }
> @@ -482,16 +486,17 @@ static struct page *alloc_huge_page_priv
>  						unsigned long addr)
>  {
>  	struct page *page = NULL;
> +	struct hstate *h = hstate_vma(vma);
> 
>  	if (hugetlb_get_quota(vma->vm_file->f_mapping, 1))
>  		return ERR_PTR(-VM_FAULT_SIGBUS);
> 
>  	spin_lock(&hugetlb_lock);
> -	if (free_huge_pages > resv_huge_pages)
> -		page = dequeue_huge_page_vma(vma, addr);
> +	if (h->free_huge_pages > h->resv_huge_pages)
> +		page = dequeue_huge_page_vma(h, vma, addr);
>  	spin_unlock(&hugetlb_lock);
>  	if (!page) {
> -		page = alloc_buddy_huge_page(vma, addr);
> +		page = alloc_buddy_huge_page(h, vma, addr);
>  		if (!page) {
>  			hugetlb_put_quota(vma->vm_file->f_mapping, 1);
>  			return ERR_PTR(-VM_FAULT_OOM);
> @@ -521,21 +526,27 @@ static struct page *alloc_huge_page(stru
>  static int __init hugetlb_init(void)
>  {
>  	unsigned long i;
> +	struct hstate *h = &global_hstate;
> 
>  	if (HPAGE_SHIFT == 0)
>  		return 0;
> 
> +	if (!h->order) {
> +		h->order = HPAGE_SHIFT - PAGE_SHIFT;
> +		h->mask = HPAGE_MASK;
> +	}
> +
>  	for (i = 0; i < MAX_NUMNODES; ++i)
> -		INIT_LIST_HEAD(&hugepage_freelists[i]);
> +		INIT_LIST_HEAD(&h->hugepage_freelists[i]);
> 
> -	hugetlb_next_nid = first_node(node_online_map);
> +	h->hugetlb_next_nid = first_node(node_online_map);
> 
>  	for (i = 0; i < max_huge_pages; ++i) {
> -		if (!alloc_fresh_huge_page())
> +		if (!alloc_fresh_huge_page(h))
>  			break;
>  	}
> -	max_huge_pages = free_huge_pages = nr_huge_pages = i;
> -	printk("Total HugeTLB memory allocated, %ld\n", free_huge_pages);
> +	max_huge_pages = h->free_huge_pages = h->nr_huge_pages = i;
> +	printk("Total HugeTLB memory allocated, %ld\n", h->free_huge_pages);
>  	return 0;
>  }
>  module_init(hugetlb_init);
> @@ -561,34 +572,36 @@ static unsigned int cpuset_mems_nr(unsig
> 
>  #ifdef CONFIG_SYSCTL
>  #ifdef CONFIG_HIGHMEM
> -static void try_to_free_low(unsigned long count)
> +static void try_to_free_low(struct hstate *h, unsigned long count)
>  {
>  	int i;
> 
>  	for (i = 0; i < MAX_NUMNODES; ++i) {
>  		struct page *page, *next;
> -		list_for_each_entry_safe(page, next, &hugepage_freelists[i], lru) {
> -			if (count >= nr_huge_pages)
> +		struct list_head *freel = &h->hugepage_freelists[i];
> +		list_for_each_entry_safe(page, next, freel, lru) {
> +			if (count >= h->nr_huge_pages)
>  				return;
>  			if (PageHighMem(page))
>  				continue;
>  			list_del(&page->lru);
>  			update_and_free_page(page);
> -			free_huge_pages--;
> -			free_huge_pages_node[page_to_nid(page)]--;
> +			h->free_huge_pages--;
> +			h->free_huge_pages_node[page_to_nid(page)]--;
>  		}
>  	}
>  }
>  #else
> -static inline void try_to_free_low(unsigned long count)
> +static inline void try_to_free_low(struct hstate *h, unsigned long count)
>  {
>  }
>  #endif
> 
> -#define persistent_huge_pages (nr_huge_pages - surplus_huge_pages)
> +#define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
>  static unsigned long set_max_huge_pages(unsigned long count)
>  {
>  	unsigned long min_count, ret;
> +	struct hstate *h = &global_hstate;
> 
>  	/*
>  	 * Increase the pool size
> @@ -602,12 +615,12 @@ static unsigned long set_max_huge_pages(
>  	 * within all the constraints specified by the sysctls.
>  	 */
>  	spin_lock(&hugetlb_lock);
> -	while (surplus_huge_pages && count > persistent_huge_pages) {
> -		if (!adjust_pool_surplus(-1))
> +	while (h->surplus_huge_pages && count > persistent_huge_pages(h)) {
> +		if (!adjust_pool_surplus(h, -1))
>  			break;
>  	}
> 
> -	while (count > persistent_huge_pages) {
> +	while (count > persistent_huge_pages(h)) {
>  		int ret;
>  		/*
>  		 * If this allocation races such that we no longer need the
> @@ -615,7 +628,7 @@ static unsigned long set_max_huge_pages(
>  		 * and reducing the surplus.
>  		 */
>  		spin_unlock(&hugetlb_lock);
> -		ret = alloc_fresh_huge_page();
> +		ret = alloc_fresh_huge_page(h);
>  		spin_lock(&hugetlb_lock);
>  		if (!ret)
>  			goto out;
> @@ -637,21 +650,21 @@ static unsigned long set_max_huge_pages(
>  	 * and won't grow the pool anywhere else. Not until one of the
>  	 * sysctls are changed, or the surplus pages go out of use.
>  	 */
> -	min_count = resv_huge_pages + nr_huge_pages - free_huge_pages;
> +	min_count = h->resv_huge_pages + h->nr_huge_pages - h->free_huge_pages;
>  	min_count = max(count, min_count);
> -	try_to_free_low(min_count);
> -	while (min_count < persistent_huge_pages) {
> -		struct page *page = dequeue_huge_page();
> +	try_to_free_low(h, min_count);
> +	while (min_count < persistent_huge_pages(h)) {
> +		struct page *page = dequeue_huge_page(h);
>  		if (!page)
>  			break;
> -		update_and_free_page(page);
> +		update_and_free_page(h, page);
>  	}
> -	while (count < persistent_huge_pages) {
> -		if (!adjust_pool_surplus(1))
> +	while (count < persistent_huge_pages(h)) {
> +		if (!adjust_pool_surplus(h, 1))
>  			break;
>  	}
>  out:
> -	ret = persistent_huge_pages;
> +	ret = persistent_huge_pages(h);
>  	spin_unlock(&hugetlb_lock);
>  	return ret;
>  }
> @@ -681,9 +694,10 @@ int hugetlb_overcommit_handler(struct ct
>  			struct file *file, void __user *buffer,
>  			size_t *length, loff_t *ppos)
>  {
> +	struct hstate *h = &global_hstate;
>  	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
>  	spin_lock(&hugetlb_lock);
> -	nr_overcommit_huge_pages = sysctl_overcommit_huge_pages;
> +	h->nr_overcommit_huge_pages = sysctl_overcommit_huge_pages;
>  	spin_unlock(&hugetlb_lock);
>  	return 0;
>  }
> @@ -692,34 +706,37 @@ int hugetlb_overcommit_handler(struct ct
> 
>  int hugetlb_report_meminfo(char *buf)
>  {
> +	struct hstate *h = &global_hstate;
>  	return sprintf(buf,
>  			"HugePages_Total: %5lu\n"
>  			"HugePages_Free:  %5lu\n"
>  			"HugePages_Rsvd:  %5lu\n"
>  			"HugePages_Surp:  %5lu\n"
>  			"Hugepagesize:    %5lu kB\n",
> -			nr_huge_pages,
> -			free_huge_pages,
> -			resv_huge_pages,
> -			surplus_huge_pages,
> -			HPAGE_SIZE/1024);
> +			h->nr_huge_pages,
> +			h->free_huge_pages,
> +			h->resv_huge_pages,
> +			h->surplus_huge_pages,
> +			1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
>  }
> 
>  int hugetlb_report_node_meminfo(int nid, char *buf)
>  {
> +	struct hstate *h = &global_hstate;
>  	return sprintf(buf,
>  		"Node %d HugePages_Total: %5u\n"
>  		"Node %d HugePages_Free:  %5u\n"
>  		"Node %d HugePages_Surp:  %5u\n",
> -		nid, nr_huge_pages_node[nid],
> -		nid, free_huge_pages_node[nid],
> -		nid, surplus_huge_pages_node[nid]);
> +		nid, h->nr_huge_pages_node[nid],
> +		nid, h->free_huge_pages_node[nid],
> +		nid, h->surplus_huge_pages_node[nid]);
>  }
> 
>  /* Return the number pages of memory we physically have, in PAGE_SIZE units. */
>  unsigned long hugetlb_total_pages(void)
>  {
> -	return nr_huge_pages * (HPAGE_SIZE / PAGE_SIZE);
> +	struct hstate *h = &global_hstate;
> +	return h->nr_huge_pages * (1 << huge_page_order(h));
>  }
> 
>  /*
> @@ -774,14 +791,16 @@ int copy_hugetlb_page_range(struct mm_st
>  	struct page *ptepage;
>  	unsigned long addr;
>  	int cow;
> +	struct hstate *h = hstate_vma(vma);
> +	unsigned long sz = huge_page_size(h);
> 
>  	cow = (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
> 
> -	for (addr = vma->vm_start; addr < vma->vm_end; addr += HPAGE_SIZE) {
> +	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
>  		src_pte = huge_pte_offset(src, addr);
>  		if (!src_pte)
>  			continue;
> -		dst_pte = huge_pte_alloc(dst, addr);
> +		dst_pte = huge_pte_alloc(dst, addr, sz);
>  		if (!dst_pte)
>  			goto nomem;
> 
> @@ -817,6 +836,9 @@ void __unmap_hugepage_range(struct vm_ar
>  	pte_t pte;
>  	struct page *page;
>  	struct page *tmp;
> +	struct hstate *h = hstate_vma(vma);
> +	unsigned long sz = huge_page_size(h);
> +
>  	/*
>  	 * A page gathering list, protected by per file i_mmap_lock. The
>  	 * lock is used to avoid list corruption from multiple unmapping
> @@ -825,11 +847,11 @@ void __unmap_hugepage_range(struct vm_ar
>  	LIST_HEAD(page_list);
> 
>  	WARN_ON(!is_vm_hugetlb_page(vma));
> -	BUG_ON(start & ~HPAGE_MASK);
> -	BUG_ON(end & ~HPAGE_MASK);
> +	BUG_ON(start & ~huge_page_mask(h));
> +	BUG_ON(end & ~huge_page_mask(h));
> 
>  	spin_lock(&mm->page_table_lock);
> -	for (address = start; address < end; address += HPAGE_SIZE) {
> +	for (address = start; address < end; address += sz) {
>  		ptep = huge_pte_offset(mm, address);
>  		if (!ptep)
>  			continue;
> @@ -877,6 +899,7 @@ static int hugetlb_cow(struct mm_struct 
>  {
>  	struct page *old_page, *new_page;
>  	int avoidcopy;
> +	struct hstate *h = hstate_vma(vma);
> 
>  	old_page = pte_page(pte);
> 
> @@ -901,7 +924,7 @@ static int hugetlb_cow(struct mm_struct 
>  	__SetPageUptodate(new_page);
>  	spin_lock(&mm->page_table_lock);
> 
> -	ptep = huge_pte_offset(mm, address & HPAGE_MASK);
> +	ptep = huge_pte_offset(mm, address & huge_page_mask(h));
>  	if (likely(pte_same(huge_ptep_get(ptep), pte))) {
>  		/* Break COW */
>  		huge_ptep_clear_flush(vma, address, ptep);
> @@ -924,10 +947,11 @@ static int hugetlb_no_page(struct mm_str
>  	struct page *page;
>  	struct address_space *mapping;
>  	pte_t new_pte;
> +	struct hstate *h = hstate_vma(vma);
> 
>  	mapping = vma->vm_file->f_mapping;
> -	idx = ((address - vma->vm_start) >> HPAGE_SHIFT)
> -		+ (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
> +	idx = ((address - vma->vm_start) >> huge_page_shift(h))
> +		+ (vma->vm_pgoff >> huge_page_order(h));
> 
>  	/*
>  	 * Use page lock to guard against racing truncation
> @@ -936,7 +960,7 @@ static int hugetlb_no_page(struct mm_str
>  retry:
>  	page = find_lock_page(mapping, idx);
>  	if (!page) {
> -		size = i_size_read(mapping->host) >> HPAGE_SHIFT;
> +		size = i_size_read(mapping->host) >> huge_page_shift(h);
>  		if (idx >= size)
>  			goto out;
>  		page = alloc_huge_page(vma, address);
> @@ -944,7 +968,7 @@ retry:
>  			ret = -PTR_ERR(page);
>  			goto out;
>  		}
> -		clear_huge_page(page, address);
> +		clear_huge_page(page, address, huge_page_size(h));
>  		__SetPageUptodate(page);
> 
>  		if (vma->vm_flags & VM_SHARED) {
> @@ -960,14 +984,14 @@ retry:
>  			}
> 
>  			spin_lock(&inode->i_lock);
> -			inode->i_blocks += BLOCKS_PER_HUGEPAGE;
> +			inode->i_blocks += blocks_per_hugepage(h);
>  			spin_unlock(&inode->i_lock);
>  		} else
>  			lock_page(page);
>  	}
> 
>  	spin_lock(&mm->page_table_lock);
> -	size = i_size_read(mapping->host) >> HPAGE_SHIFT;
> +	size = i_size_read(mapping->host) >> huge_page_shift(h);
>  	if (idx >= size)
>  		goto backout;
> 
> @@ -1003,8 +1027,9 @@ int hugetlb_fault(struct mm_struct *mm, 
>  	pte_t entry;
>  	int ret;
>  	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
> +	struct hstate *h = hstate_vma(vma);
> 
> -	ptep = huge_pte_alloc(mm, address);
> +	ptep = huge_pte_alloc(mm, address, huge_page_size(h));
>  	if (!ptep)
>  		return VM_FAULT_OOM;
> 
> @@ -1042,6 +1067,7 @@ int follow_hugetlb_page(struct mm_struct
>  	unsigned long pfn_offset;
>  	unsigned long vaddr = *position;
>  	int remainder = *length;
> +	struct hstate *h = hstate_vma(vma);
> 
>  	spin_lock(&mm->page_table_lock);
>  	while (vaddr < vma->vm_end && remainder) {
> @@ -1053,7 +1079,7 @@ int follow_hugetlb_page(struct mm_struct
>  		 * each hugepage.  We have to make * sure we get the
>  		 * first, for the page indexing below to work.
>  		 */
> -		pte = huge_pte_offset(mm, vaddr & HPAGE_MASK);
> +		pte = huge_pte_offset(mm, vaddr & huge_page_mask(h));
> 
>  		if (!pte || huge_pte_none(huge_ptep_get(pte)) ||
>  		    (write && !pte_write(huge_ptep_get(pte)))) {
> @@ -1071,7 +1097,7 @@ int follow_hugetlb_page(struct mm_struct
>  			break;
>  		}
> 
> -		pfn_offset = (vaddr & ~HPAGE_MASK) >> PAGE_SHIFT;
> +		pfn_offset = (vaddr & ~huge_page_mask(h)) >> PAGE_SHIFT;
>  		page = pte_page(huge_ptep_get(pte));
>  same_page:
>  		if (pages) {
> @@ -1087,7 +1113,7 @@ same_page:
>  		--remainder;
>  		++i;
>  		if (vaddr < vma->vm_end && remainder &&
> -				pfn_offset < HPAGE_SIZE/PAGE_SIZE) {
> +				pfn_offset < (1 << huge_page_order(h))) {
>  			/*
>  			 * We use pfn_offset to avoid touching the pageframes
>  			 * of this compound page.
> @@ -1109,13 +1135,14 @@ void hugetlb_change_protection(struct vm
>  	unsigned long start = address;
>  	pte_t *ptep;
>  	pte_t pte;
> +	struct hstate *h = hstate_vma(vma);
> 
>  	BUG_ON(address >= end);
>  	flush_cache_range(vma, address, end);
> 
>  	spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
>  	spin_lock(&mm->page_table_lock);
> -	for (; address < end; address += HPAGE_SIZE) {
> +	for (; address < end; address += huge_page_size(h)) {
>  		ptep = huge_pte_offset(mm, address);
>  		if (!ptep)
>  			continue;
> @@ -1254,7 +1281,7 @@ static long region_truncate(struct list_
>  	return chg;
>  }
> 
> -static int hugetlb_acct_memory(long delta)
> +static int hugetlb_acct_memory(struct hstate *h, long delta)
>  {
>  	int ret = -ENOMEM;
> 
> @@ -1277,18 +1304,18 @@ static int hugetlb_acct_memory(long delt
>  	 * semantics that cpuset has.
>  	 */
>  	if (delta > 0) {
> -		if (gather_surplus_pages(delta) < 0)
> +		if (gather_surplus_pages(h, delta) < 0)
>  			goto out;
> 
> -		if (delta > cpuset_mems_nr(free_huge_pages_node)) {
> -			return_unused_surplus_pages(delta);
> +		if (delta > cpuset_mems_nr(h->free_huge_pages_node)) {
> +			return_unused_surplus_pages(h, delta);
>  			goto out;
>  		}
>  	}
> 
>  	ret = 0;
>  	if (delta < 0)
> -		return_unused_surplus_pages((unsigned long) -delta);
> +		return_unused_surplus_pages(h, (unsigned long) -delta);
> 
>  out:
>  	spin_unlock(&hugetlb_lock);
> @@ -1298,6 +1325,7 @@ out:
>  int hugetlb_reserve_pages(struct inode *inode, long from, long to)
>  {
>  	long ret, chg;
> +	struct hstate *h = hstate_inode(inode);
> 
>  	chg = region_chg(&inode->i_mapping->private_list, from, to);
>  	if (chg < 0)
> @@ -1305,7 +1333,7 @@ int hugetlb_reserve_pages(struct inode *
> 
>  	if (hugetlb_get_quota(inode->i_mapping, chg))
>  		return -ENOSPC;
> -	ret = hugetlb_acct_memory(chg);
> +	ret = hugetlb_acct_memory(h, chg);
>  	if (ret < 0) {
>  		hugetlb_put_quota(inode->i_mapping, chg);
>  		return ret;
> @@ -1316,12 +1344,13 @@ int hugetlb_reserve_pages(struct inode *
> 
>  void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
>  {
> +	struct hstate *h = hstate_inode(inode);
>  	long chg = region_truncate(&inode->i_mapping->private_list, offset);
> 
>  	spin_lock(&inode->i_lock);
> -	inode->i_blocks -= BLOCKS_PER_HUGEPAGE * freed;
> +	inode->i_blocks -= blocks_per_hugepage(h);
>  	spin_unlock(&inode->i_lock);
> 
>  	hugetlb_put_quota(inode->i_mapping, (chg - freed));
> -	hugetlb_acct_memory(-(chg - freed));
> +	hugetlb_acct_memory(h, -(chg - freed));
>  }
> Index: linux-2.6/arch/powerpc/mm/hugetlbpage.c
> ===================================================================
> --- linux-2.6.orig/arch/powerpc/mm/hugetlbpage.c
> +++ linux-2.6/arch/powerpc/mm/hugetlbpage.c
> @@ -128,7 +128,7 @@ pte_t *huge_pte_offset(struct mm_struct 
>  	return NULL;
>  }
> 
> -pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr)
> +pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
>  {
>  	pgd_t *pg;
>  	pud_t *pu;
> Index: linux-2.6/arch/sparc64/mm/hugetlbpage.c
> ===================================================================
> --- linux-2.6.orig/arch/sparc64/mm/hugetlbpage.c
> +++ linux-2.6/arch/sparc64/mm/hugetlbpage.c
> @@ -175,7 +175,7 @@ hugetlb_get_unmapped_area(struct file *f
>  		return -ENOMEM;
> 
>  	if (flags & MAP_FIXED) {
> -		if (prepare_hugepage_range(addr, len))
> +		if (prepare_hugepage_range(file, addr, len))
>  			return -EINVAL;
>  		return addr;
>  	}
> @@ -195,7 +195,7 @@ hugetlb_get_unmapped_area(struct file *f
>  				pgoff, flags);
>  }
> 
> -pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr)
> +pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
>  {
>  	pgd_t *pgd;
>  	pud_t *pud;
> Index: linux-2.6/arch/sh/mm/hugetlbpage.c
> ===================================================================
> --- linux-2.6.orig/arch/sh/mm/hugetlbpage.c
> +++ linux-2.6/arch/sh/mm/hugetlbpage.c
> @@ -22,7 +22,7 @@
>  #include <asm/tlbflush.h>
>  #include <asm/cacheflush.h>
> 
> -pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr)
> +pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
>  {
>  	pgd_t *pgd;
>  	pud_t *pud;
> Index: linux-2.6/arch/ia64/mm/hugetlbpage.c
> ===================================================================
> --- linux-2.6.orig/arch/ia64/mm/hugetlbpage.c
> +++ linux-2.6/arch/ia64/mm/hugetlbpage.c
> @@ -24,7 +24,7 @@
>  unsigned int hpage_shift=HPAGE_SHIFT_DEFAULT;
> 
>  pte_t *
> -huge_pte_alloc (struct mm_struct *mm, unsigned long addr)
> +huge_pte_alloc (struct mm_struct *mm, unsigned long addr, unsigned long sz)
>  {
>  	unsigned long taddr = htlbpage_to_page(addr);
>  	pgd_t *pgd;
> @@ -75,7 +75,7 @@ int huge_pmd_unshare(struct mm_struct *m
>   * Don't actually need to do any preparation, but need to make sure
>   * the address is in the right region.
>   */
> -int prepare_hugepage_range(unsigned long addr, unsigned long len)
> +int prepare_hugepage_range(struct file *file, unsigned long addr, unsigned long len)
>  {
>  	if (len & ~HPAGE_MASK)
>  		return -EINVAL;
> @@ -149,7 +149,7 @@ unsigned long hugetlb_get_unmapped_area(
> 
>  	/* Handle MAP_FIXED */
>  	if (flags & MAP_FIXED) {
> -		if (prepare_hugepage_range(addr, len))
> +		if (prepare_hugepage_range(file, addr, len))
>  			return -EINVAL;
>  		return addr;
>  	}
> Index: linux-2.6/arch/x86/mm/hugetlbpage.c
> ===================================================================
> --- linux-2.6.orig/arch/x86/mm/hugetlbpage.c
> +++ linux-2.6/arch/x86/mm/hugetlbpage.c
> @@ -124,7 +124,7 @@ int huge_pmd_unshare(struct mm_struct *m
>  	return 1;
>  }
> 
> -pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr)
> +pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
>  {
>  	pgd_t *pgd;
>  	pud_t *pud;
> @@ -368,7 +368,7 @@ hugetlb_get_unmapped_area(struct file *f
>  		return -ENOMEM;
> 
>  	if (flags & MAP_FIXED) {
> -		if (prepare_hugepage_range(addr, len))
> +		if (prepare_hugepage_range(file, addr, len))
>  			return -EINVAL;
>  		return addr;
>  	}
> Index: linux-2.6/include/linux/hugetlb.h
> ===================================================================
> --- linux-2.6.orig/include/linux/hugetlb.h
> +++ linux-2.6/include/linux/hugetlb.h
> @@ -8,7 +8,6 @@
>  #include <linux/mempolicy.h>
>  #include <linux/shm.h>
>  #include <asm/tlbflush.h>
> -#include <asm/hugetlb.h>
> 
>  struct ctl_table;
> 
> @@ -41,7 +40,7 @@ extern int sysctl_hugetlb_shm_group;
> 
>  /* arch callbacks */
> 
> -pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr);
> +pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz);
>  pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr);
>  int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
>  struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
> @@ -71,7 +70,7 @@ static inline unsigned long hugetlb_tota
>  #define hugetlb_report_meminfo(buf)		0
>  #define hugetlb_report_node_meminfo(n, buf)	0
>  #define follow_huge_pmd(mm, addr, pmd, write)	NULL
> -#define prepare_hugepage_range(addr,len)	(-EINVAL)
> +#define prepare_hugepage_range(file, addr, len)	(-EINVAL)
>  #define pmd_huge(x)	0
>  #define is_hugepage_only_range(mm, addr, len)	0
>  #define hugetlb_free_pgd_range(tlb, addr, end, floor, ceiling) ({BUG(); 0; })
> @@ -125,8 +124,6 @@ struct file *hugetlb_file_setup(const ch
>  int hugetlb_get_quota(struct address_space *mapping, long delta);
>  void hugetlb_put_quota(struct address_space *mapping, long delta);
> 
> -#define BLOCKS_PER_HUGEPAGE	(HPAGE_SIZE / 512)
> -
>  static inline int is_file_hugepages(struct file *file)
>  {
>  	if (file->f_op == &hugetlbfs_file_operations)
> @@ -155,4 +152,78 @@ unsigned long hugetlb_get_unmapped_area(
>  					unsigned long flags);
>  #endif /* HAVE_ARCH_HUGETLB_UNMAPPED_AREA */
> 
> +#ifdef CONFIG_HUGETLB_PAGE
> +
> +/* Defines one hugetlb page size */
> +struct hstate {
> +	int hugetlb_next_nid;
> +	unsigned int order;
> +	unsigned long mask;
> +	unsigned long max_huge_pages;
> +	unsigned long nr_huge_pages;
> +	unsigned long free_huge_pages;
> +	unsigned long resv_huge_pages;
> +	unsigned long surplus_huge_pages;
> +	unsigned long nr_overcommit_huge_pages;
> +	struct list_head hugepage_freelists[MAX_NUMNODES];
> +	unsigned int nr_huge_pages_node[MAX_NUMNODES];
> +	unsigned int free_huge_pages_node[MAX_NUMNODES];
> +	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
> +};
> +
> +extern struct hstate global_hstate;
> +
> +static inline struct hstate *hstate_vma(struct vm_area_struct *vma)
> +{
> +	return &global_hstate;
> +}
> +
> +static inline struct hstate *hstate_file(struct file *f)
> +{
> +	return &global_hstate;
> +}
> +
> +static inline struct hstate *hstate_inode(struct inode *i)
> +{
> +	return &global_hstate;
> +}
> +
> +static inline unsigned long huge_page_size(struct hstate *h)
> +{
> +	return (unsigned long)PAGE_SIZE << h->order;
> +}
> +
> +static inline unsigned long huge_page_mask(struct hstate *h)
> +{
> +	return h->mask;
> +}
> +
> +static inline unsigned long huge_page_order(struct hstate *h)
> +{
> +	return h->order;
> +}
> +
> +static inline unsigned huge_page_shift(struct hstate *h)
> +{
> +	return h->order + PAGE_SHIFT;
> +}
> +
> +static inline unsigned int blocks_per_hugepage(struct hstate *h)
> +{
> +	return huge_page_size(h) / 512;
> +}
> +
> +#else
> +struct hstate {};
> +#define hstate_file(f) NULL
> +#define hstate_vma(v) NULL
> +#define hstate_inode(i) NULL
> +#define huge_page_size(h) PAGE_SIZE
> +#define huge_page_mask(h) PAGE_MASK
> +#define huge_page_order(h) 0
> +#define huge_page_shift(h) PAGE_SHIFT
> +#endif
> +
> +#include <asm/hugetlb.h>
> +
>  #endif /* _LINUX_HUGETLB_H */
> Index: linux-2.6/fs/hugetlbfs/inode.c
> ===================================================================
> --- linux-2.6.orig/fs/hugetlbfs/inode.c
> +++ linux-2.6/fs/hugetlbfs/inode.c
> @@ -80,6 +80,7 @@ static int hugetlbfs_file_mmap(struct fi
>  	struct inode *inode = file->f_path.dentry->d_inode;
>  	loff_t len, vma_len;
>  	int ret;
> +	struct hstate *h = hstate_file(file);
> 
>  	/*
>  	 * vma address alignment (but not the pgoff alignment) has
> @@ -92,7 +93,7 @@ static int hugetlbfs_file_mmap(struct fi
>  	vma->vm_flags |= VM_HUGETLB | VM_RESERVED;
>  	vma->vm_ops = &hugetlb_vm_ops;
> 
> -	if (vma->vm_pgoff & ~(HPAGE_MASK >> PAGE_SHIFT))
> +	if (vma->vm_pgoff & ~(huge_page_mask(h) >> PAGE_SHIFT))
>  		return -EINVAL;
> 
>  	vma_len = (loff_t)(vma->vm_end - vma->vm_start);
> @@ -104,8 +105,8 @@ static int hugetlbfs_file_mmap(struct fi
>  	len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
> 
>  	if (vma->vm_flags & VM_MAYSHARE &&
> -	    hugetlb_reserve_pages(inode, vma->vm_pgoff >> (HPAGE_SHIFT-PAGE_SHIFT),
> -				  len >> HPAGE_SHIFT))
> +	    hugetlb_reserve_pages(inode, vma->vm_pgoff >> huge_page_order(h),
> +				  len >> huge_page_shift(h)))
>  		goto out;
> 
>  	ret = 0;
> @@ -130,20 +131,21 @@ hugetlb_get_unmapped_area(struct file *f
>  	struct mm_struct *mm = current->mm;
>  	struct vm_area_struct *vma;
>  	unsigned long start_addr;
> +	struct hstate *h = hstate_file(file);
> 
> -	if (len & ~HPAGE_MASK)
> +	if (len & ~huge_page_mask(h))
>  		return -EINVAL;
>  	if (len > TASK_SIZE)
>  		return -ENOMEM;
> 
>  	if (flags & MAP_FIXED) {
> -		if (prepare_hugepage_range(addr, len))
> +		if (prepare_hugepage_range(file, addr, len))
>  			return -EINVAL;
>  		return addr;
>  	}
> 
>  	if (addr) {
> -		addr = ALIGN(addr, HPAGE_SIZE);
> +		addr = ALIGN(addr, huge_page_size(h));
>  		vma = find_vma(mm, addr);
>  		if (TASK_SIZE - len >= addr &&
>  		    (!vma || addr + len <= vma->vm_start))
> @@ -156,7 +158,7 @@ hugetlb_get_unmapped_area(struct file *f
>  		start_addr = TASK_UNMAPPED_BASE;
> 
>  full_search:
> -	addr = ALIGN(start_addr, HPAGE_SIZE);
> +	addr = ALIGN(start_addr, huge_page_size(h));
> 
>  	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
>  		/* At this point:  (!vma || addr < vma->vm_end). */
> @@ -174,7 +176,7 @@ full_search:
> 
>  		if (!vma || addr + len <= vma->vm_start)
>  			return addr;
> -		addr = ALIGN(vma->vm_end, HPAGE_SIZE);
> +		addr = ALIGN(vma->vm_end, huge_page_size(h));
>  	}
>  }
>  #endif
> @@ -225,10 +227,11 @@ hugetlbfs_read_actor(struct page *page, 
>  static ssize_t hugetlbfs_read(struct file *filp, char __user *buf,
>  			      size_t len, loff_t *ppos)
>  {
> +	struct hstate *h = hstate_file(filp);
>  	struct address_space *mapping = filp->f_mapping;
>  	struct inode *inode = mapping->host;
> -	unsigned long index = *ppos >> HPAGE_SHIFT;
> -	unsigned long offset = *ppos & ~HPAGE_MASK;
> +	unsigned long index = *ppos >> huge_page_shift(h);
> +	unsigned long offset = *ppos & ~huge_page_mask(h);
>  	unsigned long end_index;
>  	loff_t isize;
>  	ssize_t retval = 0;
> @@ -243,17 +246,17 @@ static ssize_t hugetlbfs_read(struct fil
>  	if (!isize)
>  		goto out;
> 
> -	end_index = (isize - 1) >> HPAGE_SHIFT;
> +	end_index = (isize - 1) >> huge_page_shift(h);
>  	for (;;) {
>  		struct page *page;
> -		int nr, ret;
> +		unsigned long nr, ret;
> 
>  		/* nr is the maximum number of bytes to copy from this page */
> -		nr = HPAGE_SIZE;
> +		nr = huge_page_size(h);
>  		if (index >= end_index) {
>  			if (index > end_index)
>  				goto out;
> -			nr = ((isize - 1) & ~HPAGE_MASK) + 1;
> +			nr = ((isize - 1) & ~huge_page_mask(h)) + 1;
>  			if (nr <= offset) {
>  				goto out;
>  			}
> @@ -287,8 +290,8 @@ static ssize_t hugetlbfs_read(struct fil
>  		offset += ret;
>  		retval += ret;
>  		len -= ret;
> -		index += offset >> HPAGE_SHIFT;
> -		offset &= ~HPAGE_MASK;
> +		index += offset >> huge_page_shift(h);
> +		offset &= ~huge_page_mask(h);
> 
>  		if (page)
>  			page_cache_release(page);
> @@ -298,7 +301,7 @@ static ssize_t hugetlbfs_read(struct fil
>  			break;
>  	}
>  out:
> -	*ppos = ((loff_t)index << HPAGE_SHIFT) + offset;
> +	*ppos = ((loff_t)index << huge_page_shift(h)) + offset;
>  	mutex_unlock(&inode->i_mutex);
>  	return retval;
>  }
> @@ -339,8 +342,9 @@ static void truncate_huge_page(struct pa
> 
>  static void truncate_hugepages(struct inode *inode, loff_t lstart)
>  {
> +	struct hstate *h = hstate_inode(inode);
>  	struct address_space *mapping = &inode->i_data;
> -	const pgoff_t start = lstart >> HPAGE_SHIFT;
> +	const pgoff_t start = lstart >> huge_page_shift(h);
>  	struct pagevec pvec;
>  	pgoff_t next;
>  	int i, freed = 0;
> @@ -449,8 +453,9 @@ static int hugetlb_vmtruncate(struct ino
>  {
>  	pgoff_t pgoff;
>  	struct address_space *mapping = inode->i_mapping;
> +	struct hstate *h = hstate_inode(inode);
> 
> -	BUG_ON(offset & ~HPAGE_MASK);
> +	BUG_ON(offset & ~huge_page_mask(h));
>  	pgoff = offset >> PAGE_SHIFT;
> 
>  	i_size_write(inode, offset);
> @@ -465,6 +470,7 @@ static int hugetlb_vmtruncate(struct ino
>  static int hugetlbfs_setattr(struct dentry *dentry, struct iattr *attr)
>  {
>  	struct inode *inode = dentry->d_inode;
> +	struct hstate *h = hstate_inode(inode);
>  	int error;
>  	unsigned int ia_valid = attr->ia_valid;
> 
> @@ -476,7 +482,7 @@ static int hugetlbfs_setattr(struct dent
> 
>  	if (ia_valid & ATTR_SIZE) {
>  		error = -EINVAL;
> -		if (!(attr->ia_size & ~HPAGE_MASK))
> +		if (!(attr->ia_size & ~huge_page_mask(h)))
>  			error = hugetlb_vmtruncate(inode, attr->ia_size);
>  		if (error)
>  			goto out;
> @@ -610,9 +616,10 @@ static int hugetlbfs_set_page_dirty(stru
>  static int hugetlbfs_statfs(struct dentry *dentry, struct kstatfs *buf)
>  {
>  	struct hugetlbfs_sb_info *sbinfo = HUGETLBFS_SB(dentry->d_sb);
> +	struct hstate *h = hstate_inode(dentry->d_inode);
> 
>  	buf->f_type = HUGETLBFS_MAGIC;
> -	buf->f_bsize = HPAGE_SIZE;
> +	buf->f_bsize = huge_page_size(h);
>  	if (sbinfo) {
>  		spin_lock(&sbinfo->stat_lock);
>  		/* If no limits set, just report 0 for max/free/used
> Index: linux-2.6/ipc/shm.c
> ===================================================================
> --- linux-2.6.orig/ipc/shm.c
> +++ linux-2.6/ipc/shm.c
> @@ -577,7 +577,8 @@ static void shm_get_stat(struct ipc_name
> 
>  		if (is_file_hugepages(shp->shm_file)) {
>  			struct address_space *mapping = inode->i_mapping;
> -			*rss += (HPAGE_SIZE/PAGE_SIZE)*mapping->nrpages;
> +			struct hstate *h = hstate_file(shp->shm_file);
> +			*rss += (1 << huge_page_order(h)) * mapping->nrpages;
>  		} else {
>  			struct shmem_inode_info *info = SHMEM_I(inode);
>  			spin_lock(&info->lock);
> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c
> +++ linux-2.6/mm/memory.c
> @@ -901,7 +901,7 @@ unsigned long unmap_vmas(struct mmu_gath
>  			if (unlikely(is_vm_hugetlb_page(vma))) {
>  				unmap_hugepage_range(vma, start, end);
>  				zap_work -= (end - start) /
> -						(HPAGE_SIZE / PAGE_SIZE);
> +					(1 << huge_page_order(hstate_vma(vma)));
>  				start = end;
>  			} else
>  				start = unmap_page_range(*tlbp, vma,
> Index: linux-2.6/mm/mempolicy.c
> ===================================================================
> --- linux-2.6.orig/mm/mempolicy.c
> +++ linux-2.6/mm/mempolicy.c
> @@ -1477,7 +1477,7 @@ struct zonelist *huge_zonelist(struct vm
> 
>  	if (unlikely((*mpol)->mode == MPOL_INTERLEAVE)) {
>  		zl = node_zonelist(interleave_nid(*mpol, vma, addr,
> -						HPAGE_SHIFT), gfp_flags);
> +				huge_page_shift(hstate_vma(vma))), gfp_flags);
>  	} else {
>  		zl = policy_zonelist(gfp_flags, *mpol);
>  		if ((*mpol)->mode == MPOL_BIND)
> @@ -2216,9 +2216,12 @@ static void check_huge_range(struct vm_a
>  {
>  	unsigned long addr;
>  	struct page *page;
> +	struct hstate *h = hstate_vma(vma);
> +	unsigned long sz = huge_page_size(h);
> 
> -	for (addr = start; addr < end; addr += HPAGE_SIZE) {
> -		pte_t *ptep = huge_pte_offset(vma->vm_mm, addr & HPAGE_MASK);
> +	for (addr = start; addr < end; addr += sz) {
> +		pte_t *ptep = huge_pte_offset(vma->vm_mm,
> +						addr & huge_page_mask(h));
>  		pte_t pte;
> 
>  		if (!ptep)
> Index: linux-2.6/mm/mmap.c
> ===================================================================
> --- linux-2.6.orig/mm/mmap.c
> +++ linux-2.6/mm/mmap.c
> @@ -1800,7 +1800,8 @@ int split_vma(struct mm_struct * mm, str
>  	struct mempolicy *pol;
>  	struct vm_area_struct *new;
> 
> -	if (is_vm_hugetlb_page(vma) && (addr & ~HPAGE_MASK))
> +	if (is_vm_hugetlb_page(vma) && (addr &
> +					~(huge_page_mask(hstate_vma(vma)))))
>  		return -EINVAL;
> 
>  	if (mm->map_count >= sysctl_max_map_count)
> Index: linux-2.6/include/asm-ia64/hugetlb.h
> ===================================================================
> --- linux-2.6.orig/include/asm-ia64/hugetlb.h
> +++ linux-2.6/include/asm-ia64/hugetlb.h
> @@ -8,7 +8,7 @@ void hugetlb_free_pgd_range(struct mmu_g
>  			    unsigned long end, unsigned long floor,
>  			    unsigned long ceiling);
> 
> -int prepare_hugepage_range(unsigned long addr, unsigned long len);
> +int prepare_hugepage_range(struct file *file, unsigned long addr, unsigned long len);
> 
>  static inline int is_hugepage_only_range(struct mm_struct *mm,
>  					 unsigned long addr,
> Index: linux-2.6/include/asm-powerpc/hugetlb.h
> ===================================================================
> --- linux-2.6.orig/include/asm-powerpc/hugetlb.h
> +++ linux-2.6/include/asm-powerpc/hugetlb.h
> @@ -21,7 +21,7 @@ pte_t huge_ptep_get_and_clear(struct mm_
>   * If the arch doesn't supply something else, assume that hugepage
>   * size aligned regions are ok without further preparation.
>   */
> -static inline int prepare_hugepage_range(unsigned long addr, unsigned long len)
> +static inline int prepare_hugepage_range(struct file *file, unsigned long addr, unsigned long len)
>  {
>  	if (len & ~HPAGE_MASK)
>  		return -EINVAL;
> Index: linux-2.6/include/asm-s390/hugetlb.h
> ===================================================================
> --- linux-2.6.orig/include/asm-s390/hugetlb.h
> +++ linux-2.6/include/asm-s390/hugetlb.h
> @@ -22,7 +22,7 @@ void set_huge_pte_at(struct mm_struct *m
>   * If the arch doesn't supply something else, assume that hugepage
>   * size aligned regions are ok without further preparation.
>   */
> -static inline int prepare_hugepage_range(unsigned long addr, unsigned long len)
> +static inline int prepare_hugepage_range(struct file *file, unsigned long addr, unsigned long len)
>  {
>  	if (len & ~HPAGE_MASK)
>  		return -EINVAL;
> Index: linux-2.6/include/asm-sh/hugetlb.h
> ===================================================================
> --- linux-2.6.orig/include/asm-sh/hugetlb.h
> +++ linux-2.6/include/asm-sh/hugetlb.h
> @@ -14,7 +14,7 @@ static inline int is_hugepage_only_range
>   * If the arch doesn't supply something else, assume that hugepage
>   * size aligned regions are ok without further preparation.
>   */
> -static inline int prepare_hugepage_range(unsigned long addr, unsigned long len)
> +static inline int prepare_hugepage_range(struct file *file, unsigned long addr, unsigned long len)
>  {
>  	if (len & ~HPAGE_MASK)
>  		return -EINVAL;
> Index: linux-2.6/include/asm-sparc64/hugetlb.h
> ===================================================================
> --- linux-2.6.orig/include/asm-sparc64/hugetlb.h
> +++ linux-2.6/include/asm-sparc64/hugetlb.h
> @@ -22,7 +22,7 @@ static inline int is_hugepage_only_range
>   * If the arch doesn't supply something else, assume that hugepage
>   * size aligned regions are ok without further preparation.
>   */
> -static inline int prepare_hugepage_range(unsigned long addr, unsigned long len)
> +static inline int prepare_hugepage_range(struct file *file, unsigned long addr, unsigned long len)
>  {
>  	if (len & ~HPAGE_MASK)
>  		return -EINVAL;
> Index: linux-2.6/include/asm-x86/hugetlb.h
> ===================================================================
> --- linux-2.6.orig/include/asm-x86/hugetlb.h
> +++ linux-2.6/include/asm-x86/hugetlb.h
> @@ -14,11 +14,12 @@ static inline int is_hugepage_only_range
>   * If the arch doesn't supply something else, assume that hugepage
>   * size aligned regions are ok without further preparation.
>   */
> -static inline int prepare_hugepage_range(unsigned long addr, unsigned long len)
> +static inline int prepare_hugepage_range(struct file *file, unsigned long addr, unsigned long len)
>  {
> -	if (len & ~HPAGE_MASK)
> +	struct hstate *h = hstate_file(file);
> +	if (len & ~huge_page_mask(h))
>  		return -EINVAL;
> -	if (addr & ~HPAGE_MASK)
> +	if (addr & ~huge_page_mask(h))
>  		return -EINVAL;
>  	return 0;
>  }
> 
-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
