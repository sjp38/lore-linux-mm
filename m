Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D7F4F6B0033
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 04:40:57 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id v69so3998502wrb.3
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 01:40:57 -0800 (PST)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id l44si4228986wre.375.2017.11.21.01.40.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Nov 2017 01:40:56 -0800 (PST)
Date: Tue, 21 Nov 2017 09:40:27 +0000
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: =?utf-8?B?562U5aSN?= =?utf-8?Q?=3A?= [PATCH 01/11] Initialize
 the mapping of KASan shadow memory
Message-ID: <20171121094027.GF31757@n2100.armlinux.org.uk>
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
Cc: Marc Zyngier <marc.zyngier@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "mhocko@suse.com" <mhocko@suse.com>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "glider@google.com" <glider@google.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "mingo@kernel.org" <mingo@kernel.org>, Christoffer Dall <cdall@linaro.org>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, Dailei <dylix.dailei@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "labbott@redhat.com" <labbott@redhat.com>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, Zengweilin <zengweilin@huawei.com>, "opendmb@gmail.com" <opendmb@gmail.com>, Heshaoliang <heshaoliang@huawei.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "dvyukov@google.com" <dvyukov@google.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jiazhenghua <jiazhenghua@huawei.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "thgarnie@google.com" <thgarnie@google.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

On Tue, Nov 21, 2017 at 07:59:01AM +0000, Liuwenliang (Abbott Liu) wrote:
> On Nov 17, 2017  21:49  Marc Zyngier [mailto:marc.zyngier@arm.com]  wrote:
> >On Sat, 18 Nov 2017 10:40:08 +0000
> >"Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com> wrote:
> 
> >> On Nov 17, 2017  15:36 Christoffer Dall [mailto:cdall@linaro.org]  wrote:
> >> >If your processor does support LPAE (like a Cortex-A15 for example),
> >> >then you have both the 32-bit accessors (MRC and MCR) and the 64-bit
> >> >accessors (MRRC, MCRR), and using the 32-bit accessor will simply access
> >> >the lower 32-bits of the 64-bit register.
> >> >
> >> >Hope this helps,
> >> >-Christoffer
> >>
> >> If you know the higher 32-bits of the 64-bits cp15's register is not useful for your system,
> >> then you can use the 32-bit accessor to get or set the 64-bit cp15's register.
> >> But if the higher 32-bits of the 64-bits cp15's register is useful for your system,
> >> then you can't use the 32-bit accessor to get or set the 64-bit cp15's register.
> >>
> >> TTBR0/TTBR1/PAR's higher 32-bits is useful for CPU supporting LPAE.
> >> The following description which comes from ARM(r) Architecture Reference
> >> Manual ARMv7-A and ARMv7-R edition tell us the reason:
> >>
> >> 64-bit TTBR0 and TTBR1 format:
> >> ...
> >> BADDR, bits[39:x] :
> >> Translation table base address, bits[39:x]. Defining the translation table base address width on
> >> page B4-1698 describes how x is defined.
> >> The value of x determines the required alignment of the translation table, which must be aligned to
> >> 2x bytes.
> >>
> >> Abbott Liu: Because BADDR on CPU supporting LPAE may be bigger than max value of 32-bit, so bits[39:32] may
> >> be valid value which is useful for the system.
> >>
> >> 64-bit PAR format
> >> ...
> >> PA[39:12]
> >> Physical Address. The physical address corresponding to the supplied virtual address. This field
> >> returns address bits[39:12].
> >>
> >> Abbott Liu: Because Physical Address on CPU supporting LPAE may be bigger than max value of 32-bit,
> >> so bits[39:32] may be valid value which is useful for the system.
> >>
> >> Conclusion: Don't use 32-bit accessor to get or set TTBR0/TTBR1/PAR on CPU supporting LPAE,
> >> if you do that, your system may run error.
> 
> >That's not really true. You can run an non-LPAE kernel that uses the
> >32bit accessors an a Cortex-A15 that supports LPAE. You're just limited
> >to 4GB of physical space. And you're pretty much guaranteed to have
> >some memory below 4GB (one way or another), or you'd have a slight
> >problem setting up your page tables.
> 
> >       M.
> >--
> >Without deviation from the norm, progress is not possible.
> 
> Thanks for your review.
> Please don't ask people to limit to 4GB of physical space on CPU
> supporting LPAE, please don't ask people to guaranteed to have some
> memory below 4GB on CPU supporting LPAE.

A LPAE-capable CPU must always have memory below 4GB physical, no ifs
no buts.

If there's no memory below 4GB physical, then the CPU has no accessible
memory before the MMU is enabled.  That means operating systems such as
Linux are completely unbootable.

There must _always_ be accessible memory below 4GB physical.  This is
not negotiable, it's a fundamental requirement.

The location of physical memory has nothing to do with the accessors.
This point I'm making also has nothing to do with the accessors.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
