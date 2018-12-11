Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 02DCA8E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 10:28:46 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x15so7134259edd.2
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 07:28:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k26sor8182415edd.12.2018.12.11.07.28.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 07:28:44 -0800 (PST)
Date: Tue, 11 Dec 2018 16:28:41 +0100
From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v13 05/25] kasan: add CONFIG_KASAN_GENERIC and
 CONFIG_KASAN_SW_TAGS
Message-ID: <20181211152840.ezjujzpyz5z6fd2d@ltop.local>
References: <cover.1544099024.git.andreyknvl@google.com>
 <b2550106eb8a68b10fefbabce820910b115aa853.1544099024.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b2550106eb8a68b10fefbabce820910b115aa853.1544099024.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Thu, Dec 06, 2018 at 01:24:23PM +0100, Andrey Konovalov wrote:
> diff --git a/include/linux/compiler-clang.h b/include/linux/compiler-clang.h
> index 3e7dafb3ea80..39f668d5066b 100644
> --- a/include/linux/compiler-clang.h
> +++ b/include/linux/compiler-clang.h
> @@ -16,9 +16,13 @@
>  /* all clang versions usable with the kernel support KASAN ABI version 5 */
>  #define KASAN_ABI_VERSION 5
>  
> +#if __has_feature(address_sanitizer) || __has_feature(hwaddress_sanitizer)
>  /* emulate gcc's __SANITIZE_ADDRESS__ flag */
> -#if __has_feature(address_sanitizer)
>  #define __SANITIZE_ADDRESS__
> +#define __no_sanitize_address \
> +		__attribute__((no_sanitize("address", "hwaddress")))
> +#else
> +#define __no_sanitize_address
>  #endif
>  
>  /*
> diff --git a/include/linux/compiler-gcc.h b/include/linux/compiler-gcc.h
> index 2010493e1040..5776da43da97 100644
> --- a/include/linux/compiler-gcc.h
> +++ b/include/linux/compiler-gcc.h
> @@ -143,6 +143,12 @@
>  #define KASAN_ABI_VERSION 3
>  #endif
>  
> +#if __has_attribute(__no_sanitize_address__)
> +#define __no_sanitize_address __attribute__((no_sanitize_address))
> +#else
> +#define __no_sanitize_address
> +#endif

Not really important but it's the name with leading and trailing
underscores that is tested with __has_attribute() but then it's
the naked 'no_sanitize_address' that is used in the attribute.

-- Luc
