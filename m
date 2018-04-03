Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 10D776B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 10:43:15 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 184so16835137iow.19
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 07:43:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y11sor1129779iod.36.2018.04.03.07.43.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Apr 2018 07:43:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2ab69c9c-6e80-ea79-e72e-012753ed3db0@virtuozzo.com>
References: <cover.1521828273.git.andreyknvl@google.com> <774016f707e494da419a2d0d8a03409e6befcaf8.1521828274.git.andreyknvl@google.com>
 <2ab69c9c-6e80-ea79-e72e-012753ed3db0@virtuozzo.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 3 Apr 2018 16:43:10 +0200
Message-ID: <CAAeHK+z37yRzK1Q6F32G=eB6_k+s_YQOoR8LLqNppxZsKMWiZg@mail.gmail.com>
Subject: Re: [RFC PATCH v2 05/15] khwasan: initialize shadow to 0xff
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, Michael Weiser <michael.weiser@gmx.de>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Steve Capper <steve.capper@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Stephen Boyd <stephen.boyd@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Woodhouse <dwmw@amazon.co.uk>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Herbert Xu <herbert@gondor.apana.org.au>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, kvmarm@lists.cs.columbia.edu, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Fri, Mar 30, 2018 at 6:07 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> On 03/23/2018 09:05 PM, Andrey Konovalov wrote:
>> A KHWASAN shadow memory cell contains a memory tag, that corresponds to
>> the tag in the top byte of the pointer, that points to that memory. The
>> native top byte value of kernel pointers is 0xff, so with KHWASAN we
>> need to initialize shadow memory to 0xff. This commit does that.
>>
>> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>> ---
>>  arch/arm64/mm/kasan_init.c | 11 ++++++++++-
>>  include/linux/kasan.h      |  8 ++++++++
>>  mm/kasan/common.c          |  7 +++++++
>>  3 files changed, 25 insertions(+), 1 deletion(-)
>>
>> diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
>> index dabfc1ecda3d..d4bceba60010 100644
>> --- a/arch/arm64/mm/kasan_init.c
>> +++ b/arch/arm64/mm/kasan_init.c
>> @@ -90,6 +90,10 @@ static void __init kasan_pte_populate(pmd_t *pmdp, unsigned long addr,
>>       do {
>>               phys_addr_t page_phys = early ? __pa_symbol(kasan_zero_page)
>>                                             : kasan_alloc_zeroed_page(node);
>> +#if KASAN_SHADOW_INIT != 0
>> +             if (!early)
>> +                     memset(__va(page_phys), KASAN_SHADOW_INIT, PAGE_SIZE);
>> +#endif
>
> Less ugly way to do the same:
>         if (KASAN_SHADOW_INIT != 0 && !early)
>                 memset(__va(page_phys), KASAN_SHADOW_INIT, PAGE_SIZE);
>
>
> But the right approach here would be allocating uninitialized memory (see memblock_virt_alloc_try_nid_raw())
> and do "if (!early) memset(.., KASAN_SHADOW_INIT, ..)" afterwards.

Will do!

>
>
>>               next = addr + PAGE_SIZE;
>>               set_pte(ptep, pfn_pte(__phys_to_pfn(page_phys), PAGE_KERNEL));
>>       } while (ptep++, addr = next, addr != end && pte_none(READ_ONCE(*ptep)));
>> @@ -139,6 +143,11 @@ asmlinkage void __init kasan_early_init(void)
>>               KASAN_SHADOW_END - (1UL << (64 - KASAN_SHADOW_SCALE_SHIFT)));
>>       BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_START, PGDIR_SIZE));
>>       BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_END, PGDIR_SIZE));
>> +
>> +#if KASAN_SHADOW_INIT != 0
>> +     memset(kasan_zero_page, KASAN_SHADOW_INIT, PAGE_SIZE);
>> +#endif
>> +
>
>  if (KASAN_SHADOW_INIT)
>         memset(...)
>
> Note that, if poisoning of stack variables will work in the same fashion as classic
> KASAN (compiler generated code writes to shadow in function prologue) than content
> of this page will be ruined very fast. Which makes this initialization questionable.

I think I agree with you on this. Since this page immediately gets
dirty and we ignore all reports until proper shadow is set up anyway,
there's no need to initialize it.

>
>
>
>>       kasan_pgd_populate(KASAN_SHADOW_START, KASAN_SHADOW_END, NUMA_NO_NODE,
>>                          true);
>>  }
>> @@ -235,7 +244,7 @@ void __init kasan_init(void)
>>               set_pte(&kasan_zero_pte[i],
>>                       pfn_pte(sym_to_pfn(kasan_zero_page), PAGE_KERNEL_RO));
>>
>> -     memset(kasan_zero_page, 0, PAGE_SIZE);
>> +     memset(kasan_zero_page, KASAN_SHADOW_INIT, PAGE_SIZE);
>>       cpu_replace_ttbr1(lm_alias(swapper_pg_dir));
>>
>>       /* At this point kasan is fully initialized. Enable error messages */
>> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
>> index 3c45e273a936..700734dff218 100644
>> --- a/include/linux/kasan.h
>> +++ b/include/linux/kasan.h
>> @@ -139,6 +139,8 @@ static inline size_t kasan_metadata_size(struct kmem_cache *cache) { return 0; }
>>
>>  #ifdef CONFIG_KASAN_CLASSIC
>>
>> +#define KASAN_SHADOW_INIT 0
>> +
>>  void kasan_cache_shrink(struct kmem_cache *cache);
>>  void kasan_cache_shutdown(struct kmem_cache *cache);
>>
>> @@ -149,4 +151,10 @@ static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
>>
>>  #endif /* CONFIG_KASAN_CLASSIC */
>>
>> +#ifdef CONFIG_KASAN_TAGS
>> +
>> +#define KASAN_SHADOW_INIT 0xFF
>> +
>> +#endif /* CONFIG_KASAN_TAGS */
>> +
>>  #endif /* LINUX_KASAN_H */
>> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
>> index 08f6c8cb9f84..f4ccb9425655 100644
>> --- a/mm/kasan/common.c
>> +++ b/mm/kasan/common.c
>> @@ -253,6 +253,9 @@ int kasan_module_alloc(void *addr, size_t size)
>>                       __builtin_return_address(0));
>>
>>       if (ret) {
>> +#if KASAN_SHADOW_INIT != 0
>> +             __memset(ret, KASAN_SHADOW_INIT, shadow_size);
>> +#endif
>
> Drop __GFP_ZERO from above and remove this #if/#endif.

Will do!

>
>
>>               find_vm_area(addr)->flags |= VM_KASAN;
>>               kmemleak_ignore(ret);
>>               return 0;
>> @@ -297,6 +300,10 @@ static int __meminit kasan_mem_notifier(struct notifier_block *nb,
>>               if (!ret)
>>                       return NOTIFY_BAD;
>>
>> +#if KASAN_SHADOW_INIT != 0
>> +             __memset(ret, KASAN_SHADOW_INIT, shadow_end - shadow_start);
>> +#endif
>> +
>
> No need to initialize anything here, kasan_free_pages() will do this later.

OK, will fix this!

>
>
>>               kmemleak_ignore(ret);
>>               return NOTIFY_OK;
>>       }
>>

Thanks!
