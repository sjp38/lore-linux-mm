Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 03A3C6B0044
	for <linux-mm@kvack.org>; Sat,  4 Aug 2012 13:21:46 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3590041pbb.14
        for <linux-mm@kvack.org>; Sat, 04 Aug 2012 10:21:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120803192151.110627928@linux.com>
References: <20120803192052.448575403@linux.com>
	<20120803192151.110627928@linux.com>
Date: Sun, 5 Aug 2012 02:21:46 +0900
Message-ID: <CAAmzW4NVxsV2pOWYkrq0e7CSafafEq7QBsvD6Zh3ztuYzaLJSQ@mail.gmail.com>
Subject: Re: Common10 [06/20] Extract a common function for kmem_cache_destroy
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

> Index: linux-2.6/mm/slab_common.c
> ===================================================================
> --- linux-2.6.orig/mm/slab_common.c     2012-08-02 14:21:12.797779926 -0500
> +++ linux-2.6/mm/slab_common.c  2012-08-02 14:21:17.301860675 -0500
> @@ -130,6 +130,31 @@
>  }
>  EXPORT_SYMBOL(kmem_cache_create);
>
> +void kmem_cache_destroy(struct kmem_cache *s)
> +{
> +       get_online_cpus();
> +       mutex_lock(&slab_mutex);
> +       s->refcount--;
> +       if (!s->refcount) {
> +               list_del(&s->list);
> +
> +               if (!__kmem_cache_shutdown(s)) {
> +                       if (s->flags & SLAB_DESTROY_BY_RCU)
> +                               rcu_barrier();
> +
> +                       __kmem_cache_destroy(s);
> +               } else {
> +                       list_add(&s->list, &slab_caches);
> +                       printk(KERN_ERR "kmem_cache_destroy %s: Slab cache still has objects\n",
> +                               s->name);
> +                       dump_stack();
> +               }
> +       }
> +       mutex_unlock(&slab_mutex);
> +       put_online_cpus();
> +}
> +EXPORT_SYMBOL(kmem_cache_destroy);

This common code diverts behavior of slub when objects is remained.
Before patch, regardless of number of remaining objects, kmem_cache is
always destroyed.
After patch, when objects is remained, kmem_cache is also remained.
This is problematic behavior as kmem_cache_close() already free
per-cpu structure.
If we reuse this kmem_cache, we may encounter NULL pointer dereference.

I suggest following modification.
I thinks it is sufficient to prevent above mentioned case.

diff --git a/mm/slub.c b/mm/slub.c
index cfe4abb..7f26b39 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3184,7 +3184,6 @@ static inline int kmem_cache_close(struct kmem_cache *s)
        int node;

        flush_all(s);
-       free_percpu(s->cpu_slab);
        /* Attempt to free all objects */
        for_each_node_state(node, N_NORMAL_MEMORY) {
                struct kmem_cache_node *n = get_node(s, node);
@@ -3193,6 +3192,7 @@ static inline int kmem_cache_close(struct kmem_cache *s)
                if (n->nr_partial || slabs_node(s, node))
                        return 1;
        }
+       free_percpu(s->cpu_slab);
        free_kmem_cache_nodes(s);
        return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
