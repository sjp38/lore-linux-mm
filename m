Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7FA6C32756
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 01:31:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A37521874
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 01:31:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="AxY1O5I9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A37521874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3C6B6B0003; Wed,  7 Aug 2019 21:31:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EBEA6B0006; Wed,  7 Aug 2019 21:31:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B4EC6B0007; Wed,  7 Aug 2019 21:31:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5378E6B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 21:31:35 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id q1so1031662pgt.2
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 18:31:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=+X8dSre5zqwCu1dF7b509vx55oD0MLvcIyuILYm1+iw=;
        b=gkPTgq4BJZWNgPcm/UqCw6Epd/rfGG3ffyZHnXbB3Yf9oKLKy9h5nRVprMaI9wDfNs
         9ki/stOpIoV1V5Vid5Pu81sq+0HSv3msVTW8SBpggg7QNaPx2B6HwWCGMlxhd2mI/1QK
         C3cuLcm7LMs5p1GKf1FoYb44oRfjQm3yBy8Q1C2QScG1glEkqJqt8IUoCyfC64MkyL5A
         FECjUN2ilUqzWb7o+eEMQWxAosUJZWo80cDdrZ+S0mAHMw8bBD82QlzVbaZKMcMSF0ac
         cFsEbY3nHQ8ukSKQFkGyAsFWlyIq2CKrYu3gthT7j8HY4dASu3zqvwOOiVgXugPRZbhv
         Mlcg==
X-Gm-Message-State: APjAAAVx78rFyW+EnlZawPY6C8UIpVJiJb86qNWagMPnJlkDw/l/Wnqy
	uycHjMXbkAU3ZemiLae9URannw7c8VlBl3OZZ4ENT5dYLhQEGB01+LlbW+JfTb7zelV/OyrsfcM
	Lj1Vv9tAXERH0O1I3JhveVDZRxjKb5ps3mO4ub+1jLZthks5mGgsVOWYjYpLlb26b8w==
X-Received: by 2002:a17:902:9b94:: with SMTP id y20mr10983679plp.260.1565227894794;
        Wed, 07 Aug 2019 18:31:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypKTMwDLWAslyjpgwK5P/dO5TqWgpYvgYM5D0u+ZBq7QGnGFPud2CMuQBic+c/UsRoMTWJ
X-Received: by 2002:a17:902:9b94:: with SMTP id y20mr10983629plp.260.1565227894085;
        Wed, 07 Aug 2019 18:31:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565227894; cv=none;
        d=google.com; s=arc-20160816;
        b=SFzphBslk7E4YcF3bnNofMMUY1sOlyTRUhuWYPEicakAxmQIzEUbk9AUa/gVD+GjEy
         nxEHQ7srfz9+0adx73djmQ04NlPe917fy/d0tnFm0+ilN1LNmljkX8wfDX/eQjY9w6FM
         eFP5MiwAx1Xq4O1McCSdFQRhUrlwr0lIDCZLNnxrH41Qxub5xDQ5qRDcZtp02+y049CB
         V2wa0XQ181exaYjGpdZ49J5IYk7JQ1rO4qT03Fmrpu2l0Ya+CJKvtGBhpoYgm0jqJdJM
         Pj8nI4MsFferdz5bUAz3O++l21jBIJNJijN34A4PbjJ09b7JH/Yp4qKZ4a/GLJzgJgHO
         UDDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=+X8dSre5zqwCu1dF7b509vx55oD0MLvcIyuILYm1+iw=;
        b=QWUH32emkJDZhA6/SJOSQfjE73zDnQ+apecfj2UtYztAorqLPR8kWEmg1JmsBvMWzm
         N9zGG8LBCod+wlQsyBINGF6nEsowDt68o/nCcFFil2tI06AqIb8YC8eDN8TJWiCisM+q
         /Yi019wnc4RPdPbddM6xRvsA14OvCMZxnMpyuwEuwaHiYpyLnXRHLhcv4wE3iEesN3vF
         rqa6xDoBRAJae6EkqbGk3cs8N1r+5zwNNpa5fFJtFFs8GWTjRNrw7pH50hjgJAYI0Hs0
         u+nYoAXswBl4tWoTsy6CimLWe+ruusP1lAJZ6Jvw9KshKPTefCuw1xtUSiJSC51MtkLZ
         UHtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=AxY1O5I9;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (bilbo.ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id d5si44311585plo.396.2019.08.07.18.31.33
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 18:31:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=AxY1O5I9;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 463rSM2nrcz9sN4;
	Thu,  8 Aug 2019 11:31:31 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1565227891;
	bh=VskflzzaHB3YqEhRaWaqpmXfLtKuW7+a50wQ5+qwMzA=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=AxY1O5I9qBH6ATA9yYG+iwxjXgQd6T44GfBT3kn9e5nQ3Lccakt9z1jIOUapSTl8a
	 ZDsBr8EmPZDgdIbBxyTJ6hHqKzlax4iuuufbrMpvpHJOGzRqCBUMgGC57dWC9vEHK8
	 FmM+AOWCdyX2sddSaOdsWiuZYeSRDje6Sq4coEnGqoPiR2jKcK8pHIGtSPHb6vo75W
	 92Xe7N2txysoLxQYPSw8wRbNlGbJ5deDKnYRE58ZwhRb4AlBzmS3gKSy/mTR+PHL8p
	 iZMFa92SHIYkLBizRhuzg+YQkHkTZJJlXf0nwfdH0c7BRDdvJmHi6KE7WAehW2o+8K
	 yP63ZpyGsZS1g==
Date: Thu, 8 Aug 2019 11:31:30 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Song Liu <songliubraving@fb.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, Andrew Morton
 <akpm@linux-foundation.org>, Linux Next Mailing List
 <linux-next@vger.kernel.org>, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Subject: Re: linux-next: Tree for Aug 7 (mm/khugepaged.c)
Message-ID: <20190808113130.4cc2902f@canb.auug.org.au>
In-Reply-To: <F53407FB-96CC-42E8-9862-105C92CC2B98@fb.com>
References: <20190807183606.372ca1a4@canb.auug.org.au>
	<c18b2828-cdf3-5248-609f-d89a24f558d1@infradead.org>
	<DCC6982B-17EF-4143-8CE8-9D0EC28FA06B@fb.com>
	<20190807131029.f7f191aaeeb88cc435c6306f@linux-foundation.org>
	<BB7412DE-A88E-41A4-9796-5ECEADE31571@fb.com>
	<20190807142755.8211d58d5ecec8082587b073@linux-foundation.org>
	<abb5daa5-322e-55e8-a08d-4e938375451f@infradead.org>
	<F53407FB-96CC-42E8-9862-105C92CC2B98@fb.com>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="Sig_/yhc0x6v6fDgfN4ZWUXD5eHT";
 protocol="application/pgp-signature"; micalg=pgp-sha256
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/yhc0x6v6fDgfN4ZWUXD5eHT
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Song,

On Wed, 7 Aug 2019 22:11:28 +0000 Song Liu <songliubraving@fb.com> wrote:
>
> From: Song Liu <songliubraving@fb.com>
> Date: Wed, 7 Aug 2019 14:57:38 -0700
> Subject: [PATCH] khugepaged: fix build without CONFIG_SHMEM
>=20
> khugepaged_scan_file() should be fully bypassed without CONFIG_SHMEM.
>=20
> Fixes: f57286140d96 ("mm,thp: add read-only THP support for (non-shmem) F=
S")
> Signed-off-by: Song Liu <songliubraving@fb.com>
> ---
>  mm/khugepaged.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 272fed3ed0f0..40c25ddf29e4 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1778,7 +1778,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigne=
d int pages,
>                         VM_BUG_ON(khugepaged_scan.address < hstart ||
>                                   khugepaged_scan.address + HPAGE_PMD_SIZ=
E >
>                                   hend);
> -                       if (vma->vm_file) {
> +                       if (IS_ENABLED(CONFIG_SHMEM) && vma->vm_file) {
>                                 struct file *file;
>                                 pgoff_t pgoff =3D linear_page_index(vma,
>                                                 khugepaged_scan.address);

I have applied this to linux-next today (it needed a little adjusting
after removing the other patches).

--=20
Cheers,
Stephen Rothwell

--Sig_/yhc0x6v6fDgfN4ZWUXD5eHT
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl1Le3IACgkQAVBC80lX
0GymPwf/Yptoay9yV8VDu8pDytNxBrsnHMGbQJ5LRMb9crEICeyHb4JVvUS4W6I7
KAcTGuB5yrUGdhYIQFU/mgiqxxAerpKch6t1Lw2PjzB+iCkQAST/OTcTmni38ln9
L+KsyAJR3AyAU6bY7u+CoWnbUeFmWV+itElbvhtJeGw8eAjbjs2OGWup03J4bJXJ
cnaY61rM0ViOVXS2tbzMJZt5j736Olu3UHRmEA4FxekLP8NHlfNm9WSmqFUOIhA5
M/zYa1NueNlchfMt3S/b+6TKxwRd3xCiFwUe0fIq04oQIhIxtqXpYv/lkvmIbja7
F13gAR8XbAdTeSucyWzRJ+16APO80A==
=5rKS
-----END PGP SIGNATURE-----

--Sig_/yhc0x6v6fDgfN4ZWUXD5eHT--

