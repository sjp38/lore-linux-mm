Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id CDA226B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 08:04:58 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id rd14so218400437obb.3
        for <linux-mm@kvack.org>; Mon, 02 May 2016 05:04:58 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id oo7si13153256igb.67.2016.05.02.05.04.56
        for <linux-mm@kvack.org>;
        Mon, 02 May 2016 05:04:58 -0700 (PDT)
Message-ID: <5727438A.1040409@emindsoft.com.cn>
Date: Mon, 02 May 2016 20:09:46 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/kasan/kasan.h: Fix boolean checking issue for kasan_report_enabled()
References: <1462167374-6321-1-git-send-email-chengang@emindsoft.com.cn> <CAG_fn=UdYpYQCyQ0JGD6VxNvNmZBChX-cTdaR5xm1S6BgP-Gnw@mail.gmail.com>
In-Reply-To: <CAG_fn=UdYpYQCyQ0JGD6VxNvNmZBChX-cTdaR5xm1S6BgP-Gnw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitriy Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On 5/2/16 19:34, Alexander Potapenko wrote:
> On Mon, May 2, 2016 at 7:36 AM,  <chengang@emindsoft.com.cn> wrote:
>> From: Chen Gang <chengang@emindsoft.com.cn>
>>
>> According to kasan_[dis|en]able_current() comments and the kasan_depth'
>> s initialization, if kasan_depth is zero, it means disable.
> The comments for those functions are really poor, but there's nothing
> there that says kasan_depth==0 disables KASAN.
> Actually, kasan_report_enabled() is currently the only place that
> denotes the semantics of kasan_depth, so it couldn't be wrong.
> 
> init_task.kasan_depth is 1 during bootstrap and is then set to zero by
> kasan_init()
> For every other thread, current->kasan_depth is zero-initialized.
> 

OK, what you said sound reasonable to me. and do you also mean:

 - kasan_depth == 0 means enable KASAN, others means disable KASAN.

 - If always let kasan_[en|dis]able_current() be pair, and notice about
   the overflow, it should be OK: "kasan_enable_current() can let
   kasan_depth++, and kasan_disable_current() will let kasan_depth--".

 - If we check the related overflow, "kasan_depth == 1" mean "the KASAN
   should be always in disable state".


Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
