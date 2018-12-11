Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3425B8E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 11:22:53 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id b18so8098371oii.1
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 08:22:53 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h1si6233598oti.258.2018.12.11.08.22.51
        for <linux-mm@kvack.org>;
        Tue, 11 Dec 2018 08:22:51 -0800 (PST)
Subject: Re: [PATCH v13 19/25] kasan: add hooks implementation for tag-based
 mode
References: <cover.1544099024.git.andreyknvl@google.com>
 <bda78069e3b8422039794050ddcb2d53d053ed41.1544099024.git.andreyknvl@google.com>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <2bf7415e-2724-b3c3-9571-20c8b6d43b92@arm.com>
Date: Tue, 11 Dec 2018 16:22:43 +0000
MIME-Version: 1.0
In-Reply-To: <bda78069e3b8422039794050ddcb2d53d053ed41.1544099024.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Vishwath Mohan <vishwath@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Jann Horn <jannh@google.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Mark Brand <markbrand@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgeniy Stepanov <eugenis@google.com>

Hi Andrey,

On 06/12/2018 12:24, Andrey Konovalov wrote:
> This commit adds tag-based KASAN specific hooks implementation and
> adjusts common generic and tag-based KASAN ones.
> 
> 1. When a new slab cache is created, tag-based KASAN rounds up the size of
>    the objects in this cache to KASAN_SHADOW_SCALE_SIZE (== 16).
> 
> 2. On each kmalloc tag-based KASAN generates a random tag, sets the shadow
>    memory, that corresponds to this object to this tag, and embeds this
>    tag value into the top byte of the returned pointer.
> 
> 3. On each kfree tag-based KASAN poisons the shadow memory with a random
>    tag to allow detection of use-after-free bugs.
> 
> The rest of the logic of the hook implementation is very much similar to
> the one provided by generic KASAN. Tag-based KASAN saves allocation and
> free stack metadata to the slab object the same way generic KASAN does.
> 
> Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  mm/kasan/common.c | 116 ++++++++++++++++++++++++++++++++++++++--------
>  mm/kasan/kasan.h  |   8 ++++
>  mm/kasan/tags.c   |  48 +++++++++++++++++++
>  3 files changed, 153 insertions(+), 19 deletions(-)
>


[...]

> @@ -265,6 +290,8 @@ void kasan_cache_create(struct kmem_cache *cache, unsigned int *size,
>  		return;
>  	}
>  
> +	cache->align = round_up(cache->align, KASAN_SHADOW_SCALE_SIZE);
> +

Did you consider to set ARCH_SLAB_MINALIGN instead of this round up?

-- 
Regards,
Vincenzo
