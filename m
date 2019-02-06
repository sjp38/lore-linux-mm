Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07018C282C2
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 21:12:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3FD7218D9
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 21:12:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3FD7218D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50A5E8E0100; Wed,  6 Feb 2019 16:12:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4938F8E00E6; Wed,  6 Feb 2019 16:12:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3354C8E0100; Wed,  6 Feb 2019 16:12:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0373C8E00E6
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 16:12:13 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id b6so7685098qkg.4
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 13:12:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:organization
         :user-agent:mime-version;
        bh=xZM6e+VSayeYWTgWLolKfXjX+/IhzGAEmt/xLMzNUug=;
        b=houYMaO07P/PU/ThCg8kcuXKp30MhOlDb0gXzuzSaXF9pFIUm4SrJGm4n2TZEJiiDr
         kHGg4ADtxOqv+jZNf7qdxDccb048WC7F26I/1+KHUYyDdjncI3yL+x5ZbZ+1yyYs5rx5
         GqrHiJWU+RqvHHQU96abzon/yUX2TdMUu2dTJo680J6lKHAAwXF216lIF+Hg1ty9RM+q
         h/jznr9RkD9Rzv1aa0+1TUxCUjbZIjR3jNfPOHfTnh//UiU/+tAnf2Bt1OcgLdfCVT5m
         wpdpPmGSytRbxtQXQBrA1hmGab/5pKVGv372ke2eZdmSQgibFSTR+/EbNPYrLzF7m8ZK
         QImw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYzRdBFPnTLBdbneFeb6+PPshTgsmqfKXu3tP32iecPIeDbx9jy
	jlrnAweT6PvP1tzo5cmdBI1uFgSDZhDpxC7v0JG7O2wDub1he0o6DvECelyOJ4T8PU1zA8uPd9J
	MRD9LdPFj0RYhGwYIiFMY2spqtGrYekyRWS84WG04nUc6ff1Pycyz2tez/8lpr0NUvg==
X-Received: by 2002:ac8:2ccc:: with SMTP id 12mr9092021qtx.277.1549487532776;
        Wed, 06 Feb 2019 13:12:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZoaySQxVKuoy/N3sqj5PndZmLbsECWwJvIcv+2WW8QwverRaJKBSL8w2tTzL1BbKNmYOoD
X-Received: by 2002:ac8:2ccc:: with SMTP id 12mr9091989qtx.277.1549487532370;
        Wed, 06 Feb 2019 13:12:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549487532; cv=none;
        d=google.com; s=arc-20160816;
        b=d1+5HlSFdxVLeVi+lTVah+rQuCQ7Ltghh2BS4cUSXcQtL3GGWkdp62OkoFxM6kjLfu
         OF47COu31Z6O8tweriMebWDadvI4UzcwdfqcgNP8eM3s7QaVntt5743zB1RTv72pa8zR
         gk12gKEs5z6Q7O+P0gzioKBS+IE5YFYp7htTvq7khBeC/F93hrtcNOvaBMxt94kI3GW4
         QDjOD+JB72spv45FILfMqx0Mda6h828gBd02X/YS+HL6HnVELlKHYLZVZ45MfyEmwP6u
         3EyhQMvoFOsUu5z3WZcan53r55H0UmzSi4dm3RieEZT0u69FDQR32r5MKmDNhygMeB5q
         Fe3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:organization:references:in-reply-to:date:cc
         :to:from:subject:message-id;
        bh=xZM6e+VSayeYWTgWLolKfXjX+/IhzGAEmt/xLMzNUug=;
        b=Bz7OJpMa5yoGCjM8IDuxGah7g0IcR7ucn+bJ9S2fK+Op1k6ufrJBWahZzjNnwyMNdh
         6Byd6Kp6evQTEEi22n0ca4UzAg8JC0T7saAZrdmJyvMihy1fRmxFPI5sumWX3KV2qNDO
         CxK6x4DNF5bzDFn5PmDgK+0dhYz4UueMmzn2GxwaqpoL0FpfTt84iU8+fp1tQBWa4JVB
         d0XtEDWcgss8UPlOgqb8yoqbCXYelhNHb5mYH1T+0dfDVvNOHzWD6/8/x5+i5H2LD6Fj
         /2vmBESB3FSgN8qF/kHsVT5tjASrH4zb4dUA/PakuBZUVIxGHAiSP4vpIZug/ADXJ+jV
         0WbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z8si3284135qvn.117.2019.02.06.13.12.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 13:12:12 -0800 (PST)
Received-SPF: pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 618988AE72;
	Wed,  6 Feb 2019 21:12:11 +0000 (UTC)
Received: from haswell-e.nc.xsintricity.com (ovpn-112-17.rdu2.redhat.com [10.10.112.17])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 03F9B84F3;
	Wed,  6 Feb 2019 21:12:08 +0000 (UTC)
Message-ID: <b3a0702baa3477748c3c243fa9d1c94f7b1954d6.camel@redhat.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
From: Doug Ledford <dledford@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox <willy@infradead.org>, 
 Jan Kara <jack@suse.cz>, Ira Weiny <ira.weiny@intel.com>,
 lsf-pc@lists.linux-foundation.org,  linux-rdma
 <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel
 Mailing List <linux-kernel@vger.kernel.org>, John Hubbard
 <jhubbard@nvidia.com>, Jerome Glisse <jglisse@redhat.com>, Dave Chinner
 <david@fromorbit.com>, Michal Hocko <mhocko@kernel.org>
Date: Wed, 06 Feb 2019 16:12:06 -0500
In-Reply-To: <CAPcyv4id2rzJVUZw98PfJ-k05BvD-opwj0XhOWPKZQicmhXJ=g@mail.gmail.com>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
	 <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca>
	 <20190206175233.GN21860@bombadil.infradead.org>
	 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
	 <20190206183503.GO21860@bombadil.infradead.org>
	 <20190206185233.GE12227@ziepe.ca>
	 <CAPcyv4j4gDNHu836N4RfgQsE+eZU9Wt0N9Y09KQ43zV+4mK-eg@mail.gmail.com>
	 <671e7ebc8e125d1ebd71de9943868183e27f052b.camel@redhat.com>
	 <CAPcyv4id2rzJVUZw98PfJ-k05BvD-opwj0XhOWPKZQicmhXJ=g@mail.gmail.com>
Organization: Red Hat, Inc.
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-Wt2EcFKp3kDyEr43gL+b"
User-Agent: Evolution 3.30.4 (3.30.4-1.fc29) 
Mime-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 06 Feb 2019 21:12:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-Wt2EcFKp3kDyEr43gL+b
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2019-02-06 at 13:04 -0800, Dan Williams wrote:
> On Wed, Feb 6, 2019 at 12:14 PM Doug Ledford <dledford@redhat.com> wrote:
> > On Wed, 2019-02-06 at 11:45 -0800, Dan Williams wrote:
> > > On Wed, Feb 6, 2019 at 10:52 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > > > On Wed, Feb 06, 2019 at 10:35:04AM -0800, Matthew Wilcox wrote:
> > > >=20
> > > > > > Admittedly, I'm coming in late to this conversation, but did I =
miss the
> > > > > > portion where that alternative was ruled out?
> > > > >=20
> > > > > That's my preferred option too, but the preponderance of opinion =
leans
> > > > > towards "We can't give people a way to make files un-truncatable"=
.
> > > >=20
> > > > I haven't heard an explanation why blocking ftruncate is worse than
> > > > giving people a way to break RDMA using process by calling ftruncat=
e??
> > > >=20
> > > > Isn't it exactly the same argument the other way?
> > >=20
> > > If the
> > > RDMA application doesn't want it to happen, arrange for it by
> > > permissions or other coordination to prevent truncation,
> >=20
> > I just argued the *exact* same thing, except from the other side: if yo=
u
> > want a guaranteed ability to truncate, then arrange the perms so the
> > RDMA or DAX capable things can't use the file.
>=20
> That doesn't make sense. All we have to work with is rwx bits. It's
> possible to prevents writes / truncates. There's no permission bit for
> mmap, O_DIRECT and RDMA mappings, hence leases.

There's ownership.  What you can't open, you can't mmap or O_DIRECT or
whatever...

Regardless though, this is mostly moot as Dave's email makes it clear
the underlying issue that is the problem is not ftruncate, but other
things.
> >=20

--=20
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--=-Wt2EcFKp3kDyEr43gL+b
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEErmsb2hIrI7QmWxJ0uCajMw5XL90FAlxbTaYACgkQuCajMw5X
L91UVRAAxQypVAaB7i52h2wDJpx5+mYhH6IiQWrtqd8xa0l2UZ2VHrRkdsn4wzGt
BQFhIJZKPh3b7yzsYKzhe9HicMCXRIXPKw/KmgJLDcDmi1hU1QCMHKohniWUbJ6G
g0IfJrLoPmMhNKn0Cm7J4s5jsP2QW6/CUn6/CGOQhWG1GtcuyFL6fCl5Bn0FFn9s
cfKDGgJ9Wy4wiguackEO+W6XUN9YFz9P4K9HMqVwXfHXXiZR2Z9H6xHQOZkafylA
KhjP2h8o0Jip4HDKOMJoP9AbmFFXK3ualefeiDoginb6D7tVs0/sbyImBTfTLzbt
7GBSNa/9Ue8qi7ZU6/ppjQILfn0mbnxV0JRV/nBOXfLeZeO1mbD2EDuPSOL+kXX4
Z4uvFWA7UxIkBTh4lwQY8g9uan3578jtdF4SNe//GBAA+pPTV9oXzzbTX+UXYE/U
MmmQjk2S+ax7PINhTZhBbkGWqVLG95Pb3UtmxPSG1uFlxdkv/DSJqkm9qeNuHZu5
Tf1Zxl648P1g7Jk6c+1hlqpe/Rt7vsjU/1gQKYMyR4ViBrvlyiwkEokrqHdN2wnK
YaJ8HcFQazJK8BwNFYmbMgWpvBN107gSh3yd3jnRm0PyxcWXNW+OfQ4X6xrgaLTQ
m6lMl9vg0O/rHaf7P53MHmweNKEOLTcH7jp1/BQ1AM5zHMN5QOA=
=Ct0f
-----END PGP SIGNATURE-----

--=-Wt2EcFKp3kDyEr43gL+b--

