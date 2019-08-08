Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34EAFC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 17:30:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E879B217F4
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 17:30:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E879B217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9450A6B0005; Thu,  8 Aug 2019 13:30:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91A6F6B0006; Thu,  8 Aug 2019 13:30:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E3596B0007; Thu,  8 Aug 2019 13:30:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3321F6B0005
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 13:30:47 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d27so58653819eda.9
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 10:30:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version;
        bh=QGAu8baUX/dwJHptqlxauYxNTuXBD1fNfPWWjfKzsgA=;
        b=qXg93dzorGvW8fG03D0LlDLTFY5JdACKYiYstSEoy/pYuX30WLkwd5a0hR+AvJ4szH
         EZ+DJXd8/z/X8s1RG6m2ODADICOM/EtaF0GgJWWS4zUhJPM5SqpaEP+ybjdTtDtPsWn/
         RVUhSab0+XTpIbg373om6tsTyb7OywkfljAHjwCj4O38Rdbz2kf5tT76wokp2duukU4g
         Rsk01q3AIsUqBE9dsVTKOnhoy13MyaWIm1bMKl++rH2MchdVmbOVDXlK4nt7bHTtEF0L
         SdG4uq175SLhWGB4nhwFXWP/ubjJungdaOliA1FP0swthtF2PpheTrU8pbRI2fs7JHV4
         BxIg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Gm-Message-State: APjAAAWPMxFhEtlaREldh/TXLLS3x3JKydK4JPSW8DS4OQSg8jfDo5x5
	X/ZCmZNZdx5GdUqqZscOY0g0sLuk7yLHGKA/xszK6Yn1ZAl/LU1S5kxYnS23hualb+IG2Ph2HLG
	x4xLP3FxOGb2hlEhAfegsLgxM48XsRZbhZagpRNcDwNgfy+Vt2FW8RhK2dOgDxr23vg==
X-Received: by 2002:a05:6402:1507:: with SMTP id f7mr17249070edw.94.1565285446641;
        Thu, 08 Aug 2019 10:30:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCcQ/I7IMqCCNxK7M5khus2j2TnDu8MPD3Q9OcIBM5HTn6HnU6ttqqSFeyadTBxUKXPWbc
X-Received: by 2002:a05:6402:1507:: with SMTP id f7mr17248970edw.94.1565285445685;
        Thu, 08 Aug 2019 10:30:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565285445; cv=none;
        d=google.com; s=arc-20160816;
        b=dE4eWl9jIofFcvXGyeNKmvJrs19YnD8gt9I3j6/GftByYWKVorAS8jU8W31ZvxUftO
         B/hFl3kGnWO3cQ+pk/dZmLNQI6AieUckmMx7KjkCek6A0bvZsCzQ5s6QCjyqGVmMsfaF
         m2335knNwaBi+HUb12tPG9RTbccfooAx83aHnCB6IsAe9lfhxsheuWcPEJESsaqYbw1G
         cgjOQbje5Oi94YJIzrgBhXIf9hAm/EcY0gPAChOyr6i6av20gaHLqkXmYVMD6zA3zvTN
         jgWxFGCFoWikbZP9YZM16ImW2xr0AE6wSZr04uEs7de5diZCEuZEdMKQvP7BTK836TIm
         n1yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:in-reply-to:date:cc:to:from
         :subject:message-id;
        bh=QGAu8baUX/dwJHptqlxauYxNTuXBD1fNfPWWjfKzsgA=;
        b=oU+wwKVYe0H1SRBrKKMjD12kxqWV8bXuRAs1Q6OKkwjW5tRe/RB3VM1Rc+q/p4WwhC
         Sx8qirBqxJTAkOB+mR6KOb+TzUKvBgLQU6FteFhahmsXukFzArPcq9kT+e9AuqCzThCB
         5UAPypV7gkME19aB6ryjisQBieDJF9I9yhBcpd/U7Vy1raS7+PUqqQG6bEWYbRZONtH3
         KdToj/74d+ntm8yFxkhAnvt4DiHtkIYliKSt0ayeLFJtzFG00eD6avqDiJTH6mQRGedn
         Bfjw1EI3hzltyPxsiwEJ349rTF+c6LO8zfGaTz7cK8A8Xh+1CK2nrKt8LCeJg/YFKmuJ
         lM4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x18si10421935edd.17.2019.08.08.10.30.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 10:30:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E72A0AF4C;
	Thu,  8 Aug 2019 17:30:44 +0000 (UTC)
Message-ID: <6917ea286e76cb0f3f3bea23552a00d1b2a381de.camel@suse.de>
Subject: Re: [PATCH 3/8] of/fdt: add function to get the SoC wide DMA
 addressable memory size
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: Rob Herring <robh+dt@kernel.org>
Cc: phill@raspberryi.org, devicetree@vger.kernel.org, "moderated
 list:BROADCOM BCM2835 ARM ARCHITECTURE"
 <linux-rpi-kernel@lists.infradead.org>, Florian Fainelli
 <f.fainelli@gmail.com>,  Will Deacon <will@kernel.org>, Eric Anholt
 <eric@anholt.net>, Marc Zyngier <marc.zyngier@arm.com>,  Catalin Marinas
 <catalin.marinas@arm.com>, Frank Rowand <frowand.list@gmail.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 linux-mm@kvack.org, Linux IOMMU <iommu@lists.linux-foundation.org>,
 Matthias Brugger <mbrugger@suse.com>,  wahrenst@gmx.net, Andrew Morton
 <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, Christoph
 Hellwig <hch@lst.de>, "moderated list:ARM/FREESCALE IMX / MXC ARM
 ARCHITECTURE" <linux-arm-kernel@lists.infradead.org>, Marek Szyprowski
 <m.szyprowski@samsung.com>
Date: Thu, 08 Aug 2019 19:30:42 +0200
In-Reply-To: <CAL_JsqJS6XBSc8DuK2sJApHtY4nCSFpLezf003YMD75THLHAqg@mail.gmail.com>
References: <20190731154752.16557-1-nsaenzjulienne@suse.de>
	 <20190731154752.16557-4-nsaenzjulienne@suse.de>
	 <CAL_JsqKF5nh3hcdLTG5+6RU3_TnFrNX08vD6qZ8wawoA3WSRpA@mail.gmail.com>
	 <2050374ac07e0330e505c4a1637256428adb10c4.camel@suse.de>
	 <CAL_Jsq+LjsRmFg-xaLgpVx3miXN3hid3aD+mgTW__j0SbEFYjQ@mail.gmail.com>
	 <12eb3aba207c552e5eb727535e7c4f08673c4c80.camel@suse.de>
	 <CAL_JsqJS6XBSc8DuK2sJApHtY4nCSFpLezf003YMD75THLHAqg@mail.gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-aUnd1sGElH9S49gE7iVL"
User-Agent: Evolution 3.32.4 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-aUnd1sGElH9S49gE7iVL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2019-08-08 at 09:02 -0600, Rob Herring wrote:
> On Tue, Aug 6, 2019 at 12:12 PM Nicolas Saenz Julienne
> <nsaenzjulienne@suse.de> wrote:
> > Hi Rob,
> >=20
> > On Mon, 2019-08-05 at 13:23 -0600, Rob Herring wrote:
> > > On Mon, Aug 5, 2019 at 10:03 AM Nicolas Saenz Julienne
> > > <nsaenzjulienne@suse.de> wrote:
> > > > Hi Rob,
> > > > Thanks for the review!
> > > >=20
> > > > On Fri, 2019-08-02 at 11:17 -0600, Rob Herring wrote:
> > > > > On Wed, Jul 31, 2019 at 9:48 AM Nicolas Saenz Julienne
> > > > > <nsaenzjulienne@suse.de> wrote:
> > > > > > Some SoCs might have multiple interconnects each with their own=
 DMA
> > > > > > addressing limitations. This function parses the 'dma-ranges' o=
n
> > > > > > each of
> > > > > > them and tries to guess the maximum SoC wide DMA addressable me=
mory
> > > > > > size.
> > > > > >=20
> > > > > > This is specially useful for arch code in order to properly set=
up
> > > > > > CMA
> > > > > > and memory zones.
> > > > >=20
> > > > > We already have a way to setup CMA in reserved-memory, so why is =
this
> > > > > needed for that?
> > > >=20
> > > > Correct me if I'm wrong but I got the feeling you got the point of =
the
> > > > patch
> > > > later on.
> > >=20
> > > No, for CMA I don't. Can't we already pass a size and location for CM=
A
> > > region under /reserved-memory. The only advantage here is perhaps the
> > > CMA range could be anywhere in the DMA zone vs. a fixed location.
> >=20
> > Now I get it, sorry I wasn't aware of that interface.
> >=20
> > Still, I'm not convinced it matches RPi's use case as this would hard-c=
ode
> > CMA's size. Most people won't care, but for the ones that do, it's nice=
r to
> > change the value from the kernel command line than editing the dtb.
>=20
> Sure, I fully agree and am not a fan of the CMA DT overlays I've seen.
>=20
> > I get that
> > if you need to, for example, reserve some memory for the video to work,=
 it's
> > silly not to hard-code it. Yet due to the board's nature and users base=
 I
> > say
> > it's important to favor flexibility. It would also break compatibility =
with
> > earlier versions of the board and diverge from the downstream kernel
> > behaviour.
> > Which is a bigger issue than it seems as most users don't always unders=
tand
> > which kernel they are running and unknowingly copy configuration option=
s
> > from
> > forums.
> >=20
> > As I also need to know the DMA addressing limitations to properly confi=
gure
> > memory zones and dma-direct. Setting up the proper CMA constraints duri=
ng
> > the
> > arch's init will be trivial anyway.
>=20
> It was really just commentary on commit text as for CMA alone we have
> a solution already. I agree on the need for zones.

Ok, understood :)

> > > > > IMO, I'd just do:
> > > > >=20
> > > > > if (of_fdt_machine_is_compatible(blob, "brcm,bcm2711"))
> > > > >     dma_zone_size =3D XX;
> > > > >=20
> > > > > 2 lines of code is much easier to maintain than 10s of incomplete=
 code
> > > > > and is clearer who needs this. Maybe if we have dozens of SoCs wi=
th
> > > > > this problem we should start parsing dma-ranges.
> > > >=20
> > > > FYI that's what arm32 is doing at the moment and was my first insti=
nct.
> > > > But
> > > > it
> > > > seems that arm64 has been able to survive so far without any machin=
e
> > > > specific
> > > > code and I have the feeling Catalin and Will will not be happy abou=
t
> > > > this
> > > > solution. Am I wrong?
> > >=20
> > > No doubt. I'm fine if the 2 lines live in drivers/of/.
> > >=20
> > > Note that I'm trying to reduce the number of early_init_dt_scan_*
> > > calls from arch code into the DT code so there's more commonality
> > > across architectures in the early DT scans. So ideally, this can all
> > > be handled under early_init_dt_scan() call.
> >=20
> > How does this look? (I'll split it in two patches and add a comment
> > explaining
> > why dt_dma_zone_size is needed)
> >=20
> > diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
> > index f2444c61a136..1395be40b722 100644
> > --- a/drivers/of/fdt.c
> > +++ b/drivers/of/fdt.c
> > @@ -30,6 +30,8 @@
> >=20
> >  #include "of_private.h"
> >=20
> > +u64 dt_dma_zone_size __ro_after_init;
>=20
> Avoiding a call from arch code by just having a variable isn't really
> better. I'd rather see a common, non DT specific variable that can be
> adjusted. Something similar to initrd_start/end. Then the arch code
> doesn't have to care what hardware description code adjusted the
> value.

Way better, I'll update it.


--=-aUnd1sGElH9S49gE7iVL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEErOkkGDHCg2EbPcGjlfZmHno8x/4FAl1MXEIACgkQlfZmHno8
x/4I5gf6A+XJGnTIx+91Jp1InIYL3ffBEX7UUGqmhdiznnad0gVF6JWh/Kq6dJyQ
zkCiCoziJ5AFuNeS3Akpa7psFTnLYsWWaeL+FzWvSvLntp6ti6URyBlx5v4JeKT2
QaGzJsdWWGEMXA8QIHk309B127xqqgKqFJKnOYubd1h7xdULE11Ht1Ur+mTlkur/
AEaSkGTAJHap13dIxCnV2cdHt8u/79mL/vDRSCDLmUrJxaOcvQPSDQHIK86j+cBb
OEzAaU89Ektf1Uq1GI5yjn0gBRcOiPw+TaMlJw4PcPWZN1Lfz8M9lb3+QZOrykTs
KgzRXlmzYbKR0CO/8rK+dbxSO+x9gg==
=JXPI
-----END PGP SIGNATURE-----

--=-aUnd1sGElH9S49gE7iVL--

