Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6E6976B0005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 09:42:23 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 1so9789145wmz.2
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 06:42:23 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id f133si3024370wmf.85.2016.08.11.06.42.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Aug 2016 06:42:22 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id f65so1057650wmi.0
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 06:42:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160810155015.bffc044a171466b2fdf5195e@linux-foundation.org>
References: <1470133620-28683-1-git-send-email-glider@google.com> <20160810155015.bffc044a171466b2fdf5195e@linux-foundation.org>
From: Alexander Potapenko <glider@google.com>
Date: Thu, 11 Aug 2016 15:42:20 +0200
Message-ID: <CAG_fn=UW0bszthjs9_8vKZOX9nCaD9gvz-7A=x8=CBf=GTDxMA@mail.gmail.com>
Subject: Re: [PATCH v2] kasan: avoid overflowing quarantine size on low memory systems
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitriy Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Aug 11, 2016 at 12:50 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue,  2 Aug 2016 12:27:00 +0200 Alexander Potapenko <glider@google.com=
> wrote:
>
>> If the total amount of memory assigned to quarantine is less than the
>> amount of memory assigned to per-cpu quarantines, |new_quarantine_size|
>> may overflow. Instead, set it to zero.
>>
>> ...
>>
>> --- a/mm/kasan/quarantine.c
>> +++ b/mm/kasan/quarantine.c
>> @@ -196,7 +196,7 @@ void quarantine_put(struct kasan_free_meta *info, st=
ruct kmem_cache *cache)
>>
>>  void quarantine_reduce(void)
>>  {
>> -     size_t new_quarantine_size;
>> +     size_t new_quarantine_size, percpu_quarantines;
>>       unsigned long flags;
>>       struct qlist_head to_free =3D QLIST_INIT;
>>       size_t size_to_free =3D 0;
>> @@ -214,7 +214,9 @@ void quarantine_reduce(void)
>>        */
>>       new_quarantine_size =3D (READ_ONCE(totalram_pages) << PAGE_SHIFT) =
/
>>               QUARANTINE_FRACTION;
>> -     new_quarantine_size -=3D QUARANTINE_PERCPU_SIZE * num_online_cpus(=
);
>> +     percpu_quarantines =3D QUARANTINE_PERCPU_SIZE * num_online_cpus();
>> +     new_quarantine_size =3D (new_quarantine_size < percpu_quarantines)=
 ?
>> +             0 : new_quarantine_size - percpu_quarantines;
>>       WRITE_ONCE(quarantine_size, new_quarantine_size);
>>
>>       last =3D global_quarantine.head;
>
> Confused.  Which kernel version is this supposed to apply to?
This is the second version of the patch which should've been applied
to the mainline instead of v1.
But since v1 has already hit upstream, this patch makes sense no more.
If WARN_ONCE (which is currently present in this code) is a big deal,
I can send a new patch that removes it.


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
