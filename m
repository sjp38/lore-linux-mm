Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E44ABC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 16:00:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B06F4206B8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 16:00:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B06F4206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4687B8E002F; Thu,  1 Aug 2019 12:00:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F5A88E0001; Thu,  1 Aug 2019 12:00:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BA2C8E002F; Thu,  1 Aug 2019 12:00:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id CF5EB8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 12:00:29 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id w25so45148285edu.11
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 09:00:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version;
        bh=1b/wt1U/lG3pg/LMYilipFpK6VhaOebkoQ+34IMQoiQ=;
        b=XhYgE+5R30CcHHOQTMtWgIIvZwfrrkLlU6GXISOkjIOIYOKR/u62duGgQ1GfRV+/SI
         Z5aXPwscHW5Mw9RCN4tNARUtwbzEBp4sol36nSMyV2yRlyVon5/QA2rGapUqKmgXw/7s
         R5RCnRN7vAikEzgvyIlYyn1MU8S4P7WDWYQzxm1s+1ms7JLFpqIM1GJ2vKbt4f1SWYHF
         hceHY5FNAvXfLdElbIvyQ5QQb1CE4krYt+eyhhwB4xnGGYJCNGPLUs8wmltVq8QcljSL
         HlOyGkfNfebMPzRunkdTCT5geBhn1hnjVDPhA/u1p3nVShf291KoqPoz9L/wC7Q7mSf7
         8fFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Gm-Message-State: APjAAAXeWdF3rKOkDA5oMnWnZFSmF+HW8/qLScLqcZmoMULkz8L9mWR1
	4lgY7n3yyB+Z3PcPFvxDrwS0pDQ0hlHqiE29t2QaiB4leqVdqgQzuFeTolsBT4KZFv9Uqe0j5In
	iEfK9byveBhnd45M+kwEXWRWH1VmvAXl8UJUkq65KsRQ7a11si0DMfS8TZHe+EefXJA==
X-Received: by 2002:a17:906:8591:: with SMTP id v17mr100150332ejx.244.1564675229402;
        Thu, 01 Aug 2019 09:00:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyA/ACUlVczI36XSWHagapMU+nXJL8dD6MllVYOCMlJexV9ABCX6O+0aQlpQ+OiRBUAA4TQ
X-Received: by 2002:a17:906:8591:: with SMTP id v17mr100150237ejx.244.1564675228541;
        Thu, 01 Aug 2019 09:00:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564675228; cv=none;
        d=google.com; s=arc-20160816;
        b=yF59kaEpcQhc+0TPExQMXuKpXIjlSkGvydk164er+PLlKnDgQRQ94/BaTalEj5ZolI
         TYTTXtAca5C2F8CikNGUPN3OYNHjcKbVd/ECGWT+Ody5FFqVxYNXDlMULTrrz5D5cgV0
         qCxOdWKItB2e965gggKns1yAQ5p4qqxKOucJvqmAp1ZEiZVzHUoqPGt0lMUrlEauCRfp
         e55Wo47Wb9fgF1M//5l72YOuNwel7aWPOkKkyzlCXvwUSWCA7CO4QG4mJnfli+DL/gA/
         vJiduEKC1a0oboYgJqfXrUC7kXD6Noimx1UTdUDki/13aS4O1Fhd3NbmjBmjEJsslW8f
         5NZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:in-reply-to:date:cc:to:from
         :subject:message-id;
        bh=1b/wt1U/lG3pg/LMYilipFpK6VhaOebkoQ+34IMQoiQ=;
        b=l6CVOaHToVv1Xa5qTY3N0B55DytfFlarsVMiM0n94Fh1VjWtnJZPCHUCxmDrNmkgx9
         dVP/LdfBYaWZQALFS9X0keO3IM3ZFs+JCR2eKioZZoL7Y2I1CqJfsYF2djEdHUgwh3ne
         LyqpssjIcAo0CQgUQC4LfVviMAjOSqr/9Ou7nK/K3rjl1yuecEDd5DDpIWqr9q1sxmbC
         PN47ELqIMnJv+gkM6WLNaPUw4F/DKBUbdi6Bgo3IQqGoaTcZXj2KgVIwBfBKykXxLGf9
         +Tme1JHVW8SueBYWrEGHOep+v6M+794rSJMiiTIeLvZTeQ9XY93jVZ6HgAOzW+HZdhsZ
         Nclg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b21si22013916edw.264.2019.08.01.09.00.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 09:00:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7FF1DAC2E;
	Thu,  1 Aug 2019 16:00:27 +0000 (UTC)
Message-ID: <ed5388412df78ad0a9ed69cdf3ac716eac075141.camel@suse.de>
Subject: Re: [PATCH 6/8] dma-direct: turn ARCH_ZONE_DMA_BITS into a variable
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: Christoph Hellwig <hch@lst.de>
Cc: catalin.marinas@arm.com, wahrenst@gmx.net, marc.zyngier@arm.com, Robin
 Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, 
 devicetree@vger.kernel.org, iommu@lists.linux-foundation.org,
 linux-mm@kvack.org,  Marek Szyprowski <m.szyprowski@samsung.com>,
 phill@raspberryi.org, f.fainelli@gmail.com, will@kernel.org, 
 linux-kernel@vger.kernel.org, robh+dt@kernel.org, eric@anholt.net, 
 mbrugger@suse.com, akpm@linux-foundation.org, frowand.list@gmail.com, 
 linux-rpi-kernel@lists.infradead.org, Benjamin Herrenschmidt
 <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael
 Ellerman <mpe@ellerman.id.au>, Heiko Carstens <heiko.carstens@de.ibm.com>,
 Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger
 <borntraeger@de.ibm.com>,  linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org
Date: Thu, 01 Aug 2019 17:59:34 +0200
In-Reply-To: <20190801140452.GB23435@lst.de>
References: <20190731154752.16557-1-nsaenzjulienne@suse.de>
	 <20190731154752.16557-7-nsaenzjulienne@suse.de>
	 <20190801140452.GB23435@lst.de>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-1xpVXG9aO5tI8LW1PkIr"
User-Agent: Evolution 3.32.4 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-1xpVXG9aO5tI8LW1PkIr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Christoph, thanks for the review.

On Thu, 2019-08-01 at 16:04 +0200, Christoph Hellwig wrote:
> A few nitpicks, otherwise this looks great:
>=20
> > @@ -201,7 +202,7 @@ static int __init mark_nonram_nosave(void)
> >   * everything else. GFP_DMA32 page allocations automatically fall back=
 to
> >   * ZONE_DMA.
> >   *
> > - * By using 31-bit unconditionally, we can exploit ARCH_ZONE_DMA_BITS =
to
> > + * By using 31-bit unconditionally, we can exploit arch_zone_dma_bits =
to
> >   * inform the generic DMA mapping code.  32-bit only devices (if not
> > handled
> >   * by an IOMMU anyway) will take a first dip into ZONE_NORMAL and get
> >   * otherwise served by ZONE_DMA.
> > @@ -237,9 +238,18 @@ void __init paging_init(void)
> >  	printk(KERN_DEBUG "Memory hole size: %ldMB\n",
> >  	       (long int)((top_of_ram - total_ram) >> 20));
> > =20
> > +	/*
> > +	 * Allow 30-bit DMA for very limited Broadcom wifi chips on many
> > +	 * powerbooks.
> > +	 */
> > +	if (IS_ENABLED(CONFIG_PPC32))
> > +		arch_zone_dma_bits =3D 30;
> > +	else
> > +		arch_zone_dma_bits =3D 31;
> > +
>=20
> So the above unconditionally comment obviously isn't true any more, and
> Ben also said for the recent ppc32 hack he'd prefer dynamic detection.
>=20
> Maybe Ben and or other ppc folks can chime in an add a patch to the serie=
s
> to sort this out now that we have a dynamic ZONE_DMA threshold?

Noted, for now I'll remove the comment.

> > diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
> > index 59bdceea3737..40dfc9b4ee4c 100644
> > --- a/kernel/dma/direct.c
> > +++ b/kernel/dma/direct.c
> > @@ -19,9 +19,7 @@
> >   * Most architectures use ZONE_DMA for the first 16 Megabytes, but
> >   * some use it for entirely different regions:
> >   */
> > -#ifndef ARCH_ZONE_DMA_BITS
> > -#define ARCH_ZONE_DMA_BITS 24
> > -#endif
> > +unsigned int arch_zone_dma_bits __ro_after_init =3D 24;
>=20
> I'd prefer to drop the arch_ prefix and just calls this zone_dma_bits.
> In the long run we really need to find a way to just automatically set
> this from the meminit code, but that is out of scope for this series.
> For now can you please just update the comment above to say something
> like:
>=20
> /*
>  * Most architectures use ZONE_DMA for the first 16 Megabytes, but some u=
se it
>  * it for entirely different regions.  In that case the arch code needs t=
o
>  * override the variable below for dma-direct to work properly.
>  */

Ok perfect.


--=-1xpVXG9aO5tI8LW1PkIr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEErOkkGDHCg2EbPcGjlfZmHno8x/4FAl1DDGYACgkQlfZmHno8
x/7w9wgAsuuhgVK1nlC7WgrB2sfSYqL6HTJlDfkLJ2RMgzu/WSw4RJsje86on5R9
NmRSTVntXnCdpTNiKcSEKP7MnrVtMh2TtopfTOCvgho/uDJsc4DPAqZaLHO4quzo
ZfimsWkcpC6n/E8ybEcew+6U7BIyqJPtqxgdkXz98gLQ1NK1wJU2x0Gt+KXT5a/0
hR3hA3whz8yIe4hwQTEiAzX/LnSP8+Yp+g1LLFjYveqt2RUbfC/udykYkLS7LdoO
SJ6j5S/1jRpvusBjENkY3PQiRGrhfRnT4qxVSdpkK/rMG6pLMW4l9YjfbQCLOFhn
8qxZKNifDs1KxpZjExjd4Lisum4nhw==
=nw8i
-----END PGP SIGNATURE-----

--=-1xpVXG9aO5tI8LW1PkIr--

