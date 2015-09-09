Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4DD6B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 03:01:11 -0400 (EDT)
Received: by obbbh8 with SMTP id bh8so724541obb.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 00:01:10 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id pu4si4068518obb.76.2015.09.09.00.01.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 09 Sep 2015 00:01:10 -0700 (PDT)
Message-ID: <55EFD46A.20309@huawei.com>
Date: Wed, 9 Sep 2015 14:40:42 +0800
From: "long.wanglong" <long.wanglong@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2] kasan: fix last shadow judgement in memory_is_poisoned_16()
References: <55EED09E.3010107@huawei.com>
In-Reply-To: <55EED09E.3010107@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, ryabinin.a.a@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <adech.fo@gmail.com>, Rusty Russell <rusty@rustcorp.com.au>, Michal Marek <mmarek@suse.cz>, zhongjiang@huawei.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wang Long <long.wanglong@huawei.com>

On 2015/9/8 20:12, Xishi Qiu wrote:
> The shadow which correspond 16 bytes memory may span 2 or 3 bytes. If the
> memory is aligned on 8, then the shadow takes only 2 bytes. So we check
> "shadow_first_bytes" is enough, and need not to call "memory_is_poisoned_1(addr + 15);".
> But the code "if (likely(!last_byte))" is wrong judgement.
> 
> e.g. addr=0, so last_byte = 15 & KASAN_SHADOW_MASK = 7, then the code will
> continue to call "memory_is_poisoned_1(addr + 15);"
> 
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
>  	if (unlikely(*shadow_addr)) {
>  		u16 shadow_first_bytes = *(u16 *)shadow_addr;
> -		s8 last_byte = (addr + 15) & KASAN_SHADOW_MASK;
>  
>  		if (unlikely(shadow_first_bytes))
>  			return true;
>  
> -		if (likely(!last_byte))
> +		if (likely(IS_ALIGNED(addr, 8)))
>  			return false;
>  
>  		return memory_is_poisoned_1(addr + 15);
> 

Hi,
I also notice this problem, how about another method to fix it:

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 5d65d06..6a20dda 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -140,7 +140,7 @@ static __always_inline bool memory_is_poisoned_16(unsigned long addr)
                if (unlikely(shadow_first_bytes))
                        return true;

-               if (likely(!last_byte))
+               if (likely(last_byte >= 7))
                        return false;

                return memory_is_poisoned_1(addr + 15);

This method can ensure consistency of code, for example, in memory_is_poisoned_8:

static __always_inline bool memory_is_poisoned_8(unsigned long addr)
{
        u16 *shadow_addr = (u16 *)kasan_mem_to_shadow((void *)addr);

        if (unlikely(*shadow_addr)) {
                if (memory_is_poisoned_1(addr + 7))
                        return true;

                if (likely(((addr + 7) & KASAN_SHADOW_MASK) >= 7))
                        return false;

                return unlikely(*(u8 *)shadow_addr);
        }

        return false;
}

Otherwise, we also should use IS_ALIGNED macro in memory_is_poisoned_8!


Best Regards
Wang Long




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
