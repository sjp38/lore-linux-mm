Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 010DD6B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 08:49:42 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id b13so7524651wgh.13
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 05:49:41 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.10])
        by mx.google.com with ESMTPS id r3si2658245wix.30.2015.01.23.05.49.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jan 2015 05:49:40 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] ARM: use default ioremap alignment for SMP or LPAE
Date: Thu, 22 Jan 2015 12:03 +0100
Message-ID: <3060178.HEZJjJCl1e@wuerfel>
In-Reply-To: <20150122100441.GA19811@e104818-lin.cambridge.arm.com>
References: <1421911075-8814-1-git-send-email-s.dyasly@samsung.com> <20150122100441.GA19811@e104818-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Sergey Dyasly <s.dyasly@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Russell King <linux@arm.linux.org.uk>, Guan Xuetao <gxt@mprc.pku.edu.cn>, "nicolas.pitre@linaro.org" <nicolas.pitre@linaro.org>, James Bottomley <JBottomley@parallels.com>, Will Deacon <Will.Deacon@arm.com>, Arnd Bergmann <arnd.bergmann@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Safonov <d.safonov@partner.samsung.com>

On Thursday 22 January 2015 10:04:41 Catalin Marinas wrote:
> On Thu, Jan 22, 2015 at 07:17:55AM +0000, Sergey Dyasly wrote:
> > 16MB alignment for ioremap mappings was added by commit a069c896d0d6 ("[ARM]
> > 3705/1: add supersection support to ioremap()") in order to support supersection
> > mappings. But __arm_ioremap_pfn_caller uses section and supersection mappings
> > only in !SMP && !LPAE case. There is no need for such big alignment if either
> > SMP or LPAE is enabled.
> [...]
> > diff --git a/arch/arm/include/asm/memory.h b/arch/arm/include/asm/memory.h
> > index 184def0..c3ef139 100644
> > --- a/arch/arm/include/asm/memory.h
> > +++ b/arch/arm/include/asm/memory.h
> > @@ -78,10 +78,12 @@
> >   */
> >  #define XIP_VIRT_ADDR(physaddr)  (MODULES_VADDR + ((physaddr) & 0x000fffff))
> >  
> > +#if !defined(CONFIG_SMP) && !defined(CONFIG_ARM_LPAE)
> >  /*
> >   * Allow 16MB-aligned ioremap pages
> >   */
> >  #define IOREMAP_MAX_ORDER    24
> > +#endif
> 
> Actually, I think we could make this depend only on CONFIG_IO_36. That's
> the only scenario where we get the supersections matter, and maybe make
> CONFIG_IO_36 dependent on !SMP or !ARM_LPAE.

Good point, I assumed this was just a performance optimization,
but it is in fact required for dynamic high mappings on XSC3.

> My assumption is that we
> don't support single zImage with CPU_XSC3 enabled (but I haven't
> followed the latest developments here).

I have said in the past that I do not expect any of the xscale or
strongarm based platforms to be used with a single zImage kernel.
This has changed slightly given the work that Robert Jarzmik and
others are doing on mach-pxa with DT conversion. I still don't
think it's likely that they will move on to multiplatform, but I
no longer think it's impossible.

Fortunately, PXA also does not have any high physical address mappings
that I can see. The only platform we have that has these (see
'git grep ioremap_pfn') is mach-iop13xx, and I am still seeing
this in the 'never going to be multiplatform' category.

Unrelated to this question however is whether we want to keep
supersection mappings as a performance optimization to save TLBs.
It seems useful to me, but not critical.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
