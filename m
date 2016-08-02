Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 431C56B0253
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 08:05:28 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id e7so93159414lfe.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 05:05:28 -0700 (PDT)
Received: from mail-lf0-x229.google.com (mail-lf0-x229.google.com. [2a00:1450:4010:c07::229])
        by mx.google.com with ESMTPS id u67si961096lfd.402.2016.08.02.05.05.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 05:05:26 -0700 (PDT)
Received: by mail-lf0-x229.google.com with SMTP id g62so136597278lfe.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 05:05:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=WP2VmNNuzp1YMi+vPLaG9B3JH9TD4FfzxVyeZL2AyM_Q@mail.gmail.com>
References: <1470062715-14077-1-git-send-email-aryabinin@virtuozzo.com>
 <1470062715-14077-6-git-send-email-aryabinin@virtuozzo.com> <CAG_fn=WP2VmNNuzp1YMi+vPLaG9B3JH9TD4FfzxVyeZL2AyM_Q@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 2 Aug 2016 14:05:25 +0200
Message-ID: <CAG_fn=WoeY8EMrmAAeKVL3Cpvko7JOcguURvowxh0L_nbZ6Chg@mail.gmail.com>
Subject: Re: [PATCH 6/6] kasan: improve double-free reports.
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@codemonkey.org.uk>, Vegard Nossum <vegard.nossum@oracle.com>, Sasha Levin <alexander.levin@verizon.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue, Aug 2, 2016 at 1:39 PM, Alexander Potapenko <glider@google.com> wro=
te:
> On Mon, Aug 1, 2016 at 4:45 PM, Andrey Ryabinin <aryabinin@virtuozzo.com>=
 wrote:
>> Currently we just dump stack in case of double free bug.
>> Let's dump all info about the object that we have.
>>
>> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> ---
>>  mm/kasan/kasan.c  |  3 +--
>>  mm/kasan/kasan.h  |  2 ++
>>  mm/kasan/report.c | 54 ++++++++++++++++++++++++++++++++++++++----------=
------
>>  3 files changed, 41 insertions(+), 18 deletions(-)
>>
>> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
>> index 92750e3..88af13c 100644
>> --- a/mm/kasan/kasan.c
>> +++ b/mm/kasan/kasan.c
>> @@ -543,8 +543,7 @@ bool kasan_slab_free(struct kmem_cache *cache, void =
*object)
>>
>>         shadow_byte =3D READ_ONCE(*(s8 *)kasan_mem_to_shadow(object));
>>         if (shadow_byte < 0 || shadow_byte >=3D KASAN_SHADOW_SCALE_SIZE)=
 {
>> -               pr_err("Double free");
>> -               dump_stack();
>> +               kasan_report_double_free(cache, object, shadow_byte);
>>                 return true;
>>         }
>>
>> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
>> index 9b7b31e..e5c2181 100644
>> --- a/mm/kasan/kasan.h
>> +++ b/mm/kasan/kasan.h
>> @@ -99,6 +99,8 @@ static inline bool kasan_report_enabled(void)
>>
>>  void kasan_report(unsigned long addr, size_t size,
>>                 bool is_write, unsigned long ip);
>> +void kasan_report_double_free(struct kmem_cache *cache, void *object,
>> +                       s8 shadow);
>>
>>  #if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
>>  void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *ca=
che);
>> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
>> index f437398..ee2bdb4 100644
>> --- a/mm/kasan/report.c
>> +++ b/mm/kasan/report.c
>> @@ -116,6 +116,26 @@ static inline bool init_task_stack_addr(const void =
*addr)
>>                         sizeof(init_thread_union.stack));
>>  }
>>
>> +static DEFINE_SPINLOCK(report_lock);
>> +
>> +static void kasan_start_report(unsigned long *flags)
>> +{
>> +       /*
>> +        * Make sure we don't end up in loop.
>> +        */
>> +       kasan_disable_current();
>> +       spin_lock_irqsave(&report_lock, *flags);
>> +       pr_err("=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\n");
>> +}
>> +
>> +static void kasan_end_report(unsigned long *flags)
>> +{
>> +       pr_err("=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\n");
>> +       add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
> Don't we want to add the taint as early as possible once we've
> detected the error?
>> +       spin_unlock_irqrestore(&report_lock, *flags);
>> +       kasan_enable_current();
>> +}
>> +
>>  static void print_track(struct kasan_track *track)
>>  {
>>         pr_err("PID =3D %u\n", track->pid);
>> @@ -129,8 +149,7 @@ static void print_track(struct kasan_track *track)
>>         }
>>  }
>>
>> -static void kasan_object_err(struct kmem_cache *cache, struct page *pag=
e,
>> -                               void *object, char *unused_reason)
>> +static void kasan_object_err(struct kmem_cache *cache, void *object)
>>  {
>>         struct kasan_alloc_meta *alloc_info =3D get_alloc_info(cache, ob=
ject);
>>
>> @@ -147,6 +166,18 @@ static void kasan_object_err(struct kmem_cache *cac=
he, struct page *page,
>>         print_track(&alloc_info->free_track);
>>  }
>>
>> +void kasan_report_double_free(struct kmem_cache *cache, void *object,
>> +                       s8 shadow)
>> +{
>> +       unsigned long flags;
>> +
>> +       kasan_start_report(&flags);
>> +       pr_err("BUG: Double free or corrupt pointer\n");
> How about "Double free or freeing an invalid pointer\n"?
> I think "corrupt pointer" doesn't exactly reflect where the bug is.
By the way, I think we could be doing a better job by always detecting
an invalid pointer being passed to kasan_slab_free().
>> +       pr_err("Unexpected shadow byte: 0x%hhX\n", shadow);
>> +       kasan_object_err(cache, object);
>> +       kasan_end_report(&flags);
>> +}
>> +
>>  static void print_address_description(struct kasan_access_info *info)
>>  {
>>         const void *addr =3D info->access_addr;
>> @@ -160,8 +191,7 @@ static void print_address_description(struct kasan_a=
ccess_info *info)
>>                         struct kmem_cache *cache =3D page->slab_cache;
>>                         object =3D nearest_obj(cache, page,
>>                                                 (void *)info->access_add=
r);
>> -                       kasan_object_err(cache, page, object,
>> -                                       "kasan: bad access detected");
>> +                       kasan_object_err(cache, object);
>>                         return;
>>                 }
>>                 dump_page(page, "kasan: bad access detected");
>> @@ -226,19 +256,13 @@ static void print_shadow_for_address(const void *a=
ddr)
>>         }
>>  }
>>
>> -static DEFINE_SPINLOCK(report_lock);
>> -
>>  static void kasan_report_error(struct kasan_access_info *info)
>>  {
>>         unsigned long flags;
>>         const char *bug_type;
>>
>> -       /*
>> -        * Make sure we don't end up in loop.
>> -        */
>> -       kasan_disable_current();
>> -       spin_lock_irqsave(&report_lock, flags);
>> -       pr_err("=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\n");
>> +       kasan_start_report(&flags);
>> +
>>         if (info->access_addr <
>>                         kasan_shadow_to_mem((void *)KASAN_SHADOW_START))=
 {
>>                 if ((unsigned long)info->access_addr < PAGE_SIZE)
>> @@ -259,10 +283,8 @@ static void kasan_report_error(struct kasan_access_=
info *info)
>>                 print_address_description(info);
>>                 print_shadow_for_address(info->first_bad_addr);
>>         }
>> -       pr_err("=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\n");
>> -       add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
>> -       spin_unlock_irqrestore(&report_lock, flags);
>> -       kasan_enable_current();
>> +
>> +       kasan_end_report(&flags);
>>  }
>>
>>  void kasan_report(unsigned long addr, size_t size,
>> --
>> 2.7.3
>>
>
>
>
> --
> Alexander Potapenko
> Software Engineer
>
> Google Germany GmbH
> Erika-Mann-Stra=C3=9Fe, 33
> 80636 M=C3=BCnchen
>
> Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
> Registergericht und -nummer: Hamburg, HRB 86891
> Sitz der Gesellschaft: Hamburg



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
