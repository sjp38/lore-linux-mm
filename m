Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 021BA8E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 11:04:09 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id d6so588061wrm.19
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 08:04:08 -0800 (PST)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30040.outbound.protection.outlook.com. [40.107.3.40])
        by mx.google.com with ESMTPS id q16si8475053wme.90.2018.12.10.08.04.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:04:05 -0800 (PST)
From: Steve Capper <Steve.Capper@arm.com>
Subject: Re: [PATCH V5 5/7] arm64: mm: Prevent mismatched 52-bit VA support
Date: Mon, 10 Dec 2018 16:04:02 +0000
Message-ID: <20181210160348.GA4564@capper-debian.cambridge.arm.com>
References: <20181206225042.11548-1-steve.capper@arm.com>
 <20181206225042.11548-6-steve.capper@arm.com>
 <81860712-ff5f-5a51-d39e-9db9e3d31a26@arm.com>
 <20181207152529.GB2682@edgewater-inn.cambridge.arm.com>
 <be06b735-c6b4-1520-73f6-02a3a8e8af45@arm.com>
 <20181210133640.GA31425@edgewater-inn.cambridge.arm.com>
In-Reply-To: <20181210133640.GA31425@edgewater-inn.cambridge.arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <EE725A03E1E0E944ADBAC7DEA0591271@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <Will.Deacon@arm.com>
Cc: Suzuki Poulose <Suzuki.Poulose@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "jcm@redhat.com" <jcm@redhat.com>, nd <nd@arm.com>

On Mon, Dec 10, 2018 at 01:36:40PM +0000, Will Deacon wrote:
> On Fri, Dec 07, 2018 at 05:28:58PM +0000, Suzuki K Poulose wrote:
> >=20
> >=20
> > On 07/12/2018 15:26, Will Deacon wrote:
> > > On Fri, Dec 07, 2018 at 10:47:57AM +0000, Suzuki K Poulose wrote:
> > > > On 12/06/2018 10:50 PM, Steve Capper wrote:
> > > > > diff --git a/arch/arm64/kernel/head.S b/arch/arm64/kernel/head.S
> > > > > index f60081be9a1b..58fcc1edd852 100644
> > > > > --- a/arch/arm64/kernel/head.S
> > > > > +++ b/arch/arm64/kernel/head.S
> > > > > @@ -707,6 +707,7 @@ secondary_startup:
> > > > >    	/*
> > > > >    	 * Common entry point for secondary CPUs.
> > > > >    	 */
> > > > > +	bl	__cpu_secondary_check52bitva
> > > > >    	bl	__cpu_setup			// initialise processor
> > > > >    	adrp	x1, swapper_pg_dir
> > > > >    	bl	__enable_mmu
> > > > > @@ -785,6 +786,31 @@ ENTRY(__enable_mmu)
> > > > >    	ret
> > > > >    ENDPROC(__enable_mmu)
> > > > > +ENTRY(__cpu_secondary_check52bitva)
> > > > > +#ifdef CONFIG_ARM64_52BIT_VA
> > > > > +	ldr_l	x0, vabits_user
> > > > > +	cmp	x0, #52
> > > > > +	b.ne	2f > +
> > > > > +	mrs_s	x0, SYS_ID_AA64MMFR2_EL1
> > > > > +	and	x0, x0, #(0xf << ID_AA64MMFR2_LVA_SHIFT)
> > > > > +	cbnz	x0, 2f
> > > > > +
> > > > > +	adr_l	x0, va52mismatch
> > > > > +	mov	w1, #1
> > > > > +	strb	w1, [x0]
> > > > > +	dmb	sy
> > > > > +	dc	ivac, x0	// Invalidate potentially stale cache line
> > > >=20
> > > > You may have to clear this variable before a CPU is brought up to a=
void
> > > > raising a false error message when another secondary CPU doesn't bo=
ot
> > > > for some other reason (say granule support) after a CPU failed with=
 lack
> > > > of 52bitva. It is really a crazy corner case.
> > >=20
> > > Can't we just follow the example set by the EL2 setup in the way that=
 is
> > > uses __boot_cpu_mode? In that case, we only need one variable and you=
 can
> > > detect a problem by comparing the two halves.
> >=20
> > The only difference here is, the support is bolted at boot CPU time and=
 hence
> > we need to verify each and every CPU, unlike the __boot_cpu_mode where =
we
> > check for mismatch after the SMP CPUs are brought up. If we decide to m=
ake
> > the choice later, something like that could work. The only caveat is th=
e 52bit
> > kernel VA will have to do something like the above.
>=20
> So looking at this a bit more, I think we're better off repurposing the
> upper bits of the early boot status word to contain a reason code, rather
> than introducing new variables for every possible mismatch.
>=20
> Does the untested diff below look remotely sane to you?
>=20
> Will
>=20

Thanks Will,
This looks good to me, I will test now and fold this into a patch.

Cheers,
--=20
Steve
