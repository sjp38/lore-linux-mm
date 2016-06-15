Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 323D96B0005
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 12:41:07 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id g18so13809183lfg.2
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 09:41:07 -0700 (PDT)
Received: from mail-lb0-x229.google.com (mail-lb0-x229.google.com. [2a00:1450:4010:c04::229])
        by mx.google.com with ESMTPS id 17si9779224ljf.13.2016.06.15.09.41.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 09:41:05 -0700 (PDT)
Received: by mail-lb0-x229.google.com with SMTP id xp5so4964224lbb.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 09:41:05 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v2] mm/page_alloc: remove unnecessary order check in __alloc_pages_direct_compact
In-Reply-To: <CAKTCnzk1GZ+=ijvOm=Tw1GNGLdefovvS5wsR9XqpLLmrSSx9=g@mail.gmail.com>
References: <1465983258-3726-1-git-send-email-opensource.ganesh@gmail.com> <CAKTCnzk1GZ+=ijvOm=Tw1GNGLdefovvS5wsR9XqpLLmrSSx9=g@mail.gmail.com>
Date: Wed, 15 Jun 2016 18:41:03 +0200
Message-ID: <xa1tlh26csm8.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, mhocko@suse.com, Minchan Kim <minchan@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

On Wed, Jun 15 2016, Balbir Singh wrote:
> On Wed, Jun 15, 2016 at 7:34 PM, Ganesh Mahendran
> <opensource.ganesh@gmail.com> wrote:
>> In the callee try_to_compact_pages(), the (order =3D=3D 0) is checked,
>> so remove check in __alloc_pages_direct_compact.
>>
>> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
>> ---
>> v2:
>>   remove the check in __alloc_pages_direct_compact - Anshuman Khandual
>> ---
>>  mm/page_alloc.c | 3 ---
>>  1 file changed, 3 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index b9ea618..2f5a82a 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3173,9 +3173,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsig=
ned int order,
>>         struct page *page;
>>         int contended_compaction;
>>
>> -       if (!order)
>> -               return NULL;
>> -
>>         current->flags |=3D PF_MEMALLOC;
>>         *compact_result =3D try_to_compact_pages(gfp_mask, order, alloc_=
flags, ac,
>>                                                 mode, &contended_compact=
ion);
>
> What is the benefit of this. Is an if check more expensive than
> calling the function and returning from it? I don't feel strongly
> about such changes, but its good to audit the overall code for reading
> and performance.

It=E2=80=99s a slow path so it probably doesn=E2=80=99t matter much.  But I=
 also don=E2=80=99t
see whether this improves readability of the code.

For performance, I would rather wait for gcc to compile kernel as one
translation unit which will allow it to inline try_to_compact_pages and
notice redundant order=3D=3D0 check.

--=20
Best regards
=E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9C=F0=9D=93=B6=F0=9D=93=B2=F0=9D=93=B7=
=F0=9D=93=AA86=E2=80=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=83=
=84
=C2=ABIf at first you don=E2=80=99t succeed, give up skydiving=C2=BB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
