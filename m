Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id AC5366B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 03:21:14 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id ma3so6915247pbc.29
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 00:21:14 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ho3si6377764pac.233.2014.06.24.00.21.12
        for <linux-mm@kvack.org>;
        Tue, 24 Jun 2014 00:21:13 -0700 (PDT)
Date: Tue, 24 Jun 2014 16:25:54 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH -mm v3 8/8] slab: do not keep free objects/slabs on dead
 memcg caches
Message-ID: <20140624072554.GB4836@js1304-P5Q-DELUXE>
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

Hello, Vladimir.

I'd like to set 0 to free_limit in __kmem_cache_shrink()
rather than memcg_cache_dead() test here, because memcg_cache_dead()
is more expensive than it. Is there any problem in this way?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
