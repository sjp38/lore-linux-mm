Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DABBDC433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 16:03:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A91E7208C3
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 16:03:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A91E7208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 402566B0007; Mon,  5 Aug 2019 12:03:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B3B96B0008; Mon,  5 Aug 2019 12:03:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C96A6B000A; Mon,  5 Aug 2019 12:03:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D38176B0007
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 12:03:58 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r21so51917949edc.6
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 09:03:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version;
        bh=Iopyt5Tl3aBWw9RGiwF5k+OCxZcoGcIVox8xkQ/7ce4=;
        b=htTKlAee2YaJKOnn/LOoSiBeCnLDijKjXCfRYkfEOY5xVDykeQYh7acs72Crtahzd1
         j18N1BhnV/5aneEjYqRUp9LHmTiXzlpognfo99BiF9qIT0KrFxEbv/8rn3wJ7ZFFFk7P
         PVYsfiOHHG2kCJcOaRb18XLsMA0OZ2JqhMCFclbYVqpt79VDALQyr/H1x/2ucHsBAg/d
         dlI6ankRWGwd46hUXMOtLO0gMFfiqrTRLPCF/eGfx3FZRL4KsAX6ogaVCpGBV9TGM4Ts
         5j41AOSP56BzOeBgMcEN+x5gzdO57NC08hMq1L1D524VQQSyr3DyFasGkbApacziKAtB
         gqCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Gm-Message-State: APjAAAWwGz9TaTV4PvGN0iJc3WqW1E/60m6Z9KIdWEGlr2P2aLAIPkvm
	u/395mDZb2U1zVBD/hIObORLEuvKNbpzZ6S8jlMeDpQnCNhLvLz4bFJ4DmKZImU1HaYiQSY68Ko
	4ZYrV/DEs2G/VrK5iUI+pI9IU9Cl0g8TajP/UXxtAgzODM7HKVcvKEIHCO08lLNBNUg==
X-Received: by 2002:a17:906:19c6:: with SMTP id h6mr30578955ejd.262.1565021038423;
        Mon, 05 Aug 2019 09:03:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAZkvgFdpGUw5uhaJHUbsytpVsbJ2llo2qzs/4mnD5Mpg2d+ExbS5oLQZ+OwarZmgwaS/Z
X-Received: by 2002:a17:906:19c6:: with SMTP id h6mr30578867ejd.262.1565021037508;
        Mon, 05 Aug 2019 09:03:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565021037; cv=none;
        d=google.com; s=arc-20160816;
        b=u2gSfOT4k7BFHQkKsVBxbyvCvXz3PSSSh4LbA+kOM91j/G9H2nm9pps3pBsvcjLI/c
         0IaVRHZu2cmomhkWjYQOG1Oqr54YJ9TMq+4ZsvfHLFM5k3zKpRoNRHNh1WCLmJgHeiN5
         dJBVjrrAt5bmCIFUVXWm40EV8DpMBShaXOOpk9pZlin+66onKVaZbdB7cpcoaSODBuo5
         nUx/oIpZC0wWQzp9pAWvleoCUKL7KwI78nFM8Y9XhfE2XKJ5KfC7SPZ1BOvXwoDTE9nr
         aB0o3NBZAnYg9wGeXKLJT7DNunprwZ+FWrki2zA0vVZ36NcCb4MZR23EN+ZxP6e0LzzG
         OteQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:in-reply-to:date:cc:to:from
         :subject:message-id;
        bh=Iopyt5Tl3aBWw9RGiwF5k+OCxZcoGcIVox8xkQ/7ce4=;
        b=AvcvlKRnfn7V1mlRTHum2E2pVfQSvsxtSAM651aZHOl3qhsjYm6X2n0JiwhMzOOwcm
         8HCsP69szgmd/rcKj3cxLI/pWVb2CFwhyiu8QpSXK1gJ2ySkYkEqYrluvQOhHO2DHrnj
         6VPA9xTlD0f4HzKpTKm/Sk57t6aQAEddD8+chcqFv3iwptZXjwXJT6Hh44YOe3413v+d
         Ov0VNPairk2itYUzoYyDs7//bLDB+A69x8EqTZkaqY01ZD6mK3wcGW50Em12+RA+Q0GZ
         Get9aGIIy2t6PNLqK0Clt7ymf1yD7WeiSTBG1Vk5sk0sDErqDB7CbEqN80InuHrDJHFQ
         GXVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j7si29191462eds.315.2019.08.05.09.03.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 09:03:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C834AAEFB;
	Mon,  5 Aug 2019 16:03:56 +0000 (UTC)
Message-ID: <2050374ac07e0330e505c4a1637256428adb10c4.camel@suse.de>
Subject: Re: [PATCH 3/8] of/fdt: add function to get the SoC wide DMA
 addressable memory size
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: Rob Herring <robh+dt@kernel.org>, Catalin Marinas
 <catalin.marinas@arm.com>,  Will Deacon <will@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, wahrenst@gmx.net, Marc Zyngier
 <marc.zyngier@arm.com>, Robin Murphy <robin.murphy@arm.com>, "moderated
 list:ARM/FREESCALE IMX / MXC ARM ARCHITECTURE"
 <linux-arm-kernel@lists.infradead.org>, devicetree@vger.kernel.org, Linux
 IOMMU <iommu@lists.linux-foundation.org>, linux-mm@kvack.org, Frank Rowand
 <frowand.list@gmail.com>, phill@raspberryi.org, Florian Fainelli
 <f.fainelli@gmail.com>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, Eric Anholt <eric@anholt.net>, Matthias
 Brugger <mbrugger@suse.com>, Andrew Morton <akpm@linux-foundation.org>,
 Marek Szyprowski <m.szyprowski@samsung.com>, "moderated list:BROADCOM
 BCM2835 ARM ARCHITECTURE" <linux-rpi-kernel@lists.infradead.org>
Date: Mon, 05 Aug 2019 18:03:53 +0200
In-Reply-To: <CAL_JsqKF5nh3hcdLTG5+6RU3_TnFrNX08vD6qZ8wawoA3WSRpA@mail.gmail.com>
References: <20190731154752.16557-1-nsaenzjulienne@suse.de>
	 <20190731154752.16557-4-nsaenzjulienne@suse.de>
	 <CAL_JsqKF5nh3hcdLTG5+6RU3_TnFrNX08vD6qZ8wawoA3WSRpA@mail.gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-bHwRoCAB9PanvfyTc8AQ"
User-Agent: Evolution 3.32.4 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-bHwRoCAB9PanvfyTc8AQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Rob,
Thanks for the review!

On Fri, 2019-08-02 at 11:17 -0600, Rob Herring wrote:
> On Wed, Jul 31, 2019 at 9:48 AM Nicolas Saenz Julienne
> <nsaenzjulienne@suse.de> wrote:
> > Some SoCs might have multiple interconnects each with their own DMA
> > addressing limitations. This function parses the 'dma-ranges' on each o=
f
> > them and tries to guess the maximum SoC wide DMA addressable memory
> > size.
> >=20
> > This is specially useful for arch code in order to properly setup CMA
> > and memory zones.
>=20
> We already have a way to setup CMA in reserved-memory, so why is this
> needed for that?

Correct me if I'm wrong but I got the feeling you got the point of the patc=
h
later on.

> > Signed-off-by: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
> > ---
> >=20
> >  drivers/of/fdt.c       | 72 ++++++++++++++++++++++++++++++++++++++++++
> >  include/linux/of_fdt.h |  2 ++
> >  2 files changed, 74 insertions(+)
> >=20
> > diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
> > index 9cdf14b9aaab..f2444c61a136 100644
> > --- a/drivers/of/fdt.c
> > +++ b/drivers/of/fdt.c
> > @@ -953,6 +953,78 @@ int __init early_init_dt_scan_chosen_stdout(void)
> >  }
> >  #endif
> >=20
> > +/**
> > + * early_init_dt_dma_zone_size - Look at all 'dma-ranges' and provide =
the
> > + * maximum common dmable memory size.
> > + *
> > + * Some devices might have multiple interconnects each with their own =
DMA
> > + * addressing limitations. For example the Raspberry Pi 4 has the
> > following:
> > + *
> > + * soc {
> > + *     dma-ranges =3D <0xc0000000  0x0 0x00000000  0x3c000000>;
> > + *     [...]
> > + * }
> > + *
> > + * v3dbus {
> > + *     dma-ranges =3D <0x00000000  0x0 0x00000000  0x3c000000>;
> > + *     [...]
> > + * }
> > + *
> > + * scb {
> > + *     dma-ranges =3D <0x0 0x00000000  0x0 0x00000000  0xfc000000>;
> > + *     [...]
> > + * }
> > + *
> > + * Here the area addressable by all devices is [0x00000000-0x3bffffff]=
.
> > Hence
> > + * the function will write in 'data' a size of 0x3c000000.
> > + *
> > + * Note that the implementation assumes all interconnects have the sam=
e
> > physical
> > + * memory view and that the mapping always start at the beginning of R=
AM.
>=20
> Not really a valid assumption for general code.

Fair enough. On my defence I settled on that assumption after grepping all =
dts
and being unable to find a board that behaved otherwise.

[...]

> It's possible to have multiple levels of nodes and dma-ranges. You need t=
o
> handle that case too. Doing that and handling differing address translati=
ons
> will be complicated.

Understood.

> IMO, I'd just do:
>=20
> if (of_fdt_machine_is_compatible(blob, "brcm,bcm2711"))
>     dma_zone_size =3D XX;
>=20
> 2 lines of code is much easier to maintain than 10s of incomplete code
> and is clearer who needs this. Maybe if we have dozens of SoCs with
> this problem we should start parsing dma-ranges.

FYI that's what arm32 is doing at the moment and was my first instinct. But=
 it
seems that arm64 has been able to survive so far without any machine specif=
ic
code and I have the feeling Catalin and Will will not be happy about this
solution. Am I wrong?


--=-bHwRoCAB9PanvfyTc8AQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEErOkkGDHCg2EbPcGjlfZmHno8x/4FAl1IU2kACgkQlfZmHno8
x/4vnwf/XE8+V9mimMzYNeVSaTESn/AL3orSEJeMoeUZ1CPBVspMiV34YhnJFTs+
P3QiXvdigSX/vj+I8400qhGBhIj/+34A+wdKwEYb80kh2OExM56tuKuptWLPuyPd
u9T3FLJ+NdnV8p6zloY7xYBtI62Hr618kOX/ku1lBC5sJX1y8bRjTpvKqOPnrcC/
lcwjF0tU+HjPtYVDvhm6Joe0DryRATvNyVHzFrzpmcnznP+/6JCSPcaeDzDgY5jK
6/oS4fQQuzbAasQYkJDdOtEbRkE6W933vTGU3+kBwMdMybPYJW47CWedJulvKZvJ
6UP+li0Bb59N44VHgsTjI8pB8bey3g==
=gqcX
-----END PGP SIGNATURE-----

--=-bHwRoCAB9PanvfyTc8AQ--

