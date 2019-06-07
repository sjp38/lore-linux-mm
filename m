Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 108EBC28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 03:19:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6A15208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 03:19:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Y2/wSIlT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6A15208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C0F96B0008; Thu,  6 Jun 2019 23:19:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 472DD6B000A; Thu,  6 Jun 2019 23:19:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33A0E6B000E; Thu,  6 Jun 2019 23:19:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07CE36B0008
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 23:19:40 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id x27so323257ote.6
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 20:19:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=9gF3uYn8obWB5VlUA+vgwaf2NDgSDG+GUN4zo8V/T7s=;
        b=PogFUYzmSHVEAHg1T3FGqy4prx6aNLb7RaGTPaLhzdehKcx7YhGNn0/AUAX5AjuIlR
         LDm9GVJwXhf9KCLrLLOKf7As7i5BmJ+OlwUh6nIzDSy/WdCQJuL0GUKL/WTq5jqzEIe7
         UihNSuYa1VyWLR2ziYqQhT/AgJmrjpmiOFA9IEuuWFhxiAmq6HGzPo8GCeZ+BX6ySjDx
         lGeCXMNqsoD2GnmHoq9yIaGUY2TJKEdqplxPkFyRT2dykpijQpQmmB0jg71t8dCNlMcc
         J/oRyK8x3jo6lgprPk0vn7gAXk+i77GVdKgXxUmTlJ0BTWKVxAiHxkPMSyxNFPwBGnWQ
         HjwQ==
X-Gm-Message-State: APjAAAXGuz4G0Uwr2lxU4i49EvL2lqQZeEykZtmfEfW4t1uU4DiXZR+1
	WbWjRcp16auLeRk8r4IHckCldk03w90ho3b+sDE+g6P2+rA8XyJt9+PItPtve0hcINvqkUM7Cs5
	G149eXmdem9sGHbSkRzDfLiqNToNQoVfYiweQm3Oeg9iV02XY4PqlsEutwRPO+JLCSw==
X-Received: by 2002:a05:6830:148c:: with SMTP id s12mr8624575otq.274.1559877579745;
        Thu, 06 Jun 2019 20:19:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrEqdb2H2tpefvX92j5FG8VtXh2O/UXnGSkztgVuXvmLO8uVLBlKZhsQgxqWW77/Z2LPhY
X-Received: by 2002:a05:6830:148c:: with SMTP id s12mr8624558otq.274.1559877579207;
        Thu, 06 Jun 2019 20:19:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559877579; cv=none;
        d=google.com; s=arc-20160816;
        b=09xaN+IYfZViurosO5a3QACEtdjc56Ej/YAgggAClj2uT7QqYR5a4+fnwowaw7VMQp
         qEYzrngAffewWLBrDnOkhSBgZIw1av6bOHbe0Xdgj5vkOI/hiSFb3aJTMZ6AVqoREApc
         JDUP+W8oyi3MF2uD+Pf554sS0PCdlWGSTNi3zmlPs3713/jJPd0/d3reszH//cxXmc/B
         r4F5gqZi0qKz6GMzNra7vFndMgVMjlihtxueA/m97DCXec8zozVlo0Nth4EMe3o60/Lc
         hCPeAdgNY+OUYN8qhwehZqthzRbbDxEU91XC9R326DRJpZbk8rJ6CqIcTT0U+9F+bscP
         kxTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=9gF3uYn8obWB5VlUA+vgwaf2NDgSDG+GUN4zo8V/T7s=;
        b=oGY5WS6td6LLAhk+VAAyWzldFStGefPlWQhbJOE57B3dAUQTRFU9v7yNRYhErfot5C
         bgMEXF7c3nJTW7QBZlVllbby9jbiqUS8HawhRMsTgShWaU7P64gg/oYwnpb06kivfPrx
         BPbZl0kwcZzYBi5Ax8SsS75SPag59H5llUH6XHERjrO9z98B/6FnGDJTWBXY4wDFfpkw
         t3Q3sYlt80Wlj0FXg4umAN3w6AsRSzoyUGbx6vdxLJsGrlGWyUKwMBEQI6xPCtzSwPIP
         M6nWf/fWEK9Xmq7R/BmtUAYg1sfbZzvySPEZVlSw+naeqNX8F/TX2xricB6uNCUVejPF
         V3jw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="Y2/wSIlT";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id z36si500508ota.112.2019.06.06.20.19.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 20:19:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="Y2/wSIlT";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf9d7bb0000>; Thu, 06 Jun 2019 20:19:23 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 06 Jun 2019 20:19:38 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 06 Jun 2019 20:19:38 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 03:19:34 +0000
Subject: Re: [PATCH v2 hmm 07/11] mm/hmm: Use lockdep instead of comments
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "Ralph
 Campbell" <rcampbell@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-8-jgg@ziepe.ca>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <c1916bf0-1cec-9742-da9a-cfb0620be1f6@nvidia.com>
Date: Thu, 6 Jun 2019 20:19:33 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-8-jgg@ziepe.ca>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559877563; bh=9gF3uYn8obWB5VlUA+vgwaf2NDgSDG+GUN4zo8V/T7s=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=Y2/wSIlTDTvSRdYSF0JE+b/OJ9Z37KAvZnjLdpqLblVoJpA9RpMEc1+t+7lodIvC+
	 K+XHIKj+M0kiuZZIjR4KCP8V9ptM6hqYnxC2cmwq9/5357Hxxim2CabkXCAfwxfrHp
	 9Wh+0tBCkMV3T7aTLJd2fnNgLpEF1E8MIZhoMqANxrZ1BOkL2sC/fAZ7g1TogRo44I
	 f3D/LwtPMs0lhTGycNl7sIhQr0vmnOvaXB9iQrOFpj6N03P5RGYLZluNdASeuRNZUt
	 CUq/h0Q3gYsBA60V6778+IW8VendGjD8aGz4nQuNAJjYGZUfIAaZiQeH5yD1+Xhn8R
	 gdpnlOI2/wIHg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
>=20
> So we can check locking at runtime.
>=20
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> ---
> v2
> - Fix missing & in lockdeps (Jason)
> ---
>  mm/hmm.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index f67ba32983d9f1..c702cd72651b53 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -254,11 +254,11 @@ static const struct mmu_notifier_ops hmm_mmu_notifi=
er_ops =3D {
>   *
>   * To start mirroring a process address space, the device driver must re=
gister
>   * an HMM mirror struct.
> - *
> - * THE mm->mmap_sem MUST BE HELD IN WRITE MODE !
>   */
>  int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
>  {
> +	lockdep_assert_held_exclusive(&mm->mmap_sem);
> +
>  	/* Sanity check */
>  	if (!mm || !mirror || !mirror->ops)
>  		return -EINVAL;
>=20

    Reviewed-by: John Hubbard <jhubbard@nvidia.com>


thanks,
--=20
John Hubbard
NVIDIA

