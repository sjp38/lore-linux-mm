Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D097C6B0253
	for <linux-mm@kvack.org>; Fri, 13 May 2016 08:15:28 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id j8so67094123lfd.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 05:15:28 -0700 (PDT)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id nq2si13019877lbc.188.2016.05.13.05.15.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 05:15:27 -0700 (PDT)
Received: by mail-lf0-x22f.google.com with SMTP id u64so87569168lff.3
        for <linux-mm@kvack.org>; Fri, 13 May 2016 05:15:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1462538722-1574-2-git-send-email-aryabinin@virtuozzo.com>
References: <1462538722-1574-1-git-send-email-aryabinin@virtuozzo.com>
	<1462538722-1574-2-git-send-email-aryabinin@virtuozzo.com>
Date: Fri, 13 May 2016 14:15:26 +0200
Message-ID: <CAG_fn=UBY_z1i+f6hUmMtf2R1CeWawNA9iwDVQ7rFNensiDgow@mail.gmail.com>
Subject: Re: [PATCH 2/4] mm/kasan: print name of mem[set,cpy,move]() caller in report
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>

On Fri, May 6, 2016 at 2:45 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> w=
rote:
> When bogus memory access happens in mem[set,cpy,move]() it's usually
> caller's fault. So don't blame mem[set,cpy,move]() in bug report, blame
> the caller instead.
>
> Before:
>         BUG: KASAN: out-of-bounds access in memset+0x23/0x40 at <address>
> After:
>         BUG: KASAN: out-of-bounds access in <memset_caller> at <address>
>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Alexander Potapenko <glider@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> ---
>  mm/kasan/kasan.c | 64 ++++++++++++++++++++++++++++++--------------------=
------
>  1 file changed, 34 insertions(+), 30 deletions(-)
>
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index ef2e87b..6e4072c 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -273,32 +273,36 @@ static __always_inline bool memory_is_poisoned(unsi=
gned long addr, size_t size)
>         return memory_is_poisoned_n(addr, size);
>  }
>
> -
> -static __always_inline void check_memory_region(unsigned long addr,
> -                                               size_t size, bool write)
> +static __always_inline void check_memory_region_inline(unsigned long add=
r,
> +                                               size_t size, bool write,
> +                                               unsigned long ret_ip)
>  {
>         if (unlikely(size =3D=3D 0))
>                 return;
>
>         if (unlikely((void *)addr <
>                 kasan_shadow_to_mem((void *)KASAN_SHADOW_START))) {
> -               kasan_report(addr, size, write, _RET_IP_);
> +               kasan_report(addr, size, write, ret_ip);
>                 return;
>         }
>
>         if (likely(!memory_is_poisoned(addr, size)))
>                 return;
>
> -       kasan_report(addr, size, write, _RET_IP_);
> +       kasan_report(addr, size, write, ret_ip);
>  }
>
> -void __asan_loadN(unsigned long addr, size_t size);
> -void __asan_storeN(unsigned long addr, size_t size);
> +static void check_memory_region(unsigned long addr,
> +                               size_t size, bool write,
> +                               unsigned long ret_ip)
> +{
> +       check_memory_region_inline(addr, size, write, ret_ip);
> +}
>
>  #undef memset
>  void *memset(void *addr, int c, size_t len)
>  {
> -       __asan_storeN((unsigned long)addr, len);
> +       check_memory_region((unsigned long)addr, len, true, _RET_IP_);
>
>         return __memset(addr, c, len);
>  }
> @@ -306,8 +310,8 @@ void *memset(void *addr, int c, size_t len)
>  #undef memmove
>  void *memmove(void *dest, const void *src, size_t len)
>  {
> -       __asan_loadN((unsigned long)src, len);
> -       __asan_storeN((unsigned long)dest, len);
> +       check_memory_region((unsigned long)src, len, false, _RET_IP_);
> +       check_memory_region((unsigned long)dest, len, true, _RET_IP_);
>
>         return __memmove(dest, src, len);
>  }
> @@ -315,8 +319,8 @@ void *memmove(void *dest, const void *src, size_t len=
)
>  #undef memcpy
>  void *memcpy(void *dest, const void *src, size_t len)
>  {
> -       __asan_loadN((unsigned long)src, len);
> -       __asan_storeN((unsigned long)dest, len);
> +       check_memory_region((unsigned long)src, len, false, _RET_IP_);
> +       check_memory_region((unsigned long)dest, len, true, _RET_IP_);
>
>         return __memcpy(dest, src, len);
>  }
> @@ -698,22 +702,22 @@ void __asan_unregister_globals(struct kasan_global =
*globals, size_t size)
>  }
>  EXPORT_SYMBOL(__asan_unregister_globals);
>
> -#define DEFINE_ASAN_LOAD_STORE(size)                           \
> -       void __asan_load##size(unsigned long addr)              \
> -       {                                                       \
> -               check_memory_region(addr, size, false);         \
> -       }                                                       \
> -       EXPORT_SYMBOL(__asan_load##size);                       \
> -       __alias(__asan_load##size)                              \
> -       void __asan_load##size##_noabort(unsigned long);        \
> -       EXPORT_SYMBOL(__asan_load##size##_noabort);             \
> -       void __asan_store##size(unsigned long addr)             \
> -       {                                                       \
> -               check_memory_region(addr, size, true);          \
> -       }                                                       \
> -       EXPORT_SYMBOL(__asan_store##size);                      \
> -       __alias(__asan_store##size)                             \
> -       void __asan_store##size##_noabort(unsigned long);       \
> +#define DEFINE_ASAN_LOAD_STORE(size)                                   \
> +       void __asan_load##size(unsigned long addr)                      \
> +       {                                                               \
> +               check_memory_region_inline(addr, size, false, _RET_IP_);\
> +       }                                                               \
> +       EXPORT_SYMBOL(__asan_load##size);                               \
> +       __alias(__asan_load##size)                                      \
> +       void __asan_load##size##_noabort(unsigned long);                \
> +       EXPORT_SYMBOL(__asan_load##size##_noabort);                     \
> +       void __asan_store##size(unsigned long addr)                     \
> +       {                                                               \
> +               check_memory_region_inline(addr, size, true, _RET_IP_); \
> +       }                                                               \
> +       EXPORT_SYMBOL(__asan_store##size);                              \
> +       __alias(__asan_store##size)                                     \
> +       void __asan_store##size##_noabort(unsigned long);               \
>         EXPORT_SYMBOL(__asan_store##size##_noabort)
>
>  DEFINE_ASAN_LOAD_STORE(1);
> @@ -724,7 +728,7 @@ DEFINE_ASAN_LOAD_STORE(16);
>
>  void __asan_loadN(unsigned long addr, size_t size)
>  {
> -       check_memory_region(addr, size, false);
> +       check_memory_region(addr, size, false, _RET_IP_);
>  }
>  EXPORT_SYMBOL(__asan_loadN);
>
> @@ -734,7 +738,7 @@ EXPORT_SYMBOL(__asan_loadN_noabort);
>
>  void __asan_storeN(unsigned long addr, size_t size)
>  {
> -       check_memory_region(addr, size, true);
> +       check_memory_region(addr, size, true, _RET_IP_);
>  }
>  EXPORT_SYMBOL(__asan_storeN);
>
> --Reviewed-by:
> 2.7.3
>
Acked-by: Alexander Potapenko <glider@google.com>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
