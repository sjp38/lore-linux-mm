Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id E036C6B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 13:46:10 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id 23so8862451uaj.5
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 10:46:10 -0700 (PDT)
Received: from mail-ua0-x232.google.com (mail-ua0-x232.google.com. [2607:f8b0:400c:c08::232])
        by mx.google.com with ESMTPS id c8si9306087uaf.244.2017.06.01.10.46.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 10:46:09 -0700 (PDT)
Received: by mail-ua0-x232.google.com with SMTP id y4so31845177uay.2
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 10:46:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170601162338.23540-1-aryabinin@virtuozzo.com>
References: <20170601162338.23540-1-aryabinin@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 1 Jun 2017 19:45:48 +0200
Message-ID: <CACT4Y+bFjAuMShPDzuSa9W6rYx2yKhdeh-UkfMyGpPxbH5yp6Q@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm/kasan: get rid of speculative shadow checks
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 1, 2017 at 6:23 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> For some unaligned memory accesses we have to check additional
> byte of the shadow memory. Currently we load that byte speculatively
> to have only single load + branch on the optimistic fast path.
>
> However, this approach have some downsides:
>  - It's unaligned access, so this prevents porting KASAN on architectures
>     which doesn't support unaligned accesses.
>  - We have to map additional shadow page to prevent crash if
>     speculative load happens near the end of the mapped memory.
>     This would significantly complicate upcoming memory hotplug support.
>
> I wasn't able to notice any performance degradation with this patch.
> So these speculative loads is just a pain with no gain, let's remove
> them.
>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>


Acked-by: Dmitry Vyukov <dvyukov@google.com>

> ---
>  mm/kasan/kasan.c | 98 +++++++++-----------------------------------------------
>  1 file changed, 16 insertions(+), 82 deletions(-)
>
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 85ee45b07615..e6fe07a98677 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -134,94 +134,30 @@ static __always_inline bool memory_is_poisoned_1(unsigned long addr)
>         return false;
>  }
>
> -static __always_inline bool memory_is_poisoned_2(unsigned long addr)
> +static __always_inline bool memory_is_poisoned_2_4_8(unsigned long addr,
> +                                               unsigned long size)
>  {
> -       u16 *shadow_addr = (u16 *)kasan_mem_to_shadow((void *)addr);
> -
> -       if (unlikely(*shadow_addr)) {
> -               if (memory_is_poisoned_1(addr + 1))
> -                       return true;
> -
> -               /*
> -                * If single shadow byte covers 2-byte access, we don't
> -                * need to do anything more. Otherwise, test the first
> -                * shadow byte.
> -                */
> -               if (likely(((addr + 1) & KASAN_SHADOW_MASK) != 0))
> -                       return false;
> -
> -               return unlikely(*(u8 *)shadow_addr);
> -       }
> +       u8 *shadow_addr = (u8 *)kasan_mem_to_shadow((void *)addr);
>
> -       return false;
> -}
> -
> -static __always_inline bool memory_is_poisoned_4(unsigned long addr)
> -{
> -       u16 *shadow_addr = (u16 *)kasan_mem_to_shadow((void *)addr);
> -
> -       if (unlikely(*shadow_addr)) {
> -               if (memory_is_poisoned_1(addr + 3))
> -                       return true;
> -
> -               /*
> -                * If single shadow byte covers 4-byte access, we don't
> -                * need to do anything more. Otherwise, test the first
> -                * shadow byte.
> -                */
> -               if (likely(((addr + 3) & KASAN_SHADOW_MASK) >= 3))
> -                       return false;
> -
> -               return unlikely(*(u8 *)shadow_addr);
> -       }
> -
> -       return false;
> -}
> -
> -static __always_inline bool memory_is_poisoned_8(unsigned long addr)
> -{
> -       u16 *shadow_addr = (u16 *)kasan_mem_to_shadow((void *)addr);
> -
> -       if (unlikely(*shadow_addr)) {
> -               if (memory_is_poisoned_1(addr + 7))
> -                       return true;
> -
> -               /*
> -                * If single shadow byte covers 8-byte access, we don't
> -                * need to do anything more. Otherwise, test the first
> -                * shadow byte.
> -                */
> -               if (likely(IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
> -                       return false;
> -
> -               return unlikely(*(u8 *)shadow_addr);
> -       }
> +       /*
> +        * Access crosses 8(shadow size)-byte boundary. Such access maps
> +        * into 2 shadow bytes, so we need to check them both.
> +        */
> +       if (unlikely(((addr + size - 1) & KASAN_SHADOW_MASK) < size - 1))
> +               return *shadow_addr || memory_is_poisoned_1(addr + size - 1);
>
> -       return false;
> +       return memory_is_poisoned_1(addr + size - 1);
>  }
>
>  static __always_inline bool memory_is_poisoned_16(unsigned long addr)
>  {
> -       u32 *shadow_addr = (u32 *)kasan_mem_to_shadow((void *)addr);
> -
> -       if (unlikely(*shadow_addr)) {
> -               u16 shadow_first_bytes = *(u16 *)shadow_addr;
> -
> -               if (unlikely(shadow_first_bytes))
> -                       return true;
> -
> -               /*
> -                * If two shadow bytes covers 16-byte access, we don't
> -                * need to do anything more. Otherwise, test the last
> -                * shadow byte.
> -                */
> -               if (likely(IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
> -                       return false;
> +       u16 *shadow_addr = (u16 *)kasan_mem_to_shadow((void *)addr);
>
> -               return memory_is_poisoned_1(addr + 15);
> -       }
> +       /* Unaligned 16-bytes access maps into 3 shadow bytes. */
> +       if (unlikely(!IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
> +               return *shadow_addr || memory_is_poisoned_1(addr + 15);
>
> -       return false;
> +       return *shadow_addr;
>  }
>
>  static __always_inline unsigned long bytes_is_nonzero(const u8 *start,
> @@ -292,11 +228,9 @@ static __always_inline bool memory_is_poisoned(unsigned long addr, size_t size)
>                 case 1:
>                         return memory_is_poisoned_1(addr);
>                 case 2:
> -                       return memory_is_poisoned_2(addr);
>                 case 4:
> -                       return memory_is_poisoned_4(addr);
>                 case 8:
> -                       return memory_is_poisoned_8(addr);
> +                       return memory_is_poisoned_2_4_8(addr, size);
>                 case 16:
>                         return memory_is_poisoned_16(addr);
>                 default:
> --
> 2.13.0
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
