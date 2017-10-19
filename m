Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4AA686B0069
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 08:42:06 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id n4so3981510wrb.8
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 05:42:06 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id w6si1484285wra.4.2017.10.19.05.42.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 05:42:05 -0700 (PDT)
Date: Thu, 19 Oct 2017 13:41:49 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 04/11] Define the virtual space of KASan's shadow region
Message-ID: <20171019124149.GX20805@n2100.armlinux.org.uk>
References: <20171011082227.20546-5-liuwenliang@huawei.com>
 <201710141957.mbxeZJHB%fengguang.wu@intel.com>
 <B8AC3E80E903784988AB3003E3E97330C005B9BF@dggemm510-mbx.china.huawei.com>
 <CAKv+Gu98M9PZk3qm0PYC8nQ3zMvLZmNmOn4=hNdFE7NTBuHbgg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu98M9PZk3qm0PYC8nQ3zMvLZmNmOn4=hNdFE7NTBuHbgg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "Liuwenliang (Lamb)" <liuwenliang@huawei.com>, "tixy@linaro.org" <tixy@linaro.org>, "mhocko@suse.com" <mhocko@suse.com>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "glider@google.com" <glider@google.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "mingo@kernel.org" <mingo@kernel.org>, "cdall@linaro.org" <cdall@linaro.org>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, kbuild test robot <lkp@intel.com>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, Dailei <dylix.dailei@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "labbott@redhat.com" <labbott@redhat.com>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, Zengweilin <zengweilin@huawei.com>, "opendmb@gmail.com" <opendmb@gmail.com>, Heshaoliang <heshaoliang@huawei.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "dvyukov@google.com" <dvyukov@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kbuild-all@01.org" <kbuild-all@01.org>, Jiazhenghua <jiazhenghua@huawei.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "thgarnie@google.com" <thgarnie@google.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

On Mon, Oct 16, 2017 at 01:14:54PM +0100, Ard Biesheuvel wrote:
> On 16 October 2017 at 12:42, Liuwenliang (Lamb) <liuwenliang@huawei.com> wrote:
> > On 10/16/2017 07:03 PM, Abbott Liu wrote:
> >>arch/arm/kernel/entry-armv.S:348: Error: selected processor does not support `movw r1,
> >   #:lower16:((((0xC0000000-0x01000000)>>3)+((0xC0000000-0x01000000)-(1<<29))))' in ARM mode
> >>arch/arm/kernel/entry-armv.S:348: Error: selected processor does not support `movt r1,
> >   #:upper16:((((0xC0000000-0x01000000)>>3)+((0xC0000000-0x01000000)-(1<<29))))' in ARM mode
> >
> > Thanks for building test. This error can be solved by following code:
> > --- a/arch/arm/kernel/entry-armv.S
> > +++ b/arch/arm/kernel/entry-armv.S
> > @@ -188,8 +188,7 @@ ENDPROC(__und_invalid)
> >         get_thread_info tsk
> >         ldr     r0, [tsk, #TI_ADDR_LIMIT]
> >  #ifdef CONFIG_KASAN
> > -   movw r1, #:lower16:TASK_SIZE
> > -   movt r1, #:upper16:TASK_SIZE
> > + ldr r1, =TASK_SIZE
> >  #else
> >         mov r1, #TASK_SIZE
> >  #endif
> 
> This is unnecessary:
> 
> ldr r1, =TASK_SIZE
> 
> will be converted to a mov instruction by the assembler if the value
> of TASK_SIZE fits its 12-bit immediate field.

It's an 8-bit immediate field for ARM.

What it won't do is expand it to a pair of movw/movt instructions if it
doesn't fit.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
