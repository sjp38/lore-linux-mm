Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id C888A6B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 10:27:43 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l184so527274lfl.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 07:27:43 -0700 (PDT)
Received: from mail-lf0-x231.google.com (mail-lf0-x231.google.com. [2a00:1450:4010:c07::231])
        by mx.google.com with ESMTPS id wx6si14735587lbb.118.2016.06.17.07.27.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 07:27:42 -0700 (PDT)
Received: by mail-lf0-x231.google.com with SMTP id q132so61408598lfe.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 07:27:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5761873A.2020104@virtuozzo.com>
References: <1466004364-57279-1-git-send-email-glider@google.com> <5761873A.2020104@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 17 Jun 2016 16:27:40 +0200
Message-ID: <CAG_fn=X8szV17tk+TBGXbKy881aNBeA=7F48_wD62LHYhjpvnw@mail.gmail.com>
Subject: Re: [PATCH v3] mm, kasan: switch SLUB to stackdepot, enable memory
 quarantine for SLUB
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 15, 2016 at 6:50 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 06/15/2016 06:26 PM, Alexander Potapenko wrote:
>> For KASAN builds:
>>  - switch SLUB allocator to using stackdepot instead of storing the
>>    allocation/deallocation stacks in the objects;
>>  - define SLAB_RED_ZONE, SLAB_POISON, SLAB_STORE_USER to zero,
>>    effectively disabling these debug features, as they're redundant in
>>    the presence of KASAN;
>
> So, why we forbid these? If user wants to set these, why not? If you don'=
t want it, just don't turn them on, that's it.
SLAB_RED_ZONE simply doesn't work with KASAN.
With additional efforts it may work, but I don't think we really need
that. Extra red zones will just bloat the heap, and won't give any
interesting signal except "someone corrupted this object from
non-instrumented code".
SLAB_POISON doesn't crash on simple tests, but I am not sure there are
no corner cases which I haven't checked, so I thought it's safer to
disable it.
As I said before, we can make SLAB_STORE_USER use stackdepot in a
later CL, thus we disable it now.

> And sometimes POISON/REDZONE might be actually useful. KASAN doesn't catc=
h everything,
> e.g. corruption may happen in assembly code, or DMA by  some device.
>
>
>>  - change the freelist hook so that parts of the freelist can be put int=
o
>>    the quarantine.
>>
>> Signed-off-by: Alexander Potapenko <glider@google.com>
>> ---
>
> ...
>
>> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
>> index fb87923..8c75953 100644
>> --- a/mm/kasan/kasan.h
>> +++ b/mm/kasan/kasan.h
>> @@ -110,7 +110,7 @@ static inline bool kasan_report_enabled(void)
>>  void kasan_report(unsigned long addr, size_t size,
>>               bool is_write, unsigned long ip);
>>
>> -#ifdef CONFIG_SLAB
>> +#if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
>>  void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *ca=
che);
>>  void quarantine_reduce(void);
>>  void quarantine_remove_cache(struct kmem_cache *cache);
>> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
>> index 4973505..89259c2 100644
>> --- a/mm/kasan/quarantine.c
>> +++ b/mm/kasan/quarantine.c
>> @@ -149,7 +149,12 @@ static void qlink_free(struct qlist_node *qlink, st=
ruct kmem_cache *cache)
>>
>>       local_irq_save(flags);
>>       alloc_info->state =3D KASAN_STATE_FREE;
>> +#ifdef CONFIG_SLAB
>>       ___cache_free(cache, object, _THIS_IP_);
>> +#elif defined(CONFIG_SLUB)
>> +     do_slab_free(cache, virt_to_head_page(object), object, NULL, 1,
>> +             _RET_IP_);
>> +#endif
>
> Please, add some simple wrapper instead of this.
>
>>       local_irq_restore(flags);
>>  }
>>
Done. I've reused ___cache_free().
>
> ...
>
>> diff --git a/mm/slub.c b/mm/slub.c
>> index 825ff45..f023dd4 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -191,7 +191,11 @@ static inline bool kmem_cache_has_cpu_partial(struc=
t kmem_cache *s)
>>  #define MAX_OBJS_PER_PAGE    32767 /* since page.objects is u15 */
>>
>>  /* Internal SLUB flags */
>> +#ifndef CONFIG_KASAN
>>  #define __OBJECT_POISON              0x80000000UL /* Poison object */
>> +#else
>> +#define __OBJECT_POISON              0x00000000UL /* Disable object poi=
soning */
>> +#endif
>>  #define __CMPXCHG_DOUBLE     0x40000000UL /* Use cmpxchg_double */
>>
>>  #ifdef CONFIG_SMP
>> @@ -454,10 +458,8 @@ static inline void *restore_red_left(struct kmem_ca=
che *s, void *p)
>>   */
>>  #if defined(CONFIG_SLUB_DEBUG_ON)
>>  static int slub_debug =3D DEBUG_DEFAULT_FLAGS;
>> -#elif defined(CONFIG_KASAN)
>> -static int slub_debug =3D SLAB_STORE_USER;
>>  #else
>> -static int slub_debug;
>> +static int slub_debug =3D SLAB_STORE_USER;
>
> Huh! So now it is on!? By default, and for everyone!
>
Good catch, thanks!


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
