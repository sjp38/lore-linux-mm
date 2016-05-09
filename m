Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 23C676B0005
	for <linux-mm@kvack.org>; Mon,  9 May 2016 01:08:38 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y84so77375661lfc.3
        for <linux-mm@kvack.org>; Sun, 08 May 2016 22:08:38 -0700 (PDT)
Received: from mail-lf0-x22b.google.com (mail-lf0-x22b.google.com. [2a00:1450:4010:c07::22b])
        by mx.google.com with ESMTPS id d4si5092272lbw.200.2016.05.08.22.08.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 May 2016 22:08:36 -0700 (PDT)
Received: by mail-lf0-x22b.google.com with SMTP id u64so188060749lff.3
        for <linux-mm@kvack.org>; Sun, 08 May 2016 22:08:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1462538722-1574-4-git-send-email-aryabinin@virtuozzo.com>
References: <1462538722-1574-1-git-send-email-aryabinin@virtuozzo.com> <1462538722-1574-4-git-send-email-aryabinin@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 9 May 2016 07:08:17 +0200
Message-ID: <CACT4Y+YHMbd71u5omD8S5fRyxM-pqZBmkfoKSzrP79Lft2VGzg@mail.gmail.com>
Subject: Re: [PATCH 4/4] x86/kasan: Instrument user memory access API
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Alexander Potapenko <glider@google.com>, "x86@kernel.org" <x86@kernel.org>

On Fri, May 6, 2016 at 2:45 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> Exchange between user and kernel memory is coded in assembly language.
> Which means that such accesses won't be spotted by KASAN as a compiler
> instruments only C code.
> Add explicit KASAN checks to user memory access API to ensure that
> userspace writes to (or reads from) a valid kernel memory.
>
> Note: Unlike others strncpy_from_user() is written mostly in C and KASAN
> sees memory accesses in it. However, it makes sense to add explicit check
> for all @count bytes that *potentially* could be written to the kernel.


Reviewed-by: Dmitry Vyukov <dvyukov@google.com>

Thanks!


> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Alexander Potapenko <glider@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: x86@kernel.org
> ---
>  arch/x86/include/asm/uaccess.h    | 5 +++++
>  arch/x86/include/asm/uaccess_64.h | 7 +++++++
>  lib/strncpy_from_user.c           | 2 ++
>  3 files changed, 14 insertions(+)
>
> diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
> index 0b17fad..5dd6d18 100644
> --- a/arch/x86/include/asm/uaccess.h
> +++ b/arch/x86/include/asm/uaccess.h
> @@ -5,6 +5,7 @@
>   */
>  #include <linux/errno.h>
>  #include <linux/compiler.h>
> +#include <linux/kasan-checks.h>
>  #include <linux/thread_info.h>
>  #include <linux/string.h>
>  #include <asm/asm.h>
> @@ -732,6 +733,8 @@ copy_from_user(void *to, const void __user *from, unsigned long n)
>
>         might_fault();
>
> +       kasan_check_write(to, n);
> +
>         /*
>          * While we would like to have the compiler do the checking for us
>          * even in the non-constant size case, any false positives there are
> @@ -765,6 +768,8 @@ copy_to_user(void __user *to, const void *from, unsigned long n)
>  {
>         int sz = __compiletime_object_size(from);
>
> +       kasan_check_read(from, n);
> +
>         might_fault();
>
>         /* See the comment in copy_from_user() above. */
> diff --git a/arch/x86/include/asm/uaccess_64.h b/arch/x86/include/asm/uaccess_64.h
> index 3076986..2eac2aa 100644
> --- a/arch/x86/include/asm/uaccess_64.h
> +++ b/arch/x86/include/asm/uaccess_64.h
> @@ -7,6 +7,7 @@
>  #include <linux/compiler.h>
>  #include <linux/errno.h>
>  #include <linux/lockdep.h>
> +#include <linux/kasan-checks.h>
>  #include <asm/alternative.h>
>  #include <asm/cpufeatures.h>
>  #include <asm/page.h>
> @@ -109,6 +110,7 @@ static __always_inline __must_check
>  int __copy_from_user(void *dst, const void __user *src, unsigned size)
>  {
>         might_fault();
> +       kasan_check_write(dst, size);
>         return __copy_from_user_nocheck(dst, src, size);
>  }
>
> @@ -175,6 +177,7 @@ static __always_inline __must_check
>  int __copy_to_user(void __user *dst, const void *src, unsigned size)
>  {
>         might_fault();
> +       kasan_check_read(src, size);
>         return __copy_to_user_nocheck(dst, src, size);
>  }
>
> @@ -242,12 +245,14 @@ int __copy_in_user(void __user *dst, const void __user *src, unsigned size)
>  static __must_check __always_inline int
>  __copy_from_user_inatomic(void *dst, const void __user *src, unsigned size)
>  {
> +       kasan_check_write(dst, size);
>         return __copy_from_user_nocheck(dst, src, size);
>  }
>
>  static __must_check __always_inline int
>  __copy_to_user_inatomic(void __user *dst, const void *src, unsigned size)
>  {
> +       kasan_check_read(src, size);
>         return __copy_to_user_nocheck(dst, src, size);
>  }
>
> @@ -258,6 +263,7 @@ static inline int
>  __copy_from_user_nocache(void *dst, const void __user *src, unsigned size)
>  {
>         might_fault();
> +       kasan_check_write(dst, size);
>         return __copy_user_nocache(dst, src, size, 1);
>  }
>
> @@ -265,6 +271,7 @@ static inline int
>  __copy_from_user_inatomic_nocache(void *dst, const void __user *src,
>                                   unsigned size)
>  {
> +       kasan_check_write(dst, size);
>         return __copy_user_nocache(dst, src, size, 0);
>  }
>
> diff --git a/lib/strncpy_from_user.c b/lib/strncpy_from_user.c
> index 3384032..e3472b0 100644
> --- a/lib/strncpy_from_user.c
> +++ b/lib/strncpy_from_user.c
> @@ -1,5 +1,6 @@
>  #include <linux/compiler.h>
>  #include <linux/export.h>
> +#include <linux/kasan-checks.h>
>  #include <linux/uaccess.h>
>  #include <linux/kernel.h>
>  #include <linux/errno.h>
> @@ -103,6 +104,7 @@ long strncpy_from_user(char *dst, const char __user *src, long count)
>         if (unlikely(count <= 0))
>                 return 0;
>
> +       kasan_check_write(dst, count);
>         max_addr = user_addr_max();
>         src_addr = (unsigned long)src;
>         if (likely(src_addr < max_addr)) {
> --
> 2.7.3
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
