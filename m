Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id E49FA6B0005
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 21:58:38 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id y69so1663962oif.0
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 18:58:38 -0700 (PDT)
Received: from mail-ob0-x236.google.com (mail-ob0-x236.google.com. [2607:f8b0:4003:c01::236])
        by mx.google.com with ESMTPS id x55si8816091otx.232.2016.04.25.18.58.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 18:58:38 -0700 (PDT)
Received: by mail-ob0-x236.google.com with SMTP id j9so373470obd.3
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 18:58:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160426004022.GA2707@js1304-P5Q-DELUXE>
References: <1461616763-60246-1-git-send-email-thgarnie@google.com>
	<20160426004022.GA2707@js1304-P5Q-DELUXE>
Date: Mon, 25 Apr 2016 18:58:37 -0700
Message-ID: <CAJcbSZFo_OWh5G0R6ghqFUrnBEQPLSknm8U5LywK5QCyTY9_pw@mail.gmail.com>
Subject: Re: [PATCH v2] mm: SLAB freelist randomization
From: Thomas Garnier <thgarnie@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Greg Thelen <gthelen@google.com>, Laura Abbott <labbott@fedoraproject.org>, kernel-hardening@lists.openwall.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Make sense. I think it is still valuable to randomize earlier pages. I
will adapt the code, test and send patch v4.

Thanks for the quick feedback,
Thomas

On Mon, Apr 25, 2016 at 5:40 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> On Mon, Apr 25, 2016 at 01:39:23PM -0700, Thomas Garnier wrote:
>> Provides an optional config (CONFIG_FREELIST_RANDOM) to randomize the
>> SLAB freelist. The list is randomized during initialization of a new set
>> of pages. The order on different freelist sizes is pre-computed at boot
>> for performance. Each kmem_cache has its own randomized freelist except
>> early on boot where global lists are used. This security feature reduces
>> the predictability of the kernel SLAB allocator against heap overflows
>> rendering attacks much less stable.
>>
>> For example this attack against SLUB (also applicable against SLAB)
>> would be affected:
>> https://jon.oberheide.org/blog/2010/09/10/linux-kernel-can-slub-overflow/
>>
>> Also, since v4.6 the freelist was moved at the end of the SLAB. It means
>> a controllable heap is opened to new attacks not yet publicly discussed.
>> A kernel heap overflow can be transformed to multiple use-after-free.
>> This feature makes this type of attack harder too.
>>
>> To generate entropy, we use get_random_bytes_arch because 0 bits of
>> entropy is available in the boot stage. In the worse case this function
>> will fallback to the get_random_bytes sub API. We also generate a shift
>> random number to shift pre-computed freelist for each new set of pages.
>>
>> The config option name is not specific to the SLAB as this approach will
>> be extended to other allocators like SLUB.
>>
>> Performance results highlighted no major changes:
>>
>> slab_test 1 run on boot. Difference only seen on the 2048 size test
>> being the worse case scenario covered by freelist randomization. New
>> slab pages are constantly being created on the 10000 allocations.
>> Variance should be mainly due to getting new pages every few
>> allocations.
>>
>> Before:
>>
>> Single thread testing
>> =====================
>> 1. Kmalloc: Repeatedly allocate then free test
>> 10000 times kmalloc(8) -> 99 cycles kfree -> 112 cycles
>> 10000 times kmalloc(16) -> 109 cycles kfree -> 140 cycles
>> 10000 times kmalloc(32) -> 129 cycles kfree -> 137 cycles
>> 10000 times kmalloc(64) -> 141 cycles kfree -> 141 cycles
>> 10000 times kmalloc(128) -> 152 cycles kfree -> 148 cycles
>> 10000 times kmalloc(256) -> 195 cycles kfree -> 167 cycles
>> 10000 times kmalloc(512) -> 257 cycles kfree -> 199 cycles
>> 10000 times kmalloc(1024) -> 393 cycles kfree -> 251 cycles
>> 10000 times kmalloc(2048) -> 649 cycles kfree -> 228 cycles
>> 10000 times kmalloc(4096) -> 806 cycles kfree -> 370 cycles
>> 10000 times kmalloc(8192) -> 814 cycles kfree -> 411 cycles
>> 10000 times kmalloc(16384) -> 892 cycles kfree -> 455 cycles
>> 2. Kmalloc: alloc/free test
>> 10000 times kmalloc(8)/kfree -> 121 cycles
>> 10000 times kmalloc(16)/kfree -> 121 cycles
>> 10000 times kmalloc(32)/kfree -> 121 cycles
>> 10000 times kmalloc(64)/kfree -> 121 cycles
>> 10000 times kmalloc(128)/kfree -> 121 cycles
>> 10000 times kmalloc(256)/kfree -> 119 cycles
>> 10000 times kmalloc(512)/kfree -> 119 cycles
>> 10000 times kmalloc(1024)/kfree -> 119 cycles
>> 10000 times kmalloc(2048)/kfree -> 119 cycles
>> 10000 times kmalloc(4096)/kfree -> 121 cycles
>> 10000 times kmalloc(8192)/kfree -> 119 cycles
>> 10000 times kmalloc(16384)/kfree -> 119 cycles
>>
>> After:
>>
>> Single thread testing
>> =====================
>> 1. Kmalloc: Repeatedly allocate then free test
>> 10000 times kmalloc(8) -> 130 cycles kfree -> 86 cycles
>> 10000 times kmalloc(16) -> 118 cycles kfree -> 86 cycles
>> 10000 times kmalloc(32) -> 121 cycles kfree -> 85 cycles
>> 10000 times kmalloc(64) -> 176 cycles kfree -> 102 cycles
>> 10000 times kmalloc(128) -> 178 cycles kfree -> 100 cycles
>> 10000 times kmalloc(256) -> 205 cycles kfree -> 109 cycles
>> 10000 times kmalloc(512) -> 262 cycles kfree -> 136 cycles
>> 10000 times kmalloc(1024) -> 342 cycles kfree -> 157 cycles
>> 10000 times kmalloc(2048) -> 701 cycles kfree -> 238 cycles
>> 10000 times kmalloc(4096) -> 803 cycles kfree -> 364 cycles
>> 10000 times kmalloc(8192) -> 835 cycles kfree -> 404 cycles
>> 10000 times kmalloc(16384) -> 896 cycles kfree -> 441 cycles
>> 2. Kmalloc: alloc/free test
>> 10000 times kmalloc(8)/kfree -> 121 cycles
>> 10000 times kmalloc(16)/kfree -> 121 cycles
>> 10000 times kmalloc(32)/kfree -> 123 cycles
>> 10000 times kmalloc(64)/kfree -> 142 cycles
>> 10000 times kmalloc(128)/kfree -> 121 cycles
>> 10000 times kmalloc(256)/kfree -> 119 cycles
>> 10000 times kmalloc(512)/kfree -> 119 cycles
>> 10000 times kmalloc(1024)/kfree -> 119 cycles
>> 10000 times kmalloc(2048)/kfree -> 119 cycles
>> 10000 times kmalloc(4096)/kfree -> 119 cycles
>> 10000 times kmalloc(8192)/kfree -> 119 cycles
>> 10000 times kmalloc(16384)/kfree -> 119 cycles
>>
>> Signed-off-by: Thomas Garnier <thgarnie@google.com>
>> ---
>> Based on next-20160422
>> ---
>>  include/linux/slab_def.h |   4 +
>>  init/Kconfig             |   9 ++
>>  mm/slab.c                | 213 ++++++++++++++++++++++++++++++++++++++++++++++-
>>  3 files changed, 224 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
>> index 9edbbf3..182ec26 100644
>> --- a/include/linux/slab_def.h
>> +++ b/include/linux/slab_def.h
>> @@ -80,6 +80,10 @@ struct kmem_cache {
>>       struct kasan_cache kasan_info;
>>  #endif
>>
>> +#ifdef CONFIG_FREELIST_RANDOM
>> +     void *random_seq;
>> +#endif
>> +
>>       struct kmem_cache_node *node[MAX_NUMNODES];
>>  };
>>
>> diff --git a/init/Kconfig b/init/Kconfig
>> index 0c66640..73453d0 100644
>> --- a/init/Kconfig
>> +++ b/init/Kconfig
>> @@ -1742,6 +1742,15 @@ config SLOB
>>
>>  endchoice
>>
>> +config FREELIST_RANDOM
>> +     default n
>> +     depends on SLAB
>> +     bool "SLAB freelist randomization"
>> +     help
>> +       Randomizes the freelist order used on creating new SLABs. This
>> +       security feature reduces the predictability of the kernel slab
>> +       allocator against heap overflows.
>> +
>>  config SLUB_CPU_PARTIAL
>>       default y
>>       depends on SLUB && SMP
>> diff --git a/mm/slab.c b/mm/slab.c
>> index b82ee6b..89eb617 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -116,6 +116,7 @@
>>  #include     <linux/kmemcheck.h>
>>  #include     <linux/memory.h>
>>  #include     <linux/prefetch.h>
>> +#include     <linux/log2.h>
>>
>>  #include     <net/sock.h>
>>
>> @@ -1230,6 +1231,100 @@ static void __init set_up_node(struct kmem_cache *cachep, int index)
>>       }
>>  }
>>
>> +#ifdef CONFIG_FREELIST_RANDOM
>> +static void freelist_randomize(struct rnd_state *state, freelist_idx_t *list,
>> +                     size_t count)
>> +{
>> +     size_t i;
>> +     unsigned int rand;
>> +
>> +     for (i = 0; i < count; i++)
>> +             list[i] = i;
>> +
>> +     /* Fisher-Yates shuffle */
>> +     for (i = count - 1; i > 0; i--) {
>> +             rand = prandom_u32_state(state);
>> +             rand %= (i + 1);
>> +             swap(list[i], list[rand]);
>> +     }
>> +}
>> +
>> +/* Create a random sequence per cache */
>> +static void cache_random_seq_create(struct kmem_cache *cachep)
>> +{
>> +     unsigned int seed, count = cachep->num;
>> +     struct rnd_state state;
>> +
>> +     if (count < 2)
>> +             return;
>> +
>> +     cachep->random_seq = kcalloc(count, sizeof(freelist_idx_t), GFP_KERNEL);
>> +     BUG_ON(cachep->random_seq == NULL);
>
> Hello,
>
> Please make function return int and propagate error to the cache creator.
>
>> +
>> +     /* Get best entropy at this stage */
>> +     get_random_bytes_arch(&seed, sizeof(seed));
>> +     prandom_seed_state(&state, seed);
>> +
>> +     freelist_randomize(&state, cachep->random_seq, count);
>> +}
>> +
>> +/* Destroy the per-cache random freelist sequence */
>> +static void cache_random_seq_destroy(struct kmem_cache *cachep)
>> +{
>> +     kfree(cachep->random_seq);
>> +     cachep->random_seq = NULL;
>> +}
>> +
>> +/*
>> + * Global static list are used when pre-computed cache list are not yet
>> + * available. Lists of different sizes are created to optimize performance on
>> + * SLABS with different object counts.
>> + */
>> +static freelist_idx_t freelist_random_seq_2[2];
>> +static freelist_idx_t freelist_random_seq_4[4];
>> +static freelist_idx_t freelist_random_seq_8[8];
>> +static freelist_idx_t freelist_random_seq_16[16];
>> +static freelist_idx_t freelist_random_seq_32[32];
>> +static freelist_idx_t freelist_random_seq_64[64];
>> +static freelist_idx_t freelist_random_seq_128[128];
>> +static freelist_idx_t freelist_random_seq_256[256];
>> +const static struct m_list {
>> +     size_t count;
>> +     freelist_idx_t *list;
>> +} freelist_random_seqs[] = {
>> +     { ARRAY_SIZE(freelist_random_seq_2), freelist_random_seq_2 },
>> +     { ARRAY_SIZE(freelist_random_seq_4), freelist_random_seq_4 },
>> +     { ARRAY_SIZE(freelist_random_seq_8), freelist_random_seq_8 },
>> +     { ARRAY_SIZE(freelist_random_seq_16), freelist_random_seq_16 },
>> +     { ARRAY_SIZE(freelist_random_seq_32), freelist_random_seq_32 },
>> +     { ARRAY_SIZE(freelist_random_seq_64), freelist_random_seq_64 },
>> +     { ARRAY_SIZE(freelist_random_seq_128), freelist_random_seq_128 },
>> +     { ARRAY_SIZE(freelist_random_seq_256), freelist_random_seq_256 },
>> +};
>
> I'd like to remove this global static list even if we can't get random
> sequence in early boot-up process. In this stage that kernel is not
> yet initialized, malicious user cannot do anything so random sequence
> doesn't give any more security. After kernel initialization, we will
> use per cache random sequence so problem suface is really small. If you
> want to randomize freelist sequence even in this case, you can manually
> permute the sequence with calling prandom_u32_state(). But, I don't
> think it is necessary.
>
> Thanks.
>
>> +
>> +/* Pre-compute the global pre-computed lists early at boot */
>> +static void __init freelist_random_init(void)
>> +{
>> +     unsigned int seed;
>> +     size_t i;
>> +     struct rnd_state state;
>> +
>> +     /* Get best entropy available at this stage */
>> +     get_random_bytes_arch(&seed, sizeof(seed));
>> +     prandom_seed_state(&state, seed);
>> +
>> +     for (i = 0; i < ARRAY_SIZE(freelist_random_seqs); i++) {
>> +             freelist_randomize(&state, freelist_random_seqs[i].list,
>> +                             freelist_random_seqs[i].count);
>> +     }
>> +}
>> +#else
>> +static inline void __init freelist_random_init(void) { }
>> +static inline void cache_random_seq_create(struct kmem_cache *cachep) { }
>> +static inline void cache_random_seq_destroy(struct kmem_cache *cachep) { }
>> +#endif /* CONFIG_FREELIST_RANDOM */
>> +
>> +
>>  /*
>>   * Initialisation.  Called after the page allocator have been initialised and
>>   * before smp_init().
>> @@ -1256,6 +1351,8 @@ void __init kmem_cache_init(void)
>>       if (!slab_max_order_set && totalram_pages > (32 << 20) >> PAGE_SHIFT)
>>               slab_max_order = SLAB_MAX_ORDER_HI;
>>
>> +     freelist_random_init();
>> +
>>       /* Bootstrap is tricky, because several objects are allocated
>>        * from caches that do not exist yet:
>>        * 1) initialize the kmem_cache cache: it contains the struct
>> @@ -2337,6 +2434,8 @@ void __kmem_cache_release(struct kmem_cache *cachep)
>>       int i;
>>       struct kmem_cache_node *n;
>>
>> +     cache_random_seq_destroy(cachep);
>> +
>>       free_percpu(cachep->cpu_cache);
>>
>>       /* NUMA: free the node structures */
>> @@ -2443,15 +2542,122 @@ static void cache_init_objs_debug(struct kmem_cache *cachep, struct page *page)
>>  #endif
>>  }
>>
>> +#ifdef CONFIG_FREELIST_RANDOM
>> +/* Hold information during a freelist initialization */
>> +struct freelist_init_state {
>> +     unsigned int padding;
>> +     unsigned int pos;
>> +     unsigned int count;
>> +     unsigned int rand;
>> +     struct m_list freelist_random_seq;
>> +};
>> +
>> +/* Select the right pre-computed list and initialize state */
>> +static void freelist_state_initialize(struct freelist_init_state *state,
>> +                             struct kmem_cache *cachep,
>> +                             unsigned int count)
>> +{
>> +     unsigned int idx;
>> +     const unsigned int last_idx = ARRAY_SIZE(freelist_random_seqs) - 1;
>> +
>> +     memset(state, 0, sizeof(*state));
>> +     state->count = count;
>> +     state->pos = 0;
>> +
>> +     /* Use best entropy available to define a random shift */
>> +     get_random_bytes_arch(&state->rand, sizeof(state->rand));
>> +
>> +     if (cachep->random_seq) {
>> +             state->freelist_random_seq.list = cachep->random_seq;
>> +             state->freelist_random_seq.count = count;
>> +     } else {
>> +             /* count is always >= 2 */
>> +             idx = ilog2(count) - 1;
>> +             if (idx >= last_idx)
>> +                     idx = last_idx;
>> +             else if (roundup_pow_of_two(idx + 1) != count)
>> +                     idx++;
>> +             state->freelist_random_seq = freelist_random_seqs[idx];
>> +     }
>> +}
>> +
>> +/* Get the next entry on the list depending on the target list size */
>> +static freelist_idx_t get_next_entry(struct freelist_init_state *state)
>> +{
>> +     freelist_idx_t ret;
>> +
>> +     if (state->pos == state->freelist_random_seq.count) {
>> +             state->padding += state->pos;
>> +             state->pos = 0;
>> +     }
>> +
>> +     /* Randomize the entry using the random shift */
>> +     ret = state->freelist_random_seq.list[state->pos++];
>> +     ret = (ret + state->rand) % state->freelist_random_seq.count;
>> +     return ret;
>> +}
>> +
>> +static freelist_idx_t next_random_slot(struct freelist_init_state *state)
>> +{
>> +     freelist_idx_t entry;
>> +
>> +     do {
>> +             entry = get_next_entry(state);
>> +     } while ((entry + state->padding) >= state->count);
>> +
>> +     return entry + state->padding;
>> +}
>> +
>> +/*
>> + * Shuffle the freelist initialization state based on pre-computed lists.
>> + * return true if the list was successfully shuffled, false otherwise.
>> + */
>> +static bool shuffle_freelist(struct kmem_cache *cachep, struct page *page)
>> +{
>> +     unsigned int objfreelist, i, count = cachep->num;
>> +     struct freelist_init_state state;
>> +
>> +     if (count < 2)
>> +             return false;
>> +
>> +     objfreelist = 0;
>> +     freelist_state_initialize(&state, cachep, count);
>> +
>> +     /* Take the first random entry as the objfreelist */
>> +     if (OBJFREELIST_SLAB(cachep)) {
>> +             objfreelist = next_random_slot(&state);
>> +             page->freelist = index_to_obj(cachep, page, objfreelist) +
>> +                                             obj_offset(cachep);
>> +             count--;
>> +     }
>> +     for (i = 0; i < count; i++)
>> +             set_free_obj(page, i, next_random_slot(&state));
>> +
>> +     if (OBJFREELIST_SLAB(cachep))
>> +             set_free_obj(page, i, objfreelist);
>> +     return true;
>> +}
>> +#else
>> +static inline bool shuffle_freelist(struct kmem_cache *cachep,
>> +                             struct page *page)
>> +{
>> +     return false;
>> +}
>> +#endif /* CONFIG_FREELIST_RANDOM */
>> +
>>  static void cache_init_objs(struct kmem_cache *cachep,
>>                           struct page *page)
>>  {
>>       int i;
>>       void *objp;
>> +     bool shuffled;
>>
>>       cache_init_objs_debug(cachep, page);
>>
>> -     if (OBJFREELIST_SLAB(cachep)) {
>> +     /* Try to randomize the freelist if enabled */
>> +     shuffled = shuffle_freelist(cachep, page);
>> +
>> +     if (!shuffled && OBJFREELIST_SLAB(cachep)) {
>>               page->freelist = index_to_obj(cachep, page, cachep->num - 1) +
>>                                               obj_offset(cachep);
>>       }
>> @@ -2465,7 +2671,8 @@ static void cache_init_objs(struct kmem_cache *cachep,
>>                       kasan_poison_object_data(cachep, objp);
>>               }
>>
>> -             set_free_obj(page, i, i);
>> +             if (!shuffled)
>> +                     set_free_obj(page, i, i);
>>       }
>>  }
>>
>> @@ -3815,6 +4022,8 @@ static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp)
>>       int shared = 0;
>>       int batchcount = 0;
>>
>> +     cache_random_seq_create(cachep);
>> +
>>       if (!is_root_cache(cachep)) {
>>               struct kmem_cache *root = memcg_root_cache(cachep);
>>               limit = root->limit;
>> --
>> 2.8.0.rc3.226.g39d4020
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
