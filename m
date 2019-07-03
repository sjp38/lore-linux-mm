Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30346C5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 04:54:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE26420989
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 04:54:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="aRxq9Doh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE26420989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A5286B0003; Wed,  3 Jul 2019 00:54:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 657638E0003; Wed,  3 Jul 2019 00:54:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 546A88E0001; Wed,  3 Jul 2019 00:54:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1ADFC6B0003
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 00:54:50 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id c18so845409pgk.2
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 21:54:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=BYSo6/sDjEOEO1NrZdVIVjkyKXcf8c2NUeP3b75fnK4=;
        b=BT4gLbdFCaw20Bavg2R7ZCrgbaJA2dNF9wBUiNCQ0xvZZtpTdkewc5vk7vIdZWEUPE
         d0p2w/4e/x2ZF2B7lMVOw0M7vb1lHvg3vB5b+8Pmdfb/RiKHi5YugqJhLa9Pp4rWD60z
         OWFRonI0YPnJR+lL66X0Eu3fxQz7mqEeRkIQ6CRhQEnTWuNQBS5s+PfvsKMi9tBlpisG
         Seh18QDbId453LOOuXkwiZL/kbxrwBZJT4LJto0/rwvqdrl1xn5DVfNibrN8riOMDrhS
         +tY86UMglDYyF2hF1WlORRYKjnT5oGg0K5zKSiwM8W3pi98LJDD26H5rVdPaQnpwGlaN
         ZBTg==
X-Gm-Message-State: APjAAAXikab7g7rXy8ifehCkcSugfo70+Yi0TliVM1JAf0mX9Rz6oxwV
	gPSugbrSg3D/+8KSPgmDvnwTdhj5Y0QtpKmsfYZqiB/UJBp4zJiq+eh2hBCgd4oaOMynVhOpfGE
	kKkbdog1Mk1tzHb9BzYfSntxNbEdKk7eyl46ZjXOCK3ZP9hx6Z4hGzs8u7w6CygkiPw==
X-Received: by 2002:a17:902:9f93:: with SMTP id g19mr39291014plq.223.1562129689703;
        Tue, 02 Jul 2019 21:54:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjjM/SguaofhcbxBzrvefe+TTo9Tk6e241VByVaYpx2+l0+VgR5jcaed0JlmCI4yf83qW6
X-Received: by 2002:a17:902:9f93:: with SMTP id g19mr39290959plq.223.1562129688916;
        Tue, 02 Jul 2019 21:54:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562129688; cv=none;
        d=google.com; s=arc-20160816;
        b=g4nSSxB8QQfaid7+C5M4LVYoL3Dy64QZG8L93Yd/mvtQ493S38JmwdQYYdX6WkSbwB
         Fp8W6haR4cnSEzompJTvDawLQwGdRxivd/KUAKdRtMjaQCcjzC8jV9qxNYyozqyPoAPq
         BHzaG5YjPOPaeITcYH0kkOmtucc0cPsVOKyBQJ2DYHRpel9obUgUrYzVkclFTX1x7nlU
         MLUl0Jkyi2BspsaRbqd3F5UiyCfUj4N45vn5rrdmIhDneBVuy54nVP6H1l4kvNkVhVSJ
         DDX37J3NUEt4tQ//Gr9H8euZwkH3WmKlYHjrTN4xlCB59lAfKQ9428rN5juwQWhEpe65
         aeNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=BYSo6/sDjEOEO1NrZdVIVjkyKXcf8c2NUeP3b75fnK4=;
        b=waUacJTOefY++dy3CF8HRyeBersKkAyfoGpQ8T1GEYZZsxAtDClN0FBoi6bfTt2PT5
         FExFPh22nOuU0KlEKjOC9fUXzUhaIfGGfoJ8YMrN5zQwXTrQu3TGF4R3YgkOtbQtr6s7
         i+gcqZnuyTZPc/gOsUesOau9K1zKQGguBTD3Wo4dBXA3s6vUMalas5qnPSSNfywogPEU
         zXLWCAKavEx15QGVDkikenJBaKAER/kjk6nkJvnhHY0MyS8Z15KyLTkJktPF0vs8zVbN
         dteoGSfod58tJQtwOkAQMocDJKiWQM9nifluIfL3oEz8JWWzqPHz+sxlLwxJA9Fqyvfd
         lSSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=aRxq9Doh;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (bilbo.ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id w21si1106855plq.91.2019.07.02.21.54.48
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 02 Jul 2019 21:54:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=aRxq9Doh;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45dpgS56gpz9s00;
	Wed,  3 Jul 2019 14:54:44 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1562129686;
	bh=Os6ca0ppiue1tcJbzi1HamLBeaX/2jBV/TB62bRk6U4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=aRxq9Doh85BZvVKPihqH3aBGTVX7KGlQRi8G4uNmaeMld3O0agP4jgFXphQxOMcTR
	 6KaMO5fHrqtHdgJRoha7Uk5u1eq4cOYKaxF0Ue4k5qXMEADMeBof0Fw9VlQADjciAB
	 ZG5zNl3+nVSx8/HQV8KhIHi2IgUNLmkc+3G2JA4J0/+XkE7UMOQHR+lSUUkL8WlccD
	 Ng7TVkmOn6VoBmmPVdKpA3+dHFYa184VTaCLx3ULJ+NbwGbRSQQeREx7etHrVJZaR+
	 HXXAgjhK+hAQ0zV16k4i2vdwhN06ydk6H13JMo0JVb6pic8IzcZV8xkoGktIr/Gqmj
	 KdxDV1upSOOHw==
Date: Wed, 3 Jul 2019 14:54:43 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>, "Yang, Philip"
 <Philip.Yang@amd.com>, Jason Gunthorpe <jgg@mellanox.com>, Dave Airlie
 <airlied@linux.ie>, "Deucher, Alexander" <Alexander.Deucher@amd.com>
Subject: Re: [PATCH 1/1] drm/amdgpu: adopt to hmm_range_register API change
Message-ID: <20190703145443.2ea425c8@canb.auug.org.au>
In-Reply-To: <20190703015442.11974-1-Felix.Kuehling@amd.com>
References: <20190703015442.11974-1-Felix.Kuehling@amd.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/1ISLS9cnW4KdQ3cHKyFA5Eq"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/1ISLS9cnW4KdQ3cHKyFA5Eq
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

On Wed, 3 Jul 2019 01:55:08 +0000 "Kuehling, Felix" <Felix.Kuehling@amd.com=
> wrote:
>
> From: Philip Yang <Philip.Yang@amd.com>
>=20
> In order to pass mirror instead of mm to hmm_range_register, we need
> pass bo instead of ttm to amdgpu_ttm_tt_get_user_pages because mirror
> is part of amdgpu_mn structure, which is accessible from bo.
>=20
> Signed-off-by: Philip Yang <Philip.Yang@amd.com>
> Reviewed-by: Felix Kuehling <Felix.Kuehling@amd.com>
> Signed-off-by: Felix Kuehling <Felix.Kuehling@amd.com>
> CC: Stephen Rothwell <sfr@canb.auug.org.au>
> CC: Jason Gunthorpe <jgg@mellanox.com>
> CC: Dave Airlie <airlied@linux.ie>
> CC: Alex Deucher <alexander.deucher@amd.com>
> ---
>  drivers/gpu/drm/Kconfig                          |  1 -
>  drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c |  5 ++---
>  drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c           |  2 +-
>  drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c          |  3 +--
>  drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c           |  8 ++++++++
>  drivers/gpu/drm/amd/amdgpu/amdgpu_mn.h           |  5 +++++
>  drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c          | 12 ++++++++++--
>  drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h          |  5 +++--
>  8 files changed, 30 insertions(+), 11 deletions(-)

I will apply this to the hmm tree merge today to see how it goes.

--=20
Cheers,
Stephen Rothwell

--Sig_/1ISLS9cnW4KdQ3cHKyFA5Eq
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl0cNRMACgkQAVBC80lX
0GxR+wf/XafVose6tyhCcoiEqvhT+ysgJzCZmqFzBVqIISTf31GzmmteRaShVfAv
qAQZpczlWvcJ8HWZIlJrNYQXlSgrP7s1Mu57oPZjUHoYwWGLKegjhVkUv8MJxm70
uD8kYtHsy7k9oK5aC+dVhcXgcVxIjFootGahidgHw0JLGTD9LrVKs5giMo/hHpRU
/VvFzLeCHKbY3VqEi4/brg6vMkx5M1gHf5oWz/S8i4XxNhKHd7X/5TGSk/IqEM3n
yG9QcUb/XHadm0DAcIYokCKQArVoB0uTo8FI23rufoP5v4imBIQVtXequtMKwA6w
2xXj+tSEXp9Ha/hkOJwI96/D/6BNHw==
=TZJq
-----END PGP SIGNATURE-----

--Sig_/1ISLS9cnW4KdQ3cHKyFA5Eq--

