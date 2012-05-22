Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 910F66B004D
	for <linux-mm@kvack.org>; Mon, 21 May 2012 23:22:28 -0400 (EDT)
Received: by dakp5 with SMTP id p5so11110090dak.14
        for <linux-mm@kvack.org>; Mon, 21 May 2012 20:22:27 -0700 (PDT)
Date: Mon, 21 May 2012 20:22:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab+slob: dup name string
In-Reply-To: <1337613539-29108-1-git-send-email-glommer@parallels.com>
Message-ID: <alpine.DEB.2.00.1205212018230.13522@chino.kir.corp.google.com>
References: <1337613539-29108-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Mon, 21 May 2012, Glauber Costa wrote:

> diff --git a/mm/slab.c b/mm/slab.c
> index e901a36..cabd217 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2118,6 +2118,7 @@ static void __kmem_cache_destroy(struct kmem_cache *cachep)
>  			kfree(l3);
>  		}
>  	}
> +	kfree(cachep->name);
>  	kmem_cache_free(&cache_cache, cachep);
>  }
>  
> @@ -2526,9 +2527,14 @@ kmem_cache_create (const char *name, size_t size, size_t align,
>  		BUG_ON(ZERO_OR_NULL_PTR(cachep->slabp_cache));
>  	}
>  	cachep->ctor = ctor;
> -	cachep->name = name;
>  
> -	if (setup_cpu_cache(cachep, gfp)) {
> +	/* Can't do strdup while kmalloc is not up */
> +	if (g_cpucache_up > EARLY)
> +		cachep->name = kstrdup(name, GFP_KERNEL);
> +	else
> +		cachep->name = name;
> +
> +	if (!cachep->name || setup_cpu_cache(cachep, gfp)) {
>  		__kmem_cache_destroy(cachep);
>  		cachep = NULL;
>  		goto oops;

This doesn't work if you kmem_cache_destroy() a cache that was created 
when g_cpucache_cpu <= EARLY, the kfree() will explode.  That never 
happens for any existing cache created in kmem_cache_init(), but this 
would introduce the first roadblock in doing so.  So you'll need some 
magic to determine whether the cache was allocated statically and suppress 
the kfree() in such a case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
