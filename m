Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D5F16B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 17:42:19 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r68so4224300wmr.6
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 14:42:19 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id t28si12474135wra.453.2017.10.11.14.42.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Oct 2017 14:42:18 -0700 (PDT)
Date: Wed, 11 Oct 2017 22:41:31 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 01/11] Initialize the mapping of KASan shadow memory
Message-ID: <20171011214131.GV20805@n2100.armlinux.org.uk>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-2-liuwenliang@huawei.com>
 <b53b3281-5eef-7cbd-c7d3-5417d764667b@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b53b3281-5eef-7cbd-c7d3-5417d764667b@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: Abbott Liu <liuwenliang@huawei.com>, aryabinin@virtuozzo.com, afzal.mohd.ma@gmail.com, labbott@redhat.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, cdall@linaro.org, marc.zyngier@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, mawilcox@microsoft.com, tglx@linutronix.de, thgarnie@google.com, keescook@chromium.org, arnd@arndb.de, vladimir.murzin@arm.com, tixy@linaro.org, ard.biesheuvel@linaro.org, robin.murphy@arm.com, mingo@kernel.org, grygorii.strashko@linaro.org, opendmb@gmail.com, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, zengweilin@huawei.com, linux-mm@kvack.org, dylix.dailei@huawei.com, glider@google.com, dvyukov@google.com, jiazhenghua@huawei.com, linux-arm-kernel@lists.infradead.org, heshaoliang@huawei.com

On Wed, Oct 11, 2017 at 12:39:39PM -0700, Florian Fainelli wrote:
> On 10/11/2017 01:22 AM, Abbott Liu wrote:
> > diff --git a/arch/arm/kernel/head-common.S b/arch/arm/kernel/head-common.S
> > index 8733012..c17f4a2 100644
> > --- a/arch/arm/kernel/head-common.S
> > +++ b/arch/arm/kernel/head-common.S
> > @@ -101,7 +101,11 @@ __mmap_switched:
> >  	str	r2, [r6]			@ Save atags pointer
> >  	cmp	r7, #0
> >  	strne	r0, [r7]			@ Save control register values
> > +#ifdef CONFIG_KASAN
> > +	b	kasan_early_init
> > +#else
> >  	b	start_kernel
> > +#endif
> 
> Please don't make this "exclusive" just conditionally call
> kasan_early_init(), remove the call to start_kernel from
> kasan_early_init and keep the call to start_kernel here.

iow:

#ifdef CONFIG_KASAN
	bl	kasan_early_init
#endif
	b	start_kernel

This has the advantage that we don't leave any stack frame from
kasan_early_init() on the init task stack.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
