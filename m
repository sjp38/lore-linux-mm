Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 056F16B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 11:08:41 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id sq19so200419701igc.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 08:08:41 -0700 (PDT)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id a35si16654185ioj.72.2016.05.02.08.08.38
        for <linux-mm@kvack.org>;
        Mon, 02 May 2016 08:08:39 -0700 (PDT)
Message-ID: <57276E95.1030201@emindsoft.com.cn>
Date: Mon, 02 May 2016 23:13:25 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/kasan/kasan.h: Fix boolean checking issue for kasan_report_enabled()
References: <1462167374-6321-1-git-send-email-chengang@emindsoft.com.cn>	<CACT4Y+Z7Yfsq9wjJuoeegEvPBvJs9iX6wN2VO1scA7HA4TVLmQ@mail.gmail.com>	<572735EB.8030300@emindsoft.com.cn>	<CACT4Y+Yrq4mt6c8wQKU7WcTnN7k28T3hM1V6_DWF-NpmuMH7Gw@mail.gmail.com>	<572747C2.5040009@emindsoft.com.cn>	<CAG_fn=VGJAGb71HU4rC9MNboqPqPs4EPgcWBfaiBpcgNQ2qFqA@mail.gmail.com>	<57275B71.8000907@emindsoft.com.cn> <CAG_fn=WBPcQ8HgG13RksM=v833Q4GmM4dXhFNa9ihhMnOWKLmA@mail.gmail.com>
In-Reply-To: <CAG_fn=WBPcQ8HgG13RksM=v833Q4GmM4dXhFNa9ihhMnOWKLmA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On 5/2/16 22:23, Alexander Potapenko wrote:
> On Mon, May 2, 2016 at 3:51 PM, Chen Gang <chengang@emindsoft.com.cn> wrote:
>>
>> OK, thanks.
>>
>> And for "kasan_depth == 1", I guess, its meaning is related with
>> kasan_depth[++|--] in kasan_[en|dis]able_current():
> Assuming you are talking about the assignment of 1 to kasan_depth in
> /include/linux/init_task.h,
> it's somewhat counterintuitive. I think we just need to replace it
> with kasan_disable_current(), and add a corresponding
> kasan_enable_current() to the end of kasan_init.
>

OK. But it does not look quite easy to use kasan_disable_current() for
INIT_KASAN which is used in INIT_TASK.

If we have to set "kasan_depth == 1", we have to use kasan_depth-- in
kasan_enable_current().
 
>>
>> OK, thanks.
>>
>> I guess, we are agree with each other: "We can both issue a WARNING and
>> prevent the actual overflow/underflow.".
> No, I am not sure think that we need to prevent the overflow.
> As I showed before, this may result in kasan_depth being off even in
> the case kasan_enable_current()/kasan_disable_current() are used
> consistently.

If we don't prevent the overflow, it will have negative effect with the
caller. When we issue an warning, it means the caller's hope fail, but
can not destroy the caller's original work. In our case:

 - Assume "kasan_depth-- for kasan_enable_current()", the first enable
   will let kasan_depth be 0.

 - If we don't prevent the overflow, 2nd enable will cause disable
   effect, which will destroy the caller's original work.

 - Enable/disable mismatch is caused by caller, we can issue warnings,
   and skip it (since it is not caused by us). But we can not generate
   new issues to the system only because of the caller's issue.


Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
