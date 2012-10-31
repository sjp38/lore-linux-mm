Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 78F236B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 04:03:34 -0400 (EDT)
Received: by mail-ea0-f169.google.com with SMTP id k11so556334eaa.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 01:03:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1351507779-26847-1-git-send-email-glommer@parallels.com>
References: <1351507779-26847-1-git-send-email-glommer@parallels.com>
Date: Wed, 31 Oct 2012 10:03:32 +0200
Message-ID: <CAOJsxLEG+gZk=TLyfhJqMb8xjxV4wnyF9wnZWPPOo8Hpc7N45A@mail.gmail.com>
Subject: Re: [PATCH] slab: annotate on-slab caches nodelist locks
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, JoonSoo Kim <js1304@gmail.com>, Michael Wang <wangyun@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>

(Adding Peter and Michael to CC.)

On Mon, Oct 29, 2012 at 12:49 PM, Glauber Costa <glommer@parallels.com> wrote:
> We currently provide lockdep annotation for kmalloc caches, and also
> caches that have SLAB_DEBUG_OBJECTS enabled. The reason for this is that
> we can quite frequently nest in the l3->list_lock lock, which is not
> something trivial to avoid.
>
> My proposal with this patch, is to extend this to caches whose slab
> management object lives within the slab as well ("on_slab"). The need
> for this arose in the context of testing kmemcg-slab patches. With such
> patchset, we can have per-memcg kmalloc caches. So the same path that
> led to nesting between kmalloc caches will could then lead to in-memcg
> nesting. Because they are not annotated, lockdep will trigger.
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Christoph Lameter <cl@linux.com>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>
> CC: David Rientjes <rientjes@google.com>
> CC: JoonSoo Kim <js1304@gmail.com>
>
> ---
> Instead of "on_slab", I considered checking the memcg cache's root
> cache, and annotating that only in case this is a kmalloc cache.
> I ended up annotating on_slab caches, because given how frequently
> those locks can nest, it seemed like a safe choice to go. I was
> a little bit inspired by the key's name as well, that indicated
> this could work for all on_slab caches. Let me know if you guys
> want a different test condition for this.
> ---
>  mm/slab.c | 30 +++++++++++++++++++++++++++++-
>  1 file changed, 29 insertions(+), 1 deletion(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index 9b7f6b63..ef1c8b3 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -654,6 +654,26 @@ static void init_node_lock_keys(int q)
>         }
>  }
>
> +static void on_slab_lock_classes_node(struct kmem_cache *cachep, int q)
> +{
> +       struct kmem_list3 *l3;
> +       l3 = cachep->nodelists[q];
> +       if (!l3)
> +               return;
> +
> +       slab_set_lock_classes(cachep, &on_slab_l3_key,
> +                       &on_slab_alc_key, q);
> +}
> +
> +static inline void on_slab_lock_classes(struct kmem_cache *cachep)
> +{
> +       int node;
> +
> +       VM_BUG_ON(OFF_SLAB(cachep));
> +       for_each_node(node)
> +               on_slab_lock_classes_node(cachep, node);
> +}
> +
>  static inline void init_lock_keys(void)
>  {
>         int node;
> @@ -670,6 +690,10 @@ static inline void init_lock_keys(void)
>  {
>  }
>
> +static inline void on_slab_lock_classes(struct kmem_cache *cachep)
> +{
> +}
> +
>  static void slab_set_debugobj_lock_classes_node(struct kmem_cache *cachep, int node)
>  {
>  }
> @@ -1397,6 +1421,9 @@ static int __cpuinit cpuup_prepare(long cpu)
>                 free_alien_cache(alien);
>                 if (cachep->flags & SLAB_DEBUG_OBJECTS)
>                         slab_set_debugobj_lock_classes_node(cachep, node);
> +               else if (!OFF_SLAB(cachep) &&
> +                        !(cachep->flags & SLAB_DESTROY_BY_RCU))
> +                       on_slab_lock_classes_node(cachep, node);
>         }
>         init_node_lock_keys(node);
>
> @@ -2554,7 +2581,8 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
>                 WARN_ON_ONCE(flags & SLAB_DESTROY_BY_RCU);
>
>                 slab_set_debugobj_lock_classes(cachep);
> -       }
> +       } else if (!OFF_SLAB(cachep) && !(flags & SLAB_DESTROY_BY_RCU))
> +               on_slab_lock_classes(cachep);
>
>         return 0;
>  }
> --
> 1.7.11.7
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
