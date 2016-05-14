Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8F8476B0005
	for <linux-mm@kvack.org>; Fri, 13 May 2016 23:25:13 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 77so239392350pfz.3
        for <linux-mm@kvack.org>; Fri, 13 May 2016 20:25:13 -0700 (PDT)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id z13si27930904pfi.155.2016.05.13.20.25.10
        for <linux-mm@kvack.org>;
        Fri, 13 May 2016 20:25:12 -0700 (PDT)
Message-ID: <57369BC8.7000602@emindsoft.com.cn>
Date: Sat, 14 May 2016 11:30:16 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/kasan/kasan.h: Fix boolean checking issue for kasan_report_enabled()
References: <1462167374-6321-1-git-send-email-chengang@emindsoft.com.cn>	<CACT4Y+Z7Yfsq9wjJuoeegEvPBvJs9iX6wN2VO1scA7HA4TVLmQ@mail.gmail.com>	<572735EB.8030300@emindsoft.com.cn>	<CACT4Y+Yrq4mt6c8wQKU7WcTnN7k28T3hM1V6_DWF-NpmuMH7Gw@mail.gmail.com>	<572747C2.5040009@emindsoft.com.cn>	<CAG_fn=VGJAGb71HU4rC9MNboqPqPs4EPgcWBfaiBpcgNQ2qFqA@mail.gmail.com>	<57275B71.8000907@emindsoft.com.cn>	<CAG_fn=WBPcQ8HgG13RksM=v833Q4GmM4dXhFNa9ihhMnOWKLmA@mail.gmail.com>	<57276E95.1030201@emindsoft.com.cn> <CAG_fn=W76ArZumUwM-fqsAZC2ksoi8azMPah+1aopigmrEWSNQ@mail.gmail.com> <57277EEA.6070909@emindsoft.com.cn> <57278294.3060006@emindsoft.com.cn>
In-Reply-To: <57278294.3060006@emindsoft.com.cn>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

Hello all:

Shall I send patch v2 for it? (if really need, please let me know, and I
shall try).

Default, I shall continue to try to find and send another patches for mm
in "include/linux/*.h".

Thanks.

On 5/3/16 00:38, Chen Gang wrote:
> On 5/3/16 00:23, Chen Gang wrote:
>> On 5/2/16 23:35, Alexander Potapenko wrote:
>>> On Mon, May 2, 2016 at 5:13 PM, Chen Gang <chengang@emindsoft.com.cn> wrote:
>>>>
>>>> OK. But it does not look quite easy to use kasan_disable_current() for
>>>> INIT_KASAN which is used in INIT_TASK.
>>>>
>>>> If we have to set "kasan_depth == 1", we have to use kasan_depth-- in
>>>> kasan_enable_current().
>>> Agreed, decrementing the counter in kasan_enable_current() is more natural.
>>> I can fix this together with the comments.
>>
>> OK, thanks. And need I also send patch v2 for include/linux/kasan.h? (or
>> you will fix them together).
>>
>>>>
>>>> If we don't prevent the overflow, it will have negative effect with the
>>>> caller. When we issue an warning, it means the caller's hope fail, but
>>>> can not destroy the caller's original work. In our case:
>>>>
>>>>  - Assume "kasan_depth-- for kasan_enable_current()", the first enable
>>>>    will let kasan_depth be 0.
>>> Sorry, I'm not sure I follow.
>>> If we start with kasan_depth=0 (which is the default case for every
>>> task except for the init, which also gets kasan_depth=0 short after
>>> the kernel starts),
>>> then the first call to kasan_disable_current() will make kasan_depth
>>> nonzero and will disable KASAN.
>>> The subsequent call to kasan_enable_current() will enable KASAN back.
>>>
>>> There indeed is a problem when someone calls kasan_enable_current()
>>> without previously calling kasan_disable_current().
>>> In this case we need to check that kasan_depth was zero and print a
>>> warning if it was.
>>> It actually does not matter whether we modify kasan_depth after that
>>> warning or not, because we are already in inconsistent state.
>>> But I think we should modify kasan_depth anyway to ease the debugging.
>>>
> 
> Oh, sorry, I forgot one of our original discussing content:
> 
>  - If we use signed int kasan_depth, and kasan_depth <= 0 means enable, I
>    guess, we can always modify kasan_depth.
> 
>  - When overflow/underflow (singed int overflow), we can use BUG_ON(),
>    since it should be rarely happen.
> 
> Thanks.
> 
>>
>> For me, BUG_ON() will be better for debugging, but it is really not well
>> for using.  For WARN_ON(), it already print warnings, so I am not quite
>> sure "always modifying kasan_depth will be ease the debugging".
>>
>> When we are in inconsistent state, for me, what we can do is:
>>
>>  - Still try to do correct things within our control: "when the caller
>>    make a mistake, if kasan_enable_current() notices about it, it need
>>    issue warning, and prevent itself to make mistake (causing disable).
>>
>>  - "try to let negative effect smaller to user", e.g. let users "loose
>>    hope" (call enable has no effect) instead of destroying users'
>>    original work (call enable, but get disable).
>>
>> Thanks.
>>
> 

-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
