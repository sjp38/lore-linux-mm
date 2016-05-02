Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7B5EE6B025E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 07:21:34 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 68so138309044lfq.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 04:21:34 -0700 (PDT)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id x5si33624313wjd.70.2016.05.02.04.21.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 04:21:33 -0700 (PDT)
Received: by mail-wm0-x22d.google.com with SMTP id e201so102896621wme.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 04:21:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <572735EB.8030300@emindsoft.com.cn>
References: <1462167374-6321-1-git-send-email-chengang@emindsoft.com.cn>
 <CACT4Y+Z7Yfsq9wjJuoeegEvPBvJs9iX6wN2VO1scA7HA4TVLmQ@mail.gmail.com> <572735EB.8030300@emindsoft.com.cn>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 2 May 2016 13:21:13 +0200
Message-ID: <CACT4Y+Yrq4mt6c8wQKU7WcTnN7k28T3hM1V6_DWF-NpmuMH7Gw@mail.gmail.com>
Subject: Re: [PATCH] mm/kasan/kasan.h: Fix boolean checking issue for kasan_report_enabled()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On Mon, May 2, 2016 at 1:11 PM, Chen Gang <chengang@emindsoft.com.cn> wrote:
> On 5/2/16 16:26, Dmitry Vyukov wrote:
>> On Mon, May 2, 2016 at 7:36 AM,  <chengang@emindsoft.com.cn> wrote:
>>> From: Chen Gang <chengang@emindsoft.com.cn>
>>>
>>> According to kasan_[dis|en]able_current() comments and the kasan_depth'
>>> s initialization, if kasan_depth is zero, it means disable.
>>>
>>> So need use "!!kasan_depth" instead of "!kasan_depth" for checking
>>> enable.
>>>
>>
>> Hi Chen,
>>
>> I don't think this is correct.
>
> OK, thanks.
>
>> We seem to have some incorrect comments around kasan_depth, and a
>> weird way of manipulating it (disable should increment, and enable
>> should decrement). But in the end it is working. This change will
>> suppress all true reports and enable all false reports.
>>
>
> For me, I guess, what you said above is reasonable.
>
> But it is really strange to any newbies (e.g. me), so it will be better
> to get another member's confirmation, too. If no any additional reply by
> any other members within 3 days, I shall treat what you said is OK.
>
>> If you want to improve kasan_depth handling, then please fix the
>> comments and make disable increment and enable decrement (potentially
>> with WARNING on overflow/underflow). It's better to produce a WARNING
>> rather than silently ignore the error. We've ate enough unmatched
>> annotations in user space (e.g. enable is skipped on an error path).
>> These unmatched annotations are hard to notice (they suppress
>> reports). So in user space we bark loudly on overflows/underflows and
>> also check that a thread does not exit with enabled suppressions.
>>
>
> For me, when WARNING on something, it will dummy the related feature
> which should be used (may let user's hope fail), but should not get the
> negative result (hurt user's original work). So in our case:
>
>  - When caller calls kasan_report_enabled(), kasan_depth-- to 0,
>
>  - When a caller calls kasan_report_enabled() again, the caller will get
>    a warning, and notice about this calling is failed, but it is still
>    in enable state, should not change to disable state automatically.
>
>  - If we report an warning, but still kasan_depth--, it will let things
>    much complex.
>
> And for me, another improvements can be done:
>
>  - signed int kasan_depth may be a little better. When kasan_depth > 0,
>    it is in disable state, else in enable state. It will be much harder
>    to generate overflow than unsigned int kasan_depth.
>
>  - Let kasan_[en|dis]able_current() return Boolean value to notify the
>    caller whether the calling succeeds or fails.

Signed counter looks good to me.
We can both issue a WARNING and prevent the actual overflow/underflow.
But I don't think that there is any sane way to handle the bug (other
than just fixing the unmatched disable/enable). If we ignore an
excessive disable, then we can end up with ignores enabled
permanently. If we ignore an excessive enable, then we can end up with
ignores enabled when they should not be enabled. The main point here
is to bark loudly, so that the unmatched annotations are noticed and
fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
