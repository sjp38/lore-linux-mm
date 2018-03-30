Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 86F926B0033
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 12:12:31 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s21so7820892pfm.15
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 09:12:31 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0118.outbound.protection.outlook.com. [104.47.0.118])
        by mx.google.com with ESMTPS id d126si6366048pfd.22.2018.03.30.09.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 30 Mar 2018 09:12:30 -0700 (PDT)
Subject: Re: [RFC PATCH v2 08/15] khwasan: add tag related helper functions
References: <cover.1521828273.git.andreyknvl@google.com>
 <b79947167d09478d3f61d2ec8de37322c0e1fe92.1521828274.git.andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <a724eee6-7aff-df8b-de2b-8e9446e94623@virtuozzo.com>
Date: Fri, 30 Mar 2018 19:13:08 +0300
MIME-Version: 1.0
In-Reply-To: <b79947167d09478d3f61d2ec8de37322c0e1fe92.1521828274.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, Michael Weiser <michael.weiser@gmx.de>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Steve Capper <steve.capper@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Woodhouse <dwmw@amazon.co.uk>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Herbert Xu <herbert@gondor.apana.org.au>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvmarm@lists.cs.columbia.edu, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>



On 03/23/2018 09:05 PM, Andrey Konovalov wrote:

> diff --git a/mm/kasan/khwasan.c b/mm/kasan/khwasan.c
> index 24d75245e9d0..da4b17997c71 100644
> --- a/mm/kasan/khwasan.c
> +++ b/mm/kasan/khwasan.c
> @@ -39,6 +39,57 @@
>  #include "kasan.h"
>  #include "../slab.h"
>  
> +int khwasan_enabled;

This is not unused (set, but never used).

> +
> +static DEFINE_PER_CPU(u32, prng_state);
> +
> +void khwasan_init(void)
> +{
> +	int cpu;
> +
> +	for_each_possible_cpu(cpu) {
> +		per_cpu(prng_state, cpu) = get_random_u32();
> +	}
> +	WRITE_ONCE(khwasan_enabled, 1);
> +}
> +
