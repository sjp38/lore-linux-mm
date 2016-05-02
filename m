Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A28C6B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 11:35:04 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so80227539wmw.3
        for <linux-mm@kvack.org>; Mon, 02 May 2016 08:35:04 -0700 (PDT)
Received: from mail-lf0-x22e.google.com (mail-lf0-x22e.google.com. [2a00:1450:4010:c07::22e])
        by mx.google.com with ESMTPS id dw7si5080011lbc.96.2016.05.02.08.35.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 08:35:03 -0700 (PDT)
Received: by mail-lf0-x22e.google.com with SMTP id y84so191940047lfc.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 08:35:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57276E95.1030201@emindsoft.com.cn>
References: <1462167374-6321-1-git-send-email-chengang@emindsoft.com.cn>
	<CACT4Y+Z7Yfsq9wjJuoeegEvPBvJs9iX6wN2VO1scA7HA4TVLmQ@mail.gmail.com>
	<572735EB.8030300@emindsoft.com.cn>
	<CACT4Y+Yrq4mt6c8wQKU7WcTnN7k28T3hM1V6_DWF-NpmuMH7Gw@mail.gmail.com>
	<572747C2.5040009@emindsoft.com.cn>
	<CAG_fn=VGJAGb71HU4rC9MNboqPqPs4EPgcWBfaiBpcgNQ2qFqA@mail.gmail.com>
	<57275B71.8000907@emindsoft.com.cn>
	<CAG_fn=WBPcQ8HgG13RksM=v833Q4GmM4dXhFNa9ihhMnOWKLmA@mail.gmail.com>
	<57276E95.1030201@emindsoft.com.cn>
Date: Mon, 2 May 2016 17:35:02 +0200
Message-ID: <CAG_fn=W76ArZumUwM-fqsAZC2ksoi8azMPah+1aopigmrEWSNQ@mail.gmail.com>
Subject: Re: [PATCH] mm/kasan/kasan.h: Fix boolean checking issue for kasan_report_enabled()
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On Mon, May 2, 2016 at 5:13 PM, Chen Gang <chengang@emindsoft.com.cn> wrote=
:
> On 5/2/16 22:23, Alexander Potapenko wrote:
>> On Mon, May 2, 2016 at 3:51 PM, Chen Gang <chengang@emindsoft.com.cn> wr=
ote:
>>>
>>> OK, thanks.
>>>
>>> And for "kasan_depth =3D=3D 1", I guess, its meaning is related with
>>> kasan_depth[++|--] in kasan_[en|dis]able_current():
>> Assuming you are talking about the assignment of 1 to kasan_depth in
>> /include/linux/init_task.h,
>> it's somewhat counterintuitive. I think we just need to replace it
>> with kasan_disable_current(), and add a corresponding
>> kasan_enable_current() to the end of kasan_init.
>>
>
> OK. But it does not look quite easy to use kasan_disable_current() for
> INIT_KASAN which is used in INIT_TASK.
>
> If we have to set "kasan_depth =3D=3D 1", we have to use kasan_depth-- in
> kasan_enable_current().
Agreed, decrementing the counter in kasan_enable_current() is more natural.
I can fix this together with the comments.
>>>
>>> OK, thanks.
>>>
>>> I guess, we are agree with each other: "We can both issue a WARNING and
>>> prevent the actual overflow/underflow.".
>> No, I am not sure think that we need to prevent the overflow.
>> As I showed before, this may result in kasan_depth being off even in
>> the case kasan_enable_current()/kasan_disable_current() are used
>> consistently.
>
> If we don't prevent the overflow, it will have negative effect with the
> caller. When we issue an warning, it means the caller's hope fail, but
> can not destroy the caller's original work. In our case:
>
>  - Assume "kasan_depth-- for kasan_enable_current()", the first enable
>    will let kasan_depth be 0.
Sorry, I'm not sure I follow.
If we start with kasan_depth=3D0 (which is the default case for every
task except for the init, which also gets kasan_depth=3D0 short after
the kernel starts),
then the first call to kasan_disable_current() will make kasan_depth
nonzero and will disable KASAN.
The subsequent call to kasan_enable_current() will enable KASAN back.

There indeed is a problem when someone calls kasan_enable_current()
without previously calling kasan_disable_current().
In this case we need to check that kasan_depth was zero and print a
warning if it was.
It actually does not matter whether we modify kasan_depth after that
warning or not, because we are already in inconsistent state.
But I think we should modify kasan_depth anyway to ease the debugging.

>  - If we don't prevent the overflow, 2nd enable will cause disable
>    effect, which will destroy the caller's original work.
The subsequent call to kasan_enable_current() will
>  - Enable/disable mismatch is caused by caller, we can issue warnings,
>    and skip it (since it is not caused by us). But we can not generate
>    new issues to the system only because of the caller's issue.
>
>
> Thanks.
> --
> Chen Gang (=E9=99=88=E5=88=9A)
>
> Managing Natural Environments is the Duty of Human Beings.



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
