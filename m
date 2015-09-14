Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id D37736B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 11:17:21 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so145490788wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:17:21 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id p11si19235572wjw.192.2015.09.14.08.17.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 08:17:20 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so144986133wic.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:17:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55F62C65.7070100@huawei.com>
References: <55F62C65.7070100@huawei.com>
Date: Mon, 14 Sep 2015 18:17:19 +0300
Message-ID: <CAPAsAGxf_OQD502cW1nbXJ7WdRxyKqTx6+BJJpJoD-Z6WFCZMg@mail.gmail.com>
Subject: Re: [PATCH V2] kasan: use IS_ALIGNED in memory_is_poisoned_8()
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <adech.fo@gmail.com>, Rusty Russell <rusty@rustcorp.com.au>, Michal Marek <mmarek@suse.cz>, "long.wanglong" <long.wanglong@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2015-09-14 5:09 GMT+03:00 Xishi Qiu <qiuxishi@huawei.com>:
> Use IS_ALIGNED() to determine whether the shadow span two bytes.
> It generates less code and more readable. Add some comments in
> shadow check functions.
>
> Please apply "kasan: fix last shadow judgement in memory_is_poisoned_16()"
> first.
>
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  mm/kasan/kasan.c | 21 +++++++++++++++++++--
>  1 file changed, 19 insertions(+), 2 deletions(-)
>
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 8da2114..00d5605 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -86,6 +86,10 @@ static __always_inline bool memory_is_poisoned_2(unsigned long addr)
>                 if (memory_is_poisoned_1(addr + 1))
>                         return true;
>
> +               /*
> +                * If the shadow spans two bytes, the first byte should
> +                * be zero.

Hmm.. I found this comment a bit odd.

How about this:
/*
 * If single shadow byte covers 2-byte access,
 * we don't need to do anything more.
 * Otherwise, test the first shadow byte.
 */

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
