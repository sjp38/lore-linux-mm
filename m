Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id A13086B025B
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 09:19:26 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so141555781wic.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:19:26 -0700 (PDT)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com. [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id im9si18605614wjb.38.2015.09.14.06.19.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 06:19:25 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so141555048wic.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:19:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150911154730.3a2151a0b111fed01acdaaa1@linux-foundation.org>
References: <55F23635.1010109@huawei.com>
	<20150911154730.3a2151a0b111fed01acdaaa1@linux-foundation.org>
Date: Mon, 14 Sep 2015 16:19:24 +0300
Message-ID: <CAPAsAGxq8pKuGpmZ9T-JB_3MP+QcTgsUpFOv-0u2a+tqfkej9w@mail.gmail.com>
Subject: Re: [PATCH] kasan: use IS_ALIGNED in memory_is_poisoned_8()
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrey Konovalov <adech.fo@gmail.com>, Rusty Russell <rusty@rustcorp.com.au>, Michal Marek <mmarek@suse.cz>, "long.wanglong" <long.wanglong@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2015-09-12 1:47 GMT+03:00 Andrew Morton <akpm@linux-foundation.org>:
> On Fri, 11 Sep 2015 10:02:29 +0800 Xishi Qiu <qiuxishi@huawei.com> wrote:
>> -             if (likely(((addr + 7) & KASAN_SHADOW_MASK) >= 7))
>> +             if (likely(IS_ALIGNED(addr, 8)))
>>                       return false;
>
> Wouldn't IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE) be more appropriate?
>
> But I'm not really sure what the original code is trying to do.
>

Original code is trying to estimate whether we should check 2 shadow
bytes or just 1 should be enough.

>         if ((addr + 7) & 7) >= 7)
>
> can only evaluate true if ((addr + 7) & 7) equals 7, so the ">=" could
> be "==".
>

Yes, it could be "==".
">=" is just for consistency with similar code in memory_is_poisoned_2/4.

If I'm not mistaken generic formula for such check looks like this:
        ((addr + size - 1) & KASAN_SHADOW_MASK) >= ((size - 1) &
KASAN_SHADOW_MASK)

But when size >= KASAN_SHADOW_SCALE_SIZE we could just check for alignment.

> I think.  The code looks a bit weird.  A code comment would help.
>
> And how come memory_is_poisoned_16() does IS_ALIGNED(addr, 8)?  Should
> it be 16?
>

No, If 16 bytes are 8-byte aligned, then shadow is 2-bytes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
