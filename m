Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 577C26B027C
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:45:32 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id u206so62862995wme.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:45:32 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id m197si5616188wma.5.2016.04.06.14.45.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 14:45:31 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id u206so62862586wme.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:45:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1459971348-81477-1-git-send-email-thgarnie@google.com>
References: <1459971348-81477-1-git-send-email-thgarnie@google.com>
Date: Wed, 6 Apr 2016 14:45:30 -0700
Message-ID: <CAGXu5jLEENTFL_NYA5r4SqmUefkEwL68_Br6bX_RY2xNv95GVg@mail.gmail.com>
Subject: Re: [RFC v1] mm: SLAB freelist randomization
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Laura Abbott <labbott@fedoraproject.org>

On Wed, Apr 6, 2016 at 12:35 PM, Thomas Garnier <thgarnie@google.com> wrote:
> Provide an optional config (CONFIG_FREELIST_RANDOM) to randomize the
> SLAB freelist.

It may be useful to describe _how_ it randomizes it (i.e. a high-level
description of what needed changing).

> This security feature reduces the predictability of
> the kernel slab allocator against heap overflows.

I would add "... rendering attacks much less stable." And if you can
find a specific example exploit that is foiled by this, I would refer
to it.

> Randomized lists are pre-computed using a Fisher-Yates shuffle and

Should the use of Fisher-Yates (over other things) be justified?

> re-used on slab creation for performance.

I'd like to see some benchmark results for this so the Kconfig can
include the performance characteristics. I recommend using hackbench
and kernel build times with a before/after comparison.

> ---
> Based on next-20160405
> ---
>  init/Kconfig |   9 ++++
>  mm/slab.c    | 155 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 164 insertions(+)
>
> diff --git a/init/Kconfig b/init/Kconfig
> index 0dfd09d..ee35418 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1742,6 +1742,15 @@ config SLOB
>
>  endchoice
>
> +config FREELIST_RANDOM

I think I would name this "SLAB_FREELIST_RANDOM" since it's
SLAB-specific, unless you think it could be extended to the other
allocators in the future too? (If so, I'd mention the naming choice in
the commit log.)

> +       default n
> +       depends on SLAB
> +       bool "SLAB freelist randomization"
> +       help
> +         Randomizes the freelist order used on creating new SLABs. This
> +         security feature reduces the predictability of the kernel slab
> +         allocator against heap overflows.
> +
>  config SLUB_CPU_PARTIAL
>         default y
>         depends on SLUB && SMP
> diff --git a/mm/slab.c b/mm/slab.c
> index b70aabf..6f0d7be 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1229,6 +1229,59 @@ static void __init set_up_node(struct kmem_cache *cachep, int index)
>         }
>  }
>
> +#ifdef CONFIG_FREELIST_RANDOM
> +/*
> + * Master lists are pre-computed random lists
> + * Lists of different sizes are used to optimize performance on different
> + * SLAB object sizes per pages.
> + */
> +static freelist_idx_t master_list_2[2];
> +static freelist_idx_t master_list_4[4];
> +static freelist_idx_t master_list_8[8];
> +static freelist_idx_t master_list_16[16];
> +static freelist_idx_t master_list_32[32];
> +static freelist_idx_t master_list_64[64];
> +static freelist_idx_t master_list_128[128];
> +static freelist_idx_t master_list_256[256];
> +static struct m_list {
> +       size_t count;
> +       freelist_idx_t *list;
> +} master_lists[] = {
> +       { ARRAY_SIZE(master_list_2), master_list_2 },
> +       { ARRAY_SIZE(master_list_4), master_list_4 },
> +       { ARRAY_SIZE(master_list_8), master_list_8 },
> +       { ARRAY_SIZE(master_list_16), master_list_16 },
> +       { ARRAY_SIZE(master_list_32), master_list_32 },
> +       { ARRAY_SIZE(master_list_64), master_list_64 },
> +       { ARRAY_SIZE(master_list_128), master_list_128 },
> +       { ARRAY_SIZE(master_list_256), master_list_256 },
> +};
> +
> +void __init freelist_random_init(void)
> +{
> +       unsigned int seed;
> +       size_t z, i, rand;
> +       struct rnd_state slab_rand;
> +
> +       get_random_bytes_arch(&seed, sizeof(seed));
> +       prandom_seed_state(&slab_rand, seed);
> +
> +       for (z = 0; z < ARRAY_SIZE(master_lists); z++) {
> +               for (i = 0; i < master_lists[z].count; i++)
> +                       master_lists[z].list[i] = i;
> +
> +               /* Fisher-Yates shuffle */
> +               for (i = master_lists[z].count - 1; i > 0; i--) {
> +                       rand = prandom_u32_state(&slab_rand);
> +                       rand %= (i + 1);
> +                       swap(master_lists[z].list[i],
> +                               master_lists[z].list[rand]);
> +               }
> +       }
> +}

For below...

#else
static inline freelist_random_init(void) { }

> +#endif /* CONFIG_FREELIST_RANDOM */
> +
> +
>  /*
>   * Initialisation.  Called after the page allocator have been initialised and
>   * before smp_init().
> @@ -1255,6 +1308,10 @@ void __init kmem_cache_init(void)
>         if (!slab_max_order_set && totalram_pages > (32 << 20) >> PAGE_SHIFT)
>                 slab_max_order = SLAB_MAX_ORDER_HI;
>
> +#ifdef CONFIG_FREELIST_RANDOM
> +       freelist_random_init();
> +#endif /* CONFIG_FREELIST_RANDOM */

Rather than these embedded ifdefs, I would create stub function at the
top, as above.

> +
>         /* Bootstrap is tricky, because several objects are allocated
>          * from caches that do not exist yet:
>          * 1) initialize the kmem_cache cache: it contains the struct
> @@ -2442,6 +2499,98 @@ static void cache_init_objs_debug(struct kmem_cache *cachep, struct page *page)
>  #endif
>  }
>
> +#ifdef CONFIG_FREELIST_RANDOM
> +enum master_type {
> +       match,
> +       less,
> +       more
> +};
> +
> +struct random_mng {
> +       unsigned int padding;
> +       unsigned int pos;
> +       unsigned int count;
> +       struct m_list master_list;
> +       unsigned int master_count;
> +       enum master_type type;
> +};
> +
> +static void random_mng_initialize(struct random_mng *mng, unsigned int count)
> +{
> +       unsigned int idx;
> +       const unsigned int last_idx = ARRAY_SIZE(master_lists) - 1;
> +
> +       memset(mng, 0, sizeof(*mng));
> +       mng->count = count;
> +       mng->pos = 0;
> +       /* count is >= 2 */
> +       idx = ilog2(count) - 1;
> +       if (idx >= last_idx)
> +               idx = last_idx;
> +       else if (roundup_pow_of_two(idx + 1) != count)
> +               idx++;
> +       mng->master_list = master_lists[idx];
> +       if (mng->master_list.count == mng->count)
> +               mng->type = match;
> +       else if (mng->master_list.count > mng->count)
> +               mng->type = more;
> +       else
> +               mng->type = less;
> +}
> +
> +static freelist_idx_t get_next_entry(struct random_mng *mng)
> +{
> +       if (mng->type == less && mng->pos == mng->master_list.count) {
> +               mng->padding += mng->pos;
> +               mng->pos = 0;
> +       }
> +       BUG_ON(mng->pos >= mng->master_list.count);
> +       return mng->master_list.list[mng->pos++];
> +}
> +
> +static freelist_idx_t next_random_slot(struct random_mng *mng)
> +{
> +       freelist_idx_t cur, entry;
> +
> +       entry = get_next_entry(mng);
> +
> +       if (mng->type != match) {
> +               while ((entry + mng->padding) >= mng->count)
> +                       entry = get_next_entry(mng);
> +               cur = entry + mng->padding;
> +               BUG_ON(cur >= mng->count);
> +       } else {
> +               cur = entry;
> +       }
> +
> +       return cur;
> +}
> +
> +static void shuffle_freelist(struct kmem_cache *cachep, struct page *page,
> +                            unsigned int count)
> +{
> +       unsigned int i;
> +       struct random_mng mng;
> +
> +       if (count < 2) {
> +               for (i = 0; i < count; i++)
> +                       set_free_obj(page, i, i);
> +               return;
> +       }
> +
> +       /* Last chunk is used already in this case */
> +       if (OBJFREELIST_SLAB(cachep))
> +               count--;
> +
> +       random_mng_initialize(&mng, count);
> +       for (i = 0; i < count; i++)
> +               set_free_obj(page, i, next_random_slot(&mng));
> +
> +       if (OBJFREELIST_SLAB(cachep))
> +               set_free_obj(page, i, i);
> +}

Same thing here...

#else
static inline void set_free_obj(...) { }
static inline void shuffle_freelist(struct kmem_cache *cachep,
                              struct page *page, unsigned int count) { }

> +#endif /* CONFIG_FREELIST_RANDOM */
> +
>  static void cache_init_objs(struct kmem_cache *cachep,
>                             struct page *page)
>  {
> @@ -2464,8 +2613,14 @@ static void cache_init_objs(struct kmem_cache *cachep,
>                         kasan_poison_object_data(cachep, objp);
>                 }
>
> +#ifndef CONFIG_FREELIST_RANDOM
>                 set_free_obj(page, i, i);
> +#endif /* CONFIG_FREELIST_RANDOM */

For this one, I'd use:

                   if (config_enabled(CONFIG_FREELIST_RANDOM))
                           set_free_obj(page, i, i);

>         }
> +
> +#ifdef CONFIG_FREELIST_RANDOM
> +       shuffle_freelist(cachep, page, cachep->num);
> +#endif /* CONFIG_FREELIST_RANDOM */

This one can drop the ifdef in favor of using the stub function too.

>  }
>
>  static void kmem_flagcheck(struct kmem_cache *cachep, gfp_t flags)
> --
> 2.8.0.rc3.226.g39d4020
>

Exciting!

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
