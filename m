Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id B9C1C6B0037
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 11:29:22 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id eu11so21212109pac.18
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 08:29:22 -0700 (PDT)
Received: from qmta08.emeryville.ca.mail.comcast.net (qmta08.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:80])
        by mx.google.com with ESMTP id t2si233907pbz.19.2014.08.25.08.29.21
        for <linux-mm@kvack.org>;
        Mon, 25 Aug 2014 08:29:21 -0700 (PDT)
Date: Mon, 25 Aug 2014 10:29:19 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] mm/slab: support slab merge
In-Reply-To: <1408608675-20420-3-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.11.1408251028420.27302@gentwo.org>
References: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com> <1408608675-20420-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 21 Aug 2014, Joonsoo Kim wrote:

> diff --git a/mm/slab.c b/mm/slab.c
> index 09b060e..a1cc1c9 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2052,6 +2052,26 @@ static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
>  	return 0;
>  }
>
> +unsigned long kmem_cache_flags(unsigned long object_size,
> +	unsigned long flags, const char *name,
> +	void (*ctor)(void *))
> +{
> +	return flags;
> +}
> +
> +struct kmem_cache *
> +__kmem_cache_alias(const char *name, size_t size, size_t align,
> +		   unsigned long flags, void (*ctor)(void *))
> +{
> +	struct kmem_cache *cachep;
> +
> +	cachep = find_mergeable(size, align, flags, name, ctor);
> +	if (cachep)
> +		cachep->refcount++;
> +
> +	return cachep;
> +}
> +

These could be commonized as well. Make refcount a common field and then
the same function can be used for both caches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
