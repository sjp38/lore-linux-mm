Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 398DF6B025A
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 13:28:16 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id n186so1800781wmn.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:28:16 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id ot8si33375183wjc.161.2016.02.29.10.28.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 10:28:15 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id l68so3377764wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:28:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56D45F67.8050508@gmail.com>
References: <cover.1456504662.git.glider@google.com>
	<5c5a22a3daee19ff5940605b946dc144515ebd63.1456504662.git.glider@google.com>
	<56D45F67.8050508@gmail.com>
Date: Mon, 29 Feb 2016 19:28:14 +0100
Message-ID: <CAG_fn=X29ejm6dBQKhu6i41aY6cf-DCdyL7D8qEwrAKbH+z1+A@mail.gmail.com>
Subject: Re: [PATCH v4 2/7] mm, kasan: SLAB support
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev@googlegroups.com, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Feb 29, 2016 at 4:10 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> w=
rote:
>
>
> On 02/26/2016 07:48 PM, Alexander Potapenko wrote:
>> Add KASAN hooks to SLAB allocator.
>>
>> This patch is based on the "mm: kasan: unified support for SLUB and
>> SLAB allocators" patch originally prepared by Dmitry Chernenkov.
>>
>> Signed-off-by: Alexander Potapenko <glider@google.com>
>> ---
>> v3: - minor description changes
>>     - store deallocation info in kasan_slab_free()
>>
>> v4: - fix kbuild compile-time warnings in print_track()
>> ---
>
>
>> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
>> index bc0a8d8..d26ffb4 100644
>> --- a/mm/kasan/kasan.c
>> +++ b/mm/kasan/kasan.c
>> @@ -314,6 +314,59 @@ void kasan_free_pages(struct page *page, unsigned i=
nt order)
>>                               KASAN_FREE_PAGE);
>>  }
>>
>> +#ifdef CONFIG_SLAB
>> +/*
>> + * Adaptive redzone policy taken from the userspace AddressSanitizer ru=
ntime.
>> + * For larger allocations larger redzones are used.
>> + */
>> +static size_t optimal_redzone(size_t object_size)
>> +{
>> +     int rz =3D
>> +             object_size <=3D 64        - 16   ? 16 :
>> +             object_size <=3D 128       - 32   ? 32 :
>> +             object_size <=3D 512       - 64   ? 64 :
>> +             object_size <=3D 4096      - 128  ? 128 :
>> +             object_size <=3D (1 << 14) - 256  ? 256 :
>> +             object_size <=3D (1 << 15) - 512  ? 512 :
>> +             object_size <=3D (1 << 16) - 1024 ? 1024 : 2048;
>> +     return rz;
>> +}
>> +
>> +void kasan_cache_create(struct kmem_cache *cache, size_t *size,
>> +                     unsigned long *flags)
>> +{
>> +     int redzone_adjust;
>> +     /* Make sure the adjusted size is still less than
>> +      * KMALLOC_MAX_CACHE_SIZE.
>> +      * TODO: this check is only useful for SLAB, but not SLUB. We'll n=
eed
>> +      * to skip it for SLUB when it starts using kasan_cache_create().
>> +      */
>> +     if (*size > KMALLOC_MAX_CACHE_SIZE -
>> +         sizeof(struct kasan_alloc_meta) -
>> +         sizeof(struct kasan_free_meta))
>> +             return;
>> +     *flags |=3D SLAB_KASAN;
>> +     /* Add alloc meta. */
>> +     cache->kasan_info.alloc_meta_offset =3D *size;
>> +     *size +=3D sizeof(struct kasan_alloc_meta);
>> +
>> +     /* Add free meta. */
>> +     if (cache->flags & SLAB_DESTROY_BY_RCU || cache->ctor ||
>> +         cache->object_size < sizeof(struct kasan_free_meta)) {
>> +             cache->kasan_info.free_meta_offset =3D *size;
>> +             *size +=3D sizeof(struct kasan_free_meta);
>> +     }
>> +     redzone_adjust =3D optimal_redzone(cache->object_size) -
>> +             (*size - cache->object_size);
>> +     if (redzone_adjust > 0)
>> +             *size +=3D redzone_adjust;
>> +     *size =3D min(KMALLOC_MAX_CACHE_SIZE,
>> +                 max(*size,
>> +                     cache->object_size +
>> +                     optimal_redzone(cache->object_size)));
>> +}
>> +#endif
>> +
>
>
>
>
>>  void kasan_poison_slab(struct page *page)
>>  {
>>       kasan_poison_shadow(page_address(page),
>> @@ -331,8 +384,36 @@ void kasan_poison_object_data(struct kmem_cache *ca=
che, void *object)
>>       kasan_poison_shadow(object,
>>                       round_up(cache->object_size, KASAN_SHADOW_SCALE_SI=
ZE),
>>                       KASAN_KMALLOC_REDZONE);
>> +#ifdef CONFIG_SLAB
>> +     if (cache->flags & SLAB_KASAN) {
>> +             struct kasan_alloc_meta *alloc_info =3D
>> +                     get_alloc_info(cache, object);
>> +             alloc_info->state =3D KASAN_STATE_INIT;
>> +     }
>> +#endif
>> +}
>> +
>> +static inline void set_track(struct kasan_track *track)
>> +{
>> +     track->cpu =3D raw_smp_processor_id();
>> +     track->pid =3D current->pid;
>> +     track->when =3D jiffies;
>>  }
>>
>> +#ifdef CONFIG_SLAB
>> +struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
>> +                                     const void *object)
>> +{
>> +     return (void *)object + cache->kasan_info.alloc_meta_offset;
>> +}
>> +
>> +struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
>> +                                   const void *object)
>> +{
>> +     return (void *)object + cache->kasan_info.free_meta_offset;
>> +}
>> +#endif
>> +
>>  void kasan_slab_alloc(struct kmem_cache *cache, void *object)
>>  {
>>       kasan_kmalloc(cache, object, cache->object_size);
>> @@ -347,6 +428,17 @@ void kasan_slab_free(struct kmem_cache *cache, void=
 *object)
>>       if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
>>               return;
>>
>> +#ifdef CONFIG_SLAB
>> +     if (cache->flags & SLAB_KASAN) {
>> +             struct kasan_free_meta *free_info =3D
>> +                     get_free_info(cache, object);
>> +             struct kasan_alloc_meta *alloc_info =3D
>> +                     get_alloc_info(cache, object);
>> +             alloc_info->state =3D KASAN_STATE_FREE;
>> +             set_track(&free_info->track);
>> +     }
>> +#endif
>> +
>>       kasan_poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
>>  }
>>
>> @@ -366,6 +458,16 @@ void kasan_kmalloc(struct kmem_cache *cache, const =
void *object, size_t size)
>>       kasan_unpoison_shadow(object, size);
>>       kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_s=
tart,
>>               KASAN_KMALLOC_REDZONE);
>> +#ifdef CONFIG_SLAB
>> +     if (cache->flags & SLAB_KASAN) {
>> +             struct kasan_alloc_meta *alloc_info =3D
>> +                     get_alloc_info(cache, object);
>> +
>> +             alloc_info->state =3D KASAN_STATE_ALLOC;
>> +             alloc_info->alloc_size =3D size;
>> +             set_track(&alloc_info->track);
>> +     }
>> +#endif
>>  }
>>  EXPORT_SYMBOL(kasan_kmalloc);
>>
>> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
>> index 4f6c62e..7b9e4ab9 100644
>> --- a/mm/kasan/kasan.h
>> +++ b/mm/kasan/kasan.h
>> @@ -54,6 +54,40 @@ struct kasan_global {
>>  #endif
>>  };
>>
>> +/**
>> + * Structures to keep alloc and free tracks *
>> + */
>> +
>> +enum kasan_state {
>> +     KASAN_STATE_INIT,
>> +     KASAN_STATE_ALLOC,
>> +     KASAN_STATE_FREE
>> +};
>> +
>> +struct kasan_track {
>> +     u64 cpu : 6;                    /* for NR_CPUS =3D 64 */
>> +     u64 pid : 16;                   /* 65536 processes */
>> +     u64 when : 42;                  /* ~140 years */
>> +};
>> +
>> +struct kasan_alloc_meta {
>> +     u32 state : 2;  /* enum kasan_state */
>> +     u32 alloc_size : 30;
>> +     struct kasan_track track;
>> +};
>> +
>> +struct kasan_free_meta {
>> +     /* Allocator freelist pointer, unused by KASAN. */
>> +     void **freelist;
>> +     struct kasan_track track;
>> +};
>> +
>> +struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
>> +                                     const void *object);
>> +struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
>> +                                     const void *object);
>> +
>> +
>
> Basically, all this big pile of code above is implementation of yet anoth=
er SLAB_STORE_USER and SLAB_RED_ZONE
> exclusively for KASAN. It would be so much better to alter existing code =
to satisfy all you needs.
Thanks for the suggestion, I will take a look.


>>  static inline const void *kasan_shadow_to_mem(const void *shadow_addr)
>>  {
>>       return (void *)(((unsigned long)shadow_addr - KASAN_SHADOW_OFFSET)
>> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
>> index 12f222d..2c1407f 100644
>> --- a/mm/kasan/report.c
>> +++ b/mm/kasan/report.c
>> @@ -115,6 +115,44 @@ static inline bool init_task_stack_addr(const void =
*addr)
>>                       sizeof(init_thread_union.stack));
>>  }
>>
>> +#ifdef CONFIG_SLAB
>> +static void print_track(struct kasan_track *track)
>> +{
>> +     pr_err("PID =3D %u, CPU =3D %u, timestamp =3D %lu\n", track->pid,
>> +            track->cpu, (unsigned long)track->when);
>> +}
>> +
>> +static void print_object(struct kmem_cache *cache, void *object)
>> +{
>> +     struct kasan_alloc_meta *alloc_info =3D get_alloc_info(cache, obje=
ct);
>> +     struct kasan_free_meta *free_info;
>> +
>> +     pr_err("Object at %p, in cache %s\n", object, cache->name);
>> +     if (!(cache->flags & SLAB_KASAN))
>> +             return;
>> +     switch (alloc_info->state) {
>
> '->state' seems useless. It's used only here, but object's state could be=
 determined by shadow value.
>
>> +     case KASAN_STATE_INIT:
>> +             pr_err("Object not allocated yet\n");
>> +             break;
>> +     case KASAN_STATE_ALLOC:
>> +             pr_err("Object allocated with size %u bytes.\n",
>> +                    alloc_info->alloc_size);
>> +             pr_err("Allocation:\n");
>> +             print_track(&alloc_info->track);
>> +             break;
>> +     case KASAN_STATE_FREE:
>> +             pr_err("Object freed, allocated with size %u bytes\n",
>> +                    alloc_info->alloc_size);
>> +             free_info =3D get_free_info(cache, object);
>> +             pr_err("Allocation:\n");
>> +             print_track(&alloc_info->track);
>> +             pr_err("Deallocation:\n");
>> +             print_track(&free_info->track);
>> +             break;
>> +     }
>> +}
>> +#endif
>> +
>>  static void print_address_description(struct kasan_access_info *info)
>>  {
>>       const void *addr =3D info->access_addr;
>> @@ -126,17 +164,14 @@ static void print_address_description(struct kasan=
_access_info *info)
>>               if (PageSlab(page)) {
>>                       void *object;
>>                       struct kmem_cache *cache =3D page->slab_cache;
>> -                     void *last_object;
>> -
>> -                     object =3D virt_to_obj(cache, page_address(page), =
addr);
>> -                     last_object =3D page_address(page) +
>> -                             page->objects * cache->size;
>> -
>> -                     if (unlikely(object > last_object))
>> -                             object =3D last_object; /* we hit into pad=
ding */
>> -
>> +                     object =3D nearest_obj(cache, page,
>> +                                             (void *)info->access_addr)=
;
>> +#ifdef CONFIG_SLAB
>> +                     print_object(cache, object);
>> +#else
>
> Instead of these ifdefs, please, make universal API for printing object's=
 information.
My intention here was to touch the SLUB functionality as little as
possible to avoid the mess and feature regressions.
I'll be happy to refactor the code in the upcoming patches once this
one is landed.

>>                       object_err(cache, page, object,
>> -                             "kasan: bad access detected");
>> +                                     "kasan: bad access detected");
>> +#endif
>>                       return;
>>               }
>>               dump_page(page, "kasan: bad access detected");
>> @@ -146,8 +181,9 @@ static void print_address_description(struct kasan_a=
ccess_info *info)
>>               if (!init_task_stack_addr(addr))
>>                       pr_err("Address belongs to variable %pS\n", addr);
>>       }
>> -
>> +#ifdef CONFIG_SLUB
>
> ???
Not sure what did you mean here, assuming this comment is related to
the next one.
>
>>       dump_stack();
>> +#endif
>>  }
>>
>>  static bool row_is_guilty(const void *row, const void *guilty)
>> @@ -233,6 +269,9 @@ static void kasan_report_error(struct kasan_access_i=
nfo *info)
>>               dump_stack();
>>       } else {
>>               print_error_description(info);
>> +#ifdef CONFIG_SLAB
>
> I'm lost here. What's the point of reordering dump_stack() for CONFIG_SLA=
B=3Dy?
I should have documented this in the patch description properly.
My intention is to make the KASAN reports look more like those in the
userspace AddressSanitizer, so I'm moving the memory access stack to
the top of the report.
Having seen hundreds and hundreds of ASan reports, we believe that
important information must go at the beginning of the error report.
First, people usually do not need to read further once they see the
access stack.
Second, the whole report may simply not make it to the log (e.g. in
the case of a premature shutdown or remote log collection).
As said before, I wasn't going to touch the SLUB output format in this
patch set, but that also needs to be fixed (I'd also remove some
unnecessary info, e.g. the memory dump).

>> +             dump_stack();
>> +#endif
>>               print_address_description(info);
>>               print_shadow_for_address(info->first_bad_addr);
>>       }
>> diff --git a/mm/slab.c b/mm/slab.c
>> index 621fbcb..805b39b 100644
>
>
>
>>
>>       if (gfpflags_allow_blocking(local_flags))
>> @@ -3364,7 +3374,10 @@ free_done:
>>  static inline void __cache_free(struct kmem_cache *cachep, void *objp,
>>                               unsigned long caller)
>>  {
>> -     struct array_cache *ac =3D cpu_cache_get(cachep);
>> +     struct array_cache *ac;
>> +
>> +     kasan_slab_free(cachep, objp);
>> +     ac =3D cpu_cache_get(cachep);
>
> Why cpu_cache_get() was moved? Looks like unnecessary change.

Agreed.

>>
>>       check_irq_off();
>>       kmemleak_free_recursive(objp, cachep->flags);
>> @@ -3403,6 +3416,8 @@ static inline void __cache_free(struct kmem_cache =
*cachep, void *objp,
>>  void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
>>  {
>>       void *ret =3D slab_alloc(cachep, flags, _RET_IP_);
>> +     if (ret)
>
> kasan_slab_alloc() should deal fine with ret =3D=3D NULL.
And it actually does. I'll remove this code in the updated patch set.
>
>> +             kasan_slab_alloc(cachep, ret);
>>
>>       trace_kmem_cache_alloc(_RET_IP_, ret,
>>                              cachep->object_size, cachep->size, flags);



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
Diese E-Mail ist vertraulich. Wenn Sie nicht der richtige Adressat sind,
leiten Sie diese bitte nicht weiter, informieren Sie den
Absender und l=C3=B6schen Sie die E-Mail und alle Anh=C3=A4nge. Vielen Dank=
.
This e-mail is confidential. If you are not the right addressee please
do not forward it, please inform the sender, and please erase this
e-mail including any attachments. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
