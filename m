Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 33AAF6B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 06:05:31 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p129so99830075wmp.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 03:05:31 -0700 (PDT)
Received: from mail-lf0-x232.google.com (mail-lf0-x232.google.com. [2a00:1450:4010:c07::232])
        by mx.google.com with ESMTPS id e14si735934lfg.417.2016.08.02.03.05.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 03:05:29 -0700 (PDT)
Received: by mail-lf0-x232.google.com with SMTP id f93so134595111lfi.2
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 03:05:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57A06F23.9080804@virtuozzo.com>
References: <1470063563-96266-1-git-send-email-glider@google.com> <57A06F23.9080804@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 2 Aug 2016 12:05:28 +0200
Message-ID: <CAG_fn=VLfdv3q1s9gauLFyV_z1sLkH-R-Ojp_4UgW=19d68WzQ@mail.gmail.com>
Subject: Re: [PATCH] kasan: avoid overflowing quarantine size on low memory systems
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dmitriy Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue, Aug 2, 2016 at 12:00 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 08/01/2016 05:59 PM, Alexander Potapenko wrote:
>> If the total amount of memory assigned to quarantine is less than the
>> amount of memory assigned to per-cpu quarantines, |new_quarantine_size|
>> may overflow. Instead, set it to zero.
>>
>
> Just curious, how did find this?
> Overflow is possible if system has more than 32 cpus per GB of memory. AF=
IAK this quite unusual.
We were just reading the quarantine code, and Dmitry spotted the problem.
I agree this is quite unusual, but we'd better prevent this case.

>> Reported-by: Dmitry Vyukov <dvyukov@google.com>
>> Fixes: 55834c59098d ("mm: kasan: initial memory quarantine
>> implementation")
>> Signed-off-by: Alexander Potapenko <glider@google.com>
>> ---
>>  mm/kasan/quarantine.c | 12 ++++++++++--
>>  1 file changed, 10 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
>> index 65793f1..416d3b0 100644
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
>> @@ -214,7 +214,15 @@ void quarantine_reduce(void)
>>        */
>>       new_quarantine_size =3D (READ_ONCE(totalram_pages) << PAGE_SHIFT) =
/
>>               QUARANTINE_FRACTION;
>> -     new_quarantine_size -=3D QUARANTINE_PERCPU_SIZE * num_online_cpus(=
);
>> +     percpu_quarantines =3D QUARANTINE_PERCPU_SIZE * num_online_cpus();
>> +     if (new_quarantine_size < percpu_quarantines) {
>> +             WARN_ONCE(1,
>> +                     "Too little memory, disabling global KASAN quarant=
ine.\n",
>> +             );
>
> Why WARN? I'd suggest pr_warn_once();
Agreed. I'll send the updated patch.
(Sorry, Andrew, I'll have to get back to the non-tidy version then, as
pr_warn_once() doesn't return the predicate value)
>> +             new_quarantine_size =3D 0;
>> +     } else {
>> +             new_quarantine_size -=3D percpu_quarantines;
>> +     }
>>       WRITE_ONCE(quarantine_size, new_quarantine_size);
>>
>>       last =3D global_quarantine.head;
>>



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
