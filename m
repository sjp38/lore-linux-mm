Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9E3CB6B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 00:38:35 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id kx10so3778150pab.14
        for <linux-mm@kvack.org>; Sun, 01 Jun 2014 21:38:35 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id gu3si14384897pbb.232.2014.06.01.21.38.33
        for <linux-mm@kvack.org>;
        Sun, 01 Jun 2014 21:38:34 -0700 (PDT)
Date: Mon, 2 Jun 2014 13:41:55 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH -mm 8/8] slab: reap dead memcg caches aggressively
Message-ID: <20140602044154.GB17964@js1304-P5Q-DELUXE>
References: <cover.1401457502.git.vdavydov@parallels.com>
 <23a736c90a81e13a2252d35d9fc3dc04a9ed7d7c.1401457502.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <23a736c90a81e13a2252d35d9fc3dc04a9ed7d7c.1401457502.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, cl@linux.com, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 30, 2014 at 05:51:11PM +0400, Vladimir Davydov wrote:
> There is no use in keeping free objects/slabs on dead memcg caches,
> because they will never be allocated. So let's make cache_reap() shrink
> as many free objects from such caches as possible.
> 
> Note the difference between SLAB and SLUB handling of dead memcg caches.
> For SLUB, dead cache destruction is scheduled as soon as the last object
> is freed, because dead caches do not cache free objects. For SLAB, dead
> caches can keep some free objects on per cpu arrays, so that an empty
> dead cache will be hanging around until cache_reap() drains it.
> 
> We don't disable free objects caching for SLAB, because it would force
> kfree to always take a spin lock, which would degrade performance
> significantly.
> 
> Since cache_reap() drains all caches once ~4 secs on each CPU, empty
> dead caches will die quickly.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> ---
>  mm/slab.c |   17 ++++++++++++-----
>  1 file changed, 12 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index cecc01bba389..d81e46316c99 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3985,6 +3985,11 @@ static void cache_reap(struct work_struct *w)
>  		goto out;
>  
>  	list_for_each_entry(searchp, &slab_caches, list) {
> +		int force = 0;
> +
> +		if (memcg_cache_dead(searchp))
> +			force = 1;
> +
>  		check_irq_on();
>  
>  		/*
> @@ -3996,7 +4001,7 @@ static void cache_reap(struct work_struct *w)
>  
>  		reap_alien(searchp, n);
>  
> -		drain_array(searchp, n, cpu_cache_get(searchp), 0, node);
> +		drain_array(searchp, n, cpu_cache_get(searchp), force, node);
>  
>  		/*
>  		 * These are racy checks but it does not matter
> @@ -4007,15 +4012,17 @@ static void cache_reap(struct work_struct *w)
>  
>  		n->next_reap = jiffies + REAPTIMEOUT_NODE;
>  
> -		drain_array(searchp, n, n->shared, 0, node);
> +		drain_array(searchp, n, n->shared, force, node);
>  
>  		if (n->free_touched)
>  			n->free_touched = 0;
>  		else {
> -			int freed;
> +			int freed, tofree;
> +
> +			tofree = force ? slabs_tofree(searchp, n) :
> +				DIV_ROUND_UP(n->free_limit, 5 * searchp->num);

Hello,

According to my code reading, slabs_to_free() doesn't return number of
free slabs. This bug is introduced by 0fa8103b. I think that it is
better to fix it before applyting this patch. Otherwise, use n->free_objects
instead of slabs_tofree() to achieve your purpose correctly.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
