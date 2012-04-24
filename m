Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 2DC4D6B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 10:03:38 -0400 (EDT)
Received: by qam2 with SMTP id 2so101775qam.14
        for <linux-mm@kvack.org>; Tue, 24 Apr 2012 07:03:37 -0700 (PDT)
Date: Tue, 24 Apr 2012 16:03:31 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH 11/23] slub: consider a memcg parameter in
 kmem_create_cache
Message-ID: <20120424140326.GA8626@somewhere>
References: <1334959051-18203-1-git-send-email-glommer@parallels.com>
 <1334959051-18203-12-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1334959051-18203-12-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, Apr 20, 2012 at 06:57:19PM -0300, Glauber Costa wrote:
> diff --git a/mm/slub.c b/mm/slub.c
> index 2652e7c..86e40cc 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -32,6 +32,7 @@
>  #include <linux/prefetch.h>
>  
>  #include <trace/events/kmem.h>
> +#include <linux/memcontrol.h>
>  
>  /*
>   * Lock order:
> @@ -3880,7 +3881,7 @@ static int slab_unmergeable(struct kmem_cache *s)
>  	return 0;
>  }
>  
> -static struct kmem_cache *find_mergeable(size_t size,
> +static struct kmem_cache *find_mergeable(struct mem_cgroup *memcg, size_t size,
>  		size_t align, unsigned long flags, const char *name,
>  		void (*ctor)(void *))
>  {
> @@ -3916,21 +3917,29 @@ static struct kmem_cache *find_mergeable(size_t size,
>  		if (s->size - size >= sizeof(void *))
>  			continue;
>  
> +		if (memcg && s->memcg_params.memcg != memcg)
> +			continue;
> +

This probably won't build without CONFIG_CGROUP_MEM_RES_CTLR_KMEM ?

>  		return s;
>  	}
>  	return NULL;
>  }
>  
> -struct kmem_cache *kmem_cache_create(const char *name, size_t size,
> -		size_t align, unsigned long flags, void (*ctor)(void *))
> +struct kmem_cache *
> +kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,

Does that build without CONFIG_CGROUP_MEM_RES_CTLR ?

> +			size_t align, unsigned long flags, void (*ctor)(void *))
>  {
>  	struct kmem_cache *s;
>  
>  	if (WARN_ON(!name))
>  		return NULL;
>  
> +#ifndef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> +	WARN_ON(memcg != NULL);
> +#endif
> +
>  	down_write(&slub_lock);
> -	s = find_mergeable(size, align, flags, name, ctor);
> +	s = find_mergeable(memcg, size, align, flags, name, ctor);
>  	if (s) {
>  		s->refcount++;
>  		/*
> @@ -3954,12 +3963,15 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size,
>  				size, align, flags, ctor)) {
>  			list_add(&s->list, &slab_caches);
>  			up_write(&slub_lock);
> +			mem_cgroup_register_cache(memcg, s);

How do you handle when the memcg cgroup gets destroyed? Also that means only one
memcg cgroup can be accounted for a given slab cache? What if that memcg cgroup has
children? Hmm, perhaps this is handled in a further patch in the series, I saw a
patch title with "children" inside :)

Also my knowledge on memory allocators is near zero, so I may well be asking weird
questions...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
