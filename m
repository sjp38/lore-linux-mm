Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 951FD6B0062
	for <linux-mm@kvack.org>; Sat, 20 Oct 2012 12:12:36 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so1611929oag.14
        for <linux-mm@kvack.org>; Sat, 20 Oct 2012 09:12:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013a797cda39-907d3721-264e-4d75-8d4d-4122eb0a981c-000000@email.amazonses.com>
References: <20121019142254.724806786@linux.com>
	<0000013a797cda39-907d3721-264e-4d75-8d4d-4122eb0a981c-000000@email.amazonses.com>
Date: Sun, 21 Oct 2012 01:12:35 +0900
Message-ID: <CAAmzW4Pmb5uFGC=qaC0WfM_pZ1s+x4Knz0QJogZZ8vesnkF6qw@mail.gmail.com>
Subject: Re: CK2 [08/15] slab: Use common kmalloc_index/kmalloc_size functions
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

2012/10/19 Christoph Lameter <cl@linux.com>:

> @@ -693,20 +657,19 @@ static inline struct array_cache *cpu_ca
>  static inline struct kmem_cache *__find_general_cachep(size_t size,
>                                                         gfp_t gfpflags)
>  {
> -       struct cache_sizes *csizep = malloc_sizes;
> +       int i;
>
>  #if DEBUG
>         /* This happens if someone tries to call
>          * kmem_cache_create(), or __kmalloc(), before
>          * the generic caches are initialized.
>          */
> -       BUG_ON(malloc_sizes[INDEX_AC].cs_cachep == NULL);
> +       BUG_ON(kmalloc_caches[INDEX_AC] == NULL);
>  #endif
>         if (!size)
>                 return ZERO_SIZE_PTR;
>
> -       while (size > csizep->cs_size)
> -               csizep++;
> +       i = kmalloc_index(size);

Above kmalloc_index(size) is called with arbitrary size, therefore it
cannot be folded.
This make size of code larger than before,
although '[15/15] Common Kmalloc cache determination' fix this issue properly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
