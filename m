Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 429776B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 06:07:11 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id e7so91122405lfe.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 03:07:11 -0700 (PDT)
Received: from mail-lf0-x231.google.com (mail-lf0-x231.google.com. [2a00:1450:4010:c07::231])
        by mx.google.com with ESMTPS id 8si749300lfe.212.2016.08.02.03.07.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 03:07:10 -0700 (PDT)
Received: by mail-lf0-x231.google.com with SMTP id g62so134462595lfe.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 03:07:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+ad6ZY=1=kM0FGZD8LtOaupV4c0AW0mXjMoxMNRsH2omA@mail.gmail.com>
References: <1470063563-96266-1-git-send-email-glider@google.com>
 <57A06F23.9080804@virtuozzo.com> <CACT4Y+ad6ZY=1=kM0FGZD8LtOaupV4c0AW0mXjMoxMNRsH2omA@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 2 Aug 2016 12:07:08 +0200
Message-ID: <CAG_fn=X2zahG9enAdSPxwqC-VV6nwK2PhuAXPyhOvASnXok9JQ@mail.gmail.com>
Subject: Re: [PATCH] kasan: avoid overflowing quarantine size on low memory systems
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Kostya Serebryany <kcc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Aug 2, 2016 at 12:05 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Tue, Aug 2, 2016 at 12:00 PM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
>>
>>
>> On 08/01/2016 05:59 PM, Alexander Potapenko wrote:
>>> If the total amount of memory assigned to quarantine is less than the
>>> amount of memory assigned to per-cpu quarantines, |new_quarantine_size|
>>> may overflow. Instead, set it to zero.
>>>
>>
>> Just curious, how did find this?
>> Overflow is possible if system has more than 32 cpus per GB of memory. A=
FIAK this quite unusual.
>
> I was reading code for unrelated reason.
>
>>> Reported-by: Dmitry Vyukov <dvyukov@google.com>
>>> Fixes: 55834c59098d ("mm: kasan: initial memory quarantine
>>> implementation")
>>> Signed-off-by: Alexander Potapenko <glider@google.com>
>>> ---
>>>  mm/kasan/quarantine.c | 12 ++++++++++--
>>>  1 file changed, 10 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
>>> index 65793f1..416d3b0 100644
>>> --- a/mm/kasan/quarantine.c
>>> +++ b/mm/kasan/quarantine.c
>>> @@ -196,7 +196,7 @@ void quarantine_put(struct kasan_free_meta *info, s=
truct kmem_cache *cache)
>>>
>>>  void quarantine_reduce(void)
>>>  {
>>> -     size_t new_quarantine_size;
>>> +     size_t new_quarantine_size, percpu_quarantines;
>>>       unsigned long flags;
>>>       struct qlist_head to_free =3D QLIST_INIT;
>>>       size_t size_to_free =3D 0;
>>> @@ -214,7 +214,15 @@ void quarantine_reduce(void)
>>>        */
>>>       new_quarantine_size =3D (READ_ONCE(totalram_pages) << PAGE_SHIFT)=
 /
>>>               QUARANTINE_FRACTION;
>>> -     new_quarantine_size -=3D QUARANTINE_PERCPU_SIZE * num_online_cpus=
();
>>> +     percpu_quarantines =3D QUARANTINE_PERCPU_SIZE * num_online_cpus()=
;
>>> +     if (new_quarantine_size < percpu_quarantines) {
>>> +             WARN_ONCE(1,
>>> +                     "Too little memory, disabling global KASAN quaran=
tine.\n",
>>> +             );
>>
>> Why WARN? I'd suggest pr_warn_once();
>
>
> I would suggest to just do something useful. Setting quarantine
> new_quarantine_size to 0 looks fine.
> What would user do with this warning? Number of CPUs and amount of
> memory are generally fixed. Why is it an issue for end user at all? We
> still have some quarantine per-cpu. A WARNING means a [non-critical]
> kernel bug. E.g. syzkaller will catch each and every boot of such
> system as a bug.
How about printk_once then?
Silently setting the quarantine size to zero may puzzle the user.
>
>>> +             new_quarantine_size =3D 0;
>>> +     } else {
>>> +             new_quarantine_size -=3D percpu_quarantines;
>>> +     }
>>>       WRITE_ONCE(quarantine_size, new_quarantine_size);
>>>
>>>       last =3D global_quarantine.head;
>>>



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
