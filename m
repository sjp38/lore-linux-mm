Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 19E1B6B0038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 16:28:02 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so6333394wic.1
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 13:28:01 -0700 (PDT)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id fz6si6375950wic.116.2015.09.17.13.28.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 13:28:00 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so6443166wic.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 13:28:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150917131519.1f579c0492dfe0d1e5a8ac54@linux-foundation.org>
References: <201509170954.bUogAGSu%fengguang.wu@intel.com>
	<20150917123751.772410664187565ba24171a5@linux-foundation.org>
	<CAPAsAGyFs7dc1AvUweJ6_KPjoK8qMELDnyOfmNSX-urr7Nnhww@mail.gmail.com>
	<20150917131519.1f579c0492dfe0d1e5a8ac54@linux-foundation.org>
Date: Thu, 17 Sep 2015 23:28:00 +0300
Message-ID: <CAPAsAGyHeww4J65-CORRgc19aJ=8D30LiwFmDwGUu+sd4kntzQ@mail.gmail.com>
Subject: Re: drivers/firmware/efi/libstub/efi-stub-helper.c:599:2: warning:
 implicit declaration of function 'memcpy'
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Andrey Konovalov <adech.fo@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>

2015-09-17 23:15 GMT+03:00 Andrew Morton <akpm@linux-foundation.org>:
> On Thu, 17 Sep 2015 23:02:14 +0300 Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
>
>> 2015-09-17 22:37 GMT+03:00 Andrew Morton <akpm@linux-foundation.org>:
>> > On Thu, 17 Sep 2015 09:17:56 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
>> >
>> >> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>> >> head:   72714841b705a5b9bccf37ee85a62352bee3a3ef
>> >> commit: 393f203f5fd54421fddb1e2a263f64d3876eeadb x86_64: kasan: add interceptors for memset/memmove/memcpy functions
>> >> date:   7 months ago
>> >> config: i386-randconfig-i0-201537 (attached as .config)
>> >> reproduce:
>> >>   git checkout 393f203f5fd54421fddb1e2a263f64d3876eeadb
>> >>   # save the attached .config to linux build tree
>> >>   make ARCH=i386
>> >>
>> >> All warnings (new ones prefixed by >>):
>> >>
>> >>    drivers/firmware/efi/libstub/efi-stub-helper.c: In function 'efi_relocate_kernel':
>> >> >> drivers/firmware/efi/libstub/efi-stub-helper.c:599:2: warning: implicit declaration of function 'memcpy' [-Wimplicit-function-declaration]
>> >>      memcpy((void *)new_addr, (void *)cur_image_addr, image_size);
>> >
>> > I can't reproduce this.
>> >
>> > But whatever.  I'll do this:
>> >
>> > --- a/drivers/firmware/efi/libstub/efi-stub-helper.c~drivers-firmware-efi-libstub-efi-stub-helperc-needs-stringh
>> > +++ a/drivers/firmware/efi/libstub/efi-stub-helper.c
>> > @@ -11,6 +11,7 @@
>> >   */
>> >
>> >  #include <linux/efi.h>
>> > +#include <linux/string.h>
>>
>> This won't help.
>> arch/x86/include/asm/string_32.h has several variants of #define memcpy()
>> But it doesn't have declaration of memcpy function like:
>>             void memcpy(const void *to, const void *from, size_t len);
>> Thus '#undef memcpy' causes this warning, and including
>> <linux/string.h> won't help (It probably already included)
>
> Well, I can't tell either way because that warning doesn't come out for
> me with the provided config.
>
That's strange, but I could reproduce this and warning didn't go away
after adding include.

>> Patch from KASAN for arm64 series:
>> http://marc.info/?l=linux-mm&m=144248270719929&w=2 ([PATCH v6 3/6]
>> x86, efi, kasan: #undef memset/memcpy/memmove per arch.)
>> should fix this warning, as it moves '#undef memcpy' under #ifdef
>> X86_64 in arch/x86/include/asm/efi.h
>
> hm, that patch was misfiled.  We want this for for 4.3-rc.  I'll queue
> it up.

Good.

> I hope it's independent of the rest of that patch series?
>

Yes, this patch doesn't depend on the rest of patches, although the
rest of patches depends on it.

>
> From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
> Subject: x86, efi, kasan: #undef memset/memcpy/memmove per arch
>
> In not-instrumented code KASAN replaces instrumented memset/memcpy/memmove
> with not-instrumented analogues __memset/__memcpy/__memove.
>
> However, on x86 the EFI stub is not linked with the kernel.  It uses
> not-instrumented mem*() functions from arch/x86/boot/compressed/string.c
>
> So we don't replace them with __mem*() variants in EFI stub.
>
> On ARM64 the EFI stub is linked with the kernel, so we should replace
> mem*() functions with __mem*(), because the EFI stub runs before KASAN
> sets up early shadow.
>
> So let's move these #undef mem* into arch's asm/efi.h which is also
> included by the EFI stub.
>
> Also, this will fix the warning in 32-bit build reported by kbuild test
> robot:
>
>         efi-stub-helper.c:599:2: warning: implicit declaration of function 'memcpy'
>
> Signed-off-by: Andrey Ryabinin <ryabinin.a.a@gmail.com>
> Reported-by: Fengguang Wu <fengguang.wu@gmail.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Matt Fleming <matt.fleming@intel.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>  arch/x86/include/asm/efi.h             |   12 ++++++++++++
>  drivers/firmware/efi/libstub/efistub.h |    4 ----
>  2 files changed, 12 insertions(+), 4 deletions(-)
>
> diff -puN arch/x86/include/asm/efi.h~x86-efi-kasan-undef-memset-memcpy-memmove-per-arch arch/x86/include/asm/efi.h
> --- a/arch/x86/include/asm/efi.h~x86-efi-kasan-undef-memset-memcpy-memmove-per-arch
> +++ a/arch/x86/include/asm/efi.h
> @@ -86,6 +86,18 @@ extern u64 asmlinkage efi_call(void *fp,
>  extern void __iomem *__init efi_ioremap(unsigned long addr, unsigned long size,
>                                         u32 type, u64 attribute);
>
> +/*
> + * CONFIG_KASAN may redefine memset to __memset.
> + * __memset function is present only in kernel binary.
> + * Since the EFI stub linked into a separate binary it
> + * doesn't have __memset(). So we should use standard
> + * memset from arch/x86/boot/compressed/string.c
> + * The same applies to memcpy and memmove.
> + */
> +#undef memcpy
> +#undef memset
> +#undef memmove
> +
>  #endif /* CONFIG_X86_32 */
>
>  extern struct efi_scratch efi_scratch;
> diff -puN drivers/firmware/efi/libstub/efistub.h~x86-efi-kasan-undef-memset-memcpy-memmove-per-arch drivers/firmware/efi/libstub/efistub.h
> --- a/drivers/firmware/efi/libstub/efistub.h~x86-efi-kasan-undef-memset-memcpy-memmove-per-arch
> +++ a/drivers/firmware/efi/libstub/efistub.h
> @@ -5,10 +5,6 @@
>  /* error code which can't be mistaken for valid address */
>  #define EFI_ERROR      (~0UL)
>
> -#undef memcpy
> -#undef memset
> -#undef memmove
> -
>  void efi_char16_printk(efi_system_table_t *, efi_char16_t *);
>
>  efi_status_t efi_open_volume(efi_system_table_t *sys_table_arg, void *__image,
> _
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
