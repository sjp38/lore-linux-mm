Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4977A6B0069
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 10:22:44 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id k100so12230499wrc.9
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 07:22:44 -0800 (PST)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id s67si5311679wme.114.2017.11.23.07.22.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 07:22:42 -0800 (PST)
Date: Thu, 23 Nov 2017 15:22:18 +0000
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 01/11] Initialize the mapping of KASan shadow memory
Message-ID: <20171123152218.GQ31757@n2100.armlinux.org.uk>
References: <87375eqobb.fsf@on-the-bus.cambridge.arm.com>
 <B8AC3E80E903784988AB3003E3E97330C0063816@dggemm510-mbs.china.huawei.com>
 <20171117073556.GB28855@cbox>
 <B8AC3E80E903784988AB3003E3E97330C00638D4@dggemm510-mbs.china.huawei.com>
 <20171118134841.3f6c9183@why.wild-wind.fr.eu.org>
 <B8AC3E80E903784988AB3003E3E97330C0068F12@dggemm510-mbx.china.huawei.com>
 <20171121122938.sydii3i36jbzi7x4@lakrids.cambridge.arm.com>
 <B8AC3E80E903784988AB3003E3E97330C0069032@dggemm510-mbx.china.huawei.com>
 <757534e5-fcea-3eb4-3c8d-b8c7e709f555@arm.com>
 <B8AC3E80E903784988AB3003E3E97330C0069083@dggemm510-mbx.china.huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <B8AC3E80E903784988AB3003E3E97330C0069083@dggemm510-mbx.china.huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Cc: Marc Zyngier <marc.zyngier@arm.com>, Mark Rutland <mark.rutland@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "mhocko@suse.com" <mhocko@suse.com>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "glider@google.com" <glider@google.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "mingo@kernel.org" <mingo@kernel.org>, Christoffer Dall <cdall@linaro.org>, "opendmb@gmail.com" <opendmb@gmail.com>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, Dailei <dylix.dailei@huawei.com>, "dvyukov@google.com" <dvyukov@google.com>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "labbott@redhat.com" <labbott@redhat.com>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, Zengweilin <zengweilin@huawei.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, Heshaoliang <heshaoliang@huawei.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jiazhenghua <jiazhenghua@huawei.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "thgarnie@google.com" <thgarnie@google.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

On Thu, Nov 23, 2017 at 01:54:59AM +0000, Liuwenliang (Abbott Liu) wrote:
> On Nov 23, 2017  20:30  Marc Zyngier [mailto:marc.zyngier@arm.com]  wrote:
> >Please define both PAR accessors. Yes, I know the 32bit version is not
> >used yet, but it doesn't hurt to make it visible.
> 
> Thanks for your review.
> I'm going to change it in the new version.
> Here is the code I tested on vexpress_a9 and vexpress_a15:
> diff --git a/arch/arm/include/asm/cp15.h b/arch/arm/include/asm/cp15.h
> index dbdbce1..b8353b1 100644
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
> @@ -64,8 +65,109 @@
>  #define __write_sysreg(v, r, w, c, t)  asm volatile(w " " c : : "r" ((t)(v)))
>  #define write_sysreg(v, ...)           __write_sysreg(v, __VA_ARGS__)
> 
> +#define TTBR0_32     __ACCESS_CP15(c2, 0, c0, 0)
> +#define TTBR1_32     __ACCESS_CP15(c2, 0, c0, 1)
> +#define PAR_32               __ACCESS_CP15(c7, 0, c4, 0)
> +#define TTBR0_64     __ACCESS_CP15_64(0, c2)
> +#define TTBR1_64     __ACCESS_CP15_64(1, c2)
> +#define PAR_64               __ACCESS_CP15_64(0, c7)
> +#define VTTBR           __ACCESS_CP15_64(6, c2)
> +#define CNTV_CVAL       __ACCESS_CP15_64(3, c14)
> +#define CNTVOFF         __ACCESS_CP15_64(4, c14)
> +
> +#define MIDR            __ACCESS_CP15(c0, 0, c0, 0)
> +#define CSSELR          __ACCESS_CP15(c0, 2, c0, 0)
> +#define VPIDR           __ACCESS_CP15(c0, 4, c0, 0)
> +#define VMPIDR          __ACCESS_CP15(c0, 4, c0, 5)
> +#define SCTLR           __ACCESS_CP15(c1, 0, c0, 0)
> +#define CPACR           __ACCESS_CP15(c1, 0, c0, 2)
> +#define HCR             __ACCESS_CP15(c1, 4, c1, 0)
> +#define HDCR            __ACCESS_CP15(c1, 4, c1, 1)
> +#define HCPTR           __ACCESS_CP15(c1, 4, c1, 2)
> +#define HSTR            __ACCESS_CP15(c1, 4, c1, 3)
> +#define TTBCR           __ACCESS_CP15(c2, 0, c0, 2)
> +#define HTCR            __ACCESS_CP15(c2, 4, c0, 2)
> +#define VTCR            __ACCESS_CP15(c2, 4, c1, 2)
> +#define DACR            __ACCESS_CP15(c3, 0, c0, 0)
> +#define DFSR            __ACCESS_CP15(c5, 0, c0, 0)
> +#define IFSR            __ACCESS_CP15(c5, 0, c0, 1)
> +#define ADFSR           __ACCESS_CP15(c5, 0, c1, 0)
> +#define AIFSR           __ACCESS_CP15(c5, 0, c1, 1)
> +#define HSR             __ACCESS_CP15(c5, 4, c2, 0)
> +#define DFAR            __ACCESS_CP15(c6, 0, c0, 0)
> +#define IFAR            __ACCESS_CP15(c6, 0, c0, 2)
> +#define HDFAR           __ACCESS_CP15(c6, 4, c0, 0)
> +#define HIFAR           __ACCESS_CP15(c6, 4, c0, 2)
> +#define HPFAR           __ACCESS_CP15(c6, 4, c0, 4)
> +#define ICIALLUIS       __ACCESS_CP15(c7, 0, c1, 0)
> +#define ATS1CPR         __ACCESS_CP15(c7, 0, c8, 0)
> +#define TLBIALLIS       __ACCESS_CP15(c8, 0, c3, 0)
> +#define TLBIALL         __ACCESS_CP15(c8, 0, c7, 0)
> +#define TLBIALLNSNHIS   __ACCESS_CP15(c8, 4, c3, 4)
> +#define PRRR            __ACCESS_CP15(c10, 0, c2, 0)
> +#define NMRR            __ACCESS_CP15(c10, 0, c2, 1)
> +#define AMAIR0          __ACCESS_CP15(c10, 0, c3, 0)
> +#define AMAIR1          __ACCESS_CP15(c10, 0, c3, 1)
> +#define VBAR            __ACCESS_CP15(c12, 0, c0, 0)
> +#define CID             __ACCESS_CP15(c13, 0, c0, 1)
> +#define TID_URW         __ACCESS_CP15(c13, 0, c0, 2)
> +#define TID_URO         __ACCESS_CP15(c13, 0, c0, 3)
> +#define TID_PRIV        __ACCESS_CP15(c13, 0, c0, 4)
> +#define HTPIDR          __ACCESS_CP15(c13, 4, c0, 2)
> +#define CNTKCTL         __ACCESS_CP15(c14, 0, c1, 0)
> +#define CNTV_CTL        __ACCESS_CP15(c14, 0, c3, 1)
> +#define CNTHCTL         __ACCESS_CP15(c14, 4, c1, 0)
> +
>  extern unsigned long cr_alignment;     /* defined in entry-armv.S */
> 
> +static inline void set_par(u64 val)
> +{
> +        if (IS_ENABLED(CONFIG_ARM_LPAE))
> +                write_sysreg(val, PAR_64);
> +        else
> +                write_sysreg(val, PAR_32);
> +}
> +
> +static inline u64 get_par(void)
> +{
> +        if (IS_ENABLED(CONFIG_ARM_LPAE))
> +                return read_sysreg(PAR_64);
> +        else
> +                return (u64)read_sysreg(PAR_32);
> +}
> +
> +static inline void set_ttbr0(u64 val)
> +{
> + if (IS_ENABLED(CONFIG_ARM_LPAE))
> +         write_sysreg(val, TTBR0_64);
> + else
> +         write_sysreg(val, TTBR0_32);
> +}
> +
> +static inline u64 get_ttbr0(void)
> +{
> + if (IS_ENABLED(CONFIG_ARM_LPAE))
> +         return read_sysreg(TTBR0_64);
> + else
> +         return (u64)read_sysreg(TTBR0_32);
> +}
> +
> +static inline void set_ttbr1(u64 val)
> +{
> + if (IS_ENABLED(CONFIG_ARM_LPAE))
> +         write_sysreg(val, TTBR1_64);
> + else
> +         write_sysreg(val, TTBR1_32);
> +}
> +
> +static inline u64 get_ttbr1(void)
> +{
> + if (IS_ENABLED(CONFIG_ARM_LPAE))
> +         return read_sysreg(TTBR1_64);
> + else
> +         return (u64)read_sysreg(TTBR1_32);
> +}
> +

Please pay attention to the project coding style whenever creating code
for a program.  It doesn't matter what the project coding style is, as
long as you write your code to match the style that is already there.

For the kernel, that is: tabs not spaces for indentation of code.
You seem to be using a variable number of spaces for all the new code
above.

Some of it seems to be your email client thinking it knows better about
white space - and such behaviours basically makes patches unapplyable.
See Documentation/process/email-clients.rst for hints about email
clients.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
