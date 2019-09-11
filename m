Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC8CFC49ED6
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 10:54:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D91F20CC7
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 10:54:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D91F20CC7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F23C86B0005; Wed, 11 Sep 2019 06:54:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EACEA6B0006; Wed, 11 Sep 2019 06:54:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9B646B0007; Wed, 11 Sep 2019 06:54:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0147.hostedemail.com [216.40.44.147])
	by kanga.kvack.org (Postfix) with ESMTP id B2DED6B0005
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 06:54:44 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 5A594180AD802
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 10:54:44 +0000 (UTC)
X-FDA: 75922331688.15.juice22_2950ef3efcc13
X-HE-Tag: juice22_2950ef3efcc13
X-Filterd-Recvd-Size: 3434
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 10:54:43 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 625F7AFBA;
	Wed, 11 Sep 2019 10:54:41 +0000 (UTC)
Message-ID: <b0b824bebb9ef13ce746f9914de83126b0386e23.camel@suse.de>
Subject: Re: [PATCH v5 3/4] arm64: use both ZONE_DMA and ZONE_DMA32
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: catalin.marinas@arm.com, hch@lst.de, wahrenst@gmx.net,
 marc.zyngier@arm.com,  robh+dt@kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
 linux-riscv@lists.infradead.org, Will Deacon <will@kernel.org>
Cc: f.fainelli@gmail.com, robin.murphy@arm.com,
 linux-kernel@vger.kernel.org,  mbrugger@suse.com,
 linux-rpi-kernel@lists.infradead.org, phill@raspberrypi.org, 
 m.szyprowski@samsung.com
Date: Wed, 11 Sep 2019 12:54:38 +0200
In-Reply-To: <20190909095807.18709-4-nsaenzjulienne@suse.de>
References: <20190909095807.18709-1-nsaenzjulienne@suse.de>
	 <20190909095807.18709-4-nsaenzjulienne@suse.de>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-+mwqdWbEE6wWAYsMfkXS"
User-Agent: Evolution 3.32.4 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-+mwqdWbEE6wWAYsMfkXS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2019-09-09 at 11:58 +0200, Nicolas Saenz Julienne wrote:
> +
>  /*
> - * Return the maximum physical address for ZONE_DMA32 (DMA_BIT_MASK(32))=
. It
> - * currently assumes that for memory starting above 4G, 32-bit devices w=
ill
> - * use a DMA offset.
> + * Return the maximum physical address for a zone with a given address s=
ize
> + * limit. It currently assumes that for memory starting above 4G, 32-bit
> + * devices will use a DMA offset.
>   */
> -static phys_addr_t __init max_zone_dma32_phys(void)
> +static phys_addr_t __init max_zone_phys(unsigned int zone_bits)
>  {
>         phys_addr_t offset =3D memblock_start_of_DRAM() & GENMASK_ULL(63,=
 32);
> -       return min(offset + (1ULL << 32), memblock_end_of_DRAM());
> +       return min(offset + (1ULL << zone_bits), memblock_end_of_DRAM());
>  }

Hi all,
while testing other code on top of this series on odd arm64 machines I foun=
d an
issue: when memblock_start_of_DRAM() !=3D 0, max_zone_phys() isn't taking i=
nto
account the offset to the beginning of memory. This doesn't matter with
zone_bits =3D=3D 32 but it does when zone_bits =3D=3D 30.

I'll send a follow-up series.

Regards,
Nicolas


--=-+mwqdWbEE6wWAYsMfkXS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEErOkkGDHCg2EbPcGjlfZmHno8x/4FAl140m4ACgkQlfZmHno8
x/7BUAf8DFgSHDr3lRvqtp8RR9IRwdyy2AUPrJxMxccznKYgaiaJpx9nyG2J8h2M
2RuPADsFlI9fX0698LVNDxwUhICkAYh5gxOw/S+KHQvpw6KDqOn5HNvAESc64TTQ
T+KDM+LR+j6W0fRNPUDWJvLJCYf0dXc2PmysKhJF+Gck5LmHPl+aNUmJjpVqa/HJ
cMUJAObpwDpLRySRBi5DtN+ZAv/SVwD1WhJkn/0FjWmBRBpwt9T0YVdPGbyJd877
kLjB51r2JQSn/+Za+2TjIx4E1Qf9APCKCYzp1Jd0ofb53DO5jFtMPZ7GQljKwVf1
d05+0WOR5OrHixfZhqXV1huP39T8Uw==
=iRPY
-----END PGP SIGNATURE-----

--=-+mwqdWbEE6wWAYsMfkXS--


