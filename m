Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 698516B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 08:42:09 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id m64so36847757lfd.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 05:42:09 -0700 (PDT)
Received: from mail-lf0-x22d.google.com (mail-lf0-x22d.google.com. [2a00:1450:4010:c07::22d])
        by mx.google.com with ESMTPS id dw7si4719509lbc.96.2016.05.02.05.42.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 05:42:07 -0700 (PDT)
Received: by mail-lf0-x22d.google.com with SMTP id j8so53985411lfd.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 05:42:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <572747C2.5040009@emindsoft.com.cn>
References: <1462167374-6321-1-git-send-email-chengang@emindsoft.com.cn>
	<CACT4Y+Z7Yfsq9wjJuoeegEvPBvJs9iX6wN2VO1scA7HA4TVLmQ@mail.gmail.com>
	<572735EB.8030300@emindsoft.com.cn>
	<CACT4Y+Yrq4mt6c8wQKU7WcTnN7k28T3hM1V6_DWF-NpmuMH7Gw@mail.gmail.com>
	<572747C2.5040009@emindsoft.com.cn>
Date: Mon, 2 May 2016 14:42:07 +0200
Message-ID: <CAG_fn=VGJAGb71HU4rC9MNboqPqPs4EPgcWBfaiBpcgNQ2qFqA@mail.gmail.com>
Subject: Re: [PATCH] mm/kasan/kasan.h: Fix boolean checking issue for kasan_report_enabled()
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On Mon, May 2, 2016 at 2:27 PM, Chen Gang <chengang@emindsoft.com.cn> wrote=
:
> On 5/2/16 19:21, Dmitry Vyukov wrote:
>> On Mon, May 2, 2016 at 1:11 PM, Chen Gang <chengang@emindsoft.com.cn> wr=
ote:
>>> On 5/2/16 16:26, Dmitry Vyukov wrote:
>>>> If you want to improve kasan_depth handling, then please fix the
>>>> comments and make disable increment and enable decrement (potentially
>>>> with WARNING on overflow/underflow). It's better to produce a WARNING
>>>> rather than silently ignore the error. We've ate enough unmatched
>>>> annotations in user space (e.g. enable is skipped on an error path).
>>>> These unmatched annotations are hard to notice (they suppress
>>>> reports). So in user space we bark loudly on overflows/underflows and
>>>> also check that a thread does not exit with enabled suppressions.
>>>>
>>>
>>> For me, when WARNING on something, it will dummy the related feature
>>> which should be used (may let user's hope fail), but should not get the
>>> negative result (hurt user's original work). So in our case:
>>>
>>>  - When caller calls kasan_report_enabled(), kasan_depth-- to 0,
>>>
>>>  - When a caller calls kasan_report_enabled() again, the caller will ge=
t
>>>    a warning, and notice about this calling is failed, but it is still
>>>    in enable state, should not change to disable state automatically.
>>>
>>>  - If we report an warning, but still kasan_depth--, it will let things
>>>    much complex.
>>>
>>> And for me, another improvements can be done:
>>>
>>>  - signed int kasan_depth may be a little better. When kasan_depth > 0,
>>>    it is in disable state, else in enable state. It will be much harder
>>>    to generate overflow than unsigned int kasan_depth.
>>>
>>>  - Let kasan_[en|dis]able_current() return Boolean value to notify the
>>>    caller whether the calling succeeds or fails.
>>
>> Signed counter looks good to me.
>
> Oh, sorry, it seems a little mess (originally, I need let the 2 patches
> in one patch set).
>
> If what Alexander's idea is OK (if I did not misunderstand), I guess,
> unsigned counter is still necessary.
I don't think it's critical for us to use an unsigned counter.
If we increment the counter in kasan_disable_current() and decrement
it in kasan_enable_current(), as Dmitry suggested, we'll be naturally
using only positive integers for the counter.
If the counter drops below zero, or exceeds a certain number (say,
20), we can immediately issue a warning.

>> We can both issue a WARNING and prevent the actual overflow/underflow.
>> But I don't think that there is any sane way to handle the bug (other
>> than just fixing the unmatched disable/enable). If we ignore an
>> excessive disable, then we can end up with ignores enabled
>> permanently. If we ignore an excessive enable, then we can end up with
>> ignores enabled when they should not be enabled. The main point here
>> is to bark loudly, so that the unmatched annotations are noticed and
>> fixed.
>>
>
> How about BUG_ON()?
As noted by Dmitry in an offline discussion, we shouldn't bail out as
long as it's possible to proceed, otherwise the kernel may become very
hard to debug.
A mismatching annotation isn't a case in which we can't proceed with
the execution.
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
