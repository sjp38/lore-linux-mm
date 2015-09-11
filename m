Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0153D6B0038
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 18:47:33 -0400 (EDT)
Received: by qgt47 with SMTP id 47so75029147qgt.2
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 15:47:32 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g77si2201120qhc.64.2015.09.11.15.47.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Sep 2015 15:47:32 -0700 (PDT)
Date: Fri, 11 Sep 2015 15:47:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] kasan: use IS_ALIGNED in memory_is_poisoned_8()
Message-Id: <20150911154730.3a2151a0b111fed01acdaaa1@linux-foundation.org>
In-Reply-To: <55F23635.1010109@huawei.com>
References: <55F23635.1010109@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Rusty Russell <rusty@rustcorp.com.au>, Michal Marek <mmarek@suse.cz>, "long.wanglong" <long.wanglong@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>

On Fri, 11 Sep 2015 10:02:29 +0800 Xishi Qiu <qiuxishi@huawei.com> wrote:

> Use IS_ALIGNED() to determine whether the shadow span two bytes.
> It generates less code and more readable.
> 

Please cc Andrey Ryabinin on kasan patches.

> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -120,7 +120,7 @@ static __always_inline bool memory_is_poisoned_8(unsigned long addr)
>  		if (memory_is_poisoned_1(addr + 7))
>  			return true;
>  
> -		if (likely(((addr + 7) & KASAN_SHADOW_MASK) >= 7))
> +		if (likely(IS_ALIGNED(addr, 8)))
>  			return false;

Wouldn't IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE) be more appropriate?

But I'm not really sure what the original code is trying to do.

	if ((addr + 7) & 7) >= 7)

can only evaluate true if ((addr + 7) & 7) equals 7, so the ">=" could
be "==".

I think.  The code looks a bit weird.  A code comment would help.

And how come memory_is_poisoned_16() does IS_ALIGNED(addr, 8)?  Should
it be 16?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
