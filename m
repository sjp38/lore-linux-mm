Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id B468D6B00ED
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 04:58:27 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id k14so908229wgh.9
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 01:58:27 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id bq18si2991804wib.25.2014.11.14.01.58.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Nov 2014 01:58:26 -0800 (PST)
Date: Fri, 14 Nov 2014 09:58:12 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC V6 2/3] arm:add bitrev.h file to support rbit instruction
Message-ID: <20141114095812.GG4042@n2100.arm.linux.org.uk>
References: <35FD53F367049845BC99AC72306C23D103E010D18265@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18266@CNBJMBX05.corpusers.net>
 <20141030120127.GC32589@arm.com>
 <CAKv+Gu9g5Q6fjPUy+P8YxkeDrH+bdO4kKGnxTQZRFhQpgPxaPA@mail.gmail.com>
 <20141030135749.GE32589@arm.com>
 <35FD53F367049845BC99AC72306C23D103E010D18272@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18273@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18275@CNBJMBX05.corpusers.net>
 <20141113235322.GC4042@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103E010D1829B@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E010D1829B@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Will Deacon' <will.deacon@arm.com>, 'Ard Biesheuvel' <ard.biesheuvel@linaro.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Joe Perches' <joe@perches.com>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

On Fri, Nov 14, 2014 at 10:01:34AM +0800, Wang, Yalin wrote:
> > -----Original Message-----
> > From: Russell King - ARM Linux [mailto:linux@arm.linux.org.uk]
> > Sent: Friday, November 14, 2014 7:53 AM
> > To: Wang, Yalin
> > > On Fri, Oct 31, 2014 at 01:42:44PM +0800, Wang, Yalin wrote:
> > > This patch add bitrev.h file to support rbit instruction, so that we
> > > can do bitrev operation by hardware.
> > > Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> > > ---
> > >  arch/arm/Kconfig              |  1 +
> > >  arch/arm/include/asm/bitrev.h | 21 +++++++++++++++++++++
> > >  2 files changed, 22 insertions(+)
> > >  create mode 100644 arch/arm/include/asm/bitrev.h
> > >
> > > diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig index
> > > 89c4b5c..be92b3b 100644
> > > --- a/arch/arm/Kconfig
> > > +++ b/arch/arm/Kconfig
> > > @@ -28,6 +28,7 @@ config ARM
> > >  	select HANDLE_DOMAIN_IRQ
> > >  	select HARDIRQS_SW_RESEND
> > >  	select HAVE_ARCH_AUDITSYSCALL if (AEABI && !OABI_COMPAT)
> > > +	select HAVE_ARCH_BITREVERSE if (CPU_V7M || CPU_V7)
> > 
> > Looking at this, this is just wrong.  Take a moment to consider what
> > happens if we build a kernel which supports both ARMv6 _and_ ARMv7 CPUs.
> > What happens if an ARMv6 CPU tries to execute an rbit instruction?
> 
> Is it possible to build a kernel that support both CPU_V6 and CPU_V7?

Absolutely it is.

> I mean in Kconfig, CPU_V6 = y and CPU_V7 = y ?

Yes.

> If there is problem like you said,
> How about this solution:
> select HAVE_ARCH_BITREVERSE if ((CPU_V7M || CPU_V7) && !CPU_V6)  

That would work.

> For this patch,
> I just cherry-pick from Joe,
> If you are not responsible for this part,
> I will submit to the maintainers for these patches .
> Sorry for that .

I think you need to discuss with Joe how Joe would like his patches
handled.  However, it seems that Joe already sent his patches to the
appropriate maintainers, and they have been applying those patches
themselves.

Since your generic ARM changes depend on these patches being accepted
first, this means is that I can't apply the generic ARM changes until
those other patches have hit mainline, otherwise things are going to
break.  So, when you come to submit the latest set of patches to the
patch system, please do so only after these dependent patches have
been merged into mainline so that they don't get accidentally applied
before hand and break the two drivers that Joe mentioned.

Thanks.

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
