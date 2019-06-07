Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53CC7C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:33:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03BFC20868
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:33:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="h/f6qK4e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03BFC20868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 896B46B026E; Fri,  7 Jun 2019 16:33:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 848BB6B026F; Fri,  7 Jun 2019 16:33:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70E7F6B0270; Fri,  7 Jun 2019 16:33:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0146B026E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 16:33:15 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id y3so3060654ybg.12
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 13:33:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=OLplF3FRcTtszyFZo8HGJ3SRTQEEwTp6Llhy0LgviKg=;
        b=tH9gz2/RVv6jrFA0VVHsW1a7Y9gaW5I3Q/yjH494VKTB148PMyNrxwUuc5Dh9lgsdK
         BLYlvvayYAO8jkV7j5lpddhvAIfUipJ35vsIqmMNOxQTnlZbQzgvdGtl6IReB7YLF9+0
         5kZeFqMuYG31s9Llh/GqQBj/XzCr6vATP0bzKawmR1cJ6ybgCJoijcHLKHUYeLfgsTP2
         LgDWMsyoz4s6DAXGfI4lif1ZdTed2ny+f6LS4UqG48gNvacrBp7g4X6lpGcm6ttvDkP+
         jrHnQ7pu0wqLOdG5hhVNRnhBPHXUloVOKng+/9UYfXB5zWpljdLkUVybWZtEnjxOBFp5
         3Cfg==
X-Gm-Message-State: APjAAAWv3XYM9PXttfldNq+75v7AktcsiV2auWcIE2VZtczr6iexIWrk
	vCjjZMLaLGrEjVdvCpdodNoVALsR+br3ZbLrSvy9ukHP4NnKpzkdOLGx/I7pAj3V035L9jFZ0gy
	YJdrFyW0we0gkWrnuzcAoL9E4Fua5HAREFLwEylluPHz44jLETDJIrEHGVuuji0ZZ/w==
X-Received: by 2002:a25:d113:: with SMTP id i19mr27284392ybg.277.1559939595051;
        Fri, 07 Jun 2019 13:33:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2zLHJzcKvJG7/kCNYgfP4ubaPlt5QSM5FZ1mCChBVVm0iJ9iFR1rpmDFvlaUJatB+n2iD
X-Received: by 2002:a25:d113:: with SMTP id i19mr27284372ybg.277.1559939594541;
        Fri, 07 Jun 2019 13:33:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559939594; cv=none;
        d=google.com; s=arc-20160816;
        b=VSIXt/d0UeTuqeqNiJfLtLqxyW1LJ7vY0Zk0whvwtdMRKp/sD4yiU26nvvV7XC+1+W
         C6S5c6Bq0CN3bWJ9niu5UGg1pTB8LdfF61gAd3SGXjbBwGwsBD6rcKx8+8sdE2dfN+S1
         AEjJZCqAuLGOLlDh328oQ0e6ki3tM3fmDpZLUG1ek/aJ4X/aCezYlzXJAjtpKBOEdATY
         sELybkQ8nK4fkIFSxWeKwYs+aGO1eCLyxn2jRuoQ6TF4U3DjMoGK9SuLeKUrqEmQHZEL
         fJb5aYIup1pWEgOV0qMZtePcSiiVPCnt4gL6yAV1CON2bOlFBpOMilqSkLJGjGpRazu9
         /Jyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=OLplF3FRcTtszyFZo8HGJ3SRTQEEwTp6Llhy0LgviKg=;
        b=vLYFT4vyY2aHMGdmk+HNJGF6EGRDGKwr8DObuGRWFGzcfaus/I+TNrpJT5Uav3DhxL
         SyZsPcqp+7P5pLSC4cECxDoga1/YTw/QABM9JDyGvuFInQkjchLTC9CUSHrDSc+o+pJq
         AdByhtoPIEhtIw4AfJ2IreNRX0MlWp0zvIq7lG6nyAJN1LxnNfxi45/PnB38emic9W1i
         Gh2+Oq6srnY+ixg7d1Wl+NC1q4t8zcPWL3GVOAb75IKP7+uPpYBHcRjgGA42+TPdrrsa
         0FMaQ5UYTCNOsID6KOHzuFG/Farks+4I5ZKYYDyVvOibxy+DiTeN170lrd851iAobZBF
         GvgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="h/f6qK4e";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id l2si893618ybm.249.2019.06.07.13.33.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 13:33:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="h/f6qK4e";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cfaca070000>; Fri, 07 Jun 2019 13:33:11 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 07 Jun 2019 13:33:13 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 07 Jun 2019 13:33:13 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 20:33:09 +0000
Subject: Re: [PATCH v2 hmm 08/11] mm/hmm: Remove racy protection against
 double-unregistration
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "John
 Hubbard" <jhubbard@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-9-jgg@ziepe.ca>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <ab93b81f-8d78-8760-6fc7-d981d528026d@nvidia.com>
Date: Fri, 7 Jun 2019 13:33:08 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-9-jgg@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559939591; bh=OLplF3FRcTtszyFZo8HGJ3SRTQEEwTp6Llhy0LgviKg=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=h/f6qK4es4H52bAwrizf7ejiA0ydq6aSXi0ApCfo8QG/yHMMZrPD6D9Nmp+9x+oSq
	 Y+Nai5Z3GNqdygDYEjs8tRe4G+equLunHMzhtVh3Ciw8F8asoW37NWSbhIPrTfQHdd
	 a0fJyGgIK8Tu4kQAsbdZd8AoQqCA/LCwiNlYM5clGsAnmVq+zds9aNO+EQXS3jycc2
	 Np37o+70Rfn9F8dzE5xPDkw7sWgYKlmOrgPYJvgePUegOSCUDtbT8LfpwUJTntw+E+
	 QyaZMFuwrE1L3P/k9EmQ6ReZp/TXbLu4f6FU+0KJhuGmXM05AU78hJi1m3gSauCf1R
	 lf5e197AMSsgQ==
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

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
>   mm/hmm.c | 9 ++-------
>   1 file changed, 2 insertions(+), 7 deletions(-)
>=20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index c702cd72651b53..6802de7080d172 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -284,18 +284,13 @@ EXPORT_SYMBOL(hmm_mirror_register);
>    */
>   void hmm_mirror_unregister(struct hmm_mirror *mirror)
>   {
> -	struct hmm *hmm =3D READ_ONCE(mirror->hmm);
> -
> -	if (hmm =3D=3D NULL)
> -		return;
> +	struct hmm *hmm =3D mirror->hmm;
>  =20
>   	down_write(&hmm->mirrors_sem);
>   	list_del_init(&mirror->list);
> -	/* To protect us against double unregister ... */
> -	mirror->hmm =3D NULL;
>   	up_write(&hmm->mirrors_sem);
> -
>   	hmm_put(hmm);
> +	memset(&mirror->hmm, POISON_INUSE, sizeof(mirror->hmm));
>   }
>   EXPORT_SYMBOL(hmm_mirror_unregister);
>  =20
>=20

