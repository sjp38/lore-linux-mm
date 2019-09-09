Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0E63C433EF
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 08:46:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FAF921D7B
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 08:46:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FAF921D7B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15ECC6B0005; Mon,  9 Sep 2019 04:46:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10FCE6B0007; Mon,  9 Sep 2019 04:46:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3F886B0008; Mon,  9 Sep 2019 04:46:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0091.hostedemail.com [216.40.44.91])
	by kanga.kvack.org (Postfix) with ESMTP id CCCCF6B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 04:46:44 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 78C55612D
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 08:46:44 +0000 (UTC)
X-FDA: 75914751528.21.fly14_7501e3028c734
X-HE-Tag: fly14_7501e3028c734
X-Filterd-Recvd-Size: 3905
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 08:46:43 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 549CAAC37;
	Mon,  9 Sep 2019 08:46:42 +0000 (UTC)
Message-ID: <7fc8f4d9a992ef9e92e0d188d32c8763a11d39e3.camel@suse.de>
Subject: Re: [PATCH v4 3/4] arm64: use both ZONE_DMA and ZONE_DMA32
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: f.fainelli@gmail.com, mbrugger@suse.com, marc.zyngier@arm.com, 
	robin.murphy@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	robh+dt@kernel.org, wahrenst@gmx.net, m.szyprowski@samsung.com, 
	linux-riscv@lists.infradead.org, phill@raspberrypi.org, Will Deacon
	 <will@kernel.org>, hch@lst.de, linux-arm-kernel@lists.infradead.org, 
	linux-rpi-kernel@lists.infradead.org
Date: Mon, 09 Sep 2019 10:46:39 +0200
In-Reply-To: <20190908212711.GA84759@huawei_p9_lite.cambridge.arm.com>
References: <20190906120617.18836-1-nsaenzjulienne@suse.de>
	 <20190906120617.18836-4-nsaenzjulienne@suse.de>
	 <20190908212711.GA84759@huawei_p9_lite.cambridge.arm.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-1LCc1QPqK5YGKmT2hHJ7"
User-Agent: Evolution 3.32.4 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-1LCc1QPqK5YGKmT2hHJ7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2019-09-08 at 22:27 +0100, Catalin Marinas wrote:
> On Fri, Sep 06, 2019 at 02:06:14PM +0200, Nicolas Saenz Julienne wrote:
> > @@ -430,7 +454,7 @@ void __init arm64_memblock_init(void)
> > =20
> >  	high_memory =3D __va(memblock_end_of_DRAM() - 1) + 1;
> > =20
> > -	dma_contiguous_reserve(arm64_dma32_phys_limit);
> > +	dma_contiguous_reserve(arm64_dma_phys_limit ? : arm64_dma32_phys_limi=
t);
> >  }
> > =20
> >  void __init bootmem_init(void)
> > @@ -534,6 +558,7 @@ static void __init free_unused_memmap(void)
> >  void __init mem_init(void)
> >  {
> >  	if (swiotlb_force =3D=3D SWIOTLB_FORCE ||
> > +	    max_pfn > (arm64_dma_phys_limit >> PAGE_SHIFT) ||
> >  	    max_pfn > (arm64_dma32_phys_limit >> PAGE_SHIFT))
> >  		swiotlb_init(1);
>=20
> So here we want to initialise the swiotlb only if we need bounce
> buffers. Prior to this patch, we assumed that swiotlb is needed if
> max_pfn is beyond the reach of 32-bit devices. With ZONE_DMA, we need to
> lower this limit to arm64_dma_phys_limit.
>
> If ZONE_DMA is enabled, just comparing max_pfn with arm64_dma_phys_limit
> is sufficient since the dma32 one limit always higher. However, if
> ZONE_DMA is disabled, arm64_dma_phys_limit is 0, so we may initialise
> swiotlb unnecessarily. I guess you need a similar check to the
> dma_contiguous_reserve() above.

Of course.

>=20
> With that:
>=20
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
>=20
> Unless there are other objections, I can queue this series for 5.5 in a
> few weeks time (too late for 5.4).

Thanks!


--=-1LCc1QPqK5YGKmT2hHJ7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEErOkkGDHCg2EbPcGjlfZmHno8x/4FAl12EW8ACgkQlfZmHno8
x/6gGAf+LvKqKpyRZyqYfBtVHx+Mh2KJ7diP9UrN83ZhxXEFsw7VTMSKhZkJ4Gwb
JukrC1rd+n1kNI5WHOQGKm3PgrtSn1zuBnf1/cWHvzy9kpD2n9UebAzNpkwg7SBR
e8h3pfAr4rEZTRalQhGBZfqHjqV6hPPrbMduCeJicfm6R1qQxSC35WG/etDmPG8i
IdERWdQ4oqIHyzxGaq4BMsZLVL9gmtAs/Dd78a8y6EMWZt1DTMicGO01riV0TmOs
mK+UJa6GL6K43yWnCa31wxSCwuiOK0ta/iZWcvgSdQEhGejqWzpXLrYPeGsFGYrV
8bc6QLV1/FvuZWy/lmEW05gQVGejyA==
=lI20
-----END PGP SIGNATURE-----

--=-1LCc1QPqK5YGKmT2hHJ7--


