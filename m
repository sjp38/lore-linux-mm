Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF92B6B0253
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 07:29:48 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id w205so5944931oig.7
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 04:29:48 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u5si5084486oif.132.2017.11.21.04.29.47
        for <linux-mm@kvack.org>;
        Tue, 21 Nov 2017 04:29:47 -0800 (PST)
Date: Tue, 21 Nov 2017 12:29:38 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: =?utf-8?B?562U5aSN?= =?utf-8?Q?=3A?= [PATCH 01/11] Initialize
 the mapping of KASan shadow memory
Message-ID: <20171121122938.sydii3i36jbzi7x4@lakrids.cambridge.arm.com>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <B8AC3E80E903784988AB3003E3E97330C0068F12@dggemm510-mbx.china.huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Cc: Marc Zyngier <marc.zyngier@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "mhocko@suse.com" <mhocko@suse.com>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "glider@google.com" <glider@google.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "mingo@kernel.org" <mingo@kernel.org>, Christoffer Dall <cdall@linaro.org>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, Dailei <dylix.dailei@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "labbott@redhat.com" <labbott@redhat.com>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, Zengweilin <zengweilin@huawei.com>, "opendmb@gmail.com" <opendmb@gmail.com>, Heshaoliang <heshaoliang@huawei.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "dvyukov@google.com" <dvyukov@google.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jiazhenghua <jiazhenghua@huawei.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "thgarnie@google.com" <thgarnie@google.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

On Tue, Nov 21, 2017 at 07:59:01AM +0000, Liuwenliang (Abbott Liu) wrote:
> On Nov 17, 2017  21:49  Marc Zyngier [mailto:marc.zyngier@arm.com]  wrote:
> >On Sat, 18 Nov 2017 10:40:08 +0000
> >"Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com> wrote:
> >> On Nov 17, 2017  15:36 Christoffer Dall [mailto:cdall@linaro.org]  wrote:

> Please don't ask people to limit to 4GB of physical space on CPU
> supporting LPAE, please don't ask people to guaranteed to have some
> memory below 4GB on CPU supporting LPAE.

I don't think that Marc is suggesting that you'd always use the 32-bit
accessors on an LPAE system, just that all the definitions should exist
regardless of configuration.

So rather than this:

> +#ifdef CONFIG_ARM_LPAE
> +#define TTBR0           __ACCESS_CP15_64(0, c2)
> +#define TTBR1           __ACCESS_CP15_64(1, c2)
> +#define PAR             __ACCESS_CP15_64(0, c7)
> +#else
> +#define TTBR0           __ACCESS_CP15(c2, 0, c0, 0)
> +#define TTBR1           __ACCESS_CP15(c2, 0, c0, 1)
> +#define PAR             __ACCESS_CP15(c7, 0, c4, 0)
> +#endif

... you'd have the following in cp15.h:

#define TTBR0_64	__ACCESS_CP15_64(0, c2)
#define TTBR1_64	__ACCESS_CP15_64(1, c2)
#define PAR_64		__ACCESS_CP15_64(0, c7)

#define TTBR0_32	__ACCESS_CP15(c2, 0, c0, 0)
#define TTBR1_32	__ACCESS_CP15(c2, 0, c0, 1)
#define PAR_32		__ACCESS_CP15(c7, 0, c4, 0)

... and elsewhere, where it matters, we choose which to use depending on
the kernel configuration, e.g.

void set_ttbr0(u64 val)
{
	if (IS_ENABLED(CONFIG_ARM_LPAE))
		write_sysreg(val, TTBR0_64);
	else
		write_sysreg(val, TTBR0_32);
}

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
