Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E4E5C28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 03:40:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BFED206DF
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 03:40:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="G1lFsOJU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BFED206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0A226B000C; Thu,  6 Jun 2019 23:40:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B9B06B000E; Thu,  6 Jun 2019 23:40:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 834166B0266; Thu,  6 Jun 2019 23:40:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 57E676B000C
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 23:40:11 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id u200so159121oia.23
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 20:40:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=pa8me+rakZWDjEypIvJVJP7U7jLDmCrHPlreNoxTeR8=;
        b=UYEIimiQy0pWuCfYcwUFOm8wF7NZH7q1s/nDE3LFkbluYxjynrYXgedcN6Jhf54DGe
         ol+TtdOv83oBOvZZYTQqY+39LW/aOCZszPFNnVEhkQfAgdlIoJt5/yKaSbpiwXOgbVdN
         V+BzImyhI7zyCySH/DtKXznbJsOtMM5kCQOCxrzj7/TIqRNSBxyZuhTElo8/h65fFw6r
         1rqrMQPydAnImebIdnWVoEz5kMrMAnD2xIkrMFMUJD3DqDDwIagJHFA9UAAVBlX57N+d
         ZaQ2EBdNWEwSl9d7nD7aEnvJq0WAmv9oYPS36mMM/VM8GfdfL/VCbjRA0cgZ5sIcKnGK
         DSig==
X-Gm-Message-State: APjAAAW9OLsvwPFtqgsw+Obk1knMbMdrBOH33UAllfvzgL5tmVaJjneN
	hfgjNUEx6MUrTYBXSJw6NgY6MNwxyB0AduwJCakAT0Fs9dj6z/dDPF2N5u8sneUr0Vv4qBHHBPy
	ccbyoS97XOVk0u84tuJaZmA5B/HHC/BpKQUOCbO4KwyRshAvroi0JDaGJaitx9rnONA==
X-Received: by 2002:a05:6830:199:: with SMTP id q25mr3528670ota.79.1559878811042;
        Thu, 06 Jun 2019 20:40:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhz1NHUrrT4i1RrGLaWG/nHTWnIhGSl7cnZjMRbe7B0ECY/aD+yLRFNAxmnMH/2PnH1+df
X-Received: by 2002:a05:6830:199:: with SMTP id q25mr3528601ota.79.1559878809484;
        Thu, 06 Jun 2019 20:40:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559878809; cv=none;
        d=google.com; s=arc-20160816;
        b=UAnjndnhs2z2xVFzvb4z1Vg2GUfw2NoSyEh912gLfMPqtVptyNL/9ftcF/Yd/u4Wj1
         cfeVLMZuJLxc1v4uMVshQeFI62sdspKhJjCIN4wq9kyYLNTijZu3dtq8+WcbGjNKPVnV
         EqlkycTedFD5fRlGBOdhOiuRvEZw5Ev1+0T/PvlfeAQ+tBbXDBA68VORo5mEGGHncVWP
         NOFMakp6MV/u1p7NuElLZeH4Ic4LfU2O80l/bQHMF3a2QLboL6kYcdBP7ZFX4ZpHJd+p
         xenqCTqzA44dHHJZ/B7X2a9Fyp851Klnt6hFD6Aqn+shNLdMazAbXSY7GroA5pHq0c9U
         H/0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=pa8me+rakZWDjEypIvJVJP7U7jLDmCrHPlreNoxTeR8=;
        b=Ge9ButWSoNICtBG3jwF2MCciv+qIuBmB127qGNI5g/BD2OPnln+OMNFIMNba1F772U
         UF0aJqVVSAPzm7gOf5H/jTFma7TAvypXouC1hhbx56Zw3UMpzgL9lSE5vwQsNfUCKi+8
         80+PvZMOUyMgn1CXBJwI+MBh6djLpv0ANZt3sZzDZMt1SbzrhrsjdoRawBUnxykfawQx
         vT/XKSvCrfh6DBTWPy13Ag7XDODsfQGuzQpXq/2otSdgXmLY0l2rTFgqA+7Kv2/BTdYR
         Ty11LW8kFHYyrlViSHMgA/JwkAQFwFhoBeF/qXOMcN3I/0cq7WqhRXx4yNcf50fMuI1M
         bz8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=G1lFsOJU;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id g23si507284otj.307.2019.06.06.20.40.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 20:40:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=G1lFsOJU;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf9dc980002>; Thu, 06 Jun 2019 20:40:08 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 06 Jun 2019 20:40:08 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 06 Jun 2019 20:40:08 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 03:40:08 +0000
Subject: Re: [PATCH v2 hmm 10/11] mm/hmm: Do not use list*_rcu() for
 hmm->ranges
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "Ralph
 Campbell" <rcampbell@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-11-jgg@ziepe.ca>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <59b5de4b-e872-30f4-149e-f8a3bc946f22@nvidia.com>
Date: Thu, 6 Jun 2019 20:40:07 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-11-jgg@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559878808; bh=pa8me+rakZWDjEypIvJVJP7U7jLDmCrHPlreNoxTeR8=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=G1lFsOJUt+3jxL5x/uSOUxqaW8LvFvibp6A1hycDOeXtZ3mAVTRD5L3VKP0+kejUe
	 plHS/p/eAzx3ex2XvNWSsTCNfKzMxe6E+GIKyEeyTNz3eSluzrCzSvLLKtXOp+RwaI
	 voG1xUgVGSn8ma6EEdNcmXRkz1nklW0nF4LIQrahYEMP2+v0xepaEdhjPoULnG84Qp
	 EDLZE60nNdaLX38kGT9lcb2ftfpDNdj31aqY2OYsEJ2m2Fb88xd/ujlbrFDIGrhXl3
	 wYDlYNzBx0QOfzYwjwKgB+ND6ZyLRRb32g3Q1tZd7Iqq+9mp7WwLSdXx/jOveKZLKX
	 LKsPn6DIVkigg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
>=20
> This list is always read and written while holding hmm->lock so there is
> no need for the confusing _rcu annotations.
>=20
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> ---
>  mm/hmm.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index c2fecb3ecb11e1..709d138dd49027 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -911,7 +911,7 @@ int hmm_range_register(struct hmm_range *range,
>  	mutex_lock(&hmm->lock);
> =20
>  	range->hmm =3D hmm;
> -	list_add_rcu(&range->list, &hmm->ranges);
> +	list_add(&range->list, &hmm->ranges);
> =20
>  	/*
>  	 * If there are any concurrent notifiers we have to wait for them for
> @@ -941,7 +941,7 @@ void hmm_range_unregister(struct hmm_range *range)
>  		return;
> =20
>  	mutex_lock(&hmm->lock);
> -	list_del_rcu(&range->list);
> +	list_del(&range->list);
>  	mutex_unlock(&hmm->lock);
> =20
>  	/* Drop reference taken by hmm_range_register() */
>=20

Good point. I'd overlooked this many times.

    Reviewed-by: John Hubbard <jhubbard@nvidia.com>


thanks,
--=20
John Hubbard
NVIDIA

