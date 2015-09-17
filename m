Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2F39C6B0038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 16:02:16 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so5305390wic.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 13:02:15 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id k14si6309594wjr.21.2015.09.17.13.02.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 13:02:15 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so5304895wic.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 13:02:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150917123751.772410664187565ba24171a5@linux-foundation.org>
References: <201509170954.bUogAGSu%fengguang.wu@intel.com>
	<20150917123751.772410664187565ba24171a5@linux-foundation.org>
Date: Thu, 17 Sep 2015 23:02:14 +0300
Message-ID: <CAPAsAGyFs7dc1AvUweJ6_KPjoK8qMELDnyOfmNSX-urr7Nnhww@mail.gmail.com>
Subject: Re: drivers/firmware/efi/libstub/efi-stub-helper.c:599:2: warning:
 implicit declaration of function 'memcpy'
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Andrey Konovalov <adech.fo@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>

2015-09-17 22:37 GMT+03:00 Andrew Morton <akpm@linux-foundation.org>:
> On Thu, 17 Sep 2015 09:17:56 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
>
>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>> head:   72714841b705a5b9bccf37ee85a62352bee3a3ef
>> commit: 393f203f5fd54421fddb1e2a263f64d3876eeadb x86_64: kasan: add interceptors for memset/memmove/memcpy functions
>> date:   7 months ago
>> config: i386-randconfig-i0-201537 (attached as .config)
>> reproduce:
>>   git checkout 393f203f5fd54421fddb1e2a263f64d3876eeadb
>>   # save the attached .config to linux build tree
>>   make ARCH=i386
>>
>> All warnings (new ones prefixed by >>):
>>
>>    drivers/firmware/efi/libstub/efi-stub-helper.c: In function 'efi_relocate_kernel':
>> >> drivers/firmware/efi/libstub/efi-stub-helper.c:599:2: warning: implicit declaration of function 'memcpy' [-Wimplicit-function-declaration]
>>      memcpy((void *)new_addr, (void *)cur_image_addr, image_size);
>
> I can't reproduce this.
>
> But whatever.  I'll do this:
>
> --- a/drivers/firmware/efi/libstub/efi-stub-helper.c~drivers-firmware-efi-libstub-efi-stub-helperc-needs-stringh
> +++ a/drivers/firmware/efi/libstub/efi-stub-helper.c
> @@ -11,6 +11,7 @@
>   */
>
>  #include <linux/efi.h>
> +#include <linux/string.h>

This won't help.
arch/x86/include/asm/string_32.h has several variants of #define memcpy()
But it doesn't have declaration of memcpy function like:
            void memcpy(const void *to, const void *from, size_t len);
Thus '#undef memcpy' causes this warning, and including
<linux/string.h> won't help (It probably already included)

Patch from KASAN for arm64 series:
http://marc.info/?l=linux-mm&m=144248270719929&w=2 ([PATCH v6 3/6]
x86, efi, kasan: #undef memset/memcpy/memmove per arch.)
should fix this warning, as it moves '#undef memcpy' under #ifdef
X86_64 in arch/x86/include/asm/efi.h

>  #include <asm/efi.h>
>
>  #include "efistub.h"
> _
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
