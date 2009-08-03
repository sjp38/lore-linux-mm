Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B39F46B005D
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 16:35:35 -0400 (EDT)
Date: Mon, 3 Aug 2009 13:57:54 -0700 (PDT)
From: Sage Weil <sage@newdream.net>
Subject: Re: [PATCH] mm: remove broken 'kzalloc' mempool
In-Reply-To: <1249332888-13440-3-git-send-email-sage@newdream.net>
Message-ID: <Pine.LNX.4.64.0908031356170.7580@cobra.newdream.net>
References: <1249332888-13440-1-git-send-email-sage@newdream.net>
 <1249332888-13440-2-git-send-email-sage@newdream.net>
 <1249332888-13440-3-git-send-email-sage@newdream.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Aug 2009, Sage Weil wrote:
> The kzalloc mempool zeros items when they are initially allocated, but
> does not rezero used items that are returned to the pool.  Consequently
> mempool_alloc()s may return non-zeroed memory.
> 
> Since there are/were only two in-tree users for mempool_create_kzalloc_pool(),
> and 'fixing' this in a way that will re-zero used (but not new) items
> before first use is non-trivial, just remove it.

This should of course only be applied after the fixes for the two callers 
(dm multipath and ibmvscsi), whatever the protocol for order that may 
be...

sage


> 
> CC: <linux-mm@kvack.org>
> Signed-off-by: Sage Weil <sage@newdream.net>
> ---
>  include/linux/mempool.h |   10 ++--------
>  mm/mempool.c            |    7 -------
>  2 files changed, 2 insertions(+), 15 deletions(-)
> 
> diff --git a/include/linux/mempool.h b/include/linux/mempool.h
> index 9be484d..7c08052 100644
> --- a/include/linux/mempool.h
> +++ b/include/linux/mempool.h
> @@ -47,22 +47,16 @@ mempool_create_slab_pool(int min_nr, struct kmem_cache *kc)
>  }
>  
>  /*
> - * 2 mempool_alloc_t's and a mempool_free_t to kmalloc/kzalloc and kfree
> - * the amount of memory specified by pool_data
> + * a mempool_alloc_t and a mempool_free_t to kmalloc and kfree the
> + * amount of memory specified by pool_data
>   */
>  void *mempool_kmalloc(gfp_t gfp_mask, void *pool_data);
> -void *mempool_kzalloc(gfp_t gfp_mask, void *pool_data);
>  void mempool_kfree(void *element, void *pool_data);
>  static inline mempool_t *mempool_create_kmalloc_pool(int min_nr, size_t size)
>  {
>  	return mempool_create(min_nr, mempool_kmalloc, mempool_kfree,
>  			      (void *) size);
>  }
> -static inline mempool_t *mempool_create_kzalloc_pool(int min_nr, size_t size)
> -{
> -	return mempool_create(min_nr, mempool_kzalloc, mempool_kfree,
> -			      (void *) size);
> -}
>  
>  /*
>   * A mempool_alloc_t and mempool_free_t for a simple page allocator that
> diff --git a/mm/mempool.c b/mm/mempool.c
> index a46eb1b..eea4f7d 100644
> --- a/mm/mempool.c
> +++ b/mm/mempool.c
> @@ -308,13 +308,6 @@ void *mempool_kmalloc(gfp_t gfp_mask, void *pool_data)
>  }
>  EXPORT_SYMBOL(mempool_kmalloc);
>  
> -void *mempool_kzalloc(gfp_t gfp_mask, void *pool_data)
> -{
> -	size_t size = (size_t) pool_data;
> -	return kzalloc(size, gfp_mask);
> -}
> -EXPORT_SYMBOL(mempool_kzalloc);
> -
>  void mempool_kfree(void *element, void *pool_data)
>  {
>  	kfree(element);
> -- 
> 1.5.6.5
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
