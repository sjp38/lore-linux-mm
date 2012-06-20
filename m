Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 2D3F06B0062
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 03:14:39 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so274983lbj.14
        for <linux-mm@kvack.org>; Wed, 20 Jun 2012 00:14:36 -0700 (PDT)
Date: Wed, 20 Jun 2012 10:14:28 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 1,2/4 v4] slub: use __cmpxchg_double_slab() at interrupt
 disabled place
In-Reply-To: <1337346077-2754-1-git-send-email-js1304@gmail.com>
Message-ID: <alpine.LFD.2.02.1206201013500.1933@tux.localdomain>
References: <alpine.LFD.2.02.1205181231170.3899@tux.localdomain> <1337346077-2754-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Fri, 18 May 2012, Joonsoo Kim wrote:

> get_freelist(), unfreeze_partials() are only called with interrupt disabled,
> so __cmpxchg_double_slab() is suitable.
> 
> Acked-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>

Applied, thanks!

> ---
> According to comment from Pekka, add some comment.
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 0c3105c..d7f8291 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1879,7 +1879,11 @@ redo:
>  	}
>  }
>  
> -/* Unfreeze all the cpu partial slabs */
> +/*
> + * Unfreeze all the cpu partial slabs.
> + *
> + * This function must be called with interrupt disabled.
> + */
>  static void unfreeze_partials(struct kmem_cache *s)
>  {
>  	struct kmem_cache_node *n = NULL;
> @@ -1935,7 +1939,7 @@ static void unfreeze_partials(struct kmem_cache *s)
>  				l = m;
>  			}
>  
> -		} while (!cmpxchg_double_slab(s, page,
> +		} while (!__cmpxchg_double_slab(s, page,
>  				old.freelist, old.counters,
>  				new.freelist, new.counters,
>  				"unfreezing slab"));
> @@ -2163,6 +2167,8 @@ static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
>   * The page is still frozen if the return value is not NULL.
>   *
>   * If this function returns NULL then the page has been unfrozen.
> + *
> + * This function must be called with interrupt disabled.
>   */
>  static inline void *get_freelist(struct kmem_cache *s, struct page *page)
>  {
> @@ -2179,7 +2185,7 @@ static inline void *get_freelist(struct kmem_cache *s, struct page *page)
>  		new.inuse = page->objects;
>  		new.frozen = freelist != NULL;
>  
> -	} while (!cmpxchg_double_slab(s, page,
> +	} while (!__cmpxchg_double_slab(s, page,
>  		freelist, counters,
>  		NULL, new.counters,
>  		"get_freelist"));
> -- 
> 1.7.9.5
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
