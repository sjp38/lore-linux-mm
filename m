Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC066B01E3
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 12:43:57 -0400 (EDT)
Date: Mon, 12 Apr 2010 17:43:35 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] code clean rename alloc_pages_exact_node()
Message-ID: <20100412164335.GQ25756@csn.ul.ie>
References: <1270900173-10695-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1270900173-10695-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, cl@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, penberg@cs.helsinki.fi, lethal@linux-sh.org, a.p.zijlstra@chello.nl, nickpiggin@yahoo.com.au, dave@linux.vnet.ibm.com, lee.schermerhorn@hp.com, rientjes@google.com, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Sat, Apr 10, 2010 at 07:49:32PM +0800, Bob Liu wrote:
> Since alloc_pages_exact_node() is not for allocate page from
> exact node but just for removing check of node's valid,
> rename it to alloc_pages_from_valid_node(). Else will make
> people misunderstanding.
> 

I don't know about this change either but as I introduced the original
function name, I am biased. My reading of it is - allocate me pages and
I know exactly which node I need. I see how it it could be read as
"allocate me pages from exactly this node" but I don't feel the new
naming is that much clearer either.

I recognise I'm not the best at naming though so I don't object to a
namechange if people really feel the new name is better.

> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  arch/ia64/hp/common/sba_iommu.c   |    2 +-
>  arch/ia64/kernel/uncached.c       |    2 +-
>  arch/ia64/sn/pci/pci_dma.c        |    2 +-
>  arch/powerpc/platforms/cell/ras.c |    4 ++--
>  arch/x86/kvm/vmx.c                |    3 ++-
>  drivers/misc/sgi-xp/xpc_uv.c      |    5 +++--
>  include/linux/gfp.h               |    2 +-
>  kernel/profile.c                  |    8 ++++----
>  mm/filemap.c                      |    2 +-
>  mm/hugetlb.c                      |    2 +-
>  mm/memory-failure.c               |    2 +-
>  mm/mempolicy.c                    |    2 +-
>  mm/migrate.c                      |    2 +-
>  mm/slab.c                         |    3 ++-
>  mm/slob.c                         |    4 ++--
>  15 files changed, 24 insertions(+), 21 deletions(-)
> 
> diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
> index e14c492..e578f08 100644
> --- a/arch/ia64/hp/common/sba_iommu.c
> +++ b/arch/ia64/hp/common/sba_iommu.c
> @@ -1140,7 +1140,7 @@ sba_alloc_coherent (struct device *dev, size_t size, dma_addr_t *dma_handle, gfp
>  #ifdef CONFIG_NUMA
>  	{
>  		struct page *page;
> -		page = alloc_pages_exact_node(ioc->node == MAX_NUMNODES ?
> +		page = alloc_pages_from_valid_node(ioc->node == MAX_NUMNODES ?
>  		                        numa_node_id() : ioc->node, flags,
>  		                        get_order(size));
>  
> diff --git a/arch/ia64/kernel/uncached.c b/arch/ia64/kernel/uncached.c
> index c4696d2..ab8c085 100644
> --- a/arch/ia64/kernel/uncached.c
> +++ b/arch/ia64/kernel/uncached.c
> @@ -98,7 +98,7 @@ static int uncached_add_chunk(struct uncached_pool *uc_pool, int nid)
>  
>  	/* attempt to allocate a granule's worth of cached memory pages */
>  
> -	page = alloc_pages_exact_node(nid,
> +	page = alloc_pages_from_valid_node(nid,
>  				GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
>  				IA64_GRANULE_SHIFT-PAGE_SHIFT);
>  	if (!page) {
> diff --git a/arch/ia64/sn/pci/pci_dma.c b/arch/ia64/sn/pci/pci_dma.c
> index a9d310d..e09ccf7 100644
> --- a/arch/ia64/sn/pci/pci_dma.c
> +++ b/arch/ia64/sn/pci/pci_dma.c
> @@ -91,7 +91,7 @@ static void *sn_dma_alloc_coherent(struct device *dev, size_t size,
>  	 */
>  	node = pcibus_to_node(pdev->bus);
>  	if (likely(node >=0)) {
> -		struct page *p = alloc_pages_exact_node(node,
> +		struct page *p = alloc_pages_from_valid_node(node,
>  						flags, get_order(size));
>  
>  		if (likely(p))
> diff --git a/arch/powerpc/platforms/cell/ras.c b/arch/powerpc/platforms/cell/ras.c
> index 1d3c4ef..6d32594 100644
> --- a/arch/powerpc/platforms/cell/ras.c
> +++ b/arch/powerpc/platforms/cell/ras.c
> @@ -123,8 +123,8 @@ static int __init cbe_ptcal_enable_on_node(int nid, int order)
>  
>  	area->nid = nid;
>  	area->order = order;
> -	area->pages = alloc_pages_exact_node(area->nid, GFP_KERNEL|GFP_THISNODE,
> -						area->order);
> +	area->pages = alloc_pages_from_valid_node(area->nid,
> +			GFP_KERNEL | GFP_THISNODE, area->order);
>  
>  	if (!area->pages) {
>  		printk(KERN_WARNING "%s: no page on node %d\n",
> diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
> index 753ffc2..f554b8c 100644
> --- a/arch/x86/kvm/vmx.c
> +++ b/arch/x86/kvm/vmx.c
> @@ -1405,7 +1405,8 @@ static struct vmcs *alloc_vmcs_cpu(int cpu)
>  	struct page *pages;
>  	struct vmcs *vmcs;
>  
> -	pages = alloc_pages_exact_node(node, GFP_KERNEL, vmcs_config.order);
> +	pages = alloc_pages_from_valid_node(node, GFP_KERNEL,
> +			vmcs_config.order);
>  	if (!pages)
>  		return NULL;
>  	vmcs = page_address(pages);
> diff --git a/drivers/misc/sgi-xp/xpc_uv.c b/drivers/misc/sgi-xp/xpc_uv.c
> index 1f59ee2..ba3544e 100644
> --- a/drivers/misc/sgi-xp/xpc_uv.c
> +++ b/drivers/misc/sgi-xp/xpc_uv.c
> @@ -238,8 +238,9 @@ xpc_create_gru_mq_uv(unsigned int mq_size, int cpu, char *irq_name,
>  	mq->mmr_blade = uv_cpu_to_blade_id(cpu);
>  
>  	nid = cpu_to_node(cpu);
> -	page = alloc_pages_exact_node(nid, GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
> -				pg_order);
> +	page = alloc_pages_from_valid_node(nid,
> +			GFP_KERNEL | __GFP_ZERO | GFP_THISNODE, pg_order);
> +
>  	if (page == NULL) {
>  		dev_err(xpc_part, "xpc_create_gru_mq_uv() failed to alloc %d "
>  			"bytes of memory on nid=%d for GRU mq\n", mq_size, nid);
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 4c6d413..c94f2ed 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -288,7 +288,7 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
>  	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
>  }
>  
> -static inline struct page *alloc_pages_exact_node(int nid, gfp_t gfp_mask,
> +static inline struct page *alloc_pages_from_valid_node(int nid, gfp_t gfp_mask,
>  						unsigned int order)
>  {
>  	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
> diff --git a/kernel/profile.c b/kernel/profile.c
> index a55d3a3..4bf82da 100644
> --- a/kernel/profile.c
> +++ b/kernel/profile.c
> @@ -366,7 +366,7 @@ static int __cpuinit profile_cpu_callback(struct notifier_block *info,
>  		node = cpu_to_node(cpu);
>  		per_cpu(cpu_profile_flip, cpu) = 0;
>  		if (!per_cpu(cpu_profile_hits, cpu)[1]) {
> -			page = alloc_pages_exact_node(node,
> +			page = alloc_pages_from_valid_node(node,
>  					GFP_KERNEL | __GFP_ZERO,
>  					0);
>  			if (!page)
> @@ -374,7 +374,7 @@ static int __cpuinit profile_cpu_callback(struct notifier_block *info,
>  			per_cpu(cpu_profile_hits, cpu)[1] = page_address(page);
>  		}
>  		if (!per_cpu(cpu_profile_hits, cpu)[0]) {
> -			page = alloc_pages_exact_node(node,
> +			page = alloc_pages_from_valid_node(node,
>  					GFP_KERNEL | __GFP_ZERO,
>  					0);
>  			if (!page)
> @@ -568,14 +568,14 @@ static int create_hash_tables(void)
>  		int node = cpu_to_node(cpu);
>  		struct page *page;
>  
> -		page = alloc_pages_exact_node(node,
> +		page = alloc_pages_from_valid_node(node,
>  				GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
>  				0);
>  		if (!page)
>  			goto out_cleanup;
>  		per_cpu(cpu_profile_hits, cpu)[1]
>  				= (struct profile_hit *)page_address(page);
> -		page = alloc_pages_exact_node(node,
> +		page = alloc_pages_from_valid_node(node,
>  				GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
>  				0);
>  		if (!page)
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 140ebda..0424c3b 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -463,7 +463,7 @@ struct page *__page_cache_alloc(gfp_t gfp)
>  {
>  	if (cpuset_do_page_mem_spread()) {
>  		int n = cpuset_mem_spread_node();
> -		return alloc_pages_exact_node(n, gfp, 0);
> +		return alloc_pages_from_valid_node(n, gfp, 0);
>  	}
>  	return alloc_pages(gfp, 0);
>  }
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 6034dc9..01dd9c6 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -607,7 +607,7 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
>  	if (h->order >= MAX_ORDER)
>  		return NULL;
>  
> -	page = alloc_pages_exact_node(nid,
> +	page = alloc_pages_from_valid_node(nid,
>  		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|
>  						__GFP_REPEAT|__GFP_NOWARN,
>  		huge_page_order(h));
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 620b0b4..43abda1 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1126,7 +1126,7 @@ EXPORT_SYMBOL(unpoison_memory);
>  static struct page *new_page(struct page *p, unsigned long private, int **x)
>  {
>  	int nid = page_to_nid(p);
> -	return alloc_pages_exact_node(nid, GFP_HIGHUSER_MOVABLE, 0);
> +	return alloc_pages_from_valid_node(nid, GFP_HIGHUSER_MOVABLE, 0);
>  }
>  
>  /*
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 08f40a2..6838cd8 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -842,7 +842,7 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
>  
>  static struct page *new_node_page(struct page *page, unsigned long node, int **x)
>  {
> -	return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE, 0);
> +	return alloc_pages_from_valid_node(node, GFP_HIGHUSER_MOVABLE, 0);
>  }
>  
>  /*
> diff --git a/mm/migrate.c b/mm/migrate.c
> index d3f3f7f..a057a1a 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -770,7 +770,7 @@ static struct page *new_page_node(struct page *p, unsigned long private,
>  
>  	*result = &pm->status;
>  
> -	return alloc_pages_exact_node(pm->node,
> +	return alloc_pages_from_valid_node(pm->node,
>  				GFP_HIGHUSER_MOVABLE | GFP_THISNODE, 0);
>  }
>  
> diff --git a/mm/slab.c b/mm/slab.c
> index 730d45b..4f71736 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1717,7 +1717,8 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
>  	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
>  		flags |= __GFP_RECLAIMABLE;
>  
> -	page = alloc_pages_exact_node(nodeid, flags | __GFP_NOTRACK, cachep->gfporder);
> +	page = alloc_pages_from_valid_node(nodeid, flags | __GFP_NOTRACK,
> +			cachep->gfporder);
>  	if (!page)
>  		return NULL;
>  
> diff --git a/mm/slob.c b/mm/slob.c
> index 837ebd6..9e3f95b 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -46,7 +46,7 @@
>   * NUMA support in SLOB is fairly simplistic, pushing most of the real
>   * logic down to the page allocator, and simply doing the node accounting
>   * on the upper levels. In the event that a node id is explicitly
> - * provided, alloc_pages_exact_node() with the specified node id is used
> + * provided, alloc_pages_from_valid_node() with the specified node id is used
>   * instead. The common case (or when the node id isn't explicitly provided)
>   * will default to the current node, as per numa_node_id().
>   *
> @@ -244,7 +244,7 @@ static void *slob_new_pages(gfp_t gfp, int order, int node)
>  
>  #ifdef CONFIG_NUMA
>  	if (node != -1)
> -		page = alloc_pages_exact_node(node, gfp, order);
> +		page = alloc_pages_from_valid_node(node, gfp, order);
>  	else
>  #endif
>  		page = alloc_pages(gfp, order);
> -- 
> 1.5.6.3
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
