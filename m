Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id E437C6B0035
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 03:11:06 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so9458741pad.24
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 00:11:06 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ro10si16577600pbc.207.2014.08.04.00.11.04
        for <linux-mm@kvack.org>;
        Mon, 04 Aug 2014 00:11:05 -0700 (PDT)
From: "Joonsoo Kim" <iamjoonsoo.kim@lge.com>
References: <54sabdnxop04vxd7ewndc0qf.1407077745645@email.android.com>
In-Reply-To: <54sabdnxop04vxd7ewndc0qf.1407077745645@email.android.com>
Subject: RE: [linux-3.10.17] Could not allocate memory from free CMA areas
Date: Mon, 4 Aug 2014 16:11:00 +0900
Message-ID: <003201cfafb3$3fe43180$bfac9480$@lge.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'pintu_agarwal' <pintu_agarwal@yahoo.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, ritesh.list@gmail.com
Cc: pintu.k@outlook.com, pintu.k@samsung.com, vishu_1385@yahoo.com, m.szyprowski@samsung.com, mina86@mina86.com, ngupta@vflare.org, iqbalblr@gmail.com

> Dear Joonsoo,
>=20
> I tried your changes which are present at the below link.=20
> https://github.com/JoonsooKim/linux/tree/cma-fix-up-v3.0-next-20140625
> But unfortunately for me it did not help much.=20
> After running various apps that uses ION nonmovable memory, it fails =
to allocate memory after some time. When I see the pagetypeinfo shows =
lots of CMA pages available and non-movable were very less and thus =
nonmovable allocation were failing.

Okay. CMA pages cannot be used for nonmovable memory, so it can fail in =
above case.

> However I noticed the failure was little delayed.

It is good sign. I guess that there is movable/CMA ratio problem.
My patchset uses free CMA pages in certain ratio to free movable page =
consumption.
If your system doesn't use movable page sufficiently, free CMA pages =
cannot
be used fully. Could you test with following workaround?

+       if (normal > cma) {
+               zone->max_try_normal =3D pageblock_nr_pages;
+               zone->max_try_cma =3D pageblock_nr_pages;
+       } else {
+               zone->max_try_normal =3D pageblock_nr_pages;
+               zone->max_try_cma =3D pageblock_nr_pages;
+       }

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
