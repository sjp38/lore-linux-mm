Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 654616B025E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 07:23:05 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r12so74268031wme.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 04:23:05 -0700 (PDT)
Received: from mail-lf0-x231.google.com (mail-lf0-x231.google.com. [2a00:1450:4010:c07::231])
        by mx.google.com with ESMTPS id re10si16822183lbb.202.2016.05.02.04.23.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 04:23:04 -0700 (PDT)
Received: by mail-lf0-x231.google.com with SMTP id y84so183880032lfc.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 04:23:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <572737FB.2020405@emindsoft.com.cn>
References: <1462167348-6280-1-git-send-email-chengang@emindsoft.com.cn>
	<CAG_fn=W5Ai_cqhzyi=EBEyhhQtvoQtOsuyfBfRihf=fuKh2Xqw@mail.gmail.com>
	<572737FB.2020405@emindsoft.com.cn>
Date: Mon, 2 May 2016 13:23:03 +0200
Message-ID: <CAG_fn=W7m0UN6-38Ut0c-a_m4BfuUPjrmHQThGCLLqV-brKTmA@mail.gmail.com>
Subject: Re: [PATCH] include/linux/kasan.h: Notice about 0 for kasan_[dis/en]able_current()
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitriy Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On Mon, May 2, 2016 at 1:20 PM, Chen Gang <chengang@emindsoft.com.cn> wrote=
:
> On 5/2/16 18:49, Alexander Potapenko wrote:
>> On Mon, May 2, 2016 at 7:35 AM,  <chengang@emindsoft.com.cn> wrote:
>>>
>>> According to their comments and the kasan_depth's initialization, if
>>> kasan_depth is zero, it means disable. So kasan_depth need consider
>>> about the 0 overflow.
>>>
>>> Also remove useless comments for dummy kasan_slab_free().
>>>
>>> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
>>
>> Acked-by: Alexander Potapenko <glider@google.com>
Nacked-by: Alexander Potapenko <glider@google.com>
>>
>
> OK, thanks.
Well, on a second thought I take that back, there still might be problems.
I haven't noticed the other CL, and was too hasty reviewing this one.

As kasan_disable_current() and kasan_enable_current() always go
together, we need to prevent nested calls to them from breaking
everything.
If we ignore some calls to kasan_disable_current() to prevent
overflows, the pairing calls to kasan_enable_current() will bring
|current->kasan_depth| to an invalid state.

E.g. if I'm understanding your idea correctly, after the following
sequence of calls:
  kasan_disable_current();  // #1
  kasan_disable_current();  // #2
  kasan_enable_current();  // #3
  kasan_enable_current();  // #4

the value of |current->kasan_depth| will be 2, so a single subsequent
call to kasan_disable_current() won't disable KASAN.

I think we'd better add BUG checks to bail out if the value of
|current->kasan_depth| is too big or too small.

> Another patch thread is also related with this patch thread, please help
> check.
>
> And sorry, originally, I did not let the 2 patches in one patches set.
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
