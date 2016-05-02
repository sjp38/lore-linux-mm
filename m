Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id C6CEA6B025E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 09:46:50 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id sq19so195684059igc.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 06:46:50 -0700 (PDT)
Received: from out1134-203.mail.aliyun.com (out1134-203.mail.aliyun.com. [42.120.134.203])
        by mx.google.com with ESMTP id np9si4090406igc.19.2016.05.02.06.46.46
        for <linux-mm@kvack.org>;
        Mon, 02 May 2016 06:46:47 -0700 (PDT)
Message-ID: <57275B71.8000907@emindsoft.com.cn>
Date: Mon, 02 May 2016 21:51:45 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/kasan/kasan.h: Fix boolean checking issue for kasan_report_enabled()
References: <1462167374-6321-1-git-send-email-chengang@emindsoft.com.cn>	<CACT4Y+Z7Yfsq9wjJuoeegEvPBvJs9iX6wN2VO1scA7HA4TVLmQ@mail.gmail.com>	<572735EB.8030300@emindsoft.com.cn>	<CACT4Y+Yrq4mt6c8wQKU7WcTnN7k28T3hM1V6_DWF-NpmuMH7Gw@mail.gmail.com>	<572747C2.5040009@emindsoft.com.cn> <CAG_fn=VGJAGb71HU4rC9MNboqPqPs4EPgcWBfaiBpcgNQ2qFqA@mail.gmail.com>
In-Reply-To: <CAG_fn=VGJAGb71HU4rC9MNboqPqPs4EPgcWBfaiBpcgNQ2qFqA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On 5/2/16 20:42, Alexander Potapenko wrote:
> On Mon, May 2, 2016 at 2:27 PM, Chen Gang <chengang@emindsoft.com.cn> wrote:
>> On 5/2/16 19:21, Dmitry Vyukov wrote:
>>>
>>> Signed counter looks good to me.
>>
>> Oh, sorry, it seems a little mess (originally, I need let the 2 patches
>> in one patch set).
>>
>> If what Alexander's idea is OK (if I did not misunderstand), I guess,
>> unsigned counter is still necessary.
> I don't think it's critical for us to use an unsigned counter.
> If we increment the counter in kasan_disable_current() and decrement
> it in kasan_enable_current(), as Dmitry suggested, we'll be naturally
> using only positive integers for the counter.
> If the counter drops below zero, or exceeds a certain number (say,
> 20), we can immediately issue a warning.
> 

OK, thanks.

And for "kasan_depth == 1", I guess, its meaning is related with
kasan_depth[++|--] in kasan_[en|dis]able_current():

 - If kasan_depth++ in kasan_enable_current() with preventing overflow/
   underflow, it means "we always want to disable KASAN, if CONFIG_KASAN
   is not under arm64 or x86_64".

 - If kasan_depth-- in kasan_enable_current() with preventing overflow/
   underflow, it means "we can enable KASAN if CONFIG_KASAN, but firstly
   we disable it, if it is not under arm64 or x86_64".

For me, I don't know which one is correct (or my whole 'guess' is
incorrect). Could any members provide your ideas?

>>> We can both issue a WARNING and prevent the actual overflow/underflow.
>>> But I don't think that there is any sane way to handle the bug (other
>>> than just fixing the unmatched disable/enable). If we ignore an
>>> excessive disable, then we can end up with ignores enabled
>>> permanently. If we ignore an excessive enable, then we can end up with
>>> ignores enabled when they should not be enabled. The main point here
>>> is to bark loudly, so that the unmatched annotations are noticed and
>>> fixed.
>>>
>>
>> How about BUG_ON()?
> As noted by Dmitry in an offline discussion, we shouldn't bail out as
> long as it's possible to proceed, otherwise the kernel may become very
> hard to debug.
> A mismatching annotation isn't a case in which we can't proceed with
> the execution.

OK, thanks.

I guess, we are agree with each other: "We can both issue a WARNING and
prevent the actual overflow/underflow.".

Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
