Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id E85176B0037
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 03:34:01 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so6883701pad.21
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 00:34:01 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id tx10si25065102pac.112.2014.06.24.00.33.59
        for <linux-mm@kvack.org>;
        Tue, 24 Jun 2014 00:34:01 -0700 (PDT)
Date: Tue, 24 Jun 2014 16:38:41 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH -mm v3 8/8] slab: do not keep free objects/slabs on dead
 memcg caches
Message-ID: <20140624073840.GC4836@js1304-P5Q-DELUXE>
References: <cover.1402602126.git.vdavydov@parallels.com>
 <a985aec824cd35df381692fca83f7a8debc80305.1402602126.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a985aec824cd35df381692fca83f7a8debc80305.1402602126.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, cl@linux.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jun 13, 2014 at 12:38:22AM +0400, Vladimir Davydov wrote:
> Since a dead memcg cache is destroyed only after the last slab allocated
> to it is freed, we must disable caching of free objects/slabs for such
> caches, otherwise they will be hanging around forever.
> 
> For SLAB that means we must disable per cpu free object arrays and make
> free_block always discard empty slabs irrespective of node's free_limit.
> 
> To disable per cpu arrays, we free them on kmem_cache_shrink (see
> drain_cpu_caches -> do_drain) and make __cache_free fall back to
> free_block if there is no per cpu array. Also, we have to disable
> allocation of per cpu arrays on cpu hotplug for dead caches (see
> cpuup_prepare, __do_tune_cpucache).
> 
> After we disabled free objects/slabs caching, there is no need to reap
> those caches periodically. Moreover, it will only result in slowdown. So
> we also make cache_reap skip then.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> ---
>  mm/slab.c |   31 ++++++++++++++++++++++++++++++-
>  1 file changed, 30 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index b3af82419251..7e91f5f1341d 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1210,6 +1210,9 @@ static int cpuup_prepare(long cpu)
>  		struct array_cache *shared = NULL;
>  		struct array_cache **alien = NULL;
>  
> +		if (memcg_cache_dead(cachep))
> +			continue;
> +
>  		nc = alloc_arraycache(node, cachep->limit,
>  					cachep->batchcount, GFP_KERNEL);
>  		if (!nc)
> @@ -2411,10 +2414,18 @@ static void do_drain(void *arg)
>  
>  	check_irq_off();
>  	ac = cpu_cache_get(cachep);
> +	if (!ac)
> +		return;
> +
>  	spin_lock(&cachep->node[node]->list_lock);
>  	free_block(cachep, ac->entry, ac->avail, node);
>  	spin_unlock(&cachep->node[node]->list_lock);
>  	ac->avail = 0;
> +
> +	if (memcg_cache_dead(cachep)) {
> +		cachep->array[smp_processor_id()] = NULL;
> +		kfree(ac);
> +	}
>  }
>  
>  static void drain_cpu_caches(struct kmem_cache *cachep)
> @@ -3368,7 +3379,8 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
>  
>  		/* fixup slab chains */
>  		if (page->active == 0) {
> -			if (n->free_objects > n->free_limit) {
> +			if (n->free_objects > n->free_limit ||
> +			    memcg_cache_dead(cachep)) {
>  				n->free_objects -= cachep->num;
>  				/* No need to drop any previously held
>  				 * lock here, even if we have a off-slab slab
> @@ -3462,6 +3474,17 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
>  
>  	kmemcheck_slab_free(cachep, objp, cachep->object_size);
>  
> +#ifdef CONFIG_MEMCG_KMEM
> +	if (unlikely(!ac)) {
> +		int nodeid = page_to_nid(virt_to_page(objp));
> +
> +		spin_lock(&cachep->node[nodeid]->list_lock);
> +		free_block(cachep, &objp, 1, nodeid);
> +		spin_unlock(&cachep->node[nodeid]->list_lock);
> +		return;
> +	}
> +#endif
> +

And, please document intention of this code. :)

And, you said that this way of implementation would be slow because
there could be many object in dead caches and this implementation
needs node spin_lock on each object freeing. Is it no problem now?

If you have any performance data about this implementation and
alternative one, could you share it?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
