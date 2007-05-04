Received: by ug-out-1314.google.com with SMTP id s2so535001uge
        for <linux-mm@kvack.org>; Fri, 04 May 2007 03:54:32 -0700 (PDT)
Message-ID: <84144f020705040354r5cb74c5fj6cb8698f93ffcb83@mail.gmail.com>
Date: Fri, 4 May 2007 13:54:32 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 08/40] mm: kmem_cache_objsize
In-Reply-To: <20070504103157.215424767@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070504102651.923946304@chello.nl>
	 <20070504103157.215424767@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@steeleye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On 5/4/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> Expost buffer_size in order to allow fair estimates on the actual space
> used/needed.

[snip]

>  #ifdef CONFIG_SLAB_FAIR
> -static inline int slab_alloc_rank(gfp_t flags)
> +static __always_inline int slab_alloc_rank(gfp_t flags)
>  {
>         return gfp_to_rank(flags);
>  }
>  #else
> -static inline int slab_alloc_rank(gfp_t flags)
> +static __always_inline int slab_alloc_rank(gfp_t flags)
>  {
>         return 0;
>  }

Me thinks this hunk doesn't belong in this patch.

> @@ -3815,6 +3815,12 @@ unsigned int kmem_cache_size(struct kmem
>  }
>  EXPORT_SYMBOL(kmem_cache_size);
>
> +unsigned int kmem_cache_objsize(struct kmem_cache *cachep)
> +{
> +       return cachep->buffer_size;
> +}
> +EXPORT_SYMBOL_GPL(kmem_cache_objsize);
> +
>  const char *kmem_cache_name(struct kmem_cache *cachep)
>  {
>         return cachep->name;
> @@ -4512,3 +4518,9 @@ unsigned int ksize(const void *objp)
>
>         return obj_size(virt_to_cache(objp));
>  }
> +
> +unsigned int kobjsize(size_t size)
> +{
> +       return kmem_cache_objsize(kmem_find_general_cachep(size, 0));
> +}
> +EXPORT_SYMBOL_GPL(kobjsize);

Looks good to me. Unfortunately, you need to do SLUB as well. Aah, the
wonders of three kernel memory allocators... ;-)

                                     Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
