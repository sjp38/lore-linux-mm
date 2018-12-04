Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 22AED6B6FE7
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 12:41:11 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id v7so6825791wme.9
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 09:41:11 -0800 (PST)
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80083.outbound.protection.outlook.com. [40.107.8.83])
        by mx.google.com with ESMTPS id b14si13156328wrn.438.2018.12.04.09.41.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 04 Dec 2018 09:41:09 -0800 (PST)
From: Steve Capper <Steve.Capper@arm.com>
Subject: Re: [PATCH V3 4/5] arm64: mm: introduce 52-bit userspace support
Date: Tue, 4 Dec 2018 17:41:07 +0000
Message-ID: <20181204174057.GA10602@capper-debian.cambridge.arm.com>
References: <20181114133920.7134-1-steve.capper@arm.com>
 <20181114133920.7134-5-steve.capper@arm.com>
 <20181130175956.GJ43329@arrakis.emea.arm.com>
In-Reply-To: <20181130175956.GJ43329@arrakis.emea.arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <D9E07313ADA61E488D3D4DCAB80FB5F3@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <Catalin.Marinas@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Will Deacon <Will.Deacon@arm.com>, "jcm@redhat.com" <jcm@redhat.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, nd <nd@arm.com>

On Fri, Nov 30, 2018 at 05:59:59PM +0000, Catalin Marinas wrote:
> On Wed, Nov 14, 2018 at 01:39:19PM +0000, Steve Capper wrote:
> > diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/=
pgtable.h
> > index 50b1ef8584c0..19736520b724 100644
> > --- a/arch/arm64/include/asm/pgtable.h
> > +++ b/arch/arm64/include/asm/pgtable.h
> > @@ -616,11 +616,21 @@ static inline phys_addr_t pgd_page_paddr(pgd_t pg=
d)
> >  #define pgd_ERROR(pgd)		__pgd_error(__FILE__, __LINE__, pgd_val(pgd))
> > =20
> >  /* to find an entry in a page-table-directory */
> > -#define pgd_index(addr)		(((addr) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1)=
)
> > +#define pgd_index(addr, ptrs)		(((addr) >> PGDIR_SHIFT) & ((ptrs) - 1)=
)
> > +#define _pgd_offset_raw(pgd, addr, ptrs) ((pgd) + pgd_index(addr, ptrs=
))
> > +#define pgd_offset_raw(pgd, addr)	(_pgd_offset_raw(pgd, addr, PTRS_PER=
_PGD))
> > =20
> > -#define pgd_offset_raw(pgd, addr)	((pgd) + pgd_index(addr))
> > +static inline pgd_t *pgd_offset(const struct mm_struct *mm, unsigned l=
ong addr)
> > +{
> > +	pgd_t *ret;
> > +
> > +	if (IS_ENABLED(CONFIG_ARM64_52BIT_VA) && (mm !=3D &init_mm))
> > +		ret =3D _pgd_offset_raw(mm->pgd, addr, 1ULL << (vabits_user - PGDIR_=
SHIFT));
>=20
> I think we can make this a constant since the additional 4 bits of the
> user address should be 0 on a 48-bit VA. Once we get the 52-bit kernel
> VA supported, we can probably revert back to a single macro.

Yeah, I see what you mean.

>=20
> Another option is to change  PTRS_PER_PGD etc. to cover the whole
> 52-bit, including the swapper_pg_dir, but with offsetting the TTBR1_EL1
> setting to keep the 48-bit kernel VA (for the time being).
>=20

I've got a 52-bit PTRS_PER_PGD working now. I will clean things up, run
more tests and then post.

Cheers,
--=20
Steve
