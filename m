Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 0B49D6B005D
	for <linux-mm@kvack.org>; Sat,  4 Aug 2012 13:44:28 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3614726pbb.14
        for <linux-mm@kvack.org>; Sat, 04 Aug 2012 10:44:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120803192154.205306565@linux.com>
References: <20120803192052.448575403@linux.com>
	<20120803192154.205306565@linux.com>
Date: Sun, 5 Aug 2012 02:44:27 +0900
Message-ID: <CAAmzW4P4aH5yvVjfboQN-+0-WG0=93LkwdmrS7yE9GQ5C=Uxdg@mail.gmail.com>
Subject: Re: Common10 [11/20] Do slab aliasing call from common code
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

2012/8/4 Christoph Lameter <cl@linux.com>:
> The slab aliasing logic causes some strange contortions in
> slub. So add a call to deal with aliases to slab_common.c
> but disable it for other slab allocators by providng stubs
> that fail to create aliases.
>
> Full general support for aliases will require additional
> cleanup passes and more standardization of fields in
> kmem_cache.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>
>
>
> ---
>  mm/slab.h        |   10 ++++++++++
>  mm/slab_common.c |   16 +++++++---------
>  mm/slub.c        |   18 ++++++++++++------
>  3 files changed, 29 insertions(+), 15 deletions(-)
>
> Index: linux-2.6/mm/slab.h
> ===================================================================
> --- linux-2.6.orig/mm/slab.h    2012-08-02 14:21:24.841995858 -0500
> +++ linux-2.6/mm/slab.h 2012-08-02 14:23:08.071846583 -0500
> @@ -36,6 +36,16 @@
>  struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
>         size_t align, unsigned long flags, void (*ctor)(void *));
>
> +#ifdef CONFIG_SLUB
> +struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
> +       size_t align, unsigned long flags, void (*ctor)(void *));
> +#else
> +static inline struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
> +       size_t align, unsigned long flags, void (*ctor)(void *))
> +{ return NULL; }
> +#endif
> +
> +
>  int __kmem_cache_shutdown(struct kmem_cache *);
>
>  #endif
> Index: linux-2.6/mm/slab_common.c
> ===================================================================
> --- linux-2.6.orig/mm/slab_common.c     2012-08-02 14:22:59.087685489 -0500
> +++ linux-2.6/mm/slab_common.c  2012-08-02 14:23:08.071846583 -0500
> @@ -94,6 +94,10 @@
>         WARN_ON(strchr(name, ' '));     /* It confuses parsers */
>  #endif
>
> +       s = __kmem_cache_alias(name, size, align, flags, ctor);
> +       if (s)
> +               goto out_locked;
> +
>         n = kstrdup(name, GFP_KERNEL);
>         if (!n) {
>                 err = -ENOMEM;z
> @@ -115,9 +119,7 @@
>                 err = -ENOSYS; /* Until __kmem_cache_create returns code */
>         }
>
> -#ifdef CONFIG_DEBUG_VM
>  out_locked:
> -#endif
>         mutex_unlock(&slab_mutex);
>         put_online_cpus();
>
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c    2012-08-02 14:21:30.678100549 -0500
> +++ linux-2.6/mm/slub.c 2012-08-02 14:23:08.075846653 -0500
> @@ -3701,7 +3701,7 @@
>                 slub_max_order = 0;
>
>         kmem_size = offsetof(struct kmem_cache, node) +
> -                               nr_node_ids * sizeof(struct kmem_cache_node *);
> +                       nr_node_ids * sizeof(struct kmem_cache_node *);
>
>         /* Allocate two kmem_caches from the page allocator */
>         kmalloc_size = ALIGN(kmem_size, cache_line_size());
> @@ -3915,7 +3915,7 @@
>         return NULL;
>  }
>
> -struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
> +struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
>                 size_t align, unsigned long flags, void (*ctor)(void *))
>  {
>         struct kmem_cache *s;
> @@ -3932,11 +3932,18 @@
>
>                 if (sysfs_slab_alias(s, name)) {
>                         s->refcount--;
> -                       return NULL;
> +                       s = NULL;
>                 }
> -               return s;
>         }
>
> +       return s;
> +}
> +
> +struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
> +               size_t align, unsigned long flags, void (*ctor)(void *))
> +{
> +       struct kmem_cache *s;
> +
>         s = kmem_cache_alloc(kmem_cache, GFP_KERNEL);
>         if (s) {
>                 if (kmem_cache_open(s, name,
>

sysfs_slab_alias() in __kmem_cache_alias() stores reference of name param.
Currently, when we call __kmem_cache_alias(), we don't do kstrdup().
It is not desired behavior as we don't want to be depend on caller of
kmem_cache_create().
So we need to do kstrdup() before invoking __kmem_cache_alias().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
