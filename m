Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 866866B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 05:40:15 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so147531304wic.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 02:40:15 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id wb10si3550165wic.81.2015.09.09.02.40.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 02:40:14 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so14644623wic.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 02:40:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1441771180-206648-3-git-send-email-long.wanglong@huawei.com>
References: <1441771180-206648-1-git-send-email-long.wanglong@huawei.com>
	<1441771180-206648-3-git-send-email-long.wanglong@huawei.com>
Date: Wed, 9 Sep 2015 12:40:13 +0300
Message-ID: <CAPAsAGyDO+bXf4zS1wxv0fCGqyC4b9MLJCFWAhpW8E8iSwz-NA@mail.gmail.com>
Subject: Re: [PATCH 2/2] kasan: Fix a type conversion error
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Long <long.wanglong@huawei.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, wanglong@laoqinren.net, peifeiyue@huawei.com, morgan.wang@huawei.com

2015-09-09 6:59 GMT+03:00 Wang Long <long.wanglong@huawei.com>:
> The current KASAN code can find the following out-of-bounds
> bugs:
>         char *ptr;
>         ptr = kmalloc(8, GFP_KERNEL);
>         memset(ptr+7, 0, 2);
>
> the cause of the problem is the type conversion error in
> *memory_is_poisoned_n* function. So this patch fix that.
>
> Signed-off-by: Wang Long <long.wanglong@huawei.com>
> ---
>  mm/kasan/kasan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 7b28e9c..5d65d06 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -204,7 +204,7 @@ static __always_inline bool memory_is_poisoned_n(unsigned long addr,
>                 s8 *last_shadow = (s8 *)kasan_mem_to_shadow((void *)last_byte);
>
>                 if (unlikely(ret != (unsigned long)last_shadow ||
> -                       ((last_byte & KASAN_SHADOW_MASK) >= *last_shadow)))
> +                       ((long)(last_byte & KASAN_SHADOW_MASK) >= *last_shadow)))

Is there any problem if we just define last_byte as 'long' instead of
'unsigned long' ?

>                         return true;
>         }
>         return false;
> --
> 1.8.3.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
