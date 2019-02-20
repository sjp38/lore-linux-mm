Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 611D4C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 21:59:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E426A2086C
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 21:59:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="di04P1Ys"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E426A2086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C1DB8E0034; Wed, 20 Feb 2019 16:59:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 471E48E0002; Wed, 20 Feb 2019 16:59:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 339838E0034; Wed, 20 Feb 2019 16:59:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 00B0D8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 16:59:26 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id h2so15972904ywm.11
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 13:59:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=2CWmRVjAKuFpLeN7gIy+VKg38JlKc0LpsSsqnsgT/i8=;
        b=psLwEtC1xM/OnsUVZLhZYOL25BWJo+cnmEdgZRw+iB0sXdkFBKBY8o1h/WIRkkmX4P
         tFgVtDXxebgkWnCWWZe1/QAxrBu8uoKEtqe5RgUJX0y0iFUeKKH8VjrU5DigzxrZaV3i
         Dtx/xVYhrlCOSf9lMIRrWlflBlhcv+lxTlZbW2WZP3trg1okl9a1ZCviOAoZHYWSWhsk
         LvvVsPr7XaEFkeBjtHelNMlCy7wqb3YNYsk6F9fTLaLSfdpQUBu3y1/YsIxf90EzO4L1
         NUywP42BPoHZWsuy02MEFFiDF6IPh+to5FppTAQBY8+uoGseI2SiaknwYOrN1z0mN7U9
         Kwpg==
X-Gm-Message-State: AHQUAubbmbnRPiK3LZSX/WVCz9v1nHsYBEx7ODIwGXrSu4x7bsaiYsZO
	81giW20qL/MHwWkTmAvgpe35kjkqahCjpsMvBsvo6fK6bBZU8dQFopk1SJJA00OgvMQHdipBJ6g
	s62kLbnsVGJ03ZG5btUMq8awm7TAWW/t4WQz0lht00dGGYub20tHEq5Y58zJTuSX56w==
X-Received: by 2002:a0d:e193:: with SMTP id k141mr30269567ywe.166.1550699966644;
        Wed, 20 Feb 2019 13:59:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iaa+FY7K+L2h3N6JcZUwLNzb7gIg4ZEtdUxGUhecni8ToLAKq7hN9h5phUz8iJAUevp1gUC
X-Received: by 2002:a0d:e193:: with SMTP id k141mr30269527ywe.166.1550699965741;
        Wed, 20 Feb 2019 13:59:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550699965; cv=none;
        d=google.com; s=arc-20160816;
        b=Pw2l5WiclLnovyEns80m6xwLYvpWk1blKjM+8tfTOckZrK7ZKXFP58pGG7tH+Y9PU7
         GFyWVJQk/+O2fUlQ0CXVtVE8+hioZLRt2b3lWvXdmAKzNGuGDuDK0veQiUESMQNh6ykg
         DMqUTH+k8eYPTB8Ln0CDD+Sw+2NrrDFU7urFR/HNZ/A5Sbynr6tcgUZtsiaHJrL2/I8m
         ngL7FHl9Wn0z+nfK+b/xUZ2w0qKHR5GQXz9W2yrRaTkKkQJHmv3ar7evy9xxHmyY91U8
         KYIiY87CC2BuebVeZFpwAG6dt0GfltvSJB72+8kIjsLufupakmNoL+WaU1L9gPIt5tUL
         V9nA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=2CWmRVjAKuFpLeN7gIy+VKg38JlKc0LpsSsqnsgT/i8=;
        b=SGOFImvMoAOxJzFbesNs9Nuk2AVlOP9PoWfOiX07SmOrvZhZ0rkhs69JHFWeEQIJhE
         o+yS28TTA8prr+NcrHa1o6RiFRanJlYCmdRVr0vkLnC4m/5tjq/ZkuRX+l2kRaGy09fU
         uQPnpZJT35eIDbItib6ypEGINMFVUCo9H7mTchzdLS2eOSSo/AnZpWdTZRkfZIi0/WF2
         vsxUOyr+vbR4q6sPpkeC3rk//R71qkzuM+sKW5ge8tKCbbBDu4uxVqWIEJ4JFjvVu6au
         6gmB1SfYxT0CFqkR0h8j+cuWGLiVlClz2lNXxS6u11qBYbTwWb3w7Ii6PAy3rRlsdavJ
         35+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=di04P1Ys;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id k3si11705671ybm.5.2019.02.20.13.59.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 13:59:25 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=di04P1Ys;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6dcdc20001>; Wed, 20 Feb 2019 13:59:30 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 20 Feb 2019 13:59:24 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 20 Feb 2019 13:59:24 -0800
Received: from [10.2.169.124] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Wed, 20 Feb
 2019 21:59:24 +0000
Subject: Re: [PATCH 10/10] mm/hmm: add helpers for driver to safely take the
 mmap_sem
To: <jglisse@redhat.com>, <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190129165428.3931-11-jglisse@redhat.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <16e62992-c937-6b05-ae37-a287294c0005@nvidia.com>
Date: Wed, 20 Feb 2019 13:59:13 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190129165428.3931-11-jglisse@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550699970; bh=2CWmRVjAKuFpLeN7gIy+VKg38JlKc0LpsSsqnsgT/i8=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=di04P1YswP5l7urY6V2cWhoJKcacLXFf0VSLnRkmKEubu1ncXJCg3DvvXm6Bcv3ZT
	 spPxgxSn7FTu5EbskxETXpUSQCSGbOaMvHkDsuVZsLwoJD5xR/vx7T7Al6sSrqu7bV
	 CvZy4VrWDJFbYVWz4R7IoY7Pivsk4y+bFxTeqoA1XH416J4+qrz8AUWzu9hWhhCkSa
	 6jX3118IpjWSBZIxIG9Y/IYU+cYV3bxCGTh/lqf+cQHtHupO7cBl9Nk5tXw9+sV2I6
	 PNN7g1r88FMJQUTZr39mjf2edLDcSi5/SP78PAfD0jGsPACFtBh6g017U6QZTJHqaZ
	 ADDuQatFhzE0Q==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/29/19 8:54 AM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> The device driver context which holds reference to mirror and thus to
> core hmm struct might outlive the mm against which it was created. To
> avoid every driver to check for that case provide an helper that check
> if mm is still alive and take the mmap_sem in read mode if so. If the
> mm have been destroy (mmu_notifier release call back did happen) then
> we return -EINVAL so that calling code knows that it is trying to do
> something against a mm that is no longer valid.
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>   include/linux/hmm.h | 50 ++++++++++++++++++++++++++++++++++++++++++---
>   1 file changed, 47 insertions(+), 3 deletions(-)
>=20
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index b3850297352f..4a1454e3efba 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -438,6 +438,50 @@ struct hmm_mirror {
>   int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm=
);
>   void hmm_mirror_unregister(struct hmm_mirror *mirror);
>  =20
> +/*
> + * hmm_mirror_mm_down_read() - lock the mmap_sem in read mode
> + * @mirror: the HMM mm mirror for which we want to lock the mmap_sem
> + * Returns: -EINVAL if the mm is dead, 0 otherwise (lock taken).
> + *
> + * The device driver context which holds reference to mirror and thus to=
 core
> + * hmm struct might outlive the mm against which it was created. To avoi=
d every
> + * driver to check for that case provide an helper that check if mm is s=
till
> + * alive and take the mmap_sem in read mode if so. If the mm have been d=
estroy
> + * (mmu_notifier release call back did happen) then we return -EINVAL so=
 that
> + * calling code knows that it is trying to do something against a mm tha=
t is
> + * no longer valid.
> + */

Hi Jerome,

Are you thinking that, throughout the HMM API, there is a problem that
the mm may have gone away, and so driver code needs to be littered with
checks to ensure that mm is non-NULL? If so, why doesn't HMM take a
reference on mm->count?

This solution here cannot work. I think you'd need refcounting in order
to avoid this kind of problem. Just doing a check will always be open to
races (see below).


> +static inline int hmm_mirror_mm_down_read(struct hmm_mirror *mirror)
> +{
> +	struct mm_struct *mm;
> +
> +	/* Sanity check ... */
> +	if (!mirror || !mirror->hmm)
> +		return -EINVAL;
> +	/*
> +	 * Before trying to take the mmap_sem make sure the mm is still
> +	 * alive as device driver context might outlive the mm lifetime.
> +	 *
> +	 * FIXME: should we also check for mm that outlive its owning
> +	 * task ?
> +	 */
> +	mm =3D READ_ONCE(mirror->hmm->mm);
> +	if (mirror->hmm->dead || !mm)
> +		return -EINVAL;
> +

Nothing really prevents mirror->hmm->mm from changing to NULL right here.

> +	down_read(&mm->mmap_sem);
> +	return 0;
> +}
> +

...maybe better to just drop this patch from the series, until we see a
pattern of uses in the calling code.

thanks,
--=20
John Hubbard
NVIDIA

