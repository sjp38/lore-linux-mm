Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 882EE8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 05:10:36 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b7so2750905eda.10
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 02:10:36 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 94si1262038edc.413.2019.01.09.02.10.34
        for <linux-mm@kvack.org>;
        Wed, 09 Jan 2019 02:10:35 -0800 (PST)
Subject: Re: [PATCH v3 1/3] kasan, arm64: use ARCH_SLAB_MINALIGN instead of
 manual aligning
References: <cover.1546540962.git.andreyknvl@google.com>
 <52ddd881916bcc153a9924c154daacde78522227.1546540962.git.andreyknvl@google.com>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <fc93e5a4-fa54-98a1-ea5f-4708568d7857@arm.com>
Date: Wed, 9 Jan 2019 10:10:26 +0000
MIME-Version: 1.0
In-Reply-To: <52ddd881916bcc153a9924c154daacde78522227.1546540962.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On 03/01/2019 18:45, Andrey Konovalov wrote:
> Instead of changing cache->align to be aligned to KASAN_SHADOW_SCALE_SIZE
> in kasan_cache_create() we can reuse the ARCH_SLAB_MINALIGN macro.
> 
> Suggested-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  arch/arm64/include/asm/cache.h | 6 ++++++
>  mm/kasan/common.c              | 2 --
>  2 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm64/include/asm/cache.h b/arch/arm64/include/asm/cache.h
> index 13dd42c3ad4e..eb43e09c1980 100644
> --- a/arch/arm64/include/asm/cache.h
> +++ b/arch/arm64/include/asm/cache.h
> @@ -58,6 +58,12 @@
>   */
>  #define ARCH_DMA_MINALIGN	(128)
>  
> +#ifdef CONFIG_KASAN_SW_TAGS
> +#define ARCH_SLAB_MINALIGN	(1ULL << KASAN_SHADOW_SCALE_SHIFT)
> +#else
> +#define ARCH_SLAB_MINALIGN	__alignof__(unsigned long long)
> +#endif
> +

Could you please remove the "#else" case here, because it is redundant (it is
defined in linux/slab.h as ifndef) and could be misleading in future?

>  #ifndef __ASSEMBLY__
>  
>  #include <linux/bitops.h>
> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index 03d5d1374ca7..44390392d4c9 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -298,8 +298,6 @@ void kasan_cache_create(struct kmem_cache *cache, unsigned int *size,
>  		return;
>  	}
>  
> -	cache->align = round_up(cache->align, KASAN_SHADOW_SCALE_SIZE);
> -
>  	*flags |= SLAB_KASAN;
>  }
>  
> 

-- 
Regards,
Vincenzo
