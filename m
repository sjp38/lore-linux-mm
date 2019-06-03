Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3ABAC282CE
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 15:11:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E7F627B42
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 15:11:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="ZoKRYuqv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E7F627B42
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A03D6B000A; Mon,  3 Jun 2019 11:11:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 051AA6B000D; Mon,  3 Jun 2019 11:11:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5A9A6B000E; Mon,  3 Jun 2019 11:11:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id AB5406B000A
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 11:11:34 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id a5so11986558pla.3
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 08:11:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=Dp0f7RM70f8esYRnlOyhn1PIG0Zw2xqX5j6+lbcs/Ug=;
        b=G4HBl9s9Nc1FF12tqhqtZwlSi5FfEkdHzHB/JTxGn2gOX2OvldLXw5oZNCpC5nfnSp
         +5EqnHwz/uxXFzOhC/0LqdG8f3Im2h0z3/QyA6623oq13/ovedqywyZ/TpS4dyr8VNFC
         maweCI/YL9kR9n2E/mvTkftO21u0livSCyxrfcLqx/lqRHuuWsHEQsb6dkZ64LwKa42K
         6JvVe1fBN40Cw3jp2ImI9lNAps7HDoxfcsmFrXildfng69A8yvhujH0zreoHEIudznOM
         zhFQMlgRCRkKfhd88MWqvomzJ7n/Yyjz11Q1jHzQQIOiuHNdHKRxrFwa9NNRF5WHz+vt
         n4TQ==
X-Gm-Message-State: APjAAAW+KRlrOaCMDaPXa6LzhbYN4OMksSoD83baNzd/kEfxvT0ppt7T
	RiENMB0pExb8SW7JgXh9ZzoxbRAFWkIYJdEnjeqem+AV+VSGi3auvrAc5FxB/+aB57Z2V5bRVZC
	v6qHXUScd5DyT6EoK7o1zW+8DGR0n6bSukvgrQ+v2nWZWqYs74qtWkwZJ+hFqKVwe5Q==
X-Received: by 2002:a17:902:ac98:: with SMTP id h24mr23371390plr.79.1559574694034;
        Mon, 03 Jun 2019 08:11:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBBOZqR48hCICgu0rLGb4ucFwQtg7JGvodEdhekb+VmxVZTqxUOoAb25H5AeYZQF3nOHIv
X-Received: by 2002:a17:902:ac98:: with SMTP id h24mr23371251plr.79.1559574692895;
        Mon, 03 Jun 2019 08:11:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559574692; cv=none;
        d=google.com; s=arc-20160816;
        b=Wvjy0ZzH31M1Dq42Dn9f4wWzEk+uDr0IcQqR0V6sXNBlCPkdB1i41K1ATkPET6DJZs
         xqSVroyL73dFus2wiCPaIRI6Y2rzqrQ79faAOElTwIObdJau9z3r6zSJElsNh/YjFdyP
         QDhbRRgZEtnDHf4fWIFuFvEsMTFqD24r81E/DZziizRMWFnfAjkBtWPebHOs8LTq44NR
         bEnGLA9iwEIeEYulweU7gjJhfajNVOtZGYZCBuhsa0O0HEphlRRwww5liThxcvrFyoyF
         Zy0BSXa4Y19ASqcIi8qjOHsoTxfAAV0LnK9KfHiXAp+tv/QN16F1LAue4F7Tsh+oTMML
         VbDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=Dp0f7RM70f8esYRnlOyhn1PIG0Zw2xqX5j6+lbcs/Ug=;
        b=mfCx8Y9OSSJnxVsvq8GEdmcaIVkI93yr2bUulKmGmF3yDG/iNvzYGPR+b+kvYsNHIZ
         07X46A6PPmMr3fFGL/5pVjUvG9L5QAAygfMgZ7/aiE0QUoGcQxoOXcnDWwJACa5bMKNJ
         uzxrxdYMdxN74X7YpUpiJ3cEFn8bw1eaIYWIgizvGW7FFIqy8rhc/0tRFFNcvowa6QM7
         7p+zbhgDI/Cx30XARFp7BA2oB9vxtrR2S1pERHXFN/q2OndW5qarv18SBft93hBK/BAQ
         OZkx578cDm9nA0AMdG4CWyIf9isbuQvu6/3XZfSsUP0qZcgix4Qv3X0L9hAH4X931wVZ
         3khg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=ZoKRYuqv;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (bilbo.ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id t1si17740379pjv.82.2019.06.03.08.11.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 08:11:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=ZoKRYuqv;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45Hdmv545Hz9s4Y;
	Tue,  4 Jun 2019 01:11:27 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1559574688;
	bh=eDuRZMdVYYQROCCGmu+HKfLRFO7Y6eokeOO3l7DvWCo=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=ZoKRYuqvpdEn7yiFycsiV4IDbycT0IPTFEnpBIksDlOrF1XldtLiq+2iloNCVu7Ey
	 42EgecTyjdqed8SbCbEbfYMj/p0/65mIlJngX8IOIyKbJd4Qd0jh4EKeVX5Fi7KWn8
	 vboNbS+dur7m6TyeZmY7wvdxsUsume249CrlxODn9R31tYvBiUdYlJrNZHDoqZeLBK
	 zDL9zRUKTqZWCuwO3RoiyergKGDPZm8AIA5NEz7RP1GqBPWLgMdupEiif1PA3OiE64
	 pJ8Yn3y0KXTDy9VgJjYl9XQsJkt6m7vf0GMQC49wUnE/pcKNFbj00bQYHfzfhHoFhG
	 mz3dWxEa2/9xw==
Date: Tue, 4 Jun 2019 01:11:25 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Krzysztof Kozlowski <krzk@kernel.org>
Cc: Uladzislau Rezki <urezki@gmail.com>, Andrew Morton
 <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>,
 "linux-samsung-soc@vger.kernel.org" <linux-samsung-soc@vger.kernel.org>,
 linux-kernel@vger.kernel.org, Hillf Danton <hdanton@sina.com>, Thomas
 Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, Andrei Vagin
 <avagin@gmail.com>
Subject: Re: [BUG BISECT] bug mm/vmalloc.c:470 (mm/vmalloc.c: get rid of one
 single unlink_va() when merge)
Message-ID: <20190604011125.266222a8@canb.auug.org.au>
In-Reply-To: <CAJKOXPed=npnfk0H2WUDityHg5cPLH_zwShyRd+B2RS8h6C7SQ@mail.gmail.com>
References: <CAJKOXPcTVpLtSSs=Q0G3fQgXYoVa=kHxWcWXyvS13ie73ByZBw@mail.gmail.com>
	<20190603135939.e2mb7vkxp64qairr@pc636>
	<CAJKOXPdczUnsaBeXTuutZXCQ70ejDT68xnVm-e+SSdLZi-vyCA@mail.gmail.com>
	<20190604003153.76f33dd2@canb.auug.org.au>
	<CAJKOXPed=npnfk0H2WUDityHg5cPLH_zwShyRd+B2RS8h6C7SQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/ydAB_847pdF8mWcT_YXzIYL"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/ydAB_847pdF8mWcT_YXzIYL
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Krzysztof,

On Mon, 3 Jun 2019 16:35:22 +0200 Krzysztof Kozlowski <krzk@kernel.org> wro=
te:
>
> On Mon, 3 Jun 2019 at 16:32, Stephen Rothwell <sfr@canb.auug.org.au> wrot=
e:
> >
> > On Mon, 3 Jun 2019 16:10:40 +0200 Krzysztof Kozlowski <krzk@kernel.org>=
 wrote: =20
> > >
> > > Indeed it looks like effect of merge conflict resolution or applying.
> > > When I look at MMOTS, it is the same as yours:
> > > http://git.cmpxchg.org/cgit.cgi/linux-mmots.git/commit/?id=3Db77b8cce=
67f246109f9d87417a32cd38f0398f2f
> > >
> > > However in linux-next it is different.
> > >
> > > Stephen, any thoughts? =20
> >
> > Have you had a look at today's linux-next?  It looks correct in
> > there.  Andrew updated his patch series over the weekend. =20
>=20
> Yes, I am looking at today's next. Both the source code and the commit
> 728e0fbf263e3ed359c10cb13623390564102881 have wrong "if (merged)" (put
> in wrong hunk).

OK, I have replaced that commit with this:

From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: mm/vmalloc.c: get rid of one single unlink_va() when merge

It does not make sense to try to "unlink" the node that is definitely not
linked with a list nor tree.  On the first merge step VA just points to
the previously disconnected busy area.

On the second step, check if the node has been merged and do "unlink" if
so, because now it points to an object that must be linked.

Link: http://lkml.kernel.org/r/20190527151843.27416-4-urezki@gmail.com
Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
Acked-by: Hillf Danton <hdanton@sina.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Joel Fernandes <joelaf@google.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Thomas Garnier <thgarnie@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/vmalloc.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

--- a/mm/vmalloc.c~mm-vmap-get-rid-of-one-single-unlink_va-when-merge
+++ a/mm/vmalloc.c
@@ -719,9 +719,6 @@ merge_or_add_vmap_area(struct vmap_area
 			/* Check and update the tree if needed. */
 			augment_tree_propagate_from(sibling);
=20
-			/* Remove this VA, it has been merged. */
-			unlink_va(va, root);
-
 			/* Free vmap_area object. */
 			kmem_cache_free(vmap_area_cachep, va);
=20
@@ -746,12 +743,11 @@ merge_or_add_vmap_area(struct vmap_area
 			/* Check and update the tree if needed. */
 			augment_tree_propagate_from(sibling);
=20
-			/* Remove this VA, it has been merged. */
-			unlink_va(va, root);
+			if (merged)
+				unlink_va(va, root);
=20
 			/* Free vmap_area object. */
 			kmem_cache_free(vmap_area_cachep, va);
-
 			return;
 		}
 	}
_

Which is the patch from mmots but with different line numbers.
--=20
Cheers,
Stephen Rothwell

--Sig_/ydAB_847pdF8mWcT_YXzIYL
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlz1OJ0ACgkQAVBC80lX
0Gy1Awf8CHdwemQ/KgeILWHLGe2zYZfMlga1K+adEnhVDxrxEryZFGJiRTFghndD
y2UPZLjUfSTmwmZwmUydCCNYHem0/M89nP6f6o2GYHtg3wQJKSVzDE7JXssQ0+p/
DMtYxHL8VCKIzTU250tEC2kzxU+9IXwflrLHuLLEaWYmbtgudEpUdFr0xWGbGPh7
17rGAfC7A+rJY3DoomLyJfsGYID6dbHewlghDzEPvNLziVfsAZH35bmzAnwEs3vv
hZhB8TZb8Lj5U4e3JT6SqVBON96IAkOj2Ti5QaeEyjXrmrQuyZ57xy+yaZmTpmLj
yFnHYZX/pQ2pSj41p4nS1joBmTaVOQ==
=XHt+
-----END PGP SIGNATURE-----

--Sig_/ydAB_847pdF8mWcT_YXzIYL--

