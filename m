Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0C3CC5B57D
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 03:14:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7492B216E3
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 03:14:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="GhC55MLd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7492B216E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2279D8E0003; Thu,  4 Jul 2019 23:14:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D86E8E0001; Thu,  4 Jul 2019 23:14:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0ED848E0003; Thu,  4 Jul 2019 23:14:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D06BE8E0001
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 23:14:41 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id k9so328907pls.13
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 20:14:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=Ihboi/Pm6sxP7OYYg927IrvIE8wkoFaaYfvB9wnilRM=;
        b=fl+O71yBgFwjgzqmIP6EerqQNh0wxg/wJbO+qJ3jdhmolTbvRMmH2pi/PZTM6AasD5
         oQJAYLjiY2cWkdp5iOrlobNkL8Gx3zfYB18AHAfC2jtWjSPLpWbg9cHxGdv8H2ZPOI/B
         mITsYrhCmBFTNwSMW3Uv7dn25oB2UGtIL3KdK3pAO9sk7MhqBvHaoH64JBVpTBdsYrzo
         2ogVsvZZGI63gqk5wO9dnNnjaZC3Tc3NdBZt/Fjb1WMglsp54b6fYtxZ9jARwvsnPiRF
         gMvM40Nb0YNcrwwNg4yfpOSqxekvN8+Zg9hd+yi3/sib+LaHkI7C3cMLKExazTmZ4JLe
         byAw==
X-Gm-Message-State: APjAAAW1zG/4K3mi5Pf0GAwK4fsLoF0O+wEJFhCApoG72wzN5yaca7Bh
	KPTjklOe2O7XlVuzf9gkitpzHjYErIgYMgEZFIZ43W/BTCkYJfb89uHyyP5p2QPND2vL/791Laj
	lpPxs/NkM1WxQzrVp7VCh2Ge3Tmk/PxJ8WZjySiQhk7GI3ZepgR67kaVqDgeSO3KI0g==
X-Received: by 2002:a63:5402:: with SMTP id i2mr2009991pgb.414.1562296481368;
        Thu, 04 Jul 2019 20:14:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0wkfqPWayF7cse/YLtKHxW7n0vDYt5b+Zri5AGEnM2ftD8DVv7/+4SKJshKgl1hlyf6v+
X-Received: by 2002:a63:5402:: with SMTP id i2mr2009936pgb.414.1562296480686;
        Thu, 04 Jul 2019 20:14:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562296480; cv=none;
        d=google.com; s=arc-20160816;
        b=v0BMzloCnoZdPeR2dSImMNNeQ1gFFcrouWv/bCly03/VlzPYG5Mk68fCwIK/hV7b1m
         bCQr78EqHIBW4DIyV8PuMI+yvdWJLBk1ENh++n8HwA54hQDueqr0gIjJhIKyOBGm92gi
         PiIKppAKIQhu7Fmqkm/KYs20veoYlUYbPyty5RAOP7pPeJPge2+6lu29FqK4wItx8eSD
         VFb97AQhq2U3e4WeqV0vEzYiGFUk91A753Zu9k/GKhPmQL0ZfzSJOxtSqNICRiqtqps6
         8g2kqodNiC7VJtSrT52kmi4bctHz+A3tnkst5U/MJl1kL2eliGM4IFbrmZD1b0wdEFCB
         Zl9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=Ihboi/Pm6sxP7OYYg927IrvIE8wkoFaaYfvB9wnilRM=;
        b=n1HYgB3zZ9FGEuDP3SqHLJgTsP71HBE5gdnyXStwNgOO6a9XNOwuZrulFOjFyWCZD4
         VyZJYJ58ajRw8oHlbdGkQE9Cw2pCHysIzvWf8bPKthD1wXWKE1upN2+Q7WorMdDYiZSG
         A4pQ0tXAHgzrP3m5KiRpspZ+EQ2t20NaCLh6TthwwqjxuZqSVQT/RvX2KtjN8/vVT2WM
         QkJIy9gbG2pDj65fkKPM/s7HkIBxih0UCASYQ0klDn7qdIrwXzwYpB9ByqGwUJVr2FJY
         IGj7ueXXwdJouq7CTxlam72e1kGT/OTkN8W52jHvy3dCkpRR+J44Ue1epp1DVwj0NsO8
         gSYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=GhC55MLd;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (bilbo.ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id w2si1062831plq.414.2019.07.04.20.14.40
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 04 Jul 2019 20:14:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=GhC55MLd;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45g0M01Bpkz9sCJ;
	Fri,  5 Jul 2019 13:14:36 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1562296478;
	bh=9605ZP4bn3MDqq1dxNaUUk8pwn4UP4BwvE48o+dZvLc=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=GhC55MLdQI6+V6yk9r3D9bck989EmS1gkht04wQVl4SzEPMOQYHM/P5vA63uV7sqg
	 FN+idxpEy1o7z/fQ33UoAB7/CqSXXme3SgQrm0EIAYsAVnWT4VXNRh+aCNM7xZiwOh
	 wIextEEub2oHRaqXTc+x6FzGXhtvwK3ly1PNvJurf4J43hMZJ37/caL8YSp5W8PNTI
	 EEJOFnmWsUbaWQ+0RRkYBowGKqsPL9Uy3JWkfYLYXGRfv7NIWOTi+s2IrIuSWkiNkr
	 P5fYU/z0+rTc5hjbZExP4Q+2OsKXy8bD3CoYWNRAwIR6BXe6faQASmYntNmoEtbEeX
	 XJ1xe+wWT0B2Q==
Date: Fri, 5 Jul 2019 13:14:35 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, Andrew Morton
 <akpm@linux-foundation.org>, Mark Brown <broonie@kernel.org>,
 linux-fsdevel@vger.kernel.org, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux-Next Mailing List
 <linux-next@vger.kernel.org>, mhocko@suse.cz, mm-commits@vger.kernel.org,
 Michal Wajdeczko <michal.wajdeczko@intel.com>, Daniel Vetter
 <daniel.vetter@ffwll.ch>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas
 Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi
 <rodrigo.vivi@intel.com>, Intel Graphics <intel-gfx@lists.freedesktop.org>,
 DRI <dri-devel@lists.freedesktop.org>, Chris Wilson
 <chris@chris-wilson.co.uk>
Subject: Re: mmotm 2019-07-04-15-01 uploaded (gpu/drm/i915/oa/)
Message-ID: <20190705131435.58c2be19@canb.auug.org.au>
In-Reply-To: <CAK7LNAQc1xYoet1o8HJVGKuonUV40MZGpK7eHLyUmqet50djLw@mail.gmail.com>
References: <20190704220152.1bF4q6uyw%akpm@linux-foundation.org>
	<80bf2204-558a-6d3f-c493-bf17b891fc8a@infradead.org>
	<CAK7LNAQc1xYoet1o8HJVGKuonUV40MZGpK7eHLyUmqet50djLw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/cNeLSVReMpluqwcRRAFLlp8"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/cNeLSVReMpluqwcRRAFLlp8
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Masahiro,

On Fri, 5 Jul 2019 12:05:49 +0900 Masahiro Yamada <yamada.masahiro@socionex=
t.com> wrote:
>
> On Fri, Jul 5, 2019 at 10:09 AM Randy Dunlap <rdunlap@infradead.org> wrot=
e:
> >
> > I get a lot of these but don't see/know what causes them:
> >
> > ../scripts/Makefile.build:42: ../drivers/gpu/drm/i915/oa/Makefile: No s=
uch file or directory
> > make[6]: *** No rule to make target '../drivers/gpu/drm/i915/oa/Makefil=
e'.  Stop.
> > ../scripts/Makefile.build:498: recipe for target 'drivers/gpu/drm/i915/=
oa' failed
> > make[5]: *** [drivers/gpu/drm/i915/oa] Error 2
> > ../scripts/Makefile.build:498: recipe for target 'drivers/gpu/drm/i915'=
 failed
> > =20
>=20
> I checked next-20190704 tag.
>=20
> I see the empty file
> drivers/gpu/drm/i915/oa/Makefile
>=20
> Did someone delete it?

Commit

  5ed7a0cf3394 ("drm/i915: Move OA files to separate folder")

from the drm-intel tree seems to have created it as an empty file.

--=20
Cheers,
Stephen Rothwell

--Sig_/cNeLSVReMpluqwcRRAFLlp8
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl0ewJsACgkQAVBC80lX
0GzYcQf+OqWJhVTJLbJLiBqRgQanYK7S/8DokAFj+dkgb9foQZIjp8ln1by3QDXg
gGAcxB9xEuIW1oxR6QUXlrWJtEJuC55Ka6LHo9DzUxF1ul9WgHLnWftKegzKG6+d
5mcol7HG8rVryx7FeEErXxZmubGS/Ws/1kh8KuZriCw2bgyZFp4Y73gqwrfGi7Pl
+PDWw1W9dnZj+mrwFMFGOA7CTKFab2paP+YOXTjrdjc0QxzaCNZjBpjT1Mo0nNbm
IJQwtCSQWTmLwfK+GEuxAQO3Z37B92G9ckWHqysmubvaWpYop3V2QUUN0PKfPdgN
s/qoynBRgRZo5pZ+E+9pICS8pwhjSQ==
=Z/Nz
-----END PGP SIGNATURE-----

--Sig_/cNeLSVReMpluqwcRRAFLlp8--

