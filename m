Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 83B626B0028
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 11:05:42 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id s62so8679912vke.4
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:05:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d46sor144506uah.231.2018.03.13.08.05.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Mar 2018 08:05:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <06a4d0c483fba8babd01fe23727fe4a79482d309.1520017438.git.andreyknvl@google.com>
References: <cover.1520017438.git.andreyknvl@google.com> <06a4d0c483fba8babd01fe23727fe4a79482d309.1520017438.git.andreyknvl@google.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 13 Mar 2018 16:05:37 +0100
Message-ID: <CAG_fn=XjN2zQQrL1r-pv5rMhLgmvOyh8LS9QF0PQ8Y7gk4AVug@mail.gmail.com>
Subject: Re: [RFC PATCH 09/14] khwasan: add hooks implementation
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Fri, Mar 2, 2018 at 8:44 PM, Andrey Konovalov <andreyknvl@google.com> wr=
ote:
> This commit adds KHWASAN hooks implementation.
>
> 1. When a new slab cache is created, KHWASAN rounds up the size of the
>    objects in this cache to KASAN_SHADOW_SCALE_SIZE (=3D=3D 16).
>
> 2. On each kmalloc KHWASAN generates a random tag, sets the shadow memory=
,
>    that corresponds to this object to this tag, and embeds this tag value
>    into the top byte of the returned pointer.
>
> 3. On each kfree KHWASAN poisons the shadow memory with a random tag to
>    allow detection of use-after-free bugs.
>
> The rest of the logic of the hook implementation is very much similar to
> the one provided by KASAN. KHWASAN saves allocation and free stack metada=
ta
> to the slab object the same was KASAN does this.
> ---
>  mm/kasan/khwasan.c | 178 ++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 175 insertions(+), 3 deletions(-)
>
> diff --git a/mm/kasan/khwasan.c b/mm/kasan/khwasan.c
> index 21a2221e3368..09d6f0a72266 100644
> --- a/mm/kasan/khwasan.c
> +++ b/mm/kasan/khwasan.c
> @@ -78,69 +78,238 @@ void *khwasan_reset_tag(void *addr)
>         return reset_tag(addr);
>  }
>
> +void kasan_poison_shadow(const void *address, size_t size, u8 value)
> +{
> +       void *shadow_start, *shadow_end;
> +
> +       /* Perform shadow offset calculation based on untagged address */
> +       address =3D reset_tag((void *)address);
> +
> +       shadow_start =3D kasan_mem_to_shadow(address);
> +       shadow_end =3D kasan_mem_to_shadow(address + size);
> +
> +       memset(shadow_start, value, shadow_end - shadow_start);
> +}
> +
>  void kasan_unpoison_shadow(const void *address, size_t size)
>  {
> +       /* KHWASAN only allows 16-byte granularity */
> +       size =3D round_up(size, KASAN_SHADOW_SCALE_SIZE);
> +       kasan_poison_shadow(address, size, get_tag(address));
>  }
>
>  void check_memory_region(unsigned long addr, size_t size, bool write,
>                                 unsigned long ret_ip)
>  {
> +       u8 tag;
> +       u8 *shadow_first, *shadow_last, *shadow;
> +       void *untagged_addr;
> +
> +       tag =3D get_tag((void *)addr);
> +       untagged_addr =3D reset_tag((void *)addr);
> +       shadow_first =3D (u8 *)kasan_mem_to_shadow(untagged_addr);
> +       shadow_last =3D (u8 *)kasan_mem_to_shadow(untagged_addr + size - =
1);
> +
> +       for (shadow =3D shadow_first; shadow <=3D shadow_last; shadow++) =
{
> +               if (*shadow !=3D tag) {
> +                       /* Report invalid-access bug here */
> +                       return;
> +               }
> +       }
>  }
>
>  void kasan_free_pages(struct page *page, unsigned int order)
>  {
> +       if (likely(!PageHighMem(page)))
> +               kasan_poison_shadow(page_address(page),
> +                               PAGE_SIZE << order,
> +                               khwasan_random_tag());
>  }
>
>  void kasan_cache_create(struct kmem_cache *cache, size_t *size,
>                 slab_flags_t *flags)
>  {
> +       int orig_size =3D *size;
> +
> +       cache->kasan_info.alloc_meta_offset =3D *size;
> +       *size +=3D sizeof(struct kasan_alloc_meta);
> +
> +       if (*size % KASAN_SHADOW_SCALE_SIZE !=3D 0)
> +               *size =3D round_up(*size, KASAN_SHADOW_SCALE_SIZE);
> +
> +
> +       if (*size > KMALLOC_MAX_SIZE) {
> +               *size =3D orig_size;
> +               return;
> +       }
> +
> +       cache->align =3D round_up(cache->align, KASAN_SHADOW_SCALE_SIZE);
> +
> +       *flags |=3D SLAB_KASAN;
>  }
>
>  void kasan_poison_slab(struct page *page)
>  {
> +       kasan_poison_shadow(page_address(page),
> +                       PAGE_SIZE << compound_order(page),
> +                       khwasan_random_tag());
>  }
>
>  void kasan_poison_object_data(struct kmem_cache *cache, void *object)
>  {
> +       kasan_poison_shadow(object,
> +                       round_up(cache->object_size, KASAN_SHADOW_SCALE_S=
IZE),
> +                       khwasan_random_tag());
>  }
>
>  void *kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t fla=
gs)
>  {
> +       if (!READ_ONCE(khwasan_enabled))
> +               return object;
> +       object =3D kasan_kmalloc(cache, object, cache->object_size, flags=
);
> +       if (unlikely(cache->ctor)) {
> +               // Cache constructor might use object's pointer value to
> +               // initialize some of its fields.
> +               cache->ctor(object);
> +       }
>         return object;
>  }
>
> -bool kasan_slab_free(struct kmem_cache *cache, void *object, unsigned lo=
ng ip)
> +static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
> +                               unsigned long ip)
>  {
> +       u8 shadow_byte;
> +       u8 tag;
> +       unsigned long rounded_up_size;
> +       void *untagged_addr =3D reset_tag(object);
> +
> +       if (unlikely(nearest_obj(cache, virt_to_head_page(untagged_addr),
> +                       untagged_addr) !=3D untagged_addr)) {
> +               /* Report invalid-free here */
> +               return true;
> +       }
> +
> +       /* RCU slabs could be legally used after free within the RCU peri=
od */
> +       if (unlikely(cache->flags & SLAB_TYPESAFE_BY_RCU))
> +               return false;
> +
> +       shadow_byte =3D READ_ONCE(*(u8 *)kasan_mem_to_shadow(untagged_add=
r));
> +       tag =3D get_tag(object);
> +       if (tag !=3D shadow_byte) {
> +               /* Report invalid-free here */
> +               return true;
> +       }
> +
> +       rounded_up_size =3D round_up(cache->object_size, KASAN_SHADOW_SCA=
LE_SIZE);
> +       kasan_poison_shadow(object, rounded_up_size, khwasan_random_tag()=
);
> +
> +       if (unlikely(!(cache->flags & SLAB_KASAN)))
> +               return false;
> +
> +       set_track(&get_alloc_info(cache, object)->free_track, GFP_NOWAIT)=
;
>         return false;
>  }
>
> +bool kasan_slab_free(struct kmem_cache *cache, void *object, unsigned lo=
ng ip)
> +{
> +       return __kasan_slab_free(cache, object, ip);
> +}
> +
>  void *kasan_kmalloc(struct kmem_cache *cache, const void *object,
>                         size_t size, gfp_t flags)
>  {
> -       return (void *)object;
> +       unsigned long redzone_start, redzone_end;
> +       u8 tag;
> +
> +       if (!READ_ONCE(khwasan_enabled))
> +               return (void *)object;
> +
> +       if (unlikely(object =3D=3D NULL))
> +               return NULL;
> +
> +       redzone_start =3D round_up((unsigned long)(object + size),
> +                               KASAN_SHADOW_SCALE_SIZE);
> +       redzone_end =3D round_up((unsigned long)(object + cache->object_s=
ize),
> +                               KASAN_SHADOW_SCALE_SIZE);
> +
> +       tag =3D khwasan_random_tag();
> +       kasan_poison_shadow(object, redzone_start - (unsigned long)object=
, tag);
> +       kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_=
start,
> +               khwasan_random_tag());
> +
> +       if (cache->flags & SLAB_KASAN)
> +               set_track(&get_alloc_info(cache, object)->alloc_track, fl=
ags);
> +
> +       return set_tag((void *)object, tag);
>  }
>  EXPORT_SYMBOL(kasan_kmalloc);
>
>  void *kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
>  {
> -       return (void *)ptr;
> +       unsigned long redzone_start, redzone_end;
> +       u8 tag;
> +       struct page *page;
> +
> +       if (!READ_ONCE(khwasan_enabled))
> +               return (void *)ptr;
> +
> +       if (unlikely(ptr =3D=3D NULL))
> +               return NULL;
> +
> +       page =3D virt_to_page(ptr);
> +       redzone_start =3D round_up((unsigned long)(ptr + size),
> +                               KASAN_SHADOW_SCALE_SIZE);
> +       redzone_end =3D (unsigned long)ptr + (PAGE_SIZE << compound_order=
(page));
> +
> +       tag =3D khwasan_random_tag();
> +       kasan_poison_shadow(ptr, redzone_start - (unsigned long)ptr, tag)=
;
> +       kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_=
start,
> +               khwasan_random_tag());
Am I understanding right that the object and the redzone may receive
identical tags here?
Does it make sense to generate the redzone tag from the object tag
(e.g. by addding 1 to it)?
> +       return set_tag((void *)ptr, tag);
>  }
>
>  void kasan_poison_kfree(void *ptr, unsigned long ip)
>  {
> +       struct page *page;
> +
> +       page =3D virt_to_head_page(ptr);
> +
> +       if (unlikely(!PageSlab(page))) {
> +               if (reset_tag(ptr) !=3D page_address(page)) {
> +                       /* Report invalid-free here */
> +                       return;
> +               }
> +               kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page=
),
> +                                       khwasan_random_tag());
> +       } else {
> +               __kasan_slab_free(page->slab_cache, ptr, ip);
> +       }
>  }
>
>  void kasan_kfree_large(void *ptr, unsigned long ip)
>  {
> +       struct page *page =3D virt_to_page(ptr);
> +       struct page *head_page =3D virt_to_head_page(ptr);
> +
> +       if (reset_tag(ptr) !=3D page_address(head_page)) {
> +               /* Report invalid-free here */
> +               return;
> +       }
> +
> +       kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
> +                       khwasan_random_tag());
>  }
>
>  #define DEFINE_HWASAN_LOAD_STORE(size)                                 \
>         void __hwasan_load##size##_noabort(unsigned long addr)          \
>         {                                                               \
> +               check_memory_region(addr, size, false, _RET_IP_);       \
>         }                                                               \
>         EXPORT_SYMBOL(__hwasan_load##size##_noabort);                   \
>         void __hwasan_store##size##_noabort(unsigned long addr)         \
>         {                                                               \
> +               check_memory_region(addr, size, true, _RET_IP_);        \
>         }                                                               \
>         EXPORT_SYMBOL(__hwasan_store##size##_noabort)
>
> @@ -152,15 +321,18 @@ DEFINE_HWASAN_LOAD_STORE(16);
>
>  void __hwasan_loadN_noabort(unsigned long addr, unsigned long size)
>  {
> +       check_memory_region(addr, size, false, _RET_IP_);
>  }
>  EXPORT_SYMBOL(__hwasan_loadN_noabort);
>
>  void __hwasan_storeN_noabort(unsigned long addr, unsigned long size)
>  {
> +       check_memory_region(addr, size, true, _RET_IP_);
>  }
>  EXPORT_SYMBOL(__hwasan_storeN_noabort);
>
>  void __hwasan_tag_memory(unsigned long addr, u8 tag, unsigned long size)
>  {
> +       kasan_poison_shadow((void *)addr, size, tag);
>  }
>  EXPORT_SYMBOL(__hwasan_tag_memory);
> --
> 2.16.2.395.g2e18187dfd-goog
>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
