Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A1EAC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:46:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F02EA208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:46:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="VluKSBvk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F02EA208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B3EE6B026E; Fri,  7 Jun 2019 16:46:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 864FF6B026F; Fri,  7 Jun 2019 16:46:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72C356B0270; Fri,  7 Jun 2019 16:46:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 54F1B6B026E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 16:46:35 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id w127so3181767ywe.6
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 13:46:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=+DzfkNN8iXOL7by8qMWBjVwFAYZtnua1XZdudIdSS1I=;
        b=s6xjde5Q1V9cTiZlDZf+QTUbKzdtOSkvJCaIu4+soG4Vb8sa4uEMYLVvnKeNner6c4
         ifaLLLqtY29OWljQD6qKWxjQPwHywroLQDUgoVC2uyXY+lrvgKwi9Wqmt49Kl9ikxDQE
         LFaDh3iOtWxJbGnpr/+hTvhhUeLo/xYzY57h8XcrUSKaVuBAB4DpTo4i3UpmmsUjxhqv
         5dzBP1ZoXWVwarGhlpmCfSx74HPxDgrWSruA8fWAOFILz1RcZjYDTHDUV2u3fYMZ0ONl
         l063+gLOMC6tazdEh9iHN+pV0+o8FLLS04PBA43yqcimj/19CwWRC8yjEJMk2q4Xfmd8
         YE1A==
X-Gm-Message-State: APjAAAUJ3VVyyPmXi4U4XJ1EXaotOVXvQx7JxswmxknWNwa3Pe5QIVMY
	0UU5snh7WpZrqjquzCzLr3A0wvbV2kMKpBtUz8k+Z92cjTSwkmhPQjo5j7lF9m5E4KoFuPPriKb
	OBRQFD98snu0AbujrGHJPFUbiAcj48FoHXK4tF5XjXpfRPeIwJl8U9vzQxdpMJNmMBQ==
X-Received: by 2002:a25:844c:: with SMTP id r12mr27291940ybm.229.1559940395121;
        Fri, 07 Jun 2019 13:46:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJAsZdVUmVSFzPA/FdNwX8SG/7FILpZ0vZgP9O1PKJoeQuIKvrCBwvSeI0xwZvl35JvZkG
X-Received: by 2002:a25:844c:: with SMTP id r12mr27291916ybm.229.1559940394286;
        Fri, 07 Jun 2019 13:46:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559940394; cv=none;
        d=google.com; s=arc-20160816;
        b=j5E5LbunIaLkR+Y2LmiSrrRdAZRdKbZ0fpEhlyY2lglVWeS9/SGWmkK08ErLS0emL6
         XZ+8XED3QrMSVF9STnkSb744YC43FyccLzIXdwx4rTrnNRbrgSYg/UuUNidbZEM1X9DF
         mYcevpPV0N/j0I2eIHKifTDXSpSO1O3ygH+ngFZK4eUVFtzNREDxBTyxn9wVtl9fLoPY
         ftwNKXZcqQQN/F5G200WZYe2EXrxBUQRCbth6wMitA88t7g8BmaWufWWQOI2JrHj16Ou
         L7tz5QEWU4ErxtCKUYi3lu04UV1OYpqLIWWih9mhZHeOPGzVwqURmIwhspY4N8bZLutk
         9uDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=+DzfkNN8iXOL7by8qMWBjVwFAYZtnua1XZdudIdSS1I=;
        b=Iw8u8gr0GIf26c2xTgq5eJi8EJ6Clse5AOIa4gJiTosxiZ34lvK2QjHlBBsCHZaJcg
         8LGOW60RhFtOf9/GyFlyoa0tf0C3CsxQi0ECrLWnVgyIdmf9M++93hn9UXhQL/5htwXu
         mzox3gRp9NctNzzdiCGFzwvS1EaSh7kgR4RTs8AiisxSqzpyTi4wLHMwMS5gEood+r9n
         WE+DyOL+fI82xD9KDZSqqw48POTmVgaNKjv6K5OgjOc0yf9et/kiPGwyz8Qcpj+qaqjI
         vddgv3gFueNcNLtK+/KWB3WfQqzYvuoqFQmFLw5KjHjd/YzmEV7nFGH6S84wht6bfE+s
         G5xQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=VluKSBvk;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id o20si1007090ywm.50.2019.06.07.13.46.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 13:46:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=VluKSBvk;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cfacd1a0000>; Fri, 07 Jun 2019 13:46:18 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 07 Jun 2019 13:46:33 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 07 Jun 2019 13:46:33 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 20:46:31 +0000
Subject: Re: [PATCH v2 hmm 09/11] mm/hmm: Poison hmm_range during unregister
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "John
 Hubbard" <jhubbard@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-10-jgg@ziepe.ca>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <96a2739f-6902-05be-7143-289b41c4304d@nvidia.com>
Date: Fri, 7 Jun 2019 13:46:30 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-10-jgg@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559940378; bh=+DzfkNN8iXOL7by8qMWBjVwFAYZtnua1XZdudIdSS1I=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=VluKSBvkfaYIX++zlv6XbGKYR777aYfJahPNKO/wmahQZbfZhQO0mclBAunQkei1x
	 cmaNgrzDDMriQDpXTunXqzxWpXX2n2UXyyFCSG3yr1peoDkbHDXEL2lhubMUXxqVpx
	 vflN1kbYMdCmz1XHBwtlcJK7eGpIO27Pznx1OsNID29nU27/Z8TKtxAqoQ4ZvR+NNG
	 y9lD95yLdEEDsDCmGy22bIUny2N5+9ttBIp9Ndq4vra/BLx9O57G9SALrAnL40nMhY
	 aeMl7wBddrI0belykCs3zCS0k7KMxawm1rABIt5Cn2NEifhgOtCyvgnknxVVQ+8WEt
	 tVh+oG5gKD+NQ==
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

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
> v2
> - Keep range start/end valid after unregistration (Jerome)
> ---
>   mm/hmm.c | 7 +++++--
>   1 file changed, 5 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 6802de7080d172..c2fecb3ecb11e1 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -937,7 +937,7 @@ void hmm_range_unregister(struct hmm_range *range)
>   	struct hmm *hmm =3D range->hmm;
>  =20
>   	/* Sanity check this really should not happen. */
> -	if (hmm =3D=3D NULL || range->end <=3D range->start)
> +	if (WARN_ON(range->end <=3D range->start))
>   		return;

WARN_ON() is definitely better than silent return but I wonder how
useful it is since the caller shouldn't be modifying the hmm_range
once it is registered. Other fields could be changed too...

>   	mutex_lock(&hmm->lock);
> @@ -948,7 +948,10 @@ void hmm_range_unregister(struct hmm_range *range)
>   	range->valid =3D false;
>   	mmput(hmm->mm);
>   	hmm_put(hmm);
> -	range->hmm =3D NULL;
> +
> +	/* The range is now invalid, leave it poisoned. */
> +	range->valid =3D false;
> +	memset(&range->hmm, POISON_INUSE, sizeof(range->hmm));
>   }
>   EXPORT_SYMBOL(hmm_range_unregister);
>  =20
>=20

