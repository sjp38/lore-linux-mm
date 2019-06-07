Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57333C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:49:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3701208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:49:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="UJz2Qt1Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3701208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 863D46B026E; Fri,  7 Jun 2019 16:49:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7ECE76B026F; Fri,  7 Jun 2019 16:49:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68D326B0270; Fri,  7 Jun 2019 16:49:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4306B6B026E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 16:49:10 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id v15so3091611ybe.13
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 13:49:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=oGeyU71GSCfi4k4k8mSueh4JEltagVCe/KlNbvsSutg=;
        b=F5WobOglWqWKK1c7UVzYqHGZSD+ZkFphU8ifq8KL4v2XwE3iy4sOXw23HkMIm4kvrp
         UiKawC1DtncWQDO8a4QF+87/SKwCpNI43hrzrSSqVIIxVjWilbSHIjRecM4Et21NORhT
         OiKs3Ubwo7F0V1sv0qeHeRkbUnC/pDOoFG1wZNQiDcvONFNA8QtT0byghJaZIZuk5pKq
         FIQZzS0FH6Z9lewNS3O0BN8OtVjt0O7WYfXDHqS/7TSrBbtAhFl4xgTJS5hZ33jK6Pm+
         EMOT7JX54W2QB9iL+vVZIXwatGGMNv4I4edrqzPXBKuVuQgocGb4nBUL0//6CHPPyd2O
         hpcA==
X-Gm-Message-State: APjAAAVzJT8WagaircleK1jEMQufnIhAbGfBB1Kl7hwM9MucNvO+SbQP
	gbu6ifzsEy6Ypw0wn7XcczF8I5HS+ueZLyhUq1y6/lMzNzZ/PYMAHYJD3IEZtiKCKAXmt2LOe3u
	t/8QjIus+9cp3pTQAfKByoRawXXaSmGVFR5G+uiDoEJxhH+P0satd2Tgpcf9h6Y944Q==
X-Received: by 2002:a25:7bc4:: with SMTP id w187mr19787474ybc.122.1559940550026;
        Fri, 07 Jun 2019 13:49:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUQY7apEzy3ipWZFEC1V/CftW1INSmdyhl9/9cb5NWrEjjnO8JO7Hqj/7EmJvuUYY64fMk
X-Received: by 2002:a25:7bc4:: with SMTP id w187mr19787454ybc.122.1559940549492;
        Fri, 07 Jun 2019 13:49:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559940549; cv=none;
        d=google.com; s=arc-20160816;
        b=lhWiqGdUrx8BJrSt/y+VnC3f3HUr94OIxDbDP8FJT1kjEqX3TrsvV7DVl7MtG48jLV
         qZzYXDwNgaJvqbtNS23PvrTfb3JuT9SppcJu3tgRjqiR4B5QAP9dVnAv1jOUib2r6eTV
         ylwzBCCfRBajiSwMUVv82qddNPDJJmm7vIeL1igRaj64my+itc1w27JSD9EOGHP8XGgL
         2Vs0j/Tm4EqYTXRV54PrDfxWFfNYlaeTGFfVS/2qbnwtIpmrmNIfmA8iOhZqwG74muwd
         lTI1WXSoq01LpIPw9RXZjkEW+eCPP/JKMfSPJpOya3aJQo0ysRe7DTacpf9VhDtO5ler
         cMoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=oGeyU71GSCfi4k4k8mSueh4JEltagVCe/KlNbvsSutg=;
        b=hQOxfjcfuabcSIcptDjcYIZc1YsnDx/2OA6xhYE0pirGPLigS+EuDxmxfno8qaeI8f
         k3bbvdW7i8sQ5nAXpJIjiQr06a2c96TYPeoWhSk5Mc3OksSJglCgEGewEbLLp/ehhTuk
         SpPi5XRLEmYgGLgiIWnA1Q7wBqhWHiSnI/CKDkygQneh1GMorMnFmODBu8+dyo8V7+zK
         8YZ3rSu/2aQxYuwu7CQ7pATYVaTTPCzBBUorXcJPq02TEFaAFtL6uObVsmOfS7/OlJn0
         NEzaSRwbLJExkaxLumjQCeH1ht31w9gLl4CAg06hZa3KTL03JLvKB+G/tnTESjL7bqzy
         f0Pg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=UJz2Qt1Q;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id v2si1100061ywg.387.2019.06.07.13.49.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 13:49:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=UJz2Qt1Q;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cfacdc20001>; Fri, 07 Jun 2019 13:49:06 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 07 Jun 2019 13:49:08 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 07 Jun 2019 13:49:08 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 20:49:06 +0000
Subject: Re: [PATCH v2 hmm 10/11] mm/hmm: Do not use list*_rcu() for
 hmm->ranges
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "John
 Hubbard" <jhubbard@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-11-jgg@ziepe.ca>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <57cf91db-bebe-24f0-29c3-64274f10d10b@nvidia.com>
Date: Fri, 7 Jun 2019 13:49:06 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-11-jgg@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559940546; bh=oGeyU71GSCfi4k4k8mSueh4JEltagVCe/KlNbvsSutg=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=UJz2Qt1QfanMEhOyt/3R/g2DHXV8MDxZ8h5tNqHZXgifBkiWanoofMHj0WGWGojU3
	 r7hVfwPkjuzgQD7LU06bneMH68aqOd5ZgdE2TfB1EmRGNULUoGCRnsfVCsdcub+iS1
	 03SomttNcSlu+bgApB2KFIb/oMQ8U6aQKkg+bakwP+c+sQwjrKCDv8TUTDpkPUHIMr
	 sGnkKrGR06RJOx8WxR7boji2N9rK6vQxJGwimzGESBTMzTX7Rla6rzRRhoGVTpbSc+
	 pJlxWklk2KTdXTtn3LcrHxzebmMdPEOIuDL28O14ysFKMaSnkp4n1nQImnJoYkwMRl
	 ITLcdbPEakgYg==
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

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
>   mm/hmm.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index c2fecb3ecb11e1..709d138dd49027 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -911,7 +911,7 @@ int hmm_range_register(struct hmm_range *range,
>   	mutex_lock(&hmm->lock);
>  =20
>   	range->hmm =3D hmm;
> -	list_add_rcu(&range->list, &hmm->ranges);
> +	list_add(&range->list, &hmm->ranges);
>  =20
>   	/*
>   	 * If there are any concurrent notifiers we have to wait for them for
> @@ -941,7 +941,7 @@ void hmm_range_unregister(struct hmm_range *range)
>   		return;
>  =20
>   	mutex_lock(&hmm->lock);
> -	list_del_rcu(&range->list);
> +	list_del(&range->list);
>   	mutex_unlock(&hmm->lock);
>  =20
>   	/* Drop reference taken by hmm_range_register() */
>=20

