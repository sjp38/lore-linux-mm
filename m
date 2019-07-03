Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7BB1C5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 21:32:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52A9221882
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 21:32:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="aB7R7tl9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52A9221882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD0848E0024; Wed,  3 Jul 2019 17:32:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7F418E0019; Wed,  3 Jul 2019 17:32:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6D998E0024; Wed,  3 Jul 2019 17:32:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 71B498E0019
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 17:32:29 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i26so2230226pfo.22
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 14:32:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=hENv4oLRjocoIypscm9ON5MvJW1r155BEzVd+Kx5Pzc=;
        b=mggpUkk5KgQ6xB/FuxCW+S4CdEnE0bYyUkqtT+CkRNkDLvWw6gQOrpQz9e381Qob4T
         HIecKAk8Qa8MLC13oHk4R9TV1zwvGn1nODrQvunIoO+y6MH7EjVmUJIAKTvzRUJpcTua
         9OWMbFubuQJRn7Fklehb3TH/Wr9Ox0gVWYydkUjtLVxoM7PZpXuCjsCaCFYwO1Nhwvop
         XtO7cp2b4/gTtzp1X/Xl/LX4yL8sIDxhxnJMzOLyt2qNcA4r9WYS6noiKuKxZ3sfDYz6
         f1SlSZC8Z//QJEbfx/Gd3C2ieFYu50t7g+QRP0GExUUYlSt3nTxAJCHmBaFXqzBinHVb
         a/Dw==
X-Gm-Message-State: APjAAAVcilCn/AkiyqEBd6DbDsybB47xmqEQ+sbjn/0URLzjCT4d835b
	4AowhIvV1DbG695AwGi7Zg3WSYzW033dMWREohogx1OdQ4YeUtMREv5ySuurn4ig1+IUZuVkh5y
	I8Ef7ZtvWF9gyWZ9Tg+Y2pSVcDDZV0FpTpg/cflrbrIbkZOjtHuLYAGyVcIsAJLqbLg==
X-Received: by 2002:a17:90a:1d8:: with SMTP id 24mr15504452pjd.70.1562189549025;
        Wed, 03 Jul 2019 14:32:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlmA5FHwB05uB0TVC/yMZaQ4mBiRzfmCtSNf7wIcrRdMJ68Ug6hh3QutngIhrj4J3Ahe3a
X-Received: by 2002:a17:90a:1d8:: with SMTP id 24mr15504394pjd.70.1562189548199;
        Wed, 03 Jul 2019 14:32:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562189548; cv=none;
        d=google.com; s=arc-20160816;
        b=PIfUZ4WZzTPWpoJkca04WQt2fR1b8X9CPHQ/qUz9o+HPYjame8HiHU+U5Plt2trvMg
         Dknb134RD0ondEaKPy1uWFcA82t+vrK4vn9jwWsStwVypeuUf+Fj8txL5cCVa+rx8Mqy
         FWcBVnEiMKgNdIDZCRWoMqUgUbqkaGN3HU6vrOPXOVGaycEuU/pxAQV5I5pswWZPvdDb
         OX/pJMSleBql3o0kFC6Hji9EHaObaawpzQDjbHh6of7xlwh7zqyFyxi9zN7m/fNeCkHA
         6A16kzmPEF81VBErUbjnTsjWhyHBUEf8fxCpEZzDSaSF6xJcNZp9caUD5xe1edPVOXsB
         MP3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=hENv4oLRjocoIypscm9ON5MvJW1r155BEzVd+Kx5Pzc=;
        b=n3W5Nh2+AM3LNuoC4uuv8ELrtOVrenZ7yDRnSO7THeoEFo10M6HLPBMycNNkDtg++W
         aAtrKtppLWOiA4l4+SqsZvnfNmRszxCmuaHeSaOBpHsXzkWaK2b4ZrAu0R0rKs80D92a
         tuzmGSOShMRUSUgxrPn4zWGSnkfI2gbzfh0BB4YNzOSUpzuV+XMItHrK4SC0LAbJQiQX
         NUL2uII8DdIkV53TcnH/nA3JzeDy31lesSrYSZOxELHj9jGkMUvycxgkoprBVVyR5mqL
         7EycTHsZ/ASTRLtP1CCbMp4Q5zvugrNddEtrHTnZ4q6pJFitMYxYuCvXhsII50N4Cj7v
         hkrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=aB7R7tl9;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id c3si3040127pje.1.2019.07.03.14.32.27
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 03 Jul 2019 14:32:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=aB7R7tl9;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45fDpY6pyGz9s4V;
	Thu,  4 Jul 2019 07:32:21 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1562189543;
	bh=vcfEUN/OJ3FmHGsLAuzadqK55t4/uLDhFaOEhdyst7E=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=aB7R7tl9cIWWDzrZOvEGwccHaqmKG7yk7h4eEkKNTOUnCjEK5L980pe9PmuU+9Wko
	 Mu+kpBTpaBamhVHsRgeicTgZLyRxbKBUJMi7Fo4nKqHKMxcw76rx5UdZUnX36EN5Ss
	 yErFzZZXXDAIiEi6PtvTWib03Cwz+AnnYS8dVu6IXYwtRnBVjijseJwJKcm1et5Utd
	 OV2jP9CktQlEvDJvxWz4rp7DDJdQJ9wQnkB32T8AIXRVHw6iqIubYeR6gsjjpSdD9K
	 F/KgB3PljSRgprGwdO/g0PpaCQ6phbyZRHjlO4CzSSKGwPWgrK/hG+uiPWsIjIEHHb
	 eYvRxhB9abG2w==
Date: Thu, 4 Jul 2019 07:32:14 +1000
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
Message-ID: <20190704073214.266a9c33@canb.auug.org.au>
In-Reply-To: <CADnq5_M0GREGG73wiu3eb=E+G2iTRmjXELh7m69BRJfVNEiHtw@mail.gmail.com>
References: <20190703015442.11974-1-Felix.Kuehling@amd.com>
	<20190703141001.GH18688@mellanox.com>
	<a9764210-9401-471b-96a7-b93606008d07@amd.com>
	<CADnq5_M0GREGG73wiu3eb=E+G2iTRmjXELh7m69BRJfVNEiHtw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/QCzYje/thezhTNHZAHbS5n."; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/QCzYje/thezhTNHZAHbS5n.
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Alex,

On Wed, 3 Jul 2019 17:09:16 -0400 Alex Deucher <alexdeucher@gmail.com> wrot=
e:
>
> Go ahead and respin your patch as per the suggestion above.  then I
> can apply it I can either merge hmm into amd's drm-next or we can just
> provide the conflict fix patch whichever is easier.  Which hmm branch
> is for 5.3?
> https://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git/?h=3Dhmm

Please do not merge the hmm tree into yours - especially if the
conflict comes down to just a few lines.  Linus has addressed this in
the past.  There is a possibility that he may take some objection to
the hmm tree (for example) and then your tree (and consequently the drm
tree) would also not be mergeable.

Just supply Linus with a hint about the conflict resolution.

--=20
Cheers,
Stephen Rothwell

--Sig_/QCzYje/thezhTNHZAHbS5n.
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl0dHt4ACgkQAVBC80lX
0GwOLwf/bLqfP05XRzAft1l6aLoPjQIG+JOwKAInxBLdWUC0kQXWzxw3AQWDl7WL
l/VowMzvzxqjHGFW5VN3kSrajP6gkSFW3yS0jK4e3Zihhw3x69anzN5VkyUiEByN
IiYHHCYnCCSxrPjAR6JWidX/upjA0+clsMdPC3JHWENnRKvTsixi6iDO/2rsEnUp
bJeXOdZXuX3cteMU7IuZHFpPDdmzJrIfz8uDQrr0AoptLamWXSTr6ep2G+oeTlhS
tBf+WCTf5TLtu5jElnEJIWLi+3UDmtFYj90xE8JHgnjS3Ks09JB4wovgIj/vyriV
TQALMjcIlQq1iRRyIYe+rd6y6V5R5Q==
=FgfH
-----END PGP SIGNATURE-----

--Sig_/QCzYje/thezhTNHZAHbS5n.--

