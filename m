Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3C58E0038
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 21:27:04 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id d13so952741wrr.6
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 18:27:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q4sor36287638wru.28.2019.01.07.18.27.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 18:27:02 -0800 (PST)
Date: Mon, 7 Jan 2019 19:26:59 -0700
From: Nathan Chancellor <natechancellor@gmail.com>
Subject: Re: [PATCH] kasan: fix kasan_check_read/write definitions
Message-ID: <20190108022659.GA13470@flashbox>
References: <20181211133453.2835077-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181211133453.2835077-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Anders Roxell <anders.roxell@linaro.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey Konovalov <andreyknvl@google.com>, Stephen Rothwell <sfr@canb.auug.org.au>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 11, 2018 at 02:34:35PM +0100, Arnd Bergmann wrote:
> Building little-endian allmodconfig kernels on arm64 started failing
> with the generated atomic.h implementation, since we now try to call
> kasan helpers from the EFI stub:
> 
> aarch64-linux-gnu-ld: drivers/firmware/efi/libstub/arm-stub.stub.o: in function `atomic_set':
> include/generated/atomic-instrumented.h:44: undefined reference to `__efistub_kasan_check_write'
> 
> I suspect that we get similar problems in other files that explicitly
> disable KASAN for some reason but call atomic_t based helper functions.
> 
> We can fix this by checking the predefined __SANITIZE_ADDRESS__ macro
> that the compiler sets instead of checking CONFIG_KASAN, but this in turn
> requires a small hack in mm/kasan/common.c so we do see the extern
> declaration there instead of the inline function.
> 
> Fixes: b1864b828644 ("locking/atomics: build atomic headers as required")
> Reported-by: Anders Roxell <anders.roxell@linaro.org>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  include/linux/kasan-checks.h | 2 +-
>  mm/kasan/common.c            | 2 ++
>  2 files changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/kasan-checks.h b/include/linux/kasan-checks.h
> index d314150658a4..a61dc075e2ce 100644
> --- a/include/linux/kasan-checks.h
> +++ b/include/linux/kasan-checks.h
> @@ -2,7 +2,7 @@
>  #ifndef _LINUX_KASAN_CHECKS_H
>  #define _LINUX_KASAN_CHECKS_H
>  
> -#ifdef CONFIG_KASAN
> +#if defined(__SANITIZE_ADDRESS__) || defined(__KASAN_INTERNAL)
>  void kasan_check_read(const volatile void *p, unsigned int size);
>  void kasan_check_write(const volatile void *p, unsigned int size);
>  #else
> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index 03d5d1374ca7..51a7932c33a3 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -14,6 +14,8 @@
>   *
>   */
>  
> +#define __KASAN_INTERNAL
> +
>  #include <linux/export.h>
>  #include <linux/interrupt.h>
>  #include <linux/init.h>
> -- 
> 2.20.0
> 

Hi all,

Was there any other movement on this patch? I am noticing this fail as
well and I have applied this patch in the meantime; it would be nice for
it to be merged so I could drop it from my stack.

Thanks,
Nathan
