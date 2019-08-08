Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58440C32754
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 01:20:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19E962184E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 01:20:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="eojPfFQr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19E962184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1D9D6B0003; Wed,  7 Aug 2019 21:20:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CD316B0006; Wed,  7 Aug 2019 21:20:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BC176B0007; Wed,  7 Aug 2019 21:20:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 56A716B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 21:20:51 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y9so54492531plp.12
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 18:20:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=vahPCJSxJzHRyTEZf2ltYsPbhbCbxjv0tkqAuZtGeDo=;
        b=Gh7C6Oil9hh+HoBviqWnDx95XfP1Dkbyn9IKEdiZLDeLGrcwoAPBWs+Yp+I58c0OQI
         u54CqpU6p7Thax+IyThQ9+aQUlCZr7TDnK6YhE9rZM4AezPMyfafV+vIcvItsZXLxr1G
         RsYbJ6DxAmD5j2iTef2jrw5NkABaDQW4/5GGMHT7EB5dZGclMwQ0JXFuEuO3AGOLON0z
         3/3Dz2GrqK74H1LlbbNKij0E+gyLjelN7jCV0KbVeqh3u6Iun+AQ4jXmXu7YMUxeAOpq
         RTnoncXRFTOA/xuUPi7ABIVcRneBG6edpRMJ1AXtPe7g1XpVXskrE1H7LSIK+4AFM0hq
         RPDA==
X-Gm-Message-State: APjAAAWfce0AORMSwOdllpHaPnhxgwCCm2GGBH/Yjz8zn39T+w3h9nEk
	JKLcE77HtShFXNJQuOowdkCGe1qicHMVwkCxchRfk1kOBu4CTrA2zAjKTfX80dMGmq7fZ5edrAF
	JYaH70nsLBNu3ww5yQNnHeJSugcJyn4nEpTygIOS2r+k3we+h0HovGIxbnEQnElBpMw==
X-Received: by 2002:a17:902:968d:: with SMTP id n13mr10989451plp.257.1565227250925;
        Wed, 07 Aug 2019 18:20:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxk8m2kfhYLxG8illvT6I0AGKr5IUT4UgOnk+NsoTRLC+fJFjXPoXHNTTBh6T4aAJuKi6+i
X-Received: by 2002:a17:902:968d:: with SMTP id n13mr10989402plp.257.1565227250130;
        Wed, 07 Aug 2019 18:20:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565227250; cv=none;
        d=google.com; s=arc-20160816;
        b=O0DmfUkddPy/N7KSYDAPA3B+K5vySiaKRupBieORkvXykr25fPyLsm9f1As38NbqHu
         TzVYb9L+1Q5zHUvJpvs/2r/BzU6V1/50TzNc9Oq/12Yt3ybHlxGL7YjGMVP2Rp26vdkJ
         f5G7ePV0YGkCqqz7rLGHg4/dgcMYnIR28v6kqdNRKkkglYoTPuMRtgjWnztmMbDSmq+J
         +P8hx474zKdhtCT/mcVKF8QT2NYUn4V3qWOUnt4Lrzo0Ew8WTUFQWmN9IqAQlFhOe9mV
         7IjsOHARkE+dokeno7R0iKuV8BdqHbIuacDw3kIGGQWMOSiiV+9hJzt3gM0dqgwSlOsv
         VrNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=vahPCJSxJzHRyTEZf2ltYsPbhbCbxjv0tkqAuZtGeDo=;
        b=nQCVqaKobXEVgM2XF2xOOeR62FUa0fL9z/y9afcbIALD3A+GTKczv8l7GZIinCUvAB
         mOToZ2xcAYvTaU6POa/VTiN8KEpA3/beZpWqhLrbHeiW0QtkHjnEKP+IglPaaJYaRZKX
         aJPxzdC23JNt2eIRlcaeRHvKJwnMFt+t9xcTpjpP7Tqef3v7h/KtYPR1rQWm5XTC/NLb
         obtwHCfdhj/VJ79QLymt0n5EGp+9i1v4YyJUtbOig0ChfmDNHEDc8jhcSYqXZEfQItA/
         FBB8VVIFEFWXgX9qg0iT4iTkjblGOojCpuTRGSHwEcTUpbjWdl7Bqbkk9oDpdE8kM7wP
         xqmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=eojPfFQr;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (bilbo.ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id bg2si44907095plb.263.2019.08.07.18.20.49
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 18:20:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=eojPfFQr;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 463rCy6VVqz9sN4;
	Thu,  8 Aug 2019 11:20:46 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1565227247;
	bh=umznyvpOFtuEr9ptCP9R8EL6gWu/KVzYLzvUfJ4fnic=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=eojPfFQryfm4YDArVQTTnE+j0hZ3FrIg3kVabXTD9DlJmAkf4QUT1xDDFfs4fUI6s
	 CK0CdaAm5kR4a0BkmC0CrIcYcBWOCAzO0L3JHyGwvsb4l8Mbp5DUBYeyVXB9k5GpPA
	 Y/SbU99wU+5wV7sQE4HJVVmSwaul4CmuLJaFHaJf+xrFsXxlb9gS56o1MRfcUhvJgF
	 Ezsmo/Veyh50isYeZ3tBPtnnVZlLGoE+OCnPs4wxbCiTI7c8pmeIGMXAyrZKreT/6L
	 XR6oPcUfR5nInwiQlMsBakcarm7tIVC/JLYtqx1EP/cmSqyYx4wAIlMHYlriqUAZoT
	 aBvZQC0mZyutg==
Date: Thu, 8 Aug 2019 11:20:44 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Song Liu <songliubraving@fb.com>, Randy Dunlap <rdunlap@infradead.org>,
 Linux Next Mailing List <linux-next@vger.kernel.org>, Linux Kernel Mailing
 List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Subject: Re: linux-next: Tree for Aug 7 (mm/khugepaged.c)
Message-ID: <20190808112044.4390d46f@canb.auug.org.au>
In-Reply-To: <20190807142755.8211d58d5ecec8082587b073@linux-foundation.org>
References: <20190807183606.372ca1a4@canb.auug.org.au>
	<c18b2828-cdf3-5248-609f-d89a24f558d1@infradead.org>
	<DCC6982B-17EF-4143-8CE8-9D0EC28FA06B@fb.com>
	<20190807131029.f7f191aaeeb88cc435c6306f@linux-foundation.org>
	<BB7412DE-A88E-41A4-9796-5ECEADE31571@fb.com>
	<20190807142755.8211d58d5ecec8082587b073@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="Sig_/j2bKP.0cu/QWzP1Yxga==yl";
 protocol="application/pgp-signature"; micalg=pgp-sha256
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/j2bKP.0cu/QWzP1Yxga==yl
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Wed, 7 Aug 2019 14:27:55 -0700 Andrew Morton <akpm@linux-foundation.org>=
 wrote:
>
> It's all a bit confusing.  I'll drop=20
>=20
> mm-move-memcmp_pages-and-pages_identical.patch
> uprobe-use-original-page-when-all-uprobes-are-removed.patch
> uprobe-use-original-page-when-all-uprobes-are-removed-v2.patch
> mm-thp-introduce-foll_split_pmd.patch
> mm-thp-introduce-foll_split_pmd-v11.patch
> uprobe-use-foll_split_pmd-instead-of-foll_split.patch
> khugepaged-enable-collapse-pmd-for-pte-mapped-thp.patch
> uprobe-collapse-thp-pmd-after-removing-all-uprobes.patch

I have dropped them all from linux-next today.

--=20
Cheers,
Stephen Rothwell

--Sig_/j2bKP.0cu/QWzP1Yxga==yl
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl1LeOwACgkQAVBC80lX
0Gx7kgf/SIl4fB7HUsRW/clKuyM12Y+85pl9oCSGfH/yoXqig2drxvBIaFMvqXaL
ANc0d6xdkx6L9WHNlorYU1pi6fDkH1oRhYzcOLVUJIkGSFDZuK5cF3GEwlFFog0p
7LzT7D1c3g4BuzhVokLGDFSRzF0kd8dewwfmLkNFbBc39i2M94gN1qrqzIc5nemZ
RbhAtO8QGH6IZ+2XAaoflITeKONoUDXXClzbx8nEGg11T8A/wXi6Q/9rmfQH0rd3
4Z60pYFpUFqBFal6IDW9yQe3plZ1PfPbnfrzGOepUEnZBgJrQ4FX4YKJa+H14FsD
Gxl7S3dArcn49pHeszLXsc5CTAEuNA==
=pphB
-----END PGP SIGNATURE-----

--Sig_/j2bKP.0cu/QWzP1Yxga==yl--

