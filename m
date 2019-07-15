Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 569DEC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 20:14:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0690F20659
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 20:14:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="WAapHeWX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0690F20659
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DC3F6B0006; Mon, 15 Jul 2019 16:14:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 88C936B0007; Mon, 15 Jul 2019 16:14:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A29C6B0008; Mon, 15 Jul 2019 16:14:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1F36B0006
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 16:14:16 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id c70so14506901ywa.20
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 13:14:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=BMxYmaxLZP+7xtagiq4XdrfPFrAjpdxkuCAPEb6M/YE=;
        b=bqH1ynbfBHpE3GyZwo56CmnY+MCfismJ2ZRzoHvCqfsq4OOU5Vc36gJBfMMU9SD9Iq
         nqf9KJuQNVJ7iPhMu119Gd6QFe9QKjJpOaWLJ2TE/tav5nH9uw9IufQ8YmNoFFbZCPhQ
         atEcCKfSva0CsLQk3heluBAasxNkJ8GJm8B2u6y8ijFSFDz/hmEqKE99Ju/vzrx9I+8M
         ExRZ3f02ZWewtZHsLvcaW8oiK4QlEp3NKAg51TZVz4gM3o13Vcab8dBA49MdNRbDKgix
         7haQ6nicfdbTEY0TNHTc2BjTrMqwpsNNlXu5qy+Bs5I2MUA79dKFGMCJBzGjlfJAoF6D
         h28g==
X-Gm-Message-State: APjAAAURoRXnnwDycso+yxBCojgz4wr9PLtZD4Bg04ryMt319UURyvaF
	9i1gMTDyVp44KYnSmfoHWSS2KYoqRJbfkJL4S8gsiPKzqJ5EEhLPjmRCDch5+OhmOHpQiFuRvOq
	GjECTPpFIAh40yq8NIA/ic53RaBU08cDfrJIR+HZ0JRgr3DGGgEab+aMTvLvG9HRDPA==
X-Received: by 2002:a25:9c01:: with SMTP id c1mr5971368ybo.418.1563221656030;
        Mon, 15 Jul 2019 13:14:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvZ3vkoaPzkEv/9ULwILx9IGlRaWcSO2y3TEAriM67Ga+tA1vOxBTjSCPJ02hprYDjAwfE
X-Received: by 2002:a25:9c01:: with SMTP id c1mr5971316ybo.418.1563221654933;
        Mon, 15 Jul 2019 13:14:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563221654; cv=none;
        d=google.com; s=arc-20160816;
        b=Rhlsq9v4osi6M0XiJiBf/B1iZKY2ymr+FroCfQjNGnqGJL4xNBqjBisbpyEKqQLsOb
         S/dFp+kn2HlWpNpxYdgqT0bcFG3AopsE7r0Ij1r4zCXE8uZtHpxtYSTXGBdspUdTYuYM
         bo+pXliG+8tLLVULLN3cOQKvz0K25rbLdFp2dKFBG2M7lQVPjkkYmAjWvgMVU7Wdnp8U
         JNuBQ7e9X8xxiQmH9YRaReqGlbzwVjkeH65E8CBRFZzLU8XskAgzPJIa2Ns/PXBKQ1lp
         ediTjwovo/+u/oatwwdHD4uLcDXfSVqMaZ6MDNF74AtOeDTQD0z9RS/E47rTkIYlMS0O
         oavg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=BMxYmaxLZP+7xtagiq4XdrfPFrAjpdxkuCAPEb6M/YE=;
        b=Uw3ffXpMKcXQFrudj+Gyjs2lsEbJaPz7vuUU1EttMb6i4Ualq8cFOeMo1TRWbrLl8k
         MITcvIx56DHf5QY+MIpAsKRqj0YkFvpaVhWOcscrVx9ixY1wGPQ/HAWTVpX/Xb9720aD
         I+WKqkHWP84fQ/Y19Tfl3c1D+1/cffUdkc5VuZZU5BEGvUO5p5BtTyhn1XSGafXKcUkD
         aUjO6FsASBbckeYJ6TTcZY09eYfHTvS7SJK/JCVbXHIei5QQllIUrm281nsGc0L7kylZ
         KF5sYjFt1ZiGlo8A40Kd2TRK2LRgLNvpGYpQ901MHYgPjMgHgn9K7t9a3nGoB0PiCcdw
         N+zg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=WAapHeWX;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id q69si7845200ywh.174.2019.07.15.13.14.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 13:14:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=WAapHeWX;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d2cde9c0000>; Mon, 15 Jul 2019 13:14:20 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Mon, 15 Jul 2019 13:14:14 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Mon, 15 Jul 2019 13:14:14 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 15 Jul
 2019 20:14:13 +0000
Subject: Re: [PATCH] staging: kpc2000: Convert put_page() to put_user_page*()
To: Bharath Vedartham <linux.bhar@gmail.com>, <ira.weiny@intel.com>,
	<gregkh@linuxfoundation.org>, <Matt.Sickler@daktronics.com>,
	<jglisse@redhat.com>
CC: <devel@driverdev.osuosl.org>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>
References: <20190715195248.GA22495@bharath12345-Inspiron-5559>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <2604fcd1-4829-d77e-9f7c-d4b731782ff9@nvidia.com>
Date: Mon, 15 Jul 2019 13:14:13 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190715195248.GA22495@bharath12345-Inspiron-5559>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563221660; bh=BMxYmaxLZP+7xtagiq4XdrfPFrAjpdxkuCAPEb6M/YE=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=WAapHeWXmLTyRYz3wNyClC6+13efTzwE10OPt/TU6UzVEhQ95SBC2gyGzhQSq8HzY
	 jif7L106RMFBSUgWWTTOtKHY++BEoNDNqfzgiSakBgXQz7mrzurCeo5LnBL3cdHTdW
	 9UQh4CqliZkdYkplEcYXuJba0rR+7so4j/xBe+8jAIUwoYBK4II+W8f3W9W3kmLAMs
	 r7cbHtFee6QReJJdSABcP7vtaZ2aA/L9fceZ+vtVh/8yr0Q/NujtUzQQnfJB33iZWA
	 VUOTM6zOa03ibnytuPQvgFn80smv0LT15Q3+mUhiPpZjESiU6lD7H4cdBJJjkE2sEO
	 ovaCokkakfJiQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/15/19 12:52 PM, Bharath Vedartham wrote:
> There have been issues with get_user_pages and filesystem writeback.
> The issues are better described in [1].
>=20
> The solution being proposed wants to keep track of gup_pinned pages which=
 will allow to take furthur steps to coordinate between subsystems using gu=
p.
>=20
> put_user_page() simply calls put_page inside for now. But the implementat=
ion will change once all call sites of put_page() are converted.
>=20
> I currently do not have the driver to test. Could I have some suggestions=
 to test this code? The solution is currently implemented in [2] and
> it would be great if we could apply the patch on top of [2] and run some =
tests to check if any regressions occur.

Hi Bharath,

Process point: the above paragraph, and other meta-questions (about the pat=
ch, rather than part of the patch) should be placed either after the "---",=
 or in a cover letter (git-send-email --cover-letter). That way, the patch =
itself is in a commit-able state.

One more below:

>=20
> [1] https://lwn.net/Articles/753027/
> [2] https://github.com/johnhubbard/linux/tree/gup_dma_core
>=20
> Cc: Matt Sickler <Matt.Sickler@daktronics.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: linux-mm@kvack.org
> Cc: devel@driverdev.osuosl.org
>=20
> Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> ---
>  drivers/staging/kpc2000/kpc_dma/fileops.c | 8 ++------
>  1 file changed, 2 insertions(+), 6 deletions(-)
>=20
> diff --git a/drivers/staging/kpc2000/kpc_dma/fileops.c b/drivers/staging/=
kpc2000/kpc_dma/fileops.c
> index 6166587..82c70e6 100644
> --- a/drivers/staging/kpc2000/kpc_dma/fileops.c
> +++ b/drivers/staging/kpc2000/kpc_dma/fileops.c
> @@ -198,9 +198,7 @@ int  kpc_dma_transfer(struct dev_private_data *priv, =
struct kiocb *kcb, unsigned
>  	sg_free_table(&acd->sgt);
>   err_dma_map_sg:
>   err_alloc_sg_table:
> -	for (i =3D 0 ; i < acd->page_count ; i++){
> -		put_page(acd->user_pages[i]);
> -	}
> +	put_user_pages(acd->user_pages, acd->page_count);
>   err_get_user_pages:
>  	kfree(acd->user_pages);
>   err_alloc_userpages:
> @@ -229,9 +227,7 @@ void  transfer_complete_cb(struct aio_cb_data *acd, s=
ize_t xfr_count, u32 flags)
>  =09
>  	dma_unmap_sg(&acd->ldev->pldev->dev, acd->sgt.sgl, acd->sgt.nents, acd-=
>ldev->dir);
>  =09
> -	for (i =3D 0 ; i < acd->page_count ; i++){
> -		put_page(acd->user_pages[i]);
> -	}
> +	put_user_pages(acd->user_pages, acd->page_count);
>  =09
>  	sg_free_table(&acd->sgt);
>  =09
>=20

Because this is a common pattern, and because the code here doesn't likely =
need to set page dirty before the dma_unmap_sg call, I think the following =
would be better (it's untested), instead of the above diff hunk:

diff --git a/drivers/staging/kpc2000/kpc_dma/fileops.c b/drivers/staging/kp=
c2000/kpc_dma/fileops.c
index 48ca88bc6b0b..d486f9866449 100644
--- a/drivers/staging/kpc2000/kpc_dma/fileops.c
+++ b/drivers/staging/kpc2000/kpc_dma/fileops.c
@@ -211,16 +211,13 @@ void  transfer_complete_cb(struct aio_cb_data *acd, s=
ize_t xfr_count, u32 flags)
        BUG_ON(acd->ldev =3D=3D NULL);
        BUG_ON(acd->ldev->pldev =3D=3D NULL);
=20
-       for (i =3D 0 ; i < acd->page_count ; i++) {
-               if (!PageReserved(acd->user_pages[i])) {
-                       set_page_dirty(acd->user_pages[i]);
-               }
-       }
-
        dma_unmap_sg(&acd->ldev->pldev->dev, acd->sgt.sgl, acd->sgt.nents, =
acd->ldev->dir);
=20
        for (i =3D 0 ; i < acd->page_count ; i++) {
-               put_page(acd->user_pages[i]);
+               if (!PageReserved(acd->user_pages[i])) {
+                       put_user_pages_dirty(&acd->user_pages[i], 1);
+               else
+                       put_user_page(acd->user_pages[i]);
        }
=20
        sg_free_table(&acd->sgt);

Assuming that you make those two changes, you can add:

    Reviewed-by: John Hubbard <jhubbard@nvidia.com>


thanks,
--=20
John Hubbard
NVIDIA

