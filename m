Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 55B368E0001
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 07:12:36 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id v3so13494071itf.4
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 04:12:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f191sor17574457itc.25.2018.12.10.04.12.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Dec 2018 04:12:35 -0800 (PST)
MIME-Version: 1.0
References: <cover.1544099024.git.andreyknvl@google.com> <5cc1b789aad7c99cf4f3ec5b328b147ad53edb40.1544099024.git.andreyknvl@google.com>
 <CAP=VYLo-o8vpGrpM_+0jdvxLC9uxw+F7_OtsSfRyq24HR1dDwA@mail.gmail.com>
In-Reply-To: <CAP=VYLo-o8vpGrpM_+0jdvxLC9uxw+F7_OtsSfRyq24HR1dDwA@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 10 Dec 2018 13:12:23 +0100
Message-ID: <CAAeHK+wWRG6kp7mn-bNpYQ5cV8ygbXKnwS9f0mDCAnwiTqEoMg@mail.gmail.com>
Subject: Re: [PATCH v13 08/25] kasan: initialize shadow to 0xff for tag-based mode
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.gortmaker@windriver.com
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgenii Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Linux-Next Mailing List <linux-next@vger.kernel.org>

On Mon, Dec 10, 2018 at 2:35 AM Paul Gortmaker
<paul.gortmaker@windriver.com> wrote:
>
> On Thu, Dec 6, 2018 at 7:25 AM Andrey Konovalov <andreyknvl@google.com> w=
rote:
>>
>> A tag-based KASAN shadow memory cell contains a memory tag, that
>> corresponds to the tag in the top byte of the pointer, that points to th=
at
>> memory. The native top byte value of kernel pointers is 0xff, so with
>> tag-based KASAN we need to initialize shadow memory to 0xff.
>>
>> Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
>> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>> ---
>>  arch/arm64/mm/kasan_init.c | 15 +++++++++++++--
>>  include/linux/kasan.h      |  8 ++++++++
>
>
> The version of this in  linux-next breaks arm64 allmodconfig for me:
>
> mm/kasan/common.c: In function =E2=80=98kasan_module_alloc=E2=80=99:
> mm/kasan/common.c:481:17: error: =E2=80=98KASAN_SHADOW_INIT=E2=80=99 unde=
clared (first use in this function)
>    __memset(ret, KASAN_SHADOW_INIT, shadow_size);
>                  ^
> mm/kasan/common.c:481:17: note: each undeclared identifier is reported on=
ly once for each function it appears in
> make[3]: *** [mm/kasan/common.o] Error 1
> make[3]: *** Waiting for unfinished jobs....
> make[2]: *** [mm/kasan] Error 2
> make[2]: *** Waiting for unfinished jobs....
> make[1]: *** [mm/] Error 2
> make: *** [sub-make] Error 2

Hi Paul,

This is my bad, this should be fixed in v13 of this patchset, which is
in mm right now but not in linux-next yet as it seems.

Thanks!

>
> An automated git bisect-run points at this:
>
> 5c36287813721999e79ac76f637f1ba7e5054402 is the first bad commit
> commit 5c36287813721999e79ac76f637f1ba7e5054402
> Author: Andrey Konovalov <andreyknvl@google.com>
> Date:   Wed Dec 5 11:13:21 2018 +1100
>
>     kasan: initialize shadow to 0xff for tag-based mode
>
> A quick look at the commit makes me think that the case where the
> "# CONFIG_KASAN_GENERIC is not set" has not been handled.
>
> I'm using an older gcc 4.8.3 - only used for build testing.
>
> Paul.
> --
>
>>  mm/kasan/common.c          |  3 ++-
>>  3 files changed, 23 insertions(+), 3 deletions(-)
>>
>> diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
>> index 4ebc19422931..7a4a0904cac8 100644
>> --- a/arch/arm64/mm/kasan_init.c
>> +++ b/arch/arm64/mm/kasan_init.c
>> @@ -43,6 +43,15 @@ static phys_addr_t __init kasan_alloc_zeroed_page(int=
 node)
>>         return __pa(p);
>>  }
>>
>> +static phys_addr_t __init kasan_alloc_raw_page(int node)
>> +{
>> +       void *p =3D memblock_alloc_try_nid_raw(PAGE_SIZE, PAGE_SIZE,
>> +                                               __pa(MAX_DMA_ADDRESS),
>> +                                               MEMBLOCK_ALLOC_ACCESSIBL=
E,
>> +                                               node);
>> +       return __pa(p);
>> +}
>> +
>>  static pte_t *__init kasan_pte_offset(pmd_t *pmdp, unsigned long addr, =
int node,
>>                                       bool early)
>>  {
>> @@ -92,7 +101,9 @@ static void __init kasan_pte_populate(pmd_t *pmdp, un=
signed long addr,
>>         do {
>>                 phys_addr_t page_phys =3D early ?
>>                                 __pa_symbol(kasan_early_shadow_page)
>> -                                       : kasan_alloc_zeroed_page(node);
>> +                                       : kasan_alloc_raw_page(node);
>> +               if (!early)
>> +                       memset(__va(page_phys), KASAN_SHADOW_INIT, PAGE_=
SIZE);
>>                 next =3D addr + PAGE_SIZE;
>>                 set_pte(ptep, pfn_pte(__phys_to_pfn(page_phys), PAGE_KER=
NEL));
>>         } while (ptep++, addr =3D next, addr !=3D end && pte_none(READ_O=
NCE(*ptep)));
>> @@ -239,7 +250,7 @@ void __init kasan_init(void)
>>                         pfn_pte(sym_to_pfn(kasan_early_shadow_page),
>>                                 PAGE_KERNEL_RO));
>>
>> -       memset(kasan_early_shadow_page, 0, PAGE_SIZE);
>> +       memset(kasan_early_shadow_page, KASAN_SHADOW_INIT, PAGE_SIZE);
>>         cpu_replace_ttbr1(lm_alias(swapper_pg_dir));
>>
>>         /* At this point kasan is fully initialized. Enable error messag=
es */
>> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
>> index ec22d548d0d7..c56af24bd3e7 100644
>> --- a/include/linux/kasan.h
>> +++ b/include/linux/kasan.h
>> @@ -153,6 +153,8 @@ static inline size_t kasan_metadata_size(struct kmem=
_cache *cache) { return 0; }
>>
>>  #ifdef CONFIG_KASAN_GENERIC
>>
>> +#define KASAN_SHADOW_INIT 0
>> +
>>  void kasan_cache_shrink(struct kmem_cache *cache);
>>  void kasan_cache_shutdown(struct kmem_cache *cache);
>>
>> @@ -163,4 +165,10 @@ static inline void kasan_cache_shutdown(struct kmem=
_cache *cache) {}
>>
>>  #endif /* CONFIG_KASAN_GENERIC */
>>
>> +#ifdef CONFIG_KASAN_SW_TAGS
>> +
>> +#define KASAN_SHADOW_INIT 0xFF
>> +
>> +#endif /* CONFIG_KASAN_SW_TAGS */
>> +
>>  #endif /* LINUX_KASAN_H */
>> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
>> index 5f68c93734ba..7134e75447ff 100644
>> --- a/mm/kasan/common.c
>> +++ b/mm/kasan/common.c
>> @@ -473,11 +473,12 @@ int kasan_module_alloc(void *addr, size_t size)
>>
>>         ret =3D __vmalloc_node_range(shadow_size, 1, shadow_start,
>>                         shadow_start + shadow_size,
>> -                       GFP_KERNEL | __GFP_ZERO,
>> +                       GFP_KERNEL,
>>                         PAGE_KERNEL, VM_NO_GUARD, NUMA_NO_NODE,
>>                         __builtin_return_address(0));
>>
>>         if (ret) {
>> +               __memset(ret, KASAN_SHADOW_INIT, shadow_size);
>>                 find_vm_area(addr)->flags |=3D VM_KASAN;
>>                 kmemleak_ignore(ret);
>>                 return 0;
>> --
>> 2.20.0.rc1.387.gf8505762e3-goog
>>
