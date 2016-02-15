Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4BF12828E2
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 09:05:47 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id g62so150512654wme.0
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 06:05:47 -0800 (PST)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id ew12si40914635wjc.123.2016.02.15.06.05.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 06:05:45 -0800 (PST)
Received: by mail-wm0-x235.google.com with SMTP id b205so69005247wmb.1
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 06:05:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=VN3+otwrjBbut365D=F0YAnow7-OHkNArLAAntBQmYvw@mail.gmail.com>
References: <cover.1453918525.git.glider@google.com>
	<35b553cafcd5b77838aeaf5548b457dfa09e30cf.1453918525.git.glider@google.com>
	<20160201213427.f428b08d.akpm@linux-foundation.org>
	<56B0CB60.1080506@gmail.com>
	<CAG_fn=VN3+otwrjBbut365D=F0YAnow7-OHkNArLAAntBQmYvw@mail.gmail.com>
Date: Mon, 15 Feb 2016 15:05:44 +0100
Message-ID: <CAG_fn=Uw7PEYADiaYsxQg9-yeHxtu6U82yF0+wVRJu5ZGFN_2w@mail.gmail.com>
Subject: Re: [PATCH v1 1/8] kasan: Change the behavior of kmalloc_large_oob_right
 test
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Turns out I've actually overintellectualized this test.
I've reworked this patch so that kmalloc_pagealloc_oob_right()
allocates a big chunk of memory from the page allocator (and therefore
is enabled only under CONFIG_SLUB).
kmalloc_large_oob_right() now allocates KMALLOC_MAX_CACHE_SIZE - 256
in both SLAB and SLUB modes.

I'll send the updated patch set later today.

On Tue, Feb 2, 2016 at 5:25 PM, Alexander Potapenko <glider@google.com> wro=
te:
> The intention was to detect the situation in which a new allocator
> appears for which we don't know how it behaves if we allocate more
> than KMALLOC_MAX_CACHE_SIZE.
> I agree this makes little sense and we can just stick to
> CONFIG_SLAB/CONFIG_SLUB cases.
>
> However I think it's better to keep 'size =3D KMALLOC_MAX_CACHE_SIZE +
> something' to keep this code working in the case the value of
> KMALLOC_MAX_CACHE_SIZE changes.
>
> On Tue, Feb 2, 2016 at 4:29 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> =
wrote:
>>
>>
>> On 02/02/2016 08:34 AM, Andrew Morton wrote:
>>> On Wed, 27 Jan 2016 19:25:06 +0100 Alexander Potapenko <glider@google.c=
om> wrote:
>>>
>>>> depending on which allocator (SLAB or SLUB) is being used
>>>>
>>>> ...
>>>>
>>>> --- a/lib/test_kasan.c
>>>> +++ b/lib/test_kasan.c
>>>> @@ -68,7 +68,22 @@ static noinline void __init kmalloc_node_oob_right(=
void)
>>>>  static noinline void __init kmalloc_large_oob_right(void)
>>>>  {
>>>>      char *ptr;
>>>> -    size_t size =3D KMALLOC_MAX_CACHE_SIZE + 10;
>>>> +    size_t size;
>>>> +
>>>> +    if (KMALLOC_MAX_CACHE_SIZE =3D=3D KMALLOC_MAX_SIZE) {
>>>> +            /*
>>>> +             * We're using the SLAB allocator. Allocate a chunk that =
fits
>>>> +             * into a slab.
>>>> +             */
>>>> +            size =3D KMALLOC_MAX_CACHE_SIZE - 256;
>>>> +    } else {
>>>> +            /*
>>>> +             * KMALLOC_MAX_SIZE > KMALLOC_MAX_CACHE_SIZE.
>>>> +             * We're using the SLUB allocator. Allocate a chunk that =
does
>>>> +             * not fit into a slab to trigger the page allocator.
>>>> +             */
>>>> +            size =3D KMALLOC_MAX_CACHE_SIZE + 10;
>>>> +    }
>>>
>>> This seems a weird way of working out whether we're using SLAB or SLUB.
>>>
>>> Can't we use, umm, #ifdef CONFIG_SLAB?  If not that then let's cook up
>>> something standardized rather than a weird just-happens-to-work like
>>> this.
>>>
>>
>> Actually it would be simpler to not use KMALLOC_MAX_CACHE_SIZE at all.
>> Simply replace it with 2 or 3 PAGE_SIZEs.
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
> Diese E-Mail ist vertraulich. Wenn Sie nicht der richtige Adressat sind,
> leiten Sie diese bitte nicht weiter, informieren Sie den
> Absender und l=C3=B6schen Sie die E-Mail und alle Anh=C3=A4nge. Vielen Da=
nk.
> This e-mail is confidential. If you are not the right addressee please
> do not forward it, please inform the sender, and please erase this
> e-mail including any attachments. Thanks.



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
