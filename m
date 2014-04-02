Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 56A026B0038
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 20:48:44 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa1so10638922pad.14
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 17:48:44 -0700 (PDT)
Received: from mail-pa0-x249.google.com (mail-pa0-x249.google.com [2607:f8b0:400e:c03::249])
        by mx.google.com with ESMTPS id ub3si141095pac.276.2014.04.01.17.48.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 17:48:43 -0700 (PDT)
Received: by mail-pa0-f73.google.com with SMTP id kq14so1404100pab.4
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 17:48:42 -0700 (PDT)
References: <cover.1396335798.git.vdavydov@parallels.com> <c50644c5c979fbe21e72cc2751876ceaff6ef495.1396335798.git.vdavydov@parallels.com>
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH -mm v2 2/2] mm: get rid of __GFP_KMEMCG
In-reply-to: <c50644c5c979fbe21e72cc2751876ceaff6ef495.1396335798.git.vdavydov@parallels.com>
Date: Tue, 01 Apr 2014 17:48:41 -0700
Message-ID: <xr93a9c4k13q.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org


On Tue, Apr 01 2014, Vladimir Davydov <vdavydov@parallels.com> wrote:

> Currently to allocate a page that should be charged to kmemcg (e.g.
> threadinfo), we pass __GFP_KMEMCG flag to the page allocator. The page
> allocated is then to be freed by free_memcg_kmem_pages. Apart from
> looking asymmetrical, this also requires intrusion to the general
> allocation path. So let's introduce separate functions that will
> alloc/free pages charged to kmemcg.
>
> The new functions are called alloc_kmem_pages and free_kmem_pages. They
> should be used when the caller actually would like to use kmalloc, but
> has to fall back to the page allocator for the allocation is large. They
> only differ from alloc_pages and free_pages in that besides allocating
> or freeing pages they also charge them to the kmem resource counter of
> the current memory cgroup.
>
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> ---
>  include/linux/gfp.h             |   10 ++++---
>  include/linux/memcontrol.h      |    2 +-
>  include/linux/slab.h            |   11 --------
>  include/linux/thread_info.h     |    2 --
>  include/trace/events/gfpflags.h |    1 -
>  kernel/fork.c                   |    6 ++---
>  mm/page_alloc.c                 |   56 ++++++++++++++++++++++++---------------
>  mm/slab_common.c                |   12 +++++++++
>  mm/slub.c                       |    6 ++---
>  9 files changed, 60 insertions(+), 46 deletions(-)
>
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 39b81dc7d01a..d382db71e300 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -31,7 +31,6 @@ struct vm_area_struct;
>  #define ___GFP_HARDWALL		0x20000u
>  #define ___GFP_THISNODE		0x40000u
>  #define ___GFP_RECLAIMABLE	0x80000u
> -#define ___GFP_KMEMCG		0x100000u
>  #define ___GFP_NOTRACK		0x200000u
>  #define ___GFP_NO_KSWAPD	0x400000u
>  #define ___GFP_OTHER_NODE	0x800000u
> @@ -91,7 +90,6 @@ struct vm_area_struct;
>  
>  #define __GFP_NO_KSWAPD	((__force gfp_t)___GFP_NO_KSWAPD)
>  #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE) /* On behalf of other node */
> -#define __GFP_KMEMCG	((__force gfp_t)___GFP_KMEMCG) /* Allocation comes from a memcg-accounted resource */
>  #define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)	/* Allocator intends to dirty page */
>  
>  /*
> @@ -353,6 +351,10 @@ extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
>  #define alloc_page_vma_node(gfp_mask, vma, addr, node)		\
>  	alloc_pages_vma(gfp_mask, 0, vma, addr, node)
>  
> +extern struct page *alloc_kmem_pages(gfp_t gfp_mask, unsigned int order);
> +extern struct page *alloc_kmem_pages_node(int nid, gfp_t gfp_mask,
> +					  unsigned int order);
> +
>  extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
>  extern unsigned long get_zeroed_page(gfp_t gfp_mask);
>  
> @@ -372,8 +374,8 @@ extern void free_pages(unsigned long addr, unsigned int order);
>  extern void free_hot_cold_page(struct page *page, int cold);
>  extern void free_hot_cold_page_list(struct list_head *list, int cold);
>  
> -extern void __free_memcg_kmem_pages(struct page *page, unsigned int order);
> -extern void free_memcg_kmem_pages(unsigned long addr, unsigned int order);
> +extern void __free_kmem_pages(struct page *page, unsigned int order);
> +extern void free_kmem_pages(unsigned long addr, unsigned int order);
>  
>  #define __free_page(page) __free_pages((page), 0)
>  #define free_page(addr) free_pages((addr), 0)
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 29068dd26c3d..13acdb5259f5 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -543,7 +543,7 @@ memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
>  	 * res_counter_charge_nofail, but we hope those allocations are rare,
>  	 * and won't be worth the trouble.
>  	 */
> -	if (!(gfp & __GFP_KMEMCG) || (gfp & __GFP_NOFAIL))
> +	if (gfp & __GFP_NOFAIL)
>  		return true;
>  	if (in_interrupt() || (!current->mm) || (current->flags & PF_KTHREAD))
>  		return true;
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 3dd389aa91c7..6d6959292e00 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -358,17 +358,6 @@ kmem_cache_alloc_node_trace(struct kmem_cache *s,
>  #include <linux/slub_def.h>
>  #endif
>  
> -static __always_inline void *
> -kmalloc_order(size_t size, gfp_t flags, unsigned int order)
> -{
> -	void *ret;
> -
> -	flags |= (__GFP_COMP | __GFP_KMEMCG);
> -	ret = (void *) __get_free_pages(flags, order);
> -	kmemleak_alloc(ret, size, 1, flags);
> -	return ret;
> -}
> -

Removing this from the header file breaks builds without
CONFIG_TRACING.
Example:
    % make allnoconfig && make -j4 mm/
    [...]
    include/linux/slab.h: In function a??kmalloc_order_tracea??:
    include/linux/slab.h:367:2: error: implicit declaration of function a??kmalloc_ordera?? [-Werror=implicit-function-declaration]

>  #ifdef CONFIG_TRACING
>  extern void *kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order);
>  #else
> diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
> index fddbe2023a5d..1807bb194816 100644
> --- a/include/linux/thread_info.h
> +++ b/include/linux/thread_info.h
> @@ -61,8 +61,6 @@ extern long do_no_restart_syscall(struct restart_block *parm);
>  # define THREADINFO_GFP		(GFP_KERNEL | __GFP_NOTRACK)
>  #endif
>  
> -#define THREADINFO_GFP_ACCOUNTED (THREADINFO_GFP | __GFP_KMEMCG)
> -
>  /*
>   * flag set/clear/test wrappers
>   * - pass TIF_xxxx constants to these functions
> diff --git a/include/trace/events/gfpflags.h b/include/trace/events/gfpflags.h
> index 1eddbf1557f2..d6fd8e5b14b7 100644
> --- a/include/trace/events/gfpflags.h
> +++ b/include/trace/events/gfpflags.h
> @@ -34,7 +34,6 @@
>  	{(unsigned long)__GFP_HARDWALL,		"GFP_HARDWALL"},	\
>  	{(unsigned long)__GFP_THISNODE,		"GFP_THISNODE"},	\
>  	{(unsigned long)__GFP_RECLAIMABLE,	"GFP_RECLAIMABLE"},	\
> -	{(unsigned long)__GFP_KMEMCG,		"GFP_KMEMCG"},		\
>  	{(unsigned long)__GFP_MOVABLE,		"GFP_MOVABLE"},		\
>  	{(unsigned long)__GFP_NOTRACK,		"GFP_NOTRACK"},		\
>  	{(unsigned long)__GFP_NO_KSWAPD,	"GFP_NO_KSWAPD"},	\
> diff --git a/kernel/fork.c b/kernel/fork.c
> index f4b09bc15f3a..a1632c878037 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -150,15 +150,15 @@ void __weak arch_release_thread_info(struct thread_info *ti)
>  static struct thread_info *alloc_thread_info_node(struct task_struct *tsk,
>  						  int node)
>  {
> -	struct page *page = alloc_pages_node(node, THREADINFO_GFP_ACCOUNTED,
> -					     THREAD_SIZE_ORDER);
> +	struct page *page = alloc_kmem_pages_node(node, THREADINFO_GFP,
> +						  THREAD_SIZE_ORDER);
>  
>  	return page ? page_address(page) : NULL;
>  }
>  
>  static inline void free_thread_info(struct thread_info *ti)
>  {
> -	free_memcg_kmem_pages((unsigned long)ti, THREAD_SIZE_ORDER);
> +	free_kmem_pages((unsigned long)ti, THREAD_SIZE_ORDER);
>  }
>  # else
>  static struct kmem_cache *thread_info_cache;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0327f9d5a8c0..41378986a1e6 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2723,7 +2723,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  	int migratetype = allocflags_to_migratetype(gfp_mask);
>  	unsigned int cpuset_mems_cookie;
>  	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
> -	struct mem_cgroup *memcg = NULL;
>  
>  	gfp_mask &= gfp_allowed_mask;
>  
> @@ -2742,13 +2741,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  	if (unlikely(!zonelist->_zonerefs->zone))
>  		return NULL;
>  
> -	/*
> -	 * Will only have any effect when __GFP_KMEMCG is set.  This is
> -	 * verified in the (always inline) callee
> -	 */
> -	if (!memcg_kmem_newpage_charge(gfp_mask, &memcg, order))
> -		return NULL;
> -
>  retry_cpuset:
>  	cpuset_mems_cookie = read_mems_allowed_begin();
>  
> @@ -2810,8 +2802,6 @@ out:
>  	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
>  		goto retry_cpuset;
>  
> -	memcg_kmem_commit_charge(page, memcg, order);
> -
>  	if (page)
>  		set_page_owner(page, order, gfp_mask);
>  
> @@ -2868,27 +2858,51 @@ void free_pages(unsigned long addr, unsigned int order)
>  EXPORT_SYMBOL(free_pages);
>  
>  /*
> - * __free_memcg_kmem_pages and free_memcg_kmem_pages will free
> - * pages allocated with __GFP_KMEMCG.
> + * alloc_kmem_pages charges newly allocated pages to the kmem resource counter
> + * of the current memory cgroup.
>   *
> - * Those pages are accounted to a particular memcg, embedded in the
> - * corresponding page_cgroup. To avoid adding a hit in the allocator to search
> - * for that information only to find out that it is NULL for users who have no
> - * interest in that whatsoever, we provide these functions.
> - *
> - * The caller knows better which flags it relies on.
> + * It should be used when the caller would like to use kmalloc, but since the
> + * allocation is large, it has to fall back to the page allocator.
> + */
> +struct page *alloc_kmem_pages(gfp_t gfp_mask, unsigned int order)
> +{
> +	struct page *page;
> +	struct mem_cgroup *memcg = NULL;
> +
> +	if (!memcg_kmem_newpage_charge(gfp_mask, &memcg, order))
> +		return NULL;
> +	page = alloc_pages(gfp_mask, order);
> +	memcg_kmem_commit_charge(page, memcg, order);
> +	return page;
> +}
> +
> +struct page *alloc_kmem_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
> +{
> +	struct page *page;
> +	struct mem_cgroup *memcg = NULL;
> +
> +	if (!memcg_kmem_newpage_charge(gfp_mask, &memcg, order))
> +		return NULL;
> +	page = alloc_pages_node(nid, gfp_mask, order);
> +	memcg_kmem_commit_charge(page, memcg, order);
> +	return page;
> +}
> +
> +/*
> + * __free_kmem_pages and free_kmem_pages will free pages allocated with
> + * alloc_kmem_pages.
>   */
> -void __free_memcg_kmem_pages(struct page *page, unsigned int order)
> +void __free_kmem_pages(struct page *page, unsigned int order)
>  {
>  	memcg_kmem_uncharge_pages(page, order);
>  	__free_pages(page, order);
>  }
>  
> -void free_memcg_kmem_pages(unsigned long addr, unsigned int order)
> +void free_kmem_pages(unsigned long addr, unsigned int order)
>  {
>  	if (addr != 0) {
>  		VM_BUG_ON(!virt_addr_valid((void *)addr));
> -		__free_memcg_kmem_pages(virt_to_page((void *)addr), order);
> +		__free_kmem_pages(virt_to_page((void *)addr), order);
>  	}
>  }
>  
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 6673597ac967..cab4c49b3e8c 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -573,6 +573,18 @@ void __init create_kmalloc_caches(unsigned long flags)
>  }
>  #endif /* !CONFIG_SLOB */
>  
> +void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
> +{
> +	void *ret;
> +	struct page *page;
> +
> +	flags |= __GFP_COMP;
> +	page = alloc_kmem_pages(flags, order);
> +	ret = page ? page_address(page) : NULL;
> +	kmemleak_alloc(ret, size, 1, flags);
> +	return ret;
> +}
> +
>  #ifdef CONFIG_TRACING
>  void *kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order)
>  {
> diff --git a/mm/slub.c b/mm/slub.c
> index b203cfceff95..fa7a1817835e 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3335,8 +3335,8 @@ static void *kmalloc_large_node(size_t size, gfp_t flags, int node)
>  	struct page *page;
>  	void *ptr = NULL;
>  
> -	flags |= __GFP_COMP | __GFP_NOTRACK | __GFP_KMEMCG;
> -	page = alloc_pages_node(node, flags, get_order(size));
> +	flags |= __GFP_COMP | __GFP_NOTRACK;
> +	page = alloc_kmem_pages_node(node, flags, get_order(size));
>  	if (page)
>  		ptr = page_address(page);
>  
> @@ -3405,7 +3405,7 @@ void kfree(const void *x)
>  	if (unlikely(!PageSlab(page))) {
>  		BUG_ON(!PageCompound(page));
>  		kfree_hook(x);
> -		__free_memcg_kmem_pages(page, compound_order(page));
> +		__free_kmem_pages(page, compound_order(page));
>  		return;
>  	}
>  	slab_free(page->slab_cache, page, object, _RET_IP_);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
