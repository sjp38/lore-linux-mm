Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3211D6B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 10:23:45 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 68so142412603lfq.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 07:23:45 -0700 (PDT)
Received: from mail-lf0-x22c.google.com (mail-lf0-x22c.google.com. [2a00:1450:4010:c07::22c])
        by mx.google.com with ESMTPS id p194si17215286lfb.106.2016.05.02.07.23.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 07:23:43 -0700 (PDT)
Received: by mail-lf0-x22c.google.com with SMTP id m64so36026437lfd.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 07:23:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57275B71.8000907@emindsoft.com.cn>
References: <1462167374-6321-1-git-send-email-chengang@emindsoft.com.cn>
	<CACT4Y+Z7Yfsq9wjJuoeegEvPBvJs9iX6wN2VO1scA7HA4TVLmQ@mail.gmail.com>
	<572735EB.8030300@emindsoft.com.cn>
	<CACT4Y+Yrq4mt6c8wQKU7WcTnN7k28T3hM1V6_DWF-NpmuMH7Gw@mail.gmail.com>
	<572747C2.5040009@emindsoft.com.cn>
	<CAG_fn=VGJAGb71HU4rC9MNboqPqPs4EPgcWBfaiBpcgNQ2qFqA@mail.gmail.com>
	<57275B71.8000907@emindsoft.com.cn>
Date: Mon, 2 May 2016 16:23:43 +0200
Message-ID: <CAG_fn=WBPcQ8HgG13RksM=v833Q4GmM4dXhFNa9ihhMnOWKLmA@mail.gmail.com>
Subject: Re: [PATCH] mm/kasan/kasan.h: Fix boolean checking issue for kasan_report_enabled()
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On Mon, May 2, 2016 at 3:51 PM, Chen Gang <chengang@emindsoft.com.cn> wrote=
:
> On 5/2/16 20:42, Alexander Potapenko wrote:
>> On Mon, May 2, 2016 at 2:27 PM, Chen Gang <chengang@emindsoft.com.cn> wr=
ote:
>>> On 5/2/16 19:21, Dmitry Vyukov wrote:
>>>>
>>>> Signed counter looks good to me.
>>>
>>> Oh, sorry, it seems a little mess (originally, I need let the 2 patches
>>> in one patch set).
>>>
>>> If what Alexander's idea is OK (if I did not misunderstand), I guess,
>>> unsigned counter is still necessary.
>> I don't think it's critical for us to use an unsigned counter.
>> If we increment the counter in kasan_disable_current() and decrement
>> it in kasan_enable_current(), as Dmitry suggested, we'll be naturally
>> using only positive integers for the counter.
>> If the counter drops below zero, or exceeds a certain number (say,
>> 20), we can immediately issue a warning.
>>
>
> OK, thanks.
>
> And for "kasan_depth =3D=3D 1", I guess, its meaning is related with
> kasan_depth[++|--] in kasan_[en|dis]able_current():
Assuming you are talking about the assignment of 1 to kasan_depth in
/include/linux/init_task.h,
it's somewhat counterintuitive. I think we just need to replace it
with kasan_disable_current(), and add a corresponding
kasan_enable_current() to the end of kasan_init.

>  - If kasan_depth++ in kasan_enable_current() with preventing overflow/
>    underflow, it means "we always want to disable KASAN, if CONFIG_KASAN
>    is not under arm64 or x86_64".
>
>  - If kasan_depth-- in kasan_enable_current() with preventing overflow/
>    underflow, it means "we can enable KASAN if CONFIG_KASAN, but firstly
>    we disable it, if it is not under arm64 or x86_64".
>
> For me, I don't know which one is correct (or my whole 'guess' is
> incorrect). Could any members provide your ideas?
>
>>>> We can both issue a WARNING and prevent the actual overflow/underflow.
>>>> But I don't think that there is any sane way to handle the bug (other
>>>> than just fixing the unmatched disable/enable). If we ignore an
>>>> excessive disable, then we can end up with ignores enabled
>>>> permanently. If we ignore an excessive enable, then we can end up with
>>>> ignores enabled when they should not be enabled. The main point here
>>>> is to bark loudly, so that the unmatched annotations are noticed and
>>>> fixed.
>>>>
>>>
>>> How about BUG_ON()?
>> As noted by Dmitry in an offline discussion, we shouldn't bail out as
>> long as it's possible to proceed, otherwise the kernel may become very
>> hard to debug.
>> A mismatching annotation isn't a case in which we can't proceed with
>> the execution.
>
> OK, thanks.
>
> I guess, we are agree with each other: "We can both issue a WARNING and
> prevent the actual overflow/underflow.".
No, I am not sure think that we need to prevent the overflow.
As I showed before, this may result in kasan_depth being off even in
the case kasan_enable_current()/kasan_disable_current() are used
consistently.
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
