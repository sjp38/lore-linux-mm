Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B74156B0022
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 14:16:06 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r78so6142438wmd.0
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 11:16:06 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id 2si597031wrg.485.2018.04.02.11.16.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Apr 2018 11:16:05 -0700 (PDT)
Date: Mon, 2 Apr 2018 19:15:37 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH v3 5/6] Initialize the mapping of KASan shadow memory
Message-ID: <20180402181536.GJ16141@n2100.armlinux.org.uk>
References: <20180402120440.31900-1-liuwenliang@huawei.com>
 <20180402120440.31900-6-liuwenliang@huawei.com>
 <nycvar.YSQ.7.76.1804021402521.28462@knanqh.ubzr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YSQ.7.76.1804021402521.28462@knanqh.ubzr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Abbott Liu <liuwenliang@huawei.com>, kstewart@linuxfoundation.org, tixy@linaro.org, grygorii.strashko@linaro.org, julien.thierry@arm.com, Catalin Marinas <catalin.marinas@arm.com>, linux@rasmusvillemoes.dk, dhowells@redhat.com, linux-mm@kvack.org, mark.rutland@arm.com, kvmarm@lists.cs.columbia.edu, f.fainelli@gmail.com, Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, geert@linux-m68k.org, linux-arm-kernel@lists.infradead.org, zhichao.huang@linaro.org, aryabinin@virtuozzo.com, labbott@redhat.com, vladimir.murzin@arm.com, keescook@chromium.org, Arnd Bergmann <arnd@arndb.de>, marc.zyngier@arm.com, philip@cog.systems, jinb.park7@gmail.com, opendmb@gmail.com, tglx@linutronix.de, dvyukov@google.com, ard.biesheuvel@linaro.org, gregkh@linuxfoundation.org, mawilcox@microsoft.com, linux-kernel@vger.kernel.org, alexander.levin@verizon.com, james.morse@arm.com, kirill.shutemov@linux.intel.com, pombredanne@nexb.com, Andrew Morton <akpm@linux-foundation.org>, thgarnie@google.com, christoffer.dall@linaro.org

On Mon, Apr 02, 2018 at 02:08:13PM -0400, Nicolas Pitre wrote:
> On Mon, 2 Apr 2018, Abbott Liu wrote:
> 
> > index c79b829..20161e2 100644
> > --- a/arch/arm/kernel/head-common.S
> > +++ b/arch/arm/kernel/head-common.S
> > @@ -115,6 +115,9 @@ __mmap_switched:
> >  	str	r8, [r2]			@ Save atags pointer
> >  	cmp	r3, #0
> >  	strne	r10, [r3]			@ Save control register values
> > +#ifdef CONFIG_KASAN
> > +	bl	kasan_early_init
> > +#endif
> >  	mov	lr, #0
> >  	b	start_kernel
> >  ENDPROC(__mmap_switched)
> 
> Would be better if lr was cleared before calling kasan_early_init.

No.  The code is correct - please remember that "bl" writes to LR.

The point of clearing LR here is to ensure that start_kernel is called
with a zero link register, which it won't be if kasan_early_init is
moved after it.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
