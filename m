Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D6C3C28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 03:29:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4D552080C
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 03:29:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="AHwcMydK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4D552080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BA626B0008; Thu,  6 Jun 2019 23:29:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46A936B000A; Thu,  6 Jun 2019 23:29:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 380D56B000E; Thu,  6 Jun 2019 23:29:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0FAA76B0008
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 23:29:15 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id n19so322665ota.14
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 20:29:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=/7QlQ0a6Qyg58unwdWuoBgEG7TwvTAAHiFUhlj29yto=;
        b=Qm62D+riqFi4Gl4CyY9FZO+DsYWnUIsofbTtyLOR0W1qjzwofuNkhDNCCJKDSZZxon
         UqP1ddVCwdx3Nt5+YHBkzEmkXDwwPARdoo/Ip20Dwmxi1LUt6ehddju56RWnXjDFDF0I
         8gqJJDO6zHq26EhtNali5eSBj9Y0q90KTM1mbQ2zXRiMPjthgHsL84zHPnMXaAtiWyNw
         rCaKzbmZiQ5U4wBWXG0CAJLLvrDqnSlt5kq8dZ1D05e9gf7yUGqYh9oSgulpXEZSzsl/
         6jnws86TItVtfxuRm1/JtLstZMKN/UfQTtRZoz7tzqDDgakDa99VweQEP/VQr/U5L2GS
         6TMQ==
X-Gm-Message-State: APjAAAUvHS/qJCKEr3XNbDhEpsGQ/OQ2Gz6GGKec7Arbpy57TKP0oMb3
	siRIiHxULbiHnrv5Gl+EAZWp9JxeeQc+lZUhWUjyTqNzZbE9atU6g9mn3C9GbILUeyZxku4tIL8
	zJ4Ouc4ya19nKakg4OGwUjQy1prw4vuLe6SR4rzdk+dAVp48SLwf6YdtHaJ9RxyX0gw==
X-Received: by 2002:a9d:7:: with SMTP id 7mr18125001ota.248.1559878154710;
        Thu, 06 Jun 2019 20:29:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYWWRJrWNcljCdXwfniglr3SCOeAoK01mKJWWvDcFhOGSM7uRPjQ7and/2lGm6dqDp2sUm
X-Received: by 2002:a9d:7:: with SMTP id 7mr18124968ota.248.1559878154098;
        Thu, 06 Jun 2019 20:29:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559878154; cv=none;
        d=google.com; s=arc-20160816;
        b=eWEfzMTLGPjY7sp+vFIlJk9RbSnGoASPElNcDCUBIipj+VkTrEBli4nCKyUIdyW1NL
         8QP71tHJ02+o57dXGCxwedRmBv2hn9JwqhD41CbvoCdDWHAsNIe3I14HXBxQIG1IGqkb
         8tNdQ9eRDkgNMyNoP1S6AXnc+FNmvUsEyyOHDEz7eZS7/PjB0AMxuTeBYrVMsOPzUMNV
         sehckD3L2WwJBUpBB8vGICYRpRTll9khrZNFfP2K8Zw6sk+hT8y51yrM6QMT/T3UbhN9
         GIIrwGRGW03qYlAStFBDi28FX90EFY0yBmisi350dORIJMkgxrF53Vkbilbw/+F/J4XF
         EHPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=/7QlQ0a6Qyg58unwdWuoBgEG7TwvTAAHiFUhlj29yto=;
        b=xLkrogHx7s4qdxunmfqd/YIl2MpRCwqFULpMSpniZzr5ixvLyYRank1WJq10pvC6eD
         vzW9ZLXw/pE9ZgHeEbjQA7DExNdu42d0Aj5zyV/PcM4UDPfjHYMAk+P2GWi8vqGVLzPx
         aTOcb8PORgAD1B6aI0RbdTJj05GPm20rOUO+pp2VyOn+Ra9jPTWDR0r/SnFIoSIpSD1g
         1Iv/qReKnS49QcKlOTlB7gIUwy7PVL6acQitvAtGsG7bSizFWZTTWKhq6iy2BRZrX0rV
         nEfzUQFQAyAFkEZyCHb9ghzTywFTTJaHOlXRa1duUOKDZGjGna7DqZkkma1+dtqx4uXE
         iscA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=AHwcMydK;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id r126si656748oih.209.2019.06.06.20.29.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 20:29:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=AHwcMydK;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf9da070000>; Thu, 06 Jun 2019 20:29:11 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 06 Jun 2019 20:29:13 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 06 Jun 2019 20:29:13 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 03:29:11 +0000
Subject: Re: [PATCH v2 hmm 08/11] mm/hmm: Remove racy protection against
 double-unregistration
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "Ralph
 Campbell" <rcampbell@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-9-jgg@ziepe.ca>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <88400de9-e1ae-509b-718f-c6b0f726b14c@nvidia.com>
Date: Thu, 6 Jun 2019 20:29:10 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-9-jgg@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559878151; bh=/7QlQ0a6Qyg58unwdWuoBgEG7TwvTAAHiFUhlj29yto=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=AHwcMydKA1TgfD4RJqQNpr6LIUb1oEFYg5HcRS/+RnCuAUqh2s7TgUqrXgG40f3zE
	 CJbyyUnf+fEgpmDguw/J/dlmtapUWsYu4zRJwhG4lAk5KJ1z8hJaflgO4aauzkfIkD
	 9a2Ifmnv/v31YF4oOrOxY6hiYuHKUt7RRpZc6d4hjn0du6hzhHC9Jdt90HeTerzaxu
	 XC8jJUk3O8sSZPt55m8DSfEC3PSlY/vAH6Oghir+BEoKhkyJwlBGxXxfzp+mlg1D4M
	 7QMfUuHCK7AUT545Pbb+BjXQV38Ce4Tbu/TuqHGQ1UQDAgvY9y6XaDAZE3Q3dpYi+I
	 q2SN2/KlPavkA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
>=20
> No other register/unregister kernel API attempts to provide this kind of
> protection as it is inherently racy, so just drop it.
>=20
> Callers should provide their own protection, it appears nouveau already
> does, but just in case drop a debugging POISON.
>=20
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> ---
>  mm/hmm.c | 9 ++-------
>  1 file changed, 2 insertions(+), 7 deletions(-)
>=20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index c702cd72651b53..6802de7080d172 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -284,18 +284,13 @@ EXPORT_SYMBOL(hmm_mirror_register);
>   */
>  void hmm_mirror_unregister(struct hmm_mirror *mirror)
>  {
> -	struct hmm *hmm =3D READ_ONCE(mirror->hmm);
> -
> -	if (hmm =3D=3D NULL)
> -		return;
> +	struct hmm *hmm =3D mirror->hmm;
> =20
>  	down_write(&hmm->mirrors_sem);
>  	list_del_init(&mirror->list);
> -	/* To protect us against double unregister ... */
> -	mirror->hmm =3D NULL;
>  	up_write(&hmm->mirrors_sem);
> -
>  	hmm_put(hmm);
> +	memset(&mirror->hmm, POISON_INUSE, sizeof(mirror->hmm));

I hadn't thought of POISON_* for these types of cases, it's a=20
good technique to remember.

I noticed that this is now done outside of the lock, but that
follows directly from your commit description, so that all looks=20
correct.

>  }
>  EXPORT_SYMBOL(hmm_mirror_unregister);
> =20
>=20


    Reviewed-by: John Hubbard <jhubbard@nvidia.com>

thanks,
--=20
John Hubbard
NVIDIA

