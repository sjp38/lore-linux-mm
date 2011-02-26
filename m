Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E20AE8D0039
	for <linux-mm@kvack.org>; Sat, 26 Feb 2011 17:41:35 -0500 (EST)
Message-ID: <4D698135.1050302@oracle.com>
Date: Sat, 26 Feb 2011 14:39:49 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: fix ksize() build error
References: <20110225105205.5a1309bb.randy.dunlap@oracle.com> <1298747426-8236-1-git-send-email-mk@lab.zgora.pl>
In-Reply-To: <1298747426-8236-1-git-send-email-mk@lab.zgora.pl>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mariusz Kozlowski <mk@lab.zgora.pl>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Eric Dumazet <eric.dumazet@gmail.com>, linux-next@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/26/11 11:10, Mariusz Kozlowski wrote:
> mm/slub.c: In function 'ksize':
> mm/slub.c:2728: error: implicit declaration of function 'slab_ksize'
> 
> slab_ksize() needs to go out of CONFIG_SLUB_DEBUG section.
> 
> Signed-off-by: Mariusz Kozlowski <mk@lab.zgora.pl>

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Thanks.

> ---
> Maybe something like this? Compile tested for slub debug enabled/disabled.
> 
>  mm/slub.c |   48 ++++++++++++++++++++++++------------------------
>  1 files changed, 24 insertions(+), 24 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 217b5b5..ea6f039 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -281,6 +281,30 @@ static inline int slab_index(void *p, struct kmem_cache *s, void *addr)
>  	return (p - addr) / s->size;
>  }
>  
> +static inline size_t slab_ksize(const struct kmem_cache *s)
> +{
> +#ifdef CONFIG_SLUB_DEBUG
> +	/*
> +	 * Debugging requires use of the padding between object
> +	 * and whatever may come after it.
> +	 */
> +	if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
> +		return s->objsize;
> +
> +#endif
> +	/*
> +	 * If we have the need to store the freelist pointer
> +	 * back there or track user information then we can
> +	 * only use the space before that information.
> +	 */
> +	if (s->flags & (SLAB_DESTROY_BY_RCU | SLAB_STORE_USER))
> +		return s->inuse;
> +	/*
> +	 * Else we can use all the padding etc for the allocation
> +	 */
> +	return s->size;
> +}
> +
>  static inline struct kmem_cache_order_objects oo_make(int order,
>  						unsigned long size)
>  {
> @@ -797,30 +821,6 @@ static inline int slab_pre_alloc_hook(struct kmem_cache *s, gfp_t flags)
>  	return should_failslab(s->objsize, flags, s->flags);
>  }
>  
> -static inline size_t slab_ksize(const struct kmem_cache *s)
> -{
> -#ifdef CONFIG_SLUB_DEBUG
> -	/*
> -	 * Debugging requires use of the padding between object
> -	 * and whatever may come after it.
> -	 */
> -	if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
> -		return s->objsize;
> -
> -#endif
> -	/*
> -	 * If we have the need to store the freelist pointer
> -	 * back there or track user information then we can
> -	 * only use the space before that information.
> -	 */
> -	if (s->flags & (SLAB_DESTROY_BY_RCU | SLAB_STORE_USER))
> -		return s->inuse;
> -	/*
> -	 * Else we can use all the padding etc for the allocation
> -	 */
> -	return s->size;
> -}
> -
>  static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags, void *object)
>  {
>  	flags &= gfp_allowed_mask;


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
