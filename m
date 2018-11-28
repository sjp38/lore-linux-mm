Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 122366B4DDF
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 11:31:29 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id g184so3326290wmd.4
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 08:31:29 -0800 (PST)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40075.outbound.protection.outlook.com. [40.107.4.75])
        by mx.google.com with ESMTPS id x191si2408397wmf.177.2018.11.28.08.31.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 28 Nov 2018 08:31:27 -0800 (PST)
From: Steve Capper <Steve.Capper@arm.com>
Subject: Re: [PATCH V3 2/5] arm64: mm: Introduce DEFAULT_MAP_WINDOW
Date: Wed, 28 Nov 2018 16:31:25 +0000
Message-ID: <20181128163115.GA20432@capper-debian.cambridge.arm.com>
References: <20181114133920.7134-1-steve.capper@arm.com>
 <20181114133920.7134-3-steve.capper@arm.com>
 <20181127170931.GC3563@arrakis.emea.arm.com>
In-Reply-To: <20181127170931.GC3563@arrakis.emea.arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <F6D6659C083C7E46B364FF997973DAE6@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <Catalin.Marinas@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Will Deacon <Will.Deacon@arm.com>, "jcm@redhat.com" <jcm@redhat.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, nd <nd@arm.com>

On Tue, Nov 27, 2018 at 05:09:32PM +0000, Catalin Marinas wrote:
> Hi Steve,

Hi Catalin,

>=20
> On Wed, Nov 14, 2018 at 01:39:17PM +0000, Steve Capper wrote:
> > diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/as=
m/processor.h
> > index 3e2091708b8e..da41a2655b69 100644
> > --- a/arch/arm64/include/asm/processor.h
> > +++ b/arch/arm64/include/asm/processor.h
> > @@ -25,6 +25,9 @@
> >  #define USER_DS		(TASK_SIZE_64 - 1)
> > =20
> >  #ifndef __ASSEMBLY__
> > +
> > +#define DEFAULT_MAP_WINDOW_64	(UL(1) << VA_BITS)
> > +
> >  #ifdef __KERNEL__
>=20
> That's a strange place to place DEFAULT_MAP_WINDOW_64. Did you have any
> #include dependency issues? If yes, we could look at cleaning them up,
> maybe moving these definitions into a separate file.
>=20
> (also, if you do a clean-up I don't think we need __KERNEL__ anymore)
>=20

Okay, I will investigate cleaning this up.

> > =20
> >  #include <linux/build_bug.h>
> > @@ -51,13 +54,16 @@
> >  				TASK_SIZE_32 : TASK_SIZE_64)
> >  #define TASK_SIZE_OF(tsk)	(test_tsk_thread_flag(tsk, TIF_32BIT) ? \
> >  				TASK_SIZE_32 : TASK_SIZE_64)
> > +#define DEFAULT_MAP_WINDOW	(test_thread_flag(TIF_32BIT) ? \
> > +				TASK_SIZE_32 : DEFAULT_MAP_WINDOW_64)
> >  #else
> >  #define TASK_SIZE		TASK_SIZE_64
> > +#define DEFAULT_MAP_WINDOW	DEFAULT_MAP_WINDOW_64
> >  #endif /* CONFIG_COMPAT */
> > =20
> > -#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(TASK_SIZE / 4))
> > +#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(DEFAULT_MAP_WINDOW / 4))
> > +#define STACK_TOP_MAX		DEFAULT_MAP_WINDOW_64
> > =20
> > -#define STACK_TOP_MAX		TASK_SIZE_64
> >  #ifdef CONFIG_COMPAT
> >  #define AARCH32_VECTORS_BASE	0xffff0000
> >  #define STACK_TOP		(test_thread_flag(TIF_32BIT) ? \
> > diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> > index 9d9582cac6c4..e5a1dc0beef9 100644
> > --- a/arch/arm64/mm/init.c
> > +++ b/arch/arm64/mm/init.c
> > @@ -609,7 +609,7 @@ void __init mem_init(void)
> >  	 * detected at build time already.
> >  	 */
> >  #ifdef CONFIG_COMPAT
> > -	BUILD_BUG_ON(TASK_SIZE_32			> TASK_SIZE_64);
> > +	BUILD_BUG_ON(TASK_SIZE_32			> DEFAULT_MAP_WINDOW_64);
> >  #endif
>=20
> Since you are at this, can you please remove the useless white space (I
> guess it was there before when we had more BUILD_BUG_ONs).
>=20

Sure thing.

> > diff --git a/drivers/firmware/efi/libstub/arm-stub.c b/drivers/firmware=
/efi/libstub/arm-stub.c
> > index 30ac0c975f8a..d1ec7136e3e1 100644
> > --- a/drivers/firmware/efi/libstub/arm-stub.c
> > +++ b/drivers/firmware/efi/libstub/arm-stub.c
> > @@ -33,7 +33,7 @@
> >  #define EFI_RT_VIRTUAL_SIZE	SZ_512M
> > =20
> >  #ifdef CONFIG_ARM64
> > -# define EFI_RT_VIRTUAL_LIMIT	TASK_SIZE_64
> > +# define EFI_RT_VIRTUAL_LIMIT	DEFAULT_MAP_WINDOW_64
> >  #else
> >  # define EFI_RT_VIRTUAL_LIMIT	TASK_SIZE
> >  #endif
>=20
> Just curious, would anything happen if we leave this to TASK_SIZE_64?
>=20

Then it doesn't compile :-). TASK_SIZE_64 is a variable that is outside
the EFI stub's knowledge (and indeed is initialised after the stub has
already executed).

Cheers,
--=20
Steve
