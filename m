Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id B8F686B005D
	for <linux-mm@kvack.org>; Sat,  4 Aug 2012 13:48:32 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3618992pbb.14
        for <linux-mm@kvack.org>; Sat, 04 Aug 2012 10:48:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120803192155.337884418@linux.com>
References: <20120803192052.448575403@linux.com>
	<20120803192155.337884418@linux.com>
Date: Sun, 5 Aug 2012 02:48:31 +0900
Message-ID: <CAAmzW4OjSm+o+dwB-EBGprQyr9TP7j3jK3=FHEFVuf97eWcrzg@mail.gmail.com>
Subject: Re: Common10 [13/20] Move kmem_cache allocations into common code.
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

2012/8/4 Christoph Lameter <cl@linux.com>:
> Shift the allocations to common code. That way the allocation
> and freeing of the kmem_cache structures is handled by common code.
>
> V1-V2: Use the return code from setup_cpucache() in slab instead of returning -ENOSPC
>
> Signed-off-by: Christoph Lameter <cl@linux.com>
>
> Index: linux-2.6/mm/slab.c
> ===================================================================
> --- linux-2.6.orig/mm/slab.c    2012-08-03 13:17:27.961262193 -0500
> +++ linux-2.6/mm/slab.c 2012-08-03 13:26:53.527477374 -0500
> @@ -1673,7 +1673,8 @@ void __init kmem_cache_init(void)
>          * bug.
>          */
>
> -       sizes[INDEX_AC].cs_cachep = __kmem_cache_create(names[INDEX_AC].name,
> +       sizes[INDEX_AC].cs_cachep = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
> +       __kmem_cache_create(sizes[INDEX_AC].cs_cachep, names[INDEX_AC].name,
>                                         sizes[INDEX_AC].cs_size,
>                                         ARCH_KMALLOC_MINALIGN,
>                                         ARCH_KMALLOC_FLAGS|SLAB_PANIC,
> @@ -1681,8 +1682,8 @@ void __init kmem_cache_init(void)
>
>         list_add(&sizes[INDEX_AC].cs_cachep->list, &slab_caches);
>         if (INDEX_AC != INDEX_L3) {
> -               sizes[INDEX_L3].cs_cachep =
> -                       __kmem_cache_create(names[INDEX_L3].name,
> +               sizes[INDEX_L3].cs_cachep = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
> +               __kmem_cache_create(sizes[INDEX_L3].cs_cachep, names[INDEX_L3].name,
>                                 sizes[INDEX_L3].cs_size,
>                                 ARCH_KMALLOC_MINALIGN,
>                                 ARCH_KMALLOC_FLAGS|SLAB_PANIC,
> @@ -1701,7 +1702,8 @@ void __init kmem_cache_init(void)
>                  * allow tighter packing of the smaller caches.
>                  */
>                 if (!sizes->cs_cachep) {
> -                       sizes->cs_cachep = __kmem_cache_create(names->name,
> +                       sizes->cs_cachep = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
> +                       __kmem_cache_create(sizes->cs_cachep, names->name,
>                                         sizes->cs_size,
>                                         ARCH_KMALLOC_MINALIGN,
>                                         ARCH_KMALLOC_FLAGS|SLAB_PANIC,
> @@ -1709,7 +1711,8 @@ void __init kmem_cache_init(void)
>                         list_add(&sizes->cs_cachep->list, &slab_caches);
>                 }
>  #ifdef CONFIG_ZONE_DMA
> -               sizes->cs_dmacachep = __kmem_cache_create(
> +               sizes->cs_dmacachep = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
> +               __kmem_cache_create(sizes->cs_dmacachep,
>                                         names->name_dma,
>                                         sizes->cs_size,
>                                         ARCH_KMALLOC_MINALIGN,
> @@ -2356,13 +2359,13 @@ static int __init_refok setup_cpu_cache(
>   * cacheline.  This can be beneficial if you're counting cycles as closely
>   * as davem.
>   */
> -struct kmem_cache *
> -__kmem_cache_create (const char *name, size_t size, size_t align,
> +int
> +__kmem_cache_create (struct kmem_cache *cachep, const char *name, size_t size, size_t align,
>         unsigned long flags, void (*ctor)(void *))
>  {
>         size_t left_over, slab_size, ralign;
> -       struct kmem_cache *cachep = NULL;
>         gfp_t gfp;
> +       int err;
>
>  #if DEBUG
>  #if FORCED_DEBUG
> @@ -2450,11 +2453,6 @@ __kmem_cache_create (const char *name, s
>         else
>                 gfp = GFP_NOWAIT;
>
> -       /* Get cache's description obj. */
> -       cachep = kmem_cache_zalloc(kmem_cache, gfp);
> -       if (!cachep)
> -               return NULL;
> -
>         cachep->nodelists = (struct kmem_list3 **)&cachep->array[nr_cpu_ids];
>         cachep->object_size = size;
>         cachep->align = align;
> @@ -2509,8 +2507,7 @@ __kmem_cache_create (const char *name, s
>         if (!cachep->num) {
>                 printk(KERN_ERR
>                        "kmem_cache_create: couldn't create cache %s.\n", name);
> -               kmem_cache_free(kmem_cache, cachep);
> -               return NULL;
> +               return -E2BIG;
>         }
>         slab_size = ALIGN(cachep->num * sizeof(kmem_bufctl_t)
>                           + sizeof(struct slab), align);
> @@ -2567,9 +2564,10 @@ __kmem_cache_create (const char *name, s
>         cachep->name = name;
>         cachep->refcount = 1;
>
> -       if (setup_cpu_cache(cachep, gfp)) {
> +       err = setup_cpu_cache(cachep, gfp);
> +       if (err) {
>                 __kmem_cache_shutdown(cachep);
> -               return NULL;
> +               return err;
>         }
>
>         if (flags & SLAB_DEBUG_OBJECTS) {
> @@ -2582,7 +2580,7 @@ __kmem_cache_create (const char *name, s
>                 slab_set_debugobj_lock_classes(cachep);
>         }
>
> -       return cachep;
> +       return 0;
>  }
>
>  #if DEBUG
> Index: linux-2.6/mm/slab.h
> ===================================================================
> --- linux-2.6.orig/mm/slab.h    2012-08-03 13:17:26.000000000 -0500
> +++ linux-2.6/mm/slab.h 2012-08-03 13:19:01.102946835 -0500
> @@ -33,8 +33,8 @@ extern struct list_head slab_caches;
>  extern struct kmem_cache *kmem_cache;
>
>  /* Functions provided by the slab allocators */
> -struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
> -       size_t align, unsigned long flags, void (*ctor)(void *));
> +extern int __kmem_cache_create(struct kmem_cache *, const char *name,
> +       size_t size, size_t align, unsigned long flags, void (*ctor)(void *));
>
>  #ifdef CONFIG_SLUB
>  struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
> Index: linux-2.6/mm/slab_common.c
> ===================================================================
> --- linux-2.6.orig/mm/slab_common.c     2012-08-03 13:17:27.000000000 -0500
> +++ linux-2.6/mm/slab_common.c  2012-08-03 13:20:48.080876182 -0500
> @@ -104,19 +104,21 @@ struct kmem_cache *kmem_cache_create(con
>                 goto out_locked;
>         }
>
> -       s = __kmem_cache_create(n, size, align, flags, ctor);
> -
> +       s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
>         if (s) {

Is it necessary that kmem_cache_zalloc() is invoked with GFP_NOWAIT?
As I understand, before patch, it is called with GFP_KERNEL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
