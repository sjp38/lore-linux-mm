Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 021266B0005
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 20:35:35 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id i27so444874730qte.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 17:35:34 -0700 (PDT)
Received: from mail-vk0-x243.google.com (mail-vk0-x243.google.com. [2607:f8b0:400c:c05::243])
        by mx.google.com with ESMTPS id 18si4017638uad.62.2016.08.04.17.35.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 17:35:34 -0700 (PDT)
Received: by mail-vk0-x243.google.com with SMTP id w127so11772274vkh.1
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 17:35:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1470337273-6700-1-git-send-email-aruna.ramakrishna@oracle.com>
References: <1470337273-6700-1-git-send-email-aruna.ramakrishna@oracle.com>
From: Joonsoo Kim <js1304@gmail.com>
Date: Fri, 5 Aug 2016 09:35:33 +0900
Message-ID: <CAAmzW4On7FWc37fQJOsDQOEOVXqK3ue+uiB0ZOFM9R5e-Jj3WQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm/slab: Improve performance of gathering slabinfo stats
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

2016-08-05 4:01 GMT+09:00 Aruna Ramakrishna <aruna.ramakrishna@oracle.com>:
> On large systems, when some slab caches grow to millions of objects (and
> many gigabytes), running 'cat /proc/slabinfo' can take up to 1-2 seconds.
> During this time, interrupts are disabled while walking the slab lists
> (slabs_full, slabs_partial, and slabs_free) for each node, and this
> sometimes causes timeouts in other drivers (for instance, Infiniband).
>
> This patch optimizes 'cat /proc/slabinfo' by maintaining a counter for
> total number of allocated slabs per node, per cache. This counter is
> updated when a slab is created or destroyed. This enables us to skip
> traversing the slabs_full list while gathering slabinfo statistics, and
> since slabs_full tends to be the biggest list when the cache is large, it
> results in a dramatic performance improvement. Getting slabinfo statistics
> now only requires walking the slabs_free and slabs_partial lists, and
> those lists are usually much smaller than slabs_full. We tested this after
> growing the dentry cache to 70GB, and the performance improved from 2s to
> 5ms.
>
> Signed-off-by: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
> Note: this has been tested only on x86_64.
>
>  mm/slab.c | 25 ++++++++++++++++---------
>  mm/slab.h | 15 ++++++++++++++-
>  mm/slub.c | 19 +------------------
>  3 files changed, 31 insertions(+), 28 deletions(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index 261147b..d683840 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -233,6 +233,7 @@ static void kmem_cache_node_init(struct kmem_cache_node *parent)
>         spin_lock_init(&parent->list_lock);
>         parent->free_objects = 0;
>         parent->free_touched = 0;
> +       atomic_long_set(&parent->nr_slabs, 0);
>  }
>
>  #define MAKE_LIST(cachep, listp, slab, nodeid)                         \
> @@ -2333,6 +2334,7 @@ static int drain_freelist(struct kmem_cache *cache,
>                 n->free_objects -= cache->num;
>                 spin_unlock_irq(&n->list_lock);
>                 slab_destroy(cache, page);
> +               atomic_long_dec(&n->nr_slabs);
>                 nr_freed++;
>         }

Please decrease counter when a slab is detached from the list.
Otherwise, there would be inconsistent between counter and
number of attached slab on the list.

>  out:
> @@ -2736,6 +2738,8 @@ static struct page *cache_grow_begin(struct kmem_cache *cachep,
>         if (gfpflags_allow_blocking(local_flags))
>                 local_irq_disable();
>
> +       atomic_long_inc(&n->nr_slabs);
> +
>         return page;

Please increase counter when a slab is attached to the list
in cache_grow_end().

>  opps1:
> @@ -3455,6 +3459,7 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
>
>                 page = list_last_entry(&n->slabs_free, struct page, lru);
>                 list_move(&page->lru, list);
> +               atomic_long_dec(&n->nr_slabs);
>         }
>  }
>
> @@ -4111,6 +4116,8 @@ void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
>         unsigned long num_objs;
>         unsigned long active_slabs = 0;
>         unsigned long num_slabs, free_objects = 0, shared_avail = 0;
> +       unsigned long num_slabs_partial = 0, num_slabs_free = 0;
> +       unsigned long num_slabs_full = 0;
>         const char *name;
>         char *error = NULL;
>         int node;
> @@ -4120,36 +4127,36 @@ void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
>         num_slabs = 0;
>         for_each_kmem_cache_node(cachep, node, n) {
>
> +               num_slabs += node_nr_slabs(n);
>                 check_irq_on();
>                 spin_lock_irq(&n->list_lock);
>
> -               list_for_each_entry(page, &n->slabs_full, lru) {
> -                       if (page->active != cachep->num && !error)
> -                               error = "slabs_full accounting error";
> -                       active_objs += cachep->num;
> -                       active_slabs++;
> -               }
>                 list_for_each_entry(page, &n->slabs_partial, lru) {
>                         if (page->active == cachep->num && !error)
>                                 error = "slabs_partial accounting error";
>                         if (!page->active && !error)
>                                 error = "slabs_partial accounting error";
>                         active_objs += page->active;
> -                       active_slabs++;
> +                       num_slabs_partial++;
>                 }
> +
>                 list_for_each_entry(page, &n->slabs_free, lru) {
>                         if (page->active && !error)
>                                 error = "slabs_free accounting error";
> -                       num_slabs++;
> +                       num_slabs_free++;
>                 }
> +
>                 free_objects += n->free_objects;
>                 if (n->shared)
>                         shared_avail += n->shared->avail;
>
>                 spin_unlock_irq(&n->list_lock);
>         }
> -       num_slabs += active_slabs;
>         num_objs = num_slabs * cachep->num;
> +       active_slabs = num_slabs - num_slabs_free;
> +       num_slabs_full = num_slabs - (num_slabs_partial + num_slabs_free);
> +       active_objs += (num_slabs_full * cachep->num);
> +
>         if (num_objs - active_objs != free_objects && !error)
>                 error = "free_objects accounting error";
>
> diff --git a/mm/slab.h b/mm/slab.h
> index 9653f2e..5740cec 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -427,6 +427,7 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
>   */
>  struct kmem_cache_node {
>         spinlock_t list_lock;
> +       atomic_long_t nr_slabs;

If above my comments are fixed, all counting would be done with
holding a lock. So, atomic definition isn't needed for the SLAB.
I think that it's better not to commonize this counting.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
