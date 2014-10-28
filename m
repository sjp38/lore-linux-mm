Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id C2193900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 09:59:56 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so789308pab.22
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 06:59:56 -0700 (PDT)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id x3si1475177pdm.53.2014.10.28.06.59.55
        for <linux-mm@kvack.org>;
        Tue, 28 Oct 2014 06:59:55 -0700 (PDT)
Date: Tue, 28 Oct 2014 13:59:44 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC V3] arm/arm64:add CONFIG_HAVE_ARCH_BITREVERSE to support
 rbit instruction
Message-ID: <20141028135944.GC29706@arm.com>
References: <35FD53F367049845BC99AC72306C23D103E010D18254@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18257@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18259@CNBJMBX05.corpusers.net>
 <20141027104848.GD8768@arm.com>
 <35FD53F367049845BC99AC72306C23D103E010D1825A@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E010D1825A@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>

On Tue, Oct 28, 2014 at 01:34:42AM +0000, Wang, Yalin wrote:
> > From: Will Deacon [mailto:will.deacon@arm.com]
> > > +++ b/arch/arm/include/asm/bitrev.h
> > > @@ -0,0 +1,28 @@
> > > +#ifndef __ASM_ARM_BITREV_H
> > > +#define __ASM_ARM_BITREV_H
> > > +
> > > +static __always_inline __attribute_const__ u32 __arch_bitrev32(u32 x)
> > > +{
> > > +	if (__builtin_constant_p(x)) {
> > > +		x = (x >> 16) | (x << 16);
> > > +		x = ((x & 0xFF00FF00) >> 8) | ((x & 0x00FF00FF) << 8);
> > > +		x = ((x & 0xF0F0F0F0) >> 4) | ((x & 0x0F0F0F0F) << 4);
> > > +		x = ((x & 0xCCCCCCCC) >> 2) | ((x & 0x33333333) << 2);
> > > +		return ((x & 0xAAAAAAAA) >> 1) | ((x & 0x55555555) << 1);
> > > +	}
> > > +	__asm__ ("rbit %0, %1" : "=r" (x) : "r" (x));
> > 
> > I think you need to use %w0 and %w1 here, otherwise you bit-reverse the 64-
> > bit register.
> For arm64 in arch/arm64/include/asm/bitrev.h.
> I have use __asm__ ("rbit %w0, %w1" : "=r" (x) : "r" (x));
> For arm , I use __asm__ ("rbit %0, %1" : "=r" (x) : "r" (x));
> Am I right ?

Yup, sorry, I didn't realise this patch covered both architectures. It would
probably be a good idea to split it into 3 parts: a core part, then the two
architectural bits.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
