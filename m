Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 5045F6B005D
	for <linux-mm@kvack.org>; Sat,  4 Aug 2012 13:46:41 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3617114pbb.14
        for <linux-mm@kvack.org>; Sat, 04 Aug 2012 10:46:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120803192154.777250838@linux.com>
References: <20120803192052.448575403@linux.com>
	<20120803192154.777250838@linux.com>
Date: Sun, 5 Aug 2012 02:46:40 +0900
Message-ID: <CAAmzW4MHW39RZ7TjAdbHZ0EWaAiqmo5NuAhRqQFpNtO5gWAGvQ@mail.gmail.com>
Subject: Re: Common10 [12/20] Move sysfs_slab_add to common
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

2012/8/4 Christoph Lameter <cl@linux.com>:
> Simplify locking by moving the slab_add_sysfs after all locks
> have been dropped. Eases the upcoming move to provide sysfs
> support for all allocators.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>
>
> Index: linux-2.6/mm/slab.h
> ===================================================================
> --- linux-2.6.orig/mm/slab.h    2012-08-03 09:04:19.558047765 -0500
> +++ linux-2.6/mm/slab.h 2012-08-03 09:04:21.258077096 -0500
> @@ -39,10 +39,13 @@ struct kmem_cache *__kmem_cache_create(c
>  #ifdef CONFIG_SLUB
>  struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
>         size_t align, unsigned long flags, void (*ctor)(void *));
> +extern int sysfs_slab_add(struct kmem_cache *s);
>  #else
>  static inline struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
>         size_t align, unsigned long flags, void (*ctor)(void *))
>  { return NULL; }
> +static inline int sysfs_slab_add(struct kmem_cache *s) { return 0; }
> +
>  #endif
>
>
> Index: linux-2.6/mm/slab_common.c
> ===================================================================
> --- linux-2.6.orig/mm/slab_common.c     2012-08-03 09:04:19.558047765 -0500
> +++ linux-2.6/mm/slab_common.c  2012-08-03 09:04:21.258077096 -0500
> @@ -140,6 +140,9 @@ out:
>                 return NULL;
>         }
>
> +       if (s->refcount == 1)
> +               sysfs_slab_add(s);
> +
>         return s;
>  }
>  EXPORT_SYMBOL(kmem_cache_create);

Why not handle error case of sysfs_slab_add()?
Before patch, it is handled.
Is there any reason for that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
