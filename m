Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id A2CFD6B0287
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 08:06:28 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id p43so8604745otd.15
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 05:06:28 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 10si6512042otb.41.2017.11.22.05.06.27
        for <linux-mm@kvack.org>;
        Wed, 22 Nov 2017 05:06:27 -0800 (PST)
Subject: Re: [PATCH 01/11] Initialize the mapping of KASan shadow memory
References: <bbf43f92-3d0c-940d-b66b-68f92eb9b282@arm.com>
 <B8AC3E80E903784988AB3003E3E97330C00635F3@dggemm510-mbs.china.huawei.com>
 <87po8ir1kg.fsf@on-the-bus.cambridge.arm.com>
 <B8AC3E80E903784988AB3003E3E97330C006371B@dggemm510-mbs.china.huawei.com>
 <87375eqobb.fsf@on-the-bus.cambridge.arm.com>
 <B8AC3E80E903784988AB3003E3E97330C0063816@dggemm510-mbs.china.huawei.com>
 <20171117073556.GB28855@cbox>
 <B8AC3E80E903784988AB3003E3E97330C00638D4@dggemm510-mbs.china.huawei.com>
 <20171118134841.3f6c9183@why.wild-wind.fr.eu.org>
 <B8AC3E80E903784988AB3003E3E97330C0068F12@dggemm510-mbx.china.huawei.com>
 <20171121122938.sydii3i36jbzi7x4@lakrids.cambridge.arm.com>
 <B8AC3E80E903784988AB3003E3E97330C0069032@dggemm510-mbx.china.huawei.com>
From: Marc Zyngier <marc.zyngier@arm.com>
Message-ID: <757534e5-fcea-3eb4-3c8d-b8c7e709f555@arm.com>
Date: Wed, 22 Nov 2017 13:06:18 +0000
MIME-Version: 1.0
In-Reply-To: <B8AC3E80E903784988AB3003E3E97330C0069032@dggemm510-mbx.china.huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>, Mark Rutland <mark.rutland@arm.com>
Cc: "tixy@linaro.org" <tixy@linaro.org>, "mhocko@suse.com" <mhocko@suse.com>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "glider@google.com" <glider@google.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "mingo@kernel.org" <mingo@kernel.org>, Christoffer Dall <cdall@linaro.org>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, Dailei <dylix.dailei@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "labbott@redhat.com" <labbott@redhat.com>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, Zengweilin <zengweilin@huawei.com>, "opendmb@gmail.com" <opendmb@gmail.com>, Heshaoliang <heshaoliang@huawei.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "dvyukov@google.com" <dvyukov@google.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jiazhenghua <jiazhenghua@huawei.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "thgarnie@google.com" <thgarnie@google.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

On 22/11/17 12:56, Liuwenliang (Abbott Liu) wrote:
> On Nov 22, 2017  20:30  Mark Rutland [mailto:mark.rutland@arm.com] wrote:
>> On Tue, Nov 21, 2017 at 07:59:01AM +0000, Liuwenliang (Abbott Liu) wrote:
>>> On Nov 17, 2017  21:49  Marc Zyngier [mailto:marc.zyngier@arm.com]  wrote:
>>>> On Sat, 18 Nov 2017 10:40:08 +0000
>>>> "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com> wrote:
>>>>> On Nov 17, 2017  15:36 Christoffer Dall [mailto:cdall@linaro.org]  wrote:
> 
>>> Please don't ask people to limit to 4GB of physical space on CPU
>>> supporting LPAE, please don't ask people to guaranteed to have some
>>> memory below 4GB on CPU supporting LPAE.
> 
>> I don't think that Marc is suggesting that you'd always use the 32-bit
>> accessors on an LPAE system, just that all the definitions should exist
>> regardless of configuration.
> 
>> So rather than this:
> 
>>> +#ifdef CONFIG_ARM_LPAE
>>> +#define TTBR0           __ACCESS_CP15_64(0, c2)
>>> +#define TTBR1           __ACCESS_CP15_64(1, c2)
>>> +#define PAR             __ACCESS_CP15_64(0, c7)
>>> +#else
>>> +#define TTBR0           __ACCESS_CP15(c2, 0, c0, 0)
>>> +#define TTBR1           __ACCESS_CP15(c2, 0, c0, 1)
>>> +#define PAR             __ACCESS_CP15(c7, 0, c4, 0)
>>> +#endif
> 
>> ... you'd have the following in cp15.h:
> 
>> #define TTBR0_64       __ACCESS_CP15_64(0, c2)
>> #define TTBR1_64       __ACCESS_CP15_64(1, c2)
>> #define PAR_64         __ACCESS_CP15_64(0, c7)
> 
>> #define TTBR0_32       __ACCESS_CP15(c2, 0, c0, 0)
>> #define TTBR1_32       __ACCESS_CP15(c2, 0, c0, 1)
>> #define PAR_32         __ACCESS_CP15(c7, 0, c4, 0)
> 
>> ... and elsewhere, where it matters, we choose which to use depending on
>> the kernel configuration, e.g.
> 
>> void set_ttbr0(u64 val)
>> {
>>       if (IS_ENABLED(CONFIG_ARM_LPAE))
>>               write_sysreg(val, TTBR0_64);
>>       else
>>               write_sysreg(val, TTBR0_32);
>> }
> 
>> Thanks,
>> Mark.
> 
> Thanks for your solution.
> I didn't know there was a IS_ENABLED macro that I can use, so I can't write a function 
> like:
> void set_ttbr0(u64 val)
> {
>        if (IS_ENABLED(CONFIG_ARM_LPAE))
>                write_sysreg(val, TTBR0_64);
>        else
>                write_sysreg(val, TTBR0_32);
> }
> 
> 
> Here is the code I tested on vexpress_a9 and vexpress_a15:
> diff --git a/arch/arm/include/asm/cp15.h b/arch/arm/include/asm/cp15.h
> index dbdbce1..5eb0185 100644
> --- a/arch/arm/include/asm/cp15.h
> +++ b/arch/arm/include/asm/cp15.h
> @@ -2,6 +2,7 @@
>  #define __ASM_ARM_CP15_H
> 
>  #include <asm/barrier.h>
> +#include <linux/stringify.h>
> 
>  /*
>   * CR1 bits (CP#15 CR1)
> @@ -64,8 +65,93 @@
>  #define __write_sysreg(v, r, w, c, t)  asm volatile(w " " c : : "r" ((t)(v)))
>  #define write_sysreg(v, ...)           __write_sysreg(v, __VA_ARGS__)
> 
> +#define TTBR0_32           __ACCESS_CP15(c2, 0, c0, 0)
> +#define TTBR1_32           __ACCESS_CP15(c2, 0, c0, 1)
> +#define TTBR0_64           __ACCESS_CP15_64(0, c2)
> +#define TTBR1_64           __ACCESS_CP15_64(1, c2)
> +#define PAR             __ACCESS_CP15_64(0, c7)

Please define both PAR accessors. Yes, I know the 32bit version is not
used yet, but it doesn't hurt to make it visible.

Thanks,

	M.
-- 
Jazz is not dead. It just smells funny...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
