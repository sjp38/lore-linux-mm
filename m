Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3E67E6B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 12:08:36 -0400 (EDT)
Received: by mail-yk0-f175.google.com with SMTP id 131so1663020ykp.34
        for <linux-mm@kvack.org>; Fri, 30 May 2014 09:08:36 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d59si8736527yhj.35.2014.05.30.09.08.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 30 May 2014 09:08:35 -0700 (PDT)
Date: Fri, 30 May 2014 12:08:24 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] gpu/drm/ttm: Use mutex_lock_killable() for shrinker
 functions.
Message-ID: <20140530160824.GD3621@localhost.localdomain>
References: <alpine.DEB.2.00.1405200140010.20503@skynet.skynet.ie>
 <201405210030.HBD65663.FFLVHOFMSJOtOQ@I-love.SAKURA.ne.jp>
 <201405242322.AID86423.HOMLQJOtFFVOSF@I-love.SAKURA.ne.jp>
 <20140528185445.GA23122@phenom.dumpdata.com>
 <201405290647.DHI69200.HSFVFMFOJOLOQt@I-love.SAKURA.ne.jp>
 <201405292334.EAG00503.FLOOJFStHVQMFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201405292334.EAG00503.FLOOJFStHVQMFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: dchinner@redhat.com, airlied@linux.ie, glommer@openvz.org, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org

On Thu, May 29, 2014 at 11:34:59PM +0900, Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > Konrad Rzeszutek Wilk wrote:
> > > On Sat, May 24, 2014 at 11:22:09PM +0900, Tetsuo Handa wrote:
> > > > Hello.
> > > > 
> > > > I tried to test whether it is OK (from point of view of reentrant) to use
> > > > mutex_lock() or mutex_lock_killable() inside shrinker functions when shrinker
> > > > functions do memory allocation, for drivers/gpu/drm/ttm/ttm_page_alloc_dma.c is
> > > > doing memory allocation with mutex lock held inside ttm_dma_pool_shrink_scan().
> > > > 
> > > > If I compile a test module shown below which mimics extreme case of what
> > > > ttm_dma_pool_shrink_scan() will do
> > > 
> > > And ttm_pool_shrink_scan.
> > 
> > I don't know why but ttm_pool_shrink_scan() does not take mutex.
> > 
> Well, it seems to me that ttm_pool_shrink_scan() not taking mutex is a bug
> which could lead to stack overflow if kmalloc() in ttm_page_pool_free()
> triggered recursion.
> 
>   shrink_slab()
>   => ttm_pool_shrink_scan()
>      => ttm_page_pool_free()
>         => kmalloc(GFP_KERNEL)
>            => shrink_slab()
>               => ttm_pool_shrink_scan()
>                  => ttm_page_pool_free()
>                     => kmalloc(GFP_KERNEL)
> 
> Maybe shrink_slab() should be updated not to call same shrinker in parallel?
> 
> Also, it seems to me that ttm_dma_pool_shrink_scan() has potential division
> by 0 bug as described below. Is this patch correct?

Looks OK. I would need to test it first. Could you send both patches
to me please so I can just test them and queue them up together?

Thank you!
> ----------
> >From 4a65744a300e14e5e202c5f13ba2759e1e797d29 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Thu, 29 May 2014 18:25:42 +0900
> Subject: [PATCH] gpu/drm/ttm: Use mutex_trylock() for shrinker functions.
> 
> I can observe that RHEL7 environment stalls with 100% CPU usage when a
> certain type of memory pressure is given. While the shrinker functions
> are called by shrink_slab() before the OOM killer is triggered, the stall
> lasts for many minutes.
> 
> One of reasons of this stall is that
> ttm_dma_pool_shrink_count()/ttm_dma_pool_shrink_scan() are called and
> are blocked at mutex_lock(&_manager->lock). GFP_KERNEL allocation with
> _manager->lock held causes someone (including kswapd) to deadlock when
> these functions are called due to memory pressure. This patch changes
> "mutex_lock();" to "if (!mutex_trylock()) return ...;" in order to
> avoid deadlock.
> 
> At the same time, this patch fixes potential division by 0 due to
> unconditionally doing "% _manager->npools". This is because
> list_empty(&_manager->pools) being false does not guarantee that
> _manager->npools != 0 after taking the _manager->lock because
> _manager->npools is updated under the _manager->lock.
> 
> At the same time, this patch moves updating of start_pool variable
> in order to avoid skipping when choosing a pool to shrink in
> round-robin style. The start_pool is changed from "atomic_t" to
> "unsigned int" because it is now updated under the _manager->lock.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: stable <stable@kernel.org> [3.3+]
> ---
>  drivers/gpu/drm/ttm/ttm_page_alloc_dma.c | 15 ++++++++++-----
>  1 file changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
> index fb8259f..5e332b4 100644
> --- a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
> +++ b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
> @@ -1004,9 +1004,9 @@ EXPORT_SYMBOL_GPL(ttm_dma_unpopulate);
>  static unsigned long
>  ttm_dma_pool_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
>  {
> -	static atomic_t start_pool = ATOMIC_INIT(0);
> +	static unsigned int start_pool;
>  	unsigned idx = 0;
> -	unsigned pool_offset = atomic_add_return(1, &start_pool);
> +	unsigned pool_offset;
>  	unsigned shrink_pages = sc->nr_to_scan;
>  	struct device_pools *p;
>  	unsigned long freed = 0;
> @@ -1014,8 +1014,11 @@ ttm_dma_pool_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
>  	if (list_empty(&_manager->pools))
>  		return SHRINK_STOP;
>  
> -	mutex_lock(&_manager->lock);
> -	pool_offset = pool_offset % _manager->npools;
> +	if (!mutex_trylock(&_manager->lock))
> +		return SHRINK_STOP;
> +	if (!_manager->npools)
> +		goto out;
> +	pool_offset = ++start_pool % _manager->npools;
>  	list_for_each_entry(p, &_manager->pools, pools) {
>  		unsigned nr_free;
>  
> @@ -1034,6 +1037,7 @@ ttm_dma_pool_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
>  			 p->pool->dev_name, p->pool->name, current->pid,
>  			 nr_free, shrink_pages);
>  	}
> +out:
>  	mutex_unlock(&_manager->lock);
>  	return freed;
>  }
> @@ -1044,7 +1048,8 @@ ttm_dma_pool_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
>  	struct device_pools *p;
>  	unsigned long count = 0;
>  
> -	mutex_lock(&_manager->lock);
> +	if (!mutex_trylock(&_manager->lock))
> +		return 0;
>  	list_for_each_entry(p, &_manager->pools, pools)
>  		count += p->pool->npages_free;
>  	mutex_unlock(&_manager->lock);
> -- 
> 1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
