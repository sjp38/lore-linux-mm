Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0160CC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 16:41:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1FEC20838
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 16:41:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1FEC20838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CFF18E0036; Thu,  1 Aug 2019 12:41:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5804A8E0001; Thu,  1 Aug 2019 12:41:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44A2E8E0036; Thu,  1 Aug 2019 12:41:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EE4928E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 12:41:09 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so45214060ede.23
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 09:41:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version;
        bh=FYkaLJEfTkQhs1LAY0HYAoA5lWSC4n+cWyjMDCTa1Hs=;
        b=DNtx5tsOdx0jBjwvJ1xvOHFMxnmTFLsIAYoxjKPkgs5NrCUuBnZjcxUsE77muO5qxY
         Q1LchlrtvvdqQIkX+5ZPmqZqTH9g2axZ3+uApRvJ2Mc1aBf2SzKzl6pC8ejoxi+iRDQw
         Q7OVTu7RQGysDRc0e+xB9SULcBYAXHohRn4/Ybw/ciPKbbMdhnotY5Lf5o3gEEVGJAzE
         kgO7OgwggnaK31KPO3OlGcMoT8G+rmhlsO/o9y2Qvn84TMbnlpek6vSBjyu8tD+bQO8W
         I+DkLlX+cguu5eGr9YKFZH/We//ymGVuUN/pCikKSc2K5QvI22EjOWE52ZhGh/sZdudX
         YaNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Gm-Message-State: APjAAAVAVLLjEg4EzTPcxcHJTpE5MLlaoSW02wWgDZ/FGGOKry/JdK5u
	QUbQ0B/Iri80sxC/zWbkLf3p9IVbeap6kxe5a0tZbXe5svhvoGFNAjgFk6Wlw4AEkggeR0L6RCH
	QOexZ3tzLRSbDL5L26dvpL3+iryKjD7VAJoOZQLfbv5wS9qNRXnXPf6KZI4XloRJf6w==
X-Received: by 2002:a50:95ae:: with SMTP id w43mr113879593eda.115.1564677669538;
        Thu, 01 Aug 2019 09:41:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnbcQRlikHXs6BQ6AoLjRa/oVxVSuB0X0HXXfvloCyT7A/giwSlY9y7gx0d8Qr29vsDbcd
X-Received: by 2002:a50:95ae:: with SMTP id w43mr113879518eda.115.1564677668673;
        Thu, 01 Aug 2019 09:41:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564677668; cv=none;
        d=google.com; s=arc-20160816;
        b=IMtOa+uIScCCp0JLy0gpuzrMNkiQ5zLlRpzMjPbv0+2pYU4NLbyYIgtQkg9Ac66xc+
         KyWF1nTaOUFPe83kj5uXHgE+DviSIzN56Gg9vzb3wUvLRXEQ8/pUJVUlHUnsXBcns8sA
         tnCVRpkLKNWzRCzKQvqXpzfyrxmxjWuVsk3WpcQQNyq8aqYaogQtg8ILvQjPI3FL0QDa
         Lo/qn5Ewy0LaabhML+YiKF2juBYM13Rg/mngMb/2z+Hn7H0a0mMRT1GCwX/j6owk8eBR
         RYO+DRCUqo6DBq9zLj8jh5qXaNosxDFjrBzFBfNphqe+JuqlCO1a4fsy1SgM6TeaAj0F
         vziA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:in-reply-to:date:cc:to:from
         :subject:message-id;
        bh=FYkaLJEfTkQhs1LAY0HYAoA5lWSC4n+cWyjMDCTa1Hs=;
        b=GkRlvg/KruDFotfxQcIfEZnn/K5PIHyCvlHIZRQGvcN06ALpNACv3zk9rOXqFAQy4r
         Y4k05++8TLY8+UoQpfsOJyVR7h8hSVeSfwO2F/qcSOp4ZbDPII6g3uPgKHFfue6XsAYn
         tA/GJZeskEFc5+QzUriCM9ywr077M3g3CScaqosmWy9WCO7XQwjCJGUcbV5OptT7cERC
         //SjruROt9HT7fKMxd2oQT9AzMMCome3fKZ3d5NljS/LaDa2JMqpR56tjlwZ+bOfUzpx
         BEWQvfzGlTk7ROjxcGig+DdoYeZkbrvmCm+yX6wOt2pziL0XtI0ovJBDsVRBFEgzYmyW
         McfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p16si21363519ejr.358.2019.08.01.09.41.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 09:41:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E44E3AFA1;
	Thu,  1 Aug 2019 16:41:07 +0000 (UTC)
Message-ID: <4027201b6128b3f2b0ab941dc473ab143da64be2.camel@suse.de>
Subject: Re: [PATCH 5/8] arm64: use ZONE_DMA on DMA addressing limited
 devices
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: Robin Murphy <robin.murphy@arm.com>, Catalin Marinas
	 <catalin.marinas@arm.com>
Cc: phill@raspberryi.org, devicetree@vger.kernel.org, f.fainelli@gmail.com, 
 linux-mm@kvack.org, marc.zyngier@arm.com, Will Deacon <will@kernel.org>, 
 linux-kernel@vger.kernel.org, eric@anholt.net,
 iommu@lists.linux-foundation.org,  robh+dt@kernel.org,
 linux-rpi-kernel@lists.infradead.org, mbrugger@suse.com, 
 akpm@linux-foundation.org, m.szyprowski@samsung.com,
 frowand.list@gmail.com,  hch@lst.de, linux-arm-kernel@lists.infradead.org,
 wahrenst@gmx.net
Date: Thu, 01 Aug 2019 18:40:50 +0200
In-Reply-To: <e35dd4a5-281b-d281-59c9-3fc7108eb8be@arm.com>
References: <20190731154752.16557-1-nsaenzjulienne@suse.de>
	 <20190731154752.16557-6-nsaenzjulienne@suse.de>
	 <20190731170742.GC17773@arrakis.emea.arm.com>
	 <d8b4a7cb9c06824ca88a0602a5bf38b6324b43c0.camel@suse.de>
	 <e35dd4a5-281b-d281-59c9-3fc7108eb8be@arm.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-qAJVJtco/gH4l0Ax6g8O"
User-Agent: Evolution 3.32.4 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-qAJVJtco/gH4l0Ax6g8O
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2019-08-01 at 17:07 +0100, Robin Murphy wrote:
> On 2019-08-01 4:44 pm, Nicolas Saenz Julienne wrote:
> > On Wed, 2019-07-31 at 18:07 +0100, Catalin Marinas wrote:
> > > On Wed, Jul 31, 2019 at 05:47:48PM +0200, Nicolas Saenz Julienne wrot=
e:
> > > > diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> > > > index 1c4ffabbe1cb..f5279ef85756 100644
> > > > --- a/arch/arm64/mm/init.c
> > > > +++ b/arch/arm64/mm/init.c
> > > > @@ -50,6 +50,13 @@
> > > >   s64 memstart_addr __ro_after_init =3D -1;
> > > >   EXPORT_SYMBOL(memstart_addr);
> > > >  =20
> > > > +/*
> > > > + * We might create both a ZONE_DMA and ZONE_DMA32. ZONE_DMA is nee=
ded
> > > > if
> > > > there
> > > > + * are periferals unable to address the first naturally aligned 4G=
B of
> > > > ram.
> > > > + * ZONE_DMA32 will be expanded to cover the rest of that memory. I=
f
> > > > such
> > > > + * limitations doesn't exist only ZONE_DMA32 is created.
> > > > + */
> > >=20
> > > Shouldn't we instead only create ZONE_DMA to cover the whole 32-bit
> > > range and leave ZONE_DMA32 empty? Can__GFP_DMA allocations fall back
> > > onto ZONE_DMA32?
> >=20
> > Hi Catalin, thanks for the review.
> >=20
> > You're right, the GFP_DMA page allocation will fail with a nasty dmesg =
error
> > if
> > ZONE_DMA is configured but empty. Unsurprisingly the opposite situation=
 is
> > fine
> > (GFP_DMA32 with an empty ZONE_DMA32).
>=20
> Was that tested on something other than RPi4 with more than 4GB of RAM?=
=20
> (i.e. with a non-empty ZONE_NORMAL either way)

No, all I did is play around with RPi4's memory size (1 GB vs 4 GB).

I'll see If I can get access to a dts based board with more than 4 GB, If n=
ot
I'll try to fake it. It's not ideal but I can set the limit on 3 GB and hav=
e
the 3 areas created (with and witouth an empty ZONE_DMA32).

On top of that, now that you ask, I realise I neglected all the ACPI based
servers. I have access to some so I'll make sure I test everything on them =
too
for the next series.

Regards,
Nicolas


--=-qAJVJtco/gH4l0Ax6g8O
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEErOkkGDHCg2EbPcGjlfZmHno8x/4FAl1DFhIACgkQlfZmHno8
x/5YnAf/aih3gNCdpPnk9CDn+WHuChefMegomFiKPy7KLWGYmB9OrtzlXlYit3VU
z2zffpz7+B+tFBZWLyxyQfJ8sT8uogFFJR+HNsvucEC2z4cDMksEkCgYQRHcv5iq
4CDSPUrd5zuESxZjq3ne7sLGx0G41aVs7o+iKAaUls/WAhq7MbYiq8B/r9HPnS1/
qAxsHlnX0PASFIN3BCnr+1VSy+xbwpFNSNVfqLYtWRQZvI8ww3Epx/AbWcTKy3YC
3YbXITPMlA4Mf+0ROrmU4sf0dj/mdQkC6SYqPjTMqVYyzON4rJ/MvOChQDmEGPs6
WiNr9ZnC1GXA4QfwFXcRrfK85+Y0vw==
=e240
-----END PGP SIGNATURE-----

--=-qAJVJtco/gH4l0Ax6g8O--

