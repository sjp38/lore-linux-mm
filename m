Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id F2AFB8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 12:31:54 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 20-v6so4286403itb.7
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 09:31:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u8-v6sor981675iod.180.2018.09.12.09.22.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Sep 2018 09:22:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <6cd298a90d02068969713f2fd440eae21227467b.1535462971.git.andreyknvl@google.com>
References: <cover.1535462971.git.andreyknvl@google.com> <6cd298a90d02068969713f2fd440eae21227467b.1535462971.git.andreyknvl@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 12 Sep 2018 18:21:38 +0200
Message-ID: <CACT4Y+adO3n4Nb4XOPyXdt43DbYjb=Kz6__tPTmb1CX=00qNSQ@mail.gmail.com>
Subject: Re: [PATCH v6 07/18] khwasan: add tag related helper functions
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Wed, Aug 29, 2018 at 1:35 PM, Andrey Konovalov <andreyknvl@google.com> w=
rote:
> This commit adds a few helper functions, that are meant to be used to
> work with tags embedded in the top byte of kernel pointers: to set, to
> get or to reset (set to 0xff) the top byte.
>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  arch/arm64/mm/kasan_init.c |  2 ++
>  include/linux/kasan.h      | 29 +++++++++++++++++
>  mm/kasan/kasan.h           | 55 ++++++++++++++++++++++++++++++++
>  mm/kasan/khwasan.c         | 65 ++++++++++++++++++++++++++++++++++++++
>  4 files changed, 151 insertions(+)
>
> diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
> index 7a31e8ccbad2..e7f37c0b7e14 100644
> --- a/arch/arm64/mm/kasan_init.c
> +++ b/arch/arm64/mm/kasan_init.c
> @@ -250,6 +250,8 @@ void __init kasan_init(void)
>         memset(kasan_zero_page, KASAN_SHADOW_INIT, PAGE_SIZE);
>         cpu_replace_ttbr1(lm_alias(swapper_pg_dir));
>
> +       khwasan_init();
> +
>         /* At this point kasan is fully initialized. Enable error message=
s */
>         init_task.kasan_depth =3D 0;
>         pr_info("KernelAddressSanitizer initialized\n");
> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> index 1c31bb089154..1f852244e739 100644
> --- a/include/linux/kasan.h
> +++ b/include/linux/kasan.h
> @@ -166,6 +166,35 @@ static inline void kasan_cache_shutdown(struct kmem_=
cache *cache) {}
>
>  #define KASAN_SHADOW_INIT 0xFF
>
> +void khwasan_init(void);
> +
> +void *khwasan_reset_tag(const void *addr);
> +
> +void *khwasan_preset_slub_tag(struct kmem_cache *cache, const void *addr=
);
> +void *khwasan_preset_slab_tag(struct kmem_cache *cache, unsigned int idx=
,
> +                                       const void *addr);
> +
> +#else /* CONFIG_KASAN_HW */
> +
> +static inline void khwasan_init(void) { }
> +
> +static inline void *khwasan_reset_tag(const void *addr)
> +{
> +       return (void *)addr;
> +}
> +
> +static inline void *khwasan_preset_slub_tag(struct kmem_cache *cache,
> +                                               const void *addr)
> +{
> +       return (void *)addr;
> +}
> +
> +static inline void *khwasan_preset_slab_tag(struct kmem_cache *cache,
> +                                       unsigned int idx, const void *add=
r)
> +{
> +       return (void *)addr;
> +}
> +
>  #endif /* CONFIG_KASAN_HW */
>
>  #endif /* LINUX_KASAN_H */
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index 19b950eaccff..a7cc27d96608 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -8,6 +8,10 @@
>  #define KASAN_SHADOW_SCALE_SIZE (1UL << KASAN_SHADOW_SCALE_SHIFT)
>  #define KASAN_SHADOW_MASK       (KASAN_SHADOW_SCALE_SIZE - 1)
>
> +#define KHWASAN_TAG_KERNEL     0xFF /* native kernel pointers tag */
> +#define KHWASAN_TAG_INVALID    0xFE /* inaccessible memory tag */
> +#define KHWASAN_TAG_MAX                0xFD /* maximum value for random =
tags */
> +
>  #define KASAN_FREE_PAGE         0xFF  /* page was freed */
>  #define KASAN_PAGE_REDZONE      0xFE  /* redzone for kmalloc_large alloc=
ations */
>  #define KASAN_KMALLOC_REDZONE   0xFC  /* redzone inside slub object */
> @@ -126,6 +130,57 @@ static inline void quarantine_reduce(void) { }
>  static inline void quarantine_remove_cache(struct kmem_cache *cache) { }
>  #endif
>
> +#ifdef CONFIG_KASAN_HW
> +
> +#define KHWASAN_TAG_SHIFT 56
> +#define KHWASAN_TAG_MASK (0xFFUL << KHWASAN_TAG_SHIFT)
> +
> +u8 random_tag(void);
> +
> +static inline void *set_tag(const void *addr, u8 tag)
> +{
> +       u64 a =3D (u64)addr;
> +
> +       a &=3D ~KHWASAN_TAG_MASK;
> +       a |=3D ((u64)tag << KHWASAN_TAG_SHIFT);
> +
> +       return (void *)a;
> +}
> +
> +static inline u8 get_tag(const void *addr)
> +{
> +       return (u8)((u64)addr >> KHWASAN_TAG_SHIFT);
> +}
> +
> +static inline void *reset_tag(const void *addr)
> +{
> +       return set_tag(addr, KHWASAN_TAG_KERNEL);
> +}
> +
> +#else /* CONFIG_KASAN_HW */
> +
> +static inline u8 random_tag(void)
> +{
> +       return 0;
> +}
> +
> +static inline void *set_tag(const void *addr, u8 tag)
> +{
> +       return (void *)addr;
> +}
> +
> +static inline u8 get_tag(const void *addr)
> +{
> +       return 0;
> +}
> +
> +static inline void *reset_tag(const void *addr)
> +{
> +       return (void *)addr;
> +}
> +
> +#endif /* CONFIG_KASAN_HW */
> +
>  /*
>   * Exported functions for interfaces called from assembly or from genera=
ted
>   * code. Declarations here to avoid warning about missing declarations.
> diff --git a/mm/kasan/khwasan.c b/mm/kasan/khwasan.c
> index e2c3a7f7fd1f..9d91bf3c8246 100644
> --- a/mm/kasan/khwasan.c
> +++ b/mm/kasan/khwasan.c
> @@ -38,6 +38,71 @@
>  #include "kasan.h"
>  #include "../slab.h"
>
> +static DEFINE_PER_CPU(u32, prng_state);
> +
> +void khwasan_init(void)
> +{
> +       int cpu;
> +
> +       for_each_possible_cpu(cpu)
> +               per_cpu(prng_state, cpu) =3D get_random_u32();
> +}
> +
> +/*
> + * If a preemption happens between this_cpu_read and this_cpu_write, the=
 only
> + * side effect is that we'll give a few allocated in different contexts =
objects
> + * the same tag. Since KHWASAN is meant to be used a probabilistic bug-d=
etection
> + * debug feature, this doesn=E2=80=99t have significant negative impact.
> + *
> + * Ideally the tags use strong randomness to prevent any attempts to pre=
dict
> + * them during explicit exploit attempts. But strong randomness is expen=
sive,
> + * and we did an intentional trade-off to use a PRNG. This non-atomic RM=
W
> + * sequence has in fact positive effect, since interrupts that randomly =
skew
> + * PRNG at unpredictable points do only good.
> + */
> +u8 random_tag(void)
> +{
> +       u32 state =3D this_cpu_read(prng_state);
> +
> +       state =3D 1664525 * state + 1013904223;
> +       this_cpu_write(prng_state, state);
> +
> +       return (u8)(state % (KHWASAN_TAG_MAX + 1));
> +}
> +
> +void *khwasan_reset_tag(const void *addr)
> +{
> +       return reset_tag(addr);
> +}
> +
> +void *khwasan_preset_slub_tag(struct kmem_cache *cache, const void *addr=
)

Can't we do this in the existing kasan_init_slab_obj() hook? It looks
like it should do exactly this -- allow any one-time initialization
for objects. We could extend it to accept index and return a new
pointer.
If that does not work for some reason, I would try to at least unify
the hook for slab/slub, e.g. pass idx=3D-1 from slub and then use
random_tag().
It also seems that we do preset tag for slab multiple times (from
slab_get_obj()). Using kasan_init_slab_obj() should resolve this too
(hopefully we don't call it multiple times).


> +{
> +       /*
> +        * Since it's desirable to only call object contructors ones duri=
ng
> +        * slab allocation, we preassign tags to all such objects.
> +        * Also preassign tags for SLAB_TYPESAFE_BY_RCU slabs to avoid
> +        * use-after-free reports.
> +        */
> +       if (cache->ctor || cache->flags & SLAB_TYPESAFE_BY_RCU)
> +               return set_tag(addr, random_tag());
> +       return (void *)addr;
> +}
> +
> +void *khwasan_preset_slab_tag(struct kmem_cache *cache, unsigned int idx=
,
> +                               const void *addr)
> +{
> +       /*
> +        * See comment in khwasan_preset_slub_tag.
> +        * For SLAB allocator we can't preassign tags randomly since the
> +        * freelist is stored as an array of indexes instead of a linked
> +        * list. Assign tags based on objects indexes, so that objects th=
at
> +        * are next to each other get different tags.
> +        */
> +       if (cache->ctor || cache->flags & SLAB_TYPESAFE_BY_RCU)
> +               return set_tag(addr, (u8)idx);
> +       return (void *)addr;
> +}
> +
>  void check_memory_region(unsigned long addr, size_t size, bool write,
>                                 unsigned long ret_ip)
>  {
> --
> 2.19.0.rc0.228.g281dcd1b4d0-goog
>
