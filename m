Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 258336B0033
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 08:14:56 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id f16so7305396ioe.1
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 05:14:56 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 83sor3679026ioh.251.2017.10.16.05.14.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Oct 2017 05:14:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <B8AC3E80E903784988AB3003E3E97330C005B9BF@dggemm510-mbx.china.huawei.com>
References: <20171011082227.20546-5-liuwenliang@huawei.com>
 <201710141957.mbxeZJHB%fengguang.wu@intel.com> <B8AC3E80E903784988AB3003E3E97330C005B9BF@dggemm510-mbx.china.huawei.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Mon, 16 Oct 2017 13:14:54 +0100
Message-ID: <CAKv+Gu98M9PZk3qm0PYC8nQ3zMvLZmNmOn4=hNdFE7NTBuHbgg@mail.gmail.com>
Subject: Re: [PATCH 04/11] Define the virtual space of KASan's shadow region
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liuwenliang (Lamb)" <liuwenliang@huawei.com>
Cc: kbuild test robot <lkp@intel.com>, "kbuild-all@01.org" <kbuild-all@01.org>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

On 16 October 2017 at 12:42, Liuwenliang (Lamb) <liuwenliang@huawei.com> wrote:
> On 10/16/2017 07:03 PM, Abbott Liu wrote:
>>arch/arm/kernel/entry-armv.S:348: Error: selected processor does not support `movw r1,
>   #:lower16:((((0xC0000000-0x01000000)>>3)+((0xC0000000-0x01000000)-(1<<29))))' in ARM mode
>>arch/arm/kernel/entry-armv.S:348: Error: selected processor does not support `movt r1,
>   #:upper16:((((0xC0000000-0x01000000)>>3)+((0xC0000000-0x01000000)-(1<<29))))' in ARM mode
>
> Thanks for building test. This error can be solved by following code:
> --- a/arch/arm/kernel/entry-armv.S
> +++ b/arch/arm/kernel/entry-armv.S
> @@ -188,8 +188,7 @@ ENDPROC(__und_invalid)
>         get_thread_info tsk
>         ldr     r0, [tsk, #TI_ADDR_LIMIT]
>  #ifdef CONFIG_KASAN
> -   movw r1, #:lower16:TASK_SIZE
> -   movt r1, #:upper16:TASK_SIZE
> + ldr r1, =TASK_SIZE
>  #else
>         mov r1, #TASK_SIZE
>  #endif

This is unnecessary:

ldr r1, =TASK_SIZE

will be converted to a mov instruction by the assembler if the value
of TASK_SIZE fits its 12-bit immediate field.

So please remove the whole #ifdef, and just use ldr r1, =xxx

> @@ -446,7 +445,12 @@ ENDPROC(__fiq_abt)
>         @ if it was interrupted in a critical region.  Here we
>         @ perform a quick test inline since it should be false
>         @ 99.9999% of the time.  The rest is done out of line.
> +#if CONFIG_KASAN
> + ldr r0, =TASK_SIZE
> + cmp r4, r0
> +#else
>         cmp     r4, #TASK_SIZE
> +#endif
>         blhs    kuser_cmpxchg64_fixup
>  #endif
>  #endif
>
> movt,movw can only be used in ARMv6*, ARMv7 instruction set. But ldr can be used in ARMv4*, ARMv5T*, ARMv6*, ARMv7.
> Maybe the performance is going to fall down by using ldr, but I think the influence of performance is very limited.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
