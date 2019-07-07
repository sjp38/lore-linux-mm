Return-Path: <SRS0=llCs=VE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21DE7C0650E
	for <linux-mm@archiver.kernel.org>; Sun,  7 Jul 2019 23:30:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B87C220665
	for <linux-mm@archiver.kernel.org>; Sun,  7 Jul 2019 23:30:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="qrXjpzMm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B87C220665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 236138E0006; Sun,  7 Jul 2019 19:30:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E77C8E0001; Sun,  7 Jul 2019 19:30:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B0248E0006; Sun,  7 Jul 2019 19:30:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C6CEF8E0001
	for <linux-mm@kvack.org>; Sun,  7 Jul 2019 19:30:40 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 6so9176364pfz.10
        for <linux-mm@kvack.org>; Sun, 07 Jul 2019 16:30:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=g8MaXsvvJlhkqk2lWsesnClAzBItmHBX1Fhhj3eTigo=;
        b=qnTZEAz4w7G61c+OhSrRSkcF9wf9iHG73SsJnYUsK8EUq9l/Cjyqzseho7AEjvrVXh
         z28av4Sx8ngwsNS2qxg6CFF0uZS/v8E6WW7k12mvWPbocEQZvSq7toTpRmKsXcs5+h4C
         ER6TkXDipcxXc2duTI1PYpatITm5fyVk1R/so2ROGLqEkybmBEFdbGTy3t2BuBq1bwdd
         EbJMsODoPeUwk2z16xHK+4n0kRiWKd3uIstMZWVO5DwInLgSTzDe4nkvXPpNE/SrpY16
         g5YZhrW+DQm6tsuioAC5fil3shkVcQ/RI0iKGy7DzRMgNjpFU2ZPztksI1MH0CHBflTh
         R71A==
X-Gm-Message-State: APjAAAWZNAYVr9yMRpTNPdmbQgqBBLSM1hGjad2SvRXC8QBr/5GgyNKU
	2ngdp/erg+xRr9NAbywm9eDOsLn/geT39RbNxgqDzZbEzKlFhN1ATwFrKWqu9qmf4bNil64DdV5
	WMAp8nqkKGhf8Zf6dzIVv1Z5fbMhID46LGBnd59pJwrH2+/JOFE7PS1TA9xNlHwLt1g==
X-Received: by 2002:a17:902:be12:: with SMTP id r18mr19534565pls.341.1562542240264;
        Sun, 07 Jul 2019 16:30:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVSJWETijGhxY4ohs23js19wmWIy1KsXXAr8y4Riz/ks2ZuDJeHcgLklGBi9xrKSIUVNfD
X-Received: by 2002:a17:902:be12:: with SMTP id r18mr19534497pls.341.1562542239394;
        Sun, 07 Jul 2019 16:30:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562542239; cv=none;
        d=google.com; s=arc-20160816;
        b=pOPgK17Cw6mmrx/vc2t98JVSjMFYIbXTvm6L5G45AMO5JSPKlP6bexv94Czjs0HJu0
         znNY2UOIuon5th8jtHzaaNVUaA1wbGNKGQFVOpVZPB8X+zu7q+NB6L3dASpL8FgHJX35
         pJedpnrWDpRziBB005Fwiwcr5skgBwD9CZ+HjC/IxlCh0C6tFKwoIqqY1oDIx7g6yLFc
         tTF05GVxMut+IdOrXqQPAVfzy54fVwIzAP+3rfWl1t+QXr2pGKax8fFaE7jOVYqqCgxf
         SKhEfbDuVxD6DZy0sLgPWKZNXY6WAlooRRl17jTBin6i/CU+OiECSeN5AmvcisD9YIRw
         3OsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=g8MaXsvvJlhkqk2lWsesnClAzBItmHBX1Fhhj3eTigo=;
        b=nzUQCUzcOgoVZspU6W8poGHEfidiGo9zCOVAdglG8yt/Ug5WDR9xl5cRyyT8STPg4i
         jieiHLg2RsU5ziO/zXy/5cFJEXqTys/06K9UgYa+dSxxH/8Pn/3SpB3GSsQp8/i5x0Kw
         6inhBpHnAjVfWcpLN0BTIGq96r5pBsQOWN7yX6H9QuWAel48aXvTdVmd+sgPP/wfdc+R
         YK0bScs+Szx38VJU+5lJ4Wzjo0SSiZ6L450t3sThzgIQUkUT5ngXHPFLDrp1MIRyeeOv
         ac63yVE5cFWXStdgIGF+QGQ0aahYyInvNCO92bL3wAPvYFADuMIv79fQTcToF0hBFDis
         lrIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=qrXjpzMm;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (bilbo.ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id w15si15147036ply.127.2019.07.07.16.30.38
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 07 Jul 2019 16:30:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=qrXjpzMm;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45hlF41wvCz9sNk;
	Mon,  8 Jul 2019 09:30:32 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1562542234;
	bh=b3Cy3L6uJ1zllsblKuLVoOFBbe1oTg28owraNeOAFTI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=qrXjpzMmuXVtUxH4xy+PPMxT/OcN8OknkLLRX0H+LcAZy1yOS5HQ0zCD4gMJPGwVz
	 7LCjzhUowqxvuoFh6OoOf6ff6xadM+XO5FOGBpF2a3F3WPxydd/BedUBRqWhpw0zJJ
	 8gyJT/VESyiyxAf+t63leV4ug1ZQbhk04vv6EcRtkV3tqGW8m8SthxBSGpuZ/qa9EE
	 KMRFiSVV7oqjaQ6BltWMKbUtxKcFrpe1tRvRwbZdeURJFqz/4zMGrK1X0qprNq07yj
	 szeLCMuESKjt8w0urx+SpnaLi40NLXtmCG+bYQlNGz+fQ/sJz8khOUINO2B0rh58te
	 vOrJJGr9+SAHg==
Date: Mon, 8 Jul 2019 09:30:20 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Alex Deucher <alexdeucher@gmail.com>
Cc: "Kuehling, Felix" <Felix.Kuehling@amd.com>, Jason Gunthorpe
 <jgg@mellanox.com>, "Yang, Philip" <Philip.Yang@amd.com>, Dave Airlie
 <airlied@linux.ie>, "dri-devel@lists.freedesktop.org"
 <dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org"
 <linux-mm@kvack.org>, "linux-next@vger.kernel.org"
 <linux-next@vger.kernel.org>, "Deucher, Alexander"
 <Alexander.Deucher@amd.com>
Subject: Re: [PATCH 1/1] drm/amdgpu: adopt to hmm_range_register API change
Message-ID: <20190708093020.676f5b3f@canb.auug.org.au>
In-Reply-To: <CADnq5_M0GREGG73wiu3eb=E+G2iTRmjXELh7m69BRJfVNEiHtw@mail.gmail.com>
References: <20190703015442.11974-1-Felix.Kuehling@amd.com>
	<20190703141001.GH18688@mellanox.com>
	<a9764210-9401-471b-96a7-b93606008d07@amd.com>
	<CADnq5_M0GREGG73wiu3eb=E+G2iTRmjXELh7m69BRJfVNEiHtw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/n1sGdhtFox.8qpMNicerEzu"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/n1sGdhtFox.8qpMNicerEzu
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

On Wed, 3 Jul 2019 17:09:16 -0400 Alex Deucher <alexdeucher@gmail.com> wrot=
e:
>
> On Wed, Jul 3, 2019 at 5:03 PM Kuehling, Felix <Felix.Kuehling@amd.com> w=
rote:
> >
> > On 2019-07-03 10:10 a.m., Jason Gunthorpe wrote: =20
> > > On Wed, Jul 03, 2019 at 01:55:08AM +0000, Kuehling, Felix wrote: =20
> > >> From: Philip Yang <Philip.Yang@amd.com>
> > >>
> > >> In order to pass mirror instead of mm to hmm_range_register, we need
> > >> pass bo instead of ttm to amdgpu_ttm_tt_get_user_pages because mirror
> > >> is part of amdgpu_mn structure, which is accessible from bo.
> > >>
> > >> Signed-off-by: Philip Yang <Philip.Yang@amd.com>
> > >> Reviewed-by: Felix Kuehling <Felix.Kuehling@amd.com>
> > >> Signed-off-by: Felix Kuehling <Felix.Kuehling@amd.com>
> > >> CC: Stephen Rothwell <sfr@canb.auug.org.au>
> > >> CC: Jason Gunthorpe <jgg@mellanox.com>
> > >> CC: Dave Airlie <airlied@linux.ie>
> > >> CC: Alex Deucher <alexander.deucher@amd.com>
> > >> ---
> > >>   drivers/gpu/drm/Kconfig                          |  1 -
> > >>   drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c |  5 ++---
> > >>   drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c           |  2 +-
> > >>   drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c          |  3 +--
> > >>   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c           |  8 ++++++++
> > >>   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.h           |  5 +++++
> > >>   drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c          | 12 ++++++++++--
> > >>   drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h          |  5 +++--
> > >>   8 files changed, 30 insertions(+), 11 deletions(-) =20
> > > This is too big to use as a conflict resolution, what you could do is
> > > apply the majority of the patch on top of your tree as-is (ie keep
> > > using the old hmm_range_register), then the conflict resolution for
> > > the updated AMD GPU tree can be a simple one line change:
> > >
> > >   -   hmm_range_register(range, mm, start,
> > >   +   hmm_range_register(range, mirror, start,
> > >                          start + ttm->num_pages * PAGE_SIZE, PAGE_SHI=
FT);
> > >
> > > Which is trivial for everone to deal with, and solves the problem. =20
> >
> > Good idea.

With the changes added to the amdgpu tree over the weekend, I will
apply the following merge fix patch to the hmm merge today:

From: Philip Yang <Philip.Yang@amd.com>
Sibject: drm/amdgpu: adopt to hmm_range_register API change

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/=
amdgpu/amdgpu_ttm.c
@@ -783,7 +783,7 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, st=
ruct page **pages)
 				0 : range->flags[HMM_PFN_WRITE];
 	range->pfn_flags_mask =3D 0;
 	range->pfns =3D pfns;
-	hmm_range_register(range, mm, start,
+	hmm_range_register(range, mirror, start,
 			   start + ttm->num_pages * PAGE_SIZE, PAGE_SHIFT);
=20
 retry:

And someone just needs to make sure Linus is aware of this needed merge fix.
--=20
Cheers,
Stephen Rothwell

--Sig_/n1sGdhtFox.8qpMNicerEzu
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl0igIwACgkQAVBC80lX
0GyMGwf9EHaqFsgZMnIUpi3rDZiJtUaKYpZhMRcEnEUKTBt9R7GcNMCmg+yWNWQm
ywXAzxy+94GmfnusEKWBCpCTTO9IyjctxH5P4i/myGwF867vEhGMXD2fg5ly85hr
oyQ60dHXBwNKwJlfoNfgC7XJ/sYSVrtngHZ+Up6SkAPlMccSJ+V4zQLi5qI8CjOz
Nqt8Eh+OHyjqZf9UdzFWAtHNO4rbIutkbdkh4YVD6V3USbcU2wJ1/8dmR8xIlvXL
BVWfIWkeX0lN+ASoK1Y3GL5RJB9ge5nRvmaRC5Tmq3dF9au7ihOveKfdqy+HdvWQ
cPEh8VGzNdBfQ1l0rDzj7y04IDNndg==
=yA1W
-----END PGP SIGNATURE-----

--Sig_/n1sGdhtFox.8qpMNicerEzu--

