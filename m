Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6836F900002
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 02:54:46 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id z10so652050pdj.20
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 23:54:46 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id zc3si40521128pbc.176.2014.06.11.23.54.44
        for <linux-mm@kvack.org>;
        Wed, 11 Jun 2014 23:54:45 -0700 (PDT)
Date: Thu, 12 Jun 2014 15:58:42 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH -mm v2 5/8] slub: make slab_free non-preemptable
Message-ID: <20140612065842.GE19918@js1304-P5Q-DELUXE>
References: <cover.1402060096.git.vdavydov@parallels.com>
 <7cd6784a36ed997cc6631615d98e11e02e811b1b.1402060096.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7cd6784a36ed997cc6631615d98e11e02e811b1b.1402060096.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, cl@linux.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jun 06, 2014 at 05:22:42PM +0400, Vladimir Davydov wrote:
> Since per memcg cache destruction is scheduled when the last slab is
> freed, to avoid use-after-free in kmem_cache_free we should either
> rearrange code in kmem_cache_free so that it won't dereference the cache
> ptr after freeing the object, or wait for all kmem_cache_free's to
> complete before proceeding to cache destruction.
> 
> The former approach isn't a good option from the future development
> point of view, because every modifications to kmem_cache_free must be
> done with great care then. Hence we should provide a method to wait for
> all currently executing kmem_cache_free's to finish.
> 
> This patch makes SLUB's implementation of kmem_cache_free
> non-preemptable. As a result, synchronize_sched() will work as a barrier
> against kmem_cache_free's in flight, so that issuing it before cache
> destruction will protect us against the use-after-free.
> 
> This won't affect performance of kmem_cache_free, because we already
> disable preemption there, and this patch only moves preempt_enable to
> the end of the function. Neither should it affect the system latency,
> because kmem_cache_free is extremely short, even in its slow path.
> 
> SLAB's version of kmem_cache_free already proceeds with irqs disabled,
> so nothing to be done there.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> ---
>  mm/slub.c |   10 ++--------
>  1 file changed, 2 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 35741592be8c..e46d6abe8a68 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2673,18 +2673,11 @@ static __always_inline void slab_free(struct kmem_cache *s,
>  
>  	slab_free_hook(s, x);
>  
> -redo:
> -	/*
> -	 * Determine the currently cpus per cpu slab.
> -	 * The cpu may change afterward. However that does not matter since
> -	 * data is retrieved via this pointer. If we are on the same cpu
> -	 * during the cmpxchg then the free will succedd.
> -	 */
>  	preempt_disable();

Hello,

Could you add some code comment why this preempt_disable/enable() is
needed? We don't have any clue that kmemcg depends on these things
on code, so someone cannot understand why it is here.

If possible, please add similar code comment on slab_alloc in mm/slab.c.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
