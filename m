Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0E41B6B3F6E
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 07:13:40 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id z16so2071400wrt.5
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 04:13:40 -0800 (PST)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40061.outbound.protection.outlook.com. [40.107.4.61])
        by mx.google.com with ESMTPS id i12si506026wmd.147.2018.11.26.04.13.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 26 Nov 2018 04:13:38 -0800 (PST)
From: Steve Capper <Steve.Capper@arm.com>
Subject: Re: [PATCH V3 4/5] arm64: mm: introduce 52-bit userspace support
Date: Mon, 26 Nov 2018 12:13:36 +0000
Message-ID: <20181126121322.GC2012@capper-debian.cambridge.arm.com>
References: <20181114133920.7134-1-steve.capper@arm.com>
 <20181114133920.7134-5-steve.capper@arm.com>
 <20181123183516.GM3360@arrakis.emea.arm.com>
In-Reply-To: <20181123183516.GM3360@arrakis.emea.arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <566264196DD5F644B8B562E23340F75B@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <Catalin.Marinas@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Will Deacon <Will.Deacon@arm.com>, "jcm@redhat.com" <jcm@redhat.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, nd <nd@arm.com>

On Fri, Nov 23, 2018 at 06:35:16PM +0000, Catalin Marinas wrote:
> On Wed, Nov 14, 2018 at 01:39:19PM +0000, Steve Capper wrote:
> > diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/=
pgalloc.h
> > index 2e05bcd944c8..56c3ccabeffe 100644
> > --- a/arch/arm64/include/asm/pgalloc.h
> > +++ b/arch/arm64/include/asm/pgalloc.h
> > @@ -27,7 +27,11 @@
> >  #define check_pgt_cache()		do { } while (0)
> > =20
> >  #define PGALLOC_GFP	(GFP_KERNEL | __GFP_ZERO)
> > +#ifdef CONFIG_ARM64_52BIT_VA
> > +#define PGD_SIZE	((1 << (52 - PGDIR_SHIFT)) * sizeof(pgd_t))
> > +#else
> >  #define PGD_SIZE	(PTRS_PER_PGD * sizeof(pgd_t))
> > +#endif
>=20
> This introduces a mismatch between PTRS_PER_PGD and PGD_SIZE. While it
> happens not to corrupt any memory (we allocate a full page for pgdirs),
> the compiler complains about the memset() in map_entry_trampoline()
> since tramp_pg_dir[] is smaller.

Thanks Catalin,
I think the way forward may be to remove the sizes from the
declarations for tramp_pg_dir and friends as they are specified to be
PAGE_SIZE by the linker script anyway.

I think this should be in a separate patch preceeding this one, will get
something ready.

(I'll also upgrade my build system :-) )

Cheers,
--=20
Steve
