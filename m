Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54DCFC7618F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 21:28:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 050FF20880
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 21:28:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="eh7z35pl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 050FF20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B732A6B0005; Fri, 19 Jul 2019 17:28:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B24AF6B0006; Fri, 19 Jul 2019 17:28:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A12968E0003; Fri, 19 Jul 2019 17:28:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 81CAF6B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 17:28:42 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id l2so13942660ybl.18
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 14:28:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=lRODC3picM28oK/N+bZmg6JsfRLb3g94XTeELCxYE9E=;
        b=oIC3WLITsXGYt0ffkK+r8sDEZ23/IeikMgF0o1A5RSEXB7aU8D4Yc0OjoDVKUGFsly
         i2xs7SbjB56Fd7fiLmULR6YOqauoSGxBFbowg/LLWg2K0tTw2N0SP8ZH2mj0Yk8d8S5W
         ilAHoqM1Kax1XNmARQ3dYnnb56lTki4Jmco7ffV1Ec0NjcXkWF8UmQThVR4miN2zUd8Z
         W/6dKlDnWGk/MurjDtIR5ytI/ibKSK4h8Pv0EDWMlky3Muyw9CcIUet3k8Hn8Q9599NF
         nbheAtWvcvfrgy4sj8hPc/ai4xuyL33cODK93p/J9em8RI52to1ScYmq1xnclZdsuyfj
         B+nw==
X-Gm-Message-State: APjAAAWwkpPLF5OQEe66l54BMS0VuInLMG/cUdjPMjEavTQQVfCu9qEj
	pQ35mb6LC1twTfKqN+i35/IDnrfDewvqufQfKKJOelytQadyhDLjxyZItkUsqNRrZYpbrPz2ZeX
	Pvm/1u1aM0GstIe9bWp3s4jg4xzdP/kEY2/ah4NkV2zcRcCsLNHvJrkSRcT8WSJrqDw==
X-Received: by 2002:a0d:f2c4:: with SMTP id b187mr34603815ywf.103.1563571722276;
        Fri, 19 Jul 2019 14:28:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPIMFpdps/gUeC2U34GgycCjsLXM7S3uUXIkTen9mNEu1t/UyF6Q6FU/fQHxClS57xJYNN
X-Received: by 2002:a0d:f2c4:: with SMTP id b187mr34603762ywf.103.1563571721189;
        Fri, 19 Jul 2019 14:28:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563571721; cv=none;
        d=google.com; s=arc-20160816;
        b=wiodx1y5hhdBSUeChkONadkgcKQFgmDkO6p2Cxq+pRm1cL97N2bdk8+9H3RgrM+Fci
         Ljxmx5LL+w1RgPmFJ8fqiIcj/mqVwFJKtRGjK1DYL9O5woU/VR+kfDOWLid+HtfrPvaF
         6fNpECQQlj07NVeUmYJjq9xxuyasu8srni6vXV3baLdHAMvDbjVNcAoZyHHPmPMRAP1I
         8axhi1UB/ebelPVwi2fNZ6e1AVTZ9qOa90qMsn9AYE/+rcqSf7TA1mdG+LTr1nH+Q7C9
         sHMKlftumfcqRKHMKIAoIF5JeoDs6dlOnYA7EgZls8EUWQivI3eX1kwCAHBytrkfw9m/
         Cdmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=lRODC3picM28oK/N+bZmg6JsfRLb3g94XTeELCxYE9E=;
        b=O/pFIwBqgOHVGL0oCwRvahMpnsogNME2VUwCdPQ6Xl52OnmjnqBoxQx/Kx3+s+MY9C
         gbNzNdk2A/NzwOTsabHIApj1lgrWeD41xPbC8nqldZFzBr2+z5y2Dv/+IWupIluzsAFI
         ixcdbOO0mLsd2JbziXQHO4raJddWFnephLwT/eY3RVZgG4/1gghwZW+VpOfYZTN7NwTW
         fHsc9kqM7Why41lcGQb7Lj31sgXtWC2kOo7DvIEMDpfl2d2+cKdv4/O5kXa34wqmKd0T
         2dOAmy4T5rfF3qcSLoun3tkIiuySp/MxxxD+AzzSD2U5dkmQcb+rOGARvIGK3rYVHsqZ
         XrRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=eh7z35pl;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id x3si8719198yba.6.2019.07.19.14.28.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 14:28:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=eh7z35pl;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d32360f0000>; Fri, 19 Jul 2019 14:28:47 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 19 Jul 2019 14:28:40 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 19 Jul 2019 14:28:40 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 19 Jul
 2019 21:28:39 +0000
Subject: Re: [PATCH v3] staging: kpc2000: Convert put_page to put_user_page*()
To: Bharath Vedartham <linux.bhar@gmail.com>, <ira.weiny@intel.com>,
	<jglisse@redhat.com>, <gregkh@linuxfoundation.org>,
	<Matt.Sickler@daktronics.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<devel@driverdev.osuosl.org>
References: <20190719200235.GA16122@bharath12345-Inspiron-5559>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <8bce5bb2-d9a5-13f1-7d96-27c41057c519@nvidia.com>
Date: Fri, 19 Jul 2019 14:28:39 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190719200235.GA16122@bharath12345-Inspiron-5559>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563571727; bh=lRODC3picM28oK/N+bZmg6JsfRLb3g94XTeELCxYE9E=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=eh7z35plcsPz2hXb3Vk4ijLn+kjkYXp+kqQFis1UItWfeWWiWslIgna9z74j23y1w
	 Q5p6kMUgK3kxxE8yrzxJl2oBaGhP9lCWpVzDjx4J5U5L3MJoptfnfFPQsrvKnItylr
	 PaHNMghL3+oV9IGu+ITEooZjRac6iWut/8/G49SifFyn122eXOjrBtnNYVLFY/gm6f
	 EtFa/wQZRe+RD/FLtg+ySaGSf+Coykpae7dfsLZeZZRfDfC6LbXl9Ivt3NWswUdCGa
	 U6cdxk1zFeTxoxJkn2DubtUFF2Xml0o6HHUyuFezCwIqOEVQiD2+22q1Z1X43yos/c
	 bY5hUBHzHbByg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/19/19 1:02 PM, Bharath Vedartham wrote:
> There have been issues with coordination of various subsystems using
> get_user_pages. These issues are better described in [1].
>=20
> An implementation of tracking get_user_pages is currently underway
> The implementation requires the use put_user_page*() variants to release
> a reference rather than put_page(). The commit that introduced
> put_user_pages, Commit fc1d8e7cca2daa18d2fe56b94874848adf89d7f5 ("mm: int=
roduce
> put_user_page*(), placeholder version").
>=20
> The implementation currently simply calls put_page() within
> put_user_page(). But in the future, it is to change to add a mechanism
> to keep track of get_user_pages. Once a tracking mechanism is
> implemented, we can make attempts to work on improving on coordination
> between various subsystems using get_user_pages.
>=20
> [1] https://lwn.net/Articles/753027/

Optional: I've been fussing about how to keep the change log reasonable,
and finally came up with the following recommended template for these=20
conversion patches. This would replace the text you have above, because the=
=20
put_user_page placeholder commit has all the documentation (and then some)=
=20
that we need:


For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").


For the change itself, you will need to rebase it onto the latest=20
linux.git, as it doesn't quite apply there.=20

Testing is good if we can get it, but as far as I can tell this is
correct, so you can also add:

    Reviewed-by: John Hubbard <jhubbard@nvidia.com>

thanks,
--=20
John Hubbard
NVIDIA

>=20
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Matt Sickler <Matt.Sickler@daktronics.com>
> Cc: devel@driverdev.osuosl.org=20
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> ---
> Changes since v1
> 	- Improved changelog by John's suggestion.
> 	- Moved logic to dirty pages below sg_dma_unmap
> 	and removed PageReserved check.
> Changes since v2
> 	- Added back PageResevered check as suggested by John Hubbard.
> =09
> The PageReserved check needs a closer look and is not worth messing
> around with for now.
>=20
> Matt, Could you give any suggestions for testing this patch?
>    =20
> If in-case, you are willing to pick this up to test. Could you
> apply this patch to this tree
> https://github.com/johnhubbard/linux/tree/gup_dma_core
> and test it with your devices?
>=20
> ---
>  drivers/staging/kpc2000/kpc_dma/fileops.c | 17 ++++++-----------
>  1 file changed, 6 insertions(+), 11 deletions(-)
>=20
> diff --git a/drivers/staging/kpc2000/kpc_dma/fileops.c b/drivers/staging/=
kpc2000/kpc_dma/fileops.c
> index 6166587..75ad263 100644
> --- a/drivers/staging/kpc2000/kpc_dma/fileops.c
> +++ b/drivers/staging/kpc2000/kpc_dma/fileops.c
> @@ -198,9 +198,7 @@ int  kpc_dma_transfer(struct dev_private_data *priv, =
struct kiocb *kcb, unsigned
>  	sg_free_table(&acd->sgt);
>   err_dma_map_sg:
>   err_alloc_sg_table:
> -	for (i =3D 0 ; i < acd->page_count ; i++){
> -		put_page(acd->user_pages[i]);
> -	}
> +	put_user_pages(acd->user_pages, acd->page_count);
>   err_get_user_pages:
>  	kfree(acd->user_pages);
>   err_alloc_userpages:
> @@ -221,16 +219,13 @@ void  transfer_complete_cb(struct aio_cb_data *acd,=
 size_t xfr_count, u32 flags)
>  =09
>  	dev_dbg(&acd->ldev->pldev->dev, "transfer_complete_cb(acd =3D [%p])\n",=
 acd);
>  =09
> -	for (i =3D 0 ; i < acd->page_count ; i++){
> -		if (!PageReserved(acd->user_pages[i])){
> -			set_page_dirty(acd->user_pages[i]);
> -		}
> -	}
> -=09
>  	dma_unmap_sg(&acd->ldev->pldev->dev, acd->sgt.sgl, acd->sgt.nents, acd-=
>ldev->dir);
>  =09
> -	for (i =3D 0 ; i < acd->page_count ; i++){
> -		put_page(acd->user_pages[i]);
> +	for (i =3D 0; i < acd->page_count; i++) {
> +		if (!PageReserved(acd->user_pages[i]))
> +			put_user_pages_dirty(&acd->user_pages[i], 1);
> +		else
> +			put_user_page(acd->user_pages[i]);
>  	}
>  =09
>  	sg_free_table(&acd->sgt);
>=20

