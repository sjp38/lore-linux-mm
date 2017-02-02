Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7F66B0272
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 19:39:49 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id y196so42054682ity.1
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 16:39:49 -0800 (PST)
Received: from mail-it0-x22e.google.com (mail-it0-x22e.google.com. [2607:f8b0:4001:c0b::22e])
        by mx.google.com with ESMTPS id j30si36364iod.233.2017.02.01.16.39.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 16:39:48 -0800 (PST)
Received: by mail-it0-x22e.google.com with SMTP id c7so30524324itd.1
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 16:39:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170201161311.2050831-1-arnd@arndb.de>
References: <20170201161311.2050831-1-arnd@arndb.de>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 1 Feb 2017 16:39:47 -0800
Message-ID: <CAGXu5jLc8z0Q-etB-=9rBnt-mNPKEL3t5rDooSwTyACPX2NW0g@mail.gmail.com>
Subject: Re: [PATCH] initity: try to improve __nocapture annotations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: PaX Team <pageexec@freemail.hu>, Emese Revfy <re.emese@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Josh Triplett <josh@joshtriplett.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, minipli@ld-linux.so, Russell King <linux@armlinux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Jeff Layton <jlayton@poochiereds.net>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, devel@acpica.org, linux-arch <linux-arch@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>

On Wed, Feb 1, 2017 at 8:11 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> There are some additional declarations that got missed in the original patch,
> and some annotated functions that use the pointer is a correct but nonobvious
> way:
>
> mm/kasan/kasan.c: In function 'memmove':
> mm/kasan/kasan.c:346:7: error: 'memmove' captures its 2 ('src') parameter, please remove it from the nocapture attribute. [-Werror]
>  void *memmove(void *dest, const void *src, size_t len)
>        ^~~~~~~
> mm/kasan/kasan.c: In function 'memcpy':
> mm/kasan/kasan.c:355:7: error: 'memcpy' captures its 2 ('src') parameter, please remove it from the nocapture attribute. [-Werror]
>  void *memcpy(void *dest, const void *src, size_t len)
>        ^~~~~~
> drivers/acpi/acpica/utdebug.c: In function 'acpi_debug_print':
> drivers/acpi/acpica/utdebug.c:158:1: error: 'acpi_debug_print' captures its 3 ('function_name') parameter, please remove it from the nocapture attribute. [-Werror]
>
> lib/string.c:893:7: error: 'memchr_inv' captures its 1 ('start') parameter, please remove it from the nocapture attribute. [-Werror]
>  void *memchr_inv(const void *start, int c, size_t bytes)
> lib/string.c: In function 'strnstr':
> lib/string.c:832:7: error: 'strnstr' captures its 1 ('s1') parameter, please remove it from the nocapture attribute. [-Werror]
>  char *strnstr(const char *s1, const char *s2, size_t len)
>        ^~~~~~~
> lib/string.c:832:7: error: 'strnstr' captures its 2 ('s2') parameter, please remove it from the nocapture attribute. [-Werror]
>
> I'm not sure if these are all appropriate fixes, please have a careful look
>
> Fixes: c2bc07665495 ("initify: Mark functions with the __nocapture attribute")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/acpi/acpica/utdebug.c        | 2 +-
>  include/acpi/acpixf.h                | 2 +-
>  include/asm-generic/asm-prototypes.h | 8 ++++----
>  include/linux/string.h               | 2 +-
>  lib/string.c                         | 2 +-
>  mm/kasan/kasan.c                     | 4 ++--
>  6 files changed, 10 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/acpi/acpica/utdebug.c b/drivers/acpi/acpica/utdebug.c
> index 044df9b0356e..de3c9cb305a2 100644
> --- a/drivers/acpi/acpica/utdebug.c
> +++ b/drivers/acpi/acpica/utdebug.c
> @@ -154,7 +154,7 @@ static const char *acpi_ut_trim_function_name(const char *function_name)
>   *
>   ******************************************************************************/
>
> -void ACPI_INTERNAL_VAR_XFACE
> +void __unverified_nocapture(3) ACPI_INTERNAL_VAR_XFACE
>  acpi_debug_print(u32 requested_debug_level,
>                  u32 line_number,
>                  const char *function_name,

This might be better by marking acpi_ut_trim_function_name() as
__nocapture. I'll give it a try...

> diff --git a/include/acpi/acpixf.h b/include/acpi/acpixf.h
> index 9f4637e9dd92..9644cec5b082 100644
> --- a/include/acpi/acpixf.h
> +++ b/include/acpi/acpixf.h
> @@ -946,7 +946,7 @@ ACPI_DBG_DEPENDENT_RETURN_VOID(ACPI_PRINTF_LIKE(6) __nocapture(3)
>                                                 const char *module_name,
>                                                 u32 component_id,
>                                                 const char *format, ...))
> -ACPI_DBG_DEPENDENT_RETURN_VOID(ACPI_PRINTF_LIKE(6)
> +ACPI_DBG_DEPENDENT_RETURN_VOID(ACPI_PRINTF_LIKE(6) __nocapture(3)
>                                 void ACPI_INTERNAL_VAR_XFACE
>                                 acpi_debug_print_raw(u32 requested_debug_level,
>                                                      u32 line_number,

I wonder why the plugin needs this at all: function_name (the third
arg) isn't even used in the function.

> diff --git a/include/asm-generic/asm-prototypes.h b/include/asm-generic/asm-prototypes.h
> index 939869c772b1..ffc0dd7e8ed2 100644
> --- a/include/asm-generic/asm-prototypes.h
> +++ b/include/asm-generic/asm-prototypes.h
> @@ -2,12 +2,12 @@
>  #undef __memset
>  extern void *__memset(void *, int, __kernel_size_t);
>  #undef __memcpy
> -extern void *__memcpy(void *, const void *, __kernel_size_t);
> +extern void *__memcpy(void *, const void *, __kernel_size_t) __nocapture(2);
>  #undef __memmove
> -extern void *__memmove(void *, const void *, __kernel_size_t);
> +extern void *__memmove(void *, const void *, __kernel_size_t) __nocapture(2);
>  #undef memset
>  extern void *memset(void *, int, __kernel_size_t);
>  #undef memcpy
> -extern void *memcpy(void *, const void *, __kernel_size_t);
> +extern void *memcpy(void *, const void *, __kernel_size_t) __nocapture(2);
>  #undef memmove
> -extern void *memmove(void *, const void *, __kernel_size_t);
> +extern void *memmove(void *, const void *, __kernel_size_t) __nocapture(2);

Ah yeah, KASAN. This seems correct.

> diff --git a/include/linux/string.h b/include/linux/string.h
> index 8b3b97e7b2b0..0ee877593464 100644
> --- a/include/linux/string.h
> +++ b/include/linux/string.h
> @@ -76,7 +76,7 @@ static inline __must_check char *strstrip(char *str)
>  extern char * strstr(const char *, const char *) __nocapture(-1, 2);
>  #endif
>  #ifndef __HAVE_ARCH_STRNSTR
> -extern char * strnstr(const char *, const char *, size_t) __nocapture(-1, 2);
> +extern char * strnstr(const char *, const char *, size_t);

That doesn't seem right: strnstr doesn't capture...

>  #endif
>  #ifndef __HAVE_ARCH_STRLEN
>  extern __kernel_size_t strlen(const char *) __nocapture(1);
> diff --git a/lib/string.c b/lib/string.c
> index ed83562a53ae..01151a1a0b61 100644
> --- a/lib/string.c
> +++ b/lib/string.c
> @@ -870,7 +870,7 @@ void *memchr(const void *s, int c, size_t n)
>  EXPORT_SYMBOL(memchr);
>  #endif
>
> -static void *check_bytes8(const u8 *start, u8 value, unsigned int bytes)
> +static __always_inline void *check_bytes8(const u8 *start, u8 value, unsigned int bytes)

Is this from another fix? Seems unrelated?

>  {
>         while (bytes) {
>                 if (*start != value)
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 5f6e09c88d25..ebc02ee1118e 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -343,7 +343,7 @@ void *memset(void *addr, int c, size_t len)
>  }
>
>  #undef memmove
> -void *memmove(void *dest, const void *src, size_t len)
> +__unverified_nocapture(2) void *memmove(void *dest, const void *src, size_t len)
>  {
>         check_memory_region((unsigned long)src, len, false, _RET_IP_);
>         check_memory_region((unsigned long)dest, len, true, _RET_IP_);
> @@ -352,7 +352,7 @@ void *memmove(void *dest, const void *src, size_t len)
>  }
>
>  #undef memcpy
> -void *memcpy(void *dest, const void *src, size_t len)
> +__unverified_nocapture(2) void *memcpy(void *dest, const void *src, size_t len)
>  {
>         check_memory_region((unsigned long)src, len, false, _RET_IP_);
>         check_memory_region((unsigned long)dest, len, true, _RET_IP_);
> --
> 2.9.0
>

Thanks for the patch! I'll try to reproduce the warnings and get some
fixes built if Emese or PaX Team don't beat me to it. :)

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
