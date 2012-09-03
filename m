Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 188BA6B0062
	for <linux-mm@kvack.org>; Mon,  3 Sep 2012 10:31:05 -0400 (EDT)
Message-ID: <5044BE6A.1030108@parallels.com>
Date: Mon, 3 Sep 2012 18:27:54 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: C13 [02/14] slub: Use kmem_cache for the kmem_cache structure
References: <20120824160903.168122683@linux.com> <00000139596cab14-093f99f6-e67c-43c2-ac90-2f617fb73f4b-000000@email.amazonses.com>
In-Reply-To: <00000139596cab14-093f99f6-e67c-43c2-ac90-2f617fb73f4b-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On 08/24/2012 08:17 PM, Christoph Lameter wrote:
> Do not use kmalloc() but kmem_cache_alloc() for the allocation
> of the kmem_cache structures in slub.
> 
> Acked-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Reviewed-by: Glauber Costa <glommer@parallels.com>

> ---
>  mm/slub.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 00f8557..e0b9403 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -213,7 +213,7 @@ static inline int sysfs_slab_alias(struct kmem_cache *s, const char *p)
>  static inline void sysfs_slab_remove(struct kmem_cache *s)
>  {
>  	kfree(s->name);
> -	kfree(s);
> +	kmem_cache_free(kmem_cache, s);
>  }
>  
>  #endif
> @@ -3969,7 +3969,7 @@ struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
>  	if (!n)
>  		return NULL;
>  
> -	s = kmalloc(kmem_size, GFP_KERNEL);
> +	s = kmem_cache_alloc(kmem_cache, GFP_KERNEL);
>  	if (s) {
>  		if (kmem_cache_open(s, n,
>  				size, align, flags, ctor)) {
> @@ -3986,7 +3986,7 @@ struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
>  			list_del(&s->list);
>  			kmem_cache_close(s);
>  		}
> -		kfree(s);
> +		kmem_cache_free(kmem_cache, s);
>  	}
>  	kfree(n);
>  	return NULL;
> @@ -5224,7 +5224,7 @@ static void kmem_cache_release(struct kobject *kobj)
>  	struct kmem_cache *s = to_slab(kobj);
>  
>  	kfree(s->name);
> -	kfree(s);
> +	kmem_cache_free(kmem_cache, s);
>  }
>  
>  static const struct sysfs_ops slab_sysfs_ops = {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
