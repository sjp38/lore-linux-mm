Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 21CD76B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 08:36:12 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id n2so364044952obo.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 05:36:12 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id b14si12507977iob.63.2016.05.02.05.36.08
        for <linux-mm@kvack.org>;
        Mon, 02 May 2016 05:36:10 -0700 (PDT)
Message-ID: <57274ADA.8060606@emindsoft.com.cn>
Date: Mon, 02 May 2016 20:40:58 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH] include/linux/kasan.h: Notice about 0 for kasan_[dis/en]able_current()
References: <1462167348-6280-1-git-send-email-chengang@emindsoft.com.cn>	<CAG_fn=W5Ai_cqhzyi=EBEyhhQtvoQtOsuyfBfRihf=fuKh2Xqw@mail.gmail.com>	<572737FB.2020405@emindsoft.com.cn> <CAG_fn=W7m0UN6-38Ut0c-a_m4BfuUPjrmHQThGCLLqV-brKTmA@mail.gmail.com>
In-Reply-To: <CAG_fn=W7m0UN6-38Ut0c-a_m4BfuUPjrmHQThGCLLqV-brKTmA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitriy Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On 5/2/16 19:23, Alexander Potapenko wrote:
> On Mon, May 2, 2016 at 1:20 PM, Chen Gang <chengang@emindsoft.com.cn> wrote:
>> On 5/2/16 18:49, Alexander Potapenko wrote:
>>> On Mon, May 2, 2016 at 7:35 AM,  <chengang@emindsoft.com.cn> wrote:
>>>>
>>>> According to their comments and the kasan_depth's initialization, if
>>>> kasan_depth is zero, it means disable. So kasan_depth need consider
>>>> about the 0 overflow.
>>>>
>>>> Also remove useless comments for dummy kasan_slab_free().
>>>>
>>>> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
>>>
>>> Acked-by: Alexander Potapenko <glider@google.com>
> Nacked-by: Alexander Potapenko <glider@google.com>
>>>
>>
>> OK, thanks.
> Well, on a second thought I take that back, there still might be problems.
> I haven't noticed the other CL, and was too hasty reviewing this one.
> 
> As kasan_disable_current() and kasan_enable_current() always go
> together, we need to prevent nested calls to them from breaking
> everything.
> If we ignore some calls to kasan_disable_current() to prevent
> overflows, the pairing calls to kasan_enable_current() will bring
> |current->kasan_depth| to an invalid state.
> 
> E.g. if I'm understanding your idea correctly, after the following
> sequence of calls:
>   kasan_disable_current();  // #1
>   kasan_disable_current();  // #2
>   kasan_enable_current();  // #3
>   kasan_enable_current();  // #4
> 
> the value of |current->kasan_depth| will be 2, so a single subsequent
> call to kasan_disable_current() won't disable KASAN.
> 
> I think we'd better add BUG checks to bail out if the value of
> |current->kasan_depth| is too big or too small.
> 

For me, BUG_ON is OK. e.g.

 - BUG_ON(!kasan_depth) as soon as be in kasan_enable_current().

 - BUG_ON(!(kasan_depth - 1)) as soon as be in kasan_disable_current().

Welcome another members ideas, if no any additional reply within 3 days,
I shall send patch v2 for it.


Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
