Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E9D3E6B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 08:41:21 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id y142so3431887wme.12
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 05:41:21 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id e15si1096987wmc.257.2017.10.19.05.41.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 05:41:20 -0700 (PDT)
Date: Thu, 19 Oct 2017 13:40:34 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 04/11] Define the virtual space of KASan's shadow region
Message-ID: <20171019124034.GW20805@n2100.armlinux.org.uk>
References: <20171011082227.20546-5-liuwenliang@huawei.com>
 <201710141957.mbxeZJHB%fengguang.wu@intel.com>
 <B8AC3E80E903784988AB3003E3E97330C005B9BF@dggemm510-mbx.china.huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <B8AC3E80E903784988AB3003E3E97330C005B9BF@dggemm510-mbx.china.huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liuwenliang (Lamb)" <liuwenliang@huawei.com>
Cc: kbuild test robot <lkp@intel.com>, "kbuild-all@01.org" <kbuild-all@01.org>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

On Mon, Oct 16, 2017 at 11:42:05AM +0000, Liuwenliang (Lamb) wrote:
> On 10/16/2017 07:03 PM, Abbott Liu wrote:
> >arch/arm/kernel/entry-armv.S:348: Error: selected processor does not support `movw r1,
>   #:lower16:((((0xC0000000-0x01000000)>>3)+((0xC0000000-0x01000000)-(1<<29))))' in ARM mode
> >arch/arm/kernel/entry-armv.S:348: Error: selected processor does not support `movt r1,
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

We can surely do better than this with macros and condition support -
we can build-time test in the assembler whether TASK_SIZE can fit in a
normal "mov", whether we can use the movw/movt instructions, or fall
back to ldr if necessary.  I'd rather we avoided "ldr" here where
possible.

> @@ -446,7 +445,12 @@ ENDPROC(__fiq_abt)
>         @ if it was interrupted in a critical region.  Here we
>         @ perform a quick test inline since it should be false
>         @ 99.9999% of the time.  The rest is done out of line.
> +#if CONFIG_KASAN
> + ldr r0, =TASK_SIZE
> + cmp r4, r0
> +#else
>         cmp     r4, #TASK_SIZE

Same sort of thing goes for here - we can select the instruction at
runtime using the assembler's macros and condition support.

We know that TASK_SIZE is going to be one of a limited set of values.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
