Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id EEEB66B0062
	for <linux-mm@kvack.org>; Mon,  3 Sep 2012 10:54:22 -0400 (EDT)
Message-ID: <5044C3DF.6090009@parallels.com>
Date: Mon, 3 Sep 2012 18:51:11 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: C13 [07/14] Move freeing of kmem_cache structure to common code
References: <20120824160903.168122683@linux.com> <000001395967d655-21142922-91ec-41da-ba80-c050d3230f44-000000@email.amazonses.com>
In-Reply-To: <000001395967d655-21142922-91ec-41da-ba80-c050d3230f44-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 08/24/2012 08:12 PM, Christoph Lameter wrote:
> The freeing action is basically the same in all slab allocators.
> Move to the common kmem_cache_destroy() function.
> 
> Reviewed-by: Joonsoo Kim <js1304@gmail.com>
> Signed-off-by: Christoph Lameter <cl@linux.com>

For slab & slub, it seems trivial. Then:

Reviewed-by: Glauber Costa <glommer@parallels.com>

I should point out that the code movement in the slob is not equivalent.
First, we'll not be always calling kmemleak_free(). We'll only do it
when SLAB_NOLEAKTRACE is not set. This actually seem even safer than
before, but it is worth mentioning.

Also, we'll be freeing here under a rcu call, which didn't happen
before. To my eyes, this seems that it will only potentially take more
time to complete, without any context problems. But slob reviewers are
appreciated.

> ---
>  mm/slab.c        |    1 -
>  mm/slab_common.c |    1 +
>  mm/slob.c        |    2 --
>  mm/slub.c        |    2 --
>  4 files changed, 1 insertion(+), 5 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 6365632..814cfc9 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2215,7 +2215,6 @@ void __kmem_cache_destroy(struct kmem_cache *cachep)
>  			kfree(l3);
>  		}
>  	}
> -	kmem_cache_free(kmem_cache, cachep);
>  }
>  
>  
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 850c497..3e3c403 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -154,6 +154,7 @@ void kmem_cache_destroy(struct kmem_cache *s)
>  				rcu_barrier();
>  
>  			__kmem_cache_destroy(s);
> +			kmem_cache_free(kmem_cache, s);
>  		} else {
>  			list_add(&s->list, &slab_caches);
>  			printk(KERN_ERR "kmem_cache_destroy %s: Slab cache still has objects\n",
> diff --git a/mm/slob.c b/mm/slob.c
> index 7d272c3..cb4ab96 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -540,8 +540,6 @@ struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
>  
>  void __kmem_cache_destroy(struct kmem_cache *c)
>  {
> -	kmemleak_free(c);
> -	slob_free(c, sizeof(struct kmem_cache));
>  }
>  
>  void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
> diff --git a/mm/slub.c b/mm/slub.c
> index 607fee5..8da785a 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -213,7 +213,6 @@ static inline int sysfs_slab_alias(struct kmem_cache *s, const char *p)
>  static inline void sysfs_slab_remove(struct kmem_cache *s)
>  {
>  	kfree(s->name);
> -	kmem_cache_free(kmem_cache, s);
>  }
>  
>  #endif
> @@ -5206,7 +5205,6 @@ static void kmem_cache_release(struct kobject *kobj)
>  	struct kmem_cache *s = to_slab(kobj);
>  
>  	kfree(s->name);
> -	kmem_cache_free(kmem_cache, s);
>  }
>  
>  static const struct sysfs_ops slab_sysfs_ops = {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
