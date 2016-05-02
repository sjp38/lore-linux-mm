Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A3C996B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 08:22:58 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id t140so126127019oie.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 05:22:58 -0700 (PDT)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id y6si17531557igs.85.2016.05.02.05.22.56
        for <linux-mm@kvack.org>;
        Mon, 02 May 2016 05:22:58 -0700 (PDT)
Message-ID: <572747C2.5040009@emindsoft.com.cn>
Date: Mon, 02 May 2016 20:27:46 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/kasan/kasan.h: Fix boolean checking issue for kasan_report_enabled()
References: <1462167374-6321-1-git-send-email-chengang@emindsoft.com.cn> <CACT4Y+Z7Yfsq9wjJuoeegEvPBvJs9iX6wN2VO1scA7HA4TVLmQ@mail.gmail.com> <572735EB.8030300@emindsoft.com.cn> <CACT4Y+Yrq4mt6c8wQKU7WcTnN7k28T3hM1V6_DWF-NpmuMH7Gw@mail.gmail.com>
In-Reply-To: <CACT4Y+Yrq4mt6c8wQKU7WcTnN7k28T3hM1V6_DWF-NpmuMH7Gw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On 5/2/16 19:21, Dmitry Vyukov wrote:
> On Mon, May 2, 2016 at 1:11 PM, Chen Gang <chengang@emindsoft.com.cn> wrote:
>> On 5/2/16 16:26, Dmitry Vyukov wrote:
>>> If you want to improve kasan_depth handling, then please fix the
>>> comments and make disable increment and enable decrement (potentially
>>> with WARNING on overflow/underflow). It's better to produce a WARNING
>>> rather than silently ignore the error. We've ate enough unmatched
>>> annotations in user space (e.g. enable is skipped on an error path).
>>> These unmatched annotations are hard to notice (they suppress
>>> reports). So in user space we bark loudly on overflows/underflows and
>>> also check that a thread does not exit with enabled suppressions.
>>>
>>
>> For me, when WARNING on something, it will dummy the related feature
>> which should be used (may let user's hope fail), but should not get the
>> negative result (hurt user's original work). So in our case:
>>
>>  - When caller calls kasan_report_enabled(), kasan_depth-- to 0,
>>
>>  - When a caller calls kasan_report_enabled() again, the caller will get
>>    a warning, and notice about this calling is failed, but it is still
>>    in enable state, should not change to disable state automatically.
>>
>>  - If we report an warning, but still kasan_depth--, it will let things
>>    much complex.
>>
>> And for me, another improvements can be done:
>>
>>  - signed int kasan_depth may be a little better. When kasan_depth > 0,
>>    it is in disable state, else in enable state. It will be much harder
>>    to generate overflow than unsigned int kasan_depth.
>>
>>  - Let kasan_[en|dis]able_current() return Boolean value to notify the
>>    caller whether the calling succeeds or fails.
> 
> Signed counter looks good to me.

Oh, sorry, it seems a little mess (originally, I need let the 2 patches
in one patch set).

If what Alexander's idea is OK (if I did not misunderstand), I guess,
unsigned counter is still necessary.

> We can both issue a WARNING and prevent the actual overflow/underflow.
> But I don't think that there is any sane way to handle the bug (other
> than just fixing the unmatched disable/enable). If we ignore an
> excessive disable, then we can end up with ignores enabled
> permanently. If we ignore an excessive enable, then we can end up with
> ignores enabled when they should not be enabled. The main point here
> is to bark loudly, so that the unmatched annotations are noticed and
> fixed.
> 

How about BUG_ON()?


Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
