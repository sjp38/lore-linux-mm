Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id BA83F6B7A29
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 07:27:52 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id y86so704192ita.2
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 04:27:52 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50086.outbound.protection.outlook.com. [40.107.5.86])
        by mx.google.com with ESMTPS id u188si103772ioe.29.2018.12.06.04.27.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 04:27:51 -0800 (PST)
From: Steve Capper <Steve.Capper@arm.com>
Subject: Re: [PATCH V4 4/6] arm64: mm: Offset TTBR1 to allow 52-bit
 PTRS_PER_PGD
Date: Thu, 6 Dec 2018 12:27:49 +0000
Message-ID: <20181206122733.GA17572@capper-debian.cambridge.arm.com>
References: <20181205164145.24568-1-steve.capper@arm.com>
 <20181205164145.24568-5-steve.capper@arm.com>
 <20181206115011.GC54495@arrakis.emea.arm.com>
In-Reply-To: <20181206115011.GC54495@arrakis.emea.arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <4025061A11372347AB0A498748503E9C@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <Catalin.Marinas@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Will Deacon <Will.Deacon@arm.com>, "jcm@redhat.com" <jcm@redhat.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, nd <nd@arm.com>

On Thu, Dec 06, 2018 at 11:50:12AM +0000, Catalin Marinas wrote:
> On Wed, Dec 05, 2018 at 04:41:43PM +0000, Steve Capper wrote:
> > diff --git a/arch/arm64/include/asm/asm-uaccess.h b/arch/arm64/include/=
asm/asm-uaccess.h
> > index 4128bec033f6..cd361dd16b12 100644
> > --- a/arch/arm64/include/asm/asm-uaccess.h
> > +++ b/arch/arm64/include/asm/asm-uaccess.h
> > @@ -14,11 +14,13 @@
> >  #ifdef CONFIG_ARM64_SW_TTBR0_PAN
> >  	.macro	__uaccess_ttbr0_disable, tmp1
> >  	mrs	\tmp1, ttbr1_el1			// swapper_pg_dir
> > +	restore_ttbr1 \tmp1
> >  	bic	\tmp1, \tmp1, #TTBR_ASID_MASK
> >  	sub	\tmp1, \tmp1, #RESERVED_TTBR0_SIZE	// reserved_ttbr0 just before =
swapper_pg_dir
> >  	msr	ttbr0_el1, \tmp1			// set reserved TTBR0_EL1
> >  	isb
> >  	add	\tmp1, \tmp1, #RESERVED_TTBR0_SIZE
> > +	offset_ttbr1 \tmp1
> >  	msr	ttbr1_el1, \tmp1		// set reserved ASID
> >  	isb
> >  	.endm
> > @@ -27,8 +29,10 @@
> >  	get_thread_info \tmp1
> >  	ldr	\tmp1, [\tmp1, #TSK_TI_TTBR0]	// load saved TTBR0_EL1
> >  	mrs	\tmp2, ttbr1_el1
> > +	restore_ttbr1 \tmp2
> >  	extr    \tmp2, \tmp2, \tmp1, #48
> >  	ror     \tmp2, \tmp2, #16
> > +	offset_ttbr1 \tmp2
> >  	msr	ttbr1_el1, \tmp2		// set the active ASID
> >  	isb
> >  	msr	ttbr0_el1, \tmp1		// set the non-PAN TTBR0_EL1
>=20
> The patch looks alright but I think we can simplify it further if we add:
>=20
> 	depends on ARM64_PAN || !ARM64_SW_TTBR0_PAN
>=20
> to the 52-bit Kconfig entry.

Ahh, thank you okay, I didn't make the connection that Privileged access
never was a mandatory feature in ARMv8.1.

Cheers,
--=20
Steve
