Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id B1F726B0276
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 10:47:46 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id fn8so103187909igb.1
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 07:47:46 -0700 (PDT)
Received: from mail-ob0-x229.google.com (mail-ob0-x229.google.com. [2607:f8b0:4003:c01::229])
        by mx.google.com with ESMTPS id wa1si26196752oeb.81.2016.04.20.07.47.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 07:47:45 -0700 (PDT)
Received: by mail-ob0-x229.google.com with SMTP id bg3so33055202obb.1
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 07:47:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160420080821.GB7071@js1304-P5Q-DELUXE>
References: <1460999679-30805-1-git-send-email-thgarnie@google.com>
	<20160419071528.GA1624@js1304-P5Q-DELUXE>
	<CAJcbSZEBc9p+HzxtsNpjV=N=vNxAdKWpKLxRxX+KQaboyM+hkw@mail.gmail.com>
	<20160420080821.GB7071@js1304-P5Q-DELUXE>
Date: Wed, 20 Apr 2016 07:47:44 -0700
Message-ID: <CAJcbSZH6Nnw-R4Y34Z16zn=LB1sz=c_PJ2uQoDPJ_TtjTFEyTA@mail.gmail.com>
Subject: Re: [PATCH v2] mm: SLAB freelist randomization
From: Thomas Garnier <thgarnie@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Greg Thelen <gthelen@google.com>, Laura Abbott <labbott@fedoraproject.org>, kernel-hardening@lists.openwall.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Apr 20, 2016 at 1:08 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> On Tue, Apr 19, 2016 at 09:44:54AM -0700, Thomas Garnier wrote:
>> On Tue, Apr 19, 2016 at 12:15 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>> > On Mon, Apr 18, 2016 at 10:14:39AM -0700, Thomas Garnier wrote:
>> >> Provides an optional config (CONFIG_FREELIST_RANDOM) to randomize the
>> >> SLAB freelist. The list is randomized during initialization of a new set
>> >> of pages. The order on different freelist sizes is pre-computed at boot
>> >> for performance. This security feature reduces the predictability of the
>> >> kernel SLAB allocator against heap overflows rendering attacks much less
>> >> stable.
>> >
>> > I'm not familiar on security but it doesn't look much secure than
>> > before. Is there any other way to generate different sequence of freelist
>> > for each new set of pages? Current approach using pre-computed array will
>> > generate same sequence of freelist for all new set of pages having same size
>> > class. Is it sufficient?
>> >
>>
>> I think it is sufficient. There is a tradeoff for performance. We could randomly
>> pick an object from the freelist every time (on slab_get_obj) but I
>> think it will
>> have significant impact (at least 3%).
>>
>> >> For example this attack against SLUB (also applicable against SLAB)
>> >> would be affected:
>> >> https://jon.oberheide.org/blog/2010/09/10/linux-kernel-can-slub-overflow/
>> >>
>> >> Also, since v4.6 the freelist was moved at the end of the SLAB. It means
>> >> a controllable heap is opened to new attacks not yet publicly discussed.
>> >> A kernel heap overflow can be transformed to multiple use-after-free.
>> >> This feature makes this type of attack harder too.
>> >>
>> >> To generate entropy, we use get_random_bytes_arch because 0 bits of
>> >> entropy is available at that boot stage. In the worse case this function
>> >> will fallback to the get_random_bytes sub API.
>> >>
>> >> The config option name is not specific to the SLAB as this approach will
>> >> be extended to other allocators like SLUB.
>> >
>> > If this feature will be applied to the SLUB, it's better to put common
>> > code to mm/slab_common.c.
>> >
>>
>> I think it might be moved there once we implement the SLUB counterpart
>> but it is too early to define which part will be common.
>>
>> >>
>> >> Performance results highlighted no major changes:
>> >>
>> >> Netperf average on 10 runs:
>> >>
>> >> threads,base,change
>> >> 16,576943.10,585905.90 (101.55%)
>> >> 32,564082.00,569741.20 (101.00%)
>> >> 48,558334.30,561851.20 (100.63%)
>> >> 64,552025.20,556448.30 (100.80%)
>> >> 80,552294.40,551743.10 (99.90%)
>> >> 96,552435.30,547529.20 (99.11%)
>> >> 112,551320.60,550183.20 (99.79%)
>> >> 128,549138.30,550542.70 (100.26%)
>> >> 144,549344.50,544529.10 (99.12%)
>> >> 160,550360.80,539929.30 (98.10%)
>> >>
>> >> slab_test 1 run on boot. After is faster except for odd result on size
>> >> 2048.
>> >
>> > Hmm... It's odd result. It adds more logic and it should
>> > decrease performance. I guess it would be experimental error but
>> > do you have any analysis about this result?
>> >
>>
>> I don't. I am glad to redo the test. I found that slab_test has very different
>> result based on the heap state at the time of the test. If I run the
>> test multiple
>> times, I have really various results on with or without the mitigation (on
>> dedicated hardware).
>>
>> >>
>> >> Before:
>> >>
>> >> Single thread testing
>> >> =====================
>> >> 1. Kmalloc: Repeatedly allocate then free test
>> >> 10000 times kmalloc(8) -> 137 cycles kfree -> 126 cycles
>> >> 10000 times kmalloc(16) -> 118 cycles kfree -> 119 cycles
>> >> 10000 times kmalloc(32) -> 112 cycles kfree -> 119 cycles
>> >> 10000 times kmalloc(64) -> 126 cycles kfree -> 123 cycles
>> >> 10000 times kmalloc(128) -> 135 cycles kfree -> 131 cycles
>> >> 10000 times kmalloc(256) -> 165 cycles kfree -> 104 cycles
>> >> 10000 times kmalloc(512) -> 174 cycles kfree -> 126 cycles
>> >> 10000 times kmalloc(1024) -> 242 cycles kfree -> 160 cycles
>> >> 10000 times kmalloc(2048) -> 478 cycles kfree -> 239 cycles
>> >> 10000 times kmalloc(4096) -> 747 cycles kfree -> 364 cycles
>> >> 10000 times kmalloc(8192) -> 774 cycles kfree -> 404 cycles
>> >> 10000 times kmalloc(16384) -> 849 cycles kfree -> 430 cycles
>> >> 2. Kmalloc: alloc/free test
>> >> 10000 times kmalloc(8)/kfree -> 118 cycles
>> >> 10000 times kmalloc(16)/kfree -> 118 cycles
>> >> 10000 times kmalloc(32)/kfree -> 118 cycles
>> >> 10000 times kmalloc(64)/kfree -> 121 cycles
>> >> 10000 times kmalloc(128)/kfree -> 118 cycles
>> >> 10000 times kmalloc(256)/kfree -> 115 cycles
>> >> 10000 times kmalloc(512)/kfree -> 115 cycles
>> >> 10000 times kmalloc(1024)/kfree -> 115 cycles
>> >> 10000 times kmalloc(2048)/kfree -> 115 cycles
>> >> 10000 times kmalloc(4096)/kfree -> 115 cycles
>> >> 10000 times kmalloc(8192)/kfree -> 115 cycles
>> >> 10000 times kmalloc(16384)/kfree -> 115 cycles
>> >>
>> >> After:
>> >>
>> >> Single thread testing
>> >> =====================
>> >> 1. Kmalloc: Repeatedly allocate then free test
>> >> 10000 times kmalloc(8) -> 99 cycles kfree -> 84 cycles
>> >> 10000 times kmalloc(16) -> 88 cycles kfree -> 83 cycles
>> >> 10000 times kmalloc(32) -> 90 cycles kfree -> 81 cycles
>> >> 10000 times kmalloc(64) -> 107 cycles kfree -> 97 cycles
>> >> 10000 times kmalloc(128) -> 134 cycles kfree -> 89 cycles
>> >> 10000 times kmalloc(256) -> 145 cycles kfree -> 97 cycles
>> >> 10000 times kmalloc(512) -> 177 cycles kfree -> 116 cycles
>> >> 10000 times kmalloc(1024) -> 223 cycles kfree -> 151 cycles
>> >> 10000 times kmalloc(2048) -> 1429 cycles kfree -> 221 cycles
>> >> 10000 times kmalloc(4096) -> 720 cycles kfree -> 348 cycles
>> >> 10000 times kmalloc(8192) -> 788 cycles kfree -> 393 cycles
>> >> 10000 times kmalloc(16384) -> 867 cycles kfree -> 433 cycles
>> >> 2. Kmalloc: alloc/free test
>> >> 10000 times kmalloc(8)/kfree -> 115 cycles
>> >> 10000 times kmalloc(16)/kfree -> 115 cycles
>> >> 10000 times kmalloc(32)/kfree -> 115 cycles
>> >> 10000 times kmalloc(64)/kfree -> 120 cycles
>> >> 10000 times kmalloc(128)/kfree -> 127 cycles
>> >> 10000 times kmalloc(256)/kfree -> 119 cycles
>> >> 10000 times kmalloc(512)/kfree -> 112 cycles
>> >> 10000 times kmalloc(1024)/kfree -> 112 cycles
>> >> 10000 times kmalloc(2048)/kfree -> 112 cycles
>> >> 10000 times kmalloc(4096)/kfree -> 112 cycles
>> >> 10000 times kmalloc(8192)/kfree -> 112 cycles
>> >> 10000 times kmalloc(16384)/kfree -> 112 cycles
>> >>
>> >> Signed-off-by: Thomas Garnier <thgarnie@google.com>
>> >> ---
>> >> Based on next-20160418
>> >> ---
>> >>  init/Kconfig |   9 ++++
>> >>  mm/slab.c    | 166 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>> >>  2 files changed, 174 insertions(+), 1 deletion(-)
>> >>
>> >> diff --git a/init/Kconfig b/init/Kconfig
>> >> index 0dfd09d..ee35418 100644
>> >> --- a/init/Kconfig
>> >> +++ b/init/Kconfig
>> >> @@ -1742,6 +1742,15 @@ config SLOB
>> >>
>> >>  endchoice
>> >>
>> >> +config FREELIST_RANDOM
>> >> +     default n
>> >> +     depends on SLAB
>> >> +     bool "SLAB freelist randomization"
>> >> +     help
>> >> +       Randomizes the freelist order used on creating new SLABs. This
>> >> +       security feature reduces the predictability of the kernel slab
>> >> +       allocator against heap overflows.
>> >> +
>> >>  config SLUB_CPU_PARTIAL
>> >>       default y
>> >>       depends on SLUB && SMP
>> >> diff --git a/mm/slab.c b/mm/slab.c
>> >> index b70aabf..8371d80 100644
>> >> --- a/mm/slab.c
>> >> +++ b/mm/slab.c
>> >> @@ -116,6 +116,7 @@
>> >>  #include     <linux/kmemcheck.h>
>> >>  #include     <linux/memory.h>
>> >>  #include     <linux/prefetch.h>
>> >> +#include     <linux/log2.h>
>> >>
>> >>  #include     <net/sock.h>
>> >>
>> >> @@ -1229,6 +1230,62 @@ static void __init set_up_node(struct kmem_cache *cachep, int index)
>> >>       }
>> >>  }
>> >>
>> >> +#ifdef CONFIG_FREELIST_RANDOM
>> >> +/*
>> >> + * Master lists are pre-computed random lists
>> >> + * Lists of different sizes are used to optimize performance on SLABS with
>> >> + * different object counts.
>> >> + */
>> >
>> > If it is for optimization, it would be one option to have separate
>> > random list for each kmem_cache. It would consume more memory but it
>> > would be marginal. And, it provides more un-predictability and it can
>> > give better performance because we don't need state->type (more, less)
>> > and special handling related for it.
>> >
>>
>> I am not sur because major caches are created early at boot time. We still have
>> the same entropy problem and we are wasting a bit more memory. It will be faster
>
> I think that entropy problem is another issue. It should be considered
> separately. If it is solved, making per-computed array for each
> kmem_cache will provide more un-predictability. If someone who succeed to
> exploit some kmem_cache with 128 object per slab want to exploit
> another kmem_cache with 128 object per slab, this separate pre-computed array
> will be helpful.
>
>> on usage though but not sure it will be significant.
>
> I also think it's not significant. But, besides performance effect,
> code doesn't look very attractive and extendable. In case of SLUB,
> there is setup_slub_max_order option and object per slab could be larger
> than 256. To deal with it, we need to add many more static definition
> and it looks not good to me. Please use dynamic allocated memory
> instead of static array definition.
>

You don't need to. We wrap the list used (if you look at get_next_entry
we reset at pos 0 when we arrive to the list size).

I do think that the design will be better with a dedicated list per cache. Given
you seem fine with the memory differences, performance can only get better...

I will refactor for that on the next iteration.

>>
>> >> +static freelist_idx_t master_list_2[2];
>> >> +static freelist_idx_t master_list_4[4];
>> >> +static freelist_idx_t master_list_8[8];
>> >> +static freelist_idx_t master_list_16[16];
>> >> +static freelist_idx_t master_list_32[32];
>> >> +static freelist_idx_t master_list_64[64];
>> >> +static freelist_idx_t master_list_128[128];
>> >> +static freelist_idx_t master_list_256[256];
>> >> +const static struct m_list {
>> >> +     size_t count;
>> >> +     freelist_idx_t *list;
>> >> +} master_lists[] = {
>> >> +     { ARRAY_SIZE(master_list_2), master_list_2 },
>> >> +     { ARRAY_SIZE(master_list_4), master_list_4 },
>> >> +     { ARRAY_SIZE(master_list_8), master_list_8 },
>> >> +     { ARRAY_SIZE(master_list_16), master_list_16 },
>> >> +     { ARRAY_SIZE(master_list_32), master_list_32 },
>> >> +     { ARRAY_SIZE(master_list_64), master_list_64 },
>> >> +     { ARRAY_SIZE(master_list_128), master_list_128 },
>> >> +     { ARRAY_SIZE(master_list_256), master_list_256 },
>> >> +};
>> >> +
>> >> +/* Pre-compute the Freelist master lists at boot */
>> >> +static void __init freelist_random_init(void)
>> >> +{
>> >> +     unsigned int seed;
>> >> +     size_t z, i, rand;
>> >> +     struct rnd_state slab_rand;
>> >> +
>> >> +     get_random_bytes_arch(&seed, sizeof(seed));
>> >> +     prandom_seed_state(&slab_rand, seed);
>> >> +
>> >> +     for (z = 0; z < ARRAY_SIZE(master_lists); z++) {
>> >> +             for (i = 0; i < master_lists[z].count; i++)
>> >> +                     master_lists[z].list[i] = i;
>> >> +
>> >> +             /* Fisher-Yates shuffle */
>> >> +             for (i = master_lists[z].count - 1; i > 0; i--) {
>> >> +                     rand = prandom_u32_state(&slab_rand);
>> >> +                     rand %= (i + 1);
>> >> +                     swap(master_lists[z].list[i],
>> >> +                             master_lists[z].list[rand]);
>> >> +             }
>> >> +     }
>> >> +}
>> >> +#else
>> >> +static inline void __init freelist_random_init(void) { }
>> >> +#endif /* CONFIG_FREELIST_RANDOM */
>> >> +
>> >> +
>> >>  /*
>> >>   * Initialisation.  Called after the page allocator have been initialised and
>> >>   * before smp_init().
>> >> @@ -1255,6 +1312,8 @@ void __init kmem_cache_init(void)
>> >>       if (!slab_max_order_set && totalram_pages > (32 << 20) >> PAGE_SHIFT)
>> >>               slab_max_order = SLAB_MAX_ORDER_HI;
>> >>
>> >> +     freelist_random_init();
>> >> +
>> >>       /* Bootstrap is tricky, because several objects are allocated
>> >>        * from caches that do not exist yet:
>> >>        * 1) initialize the kmem_cache cache: it contains the struct
>> >> @@ -2442,6 +2501,107 @@ static void cache_init_objs_debug(struct kmem_cache *cachep, struct page *page)
>> >>  #endif
>> >>  }
>> >>
>> >> +#ifdef CONFIG_FREELIST_RANDOM
>> >> +/* Identify if the target freelist matches the pre-computed list */
>> >> +enum master_type {
>> >> +     match,
>> >> +     less,
>> >> +     more
>> >> +};
>> >> +
>> >> +/* Hold information during a freelist initialization */
>> >> +struct freelist_init_state {
>> >> +     unsigned int padding;
>> >> +     unsigned int pos;
>> >> +     unsigned int count;
>> >> +     struct m_list master_list;
>> >> +     unsigned int master_count;
>> >> +     enum master_type type;
>> >> +};
>> >> +
>> >> +/* Select the right pre-computed master list and initialize state */
>> >> +static void freelist_state_initialize(struct freelist_init_state *state,
>> >> +                                   unsigned int count)
>> >> +{
>> >> +     unsigned int idx;
>> >> +     const unsigned int last_idx = ARRAY_SIZE(master_lists) - 1;
>> >> +
>> >> +     memset(state, 0, sizeof(*state));
>> >> +     state->count = count;
>> >> +     state->pos = 0;
>> >
>> > Using pos = 0 here looks not good in terms of security. In this case,
>> > every new page having same size class have same sequence of freelist since boot.
>> >
>> > How about using random value to set pos? It provides some more randomness
>> > with minimal overhead.
>> >
>>
>> I think it is a good idea. I will add that for the next iteration.
>>
>> >> +     /* count is always >= 2 */
>> >> +     idx = ilog2(count) - 1;
>> >> +     if (idx >= last_idx)
>> >> +             idx = last_idx;
>> >> +     else if (roundup_pow_of_two(idx + 1) != count)
>> >> +             idx++;
>> >> +     state->master_list = master_lists[idx];
>> >> +     if (state->master_list.count == state->count)
>> >> +             state->type = match;
>> >> +     else if (state->master_list.count > state->count)
>> >> +             state->type = more;
>> >> +     else
>> >> +             state->type = less;
>> >> +}
>> >> +
>> >> +/* Get the next entry on the master list depending on the target list size */
>> >> +static freelist_idx_t get_next_entry(struct freelist_init_state *state)
>> >> +{
>> >> +     if (state->type == less && state->pos == state->master_list.count) {
>> >> +             state->padding += state->pos;
>> >> +             state->pos = 0;
>> >> +     }
>> >> +     BUG_ON(state->pos >= state->master_list.count);
>> >> +     return state->master_list.list[state->pos++];
>> >> +}
>> >> +
>> >> +static freelist_idx_t next_random_slot(struct freelist_init_state *state)
>> >> +{
>> >> +     freelist_idx_t cur, entry;
>> >> +
>> >> +     entry = get_next_entry(state);
>> >> +
>> >> +     if (state->type != match) {
>> >> +             while ((entry + state->padding) >= state->count)
>> >> +                     entry = get_next_entry(state);
>> >> +             cur = entry + state->padding;
>> >> +             BUG_ON(cur >= state->count);
>> >> +     } else {
>> >> +             cur = entry;
>> >> +     }
>> >> +
>> >> +     return cur;
>> >> +}
>> >> +
>> >> +/* Shuffle the freelist initialization state based on pre-computed lists */
>> >> +static void shuffle_freelist(struct kmem_cache *cachep, struct page *page,
>> >> +                          unsigned int count)
>> >> +{
>> >> +     unsigned int i;
>> >> +     struct freelist_init_state state;
>> >> +
>> >> +     if (count < 2) {
>> >> +             for (i = 0; i < count; i++)
>> >> +                     set_free_obj(page, i, i);
>> >> +             return;
>> >> +     }
>> >> +
>> >> +     /* Last chunk is used already in this case */
>> >> +     if (OBJFREELIST_SLAB(cachep))
>> >> +             count--;
>> >> +
>> >> +     freelist_state_initialize(&state, count);
>> >> +     for (i = 0; i < count; i++)
>> >> +             set_free_obj(page, i, next_random_slot(&state));
>> >> +
>> >> +     if (OBJFREELIST_SLAB(cachep))
>> >> +             set_free_obj(page, i, i);
>> >
>> > Please consider last object of OBJFREELIST_SLAB cache, too.
>> >
>> > freelist_state_init()
>> > last_obj = next_randome_slot()
>> > page->freelist = XXX
>> > for (i = 0; i < count - 1; i++)
>> >         set_free_obj()
>> > set_free_obj(last_obj);
>> >
>> > Thanks.
>> >
>>
>> The current implementation take the last chunk by default before the
>> freelist is initialized. Do you want it to be randomized as well?
>
> Yes.
>
> Thanks.
>
>>
>> >> +}
>> >> +#else
>> >> +static inline void shuffle_freelist(struct kmem_cache *cachep,
>> >> +                                 struct page *page, unsigned int count) { }
>> >> +#endif /* CONFIG_FREELIST_RANDOM */
>> >> +
>> >>  static void cache_init_objs(struct kmem_cache *cachep,
>> >>                           struct page *page)
>> >>  {
>> >> @@ -2464,8 +2624,12 @@ static void cache_init_objs(struct kmem_cache *cachep,
>> >>                       kasan_poison_object_data(cachep, objp);
>> >>               }
>> >>
>> >> -             set_free_obj(page, i, i);
>> >> +             /* If enabled, initialization is done in shuffle_freelist */
>> >> +             if (!config_enabled(CONFIG_FREELIST_RANDOM))
>> >> +                     set_free_obj(page, i, i);
>> >>       }
>> >> +
>> >> +     shuffle_freelist(cachep, page, cachep->num);
>> >>  }
>> >>
>> >>  static void kmem_flagcheck(struct kmem_cache *cachep, gfp_t flags)
>> >> --
>> >> 2.8.0.rc3.226.g39d4020
>> >>
>> >> --
>> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> >> the body to majordomo@kvack.org.  For more info on Linux MM,
>> >> see: http://www.linux-mm.org/ .
>> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
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
