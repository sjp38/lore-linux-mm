Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 33C62440874
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 10:54:56 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id k192so19668904ith.0
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 07:54:56 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id x70si2645726ita.34.2017.07.12.07.54.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 07:54:55 -0700 (PDT)
Date: Wed, 12 Jul 2017 09:54:54 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] slub: Introduce 'alternate' per cpu partial lists
In-Reply-To: <1496965984-21962-1-git-send-email-labbott@redhat.com>
Message-ID: <alpine.DEB.2.20.1707120949260.15771@nuc-kabylake>
References: <1496965984-21962-1-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>

On Thu, 8 Jun 2017, Laura Abbott wrote:

> - Some of this code is redundant and can probably be combined.
> - The fast path is very sensitive and it was suggested I leave it alone. The
> approach I took means the fastpath cmpxchg always fails before trying the
> alternate cmpxchg. From some of my profiling, the cmpxchg seemed to be fairly
> expensive.

I think its better to change the fast path. Just make sure that the hot
path is as unencumbered as possible. There are already slow pieces in the
hotpath. If you modifications are similar then it would work.

> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> index 07ef550..d582101 100644
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -42,6 +44,12 @@ struct kmem_cache_cpu {
>  	unsigned long tid;	/* Globally unique transaction id */
>  	struct page *page;	/* The slab from which we are allocating */
>  	struct page *partial;	/* Partially allocated frozen slabs */
> +	/*
> +	 * The following fields have identical uses to those above */
> +	void **alt_freelist;
> +	unsigned long alt_tid;
> +	struct page *alt_partial;
> +	struct page *alt_page;
>  #ifdef CONFIG_SLUB_STATS
>  	unsigned stat[NR_SLUB_STAT_ITEMS];
>  #endif

I would rather avoid duplication here. Use the regular entries and modify
the flow depending on a flag.

> diff --git a/mm/slub.c b/mm/slub.c
> index 7449593..b1fc4c6 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -132,10 +132,24 @@ void *fixup_red_left(struct kmem_cache *s, void *p)
>  	return p;
>  }
>
> +#define SLAB_NO_PARTIAL (SLAB_CONSISTENCY_CHECKS | SLAB_STORE_USER | \
> +                               SLAB_TRACE)
> +
> +
> +static inline bool kmem_cache_use_alt_partial(struct kmem_cache *s)
> +{
> +#ifdef CONFIG_SLUB_CPU_PARTIAL
> +	return s->flags & (SLAB_RED_ZONE | SLAB_POISON) &&
> +		!(s->flags & SLAB_NO_PARTIAL);
> +#else
> +	return false;
> +#endif
> +}
> +
>  static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
>  {
>  #ifdef CONFIG_SLUB_CPU_PARTIAL
> -	return !kmem_cache_debug(s);
> +	return !(s->flags & SLAB_NO_PARTIAL);
>  #else
>  	return false;
>  #endif
> @@ -1786,6 +1800,7 @@ static inline void *acquire_slab(struct kmem_cache *s,
>  }

Hmmm... Looks like the inversion would be better

SLAB_PARTIAL?


...

Lots of duplication. I think that can be avoided by rearranging the fast
path depending on a flag.

Maybe make the fast poisoning the default? If you can keep the performance
of the fast path for regular use then this may be best. You can then avoid
adding the additional flag as well as the additional debug counters.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
