Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 95D066B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 05:35:49 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id n16so9583774oig.19
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 02:35:49 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a5si8111389otc.533.2017.11.15.02.35.48
        for <linux-mm@kvack.org>;
        Wed, 15 Nov 2017 02:35:48 -0800 (PST)
From: Marc Zyngier <marc.zyngier@arm.com>
Subject: Re: [PATCH 01/11] Initialize the mapping of KASan shadow memory
In-Reply-To: <B8AC3E80E903784988AB3003E3E97330C0063545@dggemm510-mbs.china.huawei.com>
	(liuwenliang@huawei.com's message of "Wed, 15 Nov 2017 10:20:02
	+0000")
References: <20171011082227.20546-1-liuwenliang@huawei.com>
	<20171011082227.20546-2-liuwenliang@huawei.com>
	<227e2c6e-f479-849d-8942-1d5ff4ccd440@arm.com>
	<B8AC3E80E903784988AB3003E3E97330C0063172@dggemm510-mbs.china.huawei.com>
	<8e959f69-a578-793b-6c32-18b5b0cd08c2@arm.com>
	<B8AC3E80E903784988AB3003E3E97330C0063545@dggemm510-mbs.china.huawei.com>
Date: Wed, 15 Nov 2017 10:35:38 +0000
Message-ID: <87a7znsubp.fsf@on-the-bus.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Cc: "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

On Wed, Nov 15 2017 at 10:20:02 am GMT, "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com> wrote:
> On 09/11/17 18:11, Marc Zyngier [mailto:marc.zyngier@arm.com] wrote:
>>On 09/11/17 07:46, Liuwenliang (Abbott Liu) wrote:
>>> diff --git a/arch/arm/mm/kasan_init.c b/arch/arm/mm/kasan_init.c
>>> index 049ee0a..359a782 100644
>>> --- a/arch/arm/mm/kasan_init.c
>>> +++ b/arch/arm/mm/kasan_init.c
>>> @@ -15,6 +15,7 @@
>>>  #include <asm/proc-fns.h>
>>>  #include <asm/tlbflush.h>
>>>  #include <asm/cp15.h>
>>> +#include <asm/kvm_hyp.h>
>>
>>No, please don't do that. You shouldn't have to include KVM stuff in
>>unrelated code. Instead of adding stuff to kvm_hyp.h, move all the
>>__ACCESS_CP15* to cp15.h, and it will be obvious to everyone that this
>>is where new definition should be added.
>
> Thanks for your review.  You are right. It is better to move
> __ACCESS_CP15* to cp15.h than to include kvm_hyp.h. But I don't think
> it is a good idea to move registers definition which is used in
> virtualization to cp15.h, Because there is no virtualization stuff in
> cp15.h.

It is not about virtualization at all.

It is about what is a CP15 register and what is not. This file is called
"cp15.h", not "cp15-except-virtualization-and-maybe-some-others.h". But
at the end of the day, that's for Russell to decide.

>
> Here is the code which I tested on vexpress_a15 and vexpress_a9:
> diff --git a/arch/arm/include/asm/cp15.h b/arch/arm/include/asm/cp15.h
> index dbdbce1..6db1f51 100644
> --- a/arch/arm/include/asm/cp15.h
> +++ b/arch/arm/include/asm/cp15.h
> @@ -64,6 +64,43 @@
>  #define __write_sysreg(v, r, w, c, t)  asm volatile(w " " c : : "r" ((t)(v)))
>  #define write_sysreg(v, ...)           __write_sysreg(v, __VA_ARGS__)
>
> +#ifdef CONFIG_ARM_LPAE
> +#define TTBR0           __ACCESS_CP15_64(0, c2)
> +#define TTBR1           __ACCESS_CP15_64(1, c2)
> +#define PAR             __ACCESS_CP15_64(0, c7)
> +#else
> +#define TTBR0           __ACCESS_CP15(c2, 0, c0, 0)
> +#define TTBR1           __ACCESS_CP15(c2, 0, c0, 1)
> +#define PAR             __ACCESS_CP15(c7, 0, c4, 0)
> +#endif

Again: there is no point in not having these register encodings
cohabiting. They are both perfectly defined in the architecture. Just
suffix one (or even both) with their respective size, making it obvious
which one you're talking about.

Thanks,

	M.
-- 
Jazz is not dead, it just smell funny.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
