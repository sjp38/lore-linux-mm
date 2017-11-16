Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 935134402ED
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 11:29:45 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id w186so13111165vkf.10
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 08:29:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d46sor526557uae.215.2017.11.16.08.29.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 Nov 2017 08:29:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <6f3b8fd2-d2c7-a37d-f79d-510e6cdf2ee9@virtuozzo.com>
References: <20171115173445.37236-1-glider@google.com> <6f3b8fd2-d2c7-a37d-f79d-510e6cdf2ee9@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Thu, 16 Nov 2017 17:29:41 +0100
Message-ID: <CAG_fn=XK7-AsfipM-y79HX73XAan8VyzacijU0S7Dbe2W8HG8g@mail.gmail.com>
Subject: Re: [PATCH] lib/stackdepot: use a non-instrumented version of memcmp()
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Nov 16, 2017 at 4:08 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 11/15/2017 08:34 PM, Alexander Potapenko wrote:
>> stackdepot used to call memcmp(), which compiler tools normally
>> instrument, therefore every lookup used to unnecessarily call
>> instrumented code.
>> This is somewhat ok in the case of KASAN, but under KMSAN a lot of time
>> was spent in the instrumentation.
>>
>> Signed-off-by: Alexander Potapenko <glider@google.com>
>> ---
>>  lib/stackdepot.c | 21 ++++++++++++++++++---
>>  1 file changed, 18 insertions(+), 3 deletions(-)
>>
>> diff --git a/lib/stackdepot.c b/lib/stackdepot.c
>> index f87d138e9672..d372101e8dc2 100644
>> --- a/lib/stackdepot.c
>> +++ b/lib/stackdepot.c
>> @@ -163,6 +163,23 @@ static inline u32 hash_stack(unsigned long *entries=
, unsigned int size)
>>                              STACK_HASH_SEED);
>>  }
>>
>> +/* Use our own, non-instrumented version of memcmp().
>> + *
>> + * We actually don't care about the order, just the equality.
>> + */
>> +static inline
>> +int stackdepot_memcmp(const void *s1, const void *s2, unsigned int n)
>> +{
>
> Why 'void *' types? The function treats s1, s2 as array of long, also 'n'=
 is number of longs here.
Agreed. I started with a plain memcpy, so the arg types were left over.
>> +     unsigned long *u1 =3D (unsigned long *)s1;
>> +     unsigned long *u2 =3D (unsigned long *)s2;
>> +
>> +     for ( ; n-- ; u1++, u2++) {
>> +             if (*u1 !=3D *u2)
>> +                     return 1;
>> +     }
>> +     return 0;
>> +}
>> +
>>  /* Find a stack that is equal to the one stored in entries in the hash =
*/
>>  static inline struct stack_record *find_stack(struct stack_record *buck=
et,
>>                                            unsigned long *entries, int s=
ize,
>> @@ -173,10 +190,8 @@ static inline struct stack_record *find_stack(struc=
t stack_record *bucket,
>>       for (found =3D bucket; found; found =3D found->next) {
>>               if (found->hash =3D=3D hash &&
>>                   found->size =3D=3D size &&
>> -                 !memcmp(entries, found->entries,
>> -                         size * sizeof(unsigned long))) {
>> +                 !stackdepot_memcmp(entries, found->entries, size))
>>                       return found;
>> -             }
>>       }
>>       return NULL;
>>  }
>>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
