Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 278126B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 08:52:09 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 196so3496724wma.6
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 05:52:09 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id c55si1519094wra.32.2017.10.19.05.52.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 05:52:07 -0700 (PDT)
Date: Thu, 19 Oct 2017 13:51:33 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 06/11] change memory_is_poisoned_16 for aligned error
Message-ID: <20171019125133.GA20805@n2100.armlinux.org.uk>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-7-liuwenliang@huawei.com>
 <20171011162345.f601c29d12c81af85bf38565@linux-foundation.org>
 <CACT4Y+Ym3kq5RZ-4F=f97bvT2pNpzDf0kerf6tebzLOY_crR8Q@mail.gmail.com>
 <B8AC3E80E903784988AB3003E3E97330B2528234@dggemm510-mbs.china.huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <B8AC3E80E903784988AB3003E3E97330B2528234@dggemm510-mbs.china.huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liuwenliang (Lamb)" <liuwenliang@huawei.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, Laura Abbott <labbott@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Matthew Wilcox <mawilcox@microsoft.com>, Thomas Gleixner <tglx@linutronix.de>, Thomas Garnier <thgarnie@google.com>, Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>, Vladimir Murzin <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, Ingo Molnar <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, Alexander Potapenko <glider@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

On Thu, Oct 12, 2017 at 11:27:40AM +0000, Liuwenliang (Lamb) wrote:
> >> - I don't understand why this is necessary.  memory_is_poisoned_16()
> >>   already handles unaligned addresses?
> >>
> >> - If it's needed on ARM then presumably it will be needed on other
> >>   architectures, so CONFIG_ARM is insufficiently general.
> >>
> >> - If the present memory_is_poisoned_16() indeed doesn't work on ARM,
> >>   it would be better to generalize/fix it in some fashion rather than
> >>   creating a new variant of the function.
> 
> 
> >Yes, I think it will be better to fix the current function rather then
> >have 2 slightly different copies with ifdef's.
> >Will something along these lines work for arm? 16-byte accesses are
> >not too common, so it should not be a performance problem. And
> >probably modern compilers can turn 2 1-byte checks into a 2-byte check
> >where safe (x86).
> 
> >static __always_inline bool memory_is_poisoned_16(unsigned long addr)
> >{
> >        u8 *shadow_addr = (u8 *)kasan_mem_to_shadow((void *)addr);
> >
> >        if (shadow_addr[0] || shadow_addr[1])
> >                return true;
> >        /* Unaligned 16-bytes access maps into 3 shadow bytes. */
> >        if (unlikely(!IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
> >                return memory_is_poisoned_1(addr + 15);
> >        return false;
> >}
> 
> Thanks for Andrew Morton and Dmitry Vyukov's review. 
> If the parameter addr=0xc0000008, now in function:
> static __always_inline bool memory_is_poisoned_16(unsigned long addr)
> {
>  ---     //shadow_addr = (u16 *)(KASAN_OFFSET+0x18000001(=0xc0000008>>3)) is not 
>  ---     // unsigned by 2 bytes.
>         u16 *shadow_addr = (u16 *)kasan_mem_to_shadow((void *)addr); 
> 
>         /* Unaligned 16-bytes access maps into 3 shadow bytes. */
>         if (unlikely(!IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
>                 return *shadow_addr || memory_is_poisoned_1(addr + 15);
> ----      //here is going to be error on arm, specially when kernel has not finished yet.
> ----      //Because the unsigned accessing cause DataAbort Exception which is not
> ----      //initialized when kernel is starting. 
>         return *shadow_addr;
> }
> 
> I also think it is better to fix this problem. 

What about using get_unaligned() ?

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
