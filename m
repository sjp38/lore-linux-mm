Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8DEFC5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 08:30:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 847FB2189E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 08:30:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="f1CUiiw7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 847FB2189E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17EA26B0003; Wed,  3 Jul 2019 04:30:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 109958E0003; Wed,  3 Jul 2019 04:30:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEAC88E0001; Wed,  3 Jul 2019 04:30:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id AF6766B0003
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 04:30:58 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a20so1043065pfn.19
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 01:30:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=w/NMTjYP0NqrDh4h+dZJ2OQTmVYypUGwHR6kcahNuSc=;
        b=Xntuy8FyNvJnNcPhYs9Npd7VvniaYxD2J+Ojc18Aa9Gl3vNa0WNKzJspCI55LdkhkH
         C1R+6NTQr2sF2OOpAnSnG89Duog98AuAvzx++D3cuDalSC6D2ZemaFQUfH3Y7KwxmLDz
         pHbYqlvarB8iJ+44kvEEd1C4LmHFPcvNXcGhMBhskvGb+CYqtAM1JhitRLxFZTK7yxz3
         N6hm2pqh8ZtCSZTtfOINePhn3AkehpRRr1ErlnQDu1ibZuZQPy63UOmJoEbaGb40T05u
         pRUNUqLMoKgtENAiqo5zkYsY9n00hTBQBnYj+xxop237rp+r6B1/r4NhDc13HQdgWAui
         3p+g==
X-Gm-Message-State: APjAAAWb+PAWFFdrsmPD15y9H0nqtAGEhLbZtpLnMqiWl7qf731i2XL2
	Wk6XZ4XA/W+bMDl8cVCW53VG51PatzAgW9HHrCE7z2IfCCLzIl+jOm95DRwTYfsw9r56PNBn85Q
	NKtntiJwb1leuz8f/Bmk86bgRgccJbTBOiyZZ+eLSU7u+mR//JO+T7rxXT8l+9bIcvQ==
X-Received: by 2002:a63:52:: with SMTP id 79mr35312473pga.381.1562142657269;
        Wed, 03 Jul 2019 01:30:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGkd8siLTgGNCCmm9TZDh+aZFbxqVJJJbe2riBJifsrjwdbf0LYu7tPErZ0T9BIVEYVaQf
X-Received: by 2002:a63:52:: with SMTP id 79mr35312420pga.381.1562142656551;
        Wed, 03 Jul 2019 01:30:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562142656; cv=none;
        d=google.com; s=arc-20160816;
        b=P0UQ6rJDS+z9sVMijisjmfKNuVuHBBwBxrBCFUVelcZBE5zDLSkc1L9eaJnzhriCA8
         yT3P7FZa9IcAXmaAJaRe+w28JY952e8FeXkwWAtmOkEauJHuZUUWxi3sdwDM0dYpRz8r
         F+ajeMQa9HCtfefUSOa7AK9+J6ZA+GyHXT911vQEmJC4KOZYHgRNYWow3+7TdWt4EUp1
         GO6U6NbwsIGjX7y1wIvWRBgyGl5SFvPAbsnCWjFwpmWCDS8R7e6MJE9AefpKytgjMRl6
         Aywe+2nWmBKhJuTXaVwPgUp2mTMJC/h3fls3GY5oUyLXLkYyD8IT1pvioR+pqRLfotRe
         a3Lw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=w/NMTjYP0NqrDh4h+dZJ2OQTmVYypUGwHR6kcahNuSc=;
        b=Oz7BjDdPBN+Rfa3dQz0pbo7e94b5ZzdoE9CSlae9tj9MC2MNbqYbwXwy0GdgX7JAM1
         xdMmWmHEGDJ13B8atw9qMKMg4lz8ZkvkjEuxpItla+rhaQ8COOsdYhN1KxfDhXaw1l8K
         iUrsC09FQaIaO8IN7reKwtcIorODbvelY5flmrnMHLzPcFUZCvUyTBhvwJ6grXbI9hKR
         V5DcoK57c0zOcUEzlYpLF2evI9teG+jzA70mLxMSRhcFSWEwuNMbOofytgJqjDjdIcMG
         5hFhtwMZ0LQUS2sSX0WnCVlvvib7nhO3a1We0cftxA97OfwlEzvTIdnQL3hMEyVrI4yP
         Gt8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=f1CUiiw7;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (bilbo.ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id z3si1404690pju.48.2019.07.03.01.30.55
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 03 Jul 2019 01:30:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=f1CUiiw7;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45dvSp4Mj1z9s4V;
	Wed,  3 Jul 2019 18:30:50 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1562142652;
	bh=WeDiAfo0BQ+r8aIcvSG76itffid/LwqyDD7tDwMg6TA=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=f1CUiiw7jQq2DogS1vZBh3MRXdrIsoWe04ZN7W7mCsUhkCmk8RROc1M+aD+eA0Ibp
	 ccpT/GjA1MTTwMg74R5TdnSi1OWrOzceLhDXgRbtMdJW9J36lx0FaJMhvzt8591q3k
	 6ztNxl504AMqhXpRvHvBsfzfPaupMvofwWrz3GuJxOqdcJpH5s1z1+CzyPQCdUDqZn
	 V4nKr0+m6a+gJxdte96grocHNjXgmYKPKDTokqAwqdRJcmaapgShuWnii77IG6jerW
	 fsWSnNj/dVE2wvDEaq0PF2QbPLJ8rqWZ6NlJNlWUgXyTZcY3MRCtDqomqcn/2fmo1O
	 /r8b7GMDMdGWw==
Date: Wed, 3 Jul 2019 18:30:36 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>, "Yang, Philip"
 <Philip.Yang@amd.com>, Jason Gunthorpe <jgg@mellanox.com>, Dave Airlie
 <airlied@linux.ie>, "Deucher, Alexander" <Alexander.Deucher@amd.com>
Subject: Re: [PATCH 1/1] drm/amdgpu: adopt to hmm_range_register API change
Message-ID: <20190703183036.09032d12@canb.auug.org.au>
In-Reply-To: <20190703145443.2ea425c8@canb.auug.org.au>
References: <20190703015442.11974-1-Felix.Kuehling@amd.com>
	<20190703145443.2ea425c8@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/e5qSB1VclK5wgme0230sZ_1"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/e5qSB1VclK5wgme0230sZ_1
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

On Wed, 3 Jul 2019 14:54:43 +1000 Stephen Rothwell <sfr@canb.auug.org.au> w=
rote:
>
> On Wed, 3 Jul 2019 01:55:08 +0000 "Kuehling, Felix" <Felix.Kuehling@amd.c=
om> wrote:
> >
> > From: Philip Yang <Philip.Yang@amd.com>
> >=20
> > In order to pass mirror instead of mm to hmm_range_register, we need
> > pass bo instead of ttm to amdgpu_ttm_tt_get_user_pages because mirror
> > is part of amdgpu_mn structure, which is accessible from bo.
> >=20
> > Signed-off-by: Philip Yang <Philip.Yang@amd.com>
> > Reviewed-by: Felix Kuehling <Felix.Kuehling@amd.com>
> > Signed-off-by: Felix Kuehling <Felix.Kuehling@amd.com>
> > CC: Stephen Rothwell <sfr@canb.auug.org.au>
> > CC: Jason Gunthorpe <jgg@mellanox.com>
> > CC: Dave Airlie <airlied@linux.ie>
> > CC: Alex Deucher <alexander.deucher@amd.com>
> > ---
> >  drivers/gpu/drm/Kconfig                          |  1 -
> >  drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c |  5 ++---
> >  drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c           |  2 +-
> >  drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c          |  3 +--
> >  drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c           |  8 ++++++++
> >  drivers/gpu/drm/amd/amdgpu/amdgpu_mn.h           |  5 +++++
> >  drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c          | 12 ++++++++++--
> >  drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h          |  5 +++--
> >  8 files changed, 30 insertions(+), 11 deletions(-) =20
>=20
> I will apply this to the hmm tree merge today to see how it goes.

This (at least) build for me.

--=20
Cheers,
Stephen Rothwell

--Sig_/e5qSB1VclK5wgme0230sZ_1
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl0cZ6wACgkQAVBC80lX
0GwxCAgAm5w3v6m4QhQxoWWwyh1Z0i31z/xsiFrk/0NFrUOK/amLgWJZSB6ROTmT
7ySOpcelOGLsmu7jt9EFVgk7Mio1uPAWYIErYOOp0+PlhloVGbS+lNH+mVNMNuNV
xh0mtxzfkltkBEaKMBNRU0V/GIu9s/BAQPVgy6m1g3Nc1a2iOKaojrYdgcjO5stD
jQ5J9Nw3gvx9qJmGD3vO7f9aIEOc8l+oO9thr2E3nM0f0v0OVs3oVS0yjMRnidHJ
Gu1z/04ZuG477a1nSPU6NrzNQFxrBhz5zO0OIIH2egAwJXh7DzHOIOnHFqkFPdhO
o0IPmHtn4WsoNYDaDRuHEWI2ae0V9g==
=UeUM
-----END PGP SIGNATURE-----

--Sig_/e5qSB1VclK5wgme0230sZ_1--

