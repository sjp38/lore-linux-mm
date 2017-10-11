Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2629A6B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 18:58:54 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id v127so1717718wma.3
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 15:58:54 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id t200si11194917wme.224.2017.10.11.15.58.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Oct 2017 15:58:52 -0700 (PDT)
Date: Wed, 11 Oct 2017 23:58:06 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 00/11] KASan for arm
Message-ID: <20171011225805.GY20805@n2100.armlinux.org.uk>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <26660524-3b0a-c634-e8ce-4ba7e10c055d@gmail.com>
 <bb809843-4fb8-0827-170e-26efde0eb37f@gmail.com>
 <44c86924-930b-3eff-55b8-b02c9060ebe3@gmail.com>
 <4b7b2b3c-cba9-d8ab-72a7-119bd5fae65d@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4b7b2b3c-cba9-d8ab-72a7-119bd5fae65d@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, Abbott Liu <liuwenliang@huawei.com>, aryabinin@virtuozzo.com, afzal.mohd.ma@gmail.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, cdall@linaro.org, marc.zyngier@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, mawilcox@microsoft.com, tglx@linutronix.de, thgarnie@google.com, keescook@chromium.org, arnd@arndb.de, vladimir.murzin@arm.com, tixy@linaro.org, ard.biesheuvel@linaro.org, robin.murphy@arm.com, mingo@kernel.org, grygorii.strashko@linaro.org, Nicolas Pitre <nicolas.pitre@linaro.org>, opendmb@gmail.com, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, zengweilin@huawei.com, linux-mm@kvack.org, dylix.dailei@huawei.com, glider@google.com, dvyukov@google.com, jiazhenghua@huawei.com, linux-arm-kernel@lists.infradead.org, heshaoliang@huawei.com

On Wed, Oct 11, 2017 at 03:10:56PM -0700, Laura Abbott wrote:
> On 10/11/2017 02:36 PM, Florian Fainelli wrote:
> >>   CC      arch/arm/boot/compressed/string.o
> >> arch/arm/boot/compressed/decompress.c:51:0: warning: "memmove" redefined
> >>  #define memmove memmove
> >>
> >> In file included from arch/arm/boot/compressed/decompress.c:7:0:
> >> ./arch/arm/include/asm/string.h:67:0: note: this is the location of the
> >> previous definition
> >>  #define memmove(dst, src, len) __memmove(dst, src, len)
> >>
> >> arch/arm/boot/compressed/decompress.c:52:0: warning: "memcpy" redefined
> >>  #define memcpy memcpy
> >>
> >> In file included from arch/arm/boot/compressed/decompress.c:7:0:
> >> ./arch/arm/include/asm/string.h:66:0: note: this is the location of the
> >> previous definition
> >>  #define memcpy(dst, src, len) __memcpy(dst, src, len)
> >>
> > 
> > Was not able yet to track down why __memset is not being resolved, but
> > since I don't need them, disabled CONFIG_ATAGS and
> > CONFIG_ARM_ATAG_DTB_COMPAT and this allowed me to get a build working.
> > 
> > This brought me all the way to a prompt and please find attached the
> > results of insmod test_kasan.ko for CONFIG_ARM_LPAE=y and
> > CONFIG_ARM_LPAE=n. Your patches actually spotted a genuine use after
> > free in one of our drivers (spi-bcm-qspi) so with this:
> > 
> > Tested-by: Florian Fainelli <f.fainelli@gmail.com>
> > 
> > Great job thanks!
> > 
> 
> The memset failure comes from the fact that the decompressor has
> its own string functions and there is an #undefine memset in there.
> The git history doesn't make it clear where this comes from but
> if I remove it the kernel at least compiles for me with the
> multi_v7_defconfig.

The decompressor does not link with the standard C library, so it
needs to provide implementations of standard C library functionality
where required.  That means, if we have any memset() users, we need
to provide the memset() function.

The undef is there to avoid the optimisation we have in asm/string.h
for __memzero, because we don't want to use __memzero in the
decompressor.

Whether memset() is required depends on which compression method is
being used - LZO and LZ4 appear to make direct references to it, but
the inflate (gzip) decompressor code does not.

What this means is that all supported kernel compression options need
to be tested.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
