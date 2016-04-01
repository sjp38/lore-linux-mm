Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id A83DC6B007E
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 05:04:48 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id 20so14520576wmh.1
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 02:04:48 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id k82si4720337wmc.37.2016.04.01.02.04.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Apr 2016 02:04:47 -0700 (PDT)
Date: Fri, 1 Apr 2016 11:04:41 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH -mm v2 3/3] slub: make dead caches discard free slabs
 immediately
Message-ID: <20160401090441.GD12845@twins.programming.kicks-ass.net>
References: <cover.1422461573.git.vdavydov@parallels.com>
 <6eecfafdc6c3dcbb98d2176cdebcb65abbc180b4.1422461573.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6eecfafdc6c3dcbb98d2176cdebcb65abbc180b4.1422461573.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 28, 2015 at 07:22:51PM +0300, Vladimir Davydov wrote:
> +++ b/mm/slub.c
> @@ -2007,6 +2007,7 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
>  	int pages;
>  	int pobjects;
>  
> +	preempt_disable();
>  	do {
>  		pages = 0;
>  		pobjects = 0;
> @@ -2040,6 +2041,14 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
>  
>  	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page)
>  								!= oldpage);
> +	if (unlikely(!s->cpu_partial)) {
> +		unsigned long flags;
> +
> +		local_irq_save(flags);
> +		unfreeze_partials(s, this_cpu_ptr(s->cpu_slab));
> +		local_irq_restore(flags);
> +	}
> +	preempt_enable();
>  #endif
>  }
>  
> @@ -3369,7 +3378,7 @@ EXPORT_SYMBOL(kfree);
>   * being allocated from last increasing the chance that the last objects
>   * are freed in them.
>   */
> -int __kmem_cache_shrink(struct kmem_cache *s)
> +int __kmem_cache_shrink(struct kmem_cache *s, bool deactivate)
>  {
>  	int node;
>  	int i;
> @@ -3381,14 +3390,26 @@ int __kmem_cache_shrink(struct kmem_cache *s)
>  	unsigned long flags;
>  	int ret = 0;
>  
> +	if (deactivate) {
> +		/*
> +		 * Disable empty slabs caching. Used to avoid pinning offline
> +		 * memory cgroups by kmem pages that can be freed.
> +		 */
> +		s->cpu_partial = 0;
> +		s->min_partial = 0;
> +
> +		/*
> +		 * s->cpu_partial is checked locklessly (see put_cpu_partial),
> +		 * so we have to make sure the change is visible.
> +		 */
> +		kick_all_cpus_sync();
> +	}

Argh! what the heck! and without a single mention in the changelog.

Why are you spraying IPIs across the entire machine? Why isn't
synchronize_sched() good enough, that would allow you to get rid of the
local_irq_save/restore as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
