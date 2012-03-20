Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 027B26B004A
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 10:14:47 -0400 (EDT)
Date: Tue, 20 Mar 2012 09:14:44 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 2/6] slub: add kmalloc_align()
In-Reply-To: <1332238884-6237-3-git-send-email-laijs@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1203200910030.19333@router.home>
References: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com> <1332238884-6237-3-git-send-email-laijs@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 20 Mar 2012, Lai Jiangshan wrote:

> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> index a32bcfd..67ac6b4 100644
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -280,6 +280,12 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
>  	return __kmalloc(size, flags);
>  }
>
> +static __always_inline
> +void *kmalloc_align(size_t size, gfp_t flags, size_t align)
> +{
> +	return kmalloc(ALIGN(size, align), flags);
> +}

This assumes that kmalloc allocates aligned memory. Which it does only
in special cases (power of two cache and debugging off).

>  #ifdef CONFIG_NUMA
>  void *__kmalloc_node(size_t size, gfp_t flags, int node);
>  void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
> diff --git a/mm/slub.c b/mm/slub.c
> index 4907563..01cf99d 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3238,7 +3238,7 @@ static struct kmem_cache *__init create_kmalloc_cache(const char *name,
>  	 * This function is called with IRQs disabled during early-boot on
>  	 * single CPU so there's no need to take slub_lock here.
>  	 */
> -	if (!kmem_cache_open(s, name, size, ARCH_KMALLOC_MINALIGN,
> +	if (!kmem_cache_open(s, name, size, ALIGN_OF_LAST_BIT(size),
>  								flags, NULL))
>  		goto panic;

Why does the alignment of struct kmem_cache change? I'd rather have a
__alignof__(struct kmem_cache) here with alignment specified with the
struct definition.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
