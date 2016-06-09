Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 08A966B0005
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 11:20:43 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c82so23706372wme.2
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 08:20:42 -0700 (PDT)
Received: from mail-lf0-x234.google.com (mail-lf0-x234.google.com. [2a00:1450:4010:c07::234])
        by mx.google.com with ESMTPS id f68si4256085lfi.200.2016.06.09.08.20.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 08:20:41 -0700 (PDT)
Received: by mail-lf0-x234.google.com with SMTP id f6so7685786lfg.0
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 08:20:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <575977C3.1010905@virtuozzo.com>
References: <1464785606-20349-1-git-send-email-glider@google.com>
 <574F0BB6.1040400@virtuozzo.com> <575977C3.1010905@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Thu, 9 Jun 2016 17:20:40 +0200
Message-ID: <CAG_fn=X5PkkOH3iPfS6kavo-PJmTfq8jMxCRdM9hbd+eWj+paA@mail.gmail.com>
Subject: Re: [PATCH] mm: mempool: kasan: don't poot mempool objects in quarantine
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 9, 2016 at 4:05 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> w=
rote:
> On 06/01/2016 07:22 PM, Andrey Ryabinin wrote:
>>
>>
>> On 06/01/2016 03:53 PM, Alexander Potapenko wrote:
>>> To avoid draining the mempools, KASAN shouldn't put the mempool element=
s
>>> into the quarantine upon mempool_free().
>>
>> Correct, but unfortunately this patch doesn't fix that.
>>
>
> So, I made this:
You beat me to it :)
Thanks!
>
>
> From: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Subject: [PATCH] mm: mempool: kasan: don't poot mempool objects in quaran=
tine
>
> Currently we may put reserved by mempool elements into quarantine
> via kasan_kfree(). This is totally wrong since quarantine may really
> free these objects. So when mempool will try to use such element,
> use-after-free will happen. Or mempool may decide that it no longer
> need that element and double-free it.
>
> So don't put object into quarantine in kasan_kfree(), just poison it.
> Rename kasan_kfree() to kasan_poison_kfree() to respect that.
>
> Also, we shouldn't use kasan_slab_alloc()/kasan_krealloc() in
> kasan_unpoison_element() because those functions may update allocation
> stacktrace. This would be wrong for the most of the remove_element
> call sites.
>
> (The only call site where we may want to update alloc stacktrace is
>  in mempool_alloc(). Kmemleak solves this by calling
>  kmemleak_update_trace(), so we could make something like that too.
>  But this is out of scope of this patch).
>
> Fixes: 55834c59098d ("mm: kasan: initial memory quarantine implementation=
")
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Reported-by: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
Acked-by: Alexander Potapenko <glider@google.com>
> ---
>  include/linux/kasan.h | 11 +++++++----
>  mm/kasan/kasan.c      |  6 +++---
>  mm/mempool.c          | 12 ++++--------
>  3 files changed, 14 insertions(+), 15 deletions(-)
>
> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> index 611927f..ac4b3c4 100644
> --- a/include/linux/kasan.h
> +++ b/include/linux/kasan.h
> @@ -59,14 +59,13 @@ void kasan_poison_object_data(struct kmem_cache *cach=
e, void *object);
>
>  void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags);
>  void kasan_kfree_large(const void *ptr);
> -void kasan_kfree(void *ptr);
> +void kasan_poison_kfree(void *ptr);
>  void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size=
,
>                   gfp_t flags);
>  void kasan_krealloc(const void *object, size_t new_size, gfp_t flags);
>
>  void kasan_slab_alloc(struct kmem_cache *s, void *object, gfp_t flags);
>  bool kasan_slab_free(struct kmem_cache *s, void *object);
> -void kasan_poison_slab_free(struct kmem_cache *s, void *object);
>
>  struct kasan_cache {
>         int alloc_meta_offset;
> @@ -76,6 +75,9 @@ struct kasan_cache {
>  int kasan_module_alloc(void *addr, size_t size);
>  void kasan_free_shadow(const struct vm_struct *vm);
>
> +size_t ksize(const void *);
> +static inline void kasan_unpoison_slab(const void *ptr) { ksize(ptr); }
> +
>  #else /* CONFIG_KASAN */
>
>  static inline void kasan_unpoison_shadow(const void *address, size_t siz=
e) {}
> @@ -102,7 +104,7 @@ static inline void kasan_poison_object_data(struct km=
em_cache *cache,
>
>  static inline void kasan_kmalloc_large(void *ptr, size_t size, gfp_t fla=
gs) {}
>  static inline void kasan_kfree_large(const void *ptr) {}
> -static inline void kasan_kfree(void *ptr) {}
> +static inline void kasan_poison_kfree(void *ptr) {}
>  static inline void kasan_kmalloc(struct kmem_cache *s, const void *objec=
t,
>                                 size_t size, gfp_t flags) {}
>  static inline void kasan_krealloc(const void *object, size_t new_size,
> @@ -114,11 +116,12 @@ static inline bool kasan_slab_free(struct kmem_cach=
e *s, void *object)
>  {
>         return false;
>  }
> -static inline void kasan_poison_slab_free(struct kmem_cache *s, void *ob=
ject) {}
>
>  static inline int kasan_module_alloc(void *addr, size_t size) { return 0=
; }
>  static inline void kasan_free_shadow(const struct vm_struct *vm) {}
>
> +static inline void kasan_unpoison_slab(const void *ptr) { }
> +
>  #endif /* CONFIG_KASAN */
>
>  #endif /* LINUX_KASAN_H */
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 28439ac..6845f92 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -508,7 +508,7 @@ void kasan_slab_alloc(struct kmem_cache *cache, void =
*object, gfp_t flags)
>         kasan_kmalloc(cache, object, cache->object_size, flags);
>  }
>
> -void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
> +static void kasan_poison_slab_free(struct kmem_cache *cache, void *objec=
t)
>  {
>         unsigned long size =3D cache->object_size;
>         unsigned long rounded_up_size =3D round_up(size, KASAN_SHADOW_SCA=
LE_SIZE);
> @@ -626,7 +626,7 @@ void kasan_krealloc(const void *object, size_t size, =
gfp_t flags)
>                 kasan_kmalloc(page->slab_cache, object, size, flags);
>  }
>
> -void kasan_kfree(void *ptr)
> +void kasan_poison_kfree(void *ptr)
>  {
>         struct page *page;
>
> @@ -636,7 +636,7 @@ void kasan_kfree(void *ptr)
>                 kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page=
),
>                                 KASAN_FREE_PAGE);
>         else
> -               kasan_slab_free(page->slab_cache, ptr);
> +               kasan_poison_slab_free(page->slab_cache, ptr);
>  }
>
>  void kasan_kfree_large(const void *ptr)
> diff --git a/mm/mempool.c b/mm/mempool.c
> index 9e075f8..8f65464 100644
> --- a/mm/mempool.c
> +++ b/mm/mempool.c
> @@ -104,20 +104,16 @@ static inline void poison_element(mempool_t *pool, =
void *element)
>
>  static void kasan_poison_element(mempool_t *pool, void *element)
>  {
> -       if (pool->alloc =3D=3D mempool_alloc_slab)
> -               kasan_poison_slab_free(pool->pool_data, element);
> -       if (pool->alloc =3D=3D mempool_kmalloc)
> -               kasan_kfree(element);
> +       if (pool->alloc =3D=3D mempool_alloc_slab || pool->alloc =3D=3D m=
empool_kmalloc)
> +               kasan_poison_kfree(element);
>         if (pool->alloc =3D=3D mempool_alloc_pages)
>                 kasan_free_pages(element, (unsigned long)pool->pool_data)=
;
>  }
>
>  static void kasan_unpoison_element(mempool_t *pool, void *element, gfp_t=
 flags)
>  {
> -       if (pool->alloc =3D=3D mempool_alloc_slab)
> -               kasan_slab_alloc(pool->pool_data, element, flags);
> -       if (pool->alloc =3D=3D mempool_kmalloc)
> -               kasan_krealloc(element, (size_t)pool->pool_data, flags);
> +       if (pool->alloc =3D=3D mempool_alloc_slab || pool->alloc =3D=3D m=
empool_kmalloc)
> +               kasan_unpoison_slab(element);
>         if (pool->alloc =3D=3D mempool_alloc_pages)
>                 kasan_alloc_pages(element, (unsigned long)pool->pool_data=
);
>  }
> --
> 2.7.3
>
>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
