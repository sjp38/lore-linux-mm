Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4716B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 05:36:26 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so108232150wic.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 02:36:25 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id gc6si5735771wic.19.2015.09.08.02.36.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 02:36:25 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so108231759wic.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 02:36:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55EE3D03.8000502@huawei.com>
References: <55EE3D03.8000502@huawei.com>
Date: Tue, 8 Sep 2015 12:36:24 +0300
Message-ID: <CAPAsAGwo73yh9p0GVN9Rt+U-UonJ-V7y4ZU+LfE17MDSrQpjDA@mail.gmail.com>
Subject: Re: [PATCH] kasan: fix last shadow judgement in memory_is_poisoned_16()
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <adech.fo@gmail.com>, Rusty Russell <rusty@rustcorp.com.au>, Michal Marek <mmarek@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhongjiang@huawei.com

2015-09-08 4:42 GMT+03:00 Xishi Qiu <qiuxishi@huawei.com>:
> The shadow which correspond 16 bytes may span 2 or 3 bytes. If shadow
> only take 2 bytes, we can return in "if (likely(!last_byte)) ...", but
> it calculates wrong, so fix it.
>

Please, be more specific. Describe what is wrong with the current code and why,
what's the effect of this bug and how you fixed it.


> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  mm/kasan/kasan.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
>
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 7b28e9c..8da2114 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -135,12 +135,11 @@ static __always_inline bool memory_is_poisoned_16(unsigned long addr)
>
>         if (unlikely(*shadow_addr)) {
>                 u16 shadow_first_bytes = *(u16 *)shadow_addr;
> -               s8 last_byte = (addr + 15) & KASAN_SHADOW_MASK;
>
>                 if (unlikely(shadow_first_bytes))
>                         return true;
>
> -               if (likely(!last_byte))
> +               if (likely(IS_ALIGNED(addr, 8)))
>                         return false;
>
>                 return memory_is_poisoned_1(addr + 15);
> --
> 1.7.1
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
