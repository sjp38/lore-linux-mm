Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 044EA6B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 07:06:52 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id rd14so215921047obb.3
        for <linux-mm@kvack.org>; Mon, 02 May 2016 04:06:52 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id 70si15468856ioh.95.2016.05.02.04.06.49
        for <linux-mm@kvack.org>;
        Mon, 02 May 2016 04:06:51 -0700 (PDT)
Message-ID: <572735EB.8030300@emindsoft.com.cn>
Date: Mon, 02 May 2016 19:11:39 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/kasan/kasan.h: Fix boolean checking issue for kasan_report_enabled()
References: <1462167374-6321-1-git-send-email-chengang@emindsoft.com.cn> <CACT4Y+Z7Yfsq9wjJuoeegEvPBvJs9iX6wN2VO1scA7HA4TVLmQ@mail.gmail.com>
In-Reply-To: <CACT4Y+Z7Yfsq9wjJuoeegEvPBvJs9iX6wN2VO1scA7HA4TVLmQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On 5/2/16 16:26, Dmitry Vyukov wrote:
> On Mon, May 2, 2016 at 7:36 AM,  <chengang@emindsoft.com.cn> wrote:
>> From: Chen Gang <chengang@emindsoft.com.cn>
>>
>> According to kasan_[dis|en]able_current() comments and the kasan_depth'
>> s initialization, if kasan_depth is zero, it means disable.
>>
>> So need use "!!kasan_depth" instead of "!kasan_depth" for checking
>> enable.
>>
> 
> Hi Chen,
> 
> I don't think this is correct.

OK, thanks.

> We seem to have some incorrect comments around kasan_depth, and a
> weird way of manipulating it (disable should increment, and enable
> should decrement). But in the end it is working. This change will
> suppress all true reports and enable all false reports.
> 

For me, I guess, what you said above is reasonable.

But it is really strange to any newbies (e.g. me), so it will be better
to get another member's confirmation, too. If no any additional reply by
any other members within 3 days, I shall treat what you said is OK.

> If you want to improve kasan_depth handling, then please fix the
> comments and make disable increment and enable decrement (potentially
> with WARNING on overflow/underflow). It's better to produce a WARNING
> rather than silently ignore the error. We've ate enough unmatched
> annotations in user space (e.g. enable is skipped on an error path).
> These unmatched annotations are hard to notice (they suppress
> reports). So in user space we bark loudly on overflows/underflows and
> also check that a thread does not exit with enabled suppressions.
> 

For me, when WARNING on something, it will dummy the related feature
which should be used (may let user's hope fail), but should not get the
negative result (hurt user's original work). So in our case:

 - When caller calls kasan_report_enabled(), kasan_depth-- to 0, 

 - When a caller calls kasan_report_enabled() again, the caller will get
   a warning, and notice about this calling is failed, but it is still
   in enable state, should not change to disable state automatically.

 - If we report an warning, but still kasan_depth--, it will let things
   much complex.

And for me, another improvements can be done:

 - signed int kasan_depth may be a little better. When kasan_depth > 0,
   it is in disable state, else in enable state. It will be much harder
   to generate overflow than unsigned int kasan_depth.

 - Let kasan_[en|dis]able_current() return Boolean value to notify the
   caller whether the calling succeeds or fails.

Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
