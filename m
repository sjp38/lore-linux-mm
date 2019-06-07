Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6E1BC28EBD
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 03:07:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F1D0206DF
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 03:07:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="rcX/eN6S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F1D0206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 763616B0003; Thu,  6 Jun 2019 23:07:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 713A66B0008; Thu,  6 Jun 2019 23:07:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B39E6B000A; Thu,  6 Jun 2019 23:07:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F9896B0003
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 23:07:00 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id d12so160869oic.10
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 20:07:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=70o7ZS6CN7LiHClrr+qrAlqXgM2IDbvgx4VtZ9W6MfI=;
        b=nnCF+s+tzT4cfEl9LAb0BQqhYzLG/oJwKgsudREjkDKbJEFgmzdoCpSh9MLzE6pyCA
         mOxqxQcoMbxiK5uwA1VnrhwZlsp25cYJKRWecGK1jfcxNcx5e6RLTDhX7OLGvTUlJwNp
         7Kl3nPYiws5qY8EE5ThzabkNfTBmWo743RiaAqww08fx+udjfC1Za8Njqxtus2TCEhh6
         FCKuu4EwJK9LNG2vDYFGRkOcKKR4a4oVwmQU0a6e0y4iTJvbc1Nd/cmwqkemCHIjNIGb
         D3L4TKTVwrVB/m9CkU1COwQ+vuBFwtyVXO0AK4sf2Kcr7iMYuZVgyQW7DyNjH9Yg7Lyt
         xOPg==
X-Gm-Message-State: APjAAAVrSrFei+ny43jFIh3G8SZXIPyTnLP2z8oqLc1w0U/WXuxTBgKY
	m2iObl+597+n/7GV94J1UMjQKuoJkyixdNnmM7ssBpgZHlL+p2aBDA0jDjLa2z9Wn+Jw6XHCCCU
	it+ikzmQJbxuXZOy90/Gp9gLMDJS+XY7b2dz5I8624k5h9JByjRFerIMsZGm/pEvDMA==
X-Received: by 2002:a9d:6f01:: with SMTP id n1mr11021275otq.276.1559876819779;
        Thu, 06 Jun 2019 20:06:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzBH7LZrr1iZThtvki4OV2DRbTiK2I9XYydhRkYriQcF+wImugSYOxBawWmMzfxRQgB/s7
X-Received: by 2002:a9d:6f01:: with SMTP id n1mr11021242otq.276.1559876819033;
        Thu, 06 Jun 2019 20:06:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559876819; cv=none;
        d=google.com; s=arc-20160816;
        b=L0B8ed197WGrYmqJ3hcgcvQFaM4HGdW3HUnDeOhTrWm767fZDtjNe6JSs93KRZ9BRV
         aDhOkc8Y7ECojWjvEu26e5lnJOjNW1+yljR0XeOhC8M1sUyGUBqAGmVc4xoRBTWzuxOv
         BgMXJ9reezO2pB8A1gfhtCmp5T/WnhDbMDtGB6cFPaoLx+H2puhQ/JZKO9k41cX8n2HJ
         C5zNjTXEv5jqfZZ0iLSbDbo9NI4Lvrw2wI9k7hCP4boaEEzB5zoXxa0Ds0c1LIdj1UTW
         o3QBc7qxIoG2Vg+OCLmHtvUVHtHnapAysgLNcL05gw+DJiQXR2uGfs33A9fi7tOOnodG
         LdEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=70o7ZS6CN7LiHClrr+qrAlqXgM2IDbvgx4VtZ9W6MfI=;
        b=dXRyyFLb/3gyPlb0m3+/j69Yd6rx+GT9pFO1sJ8dVFCfv3f3EqIB7xtQPnNz/14L2L
         iqd6xQVzrduneCVlFAL3BObSYjBjwDd03LcevHXi9Fg0XfVEuSqG5568Tuzb7FMZUXmV
         ykjK/nsqNkxSwxwsz1gfqUYRXPOXa8rCP/+xfalj2kQ6OMM2zgr5Ev0B6fhQjE/7PV4I
         qbY+Bw5ILMHrUaGW8JUW0tVauuWocG8TjFjiDjl7iQq4G0lnGk5Pa2iHY5hcC5SGsAAs
         L3zkf0pcQctY58UeiOwfiZhWwwOM86plXGaw27CwlVRWFJy10g3VpmKv9pXzqBsLT7Oz
         QssA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="rcX/eN6S";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id k205si626065oih.182.2019.06.06.20.06.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 20:06:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="rcX/eN6S";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf9d4d00000>; Thu, 06 Jun 2019 20:06:56 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 06 Jun 2019 20:06:58 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 06 Jun 2019 20:06:58 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 03:06:53 +0000
Subject: Re: [PATCH v2 hmm 05/11] mm/hmm: Remove duplicate condition test
 before wait_event_timeout
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "Ralph
 Campbell" <rcampbell@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-6-jgg@ziepe.ca>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <86962e22-88b1-c1bf-d704-d5a5053fa100@nvidia.com>
Date: Thu, 6 Jun 2019 20:06:52 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-6-jgg@ziepe.ca>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559876816; bh=70o7ZS6CN7LiHClrr+qrAlqXgM2IDbvgx4VtZ9W6MfI=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=rcX/eN6SVVb8ntWY1bOCeo2lBWMdj/N0N59oEGCkUxTi+CQysb8+Bm72YdWdznjXv
	 uMOqdy7CCjAssMyL0E+Wpqk7VGurL+Y48RwVXOiE8ewwA1U8PM/9NZJE3xkitfRbtm
	 2R0tTcKErsh4WABPJBiUUMm4qcT3D6UQGwZHfks5mqPWmj/hL5PzkvqZmoGIUzQXf3
	 h9jcXai0x0Nv32FWsJ/50DqS9x6531hNChV2FjPMMCXA0i+ZaV8RiLIfBNHoaTVury
	 k8sBx3IJeGnHRXFDISxYSujNyNbyr19jEa+rGYPb4C2q0guYMp9a4Ef1nDI5HcNP4z
	 RX+XUhHxNd0JQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
>=20
> The wait_event_timeout macro already tests the condition as its first
> action, so there is no reason to open code another version of this, all
> that does is skip the might_sleep() debugging in common cases, which is
> not helpful.
>=20
> Further, based on prior patches, we can no simplify the required conditio=
n

                                          "now simplify"

> test:
>  - If range is valid memory then so is range->hmm
>  - If hmm_release() has run then range->valid is set to false
>    at the same time as dead, so no reason to check both.
>  - A valid hmm has a valid hmm->mm.
>=20
> Also, add the READ_ONCE for range->valid as there is no lock held here.
>=20
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> ---
>  include/linux/hmm.h | 12 ++----------
>  1 file changed, 2 insertions(+), 10 deletions(-)
>=20
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 4ee3acabe5ed22..2ab35b40992b24 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -218,17 +218,9 @@ static inline unsigned long hmm_range_page_size(cons=
t struct hmm_range *range)
>  static inline bool hmm_range_wait_until_valid(struct hmm_range *range,
>  					      unsigned long timeout)
>  {
> -	/* Check if mm is dead ? */
> -	if (range->hmm =3D=3D NULL || range->hmm->dead || range->hmm->mm =3D=3D=
 NULL) {
> -		range->valid =3D false;
> -		return false;
> -	}
> -	if (range->valid)
> -		return true;
> -	wait_event_timeout(range->hmm->wq, range->valid || range->hmm->dead,
> +	wait_event_timeout(range->hmm->wq, range->valid,
>  			   msecs_to_jiffies(timeout));
> -	/* Return current valid status just in case we get lucky */
> -	return range->valid;
> +	return READ_ONCE(range->valid);

Just to ensure that I actually understand the model: I'm assuming that the=
=20
READ_ONCE is there solely to ensure that range->valid is read *after* the
wait_event_timeout() returns. Is that correct?


>  }
> =20
>  /*
>=20

In any case, it looks good, so:

    Reviewed-by: John Hubbard <jhubbard@nvidia.com>

thanks,
--=20
John Hubbard
NVIDIA

