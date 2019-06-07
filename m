Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDD97C28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 03:37:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A775206DF
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 03:37:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="N8RlWv2x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A775206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10A246B000C; Thu,  6 Jun 2019 23:37:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BD276B000E; Thu,  6 Jun 2019 23:37:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC5C06B0266; Thu,  6 Jun 2019 23:37:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id C4AB36B000C
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 23:37:45 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id p83so163302oih.17
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 20:37:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=hnXE0MxsnGUyN9sEUkzf3xpow50f6NZj1i458LDKMRY=;
        b=Swc/+q6Kdg/1fmXQ5Vq9un7U/lQbwIGZUPQLKiRqop+UddU3+nqS+DgshH+AR7Vs6r
         aS6iBZrWXCz+GK+WDt16Q7g+S3NaDnh5awhAmbgnZpU3Ax8XdRidHLeQtUMmMAT8bkeW
         cmNGj1UAdzS+TFvTxGvPcNOUeC4vOCCa4Bu6eUyxdfG+g0OZMCFYDwhHxolY6uJgyIqN
         Z4bbGrTtS1iMWwRGNZufHbiXv19EnDXzv0qvgIqMcoJdq4COFMqah4DLqdpRnSlKx6x9
         D2Gh8PQC0b5cWZ7I3rJnaYXkvy6cZhUu7cqepA1GCiLpuVuNb7jSY2V3/NwW1zGD+hEo
         EVgg==
X-Gm-Message-State: APjAAAVddh0z+ntNYp9q3DTi/zRv33a31LkcxHcRumwR3DVLuOULSHIh
	EZYj5RjX1dqUAmHI1KXAPe2O4SgA0V30ork4fUcvOwFLCHEPXnw3KqH8+6Cv6NsDgbAPM8I+HpI
	UpD9M/pSertsgU7HkgN7IVBU2m4dQ0XwiA0qsi94KfCnPu5JflGV7BSCCd4pQBRUt9A==
X-Received: by 2002:a9d:68c5:: with SMTP id i5mr17995005oto.224.1559878665358;
        Thu, 06 Jun 2019 20:37:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/d2I5yGc7dT9w4gR9jOgmck9xBPZfp3qM7zmXXxD7wdYz0aa5s78+Lc/fZn3UsOWOabii
X-Received: by 2002:a9d:68c5:: with SMTP id i5mr17994992oto.224.1559878664748;
        Thu, 06 Jun 2019 20:37:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559878664; cv=none;
        d=google.com; s=arc-20160816;
        b=FH1I6zDqpIlli4dtjBMH+sZYaE6//MnaCbyuWYaQ5rnkrKJWOfD9w8IX6t5N3+QTox
         asluenB48MRPlH4daQaRXMtJLm1pwl6vG0kwpLitzUsjGfax+8cNHpwA/A4BjLaMnzI4
         rPswmozgLpcNytdMnUjFRt9j9TwfiMf0KcjikhgDhcq0zXVg2Ny63CdMoSg6u2dPoxNC
         DeaXLpx1r0T8sYDG/EYmWaXOqFFCRfx6TjwspTgQNk/8KjW+yzCR9lJffolFw1QDPGO/
         vo8XMSGUzRM30b908PMpC6KLnecEn8FdYzFVAjU1upPsa0XxY5P+xelJ9oxEL/yS9OIr
         rM+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=hnXE0MxsnGUyN9sEUkzf3xpow50f6NZj1i458LDKMRY=;
        b=K8HFl56NAFCGS3RAwx8ux5M2eCbB23lMFJ0ZNn0jc8OmvxO7W264VzB4KOHQmWhljI
         hGZ6fJNKTUz7Jt79uzbMu16SEWpjXfGvHl4SA0/aHbIwkO25ChryE3PlBJ5K38y2uwj8
         GtuFKGa49ImP/BDqB7tSqHL3yXdHuveaiM37dWcUZHDykgX1AhhsU6XmFEJrFeYm7/TA
         axGPcl0AaYLDiQkJLS+KERQYsrCD/bQuRUK4bmUa9QSYUeVcv5W34GjAKbnq1ZbGZHVw
         iR/nxuZDIFFuW5+7oY34AyTgAfmQE2DCTPEl+RhdU+iRgk6duuh7jqeTpz7liOW4D/ti
         PI2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=N8RlWv2x;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id g15si504873otj.168.2019.06.06.20.37.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 20:37:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=N8RlWv2x;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf9dc050000>; Thu, 06 Jun 2019 20:37:41 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 06 Jun 2019 20:37:43 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 06 Jun 2019 20:37:43 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 03:37:43 +0000
Subject: Re: [PATCH v2 hmm 09/11] mm/hmm: Poison hmm_range during unregister
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "Ralph
 Campbell" <rcampbell@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-10-jgg@ziepe.ca>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <c00da0f2-b4b8-813b-0441-a50d4de9d8be@nvidia.com>
Date: Thu, 6 Jun 2019 20:37:42 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-10-jgg@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559878661; bh=hnXE0MxsnGUyN9sEUkzf3xpow50f6NZj1i458LDKMRY=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=N8RlWv2xDfEYSaLNfEgPO8HsRXdEbSEQyaFJIissVJcwJeh7EjuWKFbHWPoKUPURH
	 Oyg92crCE7PWV1skDH1Wku3scQRSMDd14bfAWi5o86TBFjDfjyWCzOrPaqDnbTl4zn
	 XqRZYR7aWKsZMbWTAsMzcVZLDJEioManv8HzxlJokeKWhxh4uXeJ8hD2cstTzfUALU
	 Gc6Xqz2sKONzjUtI1v4WwoaBYZqbiZZHCU1iDWDMoIw3CAJmVktcqr85nR0n6+VTZb
	 MTpSPfxRwhRMQQkkeqmrf4zQs27WL6ZQjPKzghI1xvJN5/Jzgu5WHMLVh2S52fWdU+
	 FRSERUmJs5aWA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
>=20
> Trying to misuse a range outside its lifetime is a kernel bug. Use WARN_O=
N
> and poison bytes to detect this condition.
>=20
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> ---
> v2
> - Keep range start/end valid after unregistration (Jerome)
> ---
>  mm/hmm.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 6802de7080d172..c2fecb3ecb11e1 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -937,7 +937,7 @@ void hmm_range_unregister(struct hmm_range *range)
>  	struct hmm *hmm =3D range->hmm;
> =20
>  	/* Sanity check this really should not happen. */

That comment can also be deleted, as it has the same meaning as
the WARN_ON() that you just added.

> -	if (hmm =3D=3D NULL || range->end <=3D range->start)
> +	if (WARN_ON(range->end <=3D range->start))
>  		return;
> =20
>  	mutex_lock(&hmm->lock);
> @@ -948,7 +948,10 @@ void hmm_range_unregister(struct hmm_range *range)
>  	range->valid =3D false;
>  	mmput(hmm->mm);
>  	hmm_put(hmm);
> -	range->hmm =3D NULL;
> +
> +	/* The range is now invalid, leave it poisoned. */

To be precise, we are poisoning the range's back pointer to it's
owning hmm instance.  Maybe this is clearer:

	/*
	 * The range is now invalid, so poison it's hmm pointer.=20
	 * Leave other range-> fields in place, for the caller's use.
	 */

...or something like that?

> +	range->valid =3D false;
> +	memset(&range->hmm, POISON_INUSE, sizeof(range->hmm));
>  }
>  EXPORT_SYMBOL(hmm_range_unregister);
> =20
>=20

The above are very minor documentation points, so:

    Reviewed-by: John Hubbard <jhubbard@nvidia.com>


thanks,
--=20
John Hubbard
NVIDIA

