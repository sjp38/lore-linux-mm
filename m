Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 54C0B6B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 15:09:30 -0400 (EDT)
Received: by obhx4 with SMTP id x4so3916199obh.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 12:09:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1346885323-15689-5-git-send-email-elezegarcia@gmail.com>
References: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com>
	<1346885323-15689-5-git-send-email-elezegarcia@gmail.com>
Date: Fri, 7 Sep 2012 04:09:29 +0900
Message-ID: <CAAmzW4P7=8P3h8-nCUB+iK+RSnVrcJBKUbV5hN+TpR53Xt7eGw@mail.gmail.com>
Subject: Re: [PATCH 5/5] mm, slob: Trace allocation failures consistently
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

2012/9/6 Ezequiel Garcia <elezegarcia@gmail.com>:
> This patch cleans how we trace kmalloc and kmem_cache_alloc.
> In particular, it fixes out-of-memory tracing: now every failed
> allocation will trace reporting non-zero requested bytes, zero obtained bytes.

Other SLAB allocators(slab, slub) doesn't consider zero obtained bytes
in tracing.
These just return "addr = 0, obtained size = cache size"
Why does the slob print a different output?

> @@ -573,20 +576,23 @@ void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
>
>         if (c->size < PAGE_SIZE) {
>                 b = slob_alloc(c->size, flags, c->align, node);
> -               trace_kmem_cache_alloc_node(_RET_IP_, b, c->size,
> -                                           SLOB_UNITS(c->size) * SLOB_UNIT,
> -                                           flags, node);
> +               if (!b)
> +                       goto trace_out;
> +               alloc_size = SLOB_UNITS(c->size) * SLOB_UNIT;
>         } else {
>                 b = slob_new_pages(flags, get_order(c->size), node);
> -               trace_kmem_cache_alloc_node(_RET_IP_, b, c->size,
> -                                           PAGE_SIZE << get_order(c->size),
> -                                           flags, node);
> +               if (!b)
> +                       goto trace_out;
> +               alloc_size = PAGE_SIZE << get_order(c->size);
>         }
>         if (c->ctor)
>                 c->ctor(b);

Regardless of tracing, "if (!b)" test is needed for skip "c->ctor".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
