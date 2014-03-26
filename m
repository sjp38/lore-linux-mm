Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 384446B0031
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 17:54:18 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id d1so2398092wiv.15
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 14:54:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r18si2534888wiv.66.2014.03.26.14.53.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Mar 2014 14:53:25 -0700 (PDT)
Date: Wed, 26 Mar 2014 14:53:20 -0700
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm 1/4] sl[au]b: do not charge large allocations to memcg
Message-ID: <20140326215320.GA22656@dhcp22.suse.cz>
References: <cover.1395846845.git.vdavydov@parallels.com>
 <5a5b09d4cb9a15fc120b4bec8be168630a3b43c2.1395846845.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5a5b09d4cb9a15fc120b4bec8be168630a3b43c2.1395846845.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

On Wed 26-03-14 19:28:04, Vladimir Davydov wrote:
> We don't track any random page allocation, so we shouldn't track kmalloc
> that falls back to the page allocator.

Why did we do that in the first place? d79923fad95b (sl[au]b: allocate
objects from memcg cache) didn't tell me much.

How is memcg_kmem_skip_account removal related?

> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Glauber Costa <glommer@gmail.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Pekka Enberg <penberg@kernel.org>
> ---
>  include/linux/slab.h |    2 +-
>  mm/memcontrol.c      |   27 +--------------------------
>  mm/slub.c            |    4 ++--
>  3 files changed, 4 insertions(+), 29 deletions(-)
> 
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 3dd389aa91c7..8a928ff71d93 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -363,7 +363,7 @@ kmalloc_order(size_t size, gfp_t flags, unsigned int order)
>  {
>  	void *ret;
>  
> -	flags |= (__GFP_COMP | __GFP_KMEMCG);
> +	flags |= __GFP_COMP;
>  	ret = (void *) __get_free_pages(flags, order);
>  	kmemleak_alloc(ret, size, 1, flags);
>  	return ret;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b4b6aef562fa..81a162d01d4d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3528,35 +3528,10 @@ __memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **_memcg, int order)
>  
>  	*_memcg = NULL;
>  
> -	/*
> -	 * Disabling accounting is only relevant for some specific memcg
> -	 * internal allocations. Therefore we would initially not have such
> -	 * check here, since direct calls to the page allocator that are marked
> -	 * with GFP_KMEMCG only happen outside memcg core. We are mostly
> -	 * concerned with cache allocations, and by having this test at
> -	 * memcg_kmem_get_cache, we are already able to relay the allocation to
> -	 * the root cache and bypass the memcg cache altogether.
> -	 *
> -	 * There is one exception, though: the SLUB allocator does not create
> -	 * large order caches, but rather service large kmallocs directly from
> -	 * the page allocator. Therefore, the following sequence when backed by
> -	 * the SLUB allocator:
> -	 *
> -	 *	memcg_stop_kmem_account();
> -	 *	kmalloc(<large_number>)
> -	 *	memcg_resume_kmem_account();
> -	 *
> -	 * would effectively ignore the fact that we should skip accounting,
> -	 * since it will drive us directly to this function without passing
> -	 * through the cache selector memcg_kmem_get_cache. Such large
> -	 * allocations are extremely rare but can happen, for instance, for the
> -	 * cache arrays. We bring this test here.
> -	 */
> -	if (!current->mm || current->memcg_kmem_skip_account)
> +	if (!current->mm)
>  		return true;
>  
>  	memcg = get_mem_cgroup_from_mm(current->mm);
> -
>  	if (!memcg_can_account_kmem(memcg)) {
>  		css_put(&memcg->css);
>  		return true;
> diff --git a/mm/slub.c b/mm/slub.c
> index 5e234f1f8853..c2e58a787443 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3325,7 +3325,7 @@ static void *kmalloc_large_node(size_t size, gfp_t flags, int node)
>  	struct page *page;
>  	void *ptr = NULL;
>  
> -	flags |= __GFP_COMP | __GFP_NOTRACK | __GFP_KMEMCG;
> +	flags |= __GFP_COMP | __GFP_NOTRACK;
>  	page = alloc_pages_node(node, flags, get_order(size));
>  	if (page)
>  		ptr = page_address(page);
> @@ -3395,7 +3395,7 @@ void kfree(const void *x)
>  	if (unlikely(!PageSlab(page))) {
>  		BUG_ON(!PageCompound(page));
>  		kfree_hook(x);
> -		__free_memcg_kmem_pages(page, compound_order(page));
> +		__free_pages(page, compound_order(page));
>  		return;
>  	}
>  	slab_free(page->slab_cache, page, object, _RET_IP_);
> -- 
> 1.7.10.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
