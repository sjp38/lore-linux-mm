Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 7E4F06B00B4
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 23:16:58 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so9494144pbb.14
        for <linux-mm@kvack.org>; Mon, 01 Oct 2012 20:16:57 -0700 (PDT)
Date: Mon, 1 Oct 2012 20:16:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] slab: Ignore internal flags in cache creation
In-Reply-To: <1349088458-3940-1-git-send-email-glommer@parallels.com>
Message-ID: <alpine.DEB.2.00.1210012015190.30896@chino.kir.corp.google.com>
References: <1349088458-3940-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Mon, 1 Oct 2012, Glauber Costa wrote:

> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 9c21725..f2682ee 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -107,6 +107,15 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align
>  	if (!kmem_cache_sanity_check(name, size) == 0)
>  		goto out_locked;
>  
> +	/*
> +	 * Some allocators will constraint the set of valid flags to a subset
> +	 * of all flags. We expect them to define CACHE_CREATE_MASK in this
> +	 * case, and we'll just provide them with a sanitized version of the
> +	 * passed flags.
> +	 */
> +#ifdef CACHE_CREATE_MASK
> +	flags &= ~CACHE_CREATE_MASK;
> +#endif
>  
>  	s = __kmem_cache_alias(name, size, align, flags, ctor);
>  	if (s)

flags &= CACHE_CREATE_MASK

After that's done:

	Acked-by: David Rientjes <rientjes@google.com>

Thanks for working through this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
