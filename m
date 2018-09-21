Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id ACFCC8E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 07:25:45 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id d195-v6so7082130iog.19
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 04:25:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a76-v6sor1986177itc.77.2018.09.21.04.25.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 04:25:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <d74e710797323db0e43f047ea698fbc85060fc57.1537383101.git.andreyknvl@google.com>
References: <cover.1537383101.git.andreyknvl@google.com> <d74e710797323db0e43f047ea698fbc85060fc57.1537383101.git.andreyknvl@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 21 Sep 2018 13:25:22 +0200
Message-ID: <CACT4Y+aoFSySFTd9FzA0xzRYQXSbs-wzX7B67hD3jTGAQEXBOA@mail.gmail.com>
Subject: Re: [PATCH v8 09/20] kasan: preassign tags to objects with ctors or SLAB_TYPESAFE_BY_RCU
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Wed, Sep 19, 2018 at 8:54 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> An object constructor can initialize pointers within this objects based on
> the address of the object. Since the object address might be tagged, we
> need to assign a tag before calling constructor.
>
> The implemented approach is to assign tags to objects with constructors
> when a slab is allocated and call constructors once as usual. The
> downside is that such object would always have the same tag when it is
> reallocated, so we won't catch use-after-frees on it.
>
> Also pressign tags for objects from SLAB_TYPESAFE_BY_RCU caches, since
> they can be validy accessed after having been freed.
>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  mm/slab.c |  2 +-
>  mm/slub.c | 24 ++++++++++++++----------
>  2 files changed, 15 insertions(+), 11 deletions(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index 6fdca9ec2ea4..fe0ddf08aa2c 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2574,7 +2574,7 @@ static void cache_init_objs(struct kmem_cache *cachep,
>
>         for (i = 0; i < cachep->num; i++) {
>                 objp = index_to_obj(cachep, page, i);
> -               kasan_init_slab_obj(cachep, objp);
> +               objp = kasan_init_slab_obj(cachep, objp);
>
>                 /* constructor could break poison info */
>                 if (DEBUG == 0 && cachep->ctor) {
> diff --git a/mm/slub.c b/mm/slub.c
> index c4d5f4442ff1..75fc76e42a1e 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1413,16 +1413,17 @@ static inline bool slab_free_freelist_hook(struct kmem_cache *s,
>  #endif
>  }
>
> -static void setup_object(struct kmem_cache *s, struct page *page,
> +static void *setup_object(struct kmem_cache *s, struct page *page,
>                                 void *object)
>  {
>         setup_object_debug(s, page, object);
> -       kasan_init_slab_obj(s, object);
> +       object = kasan_init_slab_obj(s, object);
>         if (unlikely(s->ctor)) {
>                 kasan_unpoison_object_data(s, object);
>                 s->ctor(object);
>                 kasan_poison_object_data(s, object);
>         }
> +       return object;
>  }
>
>  /*
> @@ -1530,16 +1531,16 @@ static bool shuffle_freelist(struct kmem_cache *s, struct page *page)
>         /* First entry is used as the base of the freelist */
>         cur = next_freelist_entry(s, page, &pos, start, page_limit,
>                                 freelist_count);
> +       cur = setup_object(s, page, cur);
>         page->freelist = cur;
>
>         for (idx = 1; idx < page->objects; idx++) {
> -               setup_object(s, page, cur);
>                 next = next_freelist_entry(s, page, &pos, start, page_limit,
>                         freelist_count);
> +               next = setup_object(s, page, next);
>                 set_freepointer(s, cur, next);
>                 cur = next;
>         }
> -       setup_object(s, page, cur);
>         set_freepointer(s, cur, NULL);
>
>         return true;
> @@ -1561,7 +1562,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>         struct page *page;
>         struct kmem_cache_order_objects oo = s->oo;
>         gfp_t alloc_gfp;
> -       void *start, *p;
> +       void *start, *p, *next;
>         int idx, order;
>         bool shuffle;
>
> @@ -1613,13 +1614,16 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>
>         if (!shuffle) {
>                 for_each_object_idx(p, idx, s, start, page->objects) {
> -                       setup_object(s, page, p);
> -                       if (likely(idx < page->objects))
> -                               set_freepointer(s, p, p + s->size);
> -                       else
> +                       if (likely(idx < page->objects)) {
> +                               next = p + s->size;
> +                               next = setup_object(s, page, next);
> +                               set_freepointer(s, p, next);
> +                       } else
>                                 set_freepointer(s, p, NULL);
>                 }
> -               page->freelist = fixup_red_left(s, start);
> +               start = fixup_red_left(s, start);
> +               start = setup_object(s, page, start);
> +               page->freelist = start;
>         }

Just want to double-check that this is correct.
We now do an additional setup_object call after the loop, but we do 1
less in the loop. So total number of calls should be the same, right?
However, after the loop we call setup_object for the first object (?),
but inside of the loop we skip the call for the last object (?). Am I
missing something, or we call ctor twice for the last object and don't
call it for the first one?


>         page->inuse = page->objects;
> --
> 2.19.0.397.gdd90340f6a-goog
