Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id CFC956B0044
	for <linux-mm@kvack.org>; Sat,  4 Aug 2012 13:34:22 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3603574pbb.14
        for <linux-mm@kvack.org>; Sat, 04 Aug 2012 10:34:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120803192153.623879087@linux.com>
References: <20120803192052.448575403@linux.com>
	<20120803192153.623879087@linux.com>
Date: Sun, 5 Aug 2012 02:34:21 +0900
Message-ID: <CAAmzW4MoHp9YXg1Y48edh2TEdR8wUYYdxE7nq5WkgCRb9fRUXw@mail.gmail.com>
Subject: Re: Common10 [10/20] Move duping of slab name to slab_common.c
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

2012/8/4 Christoph Lameter <cl@linux.com>:
> Duping of the slabname has to be done by each slab. Moving this code
> to slab_common avoids duplicate implementations.
>
> With this patch we have common string handling for all slab allocators.
> Strings passed to kmem_cache_create() are copied internally. Subsystems
> can create temporary strings to create slab caches.
>
> Slabs allocated in early states of bootstrap will never be freed (and those
> can never be freed since they are essential to slab allocator operations).
> During bootstrap we therefore do not have to worry about duping names.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

We can remove some comment for name param of  __kmem_cache_create() in slab.c.



> Index: linux-2.6/mm/slab_common.c
> ===================================================================
> --- linux-2.6.orig/mm/slab_common.c     2012-08-03 09:02:50.000000000 -0500
> +++ linux-2.6/mm/slab_common.c  2012-08-03 09:02:54.900587462 -0500
> @@ -54,6 +54,7 @@ struct kmem_cache *kmem_cache_create(con
>  {
>         struct kmem_cache *s;
>         int err = 0;
> +       char *n;
>
>  #ifdef CONFIG_DEBUG_VM
>         if (!name || in_interrupt() || size < sizeof(void *) ||
> @@ -93,16 +94,26 @@ struct kmem_cache *kmem_cache_create(con
>         WARN_ON(strchr(name, ' '));     /* It confuses parsers */
>  #endif
>
> -       s = __kmem_cache_create(name, size, align, flags, ctor);
> -       if (!s)
> -               err = -ENOSYS; /* Until __kmem_cache_create returns code */
> +       n = kstrdup(name, GFP_KERNEL);
> +       if (!n) {
> +               err = -ENOMEM;
> +               goto out_locked;
> +       }
> +
> +       s = __kmem_cache_create(n, size, align, flags, ctor);

We need to remove CONFIG_DEBUG_VM for out_locked now,
although later patch handles it.

> -       /*
> -        * Check if the slab has actually been created and if it was a
> -        * real instatiation. Aliases do not belong on the list
> -        */
> -       if (s && s->refcount == 1)
> -               list_add(&s->list, &slab_caches);
> +       if (s) {
> +               /*
> +                * Check if the slab has actually been created and if it was a
> +                * real instatiation. Aliases do not belong on the list
> +                */
> +               if (s->refcount == 1)
> +                       list_add(&s->list, &slab_caches);
> +
> +       } else {
> +               kfree(n);
> +               err = -ENOSYS; /* Until __kmem_cache_create returns code */
> +       }

In mergeable case, leak for name is possible.
__kmem_cache_create() doesn't set name to s->name in mergeable case.
So, this memory can't be freed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
