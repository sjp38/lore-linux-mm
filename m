Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F978C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 20:54:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C1772184C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 20:54:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="BFuqPlz2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C1772184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAC6E6B0282; Thu, 28 Mar 2019 16:54:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C36DA6B0284; Thu, 28 Mar 2019 16:54:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD70F6B0285; Thu, 28 Mar 2019 16:54:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8544A6B0282
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 16:54:04 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id y194so135242yby.2
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 13:54:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=66ATySaHlVECGh1E7+UM9QuEPXamIu3gtSuhG9bf+E8=;
        b=i4X2YDgsd1qCbTH2kJoKIrl1y9Jt6Q1ZOv204hKAGaBGyXvX2xPZCstw7T/+YDe+OY
         Rx3z0KDZ1hpt3oGAmq6ms8rIfhVKJ8qxj4sxAFR9Z0mC/Zw4ENksIPwME/9MRHVPYX/e
         ueNdx4o+PSThHBCTHYPqKeWKLjsS9VRatKp0zNHMOHXvJ20kY8lp3i2RDS3W6Rt9HU0M
         sVtJ98aXJG9PsTosnR8NnP6RM23IbDsqdMwtUiXRPQpLyQyYsJ+xFGl8fq35oqU/c13a
         xfXbrub0P5xd98hWBCWhfdEIW/gJKjLI/aPASv7gHwI4eU5wr1q3CBuJhIww0qe4H7Lv
         y86w==
X-Gm-Message-State: APjAAAXzIW9KfxOXNXZX5BgpEW835onGW4nnaOfEDyjv0YfuXIfZ+n9h
	P+q6DIlZE/0ZCCzPfV+ebSkoriJGlzlOPL6605dDLd8E5Je73JLS/cflYbIwChqUf/mfhblqQKz
	XPE0JAzdIzre+1qmw1sBPVvyoW1V+ysq5fDKIsoVyxBGIFcUwXgI6Y0SEUNYzpfHicg==
X-Received: by 2002:a25:10d6:: with SMTP id 205mr38569627ybq.69.1553806444213;
        Thu, 28 Mar 2019 13:54:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyxK8wKkw6LEiq52xsIMkUvVfvbWp81y9uV7WQForYzUvXzWnpUtij6jQQxImkuSjOS/rZg
X-Received: by 2002:a25:10d6:: with SMTP id 205mr38569589ybq.69.1553806443535;
        Thu, 28 Mar 2019 13:54:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553806443; cv=none;
        d=google.com; s=arc-20160816;
        b=HiQyLT5TQmYHINcNotcWwn4T9Sog2vkSGxT9H+emG78TuIlpRwDwgcJczEUBLv6KKU
         q0e2DC6L8SHfy1yWqQ8JTtEXtWr2zp3jfLHY5CVGRqq8j5xuwHFpDnknn2+hoGAR6Rjs
         wBYNhNQoeNZjhzzDykyiRkTM0k34tg914ywK1gS/0JpEtlJF2j6sg2e+tHhsXy/NOM8W
         A7ABgnmtQykf96JM0eTseuCjHV3eRRGcNj7KgXAVJAsjoyceqnjpLNNHQwNq/Jk1Jqu/
         gehs/U/2MeXWweNerpRMU6Ljc7hOuvcS2HCP7ml9Kv1Un8mzXvoledqwD4njrK3zJtps
         xFWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=66ATySaHlVECGh1E7+UM9QuEPXamIu3gtSuhG9bf+E8=;
        b=gyVhYdozcv1wGlp2OX8NYuAda+cmGh/f/d66NagzzqH8pbdjM6zDypgHHkR2fNsy3D
         UVQgF2ohkV6R+xK/AqSXiSIvR0KhNO5GB8LfTpRFH3vRQvg1pm+hL2yJkPs+yuxATRqq
         52Sgf/C+968vBc4dtABI+mVyzXwMzhR3m7qq/WGkJqKc56RWe1uu++cUOflSHOr3utdH
         GYj6tIwJmfWpCN31pI7yqSF3yV8CxngzhxXBPYTMq9OeEs5WEtqyze3mkvyYJ/BUWhg6
         IVIwrQekHHVs69cjdzoR4w2ksllNWJj9O0IFCRbLptKv3ozL0/65rDdWLCmK75ECMblG
         8CxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=BFuqPlz2;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id g3si61834ywg.303.2019.03.28.13.54.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 13:54:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=BFuqPlz2;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9d346d0001>; Thu, 28 Mar 2019 13:54:06 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 28 Mar 2019 13:54:02 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 28 Mar 2019 13:54:02 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 28 Mar
 2019 20:54:02 +0000
Subject: Re: [PATCH v2 10/11] mm/hmm: add helpers for driver to safely take
 the mmap_sem v2
To: <jglisse@redhat.com>, <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-11-jglisse@redhat.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <9df742eb-61ca-3629-a5f4-8ad1244ff840@nvidia.com>
Date: Thu, 28 Mar 2019 13:54:01 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190325144011.10560-11-jglisse@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553806446; bh=66ATySaHlVECGh1E7+UM9QuEPXamIu3gtSuhG9bf+E8=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=BFuqPlz2E3sxwSyIDD9EWu/eD+fvDokJzqkj9BM3Dd7891jCCptci248hOcEuLhLf
	 Ozn4DDhBLtg2swX3xez9IbLAnDq3F0fVZTwvNL4Tvvuhid1Rburr1dU3p30nMktUSS
	 e4H3lB4yQQ7tPrT3S1TtKHIiQyzrsFB0KvE6IUzBhJY368xVGl4oNlLpNaj3BhMw9R
	 NJkiGuKFLft21ll+xlAYtB5J8L/IrbUX+G5YBVMDf0Yd+BST/uebj9PZSVlarH+s1Y
	 SGR8bxM1Fq2m+OZi/SSHg99kBM+UnoXv6F4STZN8cDbq/cDcw2LZpkxo+N+ZXRFjB8
	 2iquhi8a6waBg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
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
> Changes since v1:
>     - removed bunch of useless check (if API is use with bogus argument
>       better to fail loudly so user fix their code)
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/hmm.h | 50 ++++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 47 insertions(+), 3 deletions(-)
>=20
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index f3b919b04eda..5f9deaeb9d77 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -438,6 +438,50 @@ struct hmm_mirror {
>  int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)=
;
>  void hmm_mirror_unregister(struct hmm_mirror *mirror);
> =20
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
> +static inline int hmm_mirror_mm_down_read(struct hmm_mirror *mirror)

Hi Jerome,

Let's please not do this. There are at least two problems here:

1. The hmm_mirror_mm_down_read() wrapper around down_read() requires a=20
return value. This is counter to how locking is normally done: callers do
not normally have to check the return value of most locks (other than
trylocks). And sure enough, your own code below doesn't check the return va=
lue.
That is a pretty good illustration of why not to do this.

2. This is a weird place to randomly check for semi-unrelated state, such=20
as "is HMM still alive". By that I mean, if you have to detect a problem
at down_read() time, then the problem could have existed both before and
after the call to this wrapper. So it is providing a false sense of securit=
y,
and it is therefore actually undesirable to add the code.

If you insist on having this wrapper, I think it should have approximately=
=20
this form:

void hmm_mirror_mm_down_read(...)
{
	WARN_ON(...)
	down_read(...)
}=20

> +{
> +	struct mm_struct *mm;
> +
> +	/* Sanity check ... */
> +	if (!mirror || !mirror->hmm)
> +		return -EINVAL;
> +	/*
> +	 * Before trying to take the mmap_sem make sure the mm is still
> +	 * alive as device driver context might outlive the mm lifetime.

Let's find another way, and a better place, to solve this problem.
Ref counting?

> +	 *
> +	 * FIXME: should we also check for mm that outlive its owning
> +	 * task ?
> +	 */
> +	mm =3D READ_ONCE(mirror->hmm->mm);
> +	if (mirror->hmm->dead || !mm)
> +		return -EINVAL;
> +
> +	down_read(&mm->mmap_sem);
> +	return 0;
> +}
> +
> +/*
> + * hmm_mirror_mm_up_read() - unlock the mmap_sem from read mode
> + * @mirror: the HMM mm mirror for which we want to lock the mmap_sem
> + */
> +static inline void hmm_mirror_mm_up_read(struct hmm_mirror *mirror)
> +{
> +	up_read(&mirror->hmm->mm->mmap_sem);
> +}
> +
> =20
>  /*
>   * To snapshot the CPU page table you first have to call hmm_range_regis=
ter()
> @@ -463,7 +507,7 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror)=
;
>   *          if (ret)
>   *              return ret;
>   *
> - *          down_read(mm->mmap_sem);
> + *          hmm_mirror_mm_down_read(mirror);

See? The normal down_read() code never needs to check a return value, so wh=
en
someone does a "simple" upgrade, it introduces a fatal bug here: if the wra=
pper
returns early, then the caller proceeds without having acquired the mmap_se=
m.

>   *      again:
>   *
>   *          if (!hmm_range_wait_until_valid(&range, TIMEOUT)) {
> @@ -476,13 +520,13 @@ void hmm_mirror_unregister(struct hmm_mirror *mirro=
r);
>   *
>   *          ret =3D hmm_range_snapshot(&range); or hmm_range_fault(&rang=
e);
>   *          if (ret =3D=3D -EAGAIN) {
> - *              down_read(mm->mmap_sem);
> + *              hmm_mirror_mm_down_read(mirror);

Same problem here.


thanks,
--=20
John Hubbard
NVIDIA

