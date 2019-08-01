Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EB01C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:44:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8BE92087E
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:44:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8BE92087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D42A8E002C; Thu,  1 Aug 2019 11:44:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5853A8E0001; Thu,  1 Aug 2019 11:44:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 474F58E002C; Thu,  1 Aug 2019 11:44:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EFD688E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 11:44:51 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f3so45135198edx.10
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 08:44:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version;
        bh=b40JMKpT5Z3tutjA7zuOzYM9A1Cnzw5E6joM5yEKgLI=;
        b=ZTLkx7NyyNB0gzcL9nGa72Hp0XV6KVrbqpwdlczB/qhyGVaO2a/SPfAE1IPrKfXFDF
         Kz/6aVA7OZVg+1PPca12YjpJ+wtCgTbD9YGBjICbeis3r/inSP6yfT5KSmQWh83oQhoQ
         KOaRPY+AJ24BRk7e4dBHF4WQ+Uuy58RfTuCJTRU2GSr3zCPeiKjVen3hx1mFLG9KlkL3
         jXVBy6fkui+oX/Rkdt31luKP4AvxK3DNEC3kemkBwSD4GBI+9iR49P3efIXfv+FpYo7+
         uwQjCZqCOW8FJXuGq+EhHufVyJjauHsXUUttmeoeD2vSlfSouF2EAtPuRBauMtW6TC/b
         n58w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Gm-Message-State: APjAAAW4tSZAnOs66hWz55HBQxfjzHhQ97RlYPh1vT05Fw1GvWhTIMch
	wzCMMcbIZqUnfiE5qdN9stf28ndaqM4L9y80034Nmn3yU5a73Vs8d2Ouy8x099idCSRGbDCF6UD
	E0E6xN2e1dlgYfzMirwadu/TZpdvlwVJgTuX+2znam+gv32dBDdMXw4eL92j1fF1fiQ==
X-Received: by 2002:a50:89a2:: with SMTP id g31mr114915460edg.93.1564674291521;
        Thu, 01 Aug 2019 08:44:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDqQV9zsbyHkIK2XIoC3H0v2FyEeYA5B/GzjdO/tkSYZzB+cMME5nLRJ/o+iFWRCS54MdD
X-Received: by 2002:a50:89a2:: with SMTP id g31mr114915399edg.93.1564674290810;
        Thu, 01 Aug 2019 08:44:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564674290; cv=none;
        d=google.com; s=arc-20160816;
        b=ulFA3BDW41gofFk/bK2SWh2xPdaO23Pb09OuMeUu+d9HHbILlwPayZLQtVm4q17mW8
         qTwceefT7oenuGSo9tJuMdcAaQIDi75AvGwFBxSM8uc4i7kr4p/jE07vTtA7NwzDbAa3
         mqBeBDWFaVIET2Mpea/qRXHEBVGLBF0dOzTxWjrceim3WwEnmgaZuL9nBRvMk1bF+pLN
         hymT8a8ze6aAsExxr0n6WYeikgMsACs4c14p6D2G7Z2A+whA+VY7elVXWgeBgswj++m9
         BoSYKU6daT06jMJdvKiYHFyido4ItesipcU//UFWLjjFtI5mslCQ/VN2X80wjStA7qbF
         wgvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:in-reply-to:date:cc:to:from
         :subject:message-id;
        bh=b40JMKpT5Z3tutjA7zuOzYM9A1Cnzw5E6joM5yEKgLI=;
        b=x/1TDuHzg3hUBT8eKK98xn8P1/DHNdyJhOzm4DsHFUslacO2Xdy5vT4CVgLTegM+Be
         QZyZ/stikTWFOAeNoxmxB7AoCud/3LWKgd6pIOKcIGdYcn+b7qWMRse3/sTnkrXnX6pD
         cHmDPLC6ujD5/IXmTRlzkanBmRKsS/+H9XBNQocNBowI0kcApaVuACu6iSf+sln0+Fy3
         yIoNw1BRND4o6cF7m4ADmLEOxzQ0BY8PD00TelbHU5pWoMydyBJZOSwiEFF7ePUZ+QVO
         rAsUJKl6qhEpCtHp9yamr2p7ZyzNG4tH4f1Za2nWNgW6nBDVuo2TVS1x0oJD45kgMX7T
         37OA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w23si23934963edw.447.2019.08.01.08.44.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 08:44:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 222CDAC9A;
	Thu,  1 Aug 2019 15:44:50 +0000 (UTC)
Message-ID: <d8b4a7cb9c06824ca88a0602a5bf38b6324b43c0.camel@suse.de>
Subject: Re: [PATCH 5/8] arm64: use ZONE_DMA on DMA addressing limited
 devices
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: phill@raspberryi.org, devicetree@vger.kernel.org, 
 linux-rpi-kernel@lists.infradead.org, f.fainelli@gmail.com, 
 frowand.list@gmail.com, eric@anholt.net, marc.zyngier@arm.com, Will Deacon
 <will@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
 iommu@lists.linux-foundation.org, robh+dt@kernel.org, wahrenst@gmx.net, 
 mbrugger@suse.com, akpm@linux-foundation.org, Robin Murphy
 <robin.murphy@arm.com>,  hch@lst.de, linux-arm-kernel@lists.infradead.org,
 m.szyprowski@samsung.com
Date: Thu, 01 Aug 2019 17:44:09 +0200
In-Reply-To: <20190731170742.GC17773@arrakis.emea.arm.com>
References: <20190731154752.16557-1-nsaenzjulienne@suse.de>
	 <20190731154752.16557-6-nsaenzjulienne@suse.de>
	 <20190731170742.GC17773@arrakis.emea.arm.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-Jl/nDcfVAied7u8Yssfo"
User-Agent: Evolution 3.32.4 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-Jl/nDcfVAied7u8Yssfo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2019-07-31 at 18:07 +0100, Catalin Marinas wrote:
> On Wed, Jul 31, 2019 at 05:47:48PM +0200, Nicolas Saenz Julienne wrote:
> > diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> > index 1c4ffabbe1cb..f5279ef85756 100644
> > --- a/arch/arm64/mm/init.c
> > +++ b/arch/arm64/mm/init.c
> > @@ -50,6 +50,13 @@
> >  s64 memstart_addr __ro_after_init =3D -1;
> >  EXPORT_SYMBOL(memstart_addr);
> > =20
> > +/*
> > + * We might create both a ZONE_DMA and ZONE_DMA32. ZONE_DMA is needed =
if
> > there
> > + * are periferals unable to address the first naturally aligned 4GB of=
 ram.
> > + * ZONE_DMA32 will be expanded to cover the rest of that memory. If su=
ch
> > + * limitations doesn't exist only ZONE_DMA32 is created.
> > + */
>=20
> Shouldn't we instead only create ZONE_DMA to cover the whole 32-bit
> range and leave ZONE_DMA32 empty? Can__GFP_DMA allocations fall back
> onto ZONE_DMA32?

Hi Catalin, thanks for the review.

You're right, the GFP_DMA page allocation will fail with a nasty dmesg erro=
r if
ZONE_DMA is configured but empty. Unsurprisingly the opposite situation is =
fine
(GFP_DMA32 with an empty ZONE_DMA32).

I switched to the scheme you're suggesting for the next version of the seri=
es.
The comment will be something the likes of this:

/*
 * We create both a ZONE_DMA and ZONE_DMA32. ZONE_DMA's size is decided bas=
ed
 * on whether the SoC's peripherals are able to address the first naturally
 * aligned 4 GB of ram.
 *
 * If limited, ZONE_DMA covers that area and ZONE_DMA32 the rest of that 32=
 bit
 * addressable memory.
 *
 * If not ZONE_DMA is expanded to cover the whole 32 bit addressable memory=
 and
 * ZONE_DMA32 is left empty.
 */

 Regards,
 Nicolas



--=-Jl/nDcfVAied7u8Yssfo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEErOkkGDHCg2EbPcGjlfZmHno8x/4FAl1DCMkACgkQlfZmHno8
x/724wgAlBvY4KUvCY6AbQ4IkNYytX+x49CEh/vxpdWWXLjrWRTBCg2SwWhZ4y9G
OjuuZe9BBgQBgnZBR0lC8MlCFN7w4Ce5aByypx2pzGLefZKqc4pesvda/gC8Jmo8
csbQ988GLPt6V35DcX3N81FjYrdsZGCcJ1XrtpUVlx6YfIPLx4ZRc/6OfV3yXXBc
XiD/luxNVqjDtvy7RnR2so9hSWet0hM4Wv5TDwI+xt1RviR4Tpdd+jNqtjxH+LcV
2uruy3yUhTGeNaiyZsPt/Bj1Mlg+Wab940ahUDn3a1KBkd4BkFZIoqfjQxBgLaal
iZB+n9PmIhCkaHygfxOy1H+xVYO/AA==
=Opde
-----END PGP SIGNATURE-----

--=-Jl/nDcfVAied7u8Yssfo--

