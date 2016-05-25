Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D1A7828E2
	for <linux-mm@kvack.org>; Wed, 25 May 2016 18:27:14 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id r185so142730556ywf.3
        for <linux-mm@kvack.org>; Wed, 25 May 2016 15:27:14 -0700 (PDT)
Received: from mail-vk0-f48.google.com (mail-vk0-f48.google.com. [209.85.213.48])
        by mx.google.com with ESMTPS id 61si8380646uax.47.2016.05.25.15.27.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 15:27:13 -0700 (PDT)
Received: by mail-vk0-f48.google.com with SMTP id c189so80834721vkb.1
        for <linux-mm@kvack.org>; Wed, 25 May 2016 15:27:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1464124523-43051-3-git-send-email-thgarnie@google.com>
References: <1464124523-43051-1-git-send-email-thgarnie@google.com> <1464124523-43051-3-git-send-email-thgarnie@google.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 25 May 2016 15:25:15 -0700
Message-ID: <CAGXu5j+t88a-nU7k86H28H=cam4kfioB=Oz-GYpx=mOQrgWNhg@mail.gmail.com>
Subject: Re: [RFC v2 2/2] mm: SLUB Freelist randomization
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Pranith Kumar <bobby.prani@gmail.com>, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Woodhouse <David.Woodhouse@intel.com>, Petr Mladek <pmladek@suse.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Tue, May 24, 2016 at 2:15 PM, Thomas Garnier <thgarnie@google.com> wrote:
> Implements Freelist randomization for the SLUB allocator. It was
> previous implemented for the SLAB allocator. Both use the same
> configuration option (CONFIG_SLAB_FREELIST_RANDOM).
>
> The list is randomized during initialization of a new set of pages. The
> order on different freelist sizes is pre-computed at boot for
> performance. Each kmem_cache has its own randomized freelist. This
> security feature reduces the predictability of the kernel SLUB allocator
> against heap overflows rendering attacks much less stable.
>
> For example these attacks exploit the predictability of the heap:
>  - Linux Kernel CAN SLUB overflow (https://goo.gl/oMNWkU)
>  - Exploiting Linux Kernel Heap corruptions (http://goo.gl/EXLn95)
>
> Performance results:
>
> slab_test impact is between 3% to 4% on average:

Seems like slab_test is pretty intensive (so the impact appears
higher). On a more "regular" load like kernbench, the impact seems to
be almost 0. Is that accurate?

Regardless, please consider both patches:

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

>
> Before:
>
> Single thread testing
> =====================
> 1. Kmalloc: Repeatedly allocate then free test
> 100000 times kmalloc(8) -> 49 cycles kfree -> 77 cycles
> 100000 times kmalloc(16) -> 51 cycles kfree -> 79 cycles
> 100000 times kmalloc(32) -> 53 cycles kfree -> 83 cycles
> 100000 times kmalloc(64) -> 62 cycles kfree -> 90 cycles
> 100000 times kmalloc(128) -> 81 cycles kfree -> 97 cycles
> 100000 times kmalloc(256) -> 98 cycles kfree -> 121 cycles
> 100000 times kmalloc(512) -> 95 cycles kfree -> 122 cycles
> 100000 times kmalloc(1024) -> 96 cycles kfree -> 126 cycles
> 100000 times kmalloc(2048) -> 115 cycles kfree -> 140 cycles
> 100000 times kmalloc(4096) -> 149 cycles kfree -> 171 cycles
> 2. Kmalloc: alloc/free test
> 100000 times kmalloc(8)/kfree -> 70 cycles
> 100000 times kmalloc(16)/kfree -> 70 cycles
> 100000 times kmalloc(32)/kfree -> 70 cycles
> 100000 times kmalloc(64)/kfree -> 70 cycles
> 100000 times kmalloc(128)/kfree -> 70 cycles
> 100000 times kmalloc(256)/kfree -> 69 cycles
> 100000 times kmalloc(512)/kfree -> 70 cycles
> 100000 times kmalloc(1024)/kfree -> 73 cycles
> 100000 times kmalloc(2048)/kfree -> 72 cycles
> 100000 times kmalloc(4096)/kfree -> 71 cycles
>
> After:
>
> Single thread testing
> =====================
> 1. Kmalloc: Repeatedly allocate then free test
> 100000 times kmalloc(8) -> 57 cycles kfree -> 78 cycles
> 100000 times kmalloc(16) -> 61 cycles kfree -> 81 cycles
> 100000 times kmalloc(32) -> 76 cycles kfree -> 93 cycles
> 100000 times kmalloc(64) -> 83 cycles kfree -> 94 cycles
> 100000 times kmalloc(128) -> 106 cycles kfree -> 107 cycles
> 100000 times kmalloc(256) -> 118 cycles kfree -> 117 cycles
> 100000 times kmalloc(512) -> 114 cycles kfree -> 116 cycles
> 100000 times kmalloc(1024) -> 115 cycles kfree -> 118 cycles
> 100000 times kmalloc(2048) -> 147 cycles kfree -> 131 cycles
> 100000 times kmalloc(4096) -> 214 cycles kfree -> 161 cycles
> 2. Kmalloc: alloc/free test
> 100000 times kmalloc(8)/kfree -> 66 cycles
> 100000 times kmalloc(16)/kfree -> 66 cycles
> 100000 times kmalloc(32)/kfree -> 66 cycles
> 100000 times kmalloc(64)/kfree -> 66 cycles
> 100000 times kmalloc(128)/kfree -> 65 cycles
> 100000 times kmalloc(256)/kfree -> 67 cycles
> 100000 times kmalloc(512)/kfree -> 67 cycles
> 100000 times kmalloc(1024)/kfree -> 64 cycles
> 100000 times kmalloc(2048)/kfree -> 67 cycles
> 100000 times kmalloc(4096)/kfree -> 67 cycles
>
> Kernbench, before:
>
> Average Optimal load -j 12 Run (std deviation):
> Elapsed Time 101.873 (1.16069)
> User Time 1045.22 (1.60447)
> System Time 88.969 (0.559195)
> Percent CPU 1112.9 (13.8279)
> Context Switches 189140 (2282.15)
> Sleeps 99008.6 (768.091)
>
> After:
>
> Average Optimal load -j 12 Run (std deviation):
> Elapsed Time 102.47 (0.562732)
> User Time 1045.3 (1.34263)
> System Time 88.311 (0.342554)
> Percent CPU 1105.8 (6.49444)
> Context Switches 189081 (2355.78)
> Sleeps 99231.5 (800.358)
>
> Signed-off-by: Thomas Garnier <thgarnie@google.com>
> ---
> Based on 0e01df100b6bf22a1de61b66657502a6454153c5
> ---
>  include/linux/slub_def.h |   8 +++
>  init/Kconfig             |   4 +-
>  mm/slub.c                | 133 ++++++++++++++++++++++++++++++++++++++++++++---
>  3 files changed, 136 insertions(+), 9 deletions(-)
>
> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> index 665cd0c..22d487e 100644
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -56,6 +56,9 @@ struct kmem_cache_order_objects {
>         unsigned long x;
>  };
>
> +/* Index used for freelist randomization */
> +typedef unsigned int freelist_idx_t;
> +
>  /*
>   * Slab cache management.
>   */
> @@ -99,6 +102,11 @@ struct kmem_cache {
>          */
>         int remote_node_defrag_ratio;
>  #endif
> +
> +#ifdef CONFIG_SLAB_FREELIST_RANDOM
> +       freelist_idx_t *random_seq;
> +#endif
> +
>         struct kmem_cache_node *node[MAX_NUMNODES];
>  };
>
> diff --git a/init/Kconfig b/init/Kconfig
> index a9c4aefd..fbb6678 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1771,10 +1771,10 @@ endchoice
>
>  config SLAB_FREELIST_RANDOM
>         default n
> -       depends on SLAB
> +       depends on SLAB || SLUB
>         bool "SLAB freelist randomization"
>         help
> -         Randomizes the freelist order used on creating new SLABs. This
> +         Randomizes the freelist order used on creating new pages. This
>           security feature reduces the predictability of the kernel slab
>           allocator against heap overflows.
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 825ff45..217aa8a 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1405,6 +1405,109 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
>         return page;
>  }
>
> +#ifdef CONFIG_SLAB_FREELIST_RANDOM
> +/* Pre-initialize the random sequence cache */
> +static int init_cache_random_seq(struct kmem_cache *s)
> +{
> +       int err;
> +       unsigned long i, count = oo_objects(s->oo);
> +
> +       err = cache_random_seq_create(s, count, GFP_KERNEL);
> +       if (err) {
> +               pr_err("SLUB: Unable to initialize free list for %s\n",
> +                       s->name);
> +               return err;
> +       }
> +
> +       /* Transform to an offset on the set of pages */
> +       if (s->random_seq) {
> +               for (i = 0; i < count; i++)
> +                       s->random_seq[i] *= s->size;
> +       }
> +       return 0;
> +}
> +
> +/* Initialize each random sequence freelist per cache */
> +static void __init init_freelist_randomization(void)
> +{
> +       struct kmem_cache *s;
> +
> +       mutex_lock(&slab_mutex);
> +
> +       list_for_each_entry(s, &slab_caches, list)
> +               init_cache_random_seq(s);
> +
> +       mutex_unlock(&slab_mutex);
> +}
> +
> +/* Get the next entry on the pre-computed freelist randomized */
> +static void *next_freelist_entry(struct kmem_cache *s, struct page *page,
> +                               unsigned long *pos, void *start,
> +                               unsigned long page_limit,
> +                               unsigned long freelist_count)
> +{
> +       freelist_idx_t idx;
> +
> +       /*
> +        * If the target page allocation failed, the number of objects on the
> +        * page might be smaller than the usual size defined by the cache.
> +        */
> +       do {
> +               idx = s->random_seq[*pos];
> +               *pos += 1;
> +               if (*pos >= freelist_count)
> +                       *pos = 0;
> +       } while (unlikely(idx >= page_limit));
> +
> +       return (char *)start + idx;
> +}
> +
> +/* Shuffle the single linked freelist based on a random pre-computed sequence */
> +static bool shuffle_freelist(struct kmem_cache *s, struct page *page)
> +{
> +       void *start;
> +       void *cur;
> +       void *next;
> +       unsigned long idx, pos, page_limit, freelist_count;
> +
> +       if (page->objects < 2 || !s->random_seq)
> +               return false;
> +
> +       freelist_count = oo_objects(s->oo);
> +       pos = get_random_int() % freelist_count;
> +
> +       page_limit = page->objects * s->size;
> +       start = fixup_red_left(s, page_address(page));
> +
> +       /* First entry is used as the base of the freelist */
> +       cur = next_freelist_entry(s, page, &pos, start, page_limit,
> +                               freelist_count);
> +       page->freelist = cur;
> +
> +       for (idx = 1; idx < page->objects; idx++) {
> +               setup_object(s, page, cur);
> +               next = next_freelist_entry(s, page, &pos, start, page_limit,
> +                       freelist_count);
> +               set_freepointer(s, cur, next);
> +               cur = next;
> +       }
> +       setup_object(s, page, cur);
> +       set_freepointer(s, cur, NULL);
> +
> +       return true;
> +}
> +#else
> +static inline int init_cache_random_seq(struct kmem_cache *s)
> +{
> +       return 0;
> +}
> +static inline void init_freelist_randomization(void) { }
> +static inline bool shuffle_freelist(struct kmem_cache *s, struct page *page)
> +{
> +       return false;
> +}
> +#endif /* CONFIG_SLAB_FREELIST_RANDOM */
> +
>  static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  {
>         struct page *page;
> @@ -1412,6 +1515,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>         gfp_t alloc_gfp;
>         void *start, *p;
>         int idx, order;
> +       bool shuffle;
>
>         flags &= gfp_allowed_mask;
>
> @@ -1473,15 +1577,19 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>
>         kasan_poison_slab(page);
>
> -       for_each_object_idx(p, idx, s, start, page->objects) {
> -               setup_object(s, page, p);
> -               if (likely(idx < page->objects))
> -                       set_freepointer(s, p, p + s->size);
> -               else
> -                       set_freepointer(s, p, NULL);
> +       shuffle = shuffle_freelist(s, page);
> +
> +       if (!shuffle) {
> +               for_each_object_idx(p, idx, s, start, page->objects) {
> +                       setup_object(s, page, p);
> +                       if (likely(idx < page->objects))
> +                               set_freepointer(s, p, p + s->size);
> +                       else
> +                               set_freepointer(s, p, NULL);
> +               }
> +               page->freelist = fixup_red_left(s, start);
>         }
>
> -       page->freelist = fixup_red_left(s, start);
>         page->inuse = page->objects;
>         page->frozen = 1;
>
> @@ -3207,6 +3315,7 @@ static void free_kmem_cache_nodes(struct kmem_cache *s)
>
>  void __kmem_cache_release(struct kmem_cache *s)
>  {
> +       cache_random_seq_destroy(s);
>         free_percpu(s->cpu_slab);
>         free_kmem_cache_nodes(s);
>  }
> @@ -3431,6 +3540,13 @@ static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
>  #ifdef CONFIG_NUMA
>         s->remote_node_defrag_ratio = 1000;
>  #endif
> +
> +       /* Initialize the pre-computed randomized freelist if slab is up */
> +       if (slab_state >= UP) {
> +               if (init_cache_random_seq(s))
> +                       goto error;
> +       }
> +
>         if (!init_kmem_cache_nodes(s))
>                 goto error;
>
> @@ -3947,6 +4063,9 @@ void __init kmem_cache_init(void)
>         setup_kmalloc_cache_index_table();
>         create_kmalloc_caches(0);
>
> +       /* Setup random freelists for each cache */
> +       init_freelist_randomization();
> +
>  #ifdef CONFIG_SMP
>         register_cpu_notifier(&slab_notifier);
>  #endif
> --
> 2.8.0.rc3.226.g39d4020
>



-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
